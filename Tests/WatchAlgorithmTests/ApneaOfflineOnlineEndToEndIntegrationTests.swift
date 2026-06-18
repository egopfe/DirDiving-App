import XCTest

@MainActor
final class ApneaOfflineOnlineEndToEndIntegrationTests: XCTestCase {
    private let peerSecret = Data(repeating: 13, count: 32).base64EncodedString()
    private var pendingURL: URL!

    override func setUp() {
        super.setUp()
        WatchSyncAuth.resetPeerTrust()
        ApneaImportedPlanStore.shared.resetForTests()
        pendingURL = FileManager.default.temporaryDirectory.appendingPathComponent("watch-pending-\(UUID().uuidString).json")
        WatchSyncAuth.ingestSharedSecretFromContext([WatchSyncAuth.contextKey: peerSecret])
    }

    override func tearDown() {
        ApneaImportedPlanStore.shared.resetForTests()
        WatchSyncAuth.resetPeerTrust()
        try? FileManager.default.removeItem(at: pendingURL)
        super.tearDown()
    }

    func testOfflineSessionQueuedAndPayloadSigned() throws {
        guard WatchSyncAuth.hasPeerSecret() else { throw XCTSkip("peer secret unavailable") }
        let package = try ApneaSyncPackageBuilder.build(
            plan: ApneaSessionPlan(kind: .custom, title: "Offline", entries: [
                ApneaPlannedDiveEntry(orderIndex: 0, targetDepthMeters: 18, targetDurationSeconds: 60, plannedRecoverySeconds: 60)
            ]),
            profile: nil,
            settings: .default,
            packageID: UUID(),
            revision: 1
        )
        let data = try ApneaSyncCodec.encode(package)
        _ = ApneaSyncWatchReceiver.importPayload(
            ApneaSyncTransferSupport.makeTransferUserInfo(packageData: data, package: package),
            store: .shared,
            sessionInProgress: false
        )
        XCTAssertEqual(ApneaImportedPlanStore.shared.activatedRevision, 1)

        var session = ApneaSession(
            startMode: .watch,
            state: .completed,
            dives: [ApneaDive(startedAtMonotonicSeconds: 0, durationSeconds: 80, maxDepthMeters: 16, averageDepthMeters: 11)]
        )
        session.statistics = session.refreshedStatistics()
        var queue = [ApneaSyncPendingTransfer(session: session)]
        try persist(&queue)
        queue = try load()
        XCTAssertEqual(queue.count, 1)

        let envelope = try ApneaSessionSyncCodec.makePayload(session: session)
        XCTAssertNotNil(envelope.message[ApneaSessionSyncCodec.payloadKey])
    }

    private func persist(_ queue: inout [ApneaSyncPendingTransfer]) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        try encoder.encode(queue).write(to: pendingURL, options: .atomic)
    }

    private func load() throws -> [ApneaSyncPendingTransfer] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([ApneaSyncPendingTransfer].self, from: Data(contentsOf: pendingURL))
    }
}
