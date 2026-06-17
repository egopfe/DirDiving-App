import Foundation
import WatchConnectivity

enum DivePlanPackageTransferState: Equatable {
    case idle
    case sending
    case awaitingAck(planID: UUID, revision: Int, checksum: String)
    case acknowledged(planID: UUID, revision: Int, syncedAt: Date)
    case failed(message: String)
}

@MainActor
final class DivePlanPackageWatchTransferService: ObservableObject {
    @Published private(set) var state: DivePlanPackageTransferState = .idle
    @Published private(set) var lastSuccessfulSyncAt: Date?
    @Published private(set) var currentPackage: DivePlanPackage?

    private struct PendingTransfer: Equatable {
        let planID: UUID
        let revision: Int
        let checksum: String
        let packageData: Data
        let enqueuedAt: Date
    }

    private var pendingQueue: [PendingTransfer] = []
    private var activePlanID: UUID?
    private var nextRevision = 1

    func preparePackage(input: GasPlanInput, plan: DivePlanResult?, modeLabel: String) throws {
        let planID = activePlanID ?? UUID()
        activePlanID = planID
        let package = try DivePlanPackageBuilder.build(
            input: input,
            plan: plan,
            modeLabel: modeLabel,
            planID: planID,
            revision: nextRevision
        )
        currentPackage = package
    }

    func sendPreparedPackage() {
        guard let package = currentPackage else {
            state = .failed(message: DIRIOSLocalizer.string("fc.plan.transfer.failed"))
            return
        }
        send(package: package)
    }

    func send(package: DivePlanPackage) {
        guard WCSession.isSupported() else {
            state = .failed(message: DIRIOSLocalizer.string("fc.plan.transfer.failed"))
            return
        }
        let session = WCSession.default
        guard session.isPaired, session.isWatchAppInstalled else {
            state = .failed(message: DIRIOSLocalizer.string("fc.plan.transfer.watch_unavailable"))
            return
        }

        do {
            let data = try DivePlanPackageCodec.encode(package)
            let pending = PendingTransfer(
                planID: package.body.planID,
                revision: package.body.revision,
                checksum: package.payloadChecksumSHA256,
                packageData: data,
                enqueuedAt: Date()
            )
            pendingQueue.append(pending)
            currentPackage = package
            activePlanID = package.body.planID
            nextRevision = max(nextRevision, package.body.revision + 1)
            state = .sending
            flushPending(session: session)
        } catch {
            state = .failed(message: DIRIOSLocalizer.string("fc.plan.transfer.failed"))
        }
    }

    func bumpRevisionAndResend() {
        guard let current = currentPackage,
              let input = currentPackageInputSnapshot else { return }
        do {
            let package = try DivePlanPackageBuilder.build(
                input: input.gasInput,
                plan: input.plan,
                modeLabel: input.modeLabel,
                planID: current.body.planID,
                revision: current.body.revision + 1
            )
            send(package: package)
        } catch {
            state = .failed(message: DIRIOSLocalizer.string("fc.plan.transfer.failed"))
        }
    }

    private struct PackageInputSnapshot {
        let gasInput: GasPlanInput
        let plan: DivePlanResult?
        let modeLabel: String
    }

    private var currentPackageInputSnapshot: PackageInputSnapshot?

    func rememberInputSnapshot(input: GasPlanInput, plan: DivePlanResult?, modeLabel: String) {
        currentPackageInputSnapshot = PackageInputSnapshot(gasInput: input, plan: plan, modeLabel: modeLabel)
    }

    func handleAck(_ ack: DivePlanPackageTransferSupport.ParsedAck) {
        guard DivePlanPackageAckSigner.verify(
            ack.signature,
            planID: ack.planID,
            revision: ack.revision,
            checksum: ack.checksum,
            issuedAt: ack.issuedAt
        ) else {
            state = .failed(message: DIRIOSLocalizer.string("fc.plan.transfer.ack_invalid"))
            return
        }

        guard let index = pendingQueue.firstIndex(where: {
            $0.planID == ack.planID && $0.revision == ack.revision && $0.checksum == ack.checksum
        }) else { return }

        if ack.status == DivePlanPackageTransferSupport.ackStatusImported {
            pendingQueue.remove(at: index)
            let syncedAt = Date()
            lastSuccessfulSyncAt = syncedAt
            state = .acknowledged(planID: ack.planID, revision: ack.revision, syncedAt: syncedAt)
        } else {
            pendingQueue.remove(at: index)
            state = .failed(message: DIRIOSLocalizer.string("fc.plan.transfer.rejected"))
        }
    }

    func flushIfNeeded() {
        guard WCSession.isSupported() else { return }
        flushPending(session: WCSession.default)
    }

    private func flushPending(session: WCSession) {
        guard session.activationState == .activated, !pendingQueue.isEmpty else { return }
        for entry in pendingQueue {
            guard let package = try? DivePlanPackageCodec.decode(entry.packageData) else { continue }
            _ = WatchSyncAuth.mergeApplicationContext(
                DivePlanPackageTransferSupport.makeSnapshotContext(packageData: entry.packageData, package: package),
                session: session
            )
            _ = session.transferUserInfo(
                DivePlanPackageTransferSupport.makeTransferUserInfo(packageData: entry.packageData, package: package)
            )
            state = .awaitingAck(planID: entry.planID, revision: entry.revision, checksum: entry.checksum)
        }
    }

    func markPrepareFailed() {
        state = .failed(message: DIRIOSLocalizer.string("fc.plan.transfer.prepare_failed"))
    }

    #if DEBUG
    func testing_setState(_ state: DivePlanPackageTransferState) {
        self.state = state
    }

    func testing_handleAck(_ ack: DivePlanPackageTransferSupport.ParsedAck) {
        handleAck(ack)
    }
    #endif
}
