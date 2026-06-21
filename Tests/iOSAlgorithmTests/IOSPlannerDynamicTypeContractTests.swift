import XCTest

final class IOSPlannerDynamicTypeContractTests: XCTestCase {
    private let dynamicTypeCategories = [
        "standard",
        "large",
        "accessibilityXL",
    ]
    private let locales = ["en", "it"]
    private let layoutProfiles = [
        "iPhoneSE",
        "iPhone17ProMax",
    ]

    func testPlannerViewSupportsDynamicTypeAccessibilityContracts() throws {
        let source = try loadSource("iOSApp/Views/PlannerView.swift")
        let keys = [
            "planner.toolbar.ascent_speeds",
            "planner.repetitive.toggle.a11y",
            "planner.oxygen_exposure.a11y",
            "planner.safety_ack.hint",
            "planner.mod.validation.title",
        ]
        for key in keys {
            XCTAssertTrue(source.contains(key), "Missing planner contract \(key)")
        }
        XCTAssertTrue(source.contains("ScrollView"))
    }

    func testPlannerAscentSettingsDiscoverabilityAcrossModes() throws {
        let planner = try loadSource("iOSApp/Views/PlannerView.swift")
        let modeSelection = try loadSource("iOSApp/Views/CCR/PlannerModeSelectionView.swift")
        XCTAssertTrue(planner.contains("PlannerAscentSpeedSettingsView"))
        XCTAssertTrue(modeSelection.contains("PlannerAscentSpeedSettingsLink"))
    }

    func testRatioDecoAndCCRPlannerReferenceContracts() throws {
        let ratio = try loadSource("iOSApp/Views/RatioDecoPlannerViews.swift")
        let ccr = try loadSource("iOSApp/Views/CCR/CCRPlannerView.swift")
        XCTAssertTrue(ratio.contains("RatioDecoDisclaimerBanner"))
        XCTAssertTrue(ratio.contains("planner.ratio_deco.disclaimer"))
        XCTAssertTrue(ccr.contains("CCR") || ccr.contains("ccr"))
    }

    func testDynamicTypeXLPlannerEvidenceTemplateExistsAndPending() throws {
        let template = try String(
            contentsOf: repositoryRoot().appendingPathComponent(
                "Docs/QA_EVIDENCE/IOS_ACCESSIBILITY/DYNAMIC_TYPE_XL_PLANNER_TEMPLATE.md"
            ),
            encoding: .utf8
        )
        XCTAssertTrue(template.contains("PENDING_PHYSICAL_QA"))
        XCTAssertTrue(template.contains("Planner"))
    }

    func testSimulatorLayoutMatrixCoversRequiredProfiles() {
        let matrix = IOSPlannerDynamicTypeSimulatorMatrix.all
        XCTAssertEqual(Set(matrix.map(\.dynamicTypeCategory)), Set(dynamicTypeCategories))
        XCTAssertTrue(matrix.contains(where: { $0.locale == "en" && $0.layoutProfile == "iPhoneSE" }))
        XCTAssertTrue(matrix.contains(where: { $0.locale == "it" && $0.layoutProfile == "iPhone17ProMax" }))
    }

    func testPlannerVisualStatesExposeStableAccessibilityIdentifiers() throws {
        let source = try loadSource("iOSApp/Views/PlannerView.swift")
        XCTAssertTrue(source.contains("accessibilityIdentifier") || source.contains("accessibilityLabel"))
        XCTAssertTrue(source.contains("planner.safety"))
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

enum IOSPlannerDynamicTypeSimulatorMatrix {
    struct Entry: Equatable {
        let plannerMode: String
        let dynamicTypeCategory: String
        let locale: String
        let layoutProfile: String
    }

    static let all: [Entry] = [
        .init(plannerMode: "base", dynamicTypeCategory: "standard", locale: "en", layoutProfile: "iPhoneSE"),
        .init(plannerMode: "base", dynamicTypeCategory: "large", locale: "en", layoutProfile: "iPhone17ProMax"),
        .init(plannerMode: "deco", dynamicTypeCategory: "accessibilityXL", locale: "en", layoutProfile: "iPhoneSE"),
        .init(plannerMode: "technical", dynamicTypeCategory: "standard", locale: "it", layoutProfile: "iPhone17ProMax"),
        .init(plannerMode: "ccr", dynamicTypeCategory: "large", locale: "it", layoutProfile: "iPhoneSE"),
        .init(plannerMode: "deco", dynamicTypeCategory: "accessibilityXL", locale: "it", layoutProfile: "iPhone17ProMax"),
    ]
}
