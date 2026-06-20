import XCTest

@MainActor
final class ActivitySyncCrossDecodeRejectionTests: XCTestCase {
    private var replayCacheURL: URL!

    override func setUp() {
        super.setUp()
        WatchSyncAuth.resetPeerTrust()
        WatchDiveSyncCodec.resetTestHooks()
        ApneaSessionSyncCodec.resetTestHooks()
        SnorkelingSessionSyncCodec.resetTestHooks()
        replayCacheURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("cross-decode-\(UUID().uuidString).json")
        WatchDiveSyncCodec.testHook_bypassConnectivityChecks = true
        ApneaSessionSyncCodec.testHook_bypassConnectivityChecks = true
        SnorkelingSessionSyncCodec.testHook_bypassConnectivityChecks = true
        ApneaSessionSyncCodec.testHook_replayCacheFileURL = replayCacheURL
        SnorkelingSessionSyncCodec.testHook_replayCacheFileURL = replayCacheURL
        WatchSyncTestSupport.installDeterministicSecrets()
    }

    override func tearDown() {
        WatchDiveSyncCodec.resetTestHooks()
        ApneaSessionSyncCodec.resetTestHooks()
        SnorkelingSessionSyncCodec.resetTestHooks()
        WatchSyncTestSupport.resetSecrets()
        try? FileManager.default.removeItem(at: replayCacheURL)
        super.tearDown()
    }

    func testCrossRouteMatrixRejectsWrongActivityPayloads() throws {
        let divePayload = try WatchDiveSyncCodec.makeTestWatchTransport(session: makeDiveSession())
        let apneaPayload = try ApneaSessionSyncCodec.makeTestWatchTransport(session: makeApneaSession())
        let snorkelPayload = try SnorkelingSessionSyncCodec.makeTestWatchTransport(session: makeSnorkelingSession())

        XCTAssertNil(divePayload[ApneaSessionSyncCodec.payloadKey])
        XCTAssertNil(divePayload[SnorkelingSessionSyncCodec.payloadKey])
        XCTAssertNil(apneaPayload[WatchDiveSyncCodec.payloadKey])
        XCTAssertNil(apneaPayload[SnorkelingSessionSyncCodec.payloadKey])
        XCTAssertNil(snorkelPayload[WatchDiveSyncCodec.payloadKey])
        XCTAssertNil(snorkelPayload[ApneaSessionSyncCodec.payloadKey])
    }

    func testWrongKeyWithSignedTransportRejectedByTargetCodec() throws {
        let session = makeApneaSession()
        let payload = try ApneaSessionSyncCodec.makeTestWatchTransport(session: session)
        guard let transportData = payload[ApneaSessionSyncCodec.payloadKey] as? Data else {
            return XCTFail("missing transport")
        }
        let wrongPayload = [WatchDiveSyncCodec.payloadKey: transportData]
        XCTAssertThrowsError(try WatchDiveSyncCodec.parsePayload(from: wrongPayload))
    }

    func testWrongEnvelopeActivityRejectedBeforeSessionDecode() throws {
        let body = try JSONEncoder().encode(makeApneaSession())
        WatchSyncTestSupport.requirePeerSecret()
        let key = try WatchSyncAuth.deriveSyncKey(peerBundleID: "com.egopfe.dirdiving.ios")
        let transport = ActivitySyncSignedTransport.makeSigned(
            body: body,
            bundleID: "com.egopfe.dirdiving.ios.watch",
            activity: .diving,
            messageType: .sessionUpsert,
            revision: 1,
            syncKey: key
        )
        let data = try JSONEncoder().encode(transport)
        let payload = [ApneaSessionSyncCodec.payloadKey: data]
        XCTAssertThrowsError(try ApneaSessionSyncCodec.parsePayload(from: payload))
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
