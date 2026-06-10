import XCTest

final class PlannerDecoGasToggleTests: XCTestCase {
    private let environment = PlannerEnvironment.seaLevelSaltWater

    func testDecoGasDisabledProjectsOnlyBackGas() {
        var input = decoInputWithStaleInvalidDecoGas()
        input.isDecoGasEnabled = false
        XCTAssertFalse(input.decoGasPlanningEnabled)

        let active = PlannerModePolicy.activePlanInput(from: input, mode: .deco)

        XCTAssertEqual(active.plannerCylinders.count, 1)
        XCTAssertEqual(active.plannerCylinders[0].role, .bottom)
        XCTAssertEqual(active.plannerCylinders[0].gas.oxygen, 0.32, accuracy: 0.001)
    }

    func testDecoGasEnabledProjectsBackGasAndDecompressionGas() {
        var input = decoInputWithStaleInvalidDecoGas()
        input.isDecoGasEnabled = true

        let active = PlannerModePolicy.activePlanInput(from: input, mode: .deco)

        XCTAssertEqual(active.plannerCylinders.count, 2)
        XCTAssertEqual(active.plannerCylinders[0].role, .bottom)
        XCTAssertEqual(active.plannerCylinders[1].role, .deco)
        XCTAssertEqual(active.plannerCylinders[1].gas.oxygen, 1.0, accuracy: 0.001)
    }

    func testDisabledDecompressionGasDoesNotCreateMODIssue() {
        var input = decoInputWithStaleInvalidDecoGas()
        input.isDecoGasEnabled = false
        XCTAssertFalse(input.decoGasPlanningEnabled)

        let active = PlannerModePolicy.activePlanInput(from: input, mode: .deco)
        let issues = PlannerMODValidator.liveInputIssues(input: active, environment: active.plannerEnvironment)

        XCTAssertTrue(issues.isEmpty)
    }

    func testEnabledDecompressionGasStillValidatesMODIssue() {
        var input = decoInputWithStaleInvalidDecoGas()
        input.isDecoGasEnabled = true

        let active = PlannerModePolicy.activePlanInput(from: input, mode: .deco)
        let issues = PlannerMODValidator.liveInputIssues(input: active, environment: active.plannerEnvironment)

        XCTAssertFalse(issues.isEmpty)
        XCTAssertTrue(issues.contains { $0.cylinderRole == .deco })
    }

    func testPlannerViewUsesDecoGasLabelsAndToggle() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/PlannerView.swift"))
        XCTAssertTrue(source.contains("planner.deco.back_gas.title"))
        XCTAssertTrue(source.contains("planner.deco.decompression_gas.title"))
        XCTAssertTrue(source.contains("planner.deco.decompression_gas.toggle"))
        XCTAssertTrue(source.contains("decoDecompressionGasToggleSection"))
        XCTAssertTrue(source.contains("isDecoGasEnabled"))
        XCTAssertFalse(source.contains("planner.cylinder.add_deco"))
    }

    func testBaseTechnicalAndCCRPresentationUnchanged() {
        XCTAssertFalse(PlannerResultPresentation.presentation(for: .base).showsGFPresets)
        XCTAssertTrue(PlannerResultPresentation.presentation(for: .technical).showsManualGFControls)
        XCTAssertTrue(PlannerResultPresentation.presentation(for: .ccr).showsManualGFControls)
        XCTAssertFalse(PlannerResultPresentation.presentation(for: .technical).showsGFPresets)
    }

    func testDecoGasEnabledDecodesFalseWhenKeyMissing() throws {
        var input = GasPlanInput()
        input.isDecoGasEnabled = true
        let encoded = try JSONEncoder().encode(input)
        guard var object = try JSONSerialization.jsonObject(with: encoded) as? [String: Any] else {
            return XCTFail("Expected JSON object")
        }
        object.removeValue(forKey: "isDecoGasEnabled")
        let legacy = try JSONSerialization.data(withJSONObject: object)
        let decoded = try JSONDecoder().decode(GasPlanInput.self, from: legacy)
        XCTAssertNil(decoded.isDecoGasEnabled)
        XCTAssertFalse(decoded.decoGasPlanningEnabled)
    }

    func testEnsureDefaultDecoGasIfNeededUsesExistingLegacyDefault() {
        var input = GasPlanInput()
        input.plannerCylinders = [
            PlannerCylinderEntry(
                role: .bottom,
                gas: GasMix(name: "EAN32", role: .bottom, mixKind: .ean, oxygen: 0.32, helium: 0, maxPPO2: 1.4)
            )
        ]
        input.ensureDefaultDecoGasIfNeeded()
        XCTAssertEqual(input.plannerCylinders.count, 2)
        XCTAssertEqual(input.plannerCylinders[1].role, .deco)
        XCTAssertEqual(input.plannerCylinders[1].gas.oxygen, input.decoGas1.oxygen, accuracy: 0.001)
    }

    private func decoInputWithStaleInvalidDecoGas() -> GasPlanInput {
        let bottom = GasMix(name: "EAN32", role: .bottom, mixKind: .ean, oxygen: 0.32, helium: 0, maxPPO2: 1.4)
        let staleOxygen = GasMix(name: "O2", role: .deco, mixKind: .oxygen, oxygen: 1.0, helium: 0, maxPPO2: 1.6)
        var input = GasPlanInput()
        input.plannedDepthMeters = 30
        input.bottomGas = bottom
        input.decoGas1 = staleOxygen
        input.plannerCylinders = [
            PlannerCylinderEntry(role: .bottom, gas: bottom),
            PlannerCylinderEntry(role: .deco, tankSize: .liters12, gas: staleOxygen, switchDepthMeters: 21)
        ]
        return input
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
