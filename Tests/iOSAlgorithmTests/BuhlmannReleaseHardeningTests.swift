import XCTest

final class BuhlmannReleaseHardeningTests: XCTestCase {
    func testExternalReferenceEnvelopeForAirNitroxAndTrimixProfiles() {
        let air = BuhlmannEngine.plan(
            BuhlmannTestSupport.request(
                depth: 30,
                bottomMinutes: 20,
                bottomGas: BuhlmannTestSupport.air(switchDepth: 30),
                gfLow: 30,
                gfHigh: 70
            )
        )
        XCTAssertEqual(air.modelState, .validReference)
        XCTAssertGreaterThanOrEqual(air.ttsMinutes, 3)
        XCTAssertLessThanOrEqual(air.ttsMinutes, 25)
        XCTAssertGreaterThanOrEqual(air.totalRuntimeMinutes, 23)
        XCTAssertLessThanOrEqual(air.totalRuntimeMinutes, 50)

        let nitrox = BuhlmannEngine.plan(
            BuhlmannTestSupport.request(
                depth: 30,
                bottomMinutes: 20,
                bottomGas: BuhlmannTestSupport.nitrox32(switchDepth: 30),
                gfLow: 30,
                gfHigh: 70
            )
        )
        XCTAssertEqual(nitrox.modelState, .validReference)
        XCTAssertLessThanOrEqual(nitrox.ttsMinutes, air.ttsMinutes)
        XCTAssertLessThanOrEqual(nitrox.totalRuntimeMinutes, air.totalRuntimeMinutes)

        let trimix = BuhlmannEngine.plan(
            BuhlmannTestSupport.request(
                depth: 50,
                bottomMinutes: 30,
                bottomGas: BuhlmannTestSupport.trimix1845(switchDepth: 50),
                decoGases: [BuhlmannTestSupport.ean50(), BuhlmannTestSupport.oxygen()],
                gfLow: 30,
                gfHigh: 70
            )
        )
        XCTAssertEqual(trimix.modelState, .validReference)
        XCTAssertFalse(trimix.stops.isEmpty)
        XCTAssertGreaterThanOrEqual(trimix.ttsMinutes, 15)
        XCTAssertLessThanOrEqual(trimix.ttsMinutes, 100)
    }

    func testTTSRuntimeAndGasSwitchAccountingAreSeparated() {
        let request = BuhlmannTestSupport.request(
            depth: 50,
            bottomMinutes: 30,
            bottomGas: BuhlmannTestSupport.trimix1845(switchDepth: 50),
            decoGases: [BuhlmannTestSupport.ean50(), BuhlmannTestSupport.oxygen()]
        )
        let plan = BuhlmannEngine.plan(request)

        XCTAssertEqual(plan.modelState, .validReference)
        XCTAssertEqual(plan.bottomMinutes, request.bottomMinutes, accuracy: 0.001)
        XCTAssertGreaterThan(plan.descentMinutes, 0)
        XCTAssertGreaterThan(plan.totalRuntimeMinutes, plan.ttsMinutes)
        XCTAssertGreaterThanOrEqual(plan.gasSwitchMinutes, BuhlmannConstants.gasSwitchMinutes)
        XCTAssertTrue(plan.segments.contains { $0.kind == .gasSwitch && $0.minutes == BuhlmannConstants.gasSwitchMinutes })
    }

    func testResidualTissueStateCanSeedARepetitivePlanningReference() throws {
        let first = BuhlmannEngine.plan(
            BuhlmannTestSupport.request(
                depth: 30,
                bottomMinutes: 30,
                bottomGas: BuhlmannTestSupport.air(switchDepth: 30)
            )
        )
        let finalState = try XCTUnwrap(first.finalTissueState)

        let cleanSecond = BuhlmannEngine.plan(
            BuhlmannTestSupport.request(
                depth: 30,
                bottomMinutes: 20,
                bottomGas: BuhlmannTestSupport.air(switchDepth: 30)
            )
        )
        var repetitiveRequest = BuhlmannTestSupport.request(
            depth: 30,
            bottomMinutes: 20,
            bottomGas: BuhlmannTestSupport.air(switchDepth: 30)
        )
        repetitiveRequest.initialTissueState = finalState
        let repetitiveSecond = BuhlmannEngine.plan(repetitiveRequest)

        XCTAssertEqual(repetitiveSecond.modelState, .validReference)
        XCTAssertGreaterThanOrEqual(repetitiveSecond.ttsMinutes, cleanSecond.ttsMinutes)
        XCTAssertNotEqual(repetitiveSecond.finalTissueState, cleanSecond.finalTissueState)
    }

