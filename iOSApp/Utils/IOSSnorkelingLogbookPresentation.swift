import Foundation

struct IOSSnorkelingSessionRowPresentation: Equatable, Identifiable, Hashable {
    var id: UUID
    var dateText: String
    var locationText: String?
    var maxDepthText: String
    var dipCountText: String
    var durationText: String
    var distanceText: String
    var showsQualityWarning: Bool
}

struct IOSSnorkelingDipDetailPresentation: Equatable, Hashable {
    var title: String
    var timeWindowText: String
    var maxDepthText: String
    var durationText: String
    var descentSpeedText: String
    var ascentSpeedText: String
    var temperatureText: String
    var surfacePositionText: String
    var surfaceMethodKey: String
    var hasDepthProfile: Bool
    var emptyProfileKey: String?
}

struct IOSSnorkelingSessionSummaryPresentation: Equatable, Hashable {
    var title: String
    var dateText: String
    var locationText: String?
    var durationText: String
    var distanceText: String
    var maxDepthText: String
    var dipCountText: String
    var warningsText: String?
}

struct IOSSnorkelingPersonalRecordPresentation: Equatable, Identifiable, Hashable {
    var id: String
    var title: String
    var valueText: String
    var dateText: String
    var contextText: String
    var tieText: String?
}

enum IOSSnorkelingLogbookPresentationMapper {
    static func sessionRow(
        _ session: SnorkelingSession,
        units: IOSUnitPreference
    ) -> IOSSnorkelingSessionRowPresentation {
        let stats = session.refreshedStatistics()
        return IOSSnorkelingSessionRowPresentation(
            id: session.id,
            dateText: session.createdAt.formatted(date: .abbreviated, time: .shortened),
            locationText: locationLabel(for: session),
            maxDepthText: Formatters.depth(stats.sessionMaxDepthMeters, units: units).text,
            dipCountText: "\(stats.dipCount)",
            durationText: Formatters.stopwatch(stats.sessionDurationSeconds),
            distanceText: formatDistance(stats.totalDistanceMeters),
            showsQualityWarning: SnorkelingRecordEligibilityPolicy.hasInsufficientDataQuality(session)
                || SnorkelingRecordEligibilityPolicy.isSimulatedSession(session)
        )
    }

    static func sessionSummary(
        _ session: SnorkelingSession,
        units: IOSUnitPreference
    ) -> IOSSnorkelingSessionSummaryPresentation {
        let stats = session.refreshedStatistics()
        return IOSSnorkelingSessionSummaryPresentation(
            title: DIRIOSLocalizer.string("snorkeling.ios.session.detail.title"),
            dateText: session.createdAt.formatted(date: .abbreviated, time: .shortened),
            locationText: locationLabel(for: session),
            durationText: Formatters.stopwatch(stats.sessionDurationSeconds),
            distanceText: formatDistance(stats.totalDistanceMeters),
            maxDepthText: Formatters.depth(stats.sessionMaxDepthMeters, units: units).text,
            dipCountText: "\(stats.dipCount)",
            warningsText: warningSummary(for: session)
        )
    }

    static func dipDetail(
        _ metrics: SnorkelingDipMetrics,
        units: IOSUnitPreference
    ) -> IOSSnorkelingDipDetailPresentation {
        let temperatureText: String
        if let temperature = metrics.averageTemperatureCelsius {
            temperatureText = Formatters.temperature(temperature, units: units).text
        } else {
            temperatureText = "—"
        }

        let start = metrics.startedAt?.formatted(date: .omitted, time: .shortened) ?? "—"
        let end = metrics.endedAt?.formatted(date: .omitted, time: .shortened) ?? "—"

        return IOSSnorkelingDipDetailPresentation(
            title: String(format: DIRIOSLocalizer.string("snorkeling.ios.dip.title_format"), metrics.dipIndex + 1),
            timeWindowText: "\(start) – \(end)",
            maxDepthText: Formatters.depth(metrics.maxDepthMeters, units: units).text,
            durationText: Formatters.stopwatch(metrics.durationSeconds),
            descentSpeedText: String(format: "%.1f m/s", metrics.descentSpeedMetersPerSecond),
            ascentSpeedText: String(format: "%.1f m/s", metrics.ascentSpeedMetersPerSecond),
            temperatureText: temperatureText,
            surfacePositionText: surfacePositionText(for: metrics.surfaceAssociation),
            surfaceMethodKey: surfaceMethodKey(for: metrics.surfaceAssociation.method),
            hasDepthProfile: metrics.hasDepthProfile,
            emptyProfileKey: metrics.hasDepthProfile ? nil : "snorkeling.ios.dip.no_profile"
        )
    }

