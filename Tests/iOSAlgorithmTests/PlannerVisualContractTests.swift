import XCTest

final class PlannerVisualContractTests: XCTestCase {
    func testPlannerViewExposesMODSwitchClampControls() throws {
        let source = try loadSource("iOSApp/Views/PlannerView.swift")
        XCTAssertTrue(source.contains("clampAllSwitchDepthsToMOD"))
        XCTAssertTrue(source.contains("planner.mod.validation.title"))
        XCTAssertTrue(source.contains("plannerMODInputWarnings"))
        XCTAssertTrue(source.contains("PlannerMODValidator"))
    }

    func testPlannerViewExposesRatioDecoVisualContracts() throws {
        let planner = try loadSource("iOSApp/Views/PlannerView.swift")
        let ratioViews = try loadSource("iOSApp/Views/RatioDecoPlannerViews.swift")
        XCTAssertTrue(planner.contains("RatioDecoPresetCard"))
        XCTAssertTrue(planner.contains("RatioDecoComparisonSection"))
        XCTAssertTrue(ratioViews.contains("RatioDecoDisclaimerBanner"))
        XCTAssertTrue(ratioViews.contains("planner.ratio_deco.disclaimer"))
        XCTAssertTrue(ratioViews.contains("RatioDecoPresentationColors"))
    }

    func testPlannerAccessibilityLabelsExistForDynamicTypeJourney() throws {
        let source = try loadSource("iOSApp/Views/PlannerView.swift")
        let keys = [
            "planner.toolbar.ascent_speeds",
            "planner.repetitive.toggle.a11y",
            "planner.oxygen_exposure.a11y",
            "planner.safety_ack.hint",
        ]
        for key in keys {
            XCTAssertTrue(source.contains(key), "Missing planner a11y contract: \(key)")
        }
    }

    func testPlannerCylinderEditorExposesSwitchDepthContract() throws {
        let source = try loadSource("iOSApp/Views/PlannerCylinderGasEditorView.swift")
        XCTAssertTrue(source.contains("switchDepthEditor"))
        XCTAssertTrue(source.contains("switchDepthMeters"))
    }

    func testVisualQAMatricesExist() {
        let root = repositoryRoot()
        let matrices = [
            "Docs/IOS_PLANNER_VISUAL_QA_MATRIX.md",
            "Docs/IOS_MOD_SWITCH_DEPTH_VISUAL_QA.md",
            "Docs/IOS_RATIO_DECO_VISUAL_QA.md",
        ]
        for path in matrices {
            XCTAssertTrue(FileManager.default.fileExists(atPath: root.appendingPathComponent(path).path), path)
        }
    }

    private func loadSource(_ relativePath: String) throws -> String {
        try String(contentsOf: repositoryRoot().appendingPathComponent(relativePath), encoding: .utf8)
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
