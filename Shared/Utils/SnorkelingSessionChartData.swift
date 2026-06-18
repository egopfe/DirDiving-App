import Foundation

enum SnorkelingSessionChartKind: String, CaseIterable, Hashable, Sendable {
    case depth
    case distance
    case speed
    case temperature
}

struct SnorkelingSessionDepthChartPoint: Equatable, Identifiable, Hashable, Sendable {
    let id: UUID
    var sessionOffsetSeconds: TimeInterval
    var depthMeters: Double
    var dipIndex: Int
    var isSurfaceGap: Bool
}

struct SnorkelingSessionDistanceChartPoint: Equatable, Identifiable, Hashable, Sendable {
    let id: UUID
    var sessionOffsetSeconds: TimeInterval
    var cumulativeDistanceMeters: Double
    var isInterpolated: Bool
}

struct SnorkelingSessionSpeedChartPoint: Equatable, Identifiable, Hashable, Sendable {
    let id: UUID
    var sessionOffsetSeconds: TimeInterval
    var speedMetersPerSecond: Double
    var isMeasured: Bool
}

struct SnorkelingSessionTemperaturePoint: Equatable, Identifiable, Hashable, Sendable {
    let id: UUID
    var sessionOffsetSeconds: TimeInterval
    var temperatureCelsius: Double
    var dipIndex: Int
}

struct SnorkelingSessionDipBar: Equatable, Identifiable, Hashable, Sendable {
    let id: UUID
    var dipIndex: Int
    var durationSeconds: TimeInterval
    var maxDepthMeters: Double
}

struct SnorkelingSessionChartsModel: Equatable, Hashable, Sendable {
    var depthPoints: [SnorkelingSessionDepthChartPoint]
    var distancePoints: [SnorkelingSessionDistanceChartPoint]
    var speedPoints: [SnorkelingSessionSpeedChartPoint]
    var temperaturePoints: [SnorkelingSessionTemperaturePoint]
    var dipBars: [SnorkelingSessionDipBar]
    var hasDepthData: Bool
    var hasDistanceData: Bool
    var hasSpeedData: Bool
    var hasTemperatureData: Bool

    static let empty = SnorkelingSessionChartsModel(
        depthPoints: [],
        distancePoints: [],
        speedPoints: [],
        temperaturePoints: [],
        dipBars: [],
        hasDepthData: false,
        hasDistanceData: false,
        hasSpeedData: false,
        hasTemperatureData: false
    )
}

