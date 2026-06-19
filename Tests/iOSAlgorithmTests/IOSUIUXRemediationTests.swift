import XCTest

@MainActor
final class IOSUIUXRemediationTests: XCTestCase {
    func testPostSelectionLandingFlagsExistForAllActivities() {
        IOSCompanionPostLegalEntry.resetForTesting()
        IOSCompanionPostLegalEntry.markPendingApneaLanding()
        IOSCompanionPostLegalEntry.markPendingSnorkelingLanding()
        IOSCompanionPostLegalEntry.markPendingPlannerLanding()
        XCTAssertTrue(IOSCompanionPostLegalEntry.consumePendingApneaLanding())
        XCTAssertTrue(IOSCompanionPostLegalEntry.consumePendingSnorkelingLanding())
        XCTAssertTrue(IOSCompanionPostLegalEntry.consumePendingPlannerLanding())
        XCTAssertFalse(IOSCompanionPostLegalEntry.consumePendingApneaLanding())
    }

    func testApneaRootViewConsumesPendingLanding() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/Apnea/IOSApneaRootView.swift"))
        XCTAssertTrue(source.contains("consumePendingApneaLanding"))
        XCTAssertTrue(source.contains("selectedTab = .dashboard"))
    }

    func testSnorkelingRootViewConsumesPendingLanding() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/Snorkeling/IOSSnorkelingRootView.swift"))
        XCTAssertTrue(source.contains("consumePendingSnorkelingLanding"))
        XCTAssertTrue(source.contains("selectedTab = .dashboard"))
    }

    func testApneaDashboardLastSessionUsesNavigationLink() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/Apnea/IOSApneaDashboardView.swift"))
        XCTAssertTrue(source.contains("NavigationLink"))
        XCTAssertTrue(source.contains("IOSApneaSessionDetailView"))
        XCTAssertTrue(source.contains("apnea.ios.dashboard.last_session.a11y"))
    }

    func testSnorkelingDashboardLastSessionUsesNavigationLink() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/Snorkeling/IOSSnorkelingDashboardView.swift"))
        XCTAssertTrue(source.contains("NavigationLink"))
        XCTAssertTrue(source.contains("IOSSnorkelingSessionDetailView"))
        XCTAssertFalse(source.contains("showRoutePlanner"))
    }

    func testActivitySelectionUsesBrandLocalizationKey() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/IOSCompanionActivitySelectionView.swift"))
        XCTAssertTrue(source.contains("brand.name"))
        XCTAssertTrue(source.contains("DIRTheme.safetyInfo"))
        XCTAssertFalse(source.contains("Color(red: 0.04, green: 0.52, blue: 1.0)"))
    }

    func testAllIOSMockupFixturesDeclared() {
        XCTAssertEqual(IOSMockupPreviewFixtures.allIOSApneaMockupIDs.count, 15)
        XCTAssertEqual(IOSMockupPreviewFixtures.allIOSSnorkelingMockupIDs.count, 3)
        XCTAssertTrue(IOSMockupPreviewFixtures.companionSelectionMockupPath.hasPrefix("mockups/"))
    }

    func testApneaIOSMockupMatrixHasExecutableFixtures() {
        for reference in ApneaMockupReferenceMatrix.all where reference.platform == .ios {
            XCTAssertTrue(reference.hasExecutableFixture, reference.id)
        }
    }

    func testSnorkelingIOSMockupMatrixHasExecutableFixtures() {
        for reference in SnorkelingMockupReferenceMatrix.all where reference.platform == .ios {
            XCTAssertTrue(reference.hasExecutableFixture, reference.id)
        }
    }

    func testDivingRootDocumentsPlannerAsHome() throws {
        let contentView = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/ContentView.swift"))
        let copy = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Utils/CompanionActivityCopy.swift"))
        XCTAssertTrue(contentView.contains("Planner (Diving home)"))
        XCTAssertTrue(copy.contains("companion.activity.diving.feature.planner"))
    }

    func testLogbookRoutesRemainActivityScoped() throws {
        let apneaRoot = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/Apnea/IOSApneaRootView.swift"))
        let snorkelingRoot = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/Snorkeling/IOSSnorkelingRootView.swift"))
        let contentView = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/ContentView.swift"))
        XCTAssertTrue(apneaRoot.contains("IOSApneaSessionsListView"))
        XCTAssertTrue(snorkelingRoot.contains("IOSSnorkelingSessionsListView"))
        XCTAssertTrue(contentView.contains("LogbookView"))
        XCTAssertFalse(apneaRoot.contains("LogbookView"))
        XCTAssertFalse(snorkelingRoot.contains("LogbookView"))
        XCTAssertFalse(apneaRoot.contains("IOSSnorkelingSessionsListView"))
        XCTAssertFalse(snorkelingRoot.contains("IOSApneaSessionsListView"))
    }

    func testSnorkelingRoutePlannerHasSinglePrimaryEntry() throws {
        let dashboard = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/Snorkeling/IOSSnorkelingDashboardView.swift"))
        let root = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/Snorkeling/IOSSnorkelingRootView.swift"))
        XCTAssertFalse(dashboard.contains("showRoutePlanner"))
        XCTAssertFalse(dashboard.contains(".sheet"))
        XCTAssertTrue(root.contains(".routePlanner"))
    }

    func testLocalizationKeysForRemediationExist() throws {
        let en = try loadIOSStrings(named: "en")
        let it = try loadIOSStrings(named: "it")
        for key in [
            "brand.name",
            "apnea.ios.dashboard.last_session.a11y",
            "snorkeling.ios.dashboard.last_session.hint",
            "companion.activity.diving.feature.planner",
        ] {
            XCTAssertFalse(en[key, default: ""].isEmpty, "Missing EN \(key)")
            XCTAssertFalse(it[key, default: ""].isEmpty, "Missing IT \(key)")
        }
        XCTAssertEqual(en["brand.name"], "DIR DIVING")
        XCTAssertEqual(it["brand.name"], "DIR DIVING")
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private func loadIOSStrings(named locale: String) throws -> [String: String] {
        let url = repositoryRoot().appendingPathComponent("iOSApp/Resources/\(locale).lproj/Localizable.strings")
        return parseStringsFile(try String(contentsOf: url, encoding: .utf8))
    }

    private func parseStringsFile(_ raw: String) -> [String: String] {
        var result: [String: String] = [:]
        let pattern = #"\"([^\"]+)\"\s*=\s*\"([^\"]*)\";"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return result }
        let range = NSRange(raw.startIndex..<raw.endIndex, in: raw)
        regex.enumerateMatches(in: raw, range: range) { match, _, _ in
            guard let match,
                  let keyRange = Range(match.range(at: 1), in: raw),
                  let valueRange = Range(match.range(at: 2), in: raw) else { return }
            result[String(raw[keyRange])] = String(raw[valueRange])
        }
        return result
    }
}
