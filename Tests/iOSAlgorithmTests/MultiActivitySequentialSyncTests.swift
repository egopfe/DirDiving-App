import XCTest

@MainActor
final class MultiActivitySequentialSyncTests: XCTestCase {
    func testSequentialImportsRemainActivityIsolated() throws {
        WatchSyncTestSupport.installDeterministicSecrets()
        defer { WatchSyncTestSupport.resetSecrets() }

        WatchDiveSyncCodec.resetTestHooks()
        ApneaSessionSyncCodec.resetTestHooks()
        SnorkelingSessionSyncCodec.resetTestHooks()
        WatchDiveSyncCodec.testHook_bypassConnectivityChecks = true
        ApneaSessionSyncCodec.testHook_bypassConnectivityChecks = true
        SnorkelingSessionSyncCodec.testHook_bypassConnectivityChecks = true

        let base = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)
        IOSApneaLogbookStore.testHook_storageDirectoryURL = base.appendingPathComponent("apnea")
        IOSSnorkelingLogbookStore.testHook_storageDirectoryURL = base.appendingPathComponent("snorkeling")
        try FileManager.default.createDirectory(at: IOSApneaLogbookStore.testHook_storageDirectoryURL!, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: IOSSnorkelingLogbookStore.testHook_storageDirectoryURL!, withIntermediateDirectories: true)
        defer {
            IOSApneaLogbookStore.testHook_storageDirectoryURL = nil
            IOSSnorkelingLogbookStore.testHook_storageDirectoryURL = nil
            try? FileManager.default.removeItem(at: base)
        }

        let apneaStore = IOSApneaLogbookStore()
        let snorkelStore = IOSSnorkelingLogbookStore()
        apneaStore.resetImportedIDsForTesting()
        snorkelStore.resetImportedIDsForTesting()

        let diveParsed = try WatchDiveSyncCodec.makeTestWatchTransport(session: makeDiveSession())
        _ = try WatchDiveSyncCodec.parsePayload(from: diveParsed)

        let apneaParsed = try ApneaSessionSyncCodec.makeTestWatchTransport(session: makeApneaSession())
        XCTAssertEqual(apneaStore.mergeImportedSession(try ApneaSessionSyncCodec.parsePayload(from: apneaParsed).session), .imported)

        let snorkelParsed = try SnorkelingSessionSyncCodec.makeTestWatchTransport(session: makeSnorkelingSession())
        XCTAssertEqual(snorkelStore.mergeImportedSession(try SnorkelingSessionSyncCodec.parsePayload(from: snorkelParsed).session), .imported)

        XCTAssertEqual(apneaStore.sessions.count, 1)
        XCTAssertEqual(snorkelStore.sessions.count, 1)
    }

    private func makeDiveSession() -> DiveSession {
        let start = Date(timeIntervalSince1970: 1_000)
        let end = start.addingTimeInterval(60)
        let samples = [
            DiveSample(timestamp: start, depthMeters: 0, temperatureCelsius: 20),
            DiveSample(timestamp: end, depthMeters: 10, temperatureCelsius: 20),
        ]
        let summary = DiveProfileMath.summary(samples: samples, startDate: start, endDate: end)
        return DiveSession(
            id: UUID(),
            startDate: start,
            endDate: end,
            durationSeconds: summary.durationSeconds,
            maxDepthMeters: summary.maxDepthMeters,
            avgDepthMeters: summary.averageDepthMeters,
            avgWaterTemperatureCelsius: summary.averageTemperatureCelsius,
            ttv: summary.ttv,
            entryGPS: nil,
            exitGPS: nil,
            samples: samples
        )
    }

    private func makeApneaSession() -> ApneaSession {
        var session = ApneaSession(
            startMode: .watch,
            state: .completed,
            dives: [ApneaDive(startedAtMonotonicSeconds: 0, durationSeconds: 60, maxDepthMeters: 12, averageDepthMeters: 8)]
        )
        session.statistics = session.refreshedStatistics()
        return session
    }

    private func makeSnorkelingSession() -> SnorkelingSession {
        var session = SnorkelingSession(
            id: UUID(),
            startMode: .watch,
            state: .completed,
            dips: [SnorkelingDip(startedAtMonotonicSeconds: 0, durationSeconds: 60, maxDepthMeters: 4, averageDepthMeters: 3)]
        )
        session.statistics = session.refreshedStatistics()
        return session
    }
}
