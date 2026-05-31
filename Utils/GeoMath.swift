import Foundation

enum GeoMath {
    static func distanceMeters(from origin: GPSPoint, to destination: GPSPoint) -> Double {
        let earthRadius = 6_371_000.0
        let lat1 = origin.latitude * .pi / 180
        let lat2 = destination.latitude * .pi / 180
        let dLat = (destination.latitude - origin.latitude) * .pi / 180
        let dLon = (destination.longitude - origin.longitude) * .pi / 180
        let a = sin(dLat / 2) * sin(dLat / 2)
            + cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        return earthRadius * c
    }

    static func bearingDegrees(from origin: GPSPoint, to destination: GPSPoint) -> Double {
        let lat1 = origin.latitude * .pi / 180
        let lat2 = destination.latitude * .pi / 180
        let dLon = (destination.longitude - origin.longitude) * .pi / 180
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radians = atan2(y, x)
        let degrees = radians * 180 / .pi
        return degrees >= 0 ? degrees : degrees + 360
    }
}
