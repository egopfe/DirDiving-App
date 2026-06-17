import XCTest
@testable import DIRDivingWatchApp

@MainActor
final class FullComputerReleaseHardValidationTests: XCTestCase {
    private var sessionStart = Date(timeIntervalSince1970: 1_700_000_000)

    override func setUp() {
        super.setUp()
        sessionStart = Date(timeIntervalSince1970: 1_700_000_000)
        FullComputerDecoSolver.resetCacheForTests()
        #if DEBUG
        FullComputerPrediveConfigurationStore.shared.resetForTests()
        #endif
    }

    // MARK: - Mockup / bundle safety

    func testNoRasterMockupEmbeddedInWatchBundle() throws {
        let bundle = Bundle.main
        let resourcePaths = bundle.paths(forResourcesOfType: "png", inDirectory: nil)
        let embeddedMockups = resourcePaths.filter { $0.contains("FC_UI_") }
        XCTAssertTrue(embeddedMockups.isEmpty, "FC_UI mockups must not ship in the app bundle: \(embeddedMockups)")
    }

    func testDiveManagerNeverAssignsGaugeDuringFullComputerSession() throws {
        let source = try String(
            contentsOf: repositoryRoot().appendingPathComponent("Services/DiveManager.swift"),
            encoding: .utf8
        )
        XCTAssertFalse(
            source.contains("sessionDivingMode = .gauge"),
            "DiveManager must not silently downgrade to Gauge during an active Full Computer session"
        )
    }

    // MARK: - Numerical robustness

    func testNaNDepthRejectedWithoutResettingTissues() throws {
        var engine = try FullComputerRuntimeEngine(sessionStart: sessionStart)
        _ = engine.ingestSample(depthMeters: 15, timestamp: sessionStart.addingTimeInterval(30))
        let before = engine.snapshot.tissueState
        XCTAssertFalse(engine.ingestSample(depthMeters: .nan, timestamp: sessionStart.addingTimeInterval(31)))
        XCTAssertEqual(engine.snapshot.tissueState, before)
        XCTAssertEqual(engine.snapshot.engineState, .unavailable)
    }

    func testInfiniteDepthRejected() throws {
        var engine = try FullComputerRuntimeEngine(sessionStart: sessionStart)
        XCTAssertFalse(engine.ingestSample(depthMeters: .infinity, timestamp: sessionStart))
        XCTAssertEqual(engine.snapshot.engineState, .unavailable)
    }

    func testNegativeDepthRejected() throws {
        var engine = try FullComputerRuntimeEngine(sessionStart: sessionStart)
        XCTAssertFalse(engine.ingestSample(depthMeters: -1, timestamp: sessionStart))
        XCTAssertEqual(engine.snapshot.engineState, .unavailable)
    }

    // MARK: - Differential planner vs runtime

    func testDifferentialAirPlannerMatchesRuntimeTTS() throws {
        try assertPlannerRuntimeTTSAlignment(
            plan: .defaultAirGF3070,
            depthMeters: 32,
            bottomMinutes: 22
        )
    }

    func testDifferentialEAN32PlannerMatchesRuntimeTTS() throws {
        var profile = FullComputerGasProfile.defaultAirGF3070
        profile.applyBottomGasKind(.ean)
        profile.bottomGas.oxygenFraction = 0.32
        profile.bottomGas.name = "EAN32"
        let plan = FullComputerRuntimePlan(profile: profile)
        try assertPlannerRuntimeTTSAlignment(plan: plan, depthMeters: 30, bottomMinutes: 25)
    }

    func testDifferentialTrimixBottomGasMatchesRuntimeTTS() throws {
        var profile = FullComputerGasProfile.defaultAirGF3070
        profile.applyBottomGasKind(.trimix)
        profile.bottomGas.oxygenFraction = 0.18
        profile.bottomGas.heliumFraction = 0.45
        profile.bottomGas.name = "TMX18/45"
        profile.decoGases = []
        profile.futureGasTTSPolicy = .enabledSwitchGasesOnly
        let plan = FullComputerRuntimePlan(profile: profile)
        XCTAssertTrue(plan.decoGases.isEmpty)
        try assertPlannerRuntimeTTSAlignment(plan: plan, depthMeters: 45, bottomMinutes: 15)
    }

