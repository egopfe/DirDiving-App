import Foundation

enum SnorkelingMockupPlatform: String, Codable, Hashable {
    case watch
    case ios
}

/// Maps external `SNORKELING_*` PNG references (Commands 04–11) to code surfaces.
/// Raster mockups live under `mockups/**` only — never in app bundles.
struct SnorkelingMockupReference: Identifiable, Equatable, Hashable {
    let id: String
    let fileName: String
    let platform: SnorkelingMockupPlatform
    let implementationReference: String
    let presentationStage: String?
    let hasExecutableFixture: Bool

    init(
        id: String,
        fileName: String,
        platform: SnorkelingMockupPlatform,
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

enum SnorkelingMockupReferenceMatrix {
    static let all: [SnorkelingMockupReference] = [
        .init(id: "SNORKELING_WATCH_01", fileName: "SNORKELING_WATCH_01_READY.png", platform: .watch, implementationReference: "Views/SnorkelingView.swift", presentationStage: "ready", hasExecutableFixture: true),
        .init(id: "SNORKELING_WATCH_02", fileName: "SNORKELING_WATCH_02_SURFACE_DASHBOARD.png", platform: .watch, implementationReference: "Views/SnorkelingView.swift", presentationStage: "surfaceDashboard", hasExecutableFixture: true),
        .init(id: "SNORKELING_WATCH_03", fileName: "SNORKELING_WATCH_03_DIP_IN_PROGRESS.png", platform: .watch, implementationReference: "Views/SnorkelingView.swift", presentationStage: "dipInProgress", hasExecutableFixture: true),
        .init(id: "SNORKELING_WATCH_04", fileName: "SNORKELING_WATCH_04_WAYPOINT_NAVIGATION.png", platform: .watch, implementationReference: "Views/SnorkelingView.swift", presentationStage: "navigation", hasExecutableFixture: true),
        .init(id: "SNORKELING_WATCH_05", fileName: "SNORKELING_WATCH_05_RETURN_TO_ENTRY.png", platform: .watch, implementationReference: "Views/SnorkelingView.swift", presentationStage: "returnToEntry", hasExecutableFixture: true),
        .init(id: "SNORKELING_WATCH_06", fileName: "SNORKELING_WATCH_06_SAVE_MARKER.png", platform: .watch, implementationReference: "Views/SnorkelingView.swift", presentationStage: "saveMarker", hasExecutableFixture: true),
        .init(id: "SNORKELING_WATCH_07", fileName: "SNORKELING_WATCH_07_SESSION_SUMMARY.png", platform: .watch, implementationReference: "Views/SnorkelingView.swift", presentationStage: "sessionSummary", hasExecutableFixture: true),

        .init(id: "SNORKELING_IOS_01", fileName: "SNORKELING_IOS_01_DASHBOARD.png", platform: .ios, implementationReference: "iOSApp/Views/Snorkeling/IOSSnorkelingDashboardView.swift", hasExecutableFixture: true),
        .init(id: "SNORKELING_IOS_02", fileName: "SNORKELING_IOS_02_ROUTE_PLANNER.png", platform: .ios, implementationReference: "iOSApp/Views/Snorkeling/IOSSnorkelingRoutePlannerView.swift", hasExecutableFixture: true),
        .init(id: "SNORKELING_IOS_03", fileName: "SNORKELING_IOS_03_SESSION_DETAIL.png", platform: .ios, implementationReference: "iOSApp/Views/Snorkeling/IOSSnorkelingSessionDetailView.swift", hasExecutableFixture: true),
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
                .appendingPathComponent(MockupCanonicalPaths.snorkelingPNG(fileName: reference.fileName))
            return FileManager.default.fileExists(atPath: path.path) ? nil : reference.fileName
        }
    }
}
