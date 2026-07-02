import Foundation

struct SnorkelingLogbookDetailPresentation: Equatable {
    var trackQualityKey: String
    var gpsQualityText: String?
    var trackPointCount: Int
    var measuredPointCount: Int
    var stalePointCount: Int
    var unavailablePointCount: Int
    var routeProgressPercent: Double?
    var offRouteDistanceMeters: Double?
    var isOffRoute: Bool
    var markerCount: Int
}

enum SnorkelingLogbookDetailPresentationPolicy {
    static func make(session: SnorkelingSession) -> SnorkelingLogbookDetailPresentation {
        let counts = ActivityGPSLogbookPresentation.snorkelTrackCounts(session.trackPoints)
        let summary = session.runtimeSummary
        let gpsQualityText = summary?.gpsQualityBand.map { DIRIOSLocalizer.string($0.localizationKey) }
        let routeProgress = summary?.routeCompletedPercentage
        let offRouteDistance = summary?.maxOffRouteDistanceMeters
        let isOffRoute = (summary?.offRouteEventCount ?? 0) > 0
        return SnorkelingLogbookDetailPresentation(
            trackQualityKey: trackQualityKey(
                measured: counts.measured,
                stale: counts.stale,
                unavailable: counts.unavailable,
                total: session.trackPoints.count
            ),
            gpsQualityText: gpsQualityText,
            trackPointCount: summary?.trackPointCount ?? session.trackPoints.count,
            measuredPointCount: counts.measured,
            stalePointCount: counts.stale,
            unavailablePointCount: counts.unavailable,
            routeProgressPercent: routeProgress,
            offRouteDistanceMeters: offRouteDistance,
            isOffRoute: isOffRoute,
            markerCount: session.markers.count
        )
    }

    static func trackQualityKey(measured: Int, stale: Int, unavailable: Int, total: Int) -> String {
        guard total > 0 else { return "snorkeling.logbook.track_quality.unavailable" }
        let measuredRatio = Double(measured) / Double(total)
        if measuredRatio >= 0.75 { return "snorkeling.logbook.track_quality.good" }
        if measuredRatio >= 0.40 { return "snorkeling.logbook.track_quality.degraded" }
        if measured > 0 { return "snorkeling.logbook.track_quality.sparse" }
        return "snorkeling.logbook.track_quality.unavailable"
    }
}
