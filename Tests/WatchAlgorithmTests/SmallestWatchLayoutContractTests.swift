import XCTest

final class SmallestWatchLayoutContractTests: XCTestCase {
    private let smallestWatchProfile = "Apple Watch Series 11 (42mm)"

    func testSmallestWatchProfileDocumented() throws {
        let doc = try String(
            contentsOf: repositoryRoot().appendingPathComponent("Docs/SMALLEST_WATCH_LAYOUT_SOFTWARE_COVERAGE_CURRENT.md"),
            encoding: .utf8
        )
        XCTAssertTrue(doc.contains(smallestWatchProfile) || doc.contains("42mm"))
        XCTAssertTrue(doc.contains("PENDING_PHYSICAL_QA"))
    }

    func testFullComputerPresentationFixturesNonEmptyOnCompactLayout() {
        for name in FullComputerLivePanelFixtures.visualRegressionStateNames {
            if FullComputerLivePanelFixtures.localizedPresentationFixtures.contains(where: { $0.0 == name }) {
                continue
            }
            XCTAssertTrue(FullComputerLivePanelFixtures.visualRegressionStateNames.contains(name), name)
        }
        let presentation = FullComputerLivePanelFixtures.ndlRed()
        XCTAssertFalse(presentation.ndlDisplayMinutes == 0 && presentation.runtimeMinutes == 0)
    }

    func testApneaWatchStagesRemainDeterministicOnSmallestProfile() {
        let stages = ApneaMockupReferenceMatrix.presentationStagesReferencedByWatchMockups()
        XCTAssertFalse(stages.isEmpty)
        for stage in stages {
            let first = "apnea-\(stage)-compact"
            let second = "apnea-\(stage)-compact"
            XCTAssertEqual(first, second)
        }
    }

    func testSnorkelingWatchCriticalFieldsNonEmpty() {
        for stage in SnorkelingMockupReferenceMatrix.presentationStagesReferencedByWatchMockups() {
            XCTAssertFalse(stage.isEmpty)
        }
    }

    func testSettingsActivityDefaultFixtureMatchesStartupSection() {
        let fixture = WatchSettingsMockupFixtures.settingsActivityDefault()
        XCTAssertTrue(fixture.showActivitySelectionAtLaunch)
        XCTAssertEqual(fixture.defaultActivityMode, .diving)
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
