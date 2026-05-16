import Foundation

struct AscentRateLimits: Codable, Hashable {
    var deepMetersPerMinute: Double
    var midMetersPerMinute: Double
    var shallowMetersPerMinute: Double
    var surfaceMetersPerMinute: Double
    var fallbackMetersPerMinute: Double

    static let standard = AscentRateLimits(
        deepMetersPerMinute: 10,
        midMetersPerMinute: 5,
        shallowMetersPerMinute: 3,
        surfaceMetersPerMinute: 1,
        fallbackMetersPerMinute: 10
    )

    func limit(for depthMeters: Double) -> Double {
        switch depthMeters {
        case 30...40: return deepMetersPerMinute
        case 20..<30: return midMetersPerMinute
        case 6..<20: return shallowMetersPerMinute
        case 0..<6: return surfaceMetersPerMinute
        default: return fallbackMetersPerMinute
        }
    }
}
