import Foundation

enum SnorkelingOffRouteDetector {
    static let defaultThresholdMeters: Double = 50

    static func distanceFromRouteMeters(
        current: SnorkelingCoordinate?,
        routePoints: [SnorkelingCoordinate]
    ) -> Double? {
        guard let current, routePoints.count >= 2 else { return nil }
        var minimum = Double.greatestFiniteMagnitude
        for index in 0 ..< routePoints.count - 1 {
            let start = routePoints[index]
            let end = routePoints[index + 1]
            let distance = distanceToSegment(current: current, start: start, end: end)
            minimum = min(minimum, distance)
        }
        return minimum.isFinite ? minimum : nil
    }

    static func isOffRoute(
        current: SnorkelingCoordinate?,
        routePoints: [SnorkelingCoordinate],
        thresholdMeters: Double = defaultThresholdMeters
    ) -> Bool {
        guard let distance = distanceFromRouteMeters(current: current, routePoints: routePoints) else {
            return false
        }
        return distance > thresholdMeters
    }

    private static func distanceToSegment(
        current: SnorkelingCoordinate,
        start: SnorkelingCoordinate,
        end: SnorkelingCoordinate
    ) -> Double {
        let segmentLength = SnorkelingDomainSupport.distanceMeters(
            from: (start.latitude, start.longitude),
            to: (end.latitude, end.longitude)
        )
        guard segmentLength > 0 else {
            return SnorkelingDomainSupport.distanceMeters(
                from: (start.latitude, start.longitude),
                to: (current.latitude, current.longitude)
            )
        }
        let toStart = SnorkelingDomainSupport.distanceMeters(
            from: (start.latitude, start.longitude),
            to: (current.latitude, current.longitude)
        )
        let toEnd = SnorkelingDomainSupport.distanceMeters(
            from: (current.latitude, current.longitude),
            to: (end.latitude, end.longitude)
        )
        if toStart <= segmentLength, toEnd <= segmentLength, (toStart + toEnd) <= segmentLength * 1.25 {
            return min(toStart, toEnd)
        }
        return min(toStart, toEnd)
    }
}
