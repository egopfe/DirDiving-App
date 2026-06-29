import XCTest
@testable import DIRDivingiOSApp

final class DivePlannerEmergencyGasAdequacyTests: XCTestCase {
    private let environment = PlannerEnvironment.seaLevelSaltWater

    func testNoDecoStopsDoesNotProduceFalseOK() {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 18, bottomMinutes: 20)
        input.isDecoGasEnabled = true
        let active = PlannerModePolicy.activePlanInput(from: input, mode: .base)
        let enginePlan = BuhlmannPlanner.enginePlan(input: active)
        let report = DivePlannerEmergencyDecoGasService.analyze(
            input: active,
            enginePlan: enginePlan,
            environment: environment,
            includeBuddyDecoGas: false
        )
        XCTAssertNil(report)
    }

    func testPerGasOverallAdequateWhenAllGasesAdequate() {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 45, bottomMinutes: 25)
        input.isDecoGasEnabled = true
        input.includeBuddyDecoGas = false
        for index in input.plannerCylinders.indices where input.plannerCylinders[index].role == .deco {
            input.plannerCylinders[index].startPressure = 200
        }
        let active = PlannerModePolicy.activePlanInput(from: input, mode: .deco)
        let enginePlan = BuhlmannPlanner.enginePlan(input: active)
        guard !enginePlan.stops.isEmpty else {
            XCTFail("Expected deco stops for multigas plan")
            return
        }
        let report = DivePlannerEmergencyDecoGasService.analyze(
            input: active,
            enginePlan: enginePlan,
            environment: environment,
            includeBuddyDecoGas: false
        )
        XCTAssertNotNil(report)
        XCTAssertTrue(report?.isOverallAdequate ?? false)
        XCTAssertTrue(report?.perGasResults.allSatisfy(\.isAdequate) ?? false)
    }

    func testPerGasOverallNotAdequateWhenOneGasInsufficientWithBuddy() {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 45, bottomMinutes: 25)
        input.isDecoGasEnabled = true
        input.includeBuddyDecoGas = true
        for index in input.plannerCylinders.indices where input.plannerCylinders[index].role == .deco {
            input.plannerCylinders[index].startPressure = 80
        }
        let active = PlannerModePolicy.activePlanInput(from: input, mode: .deco)
        let enginePlan = BuhlmannPlanner.enginePlan(input: active)
        guard !enginePlan.stops.isEmpty else {
            XCTFail("Expected deco stops for multigas plan")
            return
        }
        let report = DivePlannerEmergencyDecoGasService.analyze(
            input: active,
            enginePlan: enginePlan,
            environment: environment,
            includeBuddyDecoGas: true
        )
        XCTAssertNotNil(report)
        XCTAssertFalse(report?.isOverallAdequate ?? true)
        XCTAssertTrue(report?.perGasResults.contains(where: { !$0.isAdequate }) ?? false)
    }

    func testRequiredDecoGasUsesStopSegmentsOnly() {
        let decoGas = BuhlmannTestSupport.ean50(switchDepth: 21)
        let bottomGas = BuhlmannTestSupport.trimix1845(switchDepth: 45)
        let enginePlan = BuhlmannEngineResult(
            ndlMinutes: nil,
            ttsMinutes: 30,
            totalRuntimeMinutes: 45,
            descentMinutes: 5,
            bottomMinutes: 20,
            gasSwitchMinutes: 0,
            finalTissueState: nil,
            stops: [
                BuhlmannDecompressionStop(depthMeters: 21, minutes: 5, gas: decoGas, ppO2: 1.4, maxPPO2: 1.6, gradientFactor: 70)
            ],
            segments: [
                BuhlmannRuntimeSegment(kind: .bottom, depthMeters: 45, minutes: 20, gas: bottomGas, note: "bottom"),
                BuhlmannRuntimeSegment(kind: .stop, depthMeters: 21, minutes: 5, gas: decoGas, note: "stop")
            ],
            tissueHistory: .empty,
            issues: [],
            modelState: .validReference
        )
        var input = GasPlanInput()
        input.sacLitersPerMinute = 20
        let required = DivePlannerEmergencyDecoGasService.requiredDecoLitersByGasLabel(
            input: input,
            enginePlan: enginePlan,
            environment: environment
        )
        XCTAssertEqual(required.keys.count, 1)
        XCTAssertNotNil(required["EAN50"])
        XCTAssertNil(required[bottomGas.label])
    }

    func testBarHiddenWhenCylinderCapacityMissing() {
        let result = DivePlannerEmergencyDecoGasService.buildResult(
            gasName: "O2",
            requiredPrimary: 500,
            availableLiters: 400,
            cylinderWaterCapacityLiters: nil,
            includeBuddyDecoGas: false
        )
        XCTAssertNil(result.shortfallBar)
        XCTAssertNil(result.reserveBar)
        XCTAssertFalse(result.isAdequate)
    }
}
