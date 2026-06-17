import XCTest

final class FullComputerGasSwitchRecoveryIntegrationTests: XCTestCase {
    private var sessionStart = Date(timeIntervalSince1970: 1_710_000_000)

    func testCrashDuringConfirmedGasSwitchRecoversWithoutTissueResetOrRetroactiveGasApplication() throws {
        let plan = makeTrimixEAN50Plan()
        let bottomID = plan.activeGas.gasMixId
        let decoID = plan.decoGases[0].gasMixId
        let sessionID = UUID()
        let t1 = sessionStart.addingTimeInterval(600)
        let t2 = sessionStart.addingTimeInterval(601)

        var engine = try FullComputerRuntimeEngine(plan: plan, sessionStart: sessionStart)
        _ = engine.ingestSample(depthMeters: 21, timestamp: t1)
        let tissueBeforeSwitch = engine.snapshot.tissueState
        XCTAssertTrue(engine.confirmGasSwitch(to: decoID, at: t2))
        XCTAssertEqual(engine.snapshot.activeGas.gasMixId, decoID)
        let tissueAfterSwitch = engine.snapshot.tissueState
        XCTAssertNotEqual(tissueBeforeSwitch, tissueAfterSwitch)

        let checkpoint = try engine.exportCheckpoint(sessionID: sessionID, watchDivingMode: DIRDivingMode.fullComputer.rawValue)
        try FullComputerRuntimeCheckpointCodec.validate(checkpoint)

        var restored = try FullComputerRuntimeEngine.restoreEngine(from: checkpoint, sessionStart: sessionStart)
        XCTAssertEqual(restored.snapshot.activeGas.gasMixId, decoID)
        XCTAssertEqual(restored.snapshot.tissueState, tissueAfterSwitch)
        XCTAssertEqual(restored.gasSwitchAuditTrail.filter { $0.kind == .confirmed }.count, 1)
        XCTAssertEqual(restored.gasSwitchAuditTrail.first?.fromGasMixId, bottomID)
        XCTAssertEqual(restored.gasSwitchAuditTrail.first?.toGasMixId, decoID)
        XCTAssertFalse(restored.recoverySelfCheckDiagnostics(lastKnownDepthMeters: 21).contains("recovery_tissue_reset_detected"))

        restored.tick(now: t2.addingTimeInterval(5))
        XCTAssertEqual(restored.snapshot.activeGas.gasMixId, decoID)
    }

    func testCrashBeforeConfirmationDoesNotApplySwitch() throws {
        let plan = makeTrimixEAN50Plan()
        let bottomID = plan.activeGas.gasMixId
        let t1 = sessionStart.addingTimeInterval(500)
        var engine = try FullComputerRuntimeEngine(plan: plan, sessionStart: sessionStart)
        _ = engine.ingestSample(depthMeters: 21, timestamp: t1)
        let tissueLoaded = engine.snapshot.tissueState

        let checkpoint = try engine.exportCheckpoint(sessionID: UUID(), watchDivingMode: DIRDivingMode.fullComputer.rawValue)
        var restored = try FullComputerRuntimeEngine.restoreEngine(from: checkpoint, sessionStart: sessionStart)
        XCTAssertEqual(restored.snapshot.activeGas.gasMixId, bottomID)
        XCTAssertTrue(restored.gasSwitchAuditTrail.filter { $0.kind == .confirmed }.isEmpty)
        XCTAssertEqual(restored.snapshot.tissueState, tissueLoaded)
    }

    func testCrashAfterIgnoredSwitchPreservesMissedState() throws {
        let plan = makeTrimixEAN50Plan()
        let decoID = plan.decoGases[0].gasMixId
        let t1 = sessionStart.addingTimeInterval(400)
        var engine = try FullComputerRuntimeEngine(plan: plan, sessionStart: sessionStart)
        _ = engine.ingestSample(depthMeters: 21, timestamp: t1)
        engine.ignoreSuggestedGasSwitch(gasMixId: decoID, at: t1)
        XCTAssertEqual(engine.persistedGasSwitchTracker.activeMissedGasMixId, decoID)

        let checkpoint = try engine.exportCheckpoint(sessionID: UUID(), watchDivingMode: DIRDivingMode.fullComputer.rawValue)
        var restored = try FullComputerRuntimeEngine.restoreEngine(from: checkpoint, sessionStart: sessionStart)
        XCTAssertEqual(restored.persistedGasSwitchTracker.activeMissedGasMixId, decoID)
        XCTAssertEqual(restored.gasSwitchAuditTrail.filter { $0.kind == .ignored }.count, 1)
    }

