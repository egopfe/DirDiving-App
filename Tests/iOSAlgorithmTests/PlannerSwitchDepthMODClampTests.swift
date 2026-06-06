import XCTest

final class PlannerSwitchDepthMODClampTests: XCTestCase {
    private let environment = PlannerEnvironment.seaLevelSaltWater

    private func oxygenDecoGas(maxPPO2: Double = 1.6) -> GasMix {
        GasMix(name: "O2", role: .deco, mixKind: .ean, oxygen: 1.0, helium: 0, maxPPO2: maxPPO2)
    }

    private func ean50(maxPPO2: Double = 1.6) -> GasMix {
        GasMix(name: "EAN50", role: .deco, mixKind: .ean, oxygen: 0.50, helium: 0, maxPPO2: maxPPO2)
    }

    private func decoEntry(gas: GasMix, switchDepth: Double) -> PlannerCylinderEntry {
        PlannerCylinderEntry(role: .deco, gas: gas, switchDepthMeters: switchDepth)
    }

    func testO2AtSeaLevelSetsSwitchDepthToFlooredMOD() {
        var entry = decoEntry(gas: oxygenDecoGas(), switchDepth: 21)
        let mod = entry.modMeters(environment: environment)
        XCTAssertEqual(mod, 6, accuracy: 0.6)
        entry.updateSwitchDepthAfterGasOrPPO2Change(environment: environment)
        let usable = entry.usableSwitchDepthMeters(environment: environment)
        XCTAssertEqual(entry.switchDepthMeters, usable, accuracy: 0.01)
        XCTAssertEqual(entry.switchDepthMeters, floor(mod), accuracy: 0.01)
        XCTAssertFalse(entry.isSwitchDepthBeyondMOD(environment: environment))
    }

    func testUserMayChooseShallowerSwitchDepth() {
        var entry = decoEntry(gas: oxygenDecoGas(), switchDepth: 21)
        entry.updateSwitchDepthAfterGasOrPPO2Change(environment: environment)
        entry.switchDepthMeters = 5
        entry.clampSwitchDepthToMOD(environment: environment)
        XCTAssertEqual(entry.switchDepthMeters, 5, accuracy: 0.01)
        let validation = PlannerInputValidator.validate(makeInput(with: entry), mode: .deco)
        XCTAssertFalse(validation.states.contains(.MODExceeded))
    }

    func testDeeperSwitchDepthClampsToMOD() {
        var entry = decoEntry(gas: oxygenDecoGas(), switchDepth: 7)
        entry.clampSwitchDepthToMOD(environment: environment)
        XCTAssertEqual(entry.switchDepthMeters, entry.usableSwitchDepthMeters(environment: environment), accuracy: 0.01)
        XCTAssertFalse(entry.isSwitchDepthBeyondMOD(environment: environment))
    }

    func testPPO2ChangeUpdatesSwitchDepthToMOD() {
        var entry = decoEntry(gas: oxygenDecoGas(maxPPO2: 1.4), switchDepth: 6)
        entry.updateSwitchDepthAfterGasOrPPO2Change(environment: environment)
        let mod14 = entry.usableSwitchDepthMeters(environment: environment)
        XCTAssertEqual(entry.switchDepthMeters, mod14, accuracy: 0.01)

        entry.gas.setMaxPPO2(1.6)
        entry.updateSwitchDepthAfterGasOrPPO2Change(environment: environment)
        XCTAssertEqual(entry.switchDepthMeters, entry.usableSwitchDepthMeters(environment: environment), accuracy: 0.01)
    }

    func testOxygenFractionChangeClampsSwitchDepth() {
        var entry = decoEntry(gas: ean50(), switchDepth: 22)
        entry.updateSwitchDepthAfterGasOrPPO2Change(environment: environment)
        XCTAssertGreaterThan(entry.switchDepthMeters, entry.usableSwitchDepthMeters(environment: environment) - 1)

        entry.gas.setOxygenFraction(1.0)
        entry.updateSwitchDepthAfterGasOrPPO2Change(environment: environment)
        XCTAssertEqual(entry.switchDepthMeters, entry.usableSwitchDepthMeters(environment: environment), accuracy: 0.01)
    }

    func testEnvironmentAwareMODClampUsesPlannerEnvironment() {
        let gas = GasMix(name: "EAN32", role: .deco, mixKind: .ean, oxygen: 0.32, helium: 0, maxPPO2: 1.4)
        var entry = PlannerCylinderEntry(role: .deco, gas: gas, switchDepthMeters: 50)
        guard case .success(let altitudeEnvironment) = PlannerEnvironment.make(altitudeMeters: 2_000, salinity: .salt) else {
            return XCTFail("Expected altitude environment")
        }
        let seaMOD = entry.usableSwitchDepthMeters(environment: environment)
        let altitudeMOD = entry.usableSwitchDepthMeters(environment: altitudeEnvironment)
        XCTAssertGreaterThan(altitudeMOD, seaMOD)
        entry.clampSwitchDepthToMOD(environment: altitudeEnvironment)
        XCTAssertEqual(entry.switchDepthMeters, altitudeMOD, accuracy: 0.01)
    }

