import XCTest

@MainActor
final class SnorkelingPersistenceRecoveryTests: XCTestCase {
    private let startDate = Date(timeIntervalSince1970: 1_700_000_000)

    func testCorruptChecksumRejectedOnRead() throws {
        let envelope = try makeEnvelope()
        let url = temporaryCheckpointURL()
        defer { cleanup(url) }

        var corrupted = envelope
        corrupted.checksum = "deadbeef"
        try Data(JSONEncoder().encode(corrupted)).write(to: url, options: .atomic)
        XCTAssertThrowsError(try SnorkelingSessionCheckpointStore.read(from: url))
    }

    func testAtomicWritePreservesPreviousCheckpoint() throws {
        let first = try makeEnvelope(sessionID: UUID())
        let second = try makeEnvelope(sessionID: UUID())
        let url = temporaryCheckpointURL()
        let previousURL = url.deletingLastPathComponent()
            .appendingPathComponent(SnorkelingSessionCheckpointStore.previousCheckpointFileName)
        defer { cleanup(url); try? FileManager.default.removeItem(at: previousURL) }

        try SnorkelingSessionCheckpointStore.write(first, to: url)
        try SnorkelingSessionCheckpointStore.write(second, to: url)
        XCTAssertTrue(FileManager.default.fileExists(atPath: previousURL.path))
        let restored = try SnorkelingSessionCheckpointStore.readWithPreviousFallback(currentURL: url, previousURL: previousURL)
        XCTAssertEqual(
            try SnorkelingSessionCheckpointIntegrity.payload(from: restored).checkpoint.session.id,
            try SnorkelingSessionCheckpointIntegrity.payload(from: second).checkpoint.session.id
        )
    }

    func testPreviousCheckpointFallbackWhenCurrentCorrupt() throws {
        let valid = try makeEnvelope()
        let url = temporaryCheckpointURL()
        let previousURL = url.deletingLastPathComponent()
            .appendingPathComponent(SnorkelingSessionCheckpointStore.previousCheckpointFileName)
        defer { cleanup(url); try? FileManager.default.removeItem(at: previousURL) }

        try Data(JSONEncoder().encode(valid)).write(to: previousURL, options: .atomic)
        try Data("not-json".utf8).write(to: url, options: .atomic)
        let restored = try SnorkelingSessionCheckpointStore.readWithPreviousFallback(currentURL: url, previousURL: previousURL)
        XCTAssertEqual(
            try SnorkelingSessionCheckpointIntegrity.payload(from: restored).checkpoint.session.id,
            try SnorkelingSessionCheckpointIntegrity.payload(from: valid).checkpoint.session.id
        )
    }

    func testCrashDuringDipPreservesActiveDip() throws {
        var engine = makeEngine()
        engine.armSession(at: startDate)
        engine.startSession(at: startDate)
        ingest(&engine, depth: 0.2, offset: 0)
        ingest(&engine, depth: 1.2, offset: 2)
        ingest(&engine, depth: 1.4, offset: 4)
        let envelope = try engine.exportCheckpointEnvelope(
            runtime: SnorkelingCheckpointRuntimeState(sessionArmed: true, sessionStarted: true, missionModeEnabled: false, hapticsEnabled: true)
        )
        let restored = try SnorkelingSessionEngine.restoreState(from: envelope)
        XCTAssertEqual(restored.engine.snapshot.phase, .dipping)
        XCTAssertGreaterThan(restored.engine.snapshot.activeDipSampleCount, 0)
    }

    func testCrashDuringNavigationPreservesRouteState() throws {
        var engine = makeEngine()
        engine.armSession(at: startDate)
        engine.startSession(at: startDate)
        ingest(&engine, depth: 0.2, offset: 0, gps: gps(offset: 0))
        engine.enterNavigation()
        ingest(&engine, depth: 0.2, offset: 2, gps: gps(offset: 2, lat: 44.4002))
        let envelope = try engine.exportCheckpointEnvelope(
            runtime: SnorkelingCheckpointRuntimeState(sessionArmed: true, sessionStarted: true, missionModeEnabled: false, hapticsEnabled: true)
        )
        let restored = try SnorkelingSessionEngine.restoreState(from: envelope)
        XCTAssertEqual(restored.engine.snapshot.phase, .navigation)
        var restoredEngine = restored.engine
        XCTAssertNotNil(restoredEngine.exportCheckpoint().navigationRuntimeState)
    }

