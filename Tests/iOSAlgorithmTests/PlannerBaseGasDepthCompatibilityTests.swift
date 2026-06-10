import XCTest

final class PlannerBaseGasDepthCompatibilityTests: XCTestCase {
    private let environment = PlannerEnvironment.seaLevelSaltWater

    func testBaseProjectionForcesPPO2OnePointFour() {
        var input = GasPlanInput()
        input.plannedDepthMeters = 30
        input.ensurePlannerCylindersFromLegacy()
        if let index = input.plannerCylinders.firstIndex(where: { $0.role == .bottom }) {
            input.plannerCylinders[index].gas = GasMix(
                name: "EAN32",
                role: .deco,
                mixKind: .ean,
                oxygen: 0.32,
                helium: 0,
                maxPPO2: 1.0
            )
        }

        let active = PlannerModePolicy.activePlanInput(from: input, mode: .base)
        XCTAssertEqual(active.plannerCylinders.count, 1)
        let bottom = active.plannerCylinders[0]
        XCTAssertEqual(bottom.role, .bottom)
        XCTAssertEqual(bottom.gas.role, .bottom)
        XCTAssertEqual(bottom.gas.mixKind, .ean)
        XCTAssertEqual(bottom.gas.oxygen, 0.32, accuracy: 0.001)
        XCTAssertEqual(bottom.gas.helium, 0, accuracy: 0.001)
        XCTAssertEqual(bottom.gas.maxPPO2, PlannerModePolicy.baseBottomGasMaxPPO2, accuracy: 0.001)
    }

    func testEAN32At30MBasePassesGasDepthCompatibility() {
        var input = baseInput(oxygen: 0.32, mixKind: .ean, name: "EAN32", depthMeters: 30, maxPPO2: 1.0)
        let active = PlannerModePolicy.activePlanInput(from: input, mode: .base)
        let issues = PlannerMODValidator.liveInputIssues(input: active, environment: active.plannerEnvironment)
        XCTAssertTrue(issues.isEmpty)
    }

    func testEAN50At40MBaseFailsGasDepthCompatibility() {
        var input = baseInput(oxygen: 0.50, mixKind: .ean, name: "EAN50", depthMeters: 40, maxPPO2: 1.0)
        let active = PlannerModePolicy.activePlanInput(from: input, mode: .base)
        let issues = PlannerMODValidator.liveInputIssues(input: active, environment: active.plannerEnvironment)
        XCTAssertFalse(issues.isEmpty)
        let derivedMOD = PlannerModePolicy.baseDerivedMODMeters(for: active.bottomGas, environment: environment)
        if let issue = issues.first {
            XCTAssertEqual(issue.modMeters, derivedMOD, accuracy: 0.2)
        } else {
            XCTFail("Expected MOD issue")
        }
        XCTAssertEqual(derivedMOD, 18, accuracy: 1.5)
    }

    func testReducingEAN50DepthBelowDerivedMaxClearsIssue() {
        var input = baseInput(oxygen: 0.50, mixKind: .ean, name: "EAN50", depthMeters: 40, maxPPO2: 1.0)
        let active = PlannerModePolicy.activePlanInput(from: input, mode: .base)
        let derivedMOD = PlannerModePolicy.baseDerivedMODMeters(for: active.bottomGas, environment: environment)
        input.plannedDepthMeters = max(0, derivedMOD - 1)
        let cleared = PlannerModePolicy.activePlanInput(from: input, mode: .base)
        let issues = PlannerMODValidator.liveInputIssues(input: cleared, environment: cleared.plannerEnvironment)
        XCTAssertTrue(issues.isEmpty)
    }

    func testAirAt40MBaseDoesNotFailGasDepthCompatibility() {
        var input = baseInput(oxygen: 0.21, mixKind: .air, name: "Air", depthMeters: 40, maxPPO2: 1.0)
        let active = PlannerModePolicy.activePlanInput(from: input, mode: .base)
        let issues = PlannerMODValidator.liveInputIssues(input: active, environment: active.plannerEnvironment)
        XCTAssertTrue(issues.isEmpty)
    }

    func testBaseProjectionSanitizesTrimixToAllowedBottomGas() {
        var input = GasPlanInput()
        input.plannedDepthMeters = 30
        input.ensurePlannerCylindersFromLegacy()
        if let index = input.plannerCylinders.firstIndex(where: { $0.role == .bottom }) {
            input.plannerCylinders[index].gas = GasMix(
                name: "TX18/45",
                role: .bottom,
                mixKind: .trimix,
                oxygen: 0.18,
                helium: 0.45,
                maxPPO2: 1.4
            )
        }

        let active = PlannerModePolicy.activePlanInput(from: input, mode: .base)
        XCTAssertEqual(active.plannerCylinders.count, 1)
        XCTAssertEqual(active.plannerCylinders[0].role, .bottom)
        XCTAssertEqual(active.plannerCylinders[0].gas.helium, 0, accuracy: 0.001)
        XCTAssertTrue(PlannerModePolicy.allowedMixKinds(for: .base).contains(active.plannerCylinders[0].gas.mixKind))
    }

