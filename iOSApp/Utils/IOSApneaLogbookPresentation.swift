import Foundation

struct IOSApneaSessionRowPresentation: Equatable, Identifiable, Hashable {
    var id: UUID
    var dateText: String
    var maxDepthText: String
    var diveCountText: String
    var durationText: String
    var showsQualityWarning: Bool
}

struct IOSApneaDiveDetailPresentation: Equatable, Hashable {
    var title: String
    var dateText: String
    var maxDepthText: String
    var durationText: String
    var descentSpeedText: String
    var ascentSpeedText: String
    var bottomTimeText: String
    var temperatureText: String
    var markersText: String
    var alarmsText: String
    var recoveryBeforeText: String
    var recoveryAfterText: String
    var hasDepthProfile: Bool
    var emptyProfileKey: String?
}

struct IOSApneaSessionSummaryPresentation: Equatable, Hashable {
    var title: String
    var dateText: String
    var maxDepthText: String
    var diveCountText: String
    var durationText: String
    var recoveryText: String
    var warningsText: String?
}

struct IOSApneaPersonalRecordPresentation: Equatable, Identifiable, Hashable {
    var id: String
    var title: String
    var valueText: String
    var dateText: String
    var contextText: String
    var tieText: String?
}

enum IOSApneaLogbookPresentationMapper {
    static func sessionRow(
        _ session: ApneaSession,
        units: IOSUnitPreference
    ) -> IOSApneaSessionRowPresentation {
        let stats = session.statistics
        return IOSApneaSessionRowPresentation(
            id: session.id,
            dateText: session.createdAt.formatted(date: .abbreviated, time: .omitted),
            maxDepthText: Formatters.depth(stats.sessionMaxDepthMeters, units: units).text,
            diveCountText: "\(stats.diveCount)",
            durationText: Formatters.stopwatch(stats.sessionDurationSeconds),
            showsQualityWarning: ApneaRecordEligibilityPolicy.hasInsufficientDataQuality(session)
                || ApneaRecordEligibilityPolicy.isSimulatedSession(session)
        )
    }

    static func sessionSummary(
        _ session: ApneaSession,
        units: IOSUnitPreference
    ) -> IOSApneaSessionSummaryPresentation {
        let stats = session.statistics
        return IOSApneaSessionSummaryPresentation(
            title: DIRIOSLocalizer.string("apnea.ios.session.detail.title"),
            dateText: session.createdAt.formatted(date: .abbreviated, time: .shortened),
            maxDepthText: Formatters.depth(stats.sessionMaxDepthMeters, units: units).text,
            diveCountText: "\(stats.diveCount)",
            durationText: Formatters.stopwatch(stats.sessionDurationSeconds),
            recoveryText: Formatters.stopwatch(stats.totalRecoverySeconds),
            warningsText: warningSummary(for: session)
        )
    }

    static func diveDetail(
        _ metrics: ApneaDiveMetrics,
        units: IOSUnitPreference
    ) -> IOSApneaDiveDetailPresentation {
        let temperatureText: String
        if let temperature = metrics.averageTemperatureCelsius {
            temperatureText = Formatters.temperature(temperature, units: units).text
        } else {
            temperatureText = "--"
        }

        return IOSApneaDiveDetailPresentation(
            title: String(format: DIRIOSLocalizer.string("apnea.ios.dive.title_format"), metrics.diveIndex + 1),
            dateText: metrics.startedAt?.formatted(date: .abbreviated, time: .shortened) ?? "--",
            maxDepthText: Formatters.depth(metrics.maxDepthMeters, units: units).text,
            durationText: Formatters.stopwatch(metrics.durationSeconds),
            descentSpeedText: String(format: "%.1f m/s", metrics.descentSpeedMetersPerSecond),
            ascentSpeedText: String(format: "%.1f m/s", metrics.ascentSpeedMetersPerSecond),
            bottomTimeText: Formatters.stopwatch(metrics.bottomTimeSeconds),
            temperatureText: temperatureText,
            markersText: metrics.markersReached.isEmpty ? "--" : metrics.markersReached.joined(separator: ", "),
            alarmsText: metrics.alarmsTriggered.isEmpty ? "--" : metrics.alarmsTriggered.joined(separator: ", "),
            recoveryBeforeText: metrics.recoveryBeforeSeconds > 0 ? Formatters.stopwatch(metrics.recoveryBeforeSeconds) : "--",
            recoveryAfterText: metrics.recoveryAfterSeconds > 0 ? Formatters.stopwatch(metrics.recoveryAfterSeconds) : "--",
            hasDepthProfile: metrics.hasDepthProfile,
            emptyProfileKey: metrics.hasDepthProfile ? nil : "apnea.ios.dive.no_profile"
        )
    }