    func testCrashDuringReturnPreservesEntryPoint() throws {
        var engine = makeEngine()
        engine.armSession(at: startDate)
        engine.startSession(at: startDate)
        ingest(&engine, depth: 0.2, offset: 0, gps: gps(offset: 0))
        ingest(&engine, depth: 0.2, offset: 3, gps: gps(offset: 3, lat: 44.4002))
        engine.enterReturnMode()
        let envelope = try engine.exportCheckpointEnvelope(
            runtime: SnorkelingCheckpointRuntimeState(sessionArmed: true, sessionStarted: true, missionModeEnabled: false, hapticsEnabled: true)
        )
        let restored = try SnorkelingSessionEngine.restoreState(from: envelope)
        XCTAssertEqual(restored.engine.snapshot.phase, .returnMode)
        XCTAssertNotNil(restored.engine.snapshot.returnNavigation.entryPoint ?? restored.engine.snapshot.session.entryPoint)
    }

    func testCrashAfterMarkerPreservesMarkers() throws {
        var engine = makeEngine()
        engine.armSession(at: startDate)
        engine.startSession(at: startDate)
        ingest(&engine, depth: 0.2, offset: 0, gps: gps(offset: 0))
        _ = engine.saveMarker(
            request: SnorkelingMarkerCaptureRequest(category: .reef, allowSaveWithoutCoordinates: true),
            at: startDate.addingTimeInterval(1)
        )
        let envelope = try engine.exportCheckpointEnvelope(
            runtime: SnorkelingCheckpointRuntimeState(sessionArmed: true, sessionStarted: true, missionModeEnabled: false, hapticsEnabled: true)
        )
        let restored = try SnorkelingSessionEngine.restoreState(from: envelope)
        XCTAssertEqual(restored.engine.snapshot.session.markers.count, 1)
    }

    func testFutureEnvelopeSchemaTolerated() throws {
        var envelope = try makeEnvelope()
        var payload = try SnorkelingSessionCheckpointIntegrity.payload(from: envelope)
        payload.envelopeSchemaVersion = 99
        envelope = try SnorkelingSessionCheckpointIntegrity.makeEnvelope(payload: payload)
        let restored = try SnorkelingSessionEngine.restoreState(from: envelope)
        XCTAssertEqual(restored.engine.snapshot.session.id, payload.checkpoint.session.id)
    }

    func testLargeSessionStatisticsPreserved() throws {
        var engine = makeEngine()
        engine.armSession(at: startDate)
        engine.startSession(at: startDate)
        replay(
            &engine,
            depths: [0.2, 0.8, 1.4, 0.2, 0.1, 0.2, 0.9, 1.3, 0.2, 0.1, 0.2, 0.8, 1.2, 0.2, 0.1],
            interval: 3,
            includeGPS: true
        )
        ingest(&engine, depth: 0.1, offset: 48, gps: gps(offset: 48))
        ingest(&engine, depth: 0.1, offset: 51, gps: gps(offset: 51))
        engine.endSession(at: startDate.addingTimeInterval(52))
        XCTAssertGreaterThan(engine.snapshot.dipCount, 0)
        let envelope = try engine.exportCheckpointEnvelope(
            runtime: SnorkelingCheckpointRuntimeState(sessionArmed: true, sessionStarted: true, missionModeEnabled: false, hapticsEnabled: true)
        )
        let restored = try SnorkelingSessionEngine.restoreState(from: envelope)
        let stats = restored.engine.snapshot.session.refreshedStatistics()
        XCTAssertGreaterThan(stats.dipCount, 0)
        XCTAssertGreaterThan(stats.totalDistanceMeters, 0)
    }

    func testLogbookRetentionCapsSessions() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        SnorkelingLogbookStore.testHook_storageDirectoryURL = directory
        defer { SnorkelingLogbookStore.testHook_storageDirectoryURL = nil }

