import XCTest

final class ApneaWatchMainPromotionTests: XCTestCase {
    func testApneaViewIncludedInWatchMainTargetAfterPromotion() throws {
        let project = try String(
            contentsOf: repositoryRoot().appendingPathComponent("project.yml"),
            encoding: .utf8
        )
        XCTAssertFalse(
            project.contains("- ApneaView.swift"),
            "ApneaView must not remain explicitly excluded from MAIN Watch target"
        )
    }

    func testApneaRuntimeStoreIncludedInWatchMainTarget() throws {
        let project = try String(
            contentsOf: repositoryRoot().appendingPathComponent("project.yml"),
            encoding: .utf8
        )
        XCTAssertTrue(project.contains("Services/ApneaWatchRuntimeStore.swift"))
    }

    func testExplorationStoreExcludedFromWatchMainTarget() throws {
        let project = try String(
            contentsOf: repositoryRoot().appendingPathComponent("project.yml"),
            encoding: .utf8
        )
        XCTAssertTrue(project.contains("- ExplorationStore.swift"))
    }

    func testApneaLaunchableOnWatchMAIN() {
        XCTAssertTrue(DIRActivityMode.apnea.isLaunchableOnWatchMAIN)
    }

    func testApneaRoutesToReadyNotComingSoon() {
        XCTAssertEqual(
            DIRStartupSelectionPolicy.nextStepAfterActivitySelection(.apnea),
            .ready(activity: .apnea, divingMode: .gauge)
        )
    }

    func testDiveLiveViewRoutesApneaActivity() throws {
        let source = try String(
            contentsOf: repositoryRoot().appendingPathComponent("Views/DiveLiveView.swift"),
            encoding: .utf8
        )
        XCTAssertTrue(source.contains("ApneaView()"))
        XCTAssertTrue(source.contains("selectedActivity == .apnea"))
    }

    func testApneaViewDoesNotImportDiveManager() throws {
        let source = try String(
            contentsOf: repositoryRoot().appendingPathComponent("Views/ApneaView.swift"),
            encoding: .utf8
        )
        XCTAssertFalse(source.contains("DiveManager"))
        XCTAssertFalse(source.contains("ExplorationStore"))
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
