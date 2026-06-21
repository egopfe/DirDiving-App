import XCTest

final class FullComputerGasSwitchTimestampTests: XCTestCase {
    private var sessionStart = Date(timeIntervalSince1970: 1_740_000_000)

    func testSwitchExactlyOnSampleTimestamp() throws {
        let plan = multigasPlan()
        let decoID = plan.decoGases[0].gasMixId
        let t = sessionStart.addingTimeInterval(300)
        var engine = try FullComputerRuntimeEngine(plan: plan, sessionStart: sessionStart)
        _ = engine.ingestSample(depthMeters: 21, timestamp: t)
        let before = engine.snapshot.tissueState
        XCTAssertTrue(engine.confirmGasSwitch(to: decoID, at: t))
        XCTAssertNotEqual(engine.snapshot.tissueState, before)
        XCTAssertEqual(engine.snapshot.activeGas.gasMixId, decoID)
    }

    func testSwitchBetweenSamplesAdvancesWithOldGasUntilTimestamp() throws {
        let plan = multigasPlan()
        let decoID = plan.decoGases[0].gasMixId
        let t1 = sessionStart.addingTimeInterval(200)
        let t2 = sessionStart.addingTimeInterval(250)
        var engine = try FullComputerRuntimeEngine(plan: plan, sessionStart: sessionStart)
        _ = engine.ingestSample(depthMeters: 21, timestamp: t1)
        let atT1 = engine.snapshot.tissueState
        XCTAssertTrue(engine.confirmGasSwitch(to: decoID, at: t2))
        _ = engine.ingestSample(depthMeters: 21, timestamp: t2.addingTimeInterval(10))
        XCTAssertNotEqual(engine.snapshot.tissueState, atT1)
    }

    func testNonMonotonicTimestampRejected() throws {
        var engine = try FullComputerRuntimeEngine(plan: .defaultAirGF3070, sessionStart: sessionStart)
        _ = engine.ingestSample(depthMeters: 12, timestamp: sessionStart.addingTimeInterval(30))
        let before = engine.snapshot.tissueState
        XCTAssertFalse(engine.ingestSample(depthMeters: 13, timestamp: sessionStart.addingTimeInterval(20)))
        XCTAssertEqual(engine.snapshot.tissueState, before)
    }

    func testUnavailableGasCannotBeConfirmed() throws {
        let plan = multigasPlan()
        let decoID = plan.decoGases[0].gasMixId
        var engine = try FullComputerRuntimeEngine(plan: plan, sessionStart: sessionStart)
        _ = engine.ingestSample(depthMeters: 21, timestamp: sessionStart.addingTimeInterval(100))
        engine.markGasUnavailable(gasMixId: decoID, at: sessionStart.addingTimeInterval(101))
        XCTAssertFalse(engine.confirmGasSwitch(to: decoID, at: sessionStart.addingTimeInterval(102)))
    }

    func testSameGasSelectedAgainDoesNotDuplicateEvents() throws {
        let plan = multigasPlan()
        let bottomID = plan.activeGas.gasMixId
        var engine = try FullComputerRuntimeEngine(plan: plan, sessionStart: sessionStart)
        _ = engine.ingestSample(depthMeters: 21, timestamp: sessionStart.addingTimeInterval(50))
        XCTAssertFalse(engine.confirmGasSwitch(to: bottomID, at: sessionStart.addingTimeInterval(51)))
        XCTAssertTrue(engine.gasSwitchAuditTrail.filter { $0.kind == .confirmed }.isEmpty)
    }

    func testInvalidGasIDCannotBeConfirmed() throws {
        var engine = try FullComputerRuntimeEngine(plan: .defaultAirGF3070, sessionStart: sessionStart)
        _ = engine.ingestSample(depthMeters: 15, timestamp: sessionStart.addingTimeInterval(10))
        XCTAssertFalse(engine.confirmGasSwitch(to: UUID(), at: sessionStart.addingTimeInterval(11)))
    }

    private func multigasPlan() -> FullComputerRuntimePlan {
        var profile = FullComputerGasProfile.defaultAirGF3070
        profile.applyBottomGasKind(.trimix)
        profile.bottomGas.oxygenFraction = 0.18
        profile.bottomGas.heliumFraction = 0.45
        profile.decoGases = [.ean50(at: 21)]
        return FullComputerRuntimePlan(profile: profile, plannerEnvironment: .seaLevelSaltWater)
    }
}
