import Foundation

/// Session-level data quality (distinct from per-sample `ApneaDataQuality`).
enum ApneaDataQualityLevel: String, Codable, CaseIterable, Hashable, Sendable {
    case good
    case medium
    case poor
    case unavailable
}

enum ApneaSensorSignalLevel: String, Codable, CaseIterable, Hashable, Sendable {
    case good
    case weak
    case unavailable
}

struct ApneaSensorQuality: Codable, Hashable, Sendable {
    var depth: ApneaSensorSignalLevel
    var heartRate: ApneaSensorSignalLevel
    var spO2: ApneaSensorSignalLevel

    static let unavailable = ApneaSensorQuality(depth: .unavailable, heartRate: .unavailable, spO2: .unavailable)
}

struct ApneaSessionQualityReport: Codable, Hashable, Sendable {
    var overall: ApneaDataQualityLevel
    var sensors: ApneaSensorQuality
    var sessionCompleteness: ApneaDataQualityLevel
    var validHoldCount: Int
    var recoveryTrackingComplete: Bool
    var depthAvailable: Bool
    var heartRateAvailable: Bool
    var sensorGapCount: Int
}

struct ApneaSessionSummaryMetrics: Codable, Hashable, Sendable {
    var bestHoldSeconds: TimeInterval
    var maxDepthMeters: Double
    var repetitionCount: Int
    var averageRecoverySeconds: TimeInterval
    var dataQuality: ApneaDataQualityLevel
    var lastHoldSeconds: TimeInterval
    var averageHoldSeconds: TimeInterval
}
