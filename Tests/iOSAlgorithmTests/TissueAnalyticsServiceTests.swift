import XCTest

final class TissueAnalyticsServiceTests: XCTestCase {
    private func decoPlannerInput(gfLow: Double = 30, gfHigh: Double = 85) -> GasPlanInput {
        var input = GasPlanInput()
        input.ensurePlannerCylindersFromLegacy()
        input.plannedDepthMeters = 30
        input.plannedBottomMinutes = 20
        input.plannedAverageDepthMeters = 24
        input.gfLow = gfLow
        input.gfHigh = gfHigh
        input.bottomGas = GasMix(name: "Air", mixKind: .air, oxygen: 0.21, helium: 0, maxPPO2: 1.4)
        if let index = input.plannerCylinders.firstIndex(where: { $0.role == .bottom }) {
            input.plannerCylinders[index].gas = input.bottomGas
        }
        return PlannerModePolicy.activePlanInput(from: input, mode: .deco)
    }

    private func sampleSession() -> DiveSession {
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        var samples: [DiveSample] = []
        for minute in 0...30 {
            let depth: Double
            if minute < 5 {
                depth = Double(minute * 6)
            } else if minute < 25 {
                depth = 30
            } else {
                depth = max(0, 30 - Double(minute - 25) * 6)
            }
            samples.append(
                DiveSample(
                    timestamp: start.addingTimeInterval(TimeInterval(minute * 60)),
                    depthMeters: depth,
                    temperatureCelsius: 18
                )
            )
        }
        return DiveSession(
            startDate: start,
            endDate: start.addingTimeInterval(30 * 60),
            durationSeconds: 30 * 60,
            maxDepthMeters: 30,
            avgDepthMeters: 22,
            avgWaterTemperatureCelsius: 18,
            ttv: 0,
            entryGPS: nil,
            exitGPS: nil,
            samples: samples,
            gasLabel: .nitrox,
            isManual: false,
            hasDepthProfile: true
        )
    }

    func testPlannerTraceGeneratesSixteenCompartments() {
        let input = decoPlannerInput()
        let plan = PlannerService.makePlan(input: input, mode: .deco)
        XCTAssertFalse(plan.tissueHistory.isEmpty)
        guard let presentation = TissueAnalyticsService.presentationForPlanner(plan: plan, input: input, mode: .deco) else {
            XCTFail("Expected planner tissue analytics")
            return
        }
        XCTAssertEqual(presentation.trace.finalCompartments.count, 16)
        XCTAssertEqual(presentation.trace.samples.first?.compartmentLoadingsPercent.count, 16)
        XCTAssertEqual(presentation.trace.source, .planned)
    }

    func testPlannerIdentifiesControllingCompartment() {
        let input = decoPlannerInput()
        let plan = PlannerService.makePlan(input: input, mode: .deco)
        guard let presentation = TissueAnalyticsService.presentationForPlanner(plan: plan, input: input, mode: .deco) else {
            XCTFail("Expected planner tissue analytics")
            return
        }
        let controlling = presentation.trace.controllingCompartment
        XCTAssertTrue((0..<16).contains(controlling))
        let maxLoading = presentation.trace.finalCompartments.map(\.loadingPercent).max() ?? 0
        let controllingLoading = presentation.trace.finalCompartments[controlling].loadingPercent
        XCTAssertEqual(controllingLoading, maxLoading, accuracy: 0.001)
    }

    func testLoadingColorThresholds() {
        XCTAssertEqual(TissueAnalyticsTheme.loadingColor(for: 50), TissueAnalyticsTheme.green)
        XCTAssertEqual(TissueAnalyticsTheme.loadingColor(for: 70), TissueAnalyticsTheme.yellow)
        XCTAssertEqual(TissueAnalyticsTheme.loadingColor(for: 85), TissueAnalyticsTheme.yellow)
        XCTAssertEqual(TissueAnalyticsTheme.loadingColor(for: 91), TissueAnalyticsTheme.orangeRed)
    }

    func testPlannerTraceInvalidatesOnGFChange() {
        TissueAnalyticsService.invalidateCache()
        let baseInput = decoPlannerInput()
        let plan = PlannerService.makePlan(input: baseInput, mode: .deco)
        let first = TissueAnalyticsService.presentationForPlanner(plan: plan, input: baseInput, mode: .deco)
        XCTAssertNotNil(first)
        let changedInput = decoPlannerInput(gfLow: 40, gfHigh: 90)
        let second = TissueAnalyticsService.presentationForPlanner(plan: plan, input: changedInput, mode: .deco)
        XCTAssertNotNil(second)
        XCTAssertNotEqual(first?.cacheKey, second?.cacheKey)
    }

    func testLogbookRecordedSessionUsesRecordedBuhlmannReplay() {
        TissueAnalyticsService.invalidateCache()
        let presentation = TissueAnalyticsService.presentationForSession(sampleSession())
        XCTAssertNotNil(presentation)
        XCTAssertEqual(presentation?.trace.source, .recorded)
        XCTAssertFalse(presentation?.trace.samples.isEmpty ?? true)
    }

    func testManualLogbookSessionUsesSimulatedEstimate() {
        TissueAnalyticsService.invalidateCache()
        var session = sampleSession()
        session.isManual = true
        let presentation = TissueAnalyticsService.presentationForSession(session)
        XCTAssertEqual(presentation?.trace.source, .simulated)
    }

    func testInsufficientSessionDataReturnsNil() {
        let session = DiveSession(
            startDate: Date(),
            endDate: Date(),
            durationSeconds: 0,
            maxDepthMeters: 0,
            avgDepthMeters: 0,
            avgWaterTemperatureCelsius: nil,
            ttv: 0,
            entryGPS: nil,
            exitGPS: nil,
            samples: [],
            hasDepthProfile: false
        )
        XCTAssertNil(TissueAnalyticsService.presentationForSession(session))
    }

    func testPPN2MatchesActiveGasAndDepth() {
        let environment = PlannerEnvironment.seaLevelSaltWater
        let air = BuhlmannGas(name: "Air", role: .bottom, oxygenFraction: 0.21, heliumFraction: 0, maxPPO2Bar: 1.4, switchDepthMeters: 0)
        let depth = 30.0
        let ppN2 = NarcosisAnalyticsSupport.ppN2Bar(depthMeters: depth, gas: air, environment: environment)
        let expected = air.inspiredPressure(depthMeters: depth, inert: .nitrogen, environment: environment)
        XCTAssertEqual(ppN2, expected, accuracy: 0.001)
    }

    func testENDDerivedFromPPN2() {
        let environment = PlannerEnvironment.seaLevelSaltWater
        let air = BuhlmannGas(name: "Air", role: .bottom, oxygenFraction: 0.21, heliumFraction: 0, maxPPO2Bar: 1.4, switchDepthMeters: 0)
        let depth = 30.0
        let ppN2 = NarcosisAnalyticsSupport.ppN2Bar(depthMeters: depth, gas: air, environment: environment)
        let end = NarcosisAnalyticsSupport.endMeters(fromPPN2Bar: ppN2, environment: environment)
        XCTAssertGreaterThan(end, 0)
        XCTAssertLessThan(end, depth + 1)
    }
}
