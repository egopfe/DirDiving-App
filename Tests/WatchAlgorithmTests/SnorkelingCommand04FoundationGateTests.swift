import XCTest

final class SnorkelingCommand04FoundationGateTests: XCTestCase {
    private let startDate = Date(timeIntervalSince1970: 1_700_000_000)

    func testNavigationPhaseDoesNotMutateSessionUnexpectedly() {
        var engine = makeEngine()
        engine.armSession(at: startDate)
        engine.startSession(at: startDate)
        ingest(&engine, depth: 0.2, offset: 0)
        let dipCountBefore = engine.snapshot.dipCount
        let sessionID = engine.snapshot.session.id
        engine.enterNavigation(at: startDate.addingTimeInterval(1))
        XCTAssertEqual(engine.snapshot.session.id, sessionID)
        XCTAssertEqual(engine.snapshot.dipCount, dipCountBefore)
        XCTAssertEqual(engine.snapshot.phase, .navigation)
        XCTAssertEqual(engine.snapshot.session.state, .navigation)
    }

    func testReturnPhaseDoesNotAutoEndSession() {
        var engine = makeEngine()
        engine.armSession(at: startDate)
        engine.startSession(at: startDate)
        ingest(&engine, depth: 0.2, offset: 0)
        engine.enterReturnMode(at: startDate.addingTimeInterval(1))
        XCTAssertEqual(engine.snapshot.phase, .returnMode)
        XCTAssertNotEqual(engine.snapshot.phase, .ended)
        XCTAssertEqual(engine.snapshot.session.state, .returnMode)
    }

    func testEnteringAndExitingNavigationPreservesMetrics() {
        var engine = makeEngine()
        engine.armSession(at: startDate)
        engine.startSession(at: startDate)
        replay(&engine, depths: [0.2, 0.8, 1.4, 0.2, 0.1], interval: 2)
        let dipCount = engine.snapshot.dipCount
        let waterTime = engine.snapshot.waterTimeSeconds
        engine.enterNavigation(at: startDate.addingTimeInterval(12))
        engine.exitNavigationOrReturn(at: startDate.addingTimeInterval(13))
        XCTAssertEqual(engine.snapshot.dipCount, dipCount)
        XCTAssertEqual(engine.snapshot.waterTimeSeconds, waterTime, accuracy: 0.5)
    }

    func testNoNavigationValuesAreFabricatedBeforeCommand04() throws {
        let contract = try String(
            contentsOf: repositoryRoot().appendingPathComponent("Docs/SNORKELING_NAVIGATION_RETURN_ENGINE_CONTRACT.md"),
            encoding: .utf8
        )
        XCTAssertTrue(contract.contains("READY_FOR_SNORKELING_COMMAND_04"))
        XCTAssertTrue(contract.contains("reference-only"))
        let engineSource = try String(
            contentsOf: repositoryRoot().appendingPathComponent("Shared/Utils/SnorkelingSessionEngine.swift"),
            encoding: .utf8
        )
        XCTAssertFalse(engineSource.contains("bearingDegrees"))
        XCTAssertFalse(engineSource.contains("returnAdvisor"))
        XCTAssertFalse(engineSource.contains("TURN LEFT"))
    }

    func testFoundationGateReadyForCommand04() throws {
        XCTAssertTrue(try SnorkelingArchitectureIsolation.violations(inRepositoryRoot: repositoryRoot()).isEmpty)
        XCTAssertTrue(FileManager.default.fileExists(atPath: repositoryRoot()
            .appendingPathComponent("Docs/SNORKELING_NAVIGATION_RETURN_ENGINE_CONTRACT.md").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: repositoryRoot()
            .appendingPathComponent("Docs/SNORKELING_PERSISTENCE_RECOVERY_CONTRACT.md").path))
    }

    // MARK: - Helpers

    private func makeEngine() -> SnorkelingSessionEngine {
        var config = SnorkelingLifecycleConfiguration.default
        config.dipStartDebounceSeconds = 0.8
        config.surfaceStableDwellSeconds = 2
        config.minimumDipDurationSeconds = 2
        return SnorkelingSessionEngine(configuration: config, sessionStart: startDate)
    }

    private func replay(_ engine: inout SnorkelingSessionEngine, depths: [Double], interval: TimeInterval) {
        for (index, depth) in depths.enumerated() {
            ingest(&engine, depth: depth, offset: TimeInterval(index) * interval)
        }
        if let last = depths.indices.last {
            engine.tick(now: startDate.addingTimeInterval(TimeInterval(last) * interval + interval))
        }
    }

    private func ingest(_ engine: inout SnorkelingSessionEngine, depth: Double, offset: TimeInterval) {
        let timestamp = startDate.addingTimeInterval(offset)
        engine.ingest(
            depthRaw: DepthMeasurementRaw(depthMeters: depth, sensorTimestamp: timestamp, receivedAt: timestamp),
            wallClock: timestamp
        )
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
