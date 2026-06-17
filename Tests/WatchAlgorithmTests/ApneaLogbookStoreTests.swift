import XCTest

@MainActor
final class ApneaLogbookStoreTests: XCTestCase {
    private var storageURL: URL!

    override func setUp() async throws {
        storageURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: storageURL, withIntermediateDirectories: true)
        ApneaLogbookStore.testHook_storageDirectoryURL = storageURL
    }

    override func tearDown() async throws {
        ApneaLogbookStore.testHook_storageDirectoryURL = nil
        try? FileManager.default.removeItem(at: storageURL)
    }

    func testCRUDRoundTrip() {
        let store = ApneaLogbookStore()
        let session = makeSession(diveCount: 3, maxDepth: 21.5)
        store.add(session)
        XCTAssertEqual(store.sessions.count, 1)
        XCTAssertEqual(store.sessions.first?.statistics.diveCount, 3)
        XCTAssertEqual(store.lastSavedSessionID, session.id)

        store.delete(id: session.id)
        XCTAssertTrue(store.sessions.isEmpty)
    }

    func testMergePrefersRicherDuplicateSession() {
        let store = ApneaLogbookStore()
        let id = UUID()
        let sparse = makeSession(id: id, diveCount: 1, maxDepth: 10, includeSamples: false)
        let rich = makeSession(id: id, diveCount: 2, maxDepth: 18, includeSamples: true)
        store.add(sparse)
        store.add(rich)
        XCTAssertEqual(store.sessions.count, 1)
        XCTAssertEqual(store.sessions.first?.dives.count, 2)
        XCTAssertFalse(store.sessions.first?.dives.first?.samples.isEmpty ?? true)
    }

    func testRetentionCapsSessionCount() {
        let store = ApneaLogbookStore()
        for index in 0..<90 {
            store.add(makeSession(diveCount: 1, maxDepth: Double(index), createdAt: Date(timeIntervalSince1970: TimeInterval(index))))
        }
        XCTAssertEqual(store.sessions.count, ApneaLogbookPolicy.maxSessions)
        XCTAssertEqual(store.sessions.first?.statistics.sessionMaxDepthMeters ?? 0, 89, accuracy: 0.01)
    }

    func testCorruptFileIsQuarantinedOnLoad() throws {
        let fileURL = storageURL.appendingPathComponent("dirdiving_apnea_sessions.json")
        try Data("{not-json".utf8).write(to: fileURL)
        let store = ApneaLogbookStore()
        XCTAssertTrue(store.sessions.isEmpty)
        XCTAssertNotNil(store.loadErrorMessage)
        let quarantine = storageURL.appendingPathComponent("Diagnostics/ApneaQuarantine", isDirectory: true)
        let quarantined = try FileManager.default.contentsOfDirectory(at: quarantine, includingPropertiesForKeys: nil)
        XCTAssertFalse(quarantined.isEmpty)
    }

    func testLargeSessionStatistics() {
        var dives: [ApneaDive] = []
        for index in 0..<100 {
            let event = ApneaEvent(kind: .diveEnd, monotonicRelativeTimestampSeconds: TimeInterval(index * 120 + 60))
            let dive = ApneaDive(
                startedAtMonotonicSeconds: TimeInterval(index * 120),
                durationSeconds: 60 + TimeInterval(index % 5),
                maxDepthMeters: 10 + Double(index % 15),
                averageDepthMeters: 8 + Double(index % 10),
                events: [event]
            )
            dives.append(dive)
        }
        var session = ApneaSession(startMode: .watch, state: .completed, dives: dives)
        session.statistics = session.refreshedStatistics()
        XCTAssertEqual(session.statistics.diveCount, 100)
        XCTAssertEqual(session.statistics.eventCount, 100)
        XCTAssertGreaterThan(session.statistics.cumulativeDepthMeters, 0)

        let aggregate = ApneaLogbookStatistics.aggregate(from: [session])
        XCTAssertEqual(aggregate.totalDiveCount, 100)
        XCTAssertEqual(aggregate.bestDiveDurationSeconds, 64, accuracy: 0.1)
    }

    func testKnownAggregateStatistics() {
        let sessions = [
            makeSession(diveCount: 2, maxDepth: 20, duration: 60),
            makeSession(diveCount: 4, maxDepth: 24.7, duration: 88),
        ]
        let stats = ApneaLogbookStatistics.aggregate(from: sessions)
        XCTAssertEqual(stats.sessionCount, 2)
        XCTAssertEqual(stats.totalDiveCount, 6)
        XCTAssertEqual(stats.bestSessionMaxDepthMeters, 24.7, accuracy: 0.01)
        XCTAssertEqual(stats.mostDivesInSession, 4)
    }

    func testExportEnvelopeRoundTrip() throws {
        let store = ApneaLogbookStore()
        store.add(makeSession(diveCount: 5, maxDepth: 16))
        let exported = try store.exportData()
        let envelope = try JSONDecoder().decode(ApneaLogbookFileEnvelope.self, from: exported)
        let decoded = try ApneaLogbookPersistence.sessions(from: envelope)
        XCTAssertEqual(decoded.count, 1)
        XCTAssertEqual(decoded.first?.statistics.diveCount, 5)
    }

    func testLegacyStatisticsFieldsMigrateOnDecode() throws {
        let sessionID = UUID()
        let json = """
        {
          "id": "\(sessionID.uuidString)",
          "schemaVersion": 1,
          "startMode": "watch",
          "state": "completed",
          "createdAt": 1718539200000,
          "dives": [{
            "id": "\(UUID().uuidString)",
            "startedAtMonotonicSeconds": 0,
            "durationSeconds": 62,
            "maxDepthMeters": 18.4,
            "averageDepthMeters": 10,
            "samples": [],
            "events": [],
            "targets": [],
            "markers": [],
            "reachedTargetIDs": [],
            "reachedMarkerIDs": []
          }],
          "statistics": {
            "diveCount": 1,
            "totalUnderwaterSeconds": 62,
            "sessionMaxDepthMeters": 18.4,
            "averageDiveDurationSeconds": 62,
            "totalRecoverySeconds": 62
          },
          "surfaceGPSPoints": [],
          "warnings": []
        }
        """
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        let session = try decoder.decode(ApneaSession.self, from: Data(json.utf8))
        let refreshed = session.refreshedStatistics()
        XCTAssertEqual(refreshed.bestDiveDurationSeconds, 62)
        XCTAssertGreaterThan(refreshed.cumulativeDepthMeters, 0)
    }

    func testExplorationBridgeCreatesCompletedSession() {
        let snapshot = ApneaExplorationSessionSnapshot(
            dives: [
                ApneaLegacyDiveSnapshot(id: UUID(), durationSeconds: 62, maxDepthMeters: 18.4, recoverySeconds: 124)
            ],
            dataQualityDegraded: true,
            sessionWarnings: []
        )
        let session = ApneaExplorationSessionBridge.makeCompletedSession(from: snapshot)
        XCTAssertEqual(session.state, .completed)
        XCTAssertEqual(session.dives.count, 1)
        XCTAssertTrue(session.warnings.contains(.dataQualityDegraded))
        XCTAssertEqual(session.statistics.bestDiveDurationSeconds, 62)
    }

    func testStatisticsRangeFilter() {
        let old = makeSession(diveCount: 1, maxDepth: 10, createdAt: Date(timeIntervalSince1970: 1_700_000_000))
        let recent = makeSession(diveCount: 2, maxDepth: 22, createdAt: Date())
        let stats = ApneaLogbookStatistics.aggregate(
            from: [old, recent],
            range: .last7Days,
            referenceDate: Date()
        )
        XCTAssertEqual(stats.sessionCount, 1)
        XCTAssertEqual(stats.bestSessionMaxDepthMeters, 22, accuracy: 0.01)
    }

    private func makeSession(
        id: UUID = UUID(),
        diveCount: Int,
        maxDepth: Double,
        duration: TimeInterval = 60,
        includeSamples: Bool = true,
        createdAt: Date = Date()
    ) -> ApneaSession {
        let dives = (0..<diveCount).map { index in
            let samples: [ApneaSample]
            if includeSamples {
                samples = [
                    ApneaSample(monotonicRelativeTimestampSeconds: 0, depthMeters: 0),
                    ApneaSample(monotonicRelativeTimestampSeconds: 30, depthMeters: maxDepth),
                ]
            } else {
                samples = []
            }
            return ApneaDive(
                startedAtMonotonicSeconds: TimeInterval(index * 200),
                durationSeconds: duration,
                maxDepthMeters: maxDepth,
                averageDepthMeters: maxDepth * 0.6,
                samples: samples,
                events: [ApneaEvent(kind: .diveEnd, monotonicRelativeTimestampSeconds: duration)]
            )
        }
        var session = ApneaSession(
            id: id,
            startMode: .watch,
            state: .completed,
            createdAt: createdAt,
            dives: dives
        )
        session.statistics = session.refreshedStatistics()
        return session
    }
}