    func testRepetitiveInitialTissuesReduceNDLAndMatchSolver() throws {
        var engine = try FullComputerRuntimeEngine(sessionStart: sessionStart)
        _ = engine.ingestSample(depthMeters: 0, timestamp: sessionStart)
        _ = engine.ingestSample(depthMeters: 28, timestamp: sessionStart.addingTimeInterval(120))
        var tickTime = sessionStart.addingTimeInterval(120)
        while tickTime.timeIntervalSince(sessionStart.addingTimeInterval(120)) < 20 * 60 {
            engine.tick(now: tickTime)
            tickTime = tickTime.addingTimeInterval(1)
        }
        let loadedTissues = engine.snapshot.tissueState
        let plan = FullComputerRuntimePlan.defaultAirGF3070

        let freshProjection = BuhlmannEngine.runtimeProjection(
            tissueState: .airSaturated(surfacePressureBar: plan.plannerEnvironment.surfacePressureBar),
            depthMeters: 28,
            gas: plan.activeGas,
            gfLow: plan.gfLow,
            gfHigh: plan.gfHigh,
            plannerEnvironment: plan.plannerEnvironment,
            travelGases: plan.travelGases,
            decoGases: plan.decoGases,
            ascentRateMetersPerMinute: plan.ascentRateMetersPerMinute,
            stopIntervalMeters: plan.stopIntervalMeters
        )
        let loadedProjection = BuhlmannEngine.runtimeProjection(
            tissueState: loadedTissues,
            depthMeters: 28,
            gas: plan.activeGas,
            gfLow: plan.gfLow,
            gfHigh: plan.gfHigh,
            plannerEnvironment: plan.plannerEnvironment,
            travelGases: plan.travelGases,
            decoGases: plan.decoGases,
            ascentRateMetersPerMinute: plan.ascentRateMetersPerMinute,
            stopIntervalMeters: plan.stopIntervalMeters
        )
        XCTAssertGreaterThan(freshProjection.ndlMinutes ?? 0, loadedProjection.ndlMinutes ?? 0)

        let solverPresentation = FullComputerDecoSolver.solve(
            input: FullComputerDecoSolverInput(
                tissueState: loadedTissues,
                depthMeters: 28,
                plan: plan,
                runtimeMinutes: 20
            )
        )
        XCTAssertEqual(
            Double(solverPresentation.ndlDisplayMinutes ?? 0),
            loadedProjection.ndlMinutes ?? 0,
            accuracy: FullComputerReleaseHardTolerances.ndlMinutes
        )
    }

    func testMultilevelProfileProducesFiniteDecoMetrics() throws {
        var engine = try FullComputerRuntimeEngine(sessionStart: sessionStart)
        let depths: [(Double, TimeInterval)] = [
            (0, 0),
            (18, 90),
            (30, 180),
            (24, 420),
            (30, 540),
        ]
        for (depth, offset) in depths {
            _ = engine.ingestSample(depthMeters: depth, timestamp: sessionStart.addingTimeInterval(offset))
        }
        var tickTime = sessionStart.addingTimeInterval(540)
        for _ in 0..<120 {
            engine.tick(now: tickTime)
            tickTime = tickTime.addingTimeInterval(1)
        }
        XCTAssertGreaterThanOrEqual(engine.snapshot.ttsMinutes, 0)
        XCTAssertNotNil(engine.snapshot.ndlMinutes)
    }

    // MARK: - Safety gates

    func testInvalidPlanCannotStartRuntimeEngine() {
        let readiness = FullComputerRuntimeEngine.canStart(
            plan: FullComputerRuntimePlan(
                activeGas: BuhlmannGas(
                    name: "Bad",
                    role: .bottom,
                    oxygenFraction: 0,
                    heliumFraction: 0,
                    maxPPO2Bar: 1.4,
                    switchDepthMeters: 0
                ),
                gfLow: 30,
                gfHigh: 70,
                plannerEnvironment: .seaLevelSaltWater,
                travelGases: [],
                decoGases: [],
                ascentRateMetersPerMinute: 9,
                stopIntervalMeters: 3
            )
        )
        XCTAssertFalse(readiness.ready)
    }

    func testPrediveReadinessBlocksUnavailableSensor() {
        let readiness = FullComputerPrediveReadiness.evaluate(
            depthAutomationAvailable: false,
            validationIssues: []
        )
        XCTAssertEqual(readiness, .sensorUnavailable)
    }

