import XCTest

@MainActor
final class ApneaWatchGPSCaptureTests: XCTestCase {
    func testAppendSurfaceGPSPointStoresMetadata() {
        var engine = ApneaSessionEngine()
        engine.armSession()
        engine.appendSurfaceGPSPoint(
            ApneaSurfaceGPSPoint(latitude: 44.5, longitude: 8.95, horizontalAccuracyMeters: 7, capturedAt: Date())
        )
        XCTAssertEqual(engine.snapshot.session.surfaceGPSPoints.count, 1)
    }

    func testSaveWithoutGPSAddsWarning() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        ApneaLogbookStore.testHook_storageDirectoryURL = directory
        defer {
            ApneaLogbookStore.testHook_storageDirectoryURL = nil
            try? FileManager.default.removeItem(at: directory)
        }

        let logbook = ApneaLogbookStore()
        let store = ApneaWatchRuntimeStore()
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        var engine = ApneaSessionEngine(sessionStart: start)
        engine.armSession(at: start)
        engine.replayProfile(
            depths: [0, 0, 2, 6, 8, 4, 0, 0, 0, 0],
            intervalSeconds: 1,
            startDate: start.addingTimeInterval(1)
        )
        engine.tick(now: start.addingTimeInterval(12))
        engine.endSession(at: start.addingTimeInterval(12))
        store.replaceEngineForTesting(engine)
        store.saveCompletedSession(to: logbook)
        let saved = logbook.sessions.first
        XCTAssertNotNil(saved)
        XCTAssertTrue(saved?.warnings.contains(.gpsUnavailable) == true)
        XCTAssertTrue(saved?.surfaceGPSPoints.isEmpty == true)
    }

    func testEmptySurfaceGPSPointsRemainValid() {
        var session = ApneaSession(
            startMode: .watch,
            state: .completed,
            dives: [ApneaDive(startedAtMonotonicSeconds: 0, durationSeconds: 60, maxDepthMeters: 12, averageDepthMeters: 8)]
        )
        session.statistics = session.refreshedStatistics()
        XCTAssertTrue(ActivityGPSLogbookPolicy.apneaSessionRemainsValidWithoutGPS(session))
    }
}
