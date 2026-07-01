import Foundation

enum SnorkelingRouteProgressCalculator {
    static func progressPercent(
        current: SnorkelingCoordinate?,
        routePoints: [SnorkelingCoordinate]
    ) -> Double? {
        guard let current, routePoints.count >= 2 else { return nil }
        let segments = segmentLengths(routePoints)
        let total = segments.reduce(0, +)
        guard total > 0 else { return nil }

        var bestProgress: Double = 0
        var traversed: Double = 0
        for index in 0 ..< routePoints.count - 1 {
            let start = routePoints[index]
            let end = routePoints[index + 1]
            let segmentLength = segments[index]
            guard segmentLength > 0 else {
                traversed += segmentLength
                continue
            }
            let projection = projectedDistanceAlongSegment(
                current: current,
                start: start,
                end: end
            )
            let distToSegmentStart = SnorkelingDomainSupport.distanceMeters(
                from: (current.latitude, current.longitude),
                to: (start.latitude, start.longitude)
            )
            if index > 0, projection <= 0, distToSegmentStart > 0 {
                traversed += segmentLength
                continue
            }
            let clamped = min(max(0, projection), segmentLength)
            bestProgress = max(bestProgress, (traversed + clamped) / total)
            traversed += segmentLength
        }
        return min(100, max(0, bestProgress * 100))
    }

    private static func segmentLengths(_ points: [SnorkelingCoordinate]) -> [Double] {
        guard points.count >= 2 else { return [] }
        return (0 ..< points.count - 1).map { index in
            SnorkelingDomainSupport.distanceMeters(
                from: (points[index].latitude, points[index].longitude),
                to: (points[index + 1].latitude, points[index + 1].longitude)
            )
        }
    }

    private static func projectedDistanceAlongSegment(
        current: SnorkelingCoordinate,
        start: SnorkelingCoordinate,
        end: SnorkelingCoordinate
    ) -> Double {
        let segmentLength = SnorkelingDomainSupport.distanceMeters(
            from: (start.latitude, start.longitude),
            to: (end.latitude, end.longitude)
        )
        guard segmentLength > 0 else { return 0 }
        let toCurrent = SnorkelingDomainSupport.distanceMeters(
            from: (start.latitude, start.longitude),
            to: (current.latitude, current.longitude)
        )
        let toEnd = SnorkelingDomainSupport.distanceMeters(
            from: (current.latitude, current.longitude),
            to: (end.latitude, end.longitude)
        )
        if toEnd > segmentLength + toCurrent { return 0 }
        // Before segment start along the polyline (e.g. at route entry before later legs).
        if toEnd > segmentLength, toCurrent > 0 { return 0 }
        return min(segmentLength, toCurrent)
    }
}
