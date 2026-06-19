import Foundation

enum ApneaMockupPlatform: String, Codable, Hashable {
    case watch
    case ios
}

/// Maps external `APNEA_*` PNG references (Commands 05–11) to code surfaces.
/// Raster mockups are **not** embedded in app bundles; this matrix is the audit index only.
struct ApneaMockupReference: Identifiable, Equatable, Hashable {
    let id: String
    let fileName: String
    let platform: ApneaMockupPlatform
    let implementationReference: String
    let presentationStage: String?
    let hasExecutableFixture: Bool

    init(
        id: String,
        fileName: String,
        platform: ApneaMockupPlatform,
        implementationReference: String,
        presentationStage: String? = nil,
        hasExecutableFixture: Bool
    ) {
        self.id = id
        self.fileName = fileName
        self.platform = platform
        self.implementationReference = implementationReference
        self.presentationStage = presentationStage
        self.hasExecutableFixture = hasExecutableFixture
    }
}

enum ApneaMockupReferenceMatrix {
    static let all: [ApneaMockupReference] = [
        .init(id: "APNEA_WATCH_01", fileName: "APNEA_WATCH_01_READY.png", platform: .watch, implementationReference: "Views/ApneaView.swift", presentationStage: "ready", hasExecutableFixture: true),
        .init(id: "APNEA_WATCH_02", fileName: "APNEA_WATCH_02_DIVE_IN_PROGRESS.png", platform: .watch, implementationReference: "Views/ApneaView.swift", presentationStage: "dive", hasExecutableFixture: true),
        .init(id: "APNEA_WATCH_03", fileName: "APNEA_WATCH_03_ASCENT.png", platform: .watch, implementationReference: "Views/ApneaView.swift", presentationStage: "ascent", hasExecutableFixture: true),
        .init(id: "APNEA_WATCH_04", fileName: "APNEA_WATCH_04_SURFACE_RECOVERY.png", platform: .watch, implementationReference: "Views/ApneaView.swift", presentationStage: "surfaceRecovery", hasExecutableFixture: true),
        .init(id: "APNEA_WATCH_05", fileName: "APNEA_WATCH_05_SESSION_SUMMARY.png", platform: .watch, implementationReference: "Views/ApneaView.swift", presentationStage: "sessionSummary", hasExecutableFixture: true),
        .init(id: "APNEA_WATCH_06", fileName: "APNEA_WATCH_06_DEPTH_ALARMS.png", platform: .watch, implementationReference: "Utils/ApneaWatchPresentation.swift", presentationStage: "ready", hasExecutableFixture: true),
        .init(id: "APNEA_WATCH_07", fileName: "APNEA_WATCH_07_MARKER_REACHED.png", platform: .watch, implementationReference: "Views/ApneaView.swift (eventOverlay)", presentationStage: "dive", hasExecutableFixture: true),
        .init(id: "APNEA_WATCH_08", fileName: "APNEA_WATCH_08_TARGET_REACHED.png", platform: .watch, implementationReference: "Views/ApneaView.swift (eventOverlay)", presentationStage: "dive", hasExecutableFixture: true),

        .init(id: "APNEA_IOS_01", fileName: "APNEA_IOS_01_DASHBOARD.png", platform: .ios, implementationReference: "iOSApp/Views/Apnea/IOSApneaDashboardView.swift", hasExecutableFixture: true),
        .init(id: "APNEA_IOS_02", fileName: "APNEA_IOS_02_PROFILES.png", platform: .ios, implementationReference: "iOSApp/Views/Apnea/IOSApneaProfilesView.swift", hasExecutableFixture: true),
        .init(id: "APNEA_IOS_03", fileName: "APNEA_IOS_03_SESSION_PLANNER.png", platform: .ios, implementationReference: "iOSApp/Views/Apnea/IOSApneaSessionPlannerView.swift", hasExecutableFixture: true),
        .init(id: "APNEA_IOS_04", fileName: "APNEA_IOS_04_DIVE_DETAIL.png", platform: .ios, implementationReference: "iOSApp/Views/Apnea/IOSApneaSessionDetailView.swift", hasExecutableFixture: true),
        .init(id: "APNEA_IOS_05", fileName: "APNEA_IOS_05_SESSION_CHARTS.png", platform: .ios, implementationReference: "iOSApp/Views/Apnea/IOSApneaSessionDetailView.swift (charts)", hasExecutableFixture: true),
        .init(id: "APNEA_IOS_06", fileName: "APNEA_IOS_06_STATISTICS.png", platform: .ios, implementationReference: "iOSApp/Views/Apnea/IOSApneaStatisticsView.swift", hasExecutableFixture: true),
        .init(id: "APNEA_IOS_07", fileName: "APNEA_IOS_07_EQUIPMENT.png", platform: .ios, implementationReference: "iOSApp/Views/Apnea/IOSApneaEquipmentView.swift", hasExecutableFixture: true),
        .init(id: "APNEA_IOS_08", fileName: "APNEA_IOS_08_BUDDY_SAFETY.png", platform: .ios, implementationReference: "iOSApp/Views/Apnea/IOSApneaBuddySafetyView.swift", hasExecutableFixture: true),
        .init(id: "APNEA_IOS_09", fileName: "APNEA_IOS_09_SESSION_MAP.png", platform: .ios, implementationReference: "iOSApp/Views/Apnea/IOSApneaSessionDetailView.swift (map)", hasExecutableFixture: true),
        .init(id: "APNEA_IOS_10", fileName: "APNEA_IOS_10_LOGBOOK.png", platform: .ios, implementationReference: "iOSApp/Views/Apnea/IOSApneaSessionsListView.swift", hasExecutableFixture: true),
        .init(id: "APNEA_IOS_11", fileName: "APNEA_IOS_11_ALARMS.png", platform: .ios, implementationReference: "iOSApp/Views/Apnea/IOSApneaSettingsView.swift (alarms)", hasExecutableFixture: true),
        .init(id: "APNEA_IOS_12", fileName: "APNEA_IOS_12_MARKERS.png", platform: .ios, implementationReference: "iOSApp/Views/Apnea/IOSApneaSettingsView.swift (markers)", hasExecutableFixture: true),
        .init(id: "APNEA_IOS_13", fileName: "APNEA_IOS_13_PERSONAL_RECORDS.png", platform: .ios, implementationReference: "iOSApp/Views/Apnea/IOSApneaPersonalRecordsView.swift", hasExecutableFixture: true),
        .init(id: "APNEA_IOS_14", fileName: "APNEA_IOS_14_EXPORT_SHARE.png", platform: .ios, implementationReference: "iOSApp/Views/Apnea/IOSApneaSessionExportView.swift", hasExecutableFixture: true),
        .init(id: "APNEA_IOS_15", fileName: "APNEA_IOS_15_SETTINGS.png", platform: .ios, implementationReference: "iOSApp/Views/Apnea/IOSApneaSettingsView.swift", hasExecutableFixture: true),
    ]

    static var count: Int { all.count }

    static var watchCount: Int { all.filter { $0.platform == .watch }.count }

    static var iosCount: Int { all.filter { $0.platform == .ios }.count }

    static func presentationStagesReferencedByWatchMockups() -> Set<String> {
        Set(all.compactMap { reference in
            reference.platform == .watch ? reference.presentationStage : nil
        })
    }

    static func referencePNGExists(at repositoryRoot: URL) -> [String] {
        all.compactMap { reference in
            let path = repositoryRoot
                .appendingPathComponent(MockupCanonicalPaths.apneaPNG(fileName: reference.fileName, platform: reference.platform))
            return FileManager.default.fileExists(atPath: path.path) ? nil : reference.fileName
        }
    }
}
