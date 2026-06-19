import XCTest

final class SnorkelingAccessibilityContractTests: XCTestCase {
    func testWatchSnorkelingViewExposesStableAccessibilityIdentifiers() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("Views/SnorkelingView.swift"))
        let required = [
            "snorkeling.watch.stage.ready",
            "snorkeling.watch.stage.surface",
            "snorkeling.watch.stage.dip",
            "snorkeling.watch.stage.navigation",
            "snorkeling.watch.stage.return",
            "snorkeling.watch.stage.marker",
            "snorkeling.watch.stage.summary",
            "snorkeling.watch.gps_status",
        ]
        for id in required {
            XCTAssertTrue(source.contains(id), "Missing Watch accessibility identifier: \(id)")
        }
        XCTAssertTrue(source.contains("turnInstructionAccessibility"))
        XCTAssertTrue(source.contains("snorkeling.nav.gps_unavailable"))
    }

    func testIOSSnorkelingSurfacesExposeAccessibilityIdentifiers() throws {
        let files = [
            ("iOSApp/Views/Snorkeling/IOSSnorkelingDashboardView.swift", "snorkeling.ios.dashboard"),
            ("iOSApp/Views/Snorkeling/IOSSnorkelingRoutePlannerView.swift", "snorkeling.ios.route_planner"),
            ("iOSApp/Views/Snorkeling/IOSSnorkelingSessionsListView.swift", "snorkeling.ios.logbook"),
            ("iOSApp/Views/Snorkeling/IOSSnorkelingSessionExportView.swift", "snorkeling.ios.export"),
            ("iOSApp/Views/Snorkeling/IOSSnorkelingSessionDetailView.swift", "snorkeling.ios.map_summary"),
        ]
        for (relative, identifier) in files {
            let source = try String(contentsOf: repositoryRoot().appendingPathComponent(relative))
            XCTAssertTrue(source.contains(identifier), "\(relative) missing \(identifier)")
        }
    }

    func testVoiceOverProcedureExists() throws {
        let procedure = repositoryRoot()
            .appendingPathComponent("Docs/QA_EVIDENCE/SNORKELING_VOICEOVER/PROCEDURE.md")
        XCTAssertTrue(FileManager.default.fileExists(atPath: procedure.path))
        let text = try String(contentsOf: procedure, encoding: .utf8)
        XCTAssertTrue(text.contains("PENDING"))
        XCTAssertTrue(text.contains("snorkeling.ios.dashboard"))
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
