import Foundation

enum SnorkelingDistanceCalculator {
    static func distanceMeters(points: [SnorkelingCoordinate]) -> Double {
        guard points.count >= 2 else { return 0 }
        var total: Double = 0
        var lastValid: SnorkelingCoordinate?
        for point in points {
            guard SnorkelingDomainSupport.isValidCoordinate(
                latitude: point.latitude,
                longitude: point.longitude
            ) else {
                continue
            }
            if let previous = lastValid {
                total += SnorkelingDomainSupport.distanceMeters(
                    from: (previous.latitude, previous.longitude),
                    to: (point.latitude, point.longitude)
                )
            }
            lastValid = point
        }
        return max(0, total)
    }

    static func distanceMeters(points: [SnorkelingRoutePlannerPoint]) -> Double {
        distanceMeters(points: points.map(SnorkelingCoordinate.init))
    }
}
