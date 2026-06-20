import XCTest
@testable import DIRDivingWatchApp

@MainActor
final class WatchActivityLogbookRoutingTests: XCTestCase {
    func testDivingPageInventoryIncludesDiveLog() {
        let pages = WatchActivityPagePolicy.pages(for: .diving, includeModeSelection: false)
        XCTAssertTrue(pages.contains(.diveLog))
        XCTAssertTrue(pages.contains(.live))
    }

    func testApneaPageInventoryExcludesDiveLog() {
        let pages = WatchActivityPagePolicy.pages(for: .apnea, includeModeSelection: false)
        XCTAssertFalse(pages.contains(.diveLog))
    }

    func testSnorkelingPageInventoryExcludesDiveLog() {
        let pages = WatchActivityPagePolicy.pages(for: .snorkeling, includeModeSelection: false)
        XCTAssertFalse(pages.contains(.diveLog))
    }

    func testSixForbiddenCrossActivityLogbookRoutesOnWatch() {
        let matrix: [(DIRActivityMode, AppPage, Bool)] = [
            (.diving, .diveLog, true),
            (.apnea, .diveLog, false),
            (.snorkeling, .diveLog, false),
        ]
        for (activity, page, allowed) in matrix {
            XCTAssertEqual(
                WatchActivityPagePolicy.isPageAllowed(page, for: activity, includeModeSelection: false),
                allowed,
                "activity=\(activity) page=\(page)"
            )
        }
        // Apnea/Snorkeling have no browse logbook tabs on Watch today.
        for activity in [DIRActivityMode.apnea, .snorkeling] {
            XCTAssertFalse(WatchActivityPagePolicy.pages(for: activity, includeModeSelection: false).contains(.diveLog))
        }
    }

    func testContentViewMountsDiveLogOnlyForDiving() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("Views/ContentView.swift"))
        XCTAssertTrue(source.contains("if activitySelection.selectedActivity == .diving"))
        XCTAssertTrue(source.contains("DiveLogListView()"))
        let conditionalRange = source.range(of: "if activitySelection.selectedActivity == .diving")!
        let diveLogMount = source.range(of: "DiveLogListView()")!
        XCTAssertLessThan(conditionalRange.lowerBound, diveLogMount.lowerBound)
    }

    func testContentViewNormalizesPageWhenActivityChanges() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("Views/ContentView.swift"))
        XCTAssertTrue(source.contains("onChange(of: activitySelection.selectedActivity)"))
        XCTAssertTrue(source.contains("clampSelectedPage("))
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}

@MainActor
final class WatchActivityPageRestorationTests: XCTestCase {
    func testStaleDiveLogPageNormalizesForApnea() {
        let navigation = AppNavigationStore()
        navigation.selectedPage = .diveLog
        navigation.clampSelectedPage(for: .apnea, includeModeSelection: false)
        XCTAssertEqual(navigation.selectedPage, .live)
    }

    func testStaleDiveLogPageNormalizesForSnorkeling() {
        let navigation = AppNavigationStore()
        navigation.selectedPage = .diveLog
        navigation.clampSelectedPage(for: .snorkeling, includeModeSelection: false)
        XCTAssertEqual(navigation.selectedPage, .live)
    }

    func testDiveLogPagePreservedForDiving() {
        let navigation = AppNavigationStore()
        navigation.selectedPage = .diveLog
        navigation.clampSelectedPage(for: .diving, includeModeSelection: false)
        XCTAssertEqual(navigation.selectedPage, .diveLog)
    }

    func testColdLaunchDefaultsToLiveWhenForeignPageStored() {
        let navigation = AppNavigationStore()
        navigation.selectedPage = .diveLog
        navigation.clampSelectedPage(for: .apnea, includeModeSelection: false)
        XCTAssertEqual(navigation.selectedPage, .live)
    }

    func testActivitySwitchFromDivingLogbookToApneaResetsPage() {
        let navigation = AppNavigationStore()
        navigation.selectedPage = .diveLog
        navigation.clampSelectedPage(for: .diving, includeModeSelection: false)
        XCTAssertEqual(navigation.selectedPage, .diveLog)
        navigation.clampSelectedPage(for: .apnea, includeModeSelection: false)
        XCTAssertEqual(navigation.selectedPage, .live)
    }
}
