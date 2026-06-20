import Foundation

/// Presentation-only route simplification for Snorkeling map rendering.
/// Persisted track points remain full fidelity; map display may use a bounded coordinate series.
enum SnorkelingRoutePresentationSampling {
    static let maxMapPresentationCoordinates = 4_096

    static func downsampleTrackPointsForPresentation(
        _ trackPoints: [SnorkelingTrackPoint],
        maxPoints: Int = maxMapPresentationCoordinates
    ) -> [SnorkelingTrackPoint] {
        let normalized = SnorkelingDomainSupport.normalizedTrackPoints(trackPoints)
        guard normalized.count > maxPoints else { return normalized }
        return PresentationSeriesDownsampler.downsampleUniform(normalized, maxPoints: maxPoints)
    }

    static func presentationPointCount(originalCount: Int, maxPoints: Int = maxMapPresentationCoordinates) -> Int {
        guard originalCount > maxPoints else { return originalCount }
        return maxPoints
    }
}
