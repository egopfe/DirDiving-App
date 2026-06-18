import Foundation

enum SnorkelingDipSurfaceAssociationMethod: String, Codable, CaseIterable, Hashable, Sendable {
    case measuredAtDipStart
    case lastKnownFixBeforeDip
    case estimated
    case unavailable
}

struct SnorkelingDipSurfaceAssociation: Equatable, Hashable, Sendable {
    var method: SnorkelingDipSurfaceAssociationMethod
    var latitude: Double?
    var longitude: Double?
    var horizontalAccuracyMeters: Double?
    var associatedTrackPointID: UUID?

    var hasCoordinate: Bool {
        guard let lat = latitude, let lon = longitude else { return false }
        return SnorkelingDomainSupport.isValidCoordinate(latitude: lat, longitude: lon)
    }
}

struct SnorkelingDipDepthPoint: Equatable, Identifiable, Hashable, Sendable {
    let id: UUID
    var sessionOffsetSeconds: TimeInterval
    var depthMeters: Double
    var dipIndex: Int
}

struct SnorkelingDipMetrics: Equatable, Identifiable, Hashable, Sendable {
    var id: UUID { dipID }
    let dipID: UUID
    var dipIndex: Int
    var startedAt: Date?
    var endedAt: Date?
    var sessionOffsetSeconds: TimeInterval
    var durationSeconds: TimeInterval
    var maxDepthMeters: Double
    var averageDepthMeters: Double
    var descentSpeedMetersPerSecond: Double
    var ascentSpeedMetersPerSecond: Double
    var averageTemperatureCelsius: Double?
    var depthPoints: [SnorkelingDipDepthPoint]
    var surfaceAssociation: SnorkelingDipSurfaceAssociation
    var hasDepthProfile: Bool
}

enum SnorkelingDipAnalytics {
    static func metrics(
        for dip: SnorkelingDip,
        dipIndex: Int,
        sessionOffsetSeconds: TimeInterval,
        trackPoints: [SnorkelingTrackPoint]
    ) -> SnorkelingDipMetrics {
        let samples = SnorkelingDomainSupport.normalizedDipSamples(dip.samples)
        let depthPoints = samples.map {
            SnorkelingDipDepthPoint(
                id: $0.id,
                sessionOffsetSeconds: sessionOffsetSeconds + $0.monotonicRelativeTimestampSeconds,
                depthMeters: $0.depthMeters,
                dipIndex: dipIndex
            )
        }

        let descentSpeed = samples.compactMap(\.verticalSpeedMetersPerSecond).filter { $0 < 0 }.map { abs($0) }.max() ?? 0
        let ascentSpeed = samples.compactMap(\.verticalSpeedMetersPerSecond).filter { $0 > 0 }.max() ?? 0
        let temperatures = samples.compactMap(\.temperatureCelsius).filter(\.isFinite)
        let averageTemperature = temperatures.isEmpty ? nil : temperatures.reduce(0, +) / Double(temperatures.count)
        let association = associateSurfacePosition(
            dipStartSeconds: dip.startedAtMonotonicSeconds,
            trackPoints: trackPoints
        )

        return SnorkelingDipMetrics(
            dipID: dip.id,
            dipIndex: dipIndex,
            startedAt: dip.startedAtWallClock,
            endedAt: dip.endedAtWallClock,
            sessionOffsetSeconds: sessionOffsetSeconds,
            durationSeconds: dip.durationSeconds,
            maxDepthMeters: dip.maxDepthMeters,
            averageDepthMeters: dip.averageDepthMeters,
            descentSpeedMetersPerSecond: descentSpeed,
            ascentSpeedMetersPerSecond: ascentSpeed,
            averageTemperatureCelsius: averageTemperature,
            depthPoints: depthPoints,
            surfaceAssociation: association,
            hasDepthProfile: depthPoints.count >= 2
        )
    }

    static func metricsForSession(_ session: SnorkelingSession) -> [SnorkelingDipMetrics] {
        let ordered = session.dips.sorted { $0.startedAtMonotonicSeconds < $1.startedAtMonotonicSeconds }
        let trackPoints = SnorkelingDomainSupport.normalizedTrackPoints(session.trackPoints)
        return ordered.enumerated().map { index, dip in
            metrics(
                for: dip,
                dipIndex: index,
                sessionOffsetSeconds: dip.startedAtMonotonicSeconds,
                trackPoints: trackPoints
            )
        }
    }

    static func associateSurfacePosition(
        dipStartSeconds: TimeInterval,
        trackPoints: [SnorkelingTrackPoint]
    ) -> SnorkelingDipSurfaceAssociation {
        let ordered = trackPoints.sorted { $0.monotonicRelativeTimestampSeconds < $1.monotonicRelativeTimestampSeconds }

        if let exact = ordered.first(where: {
            abs($0.monotonicRelativeTimestampSeconds - dipStartSeconds) < 0.5
                && !$0.isUnderwater
                && $0.gpsQuality.isMeasuredSurfaceFix
                && $0.latitude != nil
                && $0.longitude != nil
        }) {
            return SnorkelingDipSurfaceAssociation(
                method: .measuredAtDipStart,
                latitude: exact.latitude,
                longitude: exact.longitude,
                horizontalAccuracyMeters: exact.horizontalAccuracyMeters,
                associatedTrackPointID: exact.id
            )
        }

        let before = ordered.last(where: {
            $0.monotonicRelativeTimestampSeconds <= dipStartSeconds
                && !$0.isUnderwater
                && $0.gpsQuality.permitsNavigation
                && $0.latitude != nil
                && $0.longitude != nil
        })
        if let before, before.gpsQuality.isMeasuredSurfaceFix {
            return SnorkelingDipSurfaceAssociation(
                method: .lastKnownFixBeforeDip,
                latitude: before.latitude,
                longitude: before.longitude,
                horizontalAccuracyMeters: before.horizontalAccuracyMeters,
                associatedTrackPointID: before.id
            )
        }

        if let estimated = ordered.last(where: {
            $0.monotonicRelativeTimestampSeconds <= dipStartSeconds
                && !$0.isUnderwater
                && $0.gpsQuality == .estimated
                && $0.latitude != nil
                && $0.longitude != nil
        }) {
            return SnorkelingDipSurfaceAssociation(
                method: .estimated,
                latitude: estimated.latitude,
                longitude: estimated.longitude,
                horizontalAccuracyMeters: estimated.horizontalAccuracyMeters,
                associatedTrackPointID: estimated.id
            )
        }

        return SnorkelingDipSurfaceAssociation(method: .unavailable)
    }
}
