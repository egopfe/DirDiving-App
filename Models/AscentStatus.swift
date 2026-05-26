import SwiftUI

enum AscentZone: String, Codable {
    case green
    case yellow
    case red
}

struct AscentStatus: Codable, Hashable {
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
        let zone: AscentZone = safeRate <= limit * 0.70 ? .green : (safeRate <= limit ? .yellow : .red)
        return AscentStatus(currentRateMetersPerMinute: safeRate, limitMetersPerMinute: limit, zone: zone)
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
