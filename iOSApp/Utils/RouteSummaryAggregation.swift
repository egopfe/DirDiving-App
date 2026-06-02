import Foundation

struct RouteSummaryAggregate: Equatable {
    let routeCount: Int
    let totalDistanceMeters: Double
    let bearingDegrees: Double?
    let bearingScope: RouteBearingScope
}

enum RouteBearingScope: Equatable {
    case none
    case singleRoute
    case firstOfMany(count: Int)
}

enum RouteSummaryAggregation {
    static func aggregate(from sessions: [DiveSession]) -> RouteSummaryAggregate {
        let routes = RouteSummaryService.summaries(from: sessions)
        guard let first = routes.first else {
            return RouteSummaryAggregate(
                routeCount: 0,
                totalDistanceMeters: 0,
                bearingDegrees: nil,
                bearingScope: .none
            )
        }
        let scope: RouteBearingScope = routes.count == 1 ? .singleRoute : .firstOfMany(count: routes.count)
        return RouteSummaryAggregate(
            routeCount: routes.count,
            totalDistanceMeters: routes.map(\.distanceMeters).reduce(0, +),
            bearingDegrees: first.bearingDegrees,
            bearingScope: scope
        )
    }
}
