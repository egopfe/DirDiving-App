import Foundation

/// Apple underwater API operating depth limits for DIR DIVING safety discouragement.
enum DepthSafetyConfiguration {
    static let cautionDepthMeters = 35.0
    static let criticalDepthMeters = 38.0
    static let maximumSupportedDepthMeters = 40.0
}

enum DepthSafetyState: Equatable {
    case normal
    case caution
    case critical
    case exceeded

    static func from(depthMeters: Double) -> DepthSafetyState {
        guard depthMeters.isFinite else { return .normal }
        let depth = max(0, depthMeters)
        if depth >= DepthSafetyConfiguration.maximumSupportedDepthMeters {
            return .exceeded
        }
        if depth >= DepthSafetyConfiguration.criticalDepthMeters {
            return .critical
        }
        if depth >= DepthSafetyConfiguration.cautionDepthMeters {
            return .caution
        }
        return .normal
    }

    var suppressesPositiveDepthReinforcement: Bool {
        self == .exceeded
    }
}