enum SnorkelingSessionChartBuilder {
    static func build(from session: SnorkelingSession) -> SnorkelingSessionChartsModel {
        let dipMetrics = SnorkelingDipAnalytics.metricsForSession(session)
        guard !dipMetrics.isEmpty || !session.trackPoints.isEmpty else { return .empty }

        var depthPoints: [SnorkelingSessionDepthChartPoint] = []
        var temperaturePoints: [SnorkelingSessionTemperaturePoint] = []
        var dipBars: [SnorkelingSessionDipBar] = []

        for metrics in dipMetrics {
            if metrics.depthPoints.isEmpty, metrics.durationSeconds > 0 {
                depthPoints.append(
                    SnorkelingSessionDepthChartPoint(
                        id: UUID(),
                        sessionOffsetSeconds: metrics.sessionOffsetSeconds,
                        depthMeters: 0,
                        dipIndex: metrics.dipIndex,
                        isSurfaceGap: false
                    )
                )
                depthPoints.append(
                    SnorkelingSessionDepthChartPoint(
                        id: UUID(),
                        sessionOffsetSeconds: metrics.sessionOffsetSeconds + metrics.durationSeconds,
                        depthMeters: metrics.maxDepthMeters,
                        dipIndex: metrics.dipIndex,
                        isSurfaceGap: false
                    )
                )
            } else {
                depthPoints.append(contentsOf: metrics.depthPoints.map {
                    SnorkelingSessionDepthChartPoint(
                        id: $0.id,
                        sessionOffsetSeconds: $0.sessionOffsetSeconds,
                        depthMeters: $0.depthMeters,
                        dipIndex: $0.dipIndex,
                        isSurfaceGap: false
                    )
                })
            }

            if let temperature = metrics.averageTemperatureCelsius {
                temperaturePoints.append(
                    SnorkelingSessionTemperaturePoint(
                        id: UUID(),
                        sessionOffsetSeconds: metrics.sessionOffsetSeconds + metrics.durationSeconds / 2,
                        temperatureCelsius: temperature,
                        dipIndex: metrics.dipIndex
                    )
                )
            }

            dipBars.append(
                SnorkelingSessionDipBar(
                    id: metrics.dipID,
                    dipIndex: metrics.dipIndex,
                    durationSeconds: metrics.durationSeconds,
                    maxDepthMeters: metrics.maxDepthMeters
                )
            )

            if metrics.dipIndex + 1 < dipMetrics.count {
                let gapStart = metrics.sessionOffsetSeconds + metrics.durationSeconds
                depthPoints.append(
                    SnorkelingSessionDepthChartPoint(
                        id: UUID(),
                        sessionOffsetSeconds: gapStart,
                        depthMeters: 0,
                        dipIndex: metrics.dipIndex,
                        isSurfaceGap: true
                    )
                )
            }
        }

        let distancePoints = buildDistancePoints(from: session.trackPoints)
        let speedPoints = buildSpeedPoints(from: session.trackPoints)

        return SnorkelingSessionChartsModel(
            depthPoints: depthPoints,
            distancePoints: distancePoints,
            speedPoints: speedPoints,
            temperaturePoints: temperaturePoints,
            dipBars: dipBars,
            hasDepthData: depthPoints.contains { !$0.isSurfaceGap && $0.depthMeters > 0 },
            hasDistanceData: distancePoints.contains { !$0.isInterpolated && $0.cumulativeDistanceMeters > 0 },
            hasSpeedData: speedPoints.contains { $0.isMeasured },
            hasTemperatureData: !temperaturePoints.isEmpty
        )
    }

    private static func buildDistancePoints(from trackPoints: [SnorkelingTrackPoint]) -> [SnorkelingSessionDistanceChartPoint] {
        let ordered = SnorkelingDomainSupport.normalizedTrackPoints(trackPoints)
        var points: [SnorkelingSessionDistanceChartPoint] = []
        var cumulative: Double = 0
        var lastMeasured: (latitude: Double, longitude: Double)?

        for point in ordered {
            guard let lat = point.latitude, let lon = point.longitude else { continue }
            let measured = point.gpsQuality.isMeasuredSurfaceFix && !point.isUnderwater
            if measured, let previous = lastMeasured {
                cumulative += SnorkelingDomainSupport.distanceMeters(
                    from: previous,
                    to: (lat, lon)
                )
                lastMeasured = (lat, lon)
            } else if measured {
                lastMeasured = (lat, lon)
            }
            points.append(
                SnorkelingSessionDistanceChartPoint(
                    id: point.id,
                    sessionOffsetSeconds: point.monotonicRelativeTimestampSeconds,
                    cumulativeDistanceMeters: cumulative,
                    isInterpolated: !measured
                )
            )
        }
        return points
    }

    private static func buildSpeedPoints(from trackPoints: [SnorkelingTrackPoint]) -> [SnorkelingSessionSpeedChartPoint] {
        SnorkelingDomainSupport.normalizedTrackPoints(trackPoints).compactMap { point in
            guard let speed = point.speedMetersPerSecond, speed.isFinite, speed >= 0 else { return nil }
            let measured = point.gpsQuality.isMeasuredSurfaceFix && !point.isUnderwater
            return SnorkelingSessionSpeedChartPoint(
                id: point.id,
                sessionOffsetSeconds: point.monotonicRelativeTimestampSeconds,
                speedMetersPerSecond: speed,
                isMeasured: measured
            )
        }
    }
}
