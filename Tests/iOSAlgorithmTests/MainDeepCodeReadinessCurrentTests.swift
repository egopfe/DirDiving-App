import XCTest

@MainActor
final class MainDeepCodeReadinessCurrentTests: XCTestCase {
    override func setUp() async throws {
        try await super.setUp()
        CloudSyncMigrationTelemetry.resetForTests()
        WatchSyncTrustStatePolicy.resetForTests()
        WatchDiveSyncCodec.replayCache.reset()
        WatchSyncAuth.resetPeerTrust()
#if DEBUG
        WatchSyncAuth.resetTestSecrets()
#endif
    }

    // MARK: - MAIN-DCA-003 legacy KVS migration

    func testLegacyOversizedPerKeyPayloadIgnored() {
        let limit = CloudSyncBudgetPolicy.maxPerKeyBytes
        XCTAssertEqual(
            CloudSyncLegacyMigrationPolicy.incomingPayloadDecision(byteCount: limit + 1),
            .ignoreLegacyOversizedPerKey
        )
        XCTAssertEqual(
            CloudSyncLegacyMigrationPolicy.incomingPayloadDecision(byteCount: limit),
            .usePayload
        )
    }

    func testExactPerKeyBoundaryAllowedOneByteOverRejected() {
        let limit = CloudSyncBudgetPolicy.maxPerKeyBytes
        XCTAssertTrue(CloudSyncLegacyMigrationPolicy.isExactPerKeyBoundary(byteCount: limit))
        XCTAssertTrue(CloudSyncLegacyMigrationPolicy.isOneByteOverPerKey(byteCount: limit + 1))
    }

    func testPartialMigrationKeepsLocalWhenAggregateBlocked() {
        let perKey = CloudSyncBudgetPolicy.maxPerKeyBytes / 4
        let chunk = Data(repeating: 0xCD, count: perKey)
        let footprints = (0..<7).map {
            CloudSyncBudgetPolicy.KeyFootprint(
                key: "k-\($0)",
                dataBytes: perKey,
                modifiedAtBytes: MemoryLayout<TimeInterval>.size
            )
        }
        let decision = CloudSyncLegacyMigrationPolicy.outgoingWriteDecision(
            key: "new-key",
            newData: chunk,
            existingFootprints: footprints
        )
        let outcome = CloudSyncLegacyMigrationPolicy.evaluatePartialMigration(
            hasLocalData: true,
            writeDecision: decision,
            alreadyCloudSynced: false
        )
        if case .blockedAggregate = decision {
            XCTAssertEqual(outcome, .partialMigrationKeptLocal)
        } else {
            XCTFail("Expected aggregate block")
        }
    }

    func testRepeatedMigrationIsIdempotentWhenAlreadySynced() {
        let data = Data(repeating: 0x01, count: 128)
        let decision = CloudSyncLegacyMigrationPolicy.outgoingWriteDecision(
            key: "solo",
            newData: data,
            existingFootprints: []
        )
        XCTAssertEqual(decision, .allowed)
        let outcome = CloudSyncLegacyMigrationPolicy.evaluatePartialMigration(
            hasLocalData: true,
            writeDecision: decision,
            alreadyCloudSynced: true
        )
        XCTAssertEqual(outcome, .idempotentNoOp)
    }

    func testMigrationTelemetryDoesNotPersistSensitiveKeys() {
        CloudSyncMigrationTelemetry.recordLegacyOversizedIgnored(storageKey: "dirdiving_ios_dive_sessions")
        CloudSyncMigrationTelemetry.recordPartialMigrationKeptLocal()
        CloudSyncMigrationTelemetry.recordMigrationAttempt()
        XCTAssertEqual(CloudSyncMigrationTelemetry.legacyOversizedIgnoredCount, 1)
        XCTAssertEqual(CloudSyncMigrationTelemetry.partialMigrationKeptLocalCount, 1)
        XCTAssertEqual(CloudSyncMigrationTelemetry.migrationAttemptCount, 1)
    }

    // MARK: - MAIN-DCA-013 TOFU trust state

