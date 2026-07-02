import Foundation

enum SnorkelingSessionShareSummaryBuilder {
    static func build(
        for session: SnorkelingSession,
        options: SnorkelingExportPrivacyOptions = .redacted
    ) -> String {
        let redacted = SnorkelingExportPrivacyPolicy.redactedSession(session, options: options)
        let stats = redacted.refreshedStatistics()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short

        var lines = [
            DIRIOSLocalizer.string("snorkeling.export.summary.title"),
            "",
            "\(DIRIOSLocalizer.string("snorkeling.export.summary.date")): \(formatter.string(from: redacted.createdAt))",
            "\(DIRIOSLocalizer.string("snorkeling.export.summary.duration")): \(formatSeconds(stats.sessionDurationSeconds))",
            "\(DIRIOSLocalizer.string("snorkeling.export.summary.distance")): \(Int(stats.totalDistanceMeters.rounded())) m",
            "\(DIRIOSLocalizer.string("snorkeling.export.summary.max_depth")): \(String(format: "%.1f m", stats.sessionMaxDepthMeters))",
            "\(DIRIOSLocalizer.string("snorkeling.export.summary.dips")): \(stats.dipCount)",
            "\(DIRIOSLocalizer.string("snorkeling.export.summary.markers")): \(redacted.markers.count)",
        ]

        let measuredPoints = SnorkelingExportPrivacyPolicy.measuredSurfacePoints(from: redacted).count
        if measuredPoints > 0, options.locationPrecision != .removed {
            lines.append("\(DIRIOSLocalizer.string("snorkeling.export.summary.track_points")): \(measuredPoints)")
        }

        if let buddy = redacted.buddy?.name, !buddy.isEmpty, options.includeBuddyContactDetails {
            lines.append("\(DIRIOSLocalizer.string("snorkeling.export.summary.buddy")): \(buddy)")
        }

        lines.append("")
        lines.append(DIRIOSLocalizer.string("snorkeling.export.summary.footer"))
        return lines.joined(separator: "\n")
    }

    private static func formatSeconds(_ seconds: TimeInterval) -> String {
        let total = max(0, Int(seconds))
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let secs = total % 60
        if hours > 0 { return String(format: "%d:%02d:%02d", hours, minutes, secs) }
        return String(format: "%d:%02d", minutes, secs)
    }
}
