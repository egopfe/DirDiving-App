import Foundation

struct SnorkelingWaypointReachedReport: Equatable {
    var hasPlannedRoute: Bool
    var reachedCount: Int
    var missedCount: Int
    var reachedWaypointNames: [String]
    var isDerived: Bool
}

enum SnorkelingWaypointReachedReportPolicy {
    static func make(session: SnorkelingSession) -> SnorkelingWaypointReachedReport {
        let activePlan: SnorkelingRoutePlan? = {
            if let id = session.activeRoutePlanID {
                return session.routePlans.first(where: { $0.id == id })
            }
            return session.routePlans.first
        }()

        guard let activePlan else {
            return SnorkelingWaypointReachedReport(
                hasPlannedRoute: false,
                reachedCount: 0,
                missedCount: 0,
                reachedWaypointNames: [],
                isDerived: false
            )
        }

        let ordered = SnorkelingDomainSupport.orderedWaypoints(activePlan.waypoints)
        let eventReachedIDs = Set(
            session.events
                .filter { $0.kind == .waypointReached }
                .compactMap(\.relatedWaypointID)
        )

        if !eventReachedIDs.isEmpty {
            let reached = ordered.filter { eventReachedIDs.contains($0.id) }
            return SnorkelingWaypointReachedReport(
                hasPlannedRoute: true,
                reachedCount: reached.count,
                missedCount: max(0, ordered.count - reached.count),
                reachedWaypointNames: reached.map(\.name),
                isDerived: false
            )
        }

        return SnorkelingWaypointReachedReport(
            hasPlannedRoute: true,
            reachedCount: 0,
            missedCount: ordered.count,
            reachedWaypointNames: [],
            isDerived: false
        )
    }
}
