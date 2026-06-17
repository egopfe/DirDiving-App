import Foundation

enum ApneaSessionChartKind: String, CaseIterable, Hashable, Sendable {
    case depth
    case time
    case recovery
}

struct ApneaSessionDepthChartPoint: Equatable, Identifiable, Hashable, Sendable {
    let id: UUID
    var sessionOffsetSeconds: TimeInterval
    var depthMeters: Double
    var diveIndex: Int
    var isSurfaceGap: Bool
}

struct ApneaSessionDiveBar: Equatable, Identifiable, Hashable, Sendable {
    let id: UUID
    var diveIndex: Int
    var durationSeconds: TimeInterval
    var maxDepthMeters: Double
}

struct ApneaSessionTemperaturePoint: Equatable, Identifiable, Hashable, Sendable {
    let id: UUID
    var sessionOffsetSeconds: TimeInterval
    var temperatureCelsius: Double
    var diveIndex: Int
}

struct ApneaSessionRecoveryBar: Equatable, Identifiable, Hashable, Sendable {
    let id: UUID
    var diveIndex: Int
    var label: String
    var seconds: TimeInterval
}

struct ApneaSessionDiveOverlay: Equatable, Identifiable, Hashable, Sendable {
    let id: UUID
    var diveIndex: Int
    var startOffsetSeconds: TimeInterval
    var endOffsetSeconds: TimeInterval
}

struct ApneaSessionChartsModel: Equatable, Hashable, Sendable {
    var depthPoints: [ApneaSessionDepthChartPoint]
    var diveBars: [ApneaSessionDiveBar]
    var temperaturePoints: [ApneaSessionTemperaturePoint]
    var recoveryBars: [ApneaSessionRecoveryBar]
    var diveOverlays: [ApneaSessionDiveOverlay]
    var hasDepthData: Bool
    var hasTemperatureData: Bool
    var hasRecoveryData: Bool

    static let empty = ApneaSessionChartsModel(
        depthPoints: [],
        diveBars: [],
        temperaturePoints: [],
        recoveryBars: [],
        diveOverlays: [],
        hasDepthData: false,
        hasTemperatureData: false,
        hasRecoveryData: false
    )
}

enum ApneaSessionChartBuilder {
    static func build(from session: ApneaSession) -> ApneaSessionChartsModel {
        guard !session.dives.isEmpty else { return .empty }

        var depthPoints: [ApneaSessionDepthChartPoint] = []
        var diveBars: [ApneaSessionDiveBar] = []
        var temperaturePoints: [ApneaSessionTemperaturePoint] = []
        var recoveryBars: [ApneaSessionRecoveryBar] = []
        var overlays: [ApneaSessionDiveOverlay] = []

        var cursor = 0.0
        for (index, dive) in session.dives.enumerated() {
            let beforeRecovery = dive.recoveryBefore?.completedSeconds ?? dive.recoveryBefore?.plannedSeconds ?? 0
            if beforeRecovery > 0 {
                recoveryBars.append(
                    ApneaSessionRecoveryBar(
                        id: UUID(),
                        diveIndex: index,
                        label: "before",
                        seconds: beforeRecovery
                    )
                )
                cursor += beforeRecovery
                depthPoints.append(
                    ApneaSessionDepthChartPoint(
                        id: UUID(),
                        sessionOffsetSeconds: cursor,
                        depthMeters: 0,
                        diveIndex: index,
                        isSurfaceGap: true
                    )
                )
            }

            let diveStart = cursor
            let metrics = ApneaDiveAnalytics.metrics(for: dive, diveIndex: index, sessionOffsetSeconds: diveStart)
            depthPoints.append(contentsOf: metrics.depthPoints.map {
                ApneaSessionDepthChartPoint(
                    id: $0.id,
                    sessionOffsetSeconds: $0.sessionOffsetSeconds,
                    depthMeters: $0.depthMeters,
                    diveIndex: $0.diveIndex,
                    isSurfaceGap: false
                )
            })

            if metrics.depthPoints.isEmpty, dive.durationSeconds > 0 {
                depthPoints.append(
                    ApneaSessionDepthChartPoint(
                        id: UUID(),
                        sessionOffsetSeconds: diveStart,
                        depthMeters: 0,
                        diveIndex: index,
                        isSurfaceGap: false
                    )
                )
                depthPoints.append(
                    ApneaSessionDepthChartPoint(
                        id: UUID(),
                        sessionOffsetSeconds: diveStart + dive.durationSeconds,
                        depthMeters: dive.maxDepthMeters,
                        diveIndex: index,
                        isSurfaceGap: false
                    )
                )
            }

            diveBars.append(
                ApneaSessionDiveBar(
                    id: dive.id,
                    diveIndex: index,
                    durationSeconds: dive.durationSeconds,
                    maxDepthMeters: dive.maxDepthMeters
                )
            )

            for sample in dive.normalizedSamples() {
                guard let temperature = sample.temperatureCelsius, temperature.isFinite else { continue }
                temperaturePoints.append(
                    ApneaSessionTemperaturePoint(
                        id: sample.id,
                        sessionOffsetSeconds: diveStart + sample.monotonicRelativeTimestampSeconds,
                        temperatureCelsius: temperature,
                        diveIndex: index
                    )
                )
            }

            cursor = diveStart + max(dive.durationSeconds, metrics.depthPoints.last.map {
                $0.sessionOffsetSeconds - diveStart
            } ?? 0)
            overlays.append(
                ApneaSessionDiveOverlay(
                    id: dive.id,
                    diveIndex: index,
                    startOffsetSeconds: diveStart,
                    endOffsetSeconds: cursor
                )
            )

            let afterRecovery = dive.recoveryAfter?.completedSeconds ?? dive.recoveryAfter?.plannedSeconds ?? 0
            if afterRecovery > 0 {
                recoveryBars.append(
                    ApneaSessionRecoveryBar(
                        id: UUID(),
                        diveIndex: index,
                        label: "after",
                        seconds: afterRecovery
                    )
                )
                cursor += afterRecovery
                depthPoints.append(
                    ApneaSessionDepthChartPoint(
                        id: UUID(),
                        sessionOffsetSeconds: cursor,
                        depthMeters: 0,
                        diveIndex: index,
                        isSurfaceGap: true
                    )
                )
            }
        }

        return ApneaSessionChartsModel(
            depthPoints: depthPoints,
            diveBars: diveBars,
            temperaturePoints: temperaturePoints,
            recoveryBars: recoveryBars,
            diveOverlays: overlays,
            hasDepthData: depthPoints.contains { !$0.isSurfaceGap && $0.depthMeters > 0 },
            hasTemperatureData: !temperaturePoints.isEmpty,
            hasRecoveryData: recoveryBars.contains { $0.seconds > 0 }
        )
    }
}