        let store = SnorkelingLogbookStore()
        for index in 0..<90 {
            var session = SnorkelingSession(startMode: .watch, state: .completed, createdAt: startDate.addingTimeInterval(TimeInterval(index)))
            session.statistics = session.refreshedStatistics()
            store.add(session)
        }
        XCTAssertLessThanOrEqual(store.sessions.count, SnorkelingLogbookPolicy.maxSessions)
    }

    func testCorruptLogbookQuarantinedWithoutCrash() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appendingPathComponent("dirdiving_snorkeling_sessions.json")
        try Data("not-json".utf8).write(to: url)
        SnorkelingLogbookStore.testHook_storageDirectoryURL = directory
        defer { SnorkelingLogbookStore.testHook_storageDirectoryURL = nil }

        let store = SnorkelingLogbookStore()
        XCTAssertTrue(store.sessions.isEmpty)
        XCTAssertNotNil(store.loadErrorMessage)
    }

    // MARK: - Helpers

    private func makeEnvelope(sessionID: UUID = UUID()) throws -> SnorkelingSessionCheckpointEnvelope {
        var engine = SnorkelingSessionEngine(configuration: .default, sessionStart: startDate)
        engine.armSession(at: startDate)
        engine.startSession(at: startDate)
        ingest(&engine, depth: 0.8, offset: 1)
        var checkpoint = engine.exportCheckpoint(now: startDate.addingTimeInterval(2))
        let exported = checkpoint.session
        checkpoint.session = SnorkelingSession(
            id: sessionID,
            schemaVersion: exported.schemaVersion,
            startMode: exported.startMode,
            state: exported.state,
            createdAt: exported.createdAt,
            startedAtMonotonicSeconds: exported.startedAtMonotonicSeconds,
            endedAtMonotonicSeconds: exported.endedAtMonotonicSeconds,
            entryPoint: exported.entryPoint,
            trackPoints: exported.trackPoints,
            dips: exported.dips,
            markers: exported.markers,
            alarms: exported.alarms,
            events: exported.events,
            routePlans: exported.routePlans,
            activeRoutePlanID: exported.activeRoutePlanID,
            statistics: exported.statistics,
            profile: exported.profile,
            equipment: exported.equipment,
            buddy: exported.buddy,
            warnings: exported.warnings
        )
        let payload = SnorkelingSessionCheckpointPayload(
            checkpoint: checkpoint,
            runtime: SnorkelingCheckpointRuntimeState(sessionArmed: true, sessionStarted: true, missionModeEnabled: false, hapticsEnabled: true)
        )
        return try SnorkelingSessionCheckpointIntegrity.makeEnvelope(payload: payload)
    }

    private func makeEngine() -> SnorkelingSessionEngine {
        SnorkelingSessionEngine(configuration: .default, sessionStart: startDate)
    }

    private func replay(
        _ engine: inout SnorkelingSessionEngine,
        depths: [Double],
        interval: TimeInterval,
        includeGPS: Bool = false
    ) {
        for (index, depth) in depths.enumerated() {
            let offset = TimeInterval(index) * interval
            ingest(
                &engine,
                depth: depth,
                offset: offset,
                gps: includeGPS ? gps(offset: offset, lat: 44.4 + Double(index) * 0.0001) : nil
            )
        }
    }

    private func ingest(
        _ engine: inout SnorkelingSessionEngine,
        depth: Double,
        offset: TimeInterval,
        gps: SnorkelingGPSRawFix? = nil
    ) {
        let timestamp = startDate.addingTimeInterval(offset)
        engine.ingest(
            depthRaw: DepthMeasurementRaw(depthMeters: depth, sensorTimestamp: timestamp, receivedAt: timestamp),
            gpsRaw: gps,
            wallClock: timestamp
        )
    }

    private func gps(offset: TimeInterval, lat: Double = 44.40012) -> SnorkelingGPSRawFix {
        SnorkelingGPSRawFix(
            latitude: lat,
            longitude: 8.94012,
            horizontalAccuracyMeters: 8,
            sensorTimestamp: startDate.addingTimeInterval(offset),
            receivedAt: startDate.addingTimeInterval(offset),
            source: .replay
        )
    }

    private func temporaryCheckpointURL() -> URL {
        FileManager.default.temporaryDirectory.appendingPathComponent("snorkeling-checkpoint-\(UUID().uuidString).json")
    }

    private func cleanup(_ url: URL) {
        try? FileManager.default.removeItem(at: url)
        try? FileManager.default.removeItem(at: url.appendingPathExtension("tmp"))
    }
}