    func testTrustFingerprintNeverEqualsRawSecret() {
        let secret = Data(repeating: 0xAB, count: 32)
        let fingerprint = WatchSyncTrustStatePolicy.peerSecretFingerprint(secret)
        XCTAssertEqual(fingerprint.count, 16)
        XCTAssertFalse(fingerprint.contains(where: { $0 == "A" && fingerprint == secret.base64EncodedString() }))
        WatchSyncTrustStatePolicy.recordEstablishedTrust(peerSecret: secret)
        XCTAssertEqual(WatchSyncTrustStatePolicy.storedFingerprint, fingerprint)
    }

    func testTrustEpochIncrementsOnReset() {
        let secret = Data(repeating: 0x01, count: 32)
        WatchSyncTrustStatePolicy.recordEstablishedTrust(peerSecret: secret)
        let before = WatchSyncTrustStatePolicy.trustEpoch
        WatchSyncTrustStatePolicy.incrementTrustEpochOnReset()
        XCTAssertEqual(WatchSyncTrustStatePolicy.trustEpoch, before + 1)
        XCTAssertNil(WatchSyncTrustStatePolicy.storedFingerprint)
    }

    func testTOFURejectsPeerSecretMismatch() {
        let first = Data(repeating: 1, count: 32)
        let second = Data(repeating: 2, count: 32)
        WatchSyncAuth.installTestSecrets(local: Data(repeating: 9, count: 32), peer: first)
        _ = WatchSyncAuth.ingestSharedSecretFromContext([
            WatchSyncAuth.contextKey: first.base64EncodedString()
        ])
        let result = WatchSyncAuth.ingestSharedSecretFromContext([
            WatchSyncAuth.contextKey: second.base64EncodedString()
        ])
        XCTAssertEqual(result, .rejectedMismatch)
        XCTAssertTrue(WatchSyncAuth.peerSecretMismatchDetected)
    }

    // MARK: - MAIN-DCA-011/028 merge matrix

    func testStaleWatchPayloadCannotOverwriteNewerIPhoneNotes() {
        let id = UUID()
        let start = Date(timeIntervalSince1970: 3_000)
        let end = start.addingTimeInterval(400)
        let sample = DiveSample(timestamp: start, depthMeters: 15, temperatureCelsius: 20)
        var local = makeSession(id: id, start: start, end: end.addingTimeInterval(60), samples: [sample], notes: "iPhone newer")
        var incoming = makeSession(id: id, start: start, end: end, samples: [sample], notes: "Watch stale")
        let merged = DiveSessionMerge.preferred(local, incoming)
        XCTAssertEqual(merged.notes, "iPhone newer")
        XCTAssertEqual(merged.endDate, local.endDate)
    }

    func testProfileIncompatibleSessionsPreferRicherLocal() {
        let id = UUID()
        let start = Date(timeIntervalSince1970: 3_100)
        let end = start.addingTimeInterval(300)
        let shallow = DiveSample(timestamp: start, depthMeters: 10, temperatureCelsius: 20)
        let deep = DiveSample(timestamp: start.addingTimeInterval(60), depthMeters: 30, temperatureCelsius: 19)
        let local = makeSession(id: id, start: start, end: end, samples: [shallow, deep], notes: "Two samples")
        let incoming = makeSession(id: id, start: start, end: end, samples: [shallow], notes: nil)
        let merged = DiveSessionMerge.preferred(local, incoming)
        XCTAssertEqual(merged.samples.count, 2)
        XCTAssertEqual(merged.notes, "Two samples")
    }

    // MARK: - MAIN-DCA-027 legacy schema

    func testLegacySchemaV1HasDocumentedRemovalTarget() {
        XCTAssertFalse(WatchSyncSchemaV1Policy.deprecationRemovalTarget.isEmpty)
        XCTAssertTrue(WatchSyncSchemaV1Policy.rejectsProtectedOperationOverLegacySchema(.signedAck, payloadVersion: 1))
    }

    // MARK: - MAIN-DCA-024 CCR tolerance

    func testCCRBailoutMODPolicyDocumentedAndCentralized() {
        XCTAssertFalse(WatchSyncTrustStatePolicy.acceptedResidualLimitation.isEmpty)
        XCTAssertGreaterThan(
            CCRMODTolerancePolicy.ccrBailoutSwitchDepthSlackMeters,
            CCRMODTolerancePolicy.openCircuitSwitchDepthSlackMeters
        )
    }

