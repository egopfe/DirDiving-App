import XCTest
@testable import DIRDivingiOSApp

final class DivePlannerEmergencyBuddyDecoGasTests: XCTestCase {
    func testDefaultIncludeBuddyDecoGasIsFalse() {
        XCTAssertFalse(GasPlanInput().includeBuddyDecoGas)
        XCTAssertFalse(DivePlannerEmergencyOptions.default.includeBuddyDecoGas)
    }

    func testEmergencyOptionsRoundTripOnGasPlanInput() {
        var input = GasPlanInput()
        input.includeBuddyDecoGas = true
        XCTAssertTrue(input.emergencyOptions.includeBuddyDecoGas)
        input.emergencyOptions = DivePlannerEmergencyOptions(includeBuddyDecoGas: false)
        XCTAssertFalse(input.includeBuddyDecoGas)
    }

    func testIncludeBuddyDecoGasDecodesFalseWhenMissing() throws {
        let json = Data("""
        {
            "plannedDepthMeters": 40,
            "plannedBottomMinutes": 20
        }
        """.utf8)
        let decoded = try JSONDecoder().decode(GasPlanInput.self, from: json)
        XCTAssertFalse(decoded.includeBuddyDecoGas)
    }

    func testIncludeBuddyDecoGasEncodesAndDecodes() throws {
        var input = GasPlanInput()
        input.includeBuddyDecoGas = true
        let data = try JSONEncoder().encode(input)
        let decoded = try JSONDecoder().decode(GasPlanInput.self, from: data)
        XCTAssertTrue(decoded.includeBuddyDecoGas)
    }

    func testBuddyOffCalculationAdequate() {
        let result = DivePlannerEmergencyDecoGasService.buildResult(
            gasName: "EAN50",
            requiredPrimary: 900,
            availableLiters: 1200,
            cylinderWaterCapacityLiters: 12,
            includeBuddyDecoGas: false
        )
        XCTAssertEqual(result.requiredLitersBuddy, 0, accuracy: 0.001)
        XCTAssertEqual(result.requiredLitersTotal, 900, accuracy: 0.001)
        XCTAssertTrue(result.isAdequate)
        XCTAssertEqual(result.reserveLiters, 300, accuracy: 0.001)
        XCTAssertFalse(result.buddyIncluded)
    }

    func testBuddyOnCalculationAdequate() {
        let result = DivePlannerEmergencyDecoGasService.buildResult(
            gasName: "O2",
            requiredPrimary: 450,
            availableLiters: 1200,
            cylinderWaterCapacityLiters: 12,
            includeBuddyDecoGas: true
        )
        XCTAssertEqual(result.requiredLitersBuddy, 450, accuracy: 0.001)
        XCTAssertEqual(result.requiredLitersTotal, 900, accuracy: 0.001)
        XCTAssertTrue(result.isAdequate)
        XCTAssertEqual(result.reserveLiters, 300, accuracy: 0.001)
        XCTAssertTrue(result.buddyIncluded)
    }

    func testBuddyOnCalculationNotAdequate() {
        let result = DivePlannerEmergencyDecoGasService.buildResult(
            gasName: "EAN50",
            requiredPrimary: 900,
            availableLiters: 1600,
            cylinderWaterCapacityLiters: 14,
            includeBuddyDecoGas: true
        )
        XCTAssertEqual(result.requiredLitersBuddy, 900, accuracy: 0.001)
        XCTAssertEqual(result.requiredLitersTotal, 1800, accuracy: 0.001)
        XCTAssertFalse(result.isAdequate)
        XCTAssertEqual(result.shortfallLiters, 200, accuracy: 0.001)
    }

    func testShortfallBarConversion() {
        let bar = DivePlannerEmergencyDecoGasService.barEquivalent(liters: 200, cylinderWaterCapacityLiters: 14)
        XCTAssertNotNil(bar)
        XCTAssertEqual(bar ?? 0, 200 / 14, accuracy: 0.05)
    }

    func testReserveBarConversion() {
        let bar = DivePlannerEmergencyDecoGasService.barEquivalent(liters: 300, cylinderWaterCapacityLiters: 12)
        XCTAssertEqual(bar ?? 0, 25, accuracy: 0.001)
    }

    func testToggleDoesNotChangeDecoStops() {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 45, bottomMinutes: 25)
        input.isDecoGasEnabled = true
        var inputOff = PlannerModePolicy.activePlanInput(from: input, mode: .deco)
        inputOff.includeBuddyDecoGas = false
        var inputOn = PlannerModePolicy.activePlanInput(from: input, mode: .deco)
        inputOn.includeBuddyDecoGas = true
        let planOff = BuhlmannPlanner.enginePlan(input: inputOff)
        let planOn = BuhlmannPlanner.enginePlan(input: inputOn)
        XCTAssertEqual(planOff.stops, planOn.stops)
        XCTAssertEqual(planOff.ttsMinutes, planOn.ttsMinutes)
        XCTAssertEqual(planOff.segments, planOn.segments)
    }
}
