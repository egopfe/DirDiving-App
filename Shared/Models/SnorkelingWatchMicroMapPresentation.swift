import Foundation

struct SnorkelingWatchMicroMapPoint: Equatable, Sendable {
    var x: Double
    var y: Double
}

struct SnorkelingWatchMicroMapPresentation: Equatable, Sendable {
    var isAvailable: Bool
    var routeLine: [SnorkelingWatchMicroMapPoint]
    var currentPoint: SnorkelingWatchMicroMapPoint?
    var entryDirectionDegrees: Double?
    var nextWaypointPoint: SnorkelingWatchMicroMapPoint?
    var unavailableReasonKey: String?

    static let unavailable = SnorkelingWatchMicroMapPresentation(
        isAvailable: false,
        routeLine: [],
        currentPoint: nil,
        entryDirectionDegrees: nil,
        nextWaypointPoint: nil,
        unavailableReasonKey: "snorkeling.watch.micro_map.unavailable"
    )
}
