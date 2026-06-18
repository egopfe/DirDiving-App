import XCTest

final class SnorkelingWatchMainIsolationTests: XCTestCase {
    func testSnorkelingViewRemainsExcludedFromWatchMain() throws {
        let project = try String(contentsOf: repositoryRoot().appendingPathComponent("project.yml"), encoding: .utf8)
        XCTAssertTrue(project.contains("- SnorkelingView.swift"))
    }

    func testSnorkelingIsNotLaunchableOnWatchMain() {
        XCTAssertFalse(DIRActivityMode.snorkeling.isLaunchableOnWatchMAIN)
        XCTAssertFalse(DIRActivityMode.snorkeling.isLaunchableOnIOSCompanionMAIN)
    }

    func testSnorkelingRoutesToComingSoon() throws {
        XCTAssertFalse(DIRActivityMode.snorkeling.isLaunchableOnWatchMAIN)
        let policySource = try String(
            contentsOf: repositoryRoot().appendingPathComponent("Utils/DIRStartupSelectionPolicy.swift"),
            encoding: .utf8
        )
        XCTAssertTrue(policySource.contains("case .snorkeling:"))
        XCTAssertTrue(policySource.contains("comingSoon(activity: activity)"))
    }

    func testNoWatchAppIntentStartsSnorkeling() throws {
        let appIntents = try String(
            contentsOf: repositoryRoot().appendingPathComponent("App/DIRDivingApp.swift"),
            encoding: .utf8
        )
        XCTAssertFalse(appIntents.localizedCaseInsensitiveContains("SnorkelingSessionEngine"))
        XCTAssertFalse(appIntents.localizedCaseInsensitiveContains("startSnorkeling"))
    }

    func testNoRestoredPreferenceStartsSnorkeling() {
        XCTAssertFalse(DIRActivityMode.snorkeling.isLaunchableOnWatchMAIN)
        XCTAssertNotEqual(DIRActivityMode.snorkeling.rawValue, DIRActivitySelectionState.gaugeDefault.activity.rawValue)
    }

    func testSharedSnorkelingEngineHasNoNavigationReachability() throws {
        let violations = try SnorkelingArchitectureIsolation.violations(inRepositoryRoot: repositoryRoot())
        XCTAssertTrue(violations.isEmpty)
        let engine = try String(
            contentsOf: repositoryRoot().appendingPathComponent("Shared/Utils/SnorkelingSessionEngine.swift"),
            encoding: .utf8
        )
        XCTAssertFalse(engine.contains("bearingDegrees"))
        XCTAssertFalse(engine.contains("turnLeft"))
        XCTAssertFalse(engine.contains("turnRight"))
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
