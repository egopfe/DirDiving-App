import XCTest

final class BuhlmannGasValidationTests: XCTestCase {
    func testInvalidGasOxygenPlusHeliumAboveOneHundredPercentFailsClosed() {
        let badGas = BuhlmannGas(
            name: "Bad TX",
            role: .bottom,
            oxygenFraction: 0.60,
            heliumFraction: 0.50,
            maxPPO2Bar: 1.4,
            switchDepthMeters: 30
        )
        let issues = BuhlmannEngine.validate(BuhlmannTestSupport.request(bottomGas: badGas))
        XCTAssertTrue(issues.contains { issue in
            if case .invalidGas = issue { return true }
            return false
        })
    }

    func testMODExceededAndActualPPO2AreReportedNotClipped() {
        let ean32 = BuhlmannTestSupport.nitrox32(switchDepth: 40)
        let issues = BuhlmannEngine.validate(BuhlmannTestSupport.request(depth: 40, bottomGas: ean32))
        XCTAssertTrue(issues.contains { issue in
            if case .ppo2Exceeded = issue { return true }
            return false
        })
        XCTAssertTrue(issues.contains { issue in
            if case .modExceeded = issue { return true }
            return false
        })

        let stop = PlannerGasSchedule.makeDecoStop(
            depthMeters: 21,
            minutes: 1,
            gas: GasMix(name: "EAN80", role: .deco, oxygen: 0.80, helium: 0, maxPPO2: 1.6)
        )
        XCTAssertGreaterThan(stop.ppO2, stop.maxPPO2)
        XCTAssertTrue(stop.states.contains(.PPO2Exceeded))
    }

    func testHypoxicGasUsedTooShallowFailsClosed() {
        let hypoxic = BuhlmannGas(
            name: "Hypoxic TX",
            role: .bottom,
            oxygenFraction: 0.10,
            heliumFraction: 0.50,
            maxPPO2Bar: 1.4,
            switchDepthMeters: 60
        )
        let issues = BuhlmannEngine.validate(BuhlmannTestSupport.request(depth: 60, bottomGas: hypoxic))
        XCTAssertTrue(issues.contains { issue in
            if case .hypoxicGasTooShallow = issue { return true }
            return false
        })
    }

    func testGasSwitchTooDeepFailsClosed() {
        let issues = BuhlmannEngine.validate(
            BuhlmannTestSupport.request(
                depth: 50,
                bottomGas: BuhlmannTestSupport.trimix1845(switchDepth: 50),
                decoGases: [BuhlmannTestSupport.ean50(switchDepth: 30)]
            )
        )
        XCTAssertTrue(issues.contains { issue in
            if case .gasSwitchTooDeep = issue { return true }
            return false
        })
    }

    func testOxygenDecoGasKeepsO2Label() {
        XCTAssertEqual(BuhlmannTestSupport.oxygen().label, "O2")
        XCTAssertEqual(GasMix(name: "O2", role: .deco, oxygen: 1.0, helium: 0, maxPPO2: 1.6).label, "O2")
    }
}
