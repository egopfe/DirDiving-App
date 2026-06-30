import Foundation

enum ApneaExportPayloadBuilder {
    struct Input: Equatable, Sendable {
        var session: ApneaSession
        var profileKind: ApneaProfileKind
        var qualityReport: ApneaSessionQualityReport
        var notes: String?
        var isDemo: Bool
    }

    static func buildText(_ input: Input, profileLabel: String, qualityLabel: String) -> String {
        let stats = input.session.refreshedStatistics()
        var lines: [String] = []
        if input.isDemo {
            lines.append("DEMO")
        }
        lines.append("Apnea Session")
        lines.append("Profile: \(profileLabel)")
        lines.append("Date: \(ISO8601DateFormatter().string(from: input.session.createdAt))")
        lines.append("Holds: \(stats.diveCount)")
        lines.append("Best hold: \(formatTime(stats.bestDiveDurationSeconds))")
        lines.append("Average hold: \(formatTime(stats.averageDiveDurationSeconds))")
        if stats.sessionMaxDepthMeters > 0 {
            lines.append("Max depth: \(String(format: "%.1f m", stats.sessionMaxDepthMeters))")
        }
        lines.append("Average recovery: \(formatTime(stats.totalRecoverySeconds / Double(max(1, stats.diveCount))))")
        lines.append("Data quality: \(qualityLabel)")
        if let notes = input.notes, !notes.isEmpty {
            lines.append("Notes: \(notes)")
        }
        lines.append("Training and logging aid only. Do not freedive alone.")
        return lines.joined(separator: "\n")
    }

    private static func formatTime(_ seconds: TimeInterval) -> String {
        let total = Int(max(0, seconds.rounded()))
        let minutes = total / 60
        let secs = total % 60
        return String(format: "%d:%02d", minutes, secs)
    }
}
