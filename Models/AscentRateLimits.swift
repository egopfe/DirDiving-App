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

    func normalized() -> AscentRateLimits {
        AscentRateLimits(
            deepMetersPerMinute: Self.clampedLimit(deepMetersPerMinute, fallback: Self.standard.deepMetersPerMinute),
            midMetersPerMinute: Self.clampedLimit(midMetersPerMinute, fallback: Self.standard.midMetersPerMinute),
            shallowMetersPerMinute: Self.clampedLimit(shallowMetersPerMinute, fallback: Self.standard.shallowMetersPerMinute),
            surfaceMetersPerMinute: Self.clampedLimit(surfaceMetersPerMinute, fallback: Self.standard.surfaceMetersPerMinute),
            fallbackMetersPerMinute: Self.clampedLimit(fallbackMetersPerMinute, fallback: Self.standard.fallbackMetersPerMinute)
        )
    }

    func limit(for depthMeters: Double) -> Double {
        let clean = normalized()
        guard depthMeters.isFinite else { return clean.fallbackMetersPerMinute }
        if depthMeters > DepthSafetyConfiguration.maximumSupportedDepthMeters {
            return min(clean.surfaceMetersPerMinute, clean.fallbackMetersPerMinute)
        }
        switch depthMeters {
        case 40...: return clean.deepMetersPerMinute
        case 30..<40: return clean.deepMetersPerMinute
        case 20..<30: return clean.midMetersPerMinute
        case 6..<20: return clean.shallowMetersPerMinute
        case 0..<6: return clean.surfaceMetersPerMinute
        default: return clean.fallbackMetersPerMinute
        }
    }

    private static func clampedLimit(_ value: Double, fallback: Double) -> Double {
        guard value.isFinite else { return fallback }
        return min(20, max(0.5, value))
    }
}
