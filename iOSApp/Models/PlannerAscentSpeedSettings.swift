import Foundation

struct PlannerAscentSpeedSettings: Codable, Equatable, Hashable {
    var deeperThan40Meters: Double
    var from40To30Meters: Double
    var from30To20Meters: Double
    var from20To6Meters: Double
    var from6To0Meters: Double

    static let storageKey = "planner.ascentSpeedSettings.v1"

    static var `default`: PlannerAscentSpeedSettings {
        PlannerAscentSpeedSettings(
            deeperThan40Meters: 9.0,
            from40To30Meters: 9.0,
            from30To20Meters: 9.0,
            from20To6Meters: 6.0,
            from6To0Meters: 3.0
        )
    }

    static func load() -> PlannerAscentSpeedSettings {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode(PlannerAscentSpeedSettings.self, from: data) else {
            return .default
        }
        return decoded.normalized()
    }

    static func save(_ settings: PlannerAscentSpeedSettings) {
        let normalized = settings.normalized()
        guard let data = try? JSONEncoder().encode(normalized) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    func normalized() -> PlannerAscentSpeedSettings {
        PlannerAscentSpeedSettings(
            deeperThan40Meters: Self.normalizedSpeed(deeperThan40Meters, fallback: Self.default.deeperThan40Meters),
            from40To30Meters: Self.normalizedSpeed(from40To30Meters, fallback: Self.default.from40To30Meters),
            from30To20Meters: Self.normalizedSpeed(from30To20Meters, fallback: Self.default.from30To20Meters),
            from20To6Meters: Self.normalizedSpeed(from20To6Meters, fallback: Self.default.from20To6Meters),
            from6To0Meters: Self.normalizedSpeed(from6To0Meters, fallback: Self.default.from6To0Meters)
        )
    }

    func speed(forDepthMeters depth: Double) -> Double {
        guard depth.isFinite else { return Self.default.from6To0Meters }
        let value = max(0, depth)
        if value > 40 { return normalized().deeperThan40Meters }
        if value > 30 { return normalized().from40To30Meters }
        if value > 20 { return normalized().from30To20Meters }
        if value > 6 { return normalized().from20To6Meters }
        return normalized().from6To0Meters
    }

    func ascentMinutes(from startDepthMeters: Double, to endDepthMeters: Double) -> Double {
        guard startDepthMeters.isFinite, endDepthMeters.isFinite else { return 0 }
        let start = max(0, startDepthMeters)
        let end = max(0, endDepthMeters)
        guard start > end + 0.000_001 else { return 0 }

        var total = 0.0
        var current = start
        let bandFloors: [Double] = [0, 6, 20, 30, 40]

        while current > end + 0.000_001 {
            let speed = speed(forDepthMeters: current)
            guard speed.isFinite, speed > 0 else { break }
            let nextFloor = bandFloors
                .filter { $0 < current - 0.000_001 && $0 >= end - 0.000_001 }
                .max() ?? end
            let target = max(end, nextFloor)
            let distance = current - target
            guard distance.isFinite, distance > 0 else { break }
            total += distance / speed
            current = target
        }
        return total
    }

    var signature: String {
        let normalized = normalized()
        return [
            normalized.deeperThan40Meters,
            normalized.from40To30Meters,
            normalized.from30To20Meters,
            normalized.from20To6Meters,
            normalized.from6To0Meters
        ]
        .map { String(format: "%.3f", $0) }
        .joined(separator: "-")
    }

    private static func normalizedSpeed(_ value: Double, fallback: Double) -> Double {
        guard value.isFinite else { return fallback }
        return min(
            IOSAlgorithmConfiguration.maxPlannerAscentSpeedMetersPerMinute,
            max(IOSAlgorithmConfiguration.minPlannerAscentSpeedMetersPerMinute, value)
        )
    }
}

enum PlannerTransitSegmentAdjuster {
    static func adjustedSegments(
        from segments: [BuhlmannRuntimeSegment],
        using settings: PlannerAscentSpeedSettings
    ) -> [BuhlmannRuntimeSegment] {
        var currentDepth = 0.0
        return segments.map { segment in
            switch segment.kind {
            case .ascent:
                let startDepth = currentDepth
                let endDepth = segment.depthMeters
                let minutes = max(0.001, settings.ascentMinutes(from: startDepth, to: endDepth))
                currentDepth = endDepth
                return BuhlmannRuntimeSegment(
                    kind: segment.kind,
                    depthMeters: segment.depthMeters,
                    minutes: minutes,
                    gas: segment.gas,
                    note: segment.note
                )
            case .descent:
                currentDepth = max(currentDepth, segment.depthMeters)
                return segment
            case .bottom, .stop:
                currentDepth = segment.depthMeters
                return segment
            case .gasSwitch:
                return segment
            }
        }
    }
}

extension BuhlmannEngineResult {
    func withPlannerTransitMinutes(using settings: PlannerAscentSpeedSettings) -> BuhlmannEngineResult {
        let adjustedSegments = PlannerTransitSegmentAdjuster.adjustedSegments(from: segments, using: settings)
        let operationalRuntime = Int(ceil(adjustedSegments.reduce(0) { $0 + max(0, $1.minutes) }))
        return BuhlmannEngineResult(
            ndlMinutes: ndlMinutes,
            ttsMinutes: ttsMinutes,
            totalRuntimeMinutes: operationalRuntime,
            descentMinutes: descentMinutes,
            bottomMinutes: bottomMinutes,
            gasSwitchMinutes: gasSwitchMinutes,
            finalTissueState: finalTissueState,
            stops: stops,
            segments: adjustedSegments,
            tissueHistory: tissueHistory,
            issues: issues,
            modelState: modelState
        )
    }
}

extension Notification.Name {
    static let plannerAscentSpeedSettingsDidChange = Notification.Name("dirdiving_ios_planner_ascent_speed_settings_did_change")
}