    func testFullComputerSessionKeepsModeWhenDepthValidationFails() {
        let diveManager = DiveManager(
            logStore: DiveLogStore(),
            gpsManager: GPSManager(),
            ascentSettings: AscentRateSettingsStore()
        )
        diveManager.testHook_setDepthAutomationAvailableForTests(true)
        diveManager.recordSessionModeSelection(activity: .diving, divingMode: .fullComputer)
        diveManager.startManualDive()
        XCTAssertEqual(diveManager.sessionDivingMode, .fullComputer)

        let start = Date()
        diveManager.testHook_processDepthMeasurement(rawDepthMeters: 20, timestamp: start)
        diveManager.testHook_processDepthMeasurement(rawDepthMeters: .nan, timestamp: start.addingTimeInterval(1))
        XCTAssertEqual(diveManager.sessionDivingMode, .fullComputer)
        XCTAssertNotNil(diveManager.testHook_lastErrorMessage)
    }

    // MARK: - Performance budgets

    func testDecoSolverRespectsPerformanceBudget() throws {
        var engine = try FullComputerRuntimeEngine(sessionStart: sessionStart)
        _ = engine.ingestSample(depthMeters: 32, timestamp: sessionStart.addingTimeInterval(600))
        engine.tick(now: sessionStart.addingTimeInterval(600))
        let input = FullComputerDecoSolverInput(
            tissueState: engine.snapshot.tissueState,
            depthMeters: engine.snapshot.depthMeters,
            plan: engine.runtimePlan,
            runtimeMinutes: engine.snapshot.decoPresentation.runtimeMinutes
        )
        let started = ProcessInfo.processInfo.systemUptime
        _ = FullComputerDecoSolver.solve(input: input)
        let elapsed = ProcessInfo.processInfo.systemUptime - started
        XCTAssertLessThanOrEqual(elapsed, FullComputerReleaseHardTolerances.decoSolverBudgetSeconds)
    }

    func testCheckpointRoundTripWithinBudget() throws {
        let sessionID = UUID()
        var engine = try FullComputerRuntimeEngine(sessionStart: sessionStart)
        _ = engine.ingestSample(depthMeters: 26, timestamp: sessionStart.addingTimeInterval(300))
        engine.tick(now: sessionStart.addingTimeInterval(300))

        let started = ProcessInfo.processInfo.systemUptime
        let checkpoint = try engine.exportCheckpoint(
            sessionID: sessionID,
            watchDivingMode: DIRDivingMode.fullComputer.rawValue
        )
        let data = try FullComputerRuntimeCheckpointCodec.encode(checkpoint)
        let decoded = try FullComputerRuntimeCheckpointCodec.decode(data)
        _ = try FullComputerRuntimeEngine.restoreEngine(from: decoded, sessionStart: sessionStart)
        let elapsed = ProcessInfo.processInfo.systemUptime - started
        XCTAssertLessThanOrEqual(elapsed, FullComputerReleaseHardTolerances.checkpointRoundTripBudgetSeconds)
    }

    // MARK: - Helpers

    private func assertPlannerRuntimeTTSAlignment(
        plan: FullComputerRuntimePlan,
        depthMeters: Double,
        bottomMinutes: Double,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        var engine = try FullComputerRuntimeEngine(plan: plan, sessionStart: sessionStart)
        _ = engine.ingestSample(depthMeters: 0, timestamp: sessionStart)
        _ = engine.ingestSample(depthMeters: depthMeters, timestamp: sessionStart.addingTimeInterval(120))
        let bottomSeconds = bottomMinutes * 60.0
        var tickTime = sessionStart.addingTimeInterval(120)
        while tickTime.timeIntervalSince(sessionStart.addingTimeInterval(120)) < bottomSeconds {
            engine.tick(now: tickTime)
            tickTime = tickTime.addingTimeInterval(1)
        }

        let planner = BuhlmannEngine.plan(
            BuhlmannPlanRequest(
                maxDepthMeters: depthMeters,
                bottomMinutes: bottomMinutes,
                bottomGas: plan.activeGas,
                travelGases: plan.travelGases,
                decoGases: plan.decoGases,
                gfLow: plan.gfLow,
                gfHigh: plan.gfHigh,
                descentRateMetersPerMinute: 18,
                initialTissueState: .airSaturated(),
                plannerEnvironment: plan.plannerEnvironment
            )
        )
        XCTAssertFalse(planner.hasBlockingIssues, file: file, line: line)
        XCTAssertEqual(
            Double(engine.snapshot.ttsMinutes),
            Double(planner.ttsMinutes),
            accuracy: FullComputerReleaseHardTolerances.plannerRuntimeTTSMinutes,
            file: file,
            line: line
        )
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
