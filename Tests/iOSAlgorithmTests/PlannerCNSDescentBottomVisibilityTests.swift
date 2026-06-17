import XCTest

final class PlannerCNSDescentBottomVisibilityTests: XCTestCase {
    func testBasePresentationHidesCNSDescentBottomSettingsCard() {
        let presentation = PlannerResultPresentation.presentation(for: .base)
        XCTAssertFalse(presentation.showsCNSDescentBottomSettings)
    }

    func testDecoPresentationHidesCNSDescentBottomSettingsCard() {
        let presentation = PlannerResultPresentation.presentation(for: .deco)
        XCTAssertFalse(presentation.showsCNSDescentBottomSettings)
    }

    func testTechnicalPresentationShowsCNSDescentBottomSettingsCard() {
        let presentation = PlannerResultPresentation.presentation(for: .technical)
        XCTAssertTrue(presentation.showsCNSDescentBottomSettings)
    }

    func testCCRPresentationShowsCNSDescentBottomSettingsCard() {
        let presentation = PlannerResultPresentation.presentation(for: .ccr)
        XCTAssertTrue(presentation.showsCNSDescentBottomSettings)
    }

    func testPlannerViewMountsCNSCardBehindVisibilityPolicy() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/PlannerView.swift"))
        XCTAssertTrue(source.contains("if modePresentation.showsCNSDescentBottomSettings"))
        XCTAssertTrue(source.contains("PlannerCNSDescentBottomSettingsCard()"))
        XCTAssertFalse(source.contains("cnsDescentBottomWarningCard"))
    }

    func testPlannerViewScrollToCNSGuardsHiddenModes() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/PlannerView.swift"))
        XCTAssertTrue(source.contains("guard modePresentation.showsCNSDescentBottomSettings else"))
        XCTAssertTrue(source.contains("store.acknowledgeCNSThresholdSettingsFocus()"))
    }

    func testCCRPlannerViewShowsCNSDescentBottomSettingsCard() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/CCR/CCRPlannerView.swift"))
        XCTAssertTrue(source.contains("showsCNSDescentBottomSettings"))
        XCTAssertTrue(source.contains("PlannerCNSDescentBottomSettingsCard()"))
        XCTAssertTrue(source.contains("PlannerCNSDescentBottomCheckSettings.scrollTargetID"))
    }

    func testPlannerResultViewPreservesCNSDescentBottomWarnings() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/PlannerView.swift"))
        XCTAssertTrue(source.contains("cnsDescentBottomWarningActive"))
        XCTAssertTrue(source.contains("cnsDescentBottomWarningBanner"))
        XCTAssertTrue(source.contains("planner.metric.cns_descent_bottom"))
    }

    func testCCRPlanResultPreservesCNSDescentBottomMetric() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/CCR/CCRPlanResultView.swift"))
        XCTAssertTrue(source.contains("planner.metric.cns_descent_bottom"))
        XCTAssertTrue(source.contains("descentBottomCNSPercent"))
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