    func testDecoAndTechnicalDoNotForceBasePPO2Policy() {
        var input = GasPlanInput()
        input.ensurePlannerCylindersFromLegacy()
        if let index = input.plannerCylinders.firstIndex(where: { $0.role == .bottom }) {
            input.plannerCylinders[index].gas.maxPPO2 = 1.6
        }

        let deco = PlannerModePolicy.activePlanInput(from: input, mode: .deco)
        let technical = PlannerModePolicy.activePlanInput(from: input, mode: .technical)
        XCTAssertEqual(deco.plannerCylinders.first(where: { $0.role == .bottom })!.gas.maxPPO2, 1.6, accuracy: 0.001)
        XCTAssertEqual(technical.plannerCylinders.first(where: { $0.role == .bottom })!.gas.maxPPO2, 1.6, accuracy: 0.001)
    }

    func testTechnicalTrimixHeliumPreserved() {
        var input = GasPlanInput()
        input.ensurePlannerCylindersFromLegacy()
        input.plannerCylinders.append(
            PlannerCylinderEntry(
                role: .bottom,
                gas: GasMix(name: "TX18/45", mixKind: .trimix, oxygen: 0.18, helium: 0.45, maxPPO2: 1.4)
            )
        )
        let active = PlannerModePolicy.activePlanInput(from: input, mode: .technical)
        let trimix = active.plannerCylinders.first { $0.gas.mixKind == .trimix }
        XCTAssertNotNil(trimix)
        XCTAssertEqual(trimix!.gas.helium, 0.45, accuracy: 0.001)
    }

    func testBaseDerivedMODUsesFixedPPO2NotGasMaxPPO2() {
        let gas = GasMix(name: "EAN50", mixKind: .ean, oxygen: 0.50, helium: 0, maxPPO2: 1.0)
        let derived = PlannerModePolicy.baseDerivedMODMeters(for: gas, environment: environment)
        let stale = PlannerMODValidator.modMeters(for: gas, environment: environment)
        XCTAssertNotEqual(derived, stale, accuracy: 0.5)
        XCTAssertEqual(derived, 18, accuracy: 1.5)
    }

    func testBaseEAN22At18MetersDoesNotRaiseGasDepthIssue() {
        var input = GasPlanInput()
        input.plannedDepthMeters = 18

        let ean22 = GasMix(
            name: "EAN22",
            role: .bottom,
            mixKind: .ean,
            oxygen: 0.22,
            helium: 0,
            maxPPO2: 1.0
        )

        input.bottomGas = ean22
        input.plannerCylinders = [
            PlannerCylinderEntry(role: .bottom, gas: ean22)
        ]

        let active = PlannerModePolicy.activePlanInput(from: input, mode: .base)

        XCTAssertEqual(active.plannerCylinders.count, 1)
        XCTAssertEqual(active.plannerCylinders[0].role, .bottom)
        XCTAssertEqual(active.plannerCylinders[0].gas.oxygen, 0.22, accuracy: 0.0001)
        XCTAssertEqual(active.plannerCylinders[0].gas.helium, 0, accuracy: 0.0001)
        XCTAssertEqual(active.plannerCylinders[0].gas.maxPPO2, PlannerModePolicy.baseBottomGasMaxPPO2, accuracy: 0.0001)

        let issues = PlannerMODValidator.liveInputIssues(input: active, environment: active.plannerEnvironment)
        XCTAssertTrue(issues.isEmpty)
    }

    func testBaseStaleExtraCylindersDoNotAffectValidation() {
        let ean22 = GasMix(
            name: "EAN22",
            role: .bottom,
            mixKind: .ean,
            oxygen: 0.22,
            helium: 0,
            maxPPO2: 1.0
        )
        let staleOxygen = GasMix(
            name: "O2",
            role: .deco,
            mixKind: .oxygen,
            oxygen: 1.0,
            helium: 0,
            maxPPO2: 1.6
        )
        let staleEAN50 = GasMix(
            name: "EAN50",
            role: .deco,
            mixKind: .ean,
            oxygen: 0.50,
            helium: 0,
            maxPPO2: 1.6
        )

        var input = GasPlanInput()
        input.plannedDepthMeters = 18
        input.bottomGas = ean22
        input.decoGas1 = staleEAN50
        input.decoGas2 = staleOxygen
        input.plannerCylinders = [
            PlannerCylinderEntry(role: .bottom, gas: ean22),
            PlannerCylinderEntry(role: .deco, tankSize: .liters12, gas: staleEAN50, switchDepthMeters: 21),
            PlannerCylinderEntry(role: .deco, tankSize: .liters12, gas: staleOxygen, switchDepthMeters: 6),
            PlannerCylinderEntry(role: .travel, tankSize: .liters12, gas: staleEAN50, switchDepthMeters: 30),
            PlannerCylinderEntry(role: .bailout, tankSize: .liters12, gas: staleOxygen, switchDepthMeters: 15)
        ]

        let active = PlannerModePolicy.activePlanInput(from: input, mode: .base)

        XCTAssertEqual(active.plannerCylinders.count, 1)
        XCTAssertEqual(active.plannerCylinders[0].role, .bottom)
        XCTAssertEqual(active.plannerCylinders[0].gas.oxygen, 0.22, accuracy: 0.0001)

        let issues = PlannerMODValidator.liveInputIssues(input: active, environment: active.plannerEnvironment)
        XCTAssertTrue(issues.isEmpty)
    }

