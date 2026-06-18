import XCTest

final class ApneaCheckpointFailureInjectionTests: XCTestCase {
    private let startDate = Date(timeIntervalSince1970: 1_700_000_000)

    func testCorruptChecksumRejectedOnRead() throws {
        let envelope = try makeEnvelope()
        let url = temporaryCheckpointURL()
        defer { try? FileManager.default.removeItem(at: url) }

        var corrupted = envelope
        corrupted.checksum = "deadbeef"
        try Data(JSONEncoder().encode(corrupted)).write(to: url, options: .atomic)
        XCTAssertThrowsError(try ApneaSessionCheckpointStore.read(from: url))
    }

    func testTruncatedCheckpointRejected() throws {
        let envelope = try makeEnvelope()
        let url = temporaryCheckpointURL()
        defer { try? FileManager.default.removeItem(at: url) }

        let data = try JSONEncoder().encode(envelope)
        try data.prefix(data.count / 2).write(to: url, options: .atomic)
        XCTAssertThrowsError(try ApneaSessionCheckpointStore.read(from: url))
    }

    func testMalformedJSONRejected() throws {
        let url = temporaryCheckpointURL()
        defer { try? FileManager.default.removeItem(at: url) }
        try Data("not-json".utf8).write(to: url, options: .atomic)
        XCTAssertThrowsError(try ApneaSessionCheckpointStore.read(from: url))
    }

    func testUnsupportedSchemaDecodedButPreservesSessionID() throws {
        var envelope = try makeEnvelope()
        var payload = try ApneaSessionCheckpointIntegrity.payload(from: envelope)
        payload.schemaVersion = 99
        envelope = try ApneaSessionCheckpointIntegrity.makeEnvelope(payload: payload)
        let restored = try ApneaSessionEngine(checkpoint: envelope)
        XCTAssertEqual(restored.snapshot.session.id, payload.sessionID)
    }

    func testAtomicWriteLeavesValidCheckpointOnDisk() throws {
        let envelope = try makeEnvelope()
        let url = temporaryCheckpointURL()
        defer { try? FileManager.default.removeItem(at: url) }

        try ApneaSessionCheckpointStore.write(envelope, to: url)
        let loaded = try ApneaSessionCheckpointStore.read(from: url)
        XCTAssertEqual(
            try ApneaSessionCheckpointIntegrity.payload(from: loaded).sessionID,
            try ApneaSessionCheckpointIntegrity.payload(from: envelope).sessionID
        )
        XCTAssertFalse(FileManager.default.fileExists(atPath: url.path + ".tmp"))
    }

    func testRepeatedRestoreIsDeterministic() throws {
        let envelope = try makeEnvelope()
        let first = try ApneaSessionEngine(checkpoint: envelope)
        let second = try ApneaSessionEngine(checkpoint: envelope)
        XCTAssertEqual(first.snapshot.session.id, second.snapshot.session.id)
        XCTAssertEqual(first.snapshot.rawSampleCount, second.snapshot.rawSampleCount)
        XCTAssertEqual(first.snapshot.phase, second.snapshot.phase)
    }

    func testRestoreDoesNotFabricateDemoSamples() throws {
        let envelope = try makeEnvelope()
        let restored = try ApneaSessionEngine(checkpoint: envelope)
        XCTAssertGreaterThan(restored.snapshot.rawSampleCount, 0)
        XCTAssertTrue(restored.snapshot.session.dives.isEmpty)
    }

    func testRestoreDoesNotDuplicateCommittedDive() throws {
        var engine = makeEngine()
        engine.armSession(at: startDate)
        replay(&engine)
        keepSurface(&engine, from: 12, count: 5)
        XCTAssertEqual(engine.snapshot.session.dives.count, 1)

        let envelope = try engine.exportCheckpoint(now: startDate.addingTimeInterval(20))
        let restored = try ApneaSessionEngine(checkpoint: envelope)
        XCTAssertEqual(restored.snapshot.session.dives.count, 1)
    }

    func testStaleCheckpointStillRestoresConservatively() throws {
        var engine = makeEngine()
        engine.armSession(at: startDate)
        ingest(&engine, depth: 0, offset: 0)
        let envelope = try engine.exportCheckpoint(now: startDate.addingTimeInterval(1))
        var restored = try ApneaSessionEngine(checkpoint: envelope)
        ingest(&restored, depth: 0, offset: 3600)
        XCTAssertEqual(restored.snapshot.session.id, engine.snapshot.session.id)
    }

    func testNonFinitePersistedDepthCannotEncodeCheckpoint() throws {
        var envelope = try makeEnvelope()
        var payload = try ApneaSessionCheckpointIntegrity.payload(from: envelope)
        payload.rawSamples.append(
            ApneaSample(monotonicRelativeTimestampSeconds: 1, depthMeters: .nan, verticalSpeedMetersPerSecond: 0)
        )
        XCTAssertThrowsError(try ApneaSessionCheckpointIntegrity.makeEnvelope(payload: payload))
    }

    // MARK: - Helpers

    private func makeEngine() -> ApneaSessionEngine {
        var config = ApneaLifecycleConfiguration.default
        config.immersionDebounceSeconds = 1
        config.surfaceStableDwellSeconds = 3
        config.minimumDiveDurationSeconds = 1
        return ApneaSessionEngine(configuration: config, sessionStart: startDate)
    }

    private func makeEnvelope() throws -> ApneaSessionCheckpointEnvelope {
        var engine = makeEngine()
        engine.armSession(at: startDate)
        ingest(&engine, depth: 0, offset: 0)
        ingest(&engine, depth: 3, offset: 1)
        return try engine.exportCheckpoint(now: startDate.addingTimeInterval(2))
    }

    private func temporaryCheckpointURL() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("apnea-failure-injection-\(UUID().uuidString).json")
    }

    private func ingest(_ engine: inout ApneaSessionEngine, depth: Double, offset: TimeInterval) {
        let timestamp = startDate.addingTimeInterval(offset)
        _ = engine.ingest(
            raw: DepthMeasurementRaw(depthMeters: depth, sensorTimestamp: timestamp, receivedAt: timestamp),
            wallClock: timestamp
        )
    }

    private func replay(_ engine: inout ApneaSessionEngine) {
        let depths: [Double] = [0, 0, 2, 5, 8, 5, 2, 0, 0, 0, 0]
        var offset: TimeInterval = 0
        for depth in depths {
            ingest(&engine, depth: depth, offset: offset)
            offset += 1
        }
    }

    private func keepSurface(_ engine: inout ApneaSessionEngine, from start: TimeInterval, count: Int) {
        for i in 0...count {
            ingest(&engine, depth: 0, offset: start + TimeInterval(i))
        }
    }
}