    static func personalRecords(
        _ summary: SnorkelingPersonalRecordsSummary,
        units: IOSUnitPreference
    ) -> [IOSSnorkelingPersonalRecordPresentation] {
        summary.records.map { record in
            IOSSnorkelingPersonalRecordPresentation(
                id: record.id,
                title: title(for: record.kind),
                valueText: formattedValue(record, units: units),
                dateText: record.sessionDate.formatted(date: .abbreviated, time: .omitted),
                contextText: context(for: record),
                tieText: record.ties.isEmpty ? nil : String(
                    format: DIRIOSLocalizer.string("snorkeling.ios.records.tie_format"),
                    record.ties.count
                )
            )
        }
    }

    private static func title(for kind: SnorkelingPersonalRecordKind) -> String {
        switch kind {
        case .deepestDip: return DIRIOSLocalizer.string("snorkeling.ios.records.deepest_dip")
        case .longestDip: return DIRIOSLocalizer.string("snorkeling.ios.records.longest_dip")
        case .greatestSessionDepth: return DIRIOSLocalizer.string("snorkeling.ios.records.best_session_depth")
        case .greatestSessionDistance: return DIRIOSLocalizer.string("snorkeling.ios.records.best_session_distance")
        case .mostDipsInSession: return DIRIOSLocalizer.string("snorkeling.ios.records.most_dips")
        case .longestSessionDuration: return DIRIOSLocalizer.string("snorkeling.ios.records.longest_session")
        }
    }

    private static func formattedValue(_ record: SnorkelingPersonalRecordEntry, units: IOSUnitPreference) -> String {
        switch record.kind {
        case .deepestDip, .greatestSessionDepth:
            return Formatters.depth(record.value, units: units).text
        case .longestDip, .longestSessionDuration:
            return Formatters.stopwatch(record.value)
        case .greatestSessionDistance:
            return formatDistance(record.value)
        case .mostDipsInSession:
            return "\(Int(record.value.rounded()))"
        }
    }

    private static func context(for record: SnorkelingPersonalRecordEntry) -> String {
        var parts: [String] = []
        if let profile = record.profileName {
            parts.append(profile)
        }
        if let dipIndex = record.dipIndex {
            parts.append(String(format: DIRIOSLocalizer.string("snorkeling.ios.dip.title_format"), dipIndex + 1))
        }
        return parts.isEmpty ? DIRIOSLocalizer.string("snorkeling.ios.records.session_context") : parts.joined(separator: " · ")
    }

    private static func warningSummary(for session: SnorkelingSession) -> String? {
        var warnings: [String] = []
        if SnorkelingRecordEligibilityPolicy.isSimulatedSession(session) {
            warnings.append(DIRIOSLocalizer.string("snorkeling.ios.session.warning.simulated"))
        }
        if SnorkelingRecordEligibilityPolicy.hasInsufficientDataQuality(session) {
            warnings.append(DIRIOSLocalizer.string("snorkeling.ios.session.warning.data_quality"))
        }
        if session.warnings.contains(.incompleteGPS) {
            warnings.append(DIRIOSLocalizer.string("snorkeling.ios.session.warning.gps"))
        }
        if session.warnings.contains(.sparseTrack) {
            warnings.append(DIRIOSLocalizer.string("snorkeling.ios.session.warning.sparse_track"))
        }
        return warnings.isEmpty ? nil : warnings.joined(separator: ", ")
    }

    private static func locationLabel(for session: SnorkelingSession) -> String? {
        if let entry = session.entryPoint,
           let lat = entry.latitude,
           let lon = entry.longitude,
           SnorkelingDomainSupport.isValidCoordinate(latitude: lat, longitude: lon) {
            return String(format: "%.4f, %.4f", lat, lon)
        }
        return nil
    }

    private static func formatDistance(_ meters: Double) -> String {
        meters >= 1_000 ? String(format: "%.2f km", meters / 1_000) : String(format: "%.0f m", meters)
    }

    private static func surfacePositionText(for association: SnorkelingDipSurfaceAssociation) -> String {
        guard association.hasCoordinate,
              let lat = association.latitude,
              let lon = association.longitude else {
            return DIRIOSLocalizer.string("snorkeling.ios.dip.surface.unavailable")
        }
        var text = String(format: "%.5f, %.5f", lat, lon)
        if let accuracy = association.horizontalAccuracyMeters {
            text += String(format: " (±%.0f m)", accuracy.rounded())
        }
        return text
    }

    private static func surfaceMethodKey(for method: SnorkelingDipSurfaceAssociationMethod) -> String {
        switch method {
        case .measuredAtDipStart: return "snorkeling.ios.dip.surface.measured_start"
        case .lastKnownFixBeforeDip: return "snorkeling.ios.dip.surface.last_known"
        case .estimated: return "snorkeling.ios.dip.surface.estimated"
        case .unavailable: return "snorkeling.ios.dip.surface.unavailable"
        }
    }
}
