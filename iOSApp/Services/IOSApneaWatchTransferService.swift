import Foundation
import WatchConnectivity

struct ApneaWatchTransferConnectivityContext: Equatable {
    var isSupported: Bool
    var activationState: WCSessionActivationState
    var isPaired: Bool
    var isWatchAppInstalled: Bool
    var isReachable: Bool
}

enum IOSApneaWatchSyncState: Equatable {
    case draft
    case validated
    case sending
    case queued
    case awaitingAck(packageID: UUID, revision: Int, checksum: String)
    case acknowledged(packageID: UUID, revision: Int, syncedAt: Date)
    case failed(messageKey: String)
}

@MainActor
final class IOSApneaWatchTransferService: ObservableObject {
    @Published private(set) var state: IOSApneaWatchSyncState = .draft
    @Published private(set) var lastSuccessfulSyncAt: Date?
    @Published private(set) var currentPackage: ApneaSyncPackage?
    @Published private(set) var lastErrorMessage: String?

    private struct PendingTransfer: Equatable {
        let packageID: UUID
        let revision: Int
        let checksum: String
        let packageData: Data
        let enqueuedAt: Date
    }

    private var pendingQueue: [PendingTransfer] = []
    private var activePackageID: UUID?
    private var nextRevision = 1

    var lastTransferState: IOSApneaWatchSyncState { state }

    func send(
        plan: ApneaSessionPlan,
        profile: ApneaCompanionProfile?,
        settings: ApneaCompanionSettings,
        connectivity: ApneaWatchTransferConnectivityContext
    ) -> Bool {
        lastErrorMessage = nil
        guard ApneaSessionPlanValidator.isValid(plan) else {
            state = .failed(messageKey: "apnea.ios.planner.validation_failed")
            lastErrorMessage = "apnea.ios.planner.validation_failed"
            return false
        }
        guard connectivity.isSupported else {
            state = .failed(messageKey: "apnea.ios.watch.unsupported")
            lastErrorMessage = "apnea.ios.watch.unsupported"
            return false
        }
        guard connectivity.activationState == .activated else {
            state = .queued
            lastErrorMessage = "apnea.ios.watch.not_active"
            return false
        }
        guard connectivity.isPaired, connectivity.isWatchAppInstalled else {
            state = .failed(messageKey: "apnea.ios.watch.not_paired")
            lastErrorMessage = "apnea.ios.watch.not_paired"
            return false
        }

        do {
            let packageID = activePackageID ?? plan.id
            activePackageID = packageID
            let package = try ApneaSyncPackageBuilder.build(
                plan: plan,
                profile: profile,
                settings: settings,
                packageID: packageID,
                revision: nextRevision
            )
            currentPackage = package
            nextRevision = max(nextRevision, package.body.revision + 1)
            send(package: package)
            return true
        } catch {
            state = .failed(messageKey: "apnea.ios.watch.encode_failed")
            lastErrorMessage = "apnea.ios.watch.encode_failed"
            return false
        }
    }

    func send(package: ApneaSyncPackage) {
#if DEBUG
        if Self.testHook_bypassWatchConnectivityChecks {
            enqueuePackageForTesting(package)
            return
        }
#endif
        guard WCSession.isSupported() else {
            state = .failed(messageKey: "apnea.ios.watch.unsupported")
            return
        }
        let session = WCSession.default
        guard session.isPaired, session.isWatchAppInstalled else {
            state = .failed(messageKey: "apnea.ios.watch.not_paired")
            return
        }

        do {
            let data = try ApneaSyncCodec.encode(package)
            let pending = PendingTransfer(
                packageID: package.body.packageID,
                revision: package.body.revision,
                checksum: package.payloadChecksumSHA256,
                packageData: data,
                enqueuedAt: Date()
            )
            pendingQueue.append(pending)
            currentPackage = package
            activePackageID = package.body.packageID
            nextRevision = max(nextRevision, package.body.revision + 1)
            state = .sending
            flushPending(session: session)
        } catch {
            state = .failed(messageKey: "apnea.ios.watch.encode_failed")
            lastErrorMessage = "apnea.ios.watch.encode_failed"
        }
    }

    func handleAck(_ ack: ApneaSyncTransferSupport.ParsedAck) {
        guard ApneaSyncAckSigner.verify(
            ack.signature,
            packageID: ack.packageID,
            revision: ack.revision,
            checksum: ack.checksum,
            issuedAt: ack.issuedAt
        ) else {
            state = .failed(messageKey: "apnea.ios.watch.ack_invalid")
            lastErrorMessage = "apnea.ios.watch.ack_invalid"
            return
        }

        guard let index = pendingQueue.firstIndex(where: {
            $0.packageID == ack.packageID && $0.revision == ack.revision && $0.checksum == ack.checksum
        }) else { return }

        if ack.status == ApneaSyncTransferSupport.ackStatusImported {
            pendingQueue.remove(at: index)
            let syncedAt = Date()
            lastSuccessfulSyncAt = syncedAt
            state = .acknowledged(packageID: ack.packageID, revision: ack.revision, syncedAt: syncedAt)
        } else {
            pendingQueue.remove(at: index)
            let errorKey = ack.errorCode == "staleRevision"
                ? "apnea.ios.watch.stale_revision"
                : "apnea.ios.watch.rejected"
            state = .failed(messageKey: errorKey)
            lastErrorMessage = errorKey
        }
    }

    func flushIfNeeded() {
        guard WCSession.isSupported() else { return }
        flushPending(session: WCSession.default)
    }

    private func flushPending(session: WCSession) {
        guard session.activationState == .activated, !pendingQueue.isEmpty else { return }
        for entry in pendingQueue {
            guard let package = try? ApneaSyncCodec.decode(entry.packageData) else { continue }
            _ = WatchSyncAuth.mergeApplicationContext(
                ApneaSyncTransferSupport.makeSnapshotContext(packageData: entry.packageData, package: package),
                session: session
            )
            _ = session.transferUserInfo(
                ApneaSyncTransferSupport.makeTransferUserInfo(packageData: entry.packageData, package: package)
            )
            state = .awaitingAck(packageID: entry.packageID, revision: entry.revision, checksum: entry.checksum)
        }
    }

    #if DEBUG
    static var testHook_bypassWatchConnectivityChecks = false

    private func enqueuePackageForTesting(_ package: ApneaSyncPackage) {
        do {
            let data = try ApneaSyncCodec.encode(package)
            pendingQueue.append(
                PendingTransfer(
                    packageID: package.body.packageID,
                    revision: package.body.revision,
                    checksum: package.payloadChecksumSHA256,
                    packageData: data,
                    enqueuedAt: Date()
                )
            )
            currentPackage = package
            activePackageID = package.body.packageID
            nextRevision = max(nextRevision, package.body.revision + 1)
            state = .awaitingAck(
                packageID: package.body.packageID,
                revision: package.body.revision,
                checksum: package.payloadChecksumSHA256
            )
        } catch {
            state = .failed(messageKey: "apnea.ios.watch.encode_failed")
            lastErrorMessage = "apnea.ios.watch.encode_failed"
        }
    }

    func testing_handleAck(_ ack: ApneaSyncTransferSupport.ParsedAck) {
        handleAck(ack)
    }

    func testing_reset() {
        state = .draft
        pendingQueue = []
        currentPackage = nil
        activePackageID = nil
        nextRevision = 1
        lastSuccessfulSyncAt = nil
        lastErrorMessage = nil
    }

    func testing_pendingQueueCount() -> Int { pendingQueue.count }
    #endif
}
