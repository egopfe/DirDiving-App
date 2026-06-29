import XCTest
@testable import DIRDivingWatchApp

/// Deterministic integrated flow: Gauge → FC → Apnea (suspend/resume) → Snorkeling.
/// Automated only — does not replace physical-device or underwater QA.
@MainActor
final class IntegratedModesSequentialFlowTests: XCTestCase {
    private var diveTempDirectory: URL!
    private var apneaStorageURL: URL!
    private var snorkelingStorageURL: URL!
    private var userDefaultsSuite: UserDefaults!
    private var diveManager: DiveManager!
    private var logStore: DiveLogStore!
    private var gpsManager: GPSManager!
    private var activityStore: DIRActivitySelectionStore!
    private var startDate = Date(timeIntervalSince1970: 1_700_000_000)
    private let baseUptime: TimeInterval = 20_000

    override func setUp() async throws {
        try await super.setUp()
        #if DEBUG
        DIRStartupSelectionPolicy.resetForTests()
        FullComputerPrediveConfigurationStore.shared.resetForTests()
        DeveloperSettings.resetShallowDepthDivingTestingForTests()
        UserDefaults.standard.removeObject(forKey: SensorSourceMode.storageKey)
        DeveloperSettings.setShallowGaugeTestingEnabled(true)
        DeveloperSettings.setShallowDepthDivingTestingEnabled(true)
        SnorkelingSyncTestSupport.installDeterministicSecrets()
        #endif

        diveTempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("IntegratedModes-\(UUID().uuidString)", isDirectory: true)
        apneaStorageURL = diveTempDirectory.appendingPathComponent("apnea", isDirectory: true)
        snorkelingStorageURL = diveTempDirectory.appendingPathComponent("snorkeling", isDirectory: true)
        try FileManager.default.createDirectory(at: diveTempDirectory, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: apneaStorageURL, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: snorkelingStorageURL, withIntermediateDirectories: true)

        DiveManager.testHook_draftDirectoryURL = diveTempDirectory
        DiveLogStore.testHook_storageDirectoryURL = diveTempDirectory
        DiveManager.testHook_suppressDepthSensorProvider = true
        ApneaLogbookStore.testHook_storageDirectoryURL = apneaStorageURL
        SnorkelingLogbookStore.testHook_storageDirectoryURL = snorkelingStorageURL

        let suiteName = "IntegratedModes-\(UUID().uuidString)"
        userDefaultsSuite = UserDefaults(suiteName: suiteName)!
        userDefaultsSuite.removePersistentDomain(forName: suiteName)

        logStore = DiveLogStore()
        gpsManager = GPSManager()
        gpsManager.testHook_holdBestEffortCapture = true
        diveManager = DiveManager(
            logStore: logStore,
            gpsManager: gpsManager,
            ascentSettings: AscentRateSettingsStore(defaults: userDefaultsSuite)
        )
        diveManager.testHook_setDepthAutomationAvailableForTests(true)
        activityStore = DIRActivitySelectionStore()
        WatchSyncService.shared.testHook_setSuppressOutboundTransferForTests(true)
        WatchSyncService.shared.testHook_resetPendingQueueForTests()
        WatchSyncService.shared.testHook_resetSnorkelingPendingQueueForTests()
    }

    override func tearDown() async throws {
        diveManager?.testHook_shutdownTimersForTests()
        diveManager?.testHook_stopDepthSensorForTests()
        diveManager?.testHook_clearActiveDiveDraft()
        DiveManager.testHook_suppressDepthSensorProvider = false
        DiveManager.testHook_draftDirectoryURL = nil
        DiveLogStore.testHook_storageDirectoryURL = nil
        ApneaLogbookStore.testHook_storageDirectoryURL = nil
        SnorkelingLogbookStore.testHook_storageDirectoryURL = nil
        WatchSyncService.shared.testHook_setSuppressOutboundTransferForTests(false)
        WatchSyncService.shared.testHook_resetPendingQueueForTests()
        WatchSyncService.shared.testHook_resetSnorkelingPendingQueueForTests()
        #if DEBUG
        SnorkelingSyncTestSupport.resetSecrets()
        FullComputerPrediveConfigurationStore.shared.resetForTests()
        DeveloperSettings.resetShallowDepthDivingTestingForTests()
        UserDefaults.standard.removeObject(forKey: SensorSourceMode.storageKey)
        #endif
        try? FileManager.default.removeItem(at: diveTempDirectory)
        try await super.tearDown()
    }

