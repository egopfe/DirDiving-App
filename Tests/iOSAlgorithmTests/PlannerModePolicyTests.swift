import XCTest

final class PlannerModePolicyTests: XCTestCase {
    func testBaseProjectionUsesSingleBottomGasOnly() {
        var input = GasPlanInput()
        input.ensurePlannerCylindersFromLegacy()
        let active = PlannerModePolicy.activePlanInput(from: input, mode: .base)
        XCTAssertEqual(active.plannerCylinders.count, 1)
        XCTAssertEqual(active.plannerCylinders.first?.role, .bottom)
    }

    func testDecoProjectionAllowsOneDecoGas() {
        var input = GasPlanInput()
        input.ensurePlannerCylindersFromLegacy()
        let active = PlannerModePolicy.activePlanInput(from: input, mode: .deco)
        XCTAssertEqual(active.plannerCylinders.filter { $0.role == .bottom }.count, 1)
        XCTAssertLessThanOrEqual(active.plannerCylinders.filter { $0.role == .deco }.count, 1)
        XCTAssertTrue(active.plannerCylinders.allSatisfy { $0.role == .bottom || $0.role == .deco })
    }

    func testTechnicalProjectionPreservesAllConfiguredGases() {
        var input = GasPlanInput()
        input.ensurePlannerCylindersFromLegacy()
        input.plannerCylinders.append(
            PlannerCylinderEntry(role: .travel, gas: GasMix(name: "Travel", oxygen: 0.32, helium: 0, maxPPO2: 1.4), switchDepthMeters: 30)
        )
        input.plannerCylinders.append(
            PlannerCylinderEntry(role: .bailout, gas: GasMix(name: "Bailout", oxygen: 0.21, helium: 0, maxPPO2: 1.4), switchDepthMeters: 6)
        )
        let draftCount = input.plannerCylinders.count
        let active = PlannerModePolicy.activePlanInput(from: input, mode: .technical)
        XCTAssertEqual(active.plannerCylinders.count, draftCount)
    }

    func testModeSwitchPreservesDraftConfiguration() {
        var input = GasPlanInput()
        input.ensurePlannerCylindersFromLegacy()
        let originalCount = input.plannerCylinders.count
        _ = PlannerModePolicy.activePlanInput(from: input, mode: .base)
        XCTAssertEqual(input.plannerCylinders.count, originalCount)
        _ = PlannerModePolicy.activePlanInput(from: input, mode: .technical)
        XCTAssertEqual(input.plannerCylinders.count, originalCount)
    }

    func testBaseRejectsTrimixBottomGas() {
        var input = GasPlanInput()
        input.ensurePlannerCylindersFromLegacy()
        if let index = input.plannerCylinders.firstIndex(where: { $0.role == .bottom }) {
            input.plannerCylinders[index].gas.applyMixKind(.trimix)
        }
        let validation = PlannerModePolicy.validate(draft: input, mode: .base)
        XCTAssertTrue(validation.states.contains(.unsupportedTrimix))
    }

    func testDecoProjectionIgnoresExtraDecoGasesInDraft() {
        var input = GasPlanInput()
        input.ensurePlannerCylindersFromLegacy()
        let active = PlannerModePolicy.activePlanInput(from: input, mode: .deco)
        XCTAssertLessThanOrEqual(active.plannerCylinders.filter { $0.role == .deco }.count, 1)
        if input.plannerCylinders.filter({ $0.role == .deco }).count > 1 {
            let validation = PlannerModePolicy.validate(draft: input, mode: .deco)
            XCTAssertTrue(validation.isValid || validation.states.contains(.validReference))
        }
    }

    func testTechnicalPlanIncludesFullResultSections() {
        var input = GasPlanInput()
        input.ensurePlannerCylindersFromLegacy()
        input.plannedDepthMeters = 30
        input.plannedBottomMinutes = 20
        input.bottomGas = GasMix(name: "Air", mixKind: .air, oxygen: 0.21, helium: 0, maxPPO2: 1.4)
        if let index = input.plannerCylinders.firstIndex(where: { $0.role == .bottom }) {
            input.plannerCylinders[index].gas = input.bottomGas
        }
        let plan = PlannerService.makePlan(input: input, mode: .technical)
        XCTAssertEqual(plan.plannerMode, .technical)
        let presentation = PlannerResultPresentation.presentation(for: .technical)
        XCTAssertTrue(presentation.showsFullAscentTable)
        XCTAssertEqual(presentation.buhlmannPresentation, .fullCurve)
    }

    func testBaseResultPresentationHidesTechnicalSections() {
        let presentation = PlannerResultPresentation.presentation(for: .base)
        XCTAssertFalse(presentation.showsFullAscentTable)
        XCTAssertFalse(presentation.showsNDLCurveTab)
        XCTAssertEqual(presentation.buhlmannPresentation, .hidden)
        XCTAssertFalse(presentation.showsCNSDescentBottomSettings)
    }

