import Foundation

struct SnorkelingTrackQualityAnalytics: Equatable {
    var totalPoints: Int
    var measuredPoints: Int
    var stalePoints: Int
    var unavailablePoints: Int
    var gpsGaps: Int
    var longestGapSeconds: TimeInterval?
    var measuredPercentage: Double
    var qualityKey: String
}

enum SnorkelingTrackQualityAnalyticsPolicy {
    static let gapThresholdSeconds: TimeInterval = SnorkelingSessionMapPresentation.maxGapSecondsForContinuousSegment

    static func make(session: SnorkelingSession) -> SnorkelingTrackQualityAnalytics {
        let counts = ActivityGPSLogbookPresentation.snorkelTrackCounts(session.trackPoints)
        let total = session.trackPoints.count
        let measuredPercentage = total > 0 ? (Double(counts.measured) / Double(total)) * 100 : 0
        let gaps = gapMetrics(from: session.trackPoints)

        return SnorkelingTrackQualityAnalytics(
            totalPoints: total,
            measuredPoints: counts.measured,
            stalePoints: counts.stale,
            unavailablePoints: counts.unavailable,
            gpsGaps: gaps.gapCount,
            longestGapSeconds: gaps.longestGapSeconds,
            measuredPercentage: measuredPercentage,
            qualityKey: SnorkelingLogbookDetailPresentationPolicy.trackQualityKey(
                measured: counts.measured,
                stale: counts.stale,
                unavailable: counts.unavailable,
                total: total
            )
        )
    }

    private static func gapMetrics(from trackPoints: [SnorkelingTrackPoint]) -> (gapCount: Int, longestGapSeconds: TimeInterval?) {
        let sorted = SnorkelingDomainSupport.normalizedTrackPoints(trackPoints)
            .sorted { $0.monotonicRelativeTimestampSeconds < $1.monotonicRelativeTimestampSeconds }
        guard sorted.count >= 2 else { return (0, nil) }

        var gapCount = 0
        var longest: TimeInterval = 0
        var previous = sorted[0].monotonicRelativeTimestampSeconds
        for point in sorted.dropFirst() {
            let delta = point.monotonicRelativeTimestampSeconds - previous
            if delta > gapThresholdSeconds {
                gapCount += 1
                longest = max(longest, delta)
            }
            previous = point.monotonicRelativeTimestampSeconds
        }
        return (gapCount, longest > 0 ? longest : nil)
    }
}
