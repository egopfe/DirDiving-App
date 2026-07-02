import Foundation

struct SnorkelingPlannedVsActualPresentation: Equatable {
    var hasPlannedRoute: Bool
    var plannedDistanceMeters: Double?
    var actualDistanceMeters: Double
    var routeProgressPercent: Double?
    var maxOffRouteMeters: Double?
    var returnAlertTriggered: Bool
    var plannedRouteName: String?
    var comparisonSummaryKey: String
}

enum SnorkelingPlannedVsActualAnalyticsPolicy {
    static func make(session: SnorkelingSession) -> SnorkelingPlannedVsActualPresentation {
        let actualDistance = session.statistics.totalDistanceMeters
        let activePlan: SnorkelingRoutePlan? = {
            if let id = session.activeRoutePlanID {
                return session.routePlans.first(where: { $0.id == id })
            }
            return session.routePlans.first
        }()

        let plannedDistance = activePlan.map(plannedDistanceMeters(for:))
        let summary = session.runtimeSummary
        let hasRoute = activePlan != nil && (plannedDistance ?? 0) > 0
        let comparisonKey: String
        if !hasRoute {
            comparisonKey = "snorkeling.logbook.planned_vs_actual.no_route"
        } else if actualDistance <= 0 {
            comparisonKey = "snorkeling.logbook.planned_vs_actual.no_track"
        } else {
            comparisonKey = "snorkeling.logbook.planned_vs_actual.available"
        }

        return SnorkelingPlannedVsActualPresentation(
            hasPlannedRoute: hasRoute,
            plannedDistanceMeters: plannedDistance,
            actualDistanceMeters: actualDistance,
            routeProgressPercent: summary?.routeCompletedPercentage,
            maxOffRouteMeters: summary?.maxOffRouteDistanceMeters,
            returnAlertTriggered: summary?.returnAlertTriggered ?? false,
            plannedRouteName: activePlan?.name,
            comparisonSummaryKey: comparisonKey
        )
    }

    private static func plannedDistanceMeters(for plan: SnorkelingRoutePlan) -> Double {
        let coordinates = SnorkelingDomainSupport.orderedWaypoints(plan.waypoints).map {
            SnorkelingCoordinate(latitude: $0.latitude, longitude: $0.longitude)
        }
        return SnorkelingDistanceCalculator.distanceMeters(points: coordinates)
    }
}
