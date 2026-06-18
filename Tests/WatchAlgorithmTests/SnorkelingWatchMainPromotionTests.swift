import XCTest

final class SnorkelingWatchMainPromotionTests: XCTestCase {
    func testSnorkelingViewIncludedInWatchMainTarget() throws {
        let project = try String(
            contentsOf: repositoryRoot().appendingPathComponent("project.yml"),
            encoding: .utf8
        )
        XCTAssertFalse(project.contains("- SnorkelingView.swift"))
    }

    func testSnorkelingRuntimeStoreIncludedInWatchMainTarget() throws {
        let project = try String(
            contentsOf: repositoryRoot().appendingPathComponent("project.yml"),
            encoding: .utf8
        )
        XCTAssertTrue(project.contains("Services/SnorkelingWatchRuntimeStore.swift"))
    }

    func testExplorationStoreExcludedFromWatchMainTarget() throws {
        let project = try String(
            contentsOf: repositoryRoot().appendingPathComponent("project.yml"),
            encoding: .utf8
        )
        XCTAssertTrue(project.contains("- ExplorationStore.swift"))
    }

    func testSnorkelingLaunchableOnWatchMAIN() {
        XCTAssertTrue(DIRActivityMode.snorkeling.isLaunchableOnWatchMAIN)
    }

    func testSnorkelingRoutesToReadyNotComingSoon() {
        XCTAssertEqual(
            DIRStartupSelectionPolicy.nextStepAfterActivitySelection(.snorkeling),
            .ready(activity: .snorkeling, divingMode: .gauge)
        )
    }

    func testDiveLiveViewRoutesSnorkelingActivity() throws {
        let source = try String(
            contentsOf: repositoryRoot().appendingPathComponent("Views/DiveLiveView.swift"),
            encoding: .utf8
        )
        XCTAssertTrue(source.contains("SnorkelingView()"))
        XCTAssertTrue(source.contains("selectedActivity == .snorkeling"))
    }

    func testSnorkelingViewDoesNotImportForeignRuntimes() throws {
        let source = try String(
            contentsOf: repositoryRoot().appendingPathComponent("Views/SnorkelingView.swift"),
            encoding: .utf8
        )
        XCTAssertFalse(source.contains("DiveManager"))
        XCTAssertFalse(source.contains("ExplorationStore"))
    }

    func testSnorkelingRuntimeInjectedInWatchApp() throws {
        let source = try String(
            contentsOf: repositoryRoot().appendingPathComponent("App/DIRDivingApp.swift"),
            encoding: .utf8
        )
        XCTAssertTrue(source.contains("SnorkelingWatchRuntimeStore"))
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
