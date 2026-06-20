import XCTest

final class MODPresentationPolicyTests: XCTestCase {
    private let environment = PlannerEnvironment.seaLevelSaltWater

    func testBaseBottomMODUsesFixedPPO2Policy() {
        let gas = GasMix(name: "EAN50", mixKind: .ean, oxygen: 0.50, helium: 0, maxPPO2: 1.0)
        let entry = PlannerCylinderEntry(role: .bottom, gas: gas)
        let canonical = MODPresentationPolicy.canonicalMODMeters(for: entry, mode: .base, environment: environment)
        let derived = PlannerModePolicy.baseDerivedMODMeters(for: gas, environment: environment)
        XCTAssertEqual(canonical, derived, accuracy: 0.001)
        XCTAssertNotEqual(canonical, entry.modMeters(environment: environment), accuracy: 0.5)
    }

    func testTechnicalMODMatchesValidator() {
        let gas = GasMix(name: "EAN50", role: .deco, oxygen: 0.50, helium: 0, maxPPO2: 1.6)
        let entry = PlannerCylinderEntry(role: .deco, gas: gas, switchDepthMeters: 21)
        let canonical = MODPresentationPolicy.canonicalMODMeters(for: entry, mode: .technical, environment: environment)
        XCTAssertEqual(canonical, PlannerMODValidator.modMeters(for: gas, environment: environment), accuracy: 0.001)
    }

    func testPDFMODMatchesCanonicalPolicy() {
        var input = GasPlanInput()
        input.plannedDepthMeters = 40
        input.bottomGas = GasMix(name: "EAN50", mixKind: .ean, oxygen: 0.50, helium: 0, maxPPO2: 1.0)
        input.plannerCylinders = [PlannerCylinderEntry(role: .bottom, gas: input.bottomGas)]
        let active = PlannerModePolicy.activePlanInput(from: input, mode: .base)
        let entry = active.plannerCylinders[0]
        let pdfMOD = MODPresentationPolicy.displayMOD(for: entry, mode: .base, environment: environment, units: .metric)
        let canonical = MODPresentationPolicy.canonicalMODMeters(for: entry, mode: .base, environment: environment)
        let expected = Formatters.depth(canonical, units: .metric)
        XCTAssertEqual(pdfMOD.value, expected.value)
    }

    func testExceedsCanonicalMODMatchesValidatorTolerance() {
        let gas = GasMix(name: "EAN50", role: .bottom, oxygen: 0.50, helium: 0, maxPPO2: 1.0)
        let mod = MODPresentationPolicy.canonicalMODMeters(for: gas, role: .bottom, mode: .base, environment: environment)
        XCTAssertFalse(MODPresentationPolicy.exceedsCanonicalMOD(depthMeters: mod, gas: gas, role: .bottom, mode: .base, environment: environment))
        XCTAssertTrue(MODPresentationPolicy.exceedsCanonicalMOD(depthMeters: mod + 1, gas: gas, role: .bottom, mode: .base, environment: environment))
    }
}
