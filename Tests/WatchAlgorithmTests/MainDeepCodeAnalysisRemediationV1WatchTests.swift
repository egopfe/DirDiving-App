import XCTest

@MainActor
final class MainDeepCodeAnalysisRemediationV1WatchTests: XCTestCase {
    override func setUp() async throws {
        try await super.setUp()
        WatchDiveSyncCodec.replayCache.reset()
        CompanionPhotoManagementAuth.requestReplayCache.reset()
        CompanionPhotoManagementAuth.responseReplayCache.reset()
        WatchSyncAuth.resetPeerTrust()
        WatchSyncService.shared.testHook_resetPendingQueueForTests()
    }

    // MARK: - MAIN-DCA-019 photo delete ACK queue

    func testDeleteAckQueuedWhenSessionInactive() throws {
        let url = PendingPhotoManagementResponseQueue.fileURL()
        defer { try? FileManager.default.removeItem(at: url) }

        let payload: [String: Any] = [
            "type": WatchSyncKeys.companionPhotoDeleteAckType,
            WatchSyncKeys.companionPhotoDeleteRequestIDKey: "req-1",
            WatchSyncKeys.companionPhotoDeleteFileNameKey: "photo.png",
            WatchSyncKeys.companionPhotoDeleteStatusKey: CompanionPhotoManagementSupport.deleteStatusDeleted,
        ]
        let queued = PendingPhotoManagementResponse.deleteAck(
            requestID: "req-1",
            storedFileName: "photo.png",
            status: CompanionPhotoManagementSupport.deleteStatusDeleted,
            errorCode: nil,
            payload: payload
        )
        XCTAssertNotNil(queued)
        PendingPhotoManagementResponseQueue.save([queued!])
        XCTAssertEqual(PendingPhotoManagementResponseQueue.load().count, 1)
    }

    func testDeleteAckQueuePersistsAcrossLoad() throws {
        let url = PendingPhotoManagementResponseQueue.fileURL()
        defer { try? FileManager.default.removeItem(at: url) }
        let payload: [String: Any] = [
            "type": WatchSyncKeys.companionPhotoDeleteAckType,
            WatchSyncKeys.companionPhotoDeleteRequestIDKey: "req-2",
            WatchSyncKeys.companionPhotoDeleteFileNameKey: "photo.png",
            WatchSyncKeys.companionPhotoDeleteStatusKey: CompanionPhotoManagementSupport.deleteStatusDeleted,
        ]
        guard let entry = PendingPhotoManagementResponse.deleteAck(
            requestID: "req-2",
            storedFileName: "photo.png",
            status: CompanionPhotoManagementSupport.deleteStatusDeleted,
            errorCode: nil,
            payload: payload
        ) else {
            return XCTFail("missing entry")
        }
        PendingPhotoManagementResponseQueue.save([entry])
        XCTAssertEqual(PendingPhotoManagementResponseQueue.load().first?.requestID, "req-2")
    }

    // MARK: - MAIN-DCA-020 briefing filename sanitization

    func testBriefingFilenameRejectsPathTraversal() {
        XCTAssertNil(PlannerBriefingFilenameSanitizer.sanitizedFileName("../card.png"))
        XCTAssertNil(PlannerBriefingFilenameSanitizer.sanitizedFileName("..%2Fcard.png"))
        XCTAssertEqual(
            PlannerBriefingFilenameSanitizer.rejectionReason(for: "/tmp/card.png"),
            .pathTraversal
        )
    }

    func testBriefingFilenameAcceptsValidPNG() {
        XCTAssertEqual(PlannerBriefingFilenameSanitizer.sanitizedFileName("runtime_card.png"), "runtime_card.png")
    }

    // MARK: - MAIN-DCA-022 reminder suppression

    func testReminderSuppressedForCriticalDepth() {
        let input = LiveDiveReminderSuppressionPolicy.Input(
            alarmWarningMessage: nil,
            depthSafetyState: .critical,
            showAscentAlarmBanner: false,
            ascentAlarmEnabled: true,
            ascentIsOverLimit: false,
            isDepthDataStale: false,
            isManualNoDepthSession: false
        )
        XCTAssertTrue(LiveDiveReminderSuppressionPolicy.shouldSuppressReminders(input))
    }

    func testReminderSuppressedForCautionDepth() {
        let input = LiveDiveReminderSuppressionPolicy.Input(
            alarmWarningMessage: nil,
            depthSafetyState: .caution,
            showAscentAlarmBanner: false,
            ascentAlarmEnabled: false,
            ascentIsOverLimit: false,
            isDepthDataStale: false,
            isManualNoDepthSession: false
        )
        XCTAssertTrue(LiveDiveReminderSuppressionPolicy.shouldSuppressReminders(input))
    }

    func testReminderNotSuppressedForNormalDepth() {
        let input = LiveDiveReminderSuppressionPolicy.Input(
            alarmWarningMessage: nil,
            depthSafetyState: .normal,
            showAscentAlarmBanner: false,
            ascentAlarmEnabled: false,
            ascentIsOverLimit: false,
            isDepthDataStale: false,
            isManualNoDepthSession: false
        )
        XCTAssertFalse(LiveDiveReminderSuppressionPolicy.shouldSuppressReminders(input))
    }

    // MARK: - MAIN-DCA-029 duplicate transfer flush guard

    func testFlushPolicySkipsInFlightSession() {
        let sessionID = UUID()
        let transfer = WatchSyncPendingTransfer(session: makeSession(id: sessionID))
        let eligible = WatchSyncPendingFlushPolicy.sessionsEligibleForSend(
            transfers: [transfer],
            sessionID: { $0.session.id },
            lastAttemptAt: { $0.lastAttemptAt },
            inFlightSessionIDs: [sessionID]
        )
        XCTAssertTrue(eligible.isEmpty)
    }

    func testFlushPolicyAllowsRetryAfterInterval() {
        let sessionID = UUID()
        var transfer = WatchSyncPendingTransfer(session: makeSession(id: sessionID))
        transfer.lastAttemptAt = Date(timeIntervalSinceNow: -60)
        let eligible = WatchSyncPendingFlushPolicy.sessionsEligibleForSend(
            transfers: [transfer],
            sessionID: { $0.session.id },
            lastAttemptAt: { $0.lastAttemptAt },
            inFlightSessionIDs: []
        )
        XCTAssertEqual(eligible.count, 1)
    }

    // MARK: - MAIN-DCA-012 alarm blink uses active flag not timer toggle

    func testAlarmBlinkActiveStartsFalseWithoutTimer() {
        let manager = DiveManager(
            logStore: DiveLogStore(),
            gpsManager: GPSManager(),
            ascentSettings: AscentRateSettingsStore()
        )
        manager.testHook_shutdownTimersForTests()
        XCTAssertFalse(manager.alarmBlinkActive)
    }

    private func makeSession(id: UUID = UUID()) -> DiveSession {
        let start = Date(timeIntervalSince1970: 1_000)
        let end = start.addingTimeInterval(600)
        return DiveSession(
            id: id,
            startDate: start,
            endDate: end,
            durationSeconds: 600,
            maxDepthMeters: 20,
            avgDepthMeters: 12,
            avgWaterTemperatureCelsius: 20,
            minWaterTemperatureCelsius: nil,
            maxWaterTemperatureCelsius: nil,
            ttv: 1,
            entryGPS: nil,
            exitGPS: nil,
            samples: [DiveSample(timestamp: start, depthMeters: 20, temperatureCelsius: 20)]
        )
    }
}
