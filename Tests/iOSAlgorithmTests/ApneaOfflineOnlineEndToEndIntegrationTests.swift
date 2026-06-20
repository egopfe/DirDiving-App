import XCTest

/// Automated offline → online Apnea sync harness (production codecs/stores, no physical devices).
@MainActor
final class ApneaOfflineOnlineEndToEndIntegrationTests: XCTestCase {
    private let peerSecret = Data(repeating: 11, count: 32).base64EncodedString()
    private var logbookDirectory: URL!
    private var replayCacheURL: URL!
    private var pendingQueueURL: URL!

    override func setUp() {
        super.setUp()
        WatchSyncAuth.resetPeerTrust()
        ApneaSessionSyncCodec.resetTestHooks()
        ApneaImportedPlanStore.shared.resetForTests()

        logbookDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: logbookDirectory, withIntermediateDirectories: true)
        IOSApneaLogbookStore.testHook_storageDirectoryURL = logbookDirectory

        replayCacheURL = FileManager.default.temporaryDirectory.appendingPathComponent("e2e-replay-\(UUID().uuidString).json")
        pendingQueueURL = FileManager.default.temporaryDirectory.appendingPathComponent("e2e-pending-\(UUID().uuidString).json")

        ApneaSessionSyncCodec.testHook_bypassConnectivityChecks = true
        ApneaSessionSyncCodec.testHook_replayCacheFileURL = replayCacheURL
        ApneaSyncTestSupport.installDeterministicSecrets()
        ApneaSyncTestSupport.requirePeerSecret()
    }

    override func tearDown() {
        ApneaSessionSyncCodec.resetTestHooks()
        IOSApneaLogbookStore.testHook_storageDirectoryURL = nil
        ApneaImportedPlanStore.shared.resetForTests()
        ApneaSyncTestSupport.resetSecrets()
        try? FileManager.default.removeItem(at: logbookDirectory)
        try? FileManager.default.removeItem(at: replayCacheURL)
        try? FileManager.default.removeItem(at: pendingQueueURL)
        super.tearDown()
    }

    func testOfflineWatchSessionImportsOnceAfterReconnectWithSignedACK() throws {
        // 1–5. iOS plan seal → Watch import (offline-capable local store)
        let package = try ApneaSyncPackageBuilder.build(
            plan: ApneaSessionPlan(kind: .custom, title: "E2E", entries: [
                ApneaPlannedDiveEntry(orderIndex: 0, targetDepthMeters: 20, targetDurationSeconds: 60, plannedRecoverySeconds: 60)
            ]),
            profile: ApneaCompanionProfile(displayName: "E2E", discipline: .custom),
            settings: .default,
            packageID: UUID(),
            revision: 1
        )
        let planData = try ApneaSyncCodec.encode(package)
        let planPayload = ApneaSyncTransferSupport.makeTransferUserInfo(packageData: planData, package: package)
        XCTAssertNotNil(ApneaSyncWatchReceiver.importPayload(planPayload, store: .shared, sessionInProgress: false))
        XCTAssertEqual(ApneaImportedPlanStore.shared.activatedRevision, 1)

        // 6–11. Watch offline session (no iPhone) — completed session queued locally
        let sessionID = UUID()
        var session = ApneaSession(
            id: sessionID,
            startMode: .watch,
            state: .completed,
            dives: [ApneaDive(startedAtMonotonicSeconds: 0, durationSeconds: 90, maxDepthMeters: 18, averageDepthMeters: 12)]
        )
        session.statistics = session.refreshedStatistics()
        var pending: [ApneaSyncPendingTransfer] = [ApneaSyncPendingTransfer(session: session)]
        try persistPendingQueue(&pending)

        // 12–14. Relaunch restores pending queue
        pending = try loadPendingQueue()
        XCTAssertEqual(pending.count, 1)
        XCTAssertEqual(pending[0].session.id, sessionID)

        // 15–19. Reconnect → signed v2 transport → iOS logbook import
        let transport = try ApneaSessionSyncCodec.makeTestWatchTransport(session: session)
        let parsed = try ApneaSessionSyncCodec.parsePayload(from: transport)
        let logbook = IOSApneaLogbookStore()
        logbook.resetImportedIDsForTesting()
        let importResult = logbook.mergeImportedSession(parsed.session)
        XCTAssertEqual(importResult, .imported)
        XCTAssertEqual(logbook.sessions.count, 1)
        XCTAssertEqual(logbook.sessions[0].id, sessionID)

        // 20–21. Signed ACK → queue item removed
        let ackIssuedAt = Date()
        let ackPayload = ApneaSessionSyncCodec.makeImportAckPayload(sessionID: sessionID, issuedAt: ackIssuedAt)
        guard let ack = ApneaSessionSyncCodec.parseImportAck(from: ackPayload) else {
            return XCTFail("ACK parse failed")
        }
        XCTAssertTrue(
            ApneaSessionSyncCodec.ackSignature(sessionID: ack.sessionID, issuedAt: ack.issuedAt).count > 0
        )
        pending.removeAll { $0.session.id == sessionID }
        try persistPendingQueue(&pending)
        XCTAssertTrue(pending.isEmpty)

        // Replay rejected
        XCTAssertThrowsError(try ApneaSessionSyncCodec.parsePayload(from: transport)) { error in
            XCTAssertEqual(error as? ApneaSessionSyncError, .replayedPayload)
        }
    }

    func testPlanReceivedDuringActiveSessionRemainsPending() throws {
        let first = try makePlan(revision: 1)
        importPlan(first, sessionInProgress: false)
        let second = try makePlan(revision: 2, packageID: first.body.packageID)
        XCTAssertNotNil(ApneaSyncWatchReceiver.importPayload(try secondPayload(second), store: .shared, sessionInProgress: true))
        XCTAssertEqual(ApneaImportedPlanStore.shared.activatedRevision, 1)
        XCTAssertTrue(ApneaImportedPlanStore.shared.hasPendingActivation)
    }

    func testDuplicateTransportIsIdempotent() throws {
        let session = ApneaSession(
            startMode: .watch,
            state: .completed,
            dives: [ApneaDive(startedAtMonotonicSeconds: 0, durationSeconds: 60, maxDepthMeters: 12, averageDepthMeters: 10)]
        )
        let transport = try ApneaSessionSyncCodec.makeTestWatchTransport(session: session)
        let logbook = IOSApneaLogbookStore()
        logbook.resetImportedIDsForTesting()
        let parsed = try ApneaSessionSyncCodec.parsePayload(from: transport)
        XCTAssertEqual(logbook.mergeImportedSession(parsed.session), .imported)
        XCTAssertEqual(logbook.mergeImportedSession(parsed.session), .merged)
        XCTAssertEqual(logbook.sessions.count, 1)
    }

    private func makePlan(revision: Int, packageID: UUID = UUID()) throws -> ApneaSyncPackage {
        try ApneaSyncPackageBuilder.build(
            plan: ApneaSessionPlan(kind: .custom, title: "Plan", entries: [
                ApneaPlannedDiveEntry(orderIndex: 0, targetDepthMeters: 15, targetDurationSeconds: 60, plannedRecoverySeconds: 60)
            ]),
            profile: nil,
            settings: .default,
            packageID: packageID,
            revision: revision
        )
    }

    private func secondPayload(_ package: ApneaSyncPackage) throws -> [String: Any] {
        let data = try ApneaSyncCodec.encode(package)
        return ApneaSyncTransferSupport.makeTransferUserInfo(packageData: data, package: package)
    }

    private func importPlan(_ package: ApneaSyncPackage, sessionInProgress: Bool) {
        guard let payload = try? secondPayload(package) else { return XCTFail("payload") }
        _ = ApneaSyncWatchReceiver.importPayload(payload, store: .shared, sessionInProgress: sessionInProgress)
    }

    private func persistPendingQueue(_ queue: inout [ApneaSyncPendingTransfer]) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(queue)
        try data.write(to: pendingQueueURL, options: .atomic)
    }

    private func loadPendingQueue() throws -> [ApneaSyncPendingTransfer] {
        let data = try Data(contentsOf: pendingQueueURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([ApneaSyncPendingTransfer].self, from: data)
    }
}
