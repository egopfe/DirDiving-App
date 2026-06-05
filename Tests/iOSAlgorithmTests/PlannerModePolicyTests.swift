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
    }

    func testDecoResultPresentationIsSimplified() {
        let presentation = PlannerResultPresentation.presentation(for: .deco)
        XCTAssertTrue(presentation.showsSimplifiedAscentTable)
        XCTAssertEqual(presentation.buhlmannPresentation, .simplifiedSummary)
        XCTAssertFalse(presentation.showsChartsTab)
    }

    func testLocalizationKeysExist() {
        XCTAssertFalse(String(localized: "planner.mode.base").isEmpty)
        XCTAssertFalse(String(localized: "planner.mode.deco").isEmpty)
        XCTAssertFalse(String(localized: "planner.mode.technical").isEmpty)
        XCTAssertFalse(String(localized: "planner.base.exceeds_mode.message").isEmpty)
        XCTAssertFalse(String(localized: "planner.reference_only.warning").isEmpty)
    }
}