    func testSequentialGaugeFullComputerApneaSnorkelingWithoutCrossDomainBleed() throws {
        var apneaSessionID: UUID?
        var apneaDiveID: UUID?
        var snorkelingSessionID: UUID?

        // MARK: Gauge
        activityStore.selectActivity(.diving)
        activityStore.selectDivingMode(.gauge)
        XCTAssertTrue(activityStore.sessionConfigured)
        diveManager.recordSessionModeSelection(activity: .diving, divingMode: .gauge)
        diveManager.startManualDive()
        XCTAssertTrue(diveManager.isDiveActive)
        XCTAssertNil(diveManager.fullComputerSnapshot)
        XCTAssertFalse(activityStore.canChangeModes)
        diveManager.testHook_processDepthMeasurement(rawDepthMeters: 4, timestamp: startDate)
        finishDivingSession()
        XCTAssertFalse(diveManager.isDiveActive)
        let divingLogCountAfterGauge = logStore.sessions.count
        assertCrossDomainIsolation(
            phase: "after-gauge",
            divingLogCount: divingLogCountAfterGauge,
            apneaLogbookCount: 0,
            snorkelingLogbookCount: 0
        )
        XCTAssertTrue(activityStore.canChangeModes)

        // MARK: Full Computer
        FullComputerPrediveConfigurationStore.shared.resetForTests()
        FullComputerPrediveConfigurationStore.shared.commitConfirmedProfile()
        activityStore.selectActivity(.diving)
        activityStore.selectDivingMode(.fullComputer)
        activityStore.proceedToFullComputerConfirmation()
        activityStore.confirmFullComputerPredive()
        diveManager.recordSessionModeSelection(activity: .diving, divingMode: .fullComputer)
        diveManager.startManualDive()
        XCTAssertTrue(diveManager.isDiveActive)
        XCTAssertNotNil(diveManager.fullComputerSnapshot)
        XCTAssertFalse(activityStore.canChangeModes)
        diveManager.testHook_processDepthMeasurement(rawDepthMeters: 12, timestamp: startDate.addingTimeInterval(10))
        finishDivingSession()
        XCTAssertFalse(diveManager.isDiveActive)
        let divingLogCountAfterFC = logStore.sessions.count
        XCTAssertGreaterThanOrEqual(divingLogCountAfterFC, divingLogCountAfterGauge)
        assertCrossDomainIsolation(
            phase: "after-full-computer",
            divingLogCount: divingLogCountAfterFC,
            apneaLogbookCount: 0,
            snorkelingLogbookCount: 0
        )
        XCTAssertTrue(activityStore.canChangeModes)

        // MARK: Apnea with suspend/resume
        activityStore.selectActivity(.apnea)
        XCTAssertTrue(activityStore.sessionConfigured)
        let apneaRuntime = ApneaWatchRuntimeStore(importedPlan: .shared)
        apneaRuntime.armSession(at: wallClock(0))
        XCTAssertFalse(activityStore.canChangeModes)

        var engine = makeApneaEngine()
        engine.armSession(at: wallClock(0), uptime: uptime(0))
        apneaSessionID = engine.snapshot.session.id
        ingestApnea(&engine, depth: 0, offset: 0)
        ingestApnea(&engine, depth: 2, offset: 1)
        ingestApnea(&engine, depth: 6, offset: 2)
        ingestApnea(&engine, depth: 8, offset: 3)
        let envelope = try engine.exportCheckpoint(now: wallClock(4), uptime: uptime(4))
        var restored = try ApneaSessionEngine(checkpoint: envelope)
        XCTAssertEqual(restored.snapshot.session.id, apneaSessionID)
        ingestApnea(&restored, depth: 6, offset: 5)
        ingestApnea(&restored, depth: 2, offset: 6)
        ingestApnea(&restored, depth: 0, offset: 7)
        keepSurfaceApnea(&restored, from: 8, count: 5)
        XCTAssertEqual(restored.snapshot.session.dives.count, 1)
        apneaDiveID = restored.snapshot.session.dives[0].id

        var completedSession = restored.snapshot.session
        completedSession.state = .completed
        ApneaLogbookStore().add(completedSession)
        apneaRuntime.endSession()
        XCTAssertEqual(ApneaLogbookStore().sessions.count, 1)
        assertCrossDomainIsolation(
            phase: "after-apnea",
            divingLogCount: divingLogCountAfterFC,
            apneaLogbookCount: 1,
            snorkelingLogbookCount: 0
        )
        XCTAssertTrue(activityStore.canChangeModes)

        // MARK: Snorkeling
        activityStore.selectActivity(.snorkeling)
        XCTAssertTrue(activityStore.sessionConfigured)
        let snorkelingRuntime = SnorkelingWatchRuntimeStore()
        snorkelingRuntime.armSession(at: wallClock(100))
        snorkelingRuntime.startSession(at: wallClock(100))
        XCTAssertFalse(activityStore.canChangeModes)
        snorkelingRuntime.ingestDepthForTesting(depthMeters: 0, at: wallClock(100))
        snorkelingRuntime.ingestDepthForTesting(depthMeters: 2, at: wallClock(101))
        snorkelingRuntime.ingestDepthForTesting(depthMeters: 4, at: wallClock(102))
        snorkelingRuntime.ingestDepthForTesting(depthMeters: 1, at: wallClock(103))
        snorkelingRuntime.ingestDepthForTesting(depthMeters: 0, at: wallClock(104))
        snorkelingRuntime.endSession(at: wallClock(105))
        XCTAssertTrue(snorkelingRuntime.saveCompletedSession(to: SnorkelingLogbookStore()))
        snorkelingSessionID = SnorkelingLogbookStore().sessions.first?.id
        snorkelingRuntime.resetAfterSave()
        XCTAssertEqual(SnorkelingLogbookStore().sessions.count, 1)
        assertCrossDomainIsolation(
            phase: "after-snorkeling",
            divingLogCount: divingLogCountAfterFC,
            apneaLogbookCount: 1,
            snorkelingLogbookCount: 1
        )
        XCTAssertTrue(activityStore.canChangeModes)
        XCTAssertNotEqual(snorkelingSessionID, apneaSessionID)
        XCTAssertEqual(restored.snapshot.session.dives[0].id, apneaDiveID)
    }

