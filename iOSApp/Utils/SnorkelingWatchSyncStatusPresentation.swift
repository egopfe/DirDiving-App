import Foundation

enum SnorkelingWatchSyncDeliveryStatus: Equatable {
    case pending
    case delivered
    case failed(String)
    case none
}

struct SnorkelingWatchSyncStatusPresentation: Equatable {
    var pendingSessionCount: Int
    var deliveryStatus: SnorkelingWatchSyncDeliveryStatus
    var statusKey: String
}

enum SnorkelingWatchSyncStatusPresentationPolicy {
    static func make(
        sessionSyncState: IOSSnorkelingSessionSyncService.PresentationState,
        pendingWatchToIOSSessionCount: Int = 0
    ) -> SnorkelingWatchSyncStatusPresentation {
        if pendingWatchToIOSSessionCount > 0 {
            return SnorkelingWatchSyncStatusPresentation(
                pendingSessionCount: pendingWatchToIOSSessionCount,
                deliveryStatus: .pending,
                statusKey: "snorkeling.sync.status.pending"
            )
        }
        let delivery: SnorkelingWatchSyncDeliveryStatus
        let statusKey: String
        switch sessionSyncState {
        case .failed(let reason):
            delivery = .failed(reason)
            statusKey = "snorkeling.sync.status.failed"
        case .imported, .merged:
            delivery = .delivered
            statusKey = "snorkeling.sync.status.delivered"
        case .duplicateIgnored, .localOnly:
            delivery = .none
            statusKey = "snorkeling.sync.status.delivered"
        }
        return SnorkelingWatchSyncStatusPresentation(
            pendingSessionCount: 0,
            deliveryStatus: delivery,
            statusKey: statusKey
        )
    }
}
