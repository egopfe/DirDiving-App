import Foundation

/// Sensor or derived sample quality for Apnea depth/time series.
enum ApneaDataQuality: String, Codable, CaseIterable, Hashable, Sendable {
    case measured
    case interpolated
    case estimated
    case missing
    case rejected
}
