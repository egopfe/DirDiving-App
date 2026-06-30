import Foundation

enum SnorkelingWaypointProgressTracker {
    static let defaultReachedThresholdMeters: Double = 25

    struct State: Equatable, Sendable {
        var reachedWaypointIDs: Set<UUID> = []
    }

    static func nextWaypointID(
        routePlan: SnorkelingRoutePlan?,
        reachedIDs: Set<UUID>
    ) -> UUID? {
        guard let routePlan else { return nil }
        let ordered = routePlan.waypoints.sorted { $0.routeOrder < $1.routeOrder }
        return ordered.first(where: { !reachedIDs.contains($0.id) })?.id
    }

    static func markReachedIfNeeded(
        current: SnorkelingCoordinate?,
        routePlan: SnorkelingRoutePlan?,
        thresholdMeters: Double = defaultReachedThresholdMeters,
        state: inout State
    ) -> UUID? {
        guard let current, let routePlan else { return nil }
        let ordered = routePlan.waypoints.sorted { $0.routeOrder < $1.routeOrder }
        for waypoint in ordered where !state.reachedWaypointIDs.contains(waypoint.id) {
            let distance = SnorkelingDomainSupport.distanceMeters(
                from: (current.latitude, current.longitude),
                to: (waypoint.latitude, waypoint.longitude)
            )
            if distance <= thresholdMeters {
                state.reachedWaypointIDs.insert(waypoint.id)
                return waypoint.id
            }
        }
        return nil
    }
}
