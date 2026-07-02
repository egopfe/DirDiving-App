import Foundation

enum SnorkelingWatchRouteSummaryPresentationPolicy {
    static func compactSummary(for route: SnorkelingWatchImportedRoutePresentation) -> String {
        guard route.status == .ready || route.status == .pending else {
            return DIRWatchLocalizer.string("snorkeling.watch.route_no_route")
        }

        var lines: [String] = []
        if let name = route.routeName, !name.isEmpty {
            lines.append(name)
        }

        var metrics: [String] = []
        if let distance = route.plannedDistanceMeters, distance.isFinite, distance > 0 {
            metrics.append("\(Formatters.zero(distance)) m")
        }
        if let duration = route.plannedDurationSeconds, duration.isFinite, duration > 0 {
            metrics.append(formatDuration(duration))
        }
        if let waypointCount = route.waypointCount, waypointCount > 0 {
            metrics.append(
                String(
                    format: DIRWatchLocalizer.string("snorkeling.watch.route_summary.waypoints"),
                    waypointCount
                )
            )
        }
        if !metrics.isEmpty {
            lines.append(metrics.joined(separator: " · "))
        }

        lines.append(returnAlertStatusText(for: route))
        lines.append(offRouteStatusText(for: route))

        return lines.joined(separator: "\n")
    }

    static func returnAlertStatusText(for route: SnorkelingWatchImportedRoutePresentation) -> String {
        guard route.returnAlertConfigured else {
            return DIRWatchLocalizer.string("snorkeling.watch.route_summary.return_alert_off")
        }
        return DIRWatchLocalizer.string("snorkeling.watch.route_summary.return_alert_on")
    }

    static func offRouteStatusText(for route: SnorkelingWatchImportedRoutePresentation) -> String {
        if let threshold = route.offRouteThresholdMeters, threshold.isFinite, threshold > 0 {
            return String(
                format: DIRWatchLocalizer.string("snorkeling.watch.route_summary.off_route_configured"),
                Formatters.zero(threshold)
            )
        }
        return String(
            format: DIRWatchLocalizer.string("snorkeling.watch.route_summary.off_route_default"),
            Formatters.zero(SnorkelingOffRouteDetector.defaultThresholdMeters)
        )
    }

    private static func formatDuration(_ seconds: TimeInterval) -> String {
        let total = max(0, Int(seconds))
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let secs = total % 60
        if hours > 0 { return String(format: "%02d:%02d:%02d", hours, minutes, secs) }
        return String(format: "%02d:%02d", minutes, secs)
    }
}
