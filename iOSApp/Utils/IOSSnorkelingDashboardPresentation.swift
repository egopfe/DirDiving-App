import Foundation

struct IOSSnorkelingDashboardPresentation {
    var hasLastSession: Bool
    var lastSessionDateText: String
    var lastSessionDurationText: String
    var lastSessionMaxDepthText: String
    var lastSessionDistanceText: String
    var totalDistanceText: String
    var maxDepthText: String
    var sessionCountText: String
    var totalWaterTimeText: String
    var sessionsThisMonthText: String
    var averageMaxDepthText: String
    var watchConnectivityText: String
    var watchConnectivityIsPositive: Bool
    var syncStatusText: String
    var syncStatusIsPositive: Bool
    var mapPreviewAvailable: Bool
    var mapCoordinates: [(latitude: Double, longitude: Double)]
    var emptyStateText: String?
}

enum IOSSnorkelingDashboardPresentationMapper {
    private static func sessionsThisMonthCount(from sessions: [SnorkelingSession], reference: Date = Date()) -> Int {
        let startOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: reference)) ?? reference
        return sessions.filter { $0.createdAt >= startOfMonth }.count
    }

    static func make(
        lastSession: SnorkelingSession?,
        sessions: [SnorkelingSession],
        statistics: SnorkelingLogbookStatistics,
        watchConnectivityText: String,
        watchConnectivityIsPositive: Bool,
        syncStatusText: String,
        syncStatusIsPositive: Bool,
        locale: Locale = .current
    ) -> IOSSnorkelingDashboardPresentation {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateStyle = .medium
        formatter.timeStyle = .short

        let mapCoordinates = mapPreviewCoordinates(from: lastSession)
        let sessionsThisMonth = sessionsThisMonthCount(from: sessions)

        if let lastSession {
            let stats = lastSession.statistics
            return IOSSnorkelingDashboardPresentation(
                hasLastSession: true,
                lastSessionDateText: formatter.string(from: lastSession.createdAt),
                lastSessionDurationText: Formatters.time(stats.sessionDurationSeconds),
                lastSessionMaxDepthText: formatDepth(stats.sessionMaxDepthMeters),
                lastSessionDistanceText: formatDistance(stats.totalDistanceMeters),
                totalDistanceText: formatDistance(statistics.totalMeasuredDistanceMeters),
                maxDepthText: formatDepth(statistics.bestSessionMaxDepthMeters),
                sessionCountText: "\(statistics.sessionCount)",
                totalWaterTimeText: Formatters.time(statistics.totalWaterTimeSeconds),
                sessionsThisMonthText: "\(sessionsThisMonth)",
                averageMaxDepthText: formatDepth(averageMaxDepth(from: sessions)),
                watchConnectivityText: watchConnectivityText,
                watchConnectivityIsPositive: watchConnectivityIsPositive,
                syncStatusText: syncStatusText,
                syncStatusIsPositive: syncStatusIsPositive,
                mapPreviewAvailable: !mapCoordinates.isEmpty,
                mapCoordinates: mapCoordinates,
                emptyStateText: nil
            )
        }

        return IOSSnorkelingDashboardPresentation(
            hasLastSession: false,
            lastSessionDateText: "—",
            lastSessionDurationText: "—",
            lastSessionMaxDepthText: "—",
            lastSessionDistanceText: "—",
            totalDistanceText: statistics.totalMeasuredDistanceMeters > 0 ? formatDistance(statistics.totalMeasuredDistanceMeters) : "—",
            maxDepthText: statistics.bestSessionMaxDepthMeters > 0 ? formatDepth(statistics.bestSessionMaxDepthMeters) : "—",
            sessionCountText: statistics.sessionCount > 0 ? "\(statistics.sessionCount)" : "—",
            totalWaterTimeText: statistics.totalWaterTimeSeconds > 0 ? Formatters.time(statistics.totalWaterTimeSeconds) : "—",
            sessionsThisMonthText: "—",
            averageMaxDepthText: "—",
            watchConnectivityText: watchConnectivityText,
            watchConnectivityIsPositive: watchConnectivityIsPositive,
            syncStatusText: syncStatusText,
            syncStatusIsPositive: syncStatusIsPositive,
            mapPreviewAvailable: false,
            mapCoordinates: [],
            emptyStateText: "snorkeling.ios.dashboard.empty"
        )
    }

    private static func formatDepth(_ meters: Double) -> String {
        String(format: "%.1f m", meters)
    }

    private static func formatDistance(_ meters: Double) -> String {
        meters >= 1_000 ? String(format: "%.2f km", meters / 1_000) : String(format: "%.0f m", meters)
    }

    private static func mapPreviewCoordinates(from session: SnorkelingSession?) -> [(latitude: Double, longitude: Double)] {
        guard let session else { return [] }
        return SnorkelingDomainSupport.normalizedTrackPoints(session.trackPoints).compactMap { point in
            guard let lat = point.latitude, let lon = point.longitude, point.gpsQuality.isMeasuredSurfaceFix else { return nil }
            return (lat, lon)
        }
    }

    private static func averageMaxDepth(from sessions: [SnorkelingSession]) -> Double {
        let depths = sessions
            .filter { SnorkelingRecordEligibilityPolicy.isEligibleForStatistics($0) }
            .map(\.statistics.sessionMaxDepthMeters)
        guard !depths.isEmpty else { return 0 }
        return depths.reduce(0, +) / Double(depths.count)
    }
}

enum IOSSnorkelingProfilePresentation {
    static func subtitle(for profile: SnorkelingCompanionProfile) -> String {
        var parts: [String] = []
        if let duration = profile.targetDurationSeconds {
            parts.append(Formatters.time(duration))
        }
        if let distance = profile.maxDistanceMeters {
            parts.append(String(format: "%.0f m", distance))
        }
        if let depth = profile.maxDepthMeters {
            parts.append(String(format: "%.0f m", depth))
        }
        let alarmCount = profile.alarms.filter(\.isEnabled).count
        if alarmCount > 0 {
            parts.append("\(alarmCount)")
        }
        if profile.missionModeEnabled {
            parts.append("Mission")
        }
        return parts.joined(separator: " · ")
    }
}

enum IOSSnorkelingRoutePresentation {
    static func distanceText(meters: Double) -> String {
        meters >= 1_000 ? String(format: "%.2f km", meters / 1_000) : String(format: "%.0f m", meters)
    }

    static func durationText(seconds: TimeInterval) -> String {
        Formatters.time(seconds)
    }

    static func validationText(for issue: SnorkelingRouteValidationIssue) -> String {
        switch issue {
        case .emptyName: return "snorkeling.ios.planner.issue.empty_name"
        case .missingEntry: return "snorkeling.ios.planner.issue.missing_entry"
        case .missingExit: return "snorkeling.ios.planner.issue.missing_exit"
        case .insufficientPoints: return "snorkeling.ios.planner.issue.insufficient_points"
        case .invalidCoordinate: return "snorkeling.ios.planner.issue.invalid_coordinate"
        case .exceedsMaxDistance: return "snorkeling.ios.planner.issue.exceeds_distance"
        case .duplicatePoint: return "snorkeling.ios.planner.issue.duplicate_point"
        }
    }
}
