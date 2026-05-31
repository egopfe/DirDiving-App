import Foundation

struct RouteSummary: Identifiable, Hashable {
    let id: UUID
    let name: String
    let startDate: Date
    let distanceMeters: Double
    let bearingDegrees: Double?
    let entry: GPSPoint
    let exit: GPSPoint
}

enum RouteSummaryService {
    static func summaries(from sessions: [DiveSession]) -> [RouteSummary] {
        sessions.compactMap { session in
            guard let entry = session.entryGPS, let exit = session.exitGPS else { return nil }
            guard DiveProfileMath.isValidGPS(entry), DiveProfileMath.isValidGPS(exit) else { return nil }
            return RouteSummary(
                id: session.id,
                name: session.siteName ?? "Immersione",
                startDate: session.startDate,
                distanceMeters: distance(from: entry, to: exit),
                bearingDegrees: bearing(from: entry, to: exit),
                entry: entry,
                exit: exit
            )
        }
    }

    static func distance(from start: GPSPoint, to end: GPSPoint) -> Double {
        guard DiveProfileMath.isValidGPS(start), DiveProfileMath.isValidGPS(end) else { return 0 }
        if start.latitude == end.latitude, start.longitude == end.longitude { return 0 }
        let radius = IOSAlgorithmConfiguration.routeEarthRadiusMeters
        let lat1 = start.latitude * .pi / 180
        let lat2 = end.latitude * .pi / 180
        let dLat = (end.latitude - start.latitude) * .pi / 180
        let dLon = (end.longitude - start.longitude) * .pi / 180
        let a = sin(dLat / 2) * sin(dLat / 2) + cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2)
        let meters = radius * 2 * atan2(sqrt(a), sqrt(max(0, 1 - a)))
        return meters.isFinite ? meters : 0
    }

    static func bearing(from start: GPSPoint, to end: GPSPoint) -> Double? {
        guard DiveProfileMath.isValidGPS(start), DiveProfileMath.isValidGPS(end) else { return nil }
        guard start.latitude != end.latitude || start.longitude != end.longitude else { return nil }
        let lat1 = start.latitude * .pi / 180
        let lat2 = end.latitude * .pi / 180
        let dLon = (end.longitude - start.longitude) * .pi / 180
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let degrees = atan2(y, x) * 180 / .pi
        let normalized = (degrees + 360).truncatingRemainder(dividingBy: 360)
        return normalized.isFinite ? normalized : nil
    }
}
