import XCTest

final class PlannerModeLimitsTests: XCTestCase {
    private func baseAirInput(depth: Double = 30, bottomMinutes: Double = 20) -> GasPlanInput {
        var input = GasPlanInput()
        input.plannedDepthMeters = depth
        input.plannedBottomMinutes = bottomMinutes
        input.plannedAverageDepthMeters = min(20, depth)
        input.bottomGas = GasMix(name: "Air", mixKind: .air, oxygen: 0.21, helium: 0, maxPPO2: 1.4)
        input.ensurePlannerCylindersFromLegacy()
        if let index = input.plannerCylinders.firstIndex(where: { $0.role == .bottom }) {
            input.plannerCylinders[index].gas = input.bottomGas
        }
        return input
    }

    func testBasicModeDepthFirstLimitsBottomTimeToBuhlmannNDL() {
        let input = baseAirInput(depth: 30, bottomMinutes: 25)
        guard let ndl = PlannerModeLimits.noDecompressionLimitMinutes(depthMeters: 30, input: input) else {
            return XCTFail("Expected NDL from Bühlmann engine")
        }
        XCTAssertGreaterThan(ndl, 0)
        var clamped = input
        PlannerModeLimits.enforceInputLimits(&clamped, mode: .base)
        XCTAssertEqual(clamped.plannedDepthMeters, 30, accuracy: 0.01)
        XCTAssertLessThanOrEqual(clamped.plannedBottomMinutes, ndl + 0.01)
    }

    func testBasicModeTimeFirstLimitsDepthToNoDecoCompatibleMax() {
        var input = baseAirInput(depth: 60, bottomMinutes: 30)
        guard let maxDepth = PlannerModeLimits.maximumNoDecompressionDepthMeters(for: input) else {
            return XCTFail("Expected max no-deco depth")
        }
        XCTAssertLessThan(maxDepth, 60)
        PlannerModeLimits.enforceInputLimits(&input, mode: .base)
        XCTAssertLessThanOrEqual(input.plannedDepthMeters, maxDepth + 0.01)
    }

    func testMandatoryDecoPlanRejectedInBasicMode() {
        var input = baseAirInput(depth: 40, bottomMinutes: 60)
        let validation = PlannerModePolicy.validate(draft: input, mode: .base)
        if PlannerModeLimits.requiresMandatoryDecompression(for: input) {
            XCTAssertTrue(validation.states.contains(.basicNoDecoLimitExceeded))
            XCTAssertFalse(validation.isValid)
        }
    }

    func testNoStaticNDLTableIntroduced() {
        let source = String(data: (
            try? Data(contentsOf: URL(fileURLWithPath: #filePath)
                .deletingLastPathComponent()
                .deletingLastPathComponent()
                .deletingLastPathComponent()
                .appendingPathComponent("iOSApp/Utils/PlannerModeLimits.swift"))
        ) ?? Data(), encoding: .utf8) ?? ""
        XCTAssertFalse(source.contains("static let ndlTable"))
        XCTAssertTrue(source.contains("BuhlmannEngine.noDecompressionLimit"))
    }

    func testDecoModeRejectsMaxDepthAbove40Meters() {
        var input = baseAirInput(depth: 45, bottomMinutes: 20)
        let validation = PlannerModePolicy.validate(draft: input, mode: .deco)
        XCTAssertTrue(validation.states.contains(.decoDepthLimitExceeded))
        XCTAssertFalse(validation.isValid)
    }

    func testDecoModeRejectsAverageDepthAbove40Meters() {
        var input = baseAirInput(depth: 38, bottomMinutes: 20)
        input.plannedAverageDepthMeters = 42
        let validation = PlannerModePolicy.validate(draft: input, mode: .deco)
        XCTAssertTrue(validation.states.contains(.decoDepthLimitExceeded))
    }

    func testDecoModeAccepts40Meters() {
        var input = baseAirInput(depth: 40, bottomMinutes: 20)
        input.plannedAverageDepthMeters = 30
        let depthValidation = PlannerModeLimits.validateDecoDepthLimits(for: input)
        XCTAssertFalse(depthValidation.states.contains(.decoDepthLimitExceeded))
    }

    func testDecoMode131FeetEquivalentWithinLimit() {
        let meters = IOSUnitConversions.meters(fromFeet: PlannerModeLimits.decoMaximumDepthFeet)
        var input = baseAirInput(depth: meters, bottomMinutes: 20)
        input.plannedAverageDepthMeters = min(20, meters)
        let validation = PlannerModeLimits.validateDecoDepthLimits(for: input)
        XCTAssertFalse(validation.states.contains(.decoDepthLimitExceeded))
    }

    func testDecoMode132FeetEquivalentRejected() {
        let meters = IOSUnitConversions.meters(fromFeet: 132)
        var input = baseAirInput(depth: meters, bottomMinutes: 20)
        let validation = PlannerModeLimits.validateDecoDepthLimits(for: input)
        XCTAssertTrue(validation.states.contains(.decoDepthLimitExceeded))
    }

    func testTechnicalModeDoesNotApplyBasicNoDecoRestriction() {
        var input = baseAirInput(depth: 40, bottomMinutes: 60)
        let validation = PlannerModePolicy.validate(draft: input, mode: .technical)
        XCTAssertFalse(validation.states.contains(.basicNoDecoLimitExceeded))
    }

    func testTechnicalModeDoesNotApplyDecoDepthCap() {
        var input = baseAirInput(depth: 55, bottomMinutes: 20)
        input.plannedAverageDepthMeters = 45
        let modeValidation = PlannerModePolicy.validate(draft: input, mode: .technical)
        XCTAssertFalse(modeValidation.states.contains(.decoDepthLimitExceeded))
    }

    func testModeSwitchClampsDecoDepthWhenNeeded() {
        var input = baseAirInput(depth: 50, bottomMinutes: 20)
        input.plannedAverageDepthMeters = 48
        PlannerModeLimits.enforceInputLimits(&input, mode: .deco)
        XCTAssertLessThanOrEqual(input.plannedDepthMeters, PlannerModeLimits.decoMaximumDepthMeters)
        XCTAssertLessThanOrEqual(input.plannedAverageDepthMeters, PlannerModeLimits.decoMaximumDepthMeters)
    }
}
