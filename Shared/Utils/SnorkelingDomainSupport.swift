import Foundation

enum SnorkelingDomainSupport {
    static let earthRadiusMeters: Double = 6_371_000

    static func normalizedTrackPoints(_ points: [SnorkelingTrackPoint]) -> [SnorkelingTrackPoint] {
        var seen = Set<UUID>()
        return points
            .sorted { $0.monotonicRelativeTimestampSeconds < $1.monotonicRelativeTimestampSeconds }
            .filter { seen.insert($0.id).inserted }
    }

    static func normalizedDipSamples(_ samples: [SnorkelingDipSample]) -> [SnorkelingDipSample] {
        var seen = Set<UUID>()
        return samples
            .sorted { $0.monotonicRelativeTimestampSeconds < $1.monotonicRelativeTimestampSeconds }
            .filter { seen.insert($0.id).inserted }
    }

    static func depthMetrics(from samples: [SnorkelingDipSample]) -> (maxDepthMeters: Double, averageDepthMeters: Double) {
        let depths = samples.map(\.depthMeters).filter { $0.isFinite && $0 >= 0 }
        guard !depths.isEmpty else { return (0, 0) }
        let maxDepth = depths.max() ?? 0
        let average = depths.reduce(0, +) / Double(depths.count)
        return (maxDepth, average)
    }

    static func isValidCoordinate(latitude: Double, longitude: Double) -> Bool {
        latitude.isFinite && longitude.isFinite
            && (-90 ... 90).contains(latitude)
            && (-180 ... 180).contains(longitude)
    }

    static func isFiniteOptional(_ value: Double?) -> Bool {
        guard let value else { return true }
        return value.isFinite
    }

    /// Haversine distance between two measured surface coordinates in meters.
    static func distanceMeters(
        from start: (latitude: Double, longitude: Double),
        to end: (latitude: Double, longitude: Double)
    ) -> Double {
        guard isValidCoordinate(latitude: start.latitude, longitude: start.longitude),
              isValidCoordinate(latitude: end.latitude, longitude: end.longitude) else {
            return 0
        }
        let lat1 = start.latitude * .pi / 180
        let lat2 = end.latitude * .pi / 180
        let dLat = (end.latitude - start.latitude) * .pi / 180
        let dLon = (end.longitude - start.longitude) * .pi / 180
        let a = sin(dLat / 2) * sin(dLat / 2)
            + cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        return earthRadiusMeters * c
    }

    /// Sums distance between measured surface fixes, skipping underwater/estimated gaps.
    static func trackDistanceMeters(_ points: [SnorkelingTrackPoint]) -> Double {
        let ordered = normalizedTrackPoints(points)
        var total: Double = 0
        var lastMeasuredSurface: (latitude: Double, longitude: Double)?
        for point in ordered {
            guard let lat = point.latitude,
                  let lon = point.longitude,
                  point.gpsQuality.isMeasuredSurfaceFix,
                  !point.isUnderwater else {
                continue
            }
            if let previous = lastMeasuredSurface {
                total += distanceMeters(from: (previous.latitude, previous.longitude), to: (lat, lon))
            }
            lastMeasuredSurface = (lat, lon)
        }
        return max(0, total)
    }
}
