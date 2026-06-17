import Foundation

struct ApneaDiveDepthPoint: Equatable, Identifiable, Hashable, Sendable {
    let id: UUID
    var sessionOffsetSeconds: TimeInterval
    var depthMeters: Double
    var diveIndex: Int

    init(id: UUID = UUID(), sessionOffsetSeconds: TimeInterval, depthMeters: Double, diveIndex: Int) {
        self.id = id
        self.sessionOffsetSeconds = sessionOffsetSeconds
        self.depthMeters = depthMeters
        self.diveIndex = diveIndex
    }
}

struct ApneaDiveMetrics: Equatable, Hashable, Sendable {
    var diveIndex: Int
    var diveID: UUID
    var title: String
    var startedAt: Date?
    var maxDepthMeters: Double
    var durationSeconds: TimeInterval
    var descentSpeedMetersPerSecond: Double
    var ascentSpeedMetersPerSecond: Double
    var bottomTimeSeconds: TimeInterval
    var averageTemperatureCelsius: Double?
    var markersReached: [String]
    var alarmsTriggered: [String]
    var recoveryBeforeSeconds: TimeInterval
    var recoveryAfterSeconds: TimeInterval
    var depthPoints: [ApneaDiveDepthPoint]
    var hasDepthProfile: Bool
}

enum ApneaDiveAnalytics {
    static func metrics(
        for dive: ApneaDive,
        diveIndex: Int,
        sessionOffsetSeconds: TimeInterval
    ) -> ApneaDiveMetrics {
        let samples = dive.normalizedSamples()
        let depthPoints = buildDepthPoints(
            samples: samples,
            diveIndex: diveIndex,
            sessionOffsetSeconds: sessionOffsetSeconds
        )
        let speeds = speedMetrics(from: samples)
        let bottomTime = bottomTimeSeconds(for: dive, samples: samples)
        let temperature = averageTemperature(from: samples)
        let markers = resolvedMarkers(for: dive)
        let alarms = alarmLabels(from: dive.events)

        return ApneaDiveMetrics(
            diveIndex: diveIndex,
            diveID: dive.id,
            title: "Dive \(diveIndex + 1)",
            startedAt: dive.startedAtWallClock,
            maxDepthMeters: dive.maxDepthMeters,
            durationSeconds: dive.durationSeconds,
            descentSpeedMetersPerSecond: speeds.descent,
            ascentSpeedMetersPerSecond: speeds.ascent,
            bottomTimeSeconds: bottomTime,
            averageTemperatureCelsius: temperature,
            markersReached: markers,
            alarmsTriggered: alarms,
            recoveryBeforeSeconds: dive.recoveryBefore?.completedSeconds ?? dive.recoveryBefore?.plannedSeconds ?? 0,
            recoveryAfterSeconds: dive.recoveryAfter?.completedSeconds ?? dive.recoveryAfter?.plannedSeconds ?? 0,
            depthPoints: depthPoints,
            hasDepthProfile: !depthPoints.isEmpty
        )
    }

    private static func buildDepthPoints(
        samples: [ApneaSample],
        diveIndex: Int,
        sessionOffsetSeconds: TimeInterval
    ) -> [ApneaDiveDepthPoint] {
        samples.map { sample in
            ApneaDiveDepthPoint(
                id: sample.id,
                sessionOffsetSeconds: sessionOffsetSeconds + sample.monotonicRelativeTimestampSeconds,
                depthMeters: sample.depthMeters,
                diveIndex: diveIndex
            )
        }
    }

    private static func speedMetrics(from samples: [ApneaSample]) -> (descent: Double, ascent: Double) {
        guard !samples.isEmpty else { return (0, 0) }
        var descent = 0.0
        var ascent = 0.0
        for sample in samples where sample.quality != .rejected && sample.quality != .missing {
            if sample.verticalSpeedMetersPerSecond < -0.01 {
                descent = max(descent, abs(sample.verticalSpeedMetersPerSecond))
            } else if sample.verticalSpeedMetersPerSecond > 0.01 {
                ascent = max(ascent, sample.verticalSpeedMetersPerSecond)
            }
        }
        if descent == 0 || ascent == 0, samples.count >= 2 {
            for index in 1..<samples.count {
                let previous = samples[index - 1]
                let current = samples[index]
                let deltaT = current.monotonicRelativeTimestampSeconds - previous.monotonicRelativeTimestampSeconds
                guard deltaT > 0 else { continue }
                let speed = (current.depthMeters - previous.depthMeters) / deltaT
                if speed < -0.01 {
                    descent = max(descent, abs(speed))
                } else if speed > 0.01 {
                    ascent = max(ascent, speed)
                }
            }
        }
        return (descent, ascent)
    }

    private static func bottomTimeSeconds(for dive: ApneaDive, samples: [ApneaSample]) -> TimeInterval {
        let threshold = max(0.5, dive.maxDepthMeters * 0.85)
        guard threshold > 0 else { return 0 }
        if samples.isEmpty {
            return dive.durationSeconds > 0 ? dive.durationSeconds * 0.35 : 0
        }
        var bottom = 0.0
        for index in 1..<samples.count {
            let previous = samples[index - 1]
            let current = samples[index]
            let midpointDepth = (previous.depthMeters + current.depthMeters) * 0.5
            guard midpointDepth >= threshold else { continue }
            let delta = current.monotonicRelativeTimestampSeconds - previous.monotonicRelativeTimestampSeconds
            if delta > 0 { bottom += delta }
        }
        return bottom
    }

    private static func averageTemperature(from samples: [ApneaSample]) -> Double? {
        let values = samples.compactMap(\.temperatureCelsius).filter(\.isFinite)
        guard !values.isEmpty else { return nil }
        return values.reduce(0, +) / Double(values.count)
    }

    private static func resolvedMarkers(for dive: ApneaDive) -> [String] {
        let reached = Set(dive.reachedMarkerIDs)
        return dive.markers
            .filter { reached.contains($0.id) }
            .map { marker in
                marker.label.isEmpty ? String(format: "%.0f m", marker.depthMeters) : marker.label
            }
    }

    private static func alarmLabels(from events: [ApneaEvent]) -> [String] {
        events
            .filter { $0.kind == .alarmTriggered }
            .compactMap { event in
                if let note = event.note, !note.isEmpty { return note }
                if let depth = event.depthMeters { return String(format: "%.1f m", depth) }
                return "alarm"
            }
    }
}
