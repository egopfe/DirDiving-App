import XCTest

@MainActor
final class SnorkelingLogbookStoreTests: XCTestCase {
    private var storageURL: URL!

    override func setUp() async throws {
        storageURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: storageURL, withIntermediateDirectories: true)
        SnorkelingLogbookStore.testHook_storageDirectoryURL = storageURL
    }

    override func tearDown() async throws {
        SnorkelingLogbookStore.testHook_storageDirectoryURL = nil
        try? FileManager.default.removeItem(at: storageURL)
    }

    func testEmptyStoreStartsEmpty() {
        XCTAssertTrue(SnorkelingLogbookStore().sessions.isEmpty)
    }

    func testCRUDRoundTrip() {
        let store = SnorkelingLogbookStore()
        let session = makeSession(dipCount: 2, maxDepth: 8.4)
        store.add(session)
        XCTAssertEqual(store.sessions.count, 1)
        XCTAssertEqual(store.lastSavedSessionID, session.id)

        var updated = session
        updated.statistics = updated.refreshedStatistics()
        store.update(updated)
        XCTAssertEqual(store.sessions.first?.statistics.dipCount, 2)

        store.delete(id: session.id)
        XCTAssertTrue(store.sessions.isEmpty)
    }

    func testDeleteUnknownSessionIsNoOp() {
        let store = SnorkelingLogbookStore()
        store.add(makeSession(dipCount: 1, maxDepth: 5))
        store.delete(id: UUID())
        XCTAssertEqual(store.sessions.count, 1)
    }

    func testReloadFromPersistence() {
        let store = SnorkelingLogbookStore()
        store.add(makeSession(dipCount: 1, maxDepth: 6))
        store.reloadFromPersistence()
        XCTAssertEqual(store.sessions.count, 1)
    }

    func testDeterministicOrderingByCreatedAt() {
        let store = SnorkelingLogbookStore()
        let older = makeSession(dipCount: 1, maxDepth: 4, createdAt: Date(timeIntervalSince1970: 100))
        let newer = makeSession(dipCount: 1, maxDepth: 5, createdAt: Date(timeIntervalSince1970: 200))
        store.add(older)
        store.add(newer)
        XCTAssertEqual(store.sessions.first?.id, newer.id)
    }

    func testMergePrefersRicherDuplicateSession() {
        let store = SnorkelingLogbookStore()
        let id = UUID()
        let sparse = makeSession(id: id, dipCount: 1, maxDepth: 6, includeSamples: false)
        let rich = makeSession(id: id, dipCount: 2, maxDepth: 12, includeSamples: true)
        store.add(sparse)
        store.add(rich)
        XCTAssertEqual(store.sessions.count, 1)
        XCTAssertEqual(store.sessions.first?.dips.count, 2)
        XCTAssertFalse(store.sessions.first?.dips.first?.samples.isEmpty ?? true)
    }

    func testRetentionCapsAtEightySessions() {
        let store = SnorkelingLogbookStore()
        for index in 0..<90 {
            store.add(makeSession(
                dipCount: 1,
                maxDepth: Double(index),
                createdAt: Date(timeIntervalSince1970: TimeInterval(index))
            ))
        }
        XCTAssertEqual(store.sessions.count, SnorkelingLogbookPolicy.maxSessions)
        XCTAssertEqual(store.sessions.first?.statistics.sessionMaxDepthMeters ?? 0, 89, accuracy: 0.01)
    }

    func testEightyFirstSessionEvictsOldest() {
        let store = SnorkelingLogbookStore()
        for index in 0..<81 {
            store.add(makeSession(
                dipCount: 1,
                maxDepth: Double(index),
                createdAt: Date(timeIntervalSince1970: TimeInterval(index))
            ))
        }
        XCTAssertEqual(store.sessions.count, 80)
        XCTAssertFalse(store.sessions.contains { $0.statistics.sessionMaxDepthMeters == 0 })
    }

    func testCorruptFileIsQuarantinedOnLoad() throws {
        let fileURL = storageURL.appendingPathComponent("dirdiving_snorkeling_sessions.json")
        try Data("{not-json".utf8).write(to: fileURL)
        let store = SnorkelingLogbookStore()
        XCTAssertTrue(store.sessions.isEmpty)
        XCTAssertNotNil(store.loadErrorMessage)
        let quarantine = storageURL.appendingPathComponent("Diagnostics/SnorkelingQuarantine", isDirectory: true)
        let quarantined = try FileManager.default.contentsOfDirectory(at: quarantine, includingPropertiesForKeys: nil)
        XCTAssertFalse(quarantined.isEmpty)
    }

    func testChecksumMismatchRejected() throws {
        let sessions = [makeSession(dipCount: 1, maxDepth: 5)]
        var envelope = try SnorkelingLogbookPersistence.makeEnvelope(sessions: sessions)
        envelope.checksum = "deadbeef"
        let data = try JSONEncoder().encode(envelope)
        XCTAssertThrowsError(try SnorkelingLogbookPersistence.decodeSessionsResiliently(from: data))
    }

    func testExportEnvelopeRoundTrip() throws {
        let store = SnorkelingLogbookStore()
        store.add(makeSession(dipCount: 3, maxDepth: 11))
        let exported = try store.exportData()
        let envelope = try JSONDecoder().decode(SnorkelingLogbookFileEnvelope.self, from: exported)
        let decoded = try SnorkelingLogbookPersistence.sessions(from: envelope)
        XCTAssertEqual(decoded.count, 1)
        XCTAssertEqual(decoded.first?.statistics.dipCount, 3)
    }

    func testIncompleteSessionRejected() {
        let store = SnorkelingLogbookStore()
        var session = SnorkelingSession(startMode: .watch, state: .active, createdAt: Date())
        session.statistics = session.refreshedStatistics()
        store.add(session)
        XCTAssertTrue(store.sessions.isEmpty)
        XCTAssertEqual(store.loadErrorMessage, "incomplete_session")
    }

    func testKnownAggregateStatistics() {
        let sessions = [
            makeSession(dipCount: 2, maxDepth: 12, duration: 60),
            makeSession(dipCount: 4, maxDepth: 15.5, duration: 90),
        ]
        let stats = SnorkelingLogbookStatistics.aggregate(from: sessions)
        XCTAssertEqual(stats.sessionCount, 2)
        XCTAssertEqual(stats.totalDipCount, 6)
        XCTAssertEqual(stats.bestSessionMaxDepthMeters, 15.5, accuracy: 0.01)
    }

    func testStatisticsIgnoreInvalidSessions() {
        var invalid = SnorkelingSession(startMode: .watch, state: .completed, createdAt: Date())
        invalid.statistics = SnorkelingSessionStatistics(
            dipCount: 1,
            totalDipSeconds: 10,
            sessionMaxDepthMeters: .nan,
            totalDistanceMeters: 0,
            averageSpeedMetersPerSecond: 0,
            markerCount: 0,
            eventCount: 0,
            sessionDurationSeconds: 10
        )
        let stats = SnorkelingLogbookStatistics.aggregate(from: [invalid])
        XCTAssertEqual(stats.sessionCount, 0)
    }

    func testStoreStatisticsAPI() {
        let store = SnorkelingLogbookStore()
        store.add(makeSession(dipCount: 2, maxDepth: 9))
        let stats = store.statistics()
        XCTAssertEqual(stats.sessionCount, 1)
        XCTAssertEqual(stats.totalDipCount, 2)
    }

    func testLogbookNamespaceIsolated() {
        XCTAssertEqual(SnorkelingLogbookFileEnvelope.namespace, "dirdiving_snorkeling_sessions")
        XCTAssertNotEqual(SnorkelingLogbookFileEnvelope.namespace, "dirdiving_apnea_sessions")
    }

    // MARK: - Helpers

    private func makeSession(
        id: UUID = UUID(),
        dipCount: Int,
        maxDepth: Double,
        duration: TimeInterval = 45,
        createdAt: Date = Date(timeIntervalSince1970: 1_700_000_000),
        includeSamples: Bool = true
    ) -> SnorkelingSession {
        var dips: [SnorkelingDip] = []
        for index in 0..<dipCount {
            let sample = SnorkelingDipSample(
                monotonicRelativeTimestampSeconds: TimeInterval(index * 30),
                wallClockTimestamp: createdAt.addingTimeInterval(TimeInterval(index * 30)),
                depthMeters: maxDepth - Double(index) * 0.2,
                temperatureCelsius: 22
            )
            dips.append(
                SnorkelingDip(
                    startedAtMonotonicSeconds: TimeInterval(index * 60),
                    endedAtMonotonicSeconds: TimeInterval(index * 60 + Int(duration)),
                    startedAtWallClock: createdAt,
                    endedAtWallClock: createdAt.addingTimeInterval(duration),
                    durationSeconds: duration,
                    maxDepthMeters: maxDepth,
                    averageDepthMeters: maxDepth * 0.7,
                    samples: includeSamples ? [sample] : [],
                    events: []
                )
            )
        }
        var session = SnorkelingSession(
            id: id,
            startMode: .watch,
            state: .completed,
            createdAt: createdAt,
            dips: dips
        )
        session.statistics = session.refreshedStatistics()
        return session
    }
}