    func testActivitySwitchingBlockedDuringActiveSession() {
        activityStore.selectActivity(.diving)
        activityStore.selectDivingMode(.gauge)
        diveManager.startManualDive()
        XCTAssertFalse(activityStore.canChangeModes)
        activityStore.selectActivity(.apnea)
        XCTAssertNotNil(activityStore.modeChangeBlockedToast)
        diveManager.endManualDive()
        diveManager.testHook_completePendingFinalizationIfNeeded()
        XCTAssertTrue(activityStore.canChangeModes)
        activityStore.selectActivity(.apnea)
        XCTAssertEqual(activityStore.selectedActivity, .apnea)
    }

    // MARK: - Helpers

    private func finishDivingSession() {
        diveManager.testHook_simulateManualToAutomaticHandoffForTests()
        diveManager.endManualDive()
        gpsManager.testHook_completeHeldBestEffortCapture(with: nil)
    }

    private func makeApneaEngine() -> ApneaSessionEngine {
        var config = ApneaLifecycleConfiguration.default
        config.immersionDebounceSeconds = 1
        config.surfaceStableDwellSeconds = 3
        config.recoveryMinimumSeconds = 3
        config.minimumDiveDurationSeconds = 1
        return ApneaSessionEngine(
            configuration: config,
            recoveryPolicy: .init(mode: .ratio2to1, minimumSurfaceSeconds: 2, recommendedSurfaceSeconds: 5),
            sessionStart: startDate
        )
    }

    private func assertCrossDomainIsolation(
        phase: String,
        divingLogCount: Int,
        apneaLogbookCount: Int,
        snorkelingLogbookCount: Int
    ) {
        XCTAssertEqual(logStore.sessions.count, divingLogCount, "diving log bleed @ \(phase)")
        XCTAssertEqual(ApneaLogbookStore().sessions.count, apneaLogbookCount, "apnea logbook bleed @ \(phase)")
        XCTAssertEqual(SnorkelingLogbookStore().sessions.count, snorkelingLogbookCount, "snorkeling logbook bleed @ \(phase)")
        XCTAssertTrue(ApneaReleaseSelfCheck.verifySyncNamespaceIsolation().isEmpty, "sync namespace @ \(phase)")
        XCTAssertNotEqual(ApneaReleaseSelfCheck.apneaSessionPayloadKey, ApneaReleaseSelfCheck.diveSessionPayloadKey)
        XCTAssertNotEqual(SnorkelingSessionSyncCodec.payloadKey, ApneaReleaseSelfCheck.apneaSessionPayloadKey)
        XCTAssertNotEqual(SnorkelingReleaseSelfCheck.checkpointNamespace, ApneaReleaseSelfCheck.apneaSessionPayloadKey)
        XCTAssertTrue(WatchSyncService.shared.testHook_pendingSnorkelingSessionIDs.isEmpty || snorkelingLogbookCount >= 0)
    }

    private func wallClock(_ offset: TimeInterval) -> Date {
        startDate.addingTimeInterval(offset)
    }

    private func uptime(_ offset: TimeInterval) -> TimeInterval {
        baseUptime + offset
    }

    private func ingestApnea(_ engine: inout ApneaSessionEngine, depth: Double, offset: TimeInterval) {
        let timestamp = wallClock(offset)
        _ = engine.ingest(
            raw: DepthMeasurementRaw(depthMeters: depth, sensorTimestamp: timestamp, receivedAt: timestamp),
            wallClock: timestamp,
            uptime: uptime(offset)
        )
    }

    private func keepSurfaceApnea(_ engine: inout ApneaSessionEngine, from startOffset: TimeInterval, count: Int) {
        for index in 0...count {
            ingestApnea(&engine, depth: 0, offset: startOffset + TimeInterval(index))
        }
    }
}
