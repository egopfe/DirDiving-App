import SwiftUI

enum AscentZone: String, Codable {
    case green
    case yellow
    case red
}

struct AscentStatus: Codable, Hashable {
    static let greenThresholdRatio = 0.70
    static let redThresholdRatio = 1.0

    let currentRateMetersPerMinute: Double
    let limitMetersPerMinute: Double
    let zone: AscentZone

    var isOverLimit: Bool { zone == .red }

    static func limit(for depthMeters: Double) -> Double {
        AscentRateLimits.standard.limit(for: depthMeters)
    }

    static func make(rate: Double, depth: Double) -> AscentStatus {
        make(rate: rate, depth: depth, limits: .standard)
    }

    static func make(rate: Double, depth: Double, limits: AscentRateLimits) -> AscentStatus {
        let safeDepth = depth.isFinite ? max(0, depth) : 0
        let limit = limits.limit(for: safeDepth)
        let safeRate = rate.isFinite ? max(0, rate) : 0
        let zone = zone(forRate: safeRate, limit: limit)
        return AscentStatus(currentRateMetersPerMinute: safeRate, limitMetersPerMinute: limit, zone: zone)
    }

    static func zone(forRate rate: Double, limit: Double) -> AscentZone {
        let safeLimit = limit.isFinite ? max(limit, 0.1) : 0.1
        let safeRate = rate.isFinite ? max(0, rate) : 0
        if safeRate <= safeLimit * greenThresholdRatio {
            return .green
        }
        if safeRate <= safeLimit * redThresholdRatio {
            return .yellow
        }
        return .red
    }
}

extension AscentZone {
    var color: Color {
        switch self {
        case .green: return .green
        case .yellow: return .yellow
        case .red: return .red
        }
    }
}