    static func personalRecords(
        _ summary: ApneaPersonalRecordsSummary,
        units: IOSUnitPreference
    ) -> [IOSApneaPersonalRecordPresentation] {
        summary.records.map { record in
            IOSApneaPersonalRecordPresentation(
                id: record.id,
                title: title(for: record.kind),
                valueText: formattedValue(record, units: units),
                dateText: record.sessionDate.formatted(date: .abbreviated, time: .omitted),
                contextText: context(for: record),
                tieText: record.ties.isEmpty ? nil : String(
                    format: DIRIOSLocalizer.string("apnea.ios.records.tie_format"),
                    record.ties.count
                )
            )
        }
    }

    private static func title(for kind: ApneaPersonalRecordKind) -> String {
        switch kind {
        case .deepestDive: return DIRIOSLocalizer.string("apnea.ios.records.deepest_dive")
        case .longestApnea: return DIRIOSLocalizer.string("apnea.ios.records.longest_apnea")
        case .mostDivesInSession: return DIRIOSLocalizer.string("apnea.ios.records.most_dives")
        case .greatestSessionDepth: return DIRIOSLocalizer.string("apnea.ios.records.best_session_depth")
        case .greatestCumulativeDepth: return DIRIOSLocalizer.string("apnea.ios.records.cumulative_depth")
        }
    }

    private static func formattedValue(_ record: ApneaPersonalRecordEntry, units: IOSUnitPreference) -> String {
        switch record.kind {
        case .deepestDive, .greatestSessionDepth:
            return Formatters.depth(record.value, units: units).text
        case .longestApnea:
            return Formatters.stopwatch(record.value)
        case .mostDivesInSession:
            return "\(Int(record.value.rounded()))"
        case .greatestCumulativeDepth:
            return String(format: "%.0f m", record.value)
        }
    }

    private static func context(for record: ApneaPersonalRecordEntry) -> String {
        var parts: [String] = []
        if let profile = record.profileName {
            parts.append(profile)
        }
        if let diveIndex = record.diveIndex {
            parts.append(String(format: DIRIOSLocalizer.string("apnea.ios.dive.title_format"), diveIndex + 1))
        }
        return parts.isEmpty ? DIRIOSLocalizer.string("apnea.ios.records.session_context") : parts.joined(separator: " · ")
    }

    private static func warningSummary(for session: ApneaSession) -> String? {
        var warnings: [String] = []
        if ApneaRecordEligibilityPolicy.isSimulatedSession(session) {
            warnings.append(DIRIOSLocalizer.string("apnea.ios.session.warning.simulated"))
        }
        if ApneaRecordEligibilityPolicy.hasInsufficientDataQuality(session) {
            warnings.append(DIRIOSLocalizer.string("apnea.ios.session.warning.data_quality"))
        }
        if session.warnings.contains(.gpsUnavailable) {
            warnings.append(DIRIOSLocalizer.string("apnea.ios.session.warning.gps"))
        }
        return warnings.isEmpty ? nil : warnings.joined(separator: ", ")
    }
}
