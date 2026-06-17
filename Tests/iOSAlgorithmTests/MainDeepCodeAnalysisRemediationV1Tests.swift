import XCTest

@MainActor
final class MainDeepCodeAnalysisRemediationV1Tests: XCTestCase {
    override func setUp() async throws {
        try await super.setUp()
        WatchDiveSyncCodec.replayCache.reset()
        WatchSyncAuth.resetPeerTrust()
    }

    // MARK: - MAIN-DCA-011 metadata-preserving Watch import merge

    func testMetadataOnlyWatchImportPreservesIOSNotes() {
        let id = UUID()
        let start = Date(timeIntervalSince1970: 2_000)
        let end = start.addingTimeInterval(600)
        let sample = DiveSample(timestamp: start, depthMeters: 10, temperatureCelsius: 20)
        var local = makeSession(id: id, start: start, end: end, samples: [sample], notes: "Edited on iPhone")
        var incoming = makeSession(id: id, start: start, end: end, samples: [sample], notes: nil)
        incoming.siteName = nil
        incoming.buddy = nil

        let merged = DiveSessionMerge.preferred(local, incoming)
        XCTAssertEqual(merged.notes, "Edited on iPhone")
        XCTAssertNil(incoming.notes)
    }

    func testMetadataOnlyWatchImportPreservesSiteBuddyEquipment() {
        let id = UUID()
        let start = Date(timeIntervalSince1970: 2_100)
        let end = start.addingTimeInterval(300)
        let sample = DiveSample(timestamp: start, depthMeters: 12, temperatureCelsius: 19)
        let local = makeSession(
            id: id,
            start: start,
            end: end,
            samples: [sample],
            siteName: "Blue Hole",
            buddy: "Alex",
            equipmentUsed: "Twinset"
        )
        let incoming = makeSession(id: id, start: start, end: end, samples: [sample])

        let merged = DiveSessionMerge.preferred(local, incoming)
        XCTAssertEqual(merged.siteName, "Blue Hole")
        XCTAssertEqual(merged.buddy, "Alex")
        XCTAssertEqual(merged.equipmentUsed, "Twinset")
    }

    func testSameProfileWithoutSignificantDiffDoesNotDropGasLabelOnNewerIOS() {
        let id = UUID()
        let start = Date(timeIntervalSince1970: 2_200)
        let end = start.addingTimeInterval(400)
        let laterEnd = end.addingTimeInterval(5)
        let sample = DiveSample(timestamp: start, depthMeters: 18, temperatureCelsius: 18)
        var local = makeSession(id: id, start: start, end: laterEnd, samples: [sample])
        local.gasLabel = .trimix
        var incoming = makeSession(id: id, start: start, end: end, samples: [sample])
        incoming.gasLabel = .oc

        let merged = DiveSessionMerge.preferred(local, incoming)
        XCTAssertEqual(merged.gasLabel, .trimix)
    }

    func testWatchSyncSessionDiffIgnoresMetadataOnlyChanges() {
        let id = UUID()
        let start = Date(timeIntervalSince1970: 2_300)
        let end = start.addingTimeInterval(500)
        let sample = DiveSample(timestamp: start, depthMeters: 20, temperatureCelsius: 17)
        var local = makeSession(id: id, start: start, end: end, samples: [sample], notes: "Keep me")
        var incoming = makeSession(id: id, start: start, end: end, samples: [sample], notes: nil)
        incoming.siteName = "Should not overwrite via diff gate alone"

        XCTAssertFalse(WatchSyncSessionDiff.hasSignificantDifference(local: local, incoming: incoming))
    }

    // MARK: - MAIN-DCA-025 aggregate KVS budget

    func testAggregateBudgetRejectsMultipleSmallKeysAboveLimit() {
        let perKey = CloudSyncBudgetPolicy.maxPerKeyBytes / 4
        let chunk = Data(repeating: 0xAB, count: perKey)
        let footprints = (0..<7).map {
            CloudSyncBudgetPolicy.KeyFootprint(
                key: "key-\($0)",
                dataBytes: perKey,
                modifiedAtBytes: MemoryLayout<TimeInterval>.size
            )
        }
        let decision = CloudSyncBudgetPolicy.evaluateWrite(
            key: "key-new",
            newData: chunk,
            existingFootprints: footprints
        )
        if case .aggregateExceeded = decision {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected aggregateExceeded, got \(decision)")
        }
    }

    func testAggregateBudgetAllowsSingleKeyBelowLimit() {
        let data = Data(repeating: 0x01, count: 1024)
        let decision = CloudSyncBudgetPolicy.evaluateWrite(key: "solo", newData: data, existingFootprints: [])
        XCTAssertEqual(decision, .allowed)
    }

    // MARK: - MAIN-DCA-026 cloud success timestamp ordering

    func testCloudSyncDoesNotMarkSuccessAtRequestTime() {
        let suite = "MainDCA026.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let store = CloudSyncStore(defaults: defaults)
        store.synchronize()
        XCTAssertNil(store.lastSuccessfulSyncDate)
        XCTAssertFalse(store.isSynchronizing)
    }

    // MARK: - MAIN-DCA-024 CCR bailout MOD tolerance

    func testCCRBailoutMODToleranceIsIntentionallyLooserThanOC() {
        XCTAssertGreaterThan(
            CCRMODTolerancePolicy.ccrBailoutSwitchDepthSlackMeters,
            CCRMODTolerancePolicy.openCircuitSwitchDepthSlackMeters
        )
        XCTAssertTrue(
            CCRMODTolerancePolicy.isBailoutSwitchDepthWithinMOD(
                switchDepthMeters: 30.4,
                modMeters: 30.0
            )
        )
    }

    // MARK: - MAIN-DCA-027 legacy sync v1 policy

    func testLegacyV1ProtectedOperationsRejected() {
        XCTAssertTrue(
            WatchSyncSchemaV1Policy.rejectsProtectedOperationOverLegacySchema(.photoDelete, payloadVersion: 1)
        )
        XCTAssertFalse(
            WatchSyncSchemaV1Policy.rejectsProtectedOperationOverLegacySchema(.photoDelete, payloadVersion: 2)
        )
    }

    func testLegacyV1UsageCounterIncrements() {
        let key = "dirdiving_ios_sync_v1_usage_count"
        UserDefaults.standard.removeObject(forKey: key)
        WatchSyncSchemaV1Policy.recordLegacyUsage()
        XCTAssertEqual(WatchSyncSchemaV1Policy.legacyUsageCount, 1)
    }

    // MARK: - MAIN-DCA-030 tissue axis localization key exists

    func testTissueAnalyticsTimeAxisLocalizationKeyExists() {
        XCTAssertFalse(DIRIOSLocalizer.string("tissue_analytics.axis.time").isEmpty)
        XCTAssertNotEqual(DIRIOSLocalizer.string("tissue_analytics.axis.time"), "tissue_analytics.axis.time")
    }

    private func makeSession(
        id: UUID = UUID(),
        start: Date,
        end: Date,
        samples: [DiveSample],
        notes: String? = nil,
        siteName: String? = nil,
        buddy: String? = nil,
        equipmentUsed: String? = nil
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
            siteName: siteName,
            buddy: buddy,
            notes: notes,
            equipmentUsed: equipmentUsed
        )
    }
}
