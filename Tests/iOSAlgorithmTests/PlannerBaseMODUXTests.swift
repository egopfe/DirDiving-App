import XCTest

final class PlannerBaseMODUXTests: XCTestCase {
    func testPlannerViewBranchesBaseMODWarningsToGasDepthCopy() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/PlannerView.swift"))
        XCTAssertTrue(source.contains("baseGasDepthCompatibilityWarning"))
        XCTAssertTrue(source.contains("planner.base.gas_depth.title"))
        XCTAssertTrue(source.contains("case .base:"))
        XCTAssertTrue(source.contains("genericMODInputWarnings"))
    }

    func testPlannerCylinderGasEditorHidesAdvancedMODControlsInBase() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/PlannerCylinderGasEditorView.swift"))
        XCTAssertTrue(source.contains("showsAdvancedMODControls"))
        XCTAssertTrue(source.contains("showsHeliumRow"))
        XCTAssertTrue(source.contains("showsRoleRow"))
        XCTAssertTrue(source.contains("if showsAdvancedMODControls"))
        XCTAssertTrue(source.contains("if showsHeliumRow"))
        XCTAssertTrue(source.contains("if showsRoleRow"))
        XCTAssertTrue(source.contains("planner.gas.ppo2_max"))
        XCTAssertTrue(source.contains("planner.gas.editor.mod"))
    }

    func testBaseGasDepthLocalizationKeysExistInCatalogs() throws {
        let en = try loadIOSStrings(named: "en")
        let it = try loadIOSStrings(named: "it")
        let keys = [
            "planner.base.gas_depth.title",
            "planner.base.gas_depth.message",
            "planner.base.gas_depth.hint",
            "planner.base.gas_depth.detail_format",
            "planner.base.gas_depth.block_calculate"
        ]
        for key in keys {
            XCTAssertFalse(en[key, default: ""].isEmpty, "Missing EN \(key)")
            XCTAssertFalse(it[key, default: ""].isEmpty, "Missing IT \(key)")
        }
        XCTAssertTrue(en["planner.base.gas_depth.message"]!.contains("PPO₂ 1.4"))
        XCTAssertTrue(it["planner.base.gas_depth.message"]!.contains("PPO₂ 1.4"))
        XCTAssertTrue(en["planner.base.gas_depth.detail_format"]!.contains("automatic maximum depth"))
    }

    func testBaseModeStillReportsUnsafeGasDepthCombination() {
        var input = GasPlanInput()
        input.plannedDepthMeters = 40
        input.ensurePlannerCylindersFromLegacy()
        if let index = input.plannerCylinders.firstIndex(where: { $0.role == .bottom }) {
            input.plannerCylinders[index].gas = GasMix(
                name: "EAN50",
                role: .bottom,
                mixKind: .ean,
                oxygen: 0.50,
                helium: 0,
                maxPPO2: 1.4
            )
        }
        let active = PlannerModePolicy.activePlanInput(from: input, mode: .base)
        let issues = PlannerMODValidator.liveInputIssues(input: active, environment: active.plannerEnvironment)
        XCTAssertFalse(issues.isEmpty)
    }

    func testBaseAllowedMixKindsRemainAirAndEANOnly() {
        XCTAssertEqual(PlannerModePolicy.allowedMixKinds(for: .base), [.air, .ean])
    }

    func testDecoModeKeepsGenericMODCopyInPlannerView() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/PlannerView.swift"))
        XCTAssertTrue(source.contains("case .deco, .technical:"))
        XCTAssertTrue(source.contains("planner.mod.validation.title"))
        XCTAssertTrue(source.contains("planner.mod.exceeds_allowed"))
    }

    func testPlannerViewLiveMODIssuesUsesActiveProjectedInput() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/PlannerView.swift"))
        XCTAssertTrue(source.contains("PlannerModePolicy.activePlanInput(from: store.input, mode: store.mode)"))
        XCTAssertTrue(source.contains("PlannerMODValidator.liveInputIssues(input: active, environment: active.plannerEnvironment)"))
        XCTAssertFalse(source.contains("PlannerMODValidator.liveInputIssues(input: store.input"))
        XCTAssertFalse(source.contains("if PlannerGasSchedule.hasMODBlockingIssues(input: store.input)"))
    }

    func testPlannerModePolicyDefinesBaseBottomGasMaxPPO2() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Utils/PlannerModePolicy.swift"))
        XCTAssertTrue(source.contains("static let baseBottomGasMaxPPO2: Double = 1.4"))
        XCTAssertTrue(source.contains("projected.plannerCylinders = [bottomEntry]"))
        XCTAssertTrue(source.contains("bottomEntry.gas.maxPPO2 = baseBottomGasMaxPPO2"))
        XCTAssertTrue(source.contains("bottomEntry.gas.helium = 0"))
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private func loadIOSStrings(named locale: String) throws -> [String: String] {
        let path = repositoryRoot()
            .appendingPathComponent("iOSApp/Resources/\(locale).lproj/Localizable.strings")
        let content = try String(contentsOf: path, encoding: .utf8)
        var result: [String: String] = [:]
        let pattern = #""([^"]+)"\s*=\s*"((?:\\.|[^"\\])*)";"#
        let regex = try NSRegularExpression(pattern: pattern)
        let range = NSRange(content.startIndex..<content.endIndex, in: content)
        for match in regex.matches(in: content, range: range) {
            guard
                let keyRange = Range(match.range(at: 1), in: content),
                let valueRange = Range(match.range(at: 2), in: content)
            else { continue }
            result[String(content[keyRange])] = String(content[valueRange])
        }
        return result
    }
}