    func testDecoResultPresentationIsSimplified() {
        let presentation = PlannerResultPresentation.presentation(for: .deco)
        XCTAssertTrue(presentation.showsSimplifiedAscentTable)
        XCTAssertEqual(presentation.buhlmannPresentation, .simplifiedSummary)
        XCTAssertFalse(presentation.showsChartsTab)
        XCTAssertFalse(presentation.showsCNSDescentBottomSettings)
    }

    func testLocalizationKeysExist() {
        XCTAssertFalse(String(localized: "planner.mode.base").isEmpty)
        XCTAssertFalse(String(localized: "planner.mode.deco").isEmpty)
        XCTAssertFalse(String(localized: "planner.mode.technical").isEmpty)
        XCTAssertFalse(String(localized: "planner.mode.base.description").isEmpty)
        XCTAssertFalse(String(localized: "planner.mode.basic.no_deco.message").isEmpty)
        XCTAssertFalse(String(localized: "planner.mode.deco.depth_limit.message").isEmpty)
        XCTAssertFalse(String(localized: "planner.mode.technical.notice.message").isEmpty)
        XCTAssertFalse(String(localized: "planner.reference_only.warning").isEmpty)
    }

    func testBaseInvalidAltitudeRejectedInAllModes() {
        var input = GasPlanInput()
        input.plannedDepthMeters = 30
        input.plannedBottomMinutes = 20
        input.altitudeMeters = 5_000
        for mode in PlannerMode.allCases {
            let result = PlannerInputValidator.validate(input, mode: mode)
            XCTAssertTrue(result.states.contains(.invalidEnvironment), "Expected invalid environment for \(mode)")
        }
    }

    func testBaseModeAnalysisIgnoresHiddenBailoutCylinder() {
        var input = GasPlanInput()
        input.ensurePlannerCylindersFromLegacy()
        input.plannerCylinders.append(
            PlannerCylinderEntry(role: .bailout, gas: GasMix(name: "Bailout", oxygen: 0.21, helium: 0, maxPPO2: 1.4), switchDepthMeters: 6)
        )
        let activeBase = PlannerModePolicy.activePlanInput(from: input, mode: .base)
        let activeTechnical = PlannerModePolicy.activePlanInput(from: input, mode: .technical)
        XCTAssertEqual(activeBase.plannerCylinders.count, 1)
        XCTAssertGreaterThan(activeTechnical.plannerCylinders.count, 1)
        let baseAnalysis = GasPlanningService.analyze(input: input, mode: .base)
        XCTAssertEqual(baseAnalysis.gas.name, activeBase.bottomGas.name)
        XCTAssertFalse(activeBase.plannerCylinders.contains { $0.role == .bailout })
    }

    func testNDLPreviewInputUsesModeProjectedGFNotDraft() {
        var input = GasPlanInput()
        input.plannedDepthMeters = 30
        input.gfHigh = 50
        input.gfLow = 40
        input.ensurePlannerCylindersFromLegacy()
        let active = PlannerModePolicy.activePlanInput(from: input, mode: .base)
        guard case .success(let environment) = PlannerEnvironment.make(altitudeMeters: active.altitudeMeters, salinity: active.salinity) else {
            return XCTFail("Expected environment")
        }
        let draftPreview = BuhlmannPlanner.plan(
            depthMeters: input.buhlmannPlanningDepthMeters,
            bottomGas: input.buhlmannBackGas,
            environment: environment,
            gfHigh: input.gfHigh
        )
        let projectedPreview = BuhlmannPlanner.plan(
            depthMeters: active.buhlmannPlanningDepthMeters,
            bottomGas: active.buhlmannBackGas,
            environment: environment,
            gfHigh: active.gfHigh
        )
        XCTAssertEqual(active.gfHigh, PlannerGFPreset.standard.gfHigh)
        XCTAssertNotEqual(draftPreview.ndlMinutes, projectedPreview.ndlMinutes)
    }

    func testDecoPresentationShowsNDLReferenceNotFullChart() {
        let presentation = PlannerResultPresentation.presentation(for: .deco)
        XCTAssertTrue(presentation.showsNDLCurveTab)
        XCTAssertEqual(presentation.buhlmannPresentation, .simplifiedSummary)
        XCTAssertFalse(presentation.showsChartsTab)
    }

    func testPPO2ToleranceConstantsAreCentralized() {
        XCTAssertEqual(IOSAlgorithmConfiguration.ppo2HardValidationToleranceBar, 0.000_1, accuracy: 0.000_000_1)
        XCTAssertEqual(IOSAlgorithmConfiguration.ppo2DecoGasSwitchDepthToleranceBar, 0.02, accuracy: 0.001)
        XCTAssertEqual(BuhlmannConstants.decoGasSwitchPPO2ToleranceBar, IOSAlgorithmConfiguration.ppo2DecoGasSwitchDepthToleranceBar)
    }
}
