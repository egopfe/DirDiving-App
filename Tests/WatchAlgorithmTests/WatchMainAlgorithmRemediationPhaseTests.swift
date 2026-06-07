import XCTest

@MainActor
final class WatchMainAlgorithmRemediationPhaseTests: XCTestCase {
    private var tempDirectory: URL!

    override func setUp() async throws {
        try await super.setUp()
        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("WatchRemediationPhase-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        DiveManager.testHook_draftDirectoryURL = tempDirectory
        DiveLogStore.testHook_storageDirectoryURL = tempDirectory.appendingPathComponent("logs", isDirectory: true)
        DiveManager.testHook_suppressDepthSensorProvider = true
    }

    override func tearDown() async throws {
        DiveManager.testHook_suppressDepthSensorProvider = false
        DiveManager.testHook_draftDirectoryURL = nil
        DiveLogStore.testHook_storageDirectoryURL = nil
        UserDefaults.standard.removeObject(forKey: HapticService.hapticsEnabledKey)
        try? FileManager.default.removeItem(at: tempDirectory)
        try await super.tearDown()
    }

    func testLegacyDraftWithoutSchemaVersionIsDiscarded() {
        let legacy: [String: Any] = [
            "phase": "active",
            "sessionID": UUID().uuidString,
            "startDate": ISO8601DateFormatter().string(from: Date()),
            "samples": [] as [Any],
            "entryGPSFixSource": "noFix",
            "isManualLifecycleActive": true,
            "sessionStartedManually": true,
            "activeDiveExceededSupportedDepth": false,
            "hasObservedSubmersionDuringCurrentDive": false,
            "createdAt": ISO8601DateFormatter().string(from: Date()),
            "updatedAt": ISO8601DateFormatter().string(from: Date())
        ]
        let data = try! JSONSerialization.data(withJSONObject: legacy)
        let url = tempDirectory.appendingPathComponent("dirdiving_active_dive_draft.json")
        try! data.write(to: url)

        let manager = DiveManager(
            logStore: DiveLogStore(),
            gpsManager: GPSManager(),
            ascentSettings: AscentRateSettingsStore(defaults: UserDefaults(suiteName: "WatchRemediationPhase-\(UUID().uuidString)")!)
        )
        XCTAssertFalse(manager.isDiveActive)
        XCTAssertFalse(manager.testHook_hasActiveDiveDraftOnDisk)
    }

    func testFinalizingDraftMissingEndDateSetsDiagnostic() {
        struct Draft: Codable {
            let schemaVersion: Int
            let phase: String
            let sessionID: UUID
            let startDate: Date
            let endDate: Date?
            let samples: [DiveSample]
            let entryGPSFixSource: GPSFixSource
            let exitGPSFixSource: GPSFixSource
            let isManualLifecycleActive: Bool
            let sessionStartedManually: Bool
            let activeDiveExceededSupportedDepth: Bool
            let hasObservedSubmersionDuringCurrentDive: Bool
            let createdAt: Date
            let updatedAt: Date
        }
        let draft = Draft(
            schemaVersion: 1,
            phase: "finalizing",
            sessionID: UUID(),
            startDate: Date(),
            endDate: nil,
            samples: [],
            entryGPSFixSource: .noFix,
            exitGPSFixSource: .noFix,
            isManualLifecycleActive: false,
            sessionStartedManually: true,
            activeDiveExceededSupportedDepth: false,
            hasObservedSubmersionDuringCurrentDive: false,
            createdAt: Date(),
            updatedAt: Date()
        )
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try! encoder.encode(draft)
        try! data.write(to: tempDirectory.appendingPathComponent("dirdiving_active_dive_draft.json"))

        let logStore = DiveLogStore()
        let manager = DiveManager(
            logStore: logStore,
            gpsManager: GPSManager(),
            ascentSettings: AscentRateSettingsStore(defaults: UserDefaults(suiteName: "WatchRemediationPhase-\(UUID().uuidString)")!)
        )
        XCTAssertFalse(manager.isDiveActive)
        XCTAssertNotNil(manager.draftRecoveryDiagnostic)
        XCTAssertEqual(logStore.sessions.count, 0)
    }

    func testMockSurfaceFrozenSampleExemptionDuringActiveDive() {
        var state = DepthSampleValidationState()
        let start = Date()
        var last: ValidatedDepthSample?
        for offset in 0...35 {
            last = state.validate(
                rawDepthMeters: 0,
                timestamp: start.addingTimeInterval(Double(offset)),
                receivedAt: start.addingTimeInterval(Double(offset)),
                temperatureCelsius: nil,
                isDiveActive: true,
                exemptMockSurfaceFrozenSamples: true
            )
        }
        XCTAssertEqual(last?.validity, .valid)
    }

    func testRealActiveFrozenSampleStillRejected() {
        var state = DepthSampleValidationState()
        let start = Date()
        _ = state.validate(rawDepthMeters: 10, timestamp: start, receivedAt: start, temperatureCelsius: nil, isDiveActive: true)
        let frozen = state.validate(
            rawDepthMeters: 10,
            timestamp: start.addingTimeInterval(35),
            receivedAt: start.addingTimeInterval(35),
            temperatureCelsius: nil,
            isDiveActive: true,
            exemptMockSurfaceFrozenSamples: false
        )
        XCTAssertEqual(frozen.validity, .frozen)
    }

    func testGPSStopClearsMaintainsLocationUpdatesFlag() {
        let manager = GPSManager()
        manager.start()
        manager.stop()
        XCTAssertFalse(manager.maintainsLocationUpdates)
    }

    func testImportedCompanionIDRetentionUses512Cap() {
        XCTAssertEqual(WatchDiveSyncCodec.importedCompanionIDRetentionLimit, 512)
        let ids = (0..<600).map { _ in UUID() }
        WatchDiveSyncCodec.saveImportedFromCompanionIDs(Set(ids))
        let loaded = WatchDiveSyncCodec.loadImportedFromCompanionIDs()
        XCTAssertEqual(loaded.count, 512)
    }

    func testDepthLimitHapticsRefreshAfterPreferenceDisable() {
        let coordinator = DepthLimitHapticCoordinator()
        UserDefaults.standard.set(true, forKey: HapticService.hapticsEnabledKey)
        coordinator.handle(depthMeters: 38, hapticsEnabled: true)
        let generationBefore = coordinator.testHook_transitionGeneration
        UserDefaults.standard.set(false, forKey: HapticService.hapticsEnabledKey)
        coordinator.refreshAfterPreferenceChange(currentDepthMeters: 38)
        XCTAssertGreaterThan(coordinator.testHook_transitionGeneration, generationBefore)
        UserDefaults.standard.removeObject(forKey: HapticService.hapticsEnabledKey)
    }
}
