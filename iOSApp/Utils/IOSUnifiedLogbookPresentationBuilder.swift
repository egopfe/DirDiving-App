import Foundation

enum IOSUnifiedLogbookPresentationBuilder {
    static func build(
        divingSessions: [DiveSession],
        snorkelingSessions: [SnorkelingSession],
        apneaSessions: [ApneaSession],
        units: IOSUnitPreference = .metric,
        includeDivingDemo: Bool = false,
        includeSnorkelingDemo: Bool = false,
        includeApneaDemo: Bool = false
    ) -> [IOSUnifiedLogbookEntry] {
        var entries: [IOSUnifiedLogbookEntry] = []
        entries.reserveCapacity(divingSessions.count + snorkelingSessions.count + apneaSessions.count)

        for session in divingSessions {
            let isDemo = session.isDemoDive
            guard includeDivingDemo || !isDemo else { continue }
            entries.append(mapDiving(session, units: units, isDemo: isDemo))
        }
        for session in snorkelingSessions {
            let isDemo = DemoSnorkelingSessionCatalog.isDemoSession(id: session.id)
            guard includeSnorkelingDemo || !isDemo else { continue }
            entries.append(mapSnorkeling(session, units: units, isDemo: isDemo))
        }
        for session in apneaSessions {
            let isDemo = DemoApneaSessionCatalog.isDemoSession(id: session.id)
            guard includeApneaDemo || !isDemo else { continue }
            entries.append(mapApnea(session, units: units, isDemo: isDemo))
        }

        return entries.sorted { $0.date > $1.date }
    }

    private static func mapDiving(
        _ session: DiveSession,
        units: IOSUnitPreference,
        isDemo: Bool
    ) -> IOSUnifiedLogbookEntry {
        let site = session.siteName ?? DIRIOSLocalizer.string("detail.default_site")
        let dateText = session.startDate.formatted(date: .abbreviated, time: .shortened)
        let subtitle = [dateText, site].joined(separator: " · ")
        let duration = DIRIOSLocalizer.formatted("logbook.card.duration", Formatters.time(session.durationSeconds))
        let maxDepth: String
        if session.isManual, !session.hasDepthProfile {
            maxDepth = DIRIOSLocalizer.string("logbook.card.runtime_gps_only")
        } else {
            maxDepth = DIRIOSLocalizer.formatted(
                "logbook.card.max_depth",
                Formatters.depth(session.maxDepthMeters, units: units).text
            )
        }
        let tertiary = session.gasLabel.rawValue

        return IOSUnifiedLogbookEntry(
            id: "\(IOSUnifiedLogbookActivityKind.diving.rawValue)-\(session.id.uuidString)",
            sourceID: session.id,
            activity: .diving,
            date: session.startDate,
            title: DIRIOSLocalizer.string("logbook.activity.diving"),
            subtitle: subtitle,
            primaryMetric: duration,
            secondaryMetric: maxDepth,
            tertiaryMetric: tertiary,
            isDemo: isDemo
        )
    }

    private static func mapSnorkeling(
        _ session: SnorkelingSession,
        units: IOSUnitPreference,
        isDemo: Bool
    ) -> IOSUnifiedLogbookEntry {
        let row = IOSSnorkelingLogbookPresentationMapper.sessionRow(session, units: units)
        var subtitleParts: [String] = []
        if let location = row.locationText, !location.isEmpty {
            subtitleParts.append(location)
        }
        subtitleParts.append(row.dateText)
        let subtitle = subtitleParts.joined(separator: " · ")

        return IOSUnifiedLogbookEntry(
            id: "\(IOSUnifiedLogbookActivityKind.snorkeling.rawValue)-\(session.id.uuidString)",
            sourceID: session.id,
            activity: .snorkeling,
            date: session.createdAt,
            title: DIRIOSLocalizer.string("logbook.activity.snorkeling"),
            subtitle: subtitle,
            primaryMetric: row.durationText,
            secondaryMetric: row.distanceText,
            tertiaryMetric: row.maxDepthText,
            isDemo: isDemo
        )
    }

    private static func mapApnea(
        _ session: ApneaSession,
        units: IOSUnitPreference,
        isDemo: Bool
    ) -> IOSUnifiedLogbookEntry {
        let stats = session.statistics
        let profile = session.profile?.displayName ?? DIRIOSLocalizer.string("apnea.ios.session.detail.title")
        let subtitle = [session.createdAt.formatted(date: .abbreviated, time: .shortened), profile]
            .joined(separator: " · ")
        let diveCount = "\(stats.diveCount)"
        let bestHold = Formatters.stopwatch(stats.bestDiveDurationSeconds)
        let maxDepth = Formatters.depth(stats.sessionMaxDepthMeters, units: units).text

        return IOSUnifiedLogbookEntry(
            id: "\(IOSUnifiedLogbookActivityKind.apnea.rawValue)-\(session.id.uuidString)",
            sourceID: session.id,
            activity: .apnea,
            date: session.createdAt,
            title: DIRIOSLocalizer.string("logbook.activity.apnea"),
            subtitle: subtitle,
            primaryMetric: diveCount,
            secondaryMetric: bestHold,
            tertiaryMetric: maxDepth,
            isDemo: isDemo
        )
    }
}
