import XCTest

final class UIUXMainRemediationCurrentTests: XCTestCase {
    func testSnorkelingExportUsesExplicitUnavailableCloudState() throws {
        let source = try readSource("iOSApp/Views/Snorkeling/IOSSnorkelingSessionExportView.swift")
        XCTAssertTrue(source.contains("SnorkelingCloudCapability"))
        XCTAssertFalse(source.contains("@AppStorage(\"dirdiving_ios_snorkeling_cloud_backup_enabled\")"))
    }

    func testMoreViewSyncRowsExposeAccessibility() throws {
        let source = try readSource("iOSApp/Views/IOSDivingSettingsEmbeddedContent.swift")
        XCTAssertTrue(source.contains("accessibleInfoRow"))
        XCTAssertTrue(source.contains("more.sync.push_to_watch.a11y.hint"))
        XCTAssertTrue(source.contains("more.icloud.sync_now.a11y.hint"))
    }

    func testWatchDiveDetailUsesLocaleAdaptiveDates() throws {
        let source = try readSource("Views/DiveDetailView.swift")
        XCTAssertTrue(source.contains("WatchLocaleAdaptiveDateFormatting"))
        XCTAssertFalse(source.contains("dateFormat = \"dd/MM/yyyy\""))
    }

    func testApneaAndSnorkelingTabsHideInactiveAccessibility() throws {
        let apnea = try readSource("iOSApp/Views/Apnea/IOSApneaRootView.swift")
        let snorkeling = try readSource("iOSApp/Views/Snorkeling/IOSSnorkelingRootView.swift")
        XCTAssertTrue(apnea.contains(".accessibilityHidden(apneaNavigation.selectedTab != tab)"))
        XCTAssertTrue(snorkeling.contains(".accessibilityHidden(snorkelingNavigation.selectedTab != tab)"))
    }

    func testPlannerAscentSpeedDiscoverability() throws {
        let modeSelection = try readSource("iOSApp/Views/CCR/PlannerModeSelectionView.swift")
        let planner = try readSource("iOSApp/Views/PlannerView.swift")
        XCTAssertTrue(modeSelection.contains("PlannerAscentSpeedSettingsLink"))
        XCTAssertTrue(planner.contains("PlannerAscentSpeedSettingsView"))
        XCTAssertTrue(planner.contains("planner.toolbar.ascent_speeds"))
    }

    func testWatchBriefingCardDetailSheetExists() throws {
        let inventory = try readSource("Views/PlannerBriefingCardsView.swift")
        let detail = try readSource("Views/PlannerBriefingCardDetailSheet.swift")
        XCTAssertTrue(inventory.contains("PlannerBriefingCardDetailSheet"))
        XCTAssertTrue(inventory.contains("selectedCard"))
        XCTAssertTrue(detail.contains("watch.planner_briefing.ref_only"))
    }

    func testWatchSyncDiagnosticsUsesSemanticKeys() throws {
        let source = try readSource("Views/WatchSyncDiagnosticsView.swift")
        XCTAssertTrue(source.contains("watch.sync.pending_count_format"))
        XCTAssertFalse(source.contains("%lld in attesa ack"))
    }

    func testWatchLiveBannersExposeAccessibility() throws {
        let source = try readSource("Views/DiveLiveView.swift")
        XCTAssertTrue(source.contains("live.sync.status.a11y.label"))
        XCTAssertTrue(source.contains("live.warning.banner.a11y.hint"))
        XCTAssertTrue(source.contains("live.gps.confirmation"))
    }

    func testBrandUsesCentralPresentation() throws {
        for path in [
            "Views/DiveLogListView.swift",
            "Views/CompassView.swift",
            "Views/DiveDetailView.swift",
        ] {
            let source = try readSource(path)
            XCTAssertTrue(source.contains("DIRBrandPresentation.displayName"), path)
            XCTAssertFalse(source.contains("Text(\"DIR DIVING\")"), path)
        }
    }

    func testApneaStatisticsUseCanonicalDepthFormatter() throws {
        let source = try readSource("iOSApp/Views/Apnea/IOSApneaSessionsListView.swift")
        XCTAssertTrue(source.contains("Formatters.depth(stats.cumulativeDepthMeters"))
        XCTAssertFalse(source.contains("String(format: \"%.0f m\""))
    }

    func testSnorkelingStatisticsUseCanonicalFormatters() throws {
        let source = try readSource("iOSApp/Views/Snorkeling/IOSSnorkelingSessionsListView.swift")
        XCTAssertTrue(source.contains("Formatters.surfaceSpeed"))
        XCTAssertTrue(source.contains("Formatters.distance(meters, units: unitPreference)"))
    }

    func testSemanticLocalizationKeysExist() throws {
        let enIOS = try loadIOSStrings("en")
        let enWatch = try loadWatchStrings("en")
        for key in [
            "settings.version.label",
            "snorkeling.ios.export.cloud_backup_status_unavailable",
            "planner.ascent_speeds.link.a11y.hint",
            "more.sync.push_to_watch.a11y.hint",
        ] {
            XCTAssertFalse(enIOS[key, default: ""].isEmpty, "Missing iOS EN \(key)")
        }
        for key in [
            "watch.sync.pending_count_format",
            "watch.info.depth_entitlement.title",
            "legal.onboarding.welcome.title",
        ] {
            XCTAssertFalse(enWatch[key, default: ""].isEmpty, "Missing Watch EN \(key)")
        }
    }

    func testMockupInventoryDocumentsLocalCanonicalAssets() throws {
        let readme = try String(contentsOf: repositoryRoot().appendingPathComponent("mockups/README.md"))
        XCTAssertTrue(readme.contains("59"))
        XCTAssertTrue(readme.localizedCaseInsensitiveContains("design references only"))
        let inventory = try String(contentsOf: repositoryRoot().appendingPathComponent("Docs/UI_UX_MOCKUP_INVENTORY_CURRENT.csv"))
        XCTAssertTrue(inventory.contains("Mockup_ID"))
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private func readSource(_ relativePath: String) throws -> String {
        try String(contentsOf: repositoryRoot().appendingPathComponent(relativePath))
    }

    private func loadIOSStrings(_ locale: String) throws -> [String: String] {
        let url = repositoryRoot().appendingPathComponent("iOSApp/Resources/\(locale).lproj/Localizable.strings")
        return parseStrings(try String(contentsOf: url))
    }

    private func loadWatchStrings(_ locale: String) throws -> [String: String] {
        let url = repositoryRoot().appendingPathComponent("Resources/\(locale).lproj/Localizable.strings")
        return parseStrings(try String(contentsOf: url))
    }

    private func parseStrings(_ raw: String) -> [String: String] {
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
