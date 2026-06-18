import Foundation
import WatchConnectivity

struct SnorkelingWatchTransferConnectivityContext: Equatable {
    var isSupported: Bool
    var activationState: WCSessionActivationState
    var isPaired: Bool
    var isWatchAppInstalled: Bool
    var isReachable: Bool
}

enum IOSSnorkelingWatchSyncState: Equatable {
    case draft
    case validated
    case sending
    case queued
    case awaitingAck(packageID: UUID, revision: Int, checksum: String)
    case acknowledged(packageID: UUID, revision: Int, syncedAt: Date)
    case failed(messageKey: String)
}

@MainActor
final class IOSSnorkelingWatchTransferService: ObservableObject {
    @Published private(set) var state: IOSSnorkelingWatchSyncState = .draft
    @Published private(set) var lastSuccessfulSyncAt: Date?
    @Published private(set) var currentPackage: SnorkelingRouteSyncPackage?
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

    func send(
        draft: SnorkelingRoutePlannerDraft,
        profile: SnorkelingCompanionProfile?,
        connectivity: SnorkelingWatchTransferConnectivityContext
    ) -> Bool {
        lastErrorMessage = nil
        guard SnorkelingRoutePlanValidator.isValid(draft: draft) else {
            state = .failed(messageKey: "snorkeling.ios.planner.validation_failed")
            lastErrorMessage = "snorkeling.ios.planner.validation_failed"
            return false
        }
        guard connectivity.isSupported else {
            state = .failed(messageKey: "snorkeling.ios.watch.unsupported")
            lastErrorMessage = "snorkeling.ios.watch.unsupported"
            return false
        }
        guard connectivity.activationState == .activated else {
            state = .queued
            lastErrorMessage = "snorkeling.ios.watch.not_active"
            return false
        }
        guard connectivity.isPaired, connectivity.isWatchAppInstalled else {
            state = .failed(messageKey: "snorkeling.ios.watch.not_paired")
            lastErrorMessage = "snorkeling.ios.watch.not_paired"
            return false
        }

        do {
            let packageID = activePackageID ?? draft.id
            activePackageID = packageID
            let package = try SnorkelingRoutePackageBuilder.build(
                draft: draft,
                profile: profile,
                packageID: packageID,
                revision: nextRevision
            )
            let data = try SnorkelingRouteSyncCodec.encode(package)
            currentPackage = package
            pendingQueue.append(
                PendingTransfer(
                    packageID: package.body.packageID,
                    revision: package.body.revision,
                    checksum: package.payloadChecksumSHA256,
                    packageData: data,
                    enqueuedAt: Date()
                )
            )
            nextRevision = max(nextRevision, package.body.revision + 1)
            state = .sending
            flushPending(session: WCSession.default)
            return true
        } catch {
            state = .failed(messageKey: "snorkeling.ios.watch.encode_failed")
            lastErrorMessage = "snorkeling.ios.watch.encode_failed"
            return false
        }
    }

    func handleAck(_ ack: SnorkelingRouteSyncTransferSupport.ParsedAck) {
        guard SnorkelingRouteSyncAckSigner.verify(
            ack.signature,
            packageID: ack.packageID,
            revision: ack.revision,
            checksum: ack.checksum,
            issuedAt: ack.issuedAt
        ) else {
            state = .failed(messageKey: "snorkeling.ios.watch.ack_invalid")
            lastErrorMessage = "snorkeling.ios.watch.ack_invalid"
            return
        }

        guard let index = pendingQueue.firstIndex(where: {
            $0.packageID == ack.packageID && $0.revision == ack.revision && $0.checksum == ack.checksum
        }) else { return }

        if ack.status == SnorkelingRouteSyncTransferSupport.ackStatusImported {
            pendingQueue.remove(at: index)
            let syncedAt = Date()
            lastSuccessfulSyncAt = syncedAt
            state = .acknowledged(packageID: ack.packageID, revision: ack.revision, syncedAt: syncedAt)
        } else {
            pendingQueue.remove(at: index)
            let errorKey = ack.errorCode == "staleRevision"
                ? "snorkeling.ios.watch.stale_revision"
                : "snorkeling.ios.watch.rejected"
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
            guard let package = try? SnorkelingRouteSyncCodec.decode(entry.packageData) else { continue }
            _ = WatchSyncAuth.mergeApplicationContext(
                SnorkelingRouteSyncTransferSupport.makeSnapshotContext(packageData: entry.packageData, package: package),
                session: session
            )
            _ = session.transferUserInfo(
                SnorkelingRouteSyncTransferSupport.makeTransferUserInfo(packageData: entry.packageData, package: package)
            )
            state = .awaitingAck(packageID: entry.packageID, revision: entry.revision, checksum: entry.checksum)
        }
    }

    #if DEBUG
    func testing_handleAck(_ ack: SnorkelingRouteSyncTransferSupport.ParsedAck) {
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
