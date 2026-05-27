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
            guard DiveSessionAlgorithmValidator.validGPS(entry),
                  DiveSessionAlgorithmValidator.validGPS(exit),
                  let distance = distance(from: entry, to: exit) else { return nil }
            return RouteSummary(
                id: session.id,
                name: session.siteName ?? "Immersione",
                startDate: session.startDate,
                distanceMeters: distance,
                bearingDegrees: bearing(from: entry, to: exit),
                entry: entry,
                exit: exit
            )
        }
    }

    static func distance(from start: GPSPoint, to end: GPSPoint) -> Double? {
        guard DiveSessionAlgorithmValidator.validGPS(start),
              DiveSessionAlgorithmValidator.validGPS(end) else { return nil }
        let radius = 6_371_000.0
        let lat1 = start.latitude * .pi / 180
        let lat2 = end.latitude * .pi / 180
        let dLat = (end.latitude - start.latitude) * .pi / 180
        let dLon = (end.longitude - start.longitude) * .pi / 180
        let a = sin(dLat / 2) * sin(dLat / 2) + cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2)
        let clamped = min(1.0, max(0.0, a))
        let distance = radius * 2 * atan2(sqrt(clamped), sqrt(1 - clamped))
        return distance.isFinite ? distance : nil
    }

    static func bearing(from start: GPSPoint, to end: GPSPoint) -> Double? {
        guard DiveSessionAlgorithmValidator.validGPS(start),
              DiveSessionAlgorithmValidator.validGPS(end) else { return nil }
        let lat1 = start.latitude * .pi / 180
        let lat2 = end.latitude * .pi / 180
        let dLon = (end.longitude - start.longitude) * .pi / 180
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let degrees = atan2(y, x) * 180 / .pi
        guard degrees.isFinite else { return nil }
        return (degrees + 360).truncatingRemainder(dividingBy: 360)
    }
}
