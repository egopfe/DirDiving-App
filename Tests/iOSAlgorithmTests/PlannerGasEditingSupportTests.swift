import XCTest

final class PlannerGasEditingSupportTests: XCTestCase {
    private let environment = PlannerEnvironment.seaLevelSaltWater

    func testAirLocksComposition() {
        var mix = GasMix(name: "Air", role: .bottom, mixKind: .air, oxygen: 0.32, helium: 0.10, maxPPO2: 1.4)
        mix.applyMixKind(.air)
        XCTAssertEqual(mix.oxygen, 0.21, accuracy: 0.001)
        XCTAssertEqual(mix.helium, 0, accuracy: 0.001)
        XCTAssertEqual(PlannerGasEditingSupport.nitrogenPercent(from: mix), 79)
        XCTAssertFalse(mix.canEditOxygen)
        XCTAssertFalse(mix.canEditHelium)
    }

    func testEANUpdatesNitrogenAutomatically() {
        var mix = GasMix(name: "EAN32", role: .bottom, mixKind: .ean, oxygen: 0.32, helium: 0, maxPPO2: 1.4)
        mix.setOxygenPercent(32)
        XCTAssertEqual(mix.helium, 0, accuracy: 0.001)
        XCTAssertEqual(PlannerGasEditingSupport.nitrogenPercent(from: mix), 68)
    }

    func testTrimixUpdatesNitrogenAutomatically() {
        var mix = GasMix(name: "TX", role: .bottom, mixKind: .trimix, oxygen: 0.18, helium: 0.45, maxPPO2: 1.4)
        mix.setOxygenPercent(18)
        mix.setHeliumPercent(45)
        XCTAssertEqual(PlannerGasEditingSupport.nitrogenPercent(from: mix), 37)
    }

    func testPureOxygenLocksComposition() {
        var mix = GasMix(name: "O2", role: .deco, mixKind: .ean, oxygen: 0.50, helium: 0, maxPPO2: 1.6)
        mix.applyMixKind(.oxygen)
        XCTAssertEqual(mix.oxygen, 1.0, accuracy: 0.001)
        XCTAssertEqual(mix.helium, 0, accuracy: 0.001)
        XCTAssertEqual(PlannerGasEditingSupport.nitrogenPercent(from: mix), 0)
        XCTAssertFalse(mix.canEditOxygen)
    }

    func testPPO2IncrementsByTenthOnly() {
        XCTAssertEqual(PlannerGasEditingSupport.normalizePPO2(1.44), 1.4, accuracy: 0.001)
        XCTAssertEqual(PlannerGasEditingSupport.normalizePPO2(1.46), 1.5, accuracy: 0.001)
        XCTAssertTrue(PlannerGasEditingSupport.ppo2PickerValues.contains(1.7))
        XCTAssertFalse(PlannerGasEditingSupport.ppo2PickerValues.contains(1.65))
    }

    func testMODUpdatesWhenOxygenChanges() {
        var mix = GasMix(name: "EAN50", role: .deco, mixKind: .ean, oxygen: 0.50, helium: 0, maxPPO2: 1.6)
        let modBefore = PlannerGasEditingSupport.modMeters(for: mix, environment: environment)
        mix.setOxygenPercent(100)
        mix.applyMixKind(.oxygen)
        let modAfter = PlannerGasEditingSupport.modMeters(for: mix, environment: environment)
        XCTAssertLessThan(modAfter, modBefore)
        XCTAssertEqual(modAfter, 6, accuracy: 0.6)
    }

    func testMODUpdatesWhenPPO2Changes() {
        var mix = GasMix(name: "Air", role: .bottom, mixKind: .air, oxygen: 0.21, helium: 0, maxPPO2: 1.4)
        let mod14 = PlannerGasEditingSupport.modMeters(for: mix, environment: environment)
        mix.setMaxPPO2(1.6)
        let mod16 = PlannerGasEditingSupport.modMeters(for: mix, environment: environment)
        XCTAssertGreaterThan(mod16, mod14)
        XCTAssertEqual(mod14, 56, accuracy: 1.5)
    }

    func testBuhlmannReceivesUpdatedGasValues() {
        var input = GasPlanInput()
        input.ensurePlannerCylindersFromLegacy()
        input.plannerCylinders[0].gas.setOxygenPercent(32)
        input.plannerCylinders[0].gas.mixKind = .ean
        input.syncLegacyGasesFromPlannerCylinders()
        let storeInput = PlannerModePolicy.activePlanInput(from: input, mode: .base)
        XCTAssertEqual(storeInput.buhlmannBackGas.oxygen, 0.32, accuracy: 0.001)
    }

    func testInvalidGasSwitchDeeperThanMODIsFlagged() {
        let gas = GasMix(name: "O2", role: .deco, mixKind: .oxygen, oxygen: 1.0, helium: 0, maxPPO2: 1.6)
        var entry = PlannerCylinderEntry(role: .deco, gas: gas, switchDepthMeters: 21)
        XCTAssertTrue(entry.isSwitchDepthBeyondMOD(environment: environment))
        XCTAssertTrue(
            PlannerGasEditingSupport.hasMODConflict(
                entry: entry,
                plannedDepthMeters: 40,
                environment: environment
            )
        )
    }

    func testInferredKindTreatsPureOxygenAsOxygenType() {
        XCTAssertEqual(GasMix.inferredKind(oxygen: 1.0, helium: 0), .oxygen)
    }
}
