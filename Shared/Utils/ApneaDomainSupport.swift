import Foundation

enum ApneaDomainSupport {
    static func normalizedSamples(_ samples: [ApneaSample]) -> [ApneaSample] {
        var seen = Set<UUID>()
        return samples
            .sorted { $0.monotonicRelativeTimestampSeconds < $1.monotonicRelativeTimestampSeconds }
            .filter { seen.insert($0.id).inserted }
    }

    static func depthMetrics(from samples: [ApneaSample]) -> (maxDepthMeters: Double, averageDepthMeters: Double) {
        let depths = samples.map(\.depthMeters).filter { $0.isFinite && $0 >= 0 }
        guard !depths.isEmpty else { return (0, 0) }
        let maxDepth = depths.max() ?? 0
        let average = depths.reduce(0, +) / Double(depths.count)
        return (maxDepth, average)
    }

    static func isFinite(_ value: Double) -> Bool {
        value.isFinite
    }

    static func isFiniteOptional(_ value: Double?) -> Bool {
        guard let value else { return true }
        return value.isFinite
    }
}
