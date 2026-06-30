import Foundation

struct SnorkelingGPSQualityThresholds: Equatable, Sendable {
    var goodAccuracyMeters: Double = 15
    var mediumAccuracyMeters: Double = 35
    var goodFixAgeSeconds: TimeInterval = 10
    var mediumFixAgeSeconds: TimeInterval = 20
    var lostFixAgeSeconds: TimeInterval = 60

    static let `default` = SnorkelingGPSQualityThresholds()
}

enum SnorkelingGPSQualityEvaluator {
    static func evaluate(
        horizontalAccuracyMeters: Double?,
        fixAgeSeconds: TimeInterval?,
        hasCoordinate: Bool,
        thresholds: SnorkelingGPSQualityThresholds = .default
    ) -> SnorkelingWatchGPSPresentationBand {
        guard hasCoordinate else { return .lost }
        guard let horizontalAccuracyMeters, horizontalAccuracyMeters.isFinite, horizontalAccuracyMeters >= 0 else {
            return .lost
        }
        let age = fixAgeSeconds ?? .infinity
        if age > thresholds.lostFixAgeSeconds { return .lost }
        if horizontalAccuracyMeters <= thresholds.goodAccuracyMeters, age <= thresholds.goodFixAgeSeconds {
            return .good
        }
        if horizontalAccuracyMeters <= thresholds.mediumAccuracyMeters, age <= thresholds.mediumFixAgeSeconds {
            return .medium
        }
        return .poor
    }
}
