import Foundation

/// Deterministic presentation-only downsampling for chart and map series.
/// Canonical solver/history data remains full fidelity; display series may be reduced.
enum PresentationSeriesDownsampler {
    static let defaultMaxPresentationPoints = 2_048

    struct IndexedSample<Value: Sendable>: Sendable {
        let index: Int
        let value: Value
    }

    /// Uniform stride sampling preserving first and last points.
    static func downsampleUniform<T>(
        _ values: [T],
        maxPoints: Int = defaultMaxPresentationPoints
    ) -> [T] {
        guard values.count > maxPoints, maxPoints >= 2 else { return values }
        let stride = Double(values.count - 1) / Double(maxPoints - 1)
        var result: [T] = []
        result.reserveCapacity(maxPoints)
        var previousIndex = -1
        for slot in 0..<maxPoints {
            let index = slot == maxPoints - 1 ? values.count - 1 : Int((Double(slot) * stride).rounded(.down))
            if index != previousIndex {
                result.append(values[index])
                previousIndex = index
            }
        }
        if previousIndex != values.count - 1 {
            result.append(values[values.count - 1])
        }
        return result
    }

    /// Preserves extrema on numeric series keyed by index.
    static func downsamplePreservingExtrema(
        _ values: [Double],
        maxPoints: Int = defaultMaxPresentationPoints
    ) -> [Double] {
        guard values.count > maxPoints, maxPoints >= 4 else { return values }
        var indices = Set<Int>([0, values.count - 1])
        if let minIndex = values.indices.min(by: { values[$0] < values[$1] }) {
            indices.insert(minIndex)
        }
        if let maxIndex = values.indices.max(by: { values[$0] < values[$1] }) {
            indices.insert(maxIndex)
        }
        let remaining = max(0, maxPoints - indices.count)
        if remaining > 0 {
            let stride = Double(values.count) / Double(remaining + 1)
            for slot in 1...remaining {
                indices.insert(min(values.count - 1, Int((Double(slot) * stride).rounded(.down))))
            }
        }
        return indices.sorted().map { values[$0] }
    }
}
