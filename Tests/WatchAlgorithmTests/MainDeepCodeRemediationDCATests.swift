import XCTest
@testable import DIRDivingWatchApp

@MainActor
final class MainDeepCodeRemediationDCATests: XCTestCase {
    override func setUp() async throws {
        try await super.setUp()
        WatchSyncAuth.resetPeerTrust()
        WatchDiveSyncCodec.replayCache.reset()
        WatchSyncService.shared.testHook_resetPendingQueueForTests()
        DiveManager.testHook_activeDraftWriteCount = 0
    }

    override func tearDown() async throws {
        WatchSyncService.shared.testHook_resetPendingQueueForTests()
        WatchSyncAuth.resetPeerTrust()
        WatchDiveSyncCodec.replayCache.reset()
        try await super.tearDown()
    }

    // MARK: - MAIN-DCA-001 import ACK via userInfo

    func testSignedImportAckViaUserInfoDequeuesPending() throws {
        try installPeerSecret()
        let sync = WatchSyncService.shared
        let session = sampleSession()
        sync.testHook_enqueueSession(session)
        let issuedAt = Date()
        let payload = WatchDiveSyncCodec.makeImportAckPayload(sessionID: session.id, issuedAt: issuedAt)
        guard let parsed = WatchDiveSyncCodec.parseImportAck(from: payload) else {
            XCTFail("Expected parseable ACK")
            return
        }
        sync.testHook_handleCompanionImportAckForTests(payload)
        XCTAssertTrue(sync.testHook_pendingSessionIDs.isEmpty)
        XCTAssertEqual(sync.acknowledgedTransferCount, 1)
        _ = parsed
    }

    func testInvalidImportAckViaUserInfoRetainsPending() throws {
        try installPeerSecret()
        let sync = WatchSyncService.shared
        let session = sampleSession()
        sync.testHook_enqueueSession(session)
        sync.testHook_confirmSignedAck(sessionID: session.id, issuedAt: Date(), signature: "invalid")
        XCTAssertEqual(sync.testHook_pendingSessionIDs, [session.id])
    }

    // MARK: - MAIN-DCA-002 cloud payload cap

    func testWatchCloudSyncRejectsOversizedPayload() {
        struct Blob: Codable { let data: String }
        let store = CloudSyncStore(defaults: UserDefaults(suiteName: "watch.cloud.\(UUID().uuidString)")!)
        let key = "test"
        let blob = Blob(data: String(repeating: "x", count: DiveAlgorithmConfiguration.maxSyncPayloadBytes + 1))
        store.save(blob, forKey: key)
        XCTAssertNil(store.load(Blob.self, forKey: key))
        XCTAssertNil(store.loadRawLocalData(forKey: key))
    }

    // MARK: - MAIN-DCA-006 merge union

    func testWatchMergeUnionsCompatibleSamples() {
        let id = UUID()
        let start = Date()
        let local = DiveSession(
            id: id,
            startDate: start,
            endDate: start.addingTimeInterval(60),
            durationSeconds: 60,
            maxDepthMeters: 10,
            avgDepthMeters: 8,
            avgWaterTemperatureCelsius: nil,
            minWaterTemperatureCelsius: nil,
            maxWaterTemperatureCelsius: nil,
            ttv: 1,
            entryGPS: nil,
            exitGPS: nil,
            samples: [DiveSample(timestamp: start.addingTimeInterval(10), depthMeters: 10, temperatureCelsius: nil)],
            isManual: false
        )
        let remote = DiveSession(
            id: id,
            startDate: start,
            endDate: start.addingTimeInterval(120),
            durationSeconds: 120,
            maxDepthMeters: 12,
            avgDepthMeters: 9,
            avgWaterTemperatureCelsius: nil,
            minWaterTemperatureCelsius: nil,
            maxWaterTemperatureCelsius: nil,
            ttv: 2,
            entryGPS: nil,
            exitGPS: nil,
            samples: [DiveSample(timestamp: start.addingTimeInterval(70), depthMeters: 12, temperatureCelsius: nil)],
            isManual: false
        )
        let merged = DiveSessionMerge.preferred(local, remote)
        XCTAssertEqual(merged.maxDepthMeters, 12, accuracy: 0.01)
        XCTAssertGreaterThanOrEqual(merged.samples.count, 1)
        XCTAssertGreaterThanOrEqual(merged.durationSeconds, 120)
    }

    // MARK: - MAIN-DCA-008 draft throttle

    func testActiveDraftDoesNotPersistOnEverySample() async throws {
        let tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("draft-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        DiveManager.testHook_draftDirectoryURL = tempDirectory
        let suiteName = "draft-throttle-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        let manager = DiveManager(
            logStore: DiveLogStore(),
            gpsManager: GPSManager(),
            ascentSettings: AscentRateSettingsStore(defaults: defaults)
        )
        manager.testHook_setDepthAutomationAvailableForTests(true)
        manager.startManualDive()
        for index in 0..<20 {
            manager.testHook_processDepthMeasurement(
                rawDepthMeters: Double(index + 1),
                timestamp: Date().addingTimeInterval(Double(index))
            )
        }
        XCTAssertLessThan(DiveManager.testHook_activeDraftWriteCount, 20)
        XCTAssertGreaterThan(DiveManager.testHook_activeDraftWriteCount, 0)
    }

    private func installPeerSecret() throws {
        let secret = Data(repeating: 9, count: 32)
        let result = WatchSyncAuth.ingestSharedSecretFromContext([
            WatchSyncAuth.contextKey: secret.base64EncodedString()
        ])
        guard WatchSyncAuth.hasPeerSecret(), result == .acceptedFirstTrust else {
            throw XCTSkip("Peer secret unavailable in test keychain")
        }
    }

    private func sampleSession() -> DiveSession {
        let start = Date()
        return DiveSession(
            id: UUID(),
            startDate: start,
            endDate: start.addingTimeInterval(120),
            durationSeconds: 120,
            maxDepthMeters: 18,
            avgDepthMeters: 12,
            avgWaterTemperatureCelsius: nil,
            minWaterTemperatureCelsius: nil,
            maxWaterTemperatureCelsius: nil,
            ttv: 1,
            entryGPS: nil,
            exitGPS: nil,
            samples: [],
            isManual: false
        )
    }
}

extension WatchSyncService {
    func testHook_handleCompanionImportAckForTests(_ payload: [String: Any]) {
        guard let parsed = WatchDiveSyncCodec.parseImportAck(from: payload) else { return }
        confirmSignedAck(sessionID: parsed.sessionID, issuedAt: parsed.issuedAt, signature: parsed.signature)
    }
}