    func testCorruptNewestCheckpointRejected() throws {
        let plan = makeTrimixEAN50Plan()
        var engine = try FullComputerRuntimeEngine(plan: plan, sessionStart: sessionStart)
        _ = engine.ingestSample(depthMeters: 25, timestamp: sessionStart.addingTimeInterval(300))
        var checkpoint = try engine.exportCheckpoint(sessionID: UUID(), watchDivingMode: DIRDivingMode.fullComputer.rawValue)
        checkpoint = FullComputerRuntimeCheckpoint(payload: checkpoint.payload, checksumHex: "badchecksum")
        XCTAssertThrowsError(try FullComputerRuntimeCheckpointCodec.validate(checkpoint))
    }

    func testCrashWithUnavailableGasPreservesUnavailableSet() throws {
        let plan = makeTrimixEAN50Plan()
        let decoID = plan.decoGases[0].gasMixId
        var engine = try FullComputerRuntimeEngine(plan: plan, sessionStart: sessionStart)
        _ = engine.ingestSample(depthMeters: 21, timestamp: sessionStart.addingTimeInterval(200))
        engine.markGasUnavailable(gasMixId: decoID, at: sessionStart.addingTimeInterval(201))

        let checkpoint = try engine.exportCheckpoint(sessionID: UUID(), watchDivingMode: DIRDivingMode.fullComputer.rawValue)
        let restored = try FullComputerRuntimeEngine.restoreEngine(from: checkpoint, sessionStart: sessionStart)
        XCTAssertTrue(restored.persistedGasSwitchTracker.unavailableGasMixIds.contains(decoID))
    }

    func testOffPlanSwitchSurvivesCheckpointRestore() throws {
        let plan = makeTrimixEAN50Plan()
        let offPlan = BuhlmannGas(
            name: "EAN32",
            role: .deco,
            oxygenFraction: 0.32,
            heliumFraction: 0,
            maxPPO2Bar: 1.4,
            switchDepthMeters: 0,
            gasMixId: UUID()
        )
        var engine = try FullComputerRuntimeEngine(plan: plan, sessionStart: sessionStart)
        let t = sessionStart.addingTimeInterval(450)
        _ = engine.ingestSample(depthMeters: 18, timestamp: t)
        XCTAssertTrue(engine.confirmOffPlanGasSwitch(offPlan, at: t.addingTimeInterval(1)))

        let checkpoint = try engine.exportCheckpoint(sessionID: UUID(), watchDivingMode: DIRDivingMode.fullComputer.rawValue)
        let restored = try FullComputerRuntimeEngine.restoreEngine(from: checkpoint, sessionStart: sessionStart)
        XCTAssertEqual(restored.snapshot.activeGas.gasMixId, offPlan.gasMixId)
        XCTAssertEqual(restored.gasSwitchAuditTrail.filter { $0.kind == .offPlan }.count, 1)
    }

    func testLogbookMetadataContainsExactlyOneSwitchEventAfterRecovery() throws {
        let plan = makeTrimixEAN50Plan()
        let decoID = plan.decoGases[0].gasMixId
        var engine = try FullComputerRuntimeEngine(plan: plan, sessionStart: sessionStart)
        let t = sessionStart.addingTimeInterval(700)
        _ = engine.ingestSample(depthMeters: 21, timestamp: t)
        XCTAssertTrue(engine.confirmGasSwitch(to: decoID, at: t.addingTimeInterval(1)))

        let checkpoint = try engine.exportCheckpoint(sessionID: UUID(), watchDivingMode: DIRDivingMode.fullComputer.rawValue)
        let restored = try FullComputerRuntimeEngine.restoreEngine(from: checkpoint, sessionStart: sessionStart)

        XCTAssertEqual(restored.gasSwitchAuditTrail.filter { $0.kind == .confirmed }.count, 1)
    }

    private func makeTrimixEAN50Plan() -> FullComputerRuntimePlan {
        var profile = FullComputerGasProfile.defaultAirGF3070
        profile.applyBottomGasKind(.trimix)
        profile.bottomGas.oxygenFraction = 0.18
        profile.bottomGas.heliumFraction = 0.45
        profile.bottomGas.name = "Trimix 18/45"
        profile.decoGases = [.ean50(at: 21)]
        return FullComputerRuntimePlan(profile: profile)
    }
}