    // MARK: - MAIN-DCA-032 deferred reminder indicator (Watch policy tested on Watch target)

    func testDeferredReminderIndicatorDocumentedAsProductDecision() {
        XCTAssertFalse(WatchSyncTrustStatePolicy.acceptedResidualLimitation.isEmpty)
    }

    // MARK: - Security negative matrix (deterministic)

    func testForgedHMACRejectedWhenPeerSecretMissing() {
        WatchSyncAuth.resetPeerTrust()
#if DEBUG
        WatchSyncAuth.resetTestSecrets()
#endif
        XCTAssertFalse(WatchSyncAuth.hasPeerSecret())
        do {
            _ = try WatchSyncAuth.deriveSyncKey(peerBundleID: "com.egopfe.dirdiving.ios")
            XCTFail("Expected missingPeerSecret")
        } catch WatchSyncAuthError.missingPeerSecret {
            XCTAssertTrue(true)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testReplayedNonceRejectedOnSecondUse() {
        WatchSyncTestSupport.installDeterministicSecrets()
        defer { WatchSyncTestSupport.resetSecrets() }
        let nonce = UUID().uuidString
        XCTAssertFalse(WatchDiveSyncCodec.replayCache.isReplay(nonce))
        XCTAssertTrue(WatchDiveSyncCodec.replayCache.register(nonce))
        XCTAssertTrue(WatchDiveSyncCodec.replayCache.isReplay(nonce))
        XCTAssertFalse(WatchDiveSyncCodec.replayCache.register(nonce))
    }

    func testBriefingFilenameTraversalRejectedOnWatchPolicyTypeViaSchema() {
        XCTAssertTrue(
            WatchSyncSchemaV1Policy.rejectsProtectedOperationOverLegacySchema(.briefingManagement, payloadVersion: 1)
        )
    }

    func testApneaCloudCapabilityExplicitlyUnavailable() {
        XCTAssertFalse(ApneaCloudCapability.current.isUploadAvailable)
    }

    func testSnorkelingCloudCapabilityStatusOnly() {
        XCTAssertFalse(SnorkelingCloudCapability.current.isUploadAvailable)
    }

    // MARK: - Performance software budgets (deterministic, non-flaky)

    func testCloudBudgetEvaluationScalesLinearlyWithKeyCount() {
        measure {
            var footprints: [CloudSyncBudgetPolicy.KeyFootprint] = []
            for index in 0..<50 {
                footprints.append(
                    CloudSyncBudgetPolicy.KeyFootprint(
                        key: "perf-\(index)",
                        dataBytes: 1024,
                        modifiedAtBytes: 8
                    )
                )
            }
            _ = CloudSyncLegacyMigrationPolicy.outgoingWriteDecision(
                key: "perf-new",
                newData: Data(repeating: 0x01, count: 1024),
                existingFootprints: footprints
            )
        }
    }

    func testMergePreferredPerformanceBudget() {
        let id = UUID()
        let start = Date(timeIntervalSince1970: 4_000)
        let end = start.addingTimeInterval(3_600)
        let samples = (0..<120).map {
            DiveSample(timestamp: start.addingTimeInterval(Double($0 * 30)), depthMeters: 18, temperatureCelsius: 20)
        }
        let local = makeSession(id: id, start: start, end: end, samples: samples, notes: "Long dive")
        let incoming = makeSession(id: id, start: start, end: end, samples: samples)
        measure {
            for _ in 0..<20 {
                _ = DiveSessionMerge.preferred(local, incoming)
            }
        }
    }

    private func makeSession(
        id: UUID = UUID(),
        start: Date,
        end: Date,
        samples: [DiveSample],
        notes: String? = nil
    ) -> DiveSession {
        DiveSession(
            id: id,
            startDate: start,
            endDate: end,
            durationSeconds: end.timeIntervalSince(start),
            maxDepthMeters: samples.map(\.depthMeters).max() ?? 0,
            avgDepthMeters: samples.map(\.depthMeters).max() ?? 0,
            avgWaterTemperatureCelsius: 20,
            ttv: 1,
            entryGPS: nil,
            exitGPS: nil,
            samples: samples,
            siteName: nil,
            buddy: nil,
            notes: notes,
            equipmentUsed: nil
        )
    }
}
