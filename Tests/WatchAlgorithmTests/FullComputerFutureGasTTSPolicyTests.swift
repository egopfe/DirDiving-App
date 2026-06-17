import XCTest

final class FullComputerFutureGasTTSPolicyTests: XCTestCase {
    private let trimix = BuhlmannGas(
        name: "Trimix",
        role: .bottom,
        oxygenFraction: 0.18,
        heliumFraction: 0.45,
        maxPPO2Bar: 1.4,
        switchDepthMeters: 0,
        gasMixId: UUID()
    )
    private let ean50 = BuhlmannGas(
        name: "EAN50",
        role: .deco,
        oxygenFraction: 0.50,
        heliumFraction: 0,
        maxPPO2Bar: 1.6,
        switchDepthMeters: 21,
        gasMixId: UUID()
    )
    private let travel = BuhlmannGas(
        name: "EAN36",
        role: .travel,
        oxygenFraction: 0.36,
        heliumFraction: 0,
        maxPPO2Bar: 1.4,
        switchDepthMeters: 30,
        gasMixId: UUID()
    )
    private let bailout = BuhlmannGas(
        name: "Bailout",
        role: .bailout,
        oxygenFraction: 0.21,
        heliumFraction: 0,
        maxPPO2Bar: 1.4,
        switchDepthMeters: 0,
        gasMixId: UUID()
    )

    func testActiveGasOnlyPolicyExcludesDecoFromPlan() {
        var profile = FullComputerGasProfile.defaultAirGF3070
        profile.decoGases = [.ean50(at: 21)]
        profile.futureGasTTSPolicy = .activeGasOnly
        let plan = FullComputerRuntimePlan(profile: profile)
        XCTAssertTrue(plan.decoGases.isEmpty)
    }

    func testUnconfirmedDecoExcludedFromProjection() {
        let plan = FullComputerRuntimePlan(
            activeGas: trimix,
            gfLow: 30,
            gfHigh: 70,
            plannerEnvironment: .seaLevelSaltWater,
            travelGases: [],
            decoGases: [ean50],
            ascentRateMetersPerMinute: 9,
            stopIntervalMeters: 3
        )
        var tracker = FullComputerGasSwitchTracker.initial
        tracker.bootstrap(bottomGasMixId: trimix.gasMixId)
        XCTAssertTrue(FullComputerGasSwitchPolicy.projectionGases(from: plan, tracker: tracker).deco.isEmpty)
    }

    func testConfirmedDecoIncludedInProjection() {
        let plan = FullComputerRuntimePlan(
            activeGas: trimix,
            gfLow: 30,
            gfHigh: 70,
            plannerEnvironment: .seaLevelSaltWater,
            travelGases: [],
            decoGases: [ean50],
            ascentRateMetersPerMinute: 9,
            stopIntervalMeters: 3
        )
        var tracker = FullComputerGasSwitchTracker.initial
        tracker.bootstrap(bottomGasMixId: trimix.gasMixId)
        tracker.confirmedGasMixIds.insert(ean50.gasMixId)
        XCTAssertEqual(FullComputerGasSwitchPolicy.projectionGases(from: plan, tracker: tracker).deco.count, 1)
    }

    func testConfirmedTravelIncludedInProjection() {
        let plan = FullComputerRuntimePlan(
            activeGas: trimix,
            gfLow: 30,
            gfHigh: 70,
            plannerEnvironment: .seaLevelSaltWater,
            travelGases: [travel],
            decoGases: [],
            ascentRateMetersPerMinute: 9,
            stopIntervalMeters: 3
        )
        var tracker = FullComputerGasSwitchTracker.initial
        tracker.bootstrap(bottomGasMixId: trimix.gasMixId)
        tracker.confirmedGasMixIds.insert(travel.gasMixId)
        XCTAssertEqual(FullComputerGasSwitchPolicy.projectionGases(from: plan, tracker: tracker).travel.count, 1)
    }

    func testUnconfirmedTravelExcludedFromProjection() {
        let plan = FullComputerRuntimePlan(
            activeGas: trimix,
            gfLow: 30,
            gfHigh: 70,
            plannerEnvironment: .seaLevelSaltWater,
            travelGases: [travel],
            decoGases: [],
            ascentRateMetersPerMinute: 9,
            stopIntervalMeters: 3
        )
        var tracker = FullComputerGasSwitchTracker.initial
        tracker.bootstrap(bottomGasMixId: trimix.gasMixId)
        XCTAssertTrue(FullComputerGasSwitchPolicy.projectionGases(from: plan, tracker: tracker).travel.isEmpty)
    }

    func testUnavailableGasExcludedFromSuggestion() {
        var tracker = FullComputerGasSwitchTracker.initial
        tracker.bootstrap(bottomGasMixId: trimix.gasMixId)
        tracker.unavailableGasMixIds.insert(ean50.gasMixId)
        let suggested = FullComputerGasSwitchPolicy.suggestedSwitchGas(
            activeGas: trimix,
            depthMeters: 21,
            plannedGases: [ean50],
            tracker: tracker,
            environment: .seaLevelSaltWater
        )
        XCTAssertNil(suggested)
    }

    func testBailoutNeverInProjectionGases() {
        var profile = FullComputerGasProfile.defaultAirGF3070
        profile.bailoutGases = [
            FullComputerConfiguredGas(
                name: "Bailout",
                role: .bailout,
                oxygenFraction: 0.21,
                heliumFraction: 0,
                maxPPO2Bar: 1.4,
                switchDepthMeters: 0
            )
        ]
        let plan = FullComputerRuntimePlan(profile: profile)
        var tracker = FullComputerGasSwitchTracker.initial
        tracker.bootstrap(bottomGasMixId: plan.activeGas.gasMixId)
        tracker.confirmedGasMixIds.insert(profile.bailoutGases[0].id)
        let projection = FullComputerGasSwitchPolicy.projectionGases(from: plan, tracker: tracker)
        XCTAssertTrue(projection.deco.isEmpty)
        XCTAssertTrue(projection.travel.isEmpty)
    }

    func testPolicyStateAfterCheckpointRestore() throws {
        var profile = FullComputerGasProfile.defaultAirGF3070
        profile.decoGases = [.ean50(at: 21)]
        let plan = FullComputerRuntimePlan(profile: profile)
        let start = Date(timeIntervalSince1970: 1_730_000_000)
        var engine = try FullComputerRuntimeEngine(plan: plan, sessionStart: start)
        _ = engine.ingestSample(depthMeters: 21, timestamp: start.addingTimeInterval(100))
        _ = engine.confirmGasSwitch(to: plan.decoGases[0].gasMixId, at: start.addingTimeInterval(101))
        let checkpoint = try engine.exportCheckpoint(sessionID: UUID(), watchDivingMode: DIRDivingMode.fullComputer.rawValue)
        let restored = try FullComputerRuntimeEngine.restoreEngine(from: checkpoint, sessionStart: start)
        let projection = FullComputerGasSwitchPolicy.projectionGases(
            from: restored.runtimePlan,
            tracker: restored.persistedGasSwitchTracker
        )
        XCTAssertEqual(projection.deco.count, 1)
    }
}
