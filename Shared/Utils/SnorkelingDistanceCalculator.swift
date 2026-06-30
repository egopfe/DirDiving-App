import Foundation

enum SnorkelingDistanceCalculator {
    static func distanceMeters(points: [SnorkelingCoordinate]) -> Double {
        guard points.count >= 2 else { return 0 }
        var total: Double = 0
        for index in 1 ..< points.count {
            total += SnorkelingDomainSupport.distanceMeters(
                from: (points[index - 1].latitude, points[index - 1].longitude),
                to: (points[index].latitude, points[index].longitude)
            )
        }
        return max(0, total)
    }

    static func distanceMeters(points: [SnorkelingRoutePlannerPoint]) -> Double {
        distanceMeters(points: points.map(SnorkelingCoordinate.init))
    }
}
