import Foundation

enum SnorkelingRouteSyncAckPresentationStatus: Equatable {
    case notAvailable
    case pending
    case delivered
    case imported
    case rejected(reasonKey: String)
}

struct SnorkelingRouteSyncStatusPresentation: Equatable {
    var routeName: String?
    var revision: Int?
    var lastSentAt: Date?
    var ackStatus: SnorkelingRouteSyncAckPresentationStatus
    var pendingActivation: Bool
    var statusSummaryKey: String
}

enum SnorkelingRouteSyncStatusPresentationPolicy {
    static func make(
        state: IOSSnorkelingWatchSyncState,
        routeName: String?,
        lastSuccessfulSyncAt: Date?,
        lastErrorMessage: String?
    ) -> SnorkelingRouteSyncStatusPresentation {
        let ackStatus = ackStatus(for: state, lastErrorMessage: lastErrorMessage, lastSuccessfulSyncAt: lastSuccessfulSyncAt)
        let revision = revision(for: state)
        let lastSent = lastSentAt(for: state, lastSuccessfulSyncAt: lastSuccessfulSyncAt)
        let summaryKey = summaryKey(for: ackStatus, state: state)
        return SnorkelingRouteSyncStatusPresentation(
            routeName: routeName,
            revision: revision,
            lastSentAt: lastSent,
            ackStatus: ackStatus,
            pendingActivation: isPending(state),
            statusSummaryKey: summaryKey
        )
    }

    static func ackStatus(
        for state: IOSSnorkelingWatchSyncState,
        lastErrorMessage: String?,
        lastSuccessfulSyncAt: Date?
    ) -> SnorkelingRouteSyncAckPresentationStatus {
        switch state {
        case .acknowledged:
            return .imported
        case .awaitingAck, .sending, .queued:
            return .pending
        case .failed:
            return .rejected(reasonKey: lastErrorMessage ?? "snorkeling.ios.sync.failed")
        case .draft, .validated:
            return lastSuccessfulSyncAt != nil ? .delivered : .notAvailable
        }
    }

    private static func isPending(_ state: IOSSnorkelingWatchSyncState) -> Bool {
        switch state {
        case .awaitingAck, .sending, .queued: return true
        default: return false
        }
    }

    private static func revision(for state: IOSSnorkelingWatchSyncState) -> Int? {
        switch state {
        case .awaitingAck(_, let revision, _), .acknowledged(_, let revision, _):
            return revision
        default:
            return nil
        }
    }

    private static func lastSentAt(
        for state: IOSSnorkelingWatchSyncState,
        lastSuccessfulSyncAt: Date?
    ) -> Date? {
        switch state {
        case .acknowledged(_, _, let syncedAt):
            return syncedAt
        case .awaitingAck, .sending, .queued:
            return Date()
        case .draft, .validated, .failed:
            return lastSuccessfulSyncAt
        }
    }

    private static func lastSuccessfulSyncAt(_ state: IOSSnorkelingWatchSyncState) -> Date? {
        if case .acknowledged(_, _, let syncedAt) = state { return syncedAt }
        return nil
    }

    private static func summaryKey(
        for ack: SnorkelingRouteSyncAckPresentationStatus,
        state: IOSSnorkelingWatchSyncState
    ) -> String {
        switch ack {
        case .imported:
            return "snorkeling.route_sync.activated"
        case .pending:
            return "snorkeling.route_sync.pending"
        case .rejected:
            return "snorkeling.route_sync.rejected"
        case .delivered:
            return "snorkeling.route_sync.received"
        case .notAvailable:
            switch state {
            case .sending:
                return "snorkeling.route_sync.sent"
            default:
                return "snorkeling.route_sync.pending"
            }
        }
    }
}