    func testDecoModeProjectionClampsActiveDecoGas() {
        var input = GasPlanInput()
        input.plannerCylinders = [
            PlannerCylinderEntry(role: .bottom, gas: GasMix(name: "Air", role: .bottom, mixKind: .air, oxygen: 0.21, helium: 0, maxPPO2: 1.4)),
            decoEntry(gas: oxygenDecoGas(), switchDepth: 21),
            PlannerCylinderEntry(role: .bailout, gas: GasMix(name: "Bailout", role: .bailout, mixKind: .air, oxygen: 0.21, helium: 0, maxPPO2: 1.4), switchDepthMeters: 30)
        ]
        input.normalizeSwitchDepthsToMOD(changedCylinderID: input.plannerCylinders[1].id, updateChangedGasToMOD: true)
        let projected = PlannerModePolicy.activePlanInput(from: input, mode: .deco)
        XCTAssertEqual(projected.plannerCylinders.filter { $0.role == .deco }.count, 1)
        let deco = projected.plannerCylinders.first { $0.role == .deco }
        XCTAssertEqual(deco?.switchDepthMeters ?? 0, deco?.usableSwitchDepthMeters(environment: input.plannerEnvironment) ?? 0, accuracy: 0.01)
    }

    func testTechnicalModeClampsAllNonBottomRoles() {
        var input = GasPlanInput()
        input.plannerCylinders = [
            PlannerCylinderEntry(role: .bottom, gas: GasMix(name: "TX", role: .bottom, mixKind: .trimix, oxygen: 0.18, helium: 0.45, maxPPO2: 1.4)),
            PlannerCylinderEntry(role: .travel, gas: GasMix(name: "EAN32", role: .travel, mixKind: .ean, oxygen: 0.32, helium: 0, maxPPO2: 1.4), switchDepthMeters: 50),
            decoEntry(gas: oxygenDecoGas(), switchDepth: 21),
            PlannerCylinderEntry(role: .bailout, gas: oxygenDecoGas(), switchDepthMeters: 21)
        ]
        input.normalizeSwitchDepthsToMOD()
        for entry in input.plannerCylinders where entry.role != .bottom {
            XCTAssertFalse(entry.isSwitchDepthBeyondMOD(environment: input.plannerEnvironment))
        }
        let bottom = input.plannerCylinders.first { $0.role == .bottom }
        XCTAssertEqual(bottom?.switchDepthMeters ?? -1, 0, accuracy: 0.01)
    }

    func testRepeatedNormalizationDoesNotOscillate() {
        var entry = decoEntry(gas: oxygenDecoGas(), switchDepth: 21)
        for _ in 0..<20 {
            entry.gas.setMaxPPO2(entry.gas.maxPPO2 == 1.6 ? 1.4 : 1.6)
            entry.updateSwitchDepthAfterGasOrPPO2Change(environment: environment)
        }
        XCTAssertLessThanOrEqual(entry.switchDepthMeters, entry.usableSwitchDepthMeters(environment: environment) + 0.05)
        XCTAssertFalse(entry.isSwitchDepthBeyondMOD(environment: environment))
    }

    func testValidationBackstopFlagsMODExceeded() {
        var input = makeInput(with: decoEntry(gas: oxygenDecoGas(), switchDepth: 21))
        let before = PlannerInputValidator.validate(input, mode: .technical)
        XCTAssertTrue(before.states.contains(.MODExceeded))

        input.normalizeSwitchDepthsToMOD()
        let after = PlannerInputValidator.validate(input, mode: .technical)
        XCTAssertFalse(after.states.contains(.MODExceeded))
    }

    func testPlanGenerationClampsUnsafePersistedSwitchDepth() {
        var input = makeInput(with: decoEntry(gas: oxygenDecoGas(), switchDepth: 21))
        let plan = PlannerService.makePlan(input: input, mode: .deco)
        XCTAssertFalse(plan.states.contains(.MODExceeded))
        let active = PlannerModePolicy.activePlanInput(from: input, mode: .deco)
        var working = active
        working.normalizeSwitchDepthsToMOD(environment: working.plannerEnvironment)
        let deco = working.plannerCylinders.first { $0.role == .deco }
        XCTAssertEqual(deco?.switchDepthMeters ?? 0, deco?.usableSwitchDepthMeters(environment: working.plannerEnvironment) ?? 0, accuracy: 0.01)
    }

    func testGasPlanInputBulkNormalizeUpdatesOnlyChangedCylinder() {
        var input = GasPlanInput()
        let decoID = UUID()
        input.plannerCylinders = [
            PlannerCylinderEntry(role: .bottom, gas: GasMix(name: "Air", role: .bottom, mixKind: .air, oxygen: 0.21, helium: 0, maxPPO2: 1.4)),
            PlannerCylinderEntry(id: decoID, role: .deco, gas: ean50(), switchDepthMeters: 5),
            decoEntry(gas: oxygenDecoGas(), switchDepth: 21)
        ]
        input.normalizeSwitchDepthsToMOD(changedCylinderID: input.plannerCylinders[2].id, updateChangedGasToMOD: true)
        XCTAssertEqual(input.plannerCylinders[1].switchDepthMeters, 5, accuracy: 0.01)
        XCTAssertEqual(
            input.plannerCylinders[2].switchDepthMeters,
            input.plannerCylinders[2].usableSwitchDepthMeters(environment: input.plannerEnvironment),
            accuracy: 0.01
        )
    }

    private func makeInput(with deco: PlannerCylinderEntry) -> GasPlanInput {
        var input = GasPlanInput()
        input.plannerCylinders = [
            PlannerCylinderEntry(role: .bottom, gas: GasMix(name: "Air", role: .bottom, mixKind: .air, oxygen: 0.21, helium: 0, maxPPO2: 1.4)),
            deco
        ]
        return input
    }
}