    func testBaseEAN50At40MUsesPPO2OnePointFourDerivedMOD() {
        var input = baseInput(oxygen: 0.50, mixKind: .ean, name: "EAN50", depthMeters: 40, maxPPO2: 1.0)
        let active = PlannerModePolicy.activePlanInput(from: input, mode: .base)
        let issues = PlannerMODValidator.liveInputIssues(input: active, environment: active.plannerEnvironment)

        XCTAssertFalse(issues.isEmpty)
        let derivedMOD = PlannerModePolicy.baseDerivedMODMeters(for: active.bottomGas, environment: environment)
        XCTAssertEqual(derivedMOD, 18, accuracy: 1.5)
        if let issue = issues.first {
            XCTAssertEqual(issue.modMeters, derivedMOD, accuracy: 0.2)
            XCTAssertEqual(issue.ppO2Max, PlannerModePolicy.baseBottomGasMaxPPO2, accuracy: 0.0001)
        } else {
            XCTFail("Expected gas/depth issue for EAN50 at 40 m")
        }
    }

    func testBaseEAN22At18MetersDoesNotBlockMODGate() {
        let ean22 = GasMix(
            name: "EAN22",
            role: .bottom,
            mixKind: .ean,
            oxygen: 0.22,
            helium: 0,
            maxPPO2: 1.0
        )
        var input = GasPlanInput()
        input.plannedDepthMeters = 18
        input.plannedBottomMinutes = 20
        input.sacLitersPerMinute = 20
        input.bottomGas = ean22
        input.plannerCylinders = [
            PlannerCylinderEntry(role: .bottom, gas: ean22),
            PlannerCylinderEntry(
                role: .deco,
                tankSize: .liters12,
                gas: GasMix(name: "O2", mixKind: .oxygen, oxygen: 1.0, helium: 0, maxPPO2: 1.6),
                switchDepthMeters: 6
            )
        ]

        XCTAssertFalse(PlannerGasSchedule.hasMODBlockingIssues(input: input, mode: .base))
        let validation = PlannerModePolicy.validate(draft: input, mode: .base)
        XCTAssertTrue(validation.isValid)
    }

    func testBaseProjectionSetsSingleBottomCylinderWithNormalizedPPO2() {
        var input = GasPlanInput()
        input.plannedDepthMeters = 18
        input.ensurePlannerCylindersFromLegacy()
        input.plannerCylinders.append(
            PlannerCylinderEntry(
                role: .deco,
                tankSize: .liters12,
                gas: GasMix(name: "O2", mixKind: .oxygen, oxygen: 1.0, helium: 0, maxPPO2: 1.6),
                switchDepthMeters: 6
            )
        )
        if let index = input.plannerCylinders.firstIndex(where: { $0.role == .bottom }) {
            input.plannerCylinders[index].gas = GasMix(
                name: "EAN22",
                role: .bottom,
                mixKind: .ean,
                oxygen: 0.22,
                helium: 0,
                maxPPO2: 1.0
            )
        }

        let active = PlannerModePolicy.activePlanInput(from: input, mode: .base)

        XCTAssertEqual(active.plannerCylinders.count, 1)
        XCTAssertEqual(active.plannerCylinders[0].role, .bottom)
        XCTAssertEqual(active.plannerCylinders[0].gas.helium, 0, accuracy: 0.0001)
        XCTAssertEqual(active.plannerCylinders[0].gas.maxPPO2, PlannerModePolicy.baseBottomGasMaxPPO2, accuracy: 0.0001)
        XCTAssertEqual(active.bottomGas.maxPPO2, PlannerModePolicy.baseBottomGasMaxPPO2, accuracy: 0.0001)
    }

    private func baseInput(
        oxygen: Double,
        mixKind: GasMixKind,
        name: String,
        depthMeters: Double,
        maxPPO2: Double
    ) -> GasPlanInput {
        var input = GasPlanInput()
        input.plannedDepthMeters = depthMeters
        input.ensurePlannerCylindersFromLegacy()
        if let index = input.plannerCylinders.firstIndex(where: { $0.role == .bottom }) {
            input.plannerCylinders[index].gas = GasMix(
                name: name,
                role: .bottom,
                mixKind: mixKind,
                oxygen: oxygen,
                helium: 0,
                maxPPO2: maxPPO2
            )
        }
        return input
    }
}
