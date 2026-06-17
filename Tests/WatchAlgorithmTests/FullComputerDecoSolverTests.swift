import XCTest

final class FullComputerDecoSolverTests: XCTestCase {
    private let plan = FullComputerRuntimePlan.defaultAirGF3070
    private let start = Date(timeIntervalSince1970: 1_700_000_000)

    override func tearDown() {
        FullComputerDecoSolver.resetCacheForTests()
        super.tearDown()
    }

    func testNoDecoNDLThresholdColors() {
        let tissue = saturatedAtDepth(12, minutes: 5)
        let projection = BuhlmannEngine.runtimeProjection(
            tissueState: tissue,
            depthMeters: 12,
            gas: plan.activeGas,
            gfLow: plan.gfLow,
            gfHigh: plan.gfHigh
        )
        XCTAssertGreaterThan(projection.ndlMinutes ?? 0, 10)
        let presentation = solve(tissue: tissue, depth: 12, runtime: 5)
        XCTAssertEqual(presentation.mode, .noDecompression)
        XCTAssertEqual(presentation.ndlAccent, .green)

        let tight = saturatedAtDepth(30, minutes: 18)
        let tightPresentation = solve(tissue: tight, depth: 30, runtime: 18)
        if let ndl = tightPresentation.ndlDisplayMinutes, ndl <= 10, ndl > 5 {
            XCTAssertEqual(tightPresentation.ndlAccent, .yellow)
        }
        if let ndl = tightPresentation.ndlDisplayMinutes, ndl <= 5 {
            XCTAssertEqual(tightPresentation.ndlAccent, .red)
        }
    }

    func testAtomicTransitionToDecompressionNeverShowsZeroNDL() throws {
        var engine = try FullComputerRuntimeEngine(sessionStart: start)
        _ = engine.ingestSample(depthMeters: 0, timestamp: start)
        _ = engine.ingestSample(depthMeters: 38, timestamp: start.addingTimeInterval(120))
        for minute in 1...24 {
            engine.tick(now: start.addingTimeInterval(120 + Double(minute * 60)))
        }
        let presentation = engine.snapshot.decoPresentation
        if presentation.mode == .decompression {
            XCTAssertNil(presentation.ndlDisplayMinutes)
            XCTAssertGreaterThan(presentation.ttsMinutes, 0)
        } else if let ndl = presentation.ndlDisplayMinutes {
            XCTAssertGreaterThan(ndl, 0)
        }
    }

    func testCeilingPresentationRoundingIsSeparateFromExact() throws {
        var engine = try FullComputerRuntimeEngine(sessionStart: start)
        _ = engine.ingestSample(depthMeters: 35, timestamp: start)
        for minute in 1...30 {
            engine.tick(now: start.addingTimeInterval(Double(minute * 60)))
        }
        let presentation = engine.snapshot.decoPresentation
        XCTAssertEqual(
            presentation.ceilingMetersRounded,
            FullComputerDecoSolver.presentationCeilingMeters(presentation.ceilingMetersExact)
        )
        if presentation.nextStopDepthMeters != nil {
            XCTAssertNotEqual(
                presentation.ceilingMetersRounded,
                presentation.nextStopDepthMeters ?? -1,
                "Ceiling presentation must stay distinct from discrete stop depth when stops exist."
            )
        }
    }

    func testSolverCachingReturnsIdenticalResultForSameInput() throws {
        var engine = try FullComputerRuntimeEngine(sessionStart: start)
        _ = engine.ingestSample(depthMeters: 24, timestamp: start.addingTimeInterval(300))
        let first = engine.snapshot.decoPresentation
        engine.tick(now: start.addingTimeInterval(301))
        let second = engine.snapshot.decoPresentation
        XCTAssertEqual(first, second)
    }

