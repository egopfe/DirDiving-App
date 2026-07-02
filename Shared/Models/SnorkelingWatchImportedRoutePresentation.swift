import Foundation

enum SnorkelingWatchRouteReadyStatus: String, Equatable, Sendable, Codable {
    case ready
    case missing
    case pending
}

struct SnorkelingWatchImportedRoutePresentation: Equatable, Sendable {
    var status: SnorkelingWatchRouteReadyStatus
    var routeName: String?
    var revision: Int?
    var plannedDistanceMeters: Double?
    var plannedDurationSeconds: TimeInterval?
    var waypointCount: Int?
    var returnAlertConfigured: Bool
    var offRouteThresholdMeters: Double?
    var isPendingWhileSessionActive: Bool
    var staleRevisionRejected: Bool
    var lastImportErrorCode: String?

    static let missing = SnorkelingWatchImportedRoutePresentation(
        status: .missing,
        routeName: nil,
        revision: nil,
        plannedDistanceMeters: nil,
        plannedDurationSeconds: nil,
        waypointCount: nil,
        returnAlertConfigured: false,
        offRouteThresholdMeters: nil,
        isPendingWhileSessionActive: false,
        staleRevisionRejected: false,
        lastImportErrorCode: nil
    )
}
