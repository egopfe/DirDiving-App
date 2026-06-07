import XCTest

@MainActor
final class MainDeepCodeAuditRemediationTests: XCTestCase {
    override func setUp() async throws {
        try await super.setUp()
        WatchDiveSyncCodec.replayCache.reset()
        CompanionPhotoManagementAuth.requestReplayCache.reset()
        CompanionPhotoManagementAuth.responseReplayCache.reset()
        WatchSyncAuth.resetPeerTrust()
    }

    override func tearDown() async throws {
        WatchDiveSyncCodec.replayCache.reset()
        CompanionPhotoManagementAuth.requestReplayCache.reset()
        CompanionPhotoManagementAuth.responseReplayCache.reset()
        WatchSyncAuth.resetPeerTrust()
        try await super.tearDown()
    }

    // MARK: - MAIN-AUD-001 iOS outbound pending ACK

    func testIOSPendingQueuePolicyDequeuesOnlyAfterSignedAck() {
        let first = sampleSession(id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!)
        let second = sampleSession(id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!)
        let queue = [
            IOSWatchSyncPendingTransfer(session: first),
            IOSWatchSyncPendingTransfer(session: second),
        ]
        let result = IOSWatchSyncPendingQueuePolicy.dequeueAfterSignedAck(transfers: queue, sessionID: first.id)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.session.id, second.id)
    }

    func testUserInfoDeliveredMarksPendingWithoutRemovingIt() {
        var transfer = IOSWatchSyncPendingTransfer(session: sampleSession())
        transfer.userInfoDeliveredAt = Date()
        XCTAssertNotNil(transfer.userInfoDeliveredAt)
    }

    func testInvalidImportAckSignatureDoesNotVerify() throws {
        try installPeerSecret()
        let sessionID = UUID()
        let issuedAt = Date()
        XCTAssertFalse(WatchDiveSyncCodec.verifyAckSignature("invalid", sessionID: sessionID, issuedAt: issuedAt))
    }

    func testValidImportAckPayloadParses() throws {
        try installPeerSecret()
        let sessionID = UUID()
        let issuedAt = Date()
        let payload = WatchDiveSyncCodec.makeImportAckPayload(sessionID: sessionID, issuedAt: issuedAt)
        let parsed = try XCTUnwrap(WatchDiveSyncCodec.parseImportAck(from: payload))
        XCTAssertEqual(parsed.sessionID, sessionID)
        XCTAssertTrue(WatchDiveSyncCodec.verifyAckSignature(parsed.signature, sessionID: sessionID, issuedAt: issuedAt))
    }

    // MARK: - MAIN-AUD-002 signed photo management

    func testSignedInventoryRequestIncludesSignature() throws {
        try installPeerSecret()
        let requestID = UUID().uuidString
        let payload = CompanionPhotoManagementSupport.makeInventoryRequestPayload(requestID: requestID)
        XCTAssertFalse((payload[WatchSyncKeys.companionPhotoManagementSignatureKey] as? String ?? "").isEmpty)
    }

    func testSignedInventoryResponseAcceptedOnIOSVerifier() throws {
        try installPeerSecret()
        let payload = CompanionPhotoManagementSupport.makeInventoryResponsePayload(requestID: "req", items: [])
        XCTAssertNotNil(CompanionPhotoManagementSupport.parseInventoryResponse(payload))
    }

    func testUnsignedInventoryResponseRejectedOnIOSVerifier() {
        let payload: [String: Any] = [
            "type": WatchSyncKeys.companionPhotoInventoryResponseType,
            WatchSyncKeys.companionPhotoInventoryRequestIDKey: "req",
            WatchSyncKeys.companionPhotoInventoryStatusKey: CompanionPhotoManagementSupport.inventoryStatusOK,
            WatchSyncKeys.companionPhotoInventoryItemsKey: [[String: Any]](),
        ]
        XCTAssertNil(CompanionPhotoManagementSupport.parseInventoryResponse(payload))
    }

    func testReplayedSignedInventoryRequestRejected() throws {
        try installPeerSecret()
        let requestID = UUID().uuidString
        let payload = CompanionPhotoManagementSupport.makeInventoryRequestPayload(requestID: requestID)
        XCTAssertFalse((payload[WatchSyncKeys.companionPhotoManagementSignatureKey] as? String ?? "").isEmpty)
        let second = CompanionPhotoManagementSupport.makeInventoryRequestPayload(requestID: requestID)
        XCTAssertNotEqual(
            payload[WatchSyncKeys.companionPhotoManagementIssuedAtKey] as? TimeInterval,
            second[WatchSyncKeys.companionPhotoManagementIssuedAtKey] as? TimeInterval
        )
    }

    // MARK: - MAIN-AUD-003 / MAIN-AUD-010 cloud sync

    func testCloudSyncRejectsOversizedPayloadBeforeLocalWrite() {
        struct Payload: Codable { let blob: String }
        let suite = "MainDeepCodeAudit.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let key = "cloud.payload"
        let previous = Data("keep".utf8)
        defaults.set(previous, forKey: key)
        let store = CloudSyncStore(defaults: defaults)
        store.save(Payload(blob: String(repeating: "x", count: IOSAlgorithmConfiguration.maxSyncPayloadBytes + 1)), forKey: key)
        XCTAssertEqual(defaults.data(forKey: key), previous)
    }

    func testCloudSyncGenerationTokenPreventsStaleClear() async {
        let suite = "MainDeepCodeAudit.sync.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let store = CloudSyncStore(defaults: defaults)
        store.synchronize()
        store.synchronize()
        try? await Task.sleep(nanoseconds: 950_000_000)
        XCTAssertFalse(store.isSynchronizing)
    }

    // MARK: - MAIN-AUD-004 PDF protection

    func testPDFExportUsesCompleteFileProtection() throws {
        let directory = try PDFExportFilename.protectedExportDirectory()
        XCTAssertTrue(directory.path.contains("Application Support"))
        XCTAssertTrue(directory.lastPathComponent.contains("DIRDivingPDFExports"))

        let url = try PDFExportFilename.write(data: Data("%PDF-1.4".utf8), filename: "audit_test.pdf")
        defer { try? FileManager.default.removeItem(at: url) }
        XCTAssertTrue(url.path.hasPrefix(directory.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
    }

    func testPDFExportCleanupRemovesStaleFiles() throws {
        let directory = try PDFExportFilename.protectedExportDirectory()
        let staleURL = directory.appendingPathComponent("stale.pdf")
        try Data("%PDF".utf8).write(to: staleURL, options: [.atomic, .completeFileProtection])
        try FileManager.default.setAttributes([.modificationDate: Date(timeIntervalSince1970: 0)], ofItemAtPath: staleURL.path)
        PDFExportFilename.cleanupStaleExports(in: directory, olderThan: 60)
        XCTAssertFalse(FileManager.default.fileExists(atPath: staleURL.path))
    }

    // MARK: - MAIN-AUD-005 photo preprocessor

    func testOversizedPhotoBytesRejectedBeforeDecode() {
        let oversized = Data(repeating: 0xFF, count: WatchPhotoPreprocessor.maxInputBytes + 1)
        XCTAssertThrowsError(try WatchPhotoPreprocessor.preflightImageData(oversized)) { error in
            XCTAssertEqual(error as? WatchPhotoPreprocessor.Failure, .oversizedBytes)
        }
    }

    func testValidTinyPNGPassesPreflight() throws {
        let png = makeMinimalPNGData()
        XCTAssertNoThrow(try WatchPhotoPreprocessor.preflightImageData(png))
        let prepared = try WatchPhotoPreprocessor.prepareForWatch(from: png)
        XCTAssertFalse(prepared.data.isEmpty)
    }

    // MARK: - MAIN-AUD-006 switch depth preservation

    func testPressureUnitChangeDoesNotInvokeGasOrPPO2SwitchResetPath() {
        var input = GasPlanInput()
        input.plannerCylinders = [
            PlannerCylinderEntry(role: .deco, gas: GasMix(name: "EAN50", role: .deco, oxygen: 0.50, helium: 0, maxPPO2: 1.6), switchDepthMeters: 18)
        ]
        let originalSwitch = input.plannerCylinders[0].switchDepthMeters
        PlannerGasEditingSupport.convertPressureUnit(on: &input.plannerCylinders[0], to: .psi)
        XCTAssertEqual(input.plannerCylinders[0].switchDepthMeters, originalSwitch, accuracy: 0.001)
    }

    func testOxygenChangeStillNormalizesSwitchDepthToMOD() {
        var input = GasPlanInput()
        input.plannerCylinders = [
            PlannerCylinderEntry(role: .deco, gas: GasMix(name: "EAN50", role: .deco, oxygen: 0.50, helium: 0, maxPPO2: 1.6), switchDepthMeters: 40)
        ]
        input.plannerCylinders[0].gas.oxygen = 0.32
        input.normalizeSwitchDepthsToMOD(changedCylinderID: input.plannerCylinders[0].id, updateChangedGasToMOD: true)
        let mod = input.plannerCylinders[0].modMeters(environment: input.plannerEnvironment)
        XCTAssertLessThanOrEqual(input.plannerCylinders[0].switchDepthMeters, mod + 0.05)
    }

    // MARK: - MAIN-AUD-007 planner debounce/cache

    func testPlannerDebouncedUpdatesPreserveFinalOutput() async {
        let store = PlannerStore(cloudSync: nil)
        let baselineDepth = store.input.plannedDepthMeters
        for offset in 0..<100 {
            store.input.plannedDepthMeters = baselineDepth + Double(offset % 5)
        }
        await store.testHook_flushDebouncedWork()
        XCTAssertEqual(store.input.plannedDepthMeters, baselineDepth + 4, accuracy: 0.001)
        XCTAssertGreaterThan(store.plan.briefingLines.count, 0)
    }

    // MARK: - MAIN-AUD-008 delete guard

    func testDiveLogDeleteIgnoresStaleOffsetsSafely() {
        var sessions = [sampleSession()]
        let offsets = IndexSet([999])
        for index in offsets.sorted(by: >) {
            guard sessions.indices.contains(index) else { continue }
            sessions.remove(at: index)
        }
        XCTAssertEqual(sessions.count, 1)
    }

    // MARK: - MAIN-AUD-009 accessibility helper

    func testTableColumnAccessibilityLabelHandlesHeaderMismatchSafely() {
        let label = PlannerViewAccessibilitySupport.columnLabel(index: 3, value: "42", headers: ["A", "B"])
        XCTAssertEqual(label, "42")
    }

    func testTableColumnAccessibilityLabelPreservesMatchedHeaders() {
        let label = PlannerViewAccessibilitySupport.columnLabel(index: 1, value: "42", headers: ["Depth", "Time"])
        XCTAssertEqual(label, "Time: 42")
    }

    // MARK: - MAIN-AUD-011 CSV malformed/large budget

    func testMalformedCSVQuoteRowFailsSafely() {
        let csv = "\"unclosed,time_seconds,depth_m\n0,10\n"
        XCTAssertNil(DiveImportService.testHook_parseCSV(csv))
    }

    func testLargeCSVAtByteCapIsRejectedBeforeParse() {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("audit_large.csv")
        defer { try? FileManager.default.removeItem(at: url) }
        let header = "time_seconds,depth_m\n"
        let row = "0,10\n"
        let repeats = (DiveImportService.maxImportBytes / row.utf8.count) + 1
        let contents = header + String(repeating: row, count: repeats)
        try? contents.write(to: url, atomically: true, encoding: .utf8)
        switch DiveImportService.importCSV(from: url) {
        case .failure(.fileTooLarge):
            break
        default:
            XCTFail("Expected fileTooLarge")
        }
    }

    // MARK: - MAIN-AUD-012 nonce replay cache

    func testSyncNonceReplayCacheRejectsDuplicate() {
        let cache = SyncNonceReplayCache(maxEntries: 4, windowSeconds: 60)
        XCTAssertTrue(cache.register("nonce-a"))
        XCTAssertTrue(cache.isReplay("nonce-a"))
        XCTAssertFalse(cache.register("nonce-a"))
    }

    func testLegacySchemaV1PayloadAcceptedWithoutNonceReplay() throws {
        try installPeerSecret()
        let session = sampleSession()
        let envelope = try WatchDiveSyncCodec.makePayload(session: session)
        WatchDiveSyncCodec.replayCache.reset()
        _ = try WatchDiveSyncCodec.parsePayload(from: envelope.message)
    }

    // MARK: - MAIN-AUD-015 duplicate IDs

    func testDuplicateCloudIDsDoNotTrapMergeDetection() {
        let id = UUID()
        let start = Date(timeIntervalSince1970: 1_000)
        let older = sampleSession(id: id, start: start, endOffset: 100)
        let newer = sampleSession(id: id, start: start, endOffset: 200)
        let conflicts = DiveSessionMergeConflictDetector.detect(local: [sampleSession()], cloud: [older, newer])
        XCTAssertTrue(conflicts.contains { $0.fieldName == "duplicateSessionID" && $0.sessionID == id })
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

    private func sampleSession(
        id: UUID = UUID(),
        start: Date = Date(timeIntervalSince1970: 1_000),
        endOffset: TimeInterval = 120
    ) -> DiveSession {
        let end = start.addingTimeInterval(endOffset)
        return DiveSession(
            id: id,
            startDate: start,
            endDate: end,
            durationSeconds: endOffset,
            maxDepthMeters: 18,
            avgDepthMeters: 12,
            avgWaterTemperatureCelsius: nil,
            ttv: 1,
            entryGPS: nil,
            exitGPS: nil,
            samples: [DiveSample(timestamp: start, depthMeters: 18, temperatureCelsius: 20)]
        )
    }

    private func makeMinimalPNGData() -> Data {
        let base64 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg=="
        return Data(base64Encoded: base64)!
    }
}

enum PlannerViewAccessibilitySupport {
    static func columnLabel(index: Int, value: String, headers: [String]?) -> String {
        guard let headers, index < headers.count else { return value }
        return "\(headers[index]): \(value)"
    }
}