    func testGasMustBeOperationalAcrossTheWholeRespiredSegment() {
        let hypoxicBottom = BuhlmannGas(
            name: "TX 10/50",
            role: .bottom,
            oxygenFraction: 0.10,
            heliumFraction: 0.50,
            maxPPO2Bar: 1.4,
            switchDepthMeters: 60
        )
        let missingTravel = BuhlmannEngine.validate(
            BuhlmannTestSupport.request(depth: 60, bottomMinutes: 20, bottomGas: hypoxicBottom)
        )
        XCTAssertTrue(missingTravel.contains { issue in
            if case .hypoxicGasTooShallow = issue { return true }
            return false
        })

        let overLimitTravel = BuhlmannGas(
            name: "EAN32 travel",
            role: .travel,
            oxygenFraction: 0.32,
            heliumFraction: 0,
            maxPPO2Bar: 1.4,
            switchDepthMeters: 30
        )
        let travelIssues = BuhlmannEngine.validate(
            BuhlmannTestSupport.request(
                depth: 60,
                bottomMinutes: 20,
                bottomGas: hypoxicBottom,
                travelGases: [overLimitTravel],
                decoGases: [BuhlmannTestSupport.oxygen()]
            )
        )
        XCTAssertTrue(travelIssues.contains { issue in
            if case .ppo2Exceeded = issue { return true }
            return false
        })

        let validatedTravel = BuhlmannGas(
            name: "Air travel",
            role: .travel,
            oxygenFraction: 0.21,
            heliumFraction: 0,
            maxPPO2Bar: 1.6,
            switchDepthMeters: 30
        )
        let validTravelPlan = BuhlmannEngine.plan(
            BuhlmannTestSupport.request(
                depth: 60,
                bottomMinutes: 20,
                bottomGas: hypoxicBottom,
                travelGases: [validatedTravel],
                decoGases: [BuhlmannTestSupport.ean50(), BuhlmannTestSupport.oxygen()]
            )
        )
        XCTAssertFalse(validTravelPlan.issues.contains { issue in
            if case .gasNotOperationalInSegment = issue { return true }
            return false
        })
    }

    func testNoStopAscentCanUseValidatedTravelGasSwitch() {
        let hypoxicBottom = BuhlmannGas(
            name: "TX 10/50",
            role: .bottom,
            oxygenFraction: 0.10,
            heliumFraction: 0.50,
            maxPPO2Bar: 1.4,
            switchDepthMeters: 30
        )
        let airTravel = BuhlmannGas(
            name: "Air travel",
            role: .travel,
            oxygenFraction: 0.21,
            heliumFraction: 0,
            maxPPO2Bar: 1.6,
            switchDepthMeters: 18
        )
        let plan = BuhlmannEngine.plan(
            BuhlmannTestSupport.request(
                depth: 30,
                bottomMinutes: 5,
                bottomGas: hypoxicBottom,
                travelGases: [airTravel]
            )
        )

        XCTAssertEqual(plan.modelState, .validReference)
        XCTAssertFalse(plan.issues.contains { issue in
            if case .gasNotOperationalInSegment = issue { return true }
            return false
        })
        XCTAssertTrue(plan.segments.contains { $0.kind == .gasSwitch && $0.gas.name == "Air travel" && abs($0.depthMeters - 18) < 0.01 })
    }

    func testGasAnalysisUsesGeneratedScheduleForOxygenExposureAndDensity() {
        let input = BuhlmannTestSupport.gasPlanInput()
        let enginePlan = BuhlmannPlanner.enginePlan(input: input)
        let bottomOnly = GasPlanningService.analyze(input: input)
        let scheduleAware = GasPlanningService.analyze(input: input, enginePlan: enginePlan)

        XCTAssertEqual(enginePlan.modelState, .validReference)
        XCTAssertGreaterThanOrEqual(scheduleAware.cnsPercent, bottomOnly.cnsPercent)
        XCTAssertGreaterThanOrEqual(scheduleAware.otu, bottomOnly.otu)
        XCTAssertGreaterThanOrEqual(scheduleAware.densityAtDepth, bottomOnly.densityAtDepth)
    }
}
