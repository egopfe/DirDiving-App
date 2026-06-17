import XCTest

final class EquipmentPlannerMapperTests: XCTestCase {
    private func technicalProfile() -> EquipmentProfile {
        var profile = EquipmentProfile()
        profile.sacLitersMinute = 20
        profile.structuredCylinders = [
            EquipmentGasCylinder(
                name: "Back",
                role: .bottom,
                tankSize: .liters12,
                gas: EquipmentStructuredSupport.defaultBottomGas(named: "TRIMIX 18/45"),
                startPressureBar: 200,
                reservePressureBar: 50
            ),
            EquipmentGasCylinder(
                name: "Deco50",
                role: .deco,
                tankSize: .liters12,
                gas: EquipmentStructuredSupport.defaultDecoGas(named: "EAN50", oxygen: 0.5),
                startPressureBar: 200,
                reservePressureBar: 50,
                switchDepthMeters: 21
            )
        ]
        return profile
    }

    func testEquipmentPlannerMapperCopiesBottomGasAndPrimaryCylinder() {
        var input = GasPlanInput()
        let profile = technicalProfile()
        let result = EquipmentPlannerMapper.apply(profile: profile, to: &input, plannerMode: .deco)
        XCTAssertEqual(result.appliedCylinderCount, 2)
        XCTAssertEqual(input.sacLitersPerMinute, 20, accuracy: 0.01)
        let bottomPressure = input.plannerCylinders.first(where: { $0.role == .bottom })?.startPressure
        XCTAssertEqual(bottomPressure ?? 0, 200, accuracy: 0.01)
        XCTAssertEqual(input.bottomGas.name, "TRIMIX 18/45")
    }

    func testEquipmentPlannerMapperCopiesDecoCylinderWhenSupported() {
        var input = GasPlanInput()
        let profile = technicalProfile()
        _ = EquipmentPlannerMapper.apply(profile: profile, to: &input, plannerMode: .technical)
        let deco = input.plannerCylinders.first(where: { $0.role == .deco })
        XCTAssertNotNil(deco)
        XCTAssertEqual(deco!.switchDepthMeters, 21, accuracy: 0.01)
    }

    func testEquipmentPlannerMapperDoesNotRunPlannerMath() {
        var input = GasPlanInput()
        input.plannedDepthMeters = 40
        input.plannedBottomMinutes = 25
        input.gfLow = 30
        input.gfHigh = 70
        var mappedInput = input
        _ = EquipmentPlannerMapper.apply(profile: technicalProfile(), to: &mappedInput, plannerMode: .deco)
        XCTAssertEqual(mappedInput.plannedDepthMeters, 40, accuracy: 0.01)
        XCTAssertEqual(mappedInput.plannedBottomMinutes, 25, accuracy: 0.01)
        XCTAssertEqual(mappedInput.gfLow, 30, accuracy: 0.01)
        XCTAssertEqual(mappedInput.gfHigh, 70, accuracy: 0.01)
        XCTAssertFalse(mappedInput.plannerCylinders.isEmpty)
    }

    func testUnsupportedRolesAreIgnoredSafely() {
        var profile = EquipmentProfile()
        profile.structuredCylinders = [
            EquipmentGasCylinder(
                name: "Diluent",
                role: .ccrDiluent,
                tankSize: .liters12,
                gas: EquipmentStructuredSupport.defaultBottomGas(named: "Air")
            )
        ]
        var input = GasPlanInput()
        let result = EquipmentPlannerMapper.apply(profile: profile, to: &input, plannerMode: .deco)
        XCTAssertTrue(result.ignoredRoles.contains(.ccrDiluent))
        XCTAssertTrue(input.plannerCylinders.filter { $0.role == .ccrDiluent }.isEmpty)
    }
}
