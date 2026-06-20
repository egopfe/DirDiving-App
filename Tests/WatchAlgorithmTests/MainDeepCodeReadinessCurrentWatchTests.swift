import XCTest

@MainActor
final class MainDeepCodeReadinessCurrentWatchTests: XCTestCase {
    override func setUp() async throws {
        try await super.setUp()
        CloudSyncMigrationTelemetry.resetForTests()
        WatchSyncTrustStatePolicy.resetForTests()
        WatchDiveSyncCodec.replayCache.reset()
        WatchSyncAuth.resetPeerTrust()
    }

    // MARK: - MAIN-DCA-003

    func testLegacyOversizedCloudPayloadDecision() {
        let over = CloudSyncBudgetPolicy.maxPerKeyBytes + 1
        XCTAssertEqual(
            CloudSyncLegacyMigrationPolicy.incomingPayloadDecision(byteCount: over),
            .ignoreLegacyOversizedPerKey
        )
    }

    func testMigrationTelemetryCounters() {
        CloudSyncMigrationTelemetry.recordMigrationAttempt()
        XCTAssertEqual(CloudSyncMigrationTelemetry.migrationAttemptCount, 1)
    }

    // MARK: - MAIN-DCA-013

    func testTrustStateRecordsFingerprintWithoutSecret() {
        let secret = Data(repeating: 0xFE, count: 32)
        WatchSyncTrustStatePolicy.recordEstablishedTrust(peerSecret: secret)
        XCTAssertNotNil(WatchSyncTrustStatePolicy.storedFingerprint)
        XCTAssertNotEqual(WatchSyncTrustStatePolicy.storedFingerprint, secret.base64EncodedString())
    }

    // MARK: - MAIN-DCA-019 photo ACK queue

    func testPhotoDeleteAckQueueSurvivesRestart() throws {
        let url = PendingPhotoManagementResponseQueue.fileURL()
        defer { try? FileManager.default.removeItem(at: url) }
        let payload: [String: Any] = [
            "type": WatchSyncKeys.companionPhotoDeleteAckType,
            WatchSyncKeys.companionPhotoDeleteRequestIDKey: "readiness-req",
            WatchSyncKeys.companionPhotoDeleteFileNameKey: "photo.jpg",
            WatchSyncKeys.companionPhotoDeleteStatusKey: CompanionPhotoManagementSupport.deleteStatusDeleted,
        ]
        let entry = PendingPhotoManagementResponse.deleteAck(
            requestID: "readiness-req",
            storedFileName: "photo.jpg",
            status: CompanionPhotoManagementSupport.deleteStatusDeleted,
            errorCode: nil,
            payload: payload
        )
        XCTAssertNotNil(entry)
        PendingPhotoManagementResponseQueue.save([entry!])
        XCTAssertEqual(PendingPhotoManagementResponseQueue.load().count, 1)
    }

    // MARK: - MAIN-DCA-020/021 briefing security

    func testBriefingAdversarialFilenamesRejected() {
        XCTAssertNil(PlannerBriefingFilenameSanitizer.sanitizedFileName("../card.png"))
        XCTAssertNil(PlannerBriefingFilenameSanitizer.sanitizedFileName("..%2Fcard.png"))
        XCTAssertEqual(PlannerBriefingFilenameSanitizer.sanitizedFileName("valid_card.png"), "valid_card.png")
    }

    // MARK: - MAIN-DCA-022 reminder suppression

    func testCriticalDepthStateSuppressesReminders() {
        let input = LiveDiveReminderSuppressionPolicy.Input(
            alarmWarningMessage: nil,
            depthSafetyState: .critical,
            showAscentAlarmBanner: false,
            ascentAlarmEnabled: false,
            ascentIsOverLimit: false,
            isDepthDataStale: false,
            isManualNoDepthSession: false
        )
        XCTAssertTrue(LiveDiveReminderSuppressionPolicy.shouldSuppressReminders(input))
    }

    // MARK: - MAIN-DCA-027

    func testLegacyV1ProtectedOperationsBlocked() {
        XCTAssertTrue(
            WatchSyncSchemaV1Policy.rejectsProtectedOperationOverLegacySchema(.photoDelete, payloadVersion: 1)
        )
    }

    // MARK: - MAIN-DCA-008/012 performance posture

    func testDraftPersistenceIntervalIsThrottled() {
        XCTAssertGreaterThanOrEqual(DiveAlgorithmConfiguration.activeDiveDraftPersistenceIntervalSeconds, 1)
    }

    // MARK: - Security negatives

    func testSchemaV1DeprecationTargetExists() {
        XCTAssertFalse(WatchSyncSchemaV1Policy.deprecationRemovalTarget.isEmpty)
    }

    func testPendingFlushPolicyPreventsDuplicateInFlight() {
        struct Stub { let id: UUID; let lastAttempt: Date? }
        let sessionID = UUID()
        let transfers = [Stub(id: sessionID, lastAttempt: nil)]
        var inFlight = Set<UUID>()
        let eligible = WatchSyncPendingFlushPolicy.sessionsEligibleForSend(
            transfers: transfers,
            sessionID: { $0.id },
            lastAttemptAt: { $0.lastAttempt },
            inFlightSessionIDs: inFlight
        )
        XCTAssertEqual(eligible.count, 1)
        inFlight.insert(sessionID)
        let blocked = WatchSyncPendingFlushPolicy.sessionsEligibleForSend(
            transfers: transfers,
            sessionID: { $0.id },
            lastAttemptAt: { $0.lastAttempt },
            inFlightSessionIDs: inFlight
        )
        XCTAssertTrue(blocked.isEmpty)
    }
}
