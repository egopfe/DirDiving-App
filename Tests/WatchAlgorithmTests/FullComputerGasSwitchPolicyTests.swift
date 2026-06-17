import XCTest

final class FullComputerGasSwitchPolicyTests: XCTestCase {
    private let ean50 = BuhlmannGas(
        name: "EAN50",
        role: .deco,
        oxygenFraction: 0.50,
        heliumFraction: 0,
        maxPPO2Bar: 1.6,
        switchDepthMeters: 21,
        gasMixId: UUID()
    )
    private let trimix = BuhlmannGas(
        name: "Trimix 18/45",
        role: .bottom,
        oxygenFraction: 0.18,
        heliumFraction: 0.45,
        maxPPO2Bar: 1.4,
        switchDepthMeters: 0,
        gasMixId: UUID()
    )

    func testSuggestedGasAtSwitchDepth() {
        var tracker = FullComputerGasSwitchTracker.initial
        tracker.bootstrap(bottomGasMixId: trimix.gasMixId)
        let suggested = FullComputerGasSwitchPolicy.suggestedSwitchGas(
            activeGas: trimix,
            depthMeters: 21,
            plannedGases: [ean50],
            tracker: tracker,
            environment: .seaLevelSaltWater
        )
        XCTAssertEqual(suggested?.gasMixId, ean50.gasMixId)
    }

    func testIgnoredSwitchShowsMissedSurface() {
        var tracker = FullComputerGasSwitchTracker.initial
        tracker.bootstrap(bottomGasMixId: trimix.gasMixId)
        let key = FullComputerGasSwitchTracker.opportunityKey(
            gasMixId: ean50.gasMixId,
            switchDepthMeters: ean50.switchDepthMeters
        )
        tracker.ignoredOpportunityKeys.insert(key)
        tracker.activeMissedGasMixId = ean50.gasMixId
        let surface = FullComputerGasSwitchPolicy.evaluateSurface(
            activeGas: trimix,
            depthMeters: 20,
            plannedGases: [ean50],
            tracker: tracker,
            environment: .seaLevelSaltWater
        )
        if case .missed(let prompt) = surface {
            XCTAssertEqual(prompt.suggestedGasMixId, ean50.gasMixId)
        } else {
            XCTFail("Expected missed surface")
        }
    }

    func testProjectionUsesOnlyConfirmedGases() {
        var tracker = FullComputerGasSwitchTracker.initial
        tracker.bootstrap(bottomGasMixId: trimix.gasMixId)
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
        let projection = FullComputerGasSwitchPolicy.projectionGases(from: plan, tracker: tracker)
        XCTAssertTrue(projection.deco.isEmpty)
        tracker.confirmedGasMixIds.insert(ean50.gasMixId)
        let confirmed = FullComputerGasSwitchPolicy.projectionGases(from: plan, tracker: tracker)
        XCTAssertEqual(confirmed.deco.count, 1)
    }
}
