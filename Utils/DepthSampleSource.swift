import Foundation

enum DepthSampleSource: String, Codable, Equatable, Sendable {
    case appleShallow
    case appleFull
    case simulation
    case unavailable

    var localizedLogbookLabel: String {
        switch self {
        case .appleShallow:
            return String(localized: "watch.depth_sample_source.apple_shallow")
        case .appleFull:
            return String(localized: "watch.depth_sample_source.apple_full")
        case .simulation:
            return String(localized: "watch.depth_sample_source.simulation")
        case .unavailable:
            return String(localized: "watch.depth_sample_source.unavailable")
        }
    }

    init?(persistedTag: String?) {
        guard let persistedTag, let value = DepthSampleSource(rawValue: persistedTag) else { return nil }
        self = value
    }
}

enum DepthSampleQuality: String, Codable, Equatable, Sendable {
    case measured
    case degraded
    case unavailable
}

struct DepthSample: Equatable, Sendable {
    let timestamp: Date
    let depthMeters: Double
    let pressureBar: Double?
    let temperatureCelsius: Double?
    let source: DepthSampleSource
    let quality: DepthSampleQuality
}