    func testPlannerRuntimeTTSWithinTolerance() throws {
        let depth = 32.0
        let bottomMinutes = 22.0
        var engine = try FullComputerRuntimeEngine(sessionStart: start)
        _ = engine.ingestSample(depthMeters: 0, timestamp: start)
        _ = engine.ingestSample(depthMeters: depth, timestamp: start.addingTimeInterval(120))
        var tick = start.addingTimeInterval(120)
        for _ in 0..<Int(bottomMinutes * 60) {
            engine.tick(now: tick)
            tick = tick.addingTimeInterval(1)
        }
        let runtimePresentation = engine.snapshot.decoPresentation
        let planner = BuhlmannEngine.plan(
            BuhlmannPlanRequest(
                maxDepthMeters: depth,
                bottomMinutes: bottomMinutes,
                bottomGas: plan.activeGas,
                travelGases: [],
                decoGases: [],
                gfLow: 30,
                gfHigh: 70,
                initialTissueState: .airSaturated()
            )
        )
        XCTAssertFalse(planner.hasBlockingIssues)
        XCTAssertEqual(
            Double(runtimePresentation.ttsMinutes),
            Double(planner.ttsMinutes),
            accuracy: 4.0
        )
    }

    func testDecoStopPanelAppearsWhenStopsExist() throws {
        var engine = try FullComputerRuntimeEngine(sessionStart: start)
        _ = engine.ingestSample(depthMeters: 40, timestamp: start)
        for minute in 1...28 {
            engine.tick(now: start.addingTimeInterval(Double(minute * 60)))
        }
        let presentation = engine.snapshot.decoPresentation
        if presentation.mode == .decompression, presentation.remainingStopCount > 0 {
            XCTAssertTrue(presentation.showDecoStopPanel)
            XCTAssertNotNil(presentation.nextStopDepthMeters)
        }
    }

    func testRequiresDecompressionTreatsPositiveNDLAsNoDeco() {
        let tissue = saturatedAtDepth(18, minutes: 5)
        let projection = BuhlmannEngine.runtimeProjection(
            tissueState: tissue,
            depthMeters: 18,
            gas: plan.activeGas,
            gfLow: plan.gfLow,
            gfHigh: plan.gfHigh
        )
        XCTAssertGreaterThan(projection.ndlMinutes ?? 0, 0)
        XCTAssertFalse(
            FullComputerDecoSolver.requiresDecompression(projection: projection, depthMeters: 18)
        )
    }

    func testRequiresDecompressionTreatsZeroOrMissingNDLAsDecoEligible() {
        let tissue = saturatedAtDepth(40, minutes: 30)
        let projection = BuhlmannEngine.runtimeProjection(
            tissueState: tissue,
            depthMeters: 40,
            gas: plan.activeGas,
            gfLow: plan.gfLow,
            gfHigh: plan.gfHigh
        )
        if projection.ndlMinutes == 0 || projection.ndlMinutes == nil || !projection.stops.isEmpty {
            XCTAssertTrue(
                FullComputerDecoSolver.requiresDecompression(projection: projection, depthMeters: 40)
            )
        }
    }

    func testCeilingViolationDetectedWhenTooShallow() {
        let tissue = saturatedAtDepth(35, minutes: 25)
        let projection = BuhlmannEngine.runtimeProjection(
            tissueState: tissue,
            depthMeters: 35,
            gas: plan.activeGas,
            gfLow: plan.gfLow,
            gfHigh: plan.gfHigh
        )
        guard FullComputerDecoSolver.requiresDecompression(projection: projection, depthMeters: 35) else {
            return
        }
        let shallowPresentation = solve(
            tissue: tissue,
            depth: max(0, projection.operationalCeilingMeters - 2),
            runtime: 30
        )
        if projection.operationalCeilingMeters > 1 {
            XCTAssertTrue(shallowPresentation.ceilingViolation)
            XCTAssertTrue(shallowPresentation.showCeilingViolationBanner)
        }
    }

    private func solve(tissue: BuhlmannTissueState, depth: Double, runtime: Int) -> FullComputerDecoPresentation {
        FullComputerDecoSolver.solve(
            input: FullComputerDecoSolverInput(
                tissueState: tissue,
                depthMeters: depth,
                plan: plan,
                runtimeMinutes: runtime
            )
        )
    }

    private func saturatedAtDepth(_ depth: Double, minutes: Double) -> BuhlmannTissueState {
        BuhlmannTissueState.airSaturated().loadedConstantDepth(
            depthMeters: depth,
            minutes: minutes,
            gas: plan.activeGas,
            environment: plan.plannerEnvironment
        )
    }
}
