import XCTest

final class FullComputerNoAutomaticGasSwitchTests: XCTestCase {
    func testSuggestionEvaluationDoesNotMutateActiveGas() throws {
        let plan = multigasPlan()
        let decoID = plan.decoGases[0].gasMixId
        let start = Date(timeIntervalSince1970: 1_750_000_000)
        var engine = try FullComputerRuntimeEngine(plan: plan, sessionStart: start)
        _ = engine.ingestSample(depthMeters: 21, timestamp: start.addingTimeInterval(60))
        let activeBefore = engine.snapshot.activeGas.gasMixId
        _ = FullComputerGasSwitchPolicy.evaluateSurface(
            activeGas: engine.snapshot.activeGas,
            depthMeters: 21,
            plannedGases: plan.decoGases,
            tracker: engine.persistedGasSwitchTracker,
            environment: plan.plannerEnvironment
        )
        XCTAssertEqual(engine.snapshot.activeGas.gasMixId, activeBefore)
        XCTAssertFalse(engine.persistedGasSwitchTracker.confirmedGasMixIds.contains(decoID))
    }

    func testRestoreDoesNotInventSwitch() throws {
        let plan = multigasPlan()
        let start = Date(timeIntervalSince1970: 1_751_000_000)
        var engine = try FullComputerRuntimeEngine(plan: plan, sessionStart: start)
        _ = engine.ingestSample(depthMeters: 21, timestamp: start.addingTimeInterval(90))
        let checkpoint = try engine.exportCheckpoint(sessionID: UUID(), watchDivingMode: DIRDivingMode.fullComputer.rawValue)
        let restored = try FullComputerRuntimeEngine.restoreEngine(from: checkpoint, sessionStart: start)
        XCTAssertEqual(restored.snapshot.activeGas.gasMixId, plan.activeGas.gasMixId)
        XCTAssertTrue(restored.gasSwitchAuditTrail.filter { $0.kind == .confirmed }.isEmpty)
    }

    func testAvailabilityChangeDoesNotSwitchGas() throws {
        let plan = multigasPlan()
        let decoID = plan.decoGases[0].gasMixId
        let start = Date(timeIntervalSince1970: 1_752_000_000)
        var engine = try FullComputerRuntimeEngine(plan: plan, sessionStart: start)
        _ = engine.ingestSample(depthMeters: 21, timestamp: start.addingTimeInterval(70))
        let active = engine.snapshot.activeGas.gasMixId
        engine.markGasUnavailable(gasMixId: decoID, at: start.addingTimeInterval(71))
        XCTAssertEqual(engine.snapshot.activeGas.gasMixId, active)
    }

    func testOnlyConfirmationAPIsMutateActiveGas() throws {
        let plan = multigasPlan()
        let decoID = plan.decoGases[0].gasMixId
        let start = Date(timeIntervalSince1970: 1_753_000_000)
        var engine = try FullComputerRuntimeEngine(plan: plan, sessionStart: start)
        _ = engine.ingestSample(depthMeters: 21, timestamp: start.addingTimeInterval(80))
        engine.tick(now: start.addingTimeInterval(81))
        XCTAssertEqual(engine.snapshot.activeGas.gasMixId, plan.activeGas.gasMixId)
        XCTAssertTrue(engine.confirmGasSwitch(to: decoID, at: start.addingTimeInterval(82)))
        XCTAssertEqual(engine.snapshot.activeGas.gasMixId, decoID)
    }

    private func multigasPlan() -> FullComputerRuntimePlan {
        var profile = FullComputerGasProfile.defaultAirGF3070
        profile.applyBottomGasKind(.trimix)
        profile.bottomGas.oxygenFraction = 0.18
        profile.bottomGas.heliumFraction = 0.45
        profile.decoGases = [.ean50(at: 21)]
        return FullComputerRuntimePlan(profile: profile)
    }
}
