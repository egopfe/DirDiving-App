import XCTest

final class PerformanceConcurrencyBatteryRemediationWatchTests: XCTestCase {
    private var sessionStart = Date(timeIntervalSince1970: 1_713_000_000)

    override func setUp() {
        super.setUp()
        sessionStart = Date(timeIntervalSince1970: 1_713_000_000)
        FullComputerDecoSolver.resetCacheForTests()
        StopwatchPersistencePolicy.resetTestHook()
        GPSLifecyclePolicy.resetTestHook()
    }

    func testSignpostCatalogCompilesOnWatch() {
        XCTAssertEqual(DIRPerformanceSignpostCategory.allCases.count, 24)
        let interval = DIRPerformanceSignpost.begin(.watchFullComputerTissueTick)
        interval.end()
    }

    func testFullComputerTimingFaultMatrixExtended() throws {
        let deltas: [TimeInterval] = [0.5, 1.0, 1.5, 2, 5, 10, 30]
        for delta in deltas {
            var engine = try FullComputerRuntimeEngine(plan: .defaultAirGF3070, sessionStart: sessionStart)
            _ = engine.ingestSample(depthMeters: 22, timestamp: sessionStart)
            let before = engine.snapshot.tissueState.compartments[0].nitrogenPressure
            engine.tick(now: sessionStart.addingTimeInterval(delta))
            let after = engine.snapshot.tissueState.compartments[0].nitrogenPressure
            if delta > 0 {
                XCTAssertGreaterThan(after, before, "delta \(delta)s should load tissues")
            }
        }
    }

    func testDuplicateTickDoesNotDoubleIntegrate() throws {
        var engine = try FullComputerRuntimeEngine(plan: .defaultAirGF3070, sessionStart: sessionStart)
        _ = engine.ingestSample(depthMeters: 18, timestamp: sessionStart)
        let tissue = engine.snapshot.tissueState
        engine.tick(now: sessionStart)
        engine.tick(now: sessionStart)
        XCTAssertEqual(engine.snapshot.tissueState, tissue)
    }

    func testDecoSolverWithinBudget() throws {
        var engine = try FullComputerRuntimeEngine(plan: .defaultAirGF3070, sessionStart: sessionStart)
        _ = engine.ingestSample(depthMeters: 40, timestamp: sessionStart)
        let budget = DIRPerformanceBudgets.entry(for: .watchFullComputerCompleteSolver)!
        let start = CFAbsoluteTimeGetCurrent()
        engine.tick(now: sessionStart.addingTimeInterval(1))
        let elapsed = CFAbsoluteTimeGetCurrent() - start
        XCTAssertLessThan(elapsed, budget.hardTestLimit)
        XCTAssertNotEqual(engine.snapshot.modelState, .unavailable)
    }

    func testStopwatchRuntimeTickDoesNotPersistUserDefaults() {
        StopwatchPersistencePolicy.resetTestHook()
        let before = StopwatchPersistencePolicy.testHook_writeCount
        for _ in 0..<60 {
            _ = StopwatchPersistencePolicy.isAcceptedPayload(
                accumulatedTime: Double.random(in: 0...100),
                isRunning: true,
                startedAt: Date()
            )
        }
        XCTAssertEqual(StopwatchPersistencePolicy.testHook_writeCount, before)
    }

    func testDraftPersistenceIntervalAtLeastEightSeconds() {
        let interval = DiveAlgorithmConfiguration.activeDiveDraftPersistenceIntervalSeconds
        XCTAssertGreaterThanOrEqual(interval, 8)
    }

    func testSnorkelingCheckpointDebounceMatchesPolicy() {
        XCTAssertEqual(
            SnorkelingReleaseHardTolerances.checkpointDebounceNanoseconds,
            250_000_000
        )
    }

    func testMissionModeDoesNotChangeRuntimeMathProfile() {
        XCTAssertTrue(MissionModeRuntimeProfile.standard.animationsEnabled)
        XCTAssertFalse(MissionModeRuntimeProfile.mission.animationsEnabled)
        XCTAssertTrue(MissionModeLifecycle.shouldActivateRuntime(autoEnablePreference: true, manualPendingForSession: false))
    }

    func testWatchDiveLogbookSyntheticDecode() throws {
        let sessions = WatchDiveLogbookScalabilitySupport.makeSyntheticSessions(count: 500)
        let data = try WatchDiveLogbookScalabilitySupport.encodeSessions(sessions)
        let decoded = try WatchDiveLogbookScalabilitySupport.decodeSessions(from: data)
        XCTAssertEqual(decoded.count, 500)
    }

    func testGPSLifecyclePolicyDocumentsDiveOwnership() {
        XCTAssertEqual(GPSLifecyclePolicy.diveDistanceFilterMeters, 5)
        XCTAssertFalse(
            GPSLifecyclePolicy.shouldRestartUpdatesAfterAuthorization(
                maintainsLocationUpdates: false,
                hasActiveBestEffortCapture: false
            )
        )
    }
}
