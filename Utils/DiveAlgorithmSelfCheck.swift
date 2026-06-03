import Foundation

/// Lightweight validation helpers (run from debugger or a future test target).
enum DiveAlgorithmSelfCheck {
    static func failures() -> [String] {
        averageDepthFailures()
            + ttvFailures()
            + ascentRateFailures()
            + ascentLimitFailures()
            + bearingFailures()
            + sanitizerFailures()
    }

    private static func averageDepthFailures() -> [String] {
        let start = Date(timeIntervalSince1970: 0)
        let samples = [
            DiveSample(timestamp: start, depthMeters: 10, temperatureCelsius: nil),
            DiveSample(timestamp: start.addingTimeInterval(60), depthMeters: 20, temperatureCelsius: nil),
            DiveSample(timestamp: start.addingTimeInterval(120), depthMeters: 20, temperatureCelsius: nil)
        ]
        let average = DiveAlgorithm.timeWeightedAverageDepth(
            samples: samples,
            endDate: start.addingTimeInterval(180)
        )
        return abs(average - 50.0 / 3.0) < 0.001
            ? []
            : ["time-weighted average expected 16.667, got \(average)"]
    }

    private static func ttvFailures() -> [String] {
        let ttv = DiveAlgorithm.ttvIndex(averageDepthMeters: 20, durationSeconds: 1_800)
        return abs(ttv - 50) < 0.001 ? [] : ["TTV/index expected 50, got \(ttv)"]
    }

    private static func ascentLimitFailures() -> [String] {
        let cases: [(Double, Double)] = [
            (45, 1),
            (40.01, 1),
            (35, 10),
            (25, 5),
            (10, 3),
            (3, 1)
        ]
        return cases.compactMap { depth, expected in
            let actual = AscentRateLimits.standard.limit(for: depth)
            return actual == expected ? nil : "ascent limit depth \(depth): expected \(expected), got \(actual)"
        }
    }

    private static func ascentRateFailures() -> [String] {
        let start = Date(timeIntervalSince1970: 0)
        let first = DiveSample(timestamp: start, depthMeters: 20, temperatureCelsius: nil)
        let current = DiveSample(timestamp: start.addingTimeInterval(10), depthMeters: 19, temperatureCelsius: nil)
        let rate = DiveAlgorithm.ascentRateMetersPerMinute(samples: [first, current], current: current)
        return abs(rate - 6) < 0.001 ? [] : ["ascent rate expected 6 m/min, got \(rate)"]
    }

    private static func bearingFailures() -> [String] {
        let delta = DiveAlgorithm.signedBearingDeltaDegrees(from: 350, to: 10)
        return abs(delta - 20) < 0.001 ? [] : ["bearing wrap expected +20, got \(delta)"]
    }

    private static func sanitizerFailures() -> [String] {
        var failures: [String] = []
        if DiveAlgorithm.sanitizedDepthMeters(-1) != 0 {
            failures.append("negative depth should clamp to 0")
        }
        if DiveAlgorithm.sanitizedDepthMeters(Double.infinity) != nil {
            failures.append("infinite depth should be rejected")
        }
        if DiveAlgorithm.sanitizedDepthMeters(351) != nil {
            failures.append("depth beyond plausible maximum should be rejected")
        }
        return failures
    }
}
