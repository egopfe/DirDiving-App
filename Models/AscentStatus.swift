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
        switch depthMeters {
        case 30..<40: return 10
        case 20..<30: return 5
        case 6..<20: return 3
        case 0..<6: return 1
        default: return 10
        }
    }

    static func make(rate: Double, depth: Double) -> AscentStatus {
        make(rate: rate, depth: depth, limits: .standard)
    }

    static func make(rate: Double, depth: Double, limits: AscentRateLimits) -> AscentStatus {
        let limit = limits.limit(for: depth)
        let safeRate = max(0, rate)
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
