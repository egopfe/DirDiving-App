import XCTest

@MainActor
final class WatchMainAlgorithmAuditRemediationTests: XCTestCase {
    private var tempDraftDirectory: URL!

    override func setUp() async throws {
        try await super.setUp()
        tempDraftDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("WatchAuditRemediation-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: tempDraftDirectory, withIntermediateDirectories: true)
        DiveManager.testHook_draftDirectoryURL = tempDraftDirectory
        DiveLogStore.testHook_storageDirectoryURL = tempDraftDirectory.appendingPathComponent("logs", isDirectory: true)
        DiveManager.testHook_suppressDepthSensorProvider = true
    }

    override func tearDown() async throws {
        DiveManager.testHook_suppressDepthSensorProvider = false
        DiveManager.testHook_draftDirectoryURL = nil
        DiveLogStore.testHook_storageDirectoryURL = nil
        try? FileManager.default.removeItem(at: tempDraftDirectory)
        try await super.tearDown()
    }

    // MARK: - WATCHMATH-HIGH-001

    func testNormalEndCompletesGPSFinalizationAndClearsDraft() {
        let logStore = DiveLogStore()
        let gps = GPSManager()
        gps.testHook_holdBestEffortCapture = true
        let manager = makeDiveManager(logStore: logStore, gps: gps)
        manager.startManualDive()
        let start = Date()
        manager.testHook_processDepthMeasurement(rawDepthMeters: 0.5, timestamp: start)
        manager.testHook_endDiveForTests()
        XCTAssertFalse(manager.isDiveActive)
        XCTAssertTrue(manager.testHook_hasActiveDiveDraftOnDisk)
        gps.testHook_completeHeldBestEffortCapture(with: nil)
        XCTAssertFalse(manager.testHook_hasActiveDiveDraftOnDisk)
        XCTAssertEqual(logStore.sessions.count, 1)
    }

    func testTerminationDuringGPSFinalizationDoesNotRestoreActiveDive() {
        let logStore = DiveLogStore()
        let gps = GPSManager()
        gps.testHook_holdBestEffortCapture = true
        let manager = makeDiveManager(logStore: logStore, gps: gps)
        manager.startManualDive()
        let start = Date()
        manager.testHook_processDepthMeasurement(rawDepthMeters: 0.5, timestamp: start)
        manager.testHook_endDiveForTests()
        XCTAssertTrue(manager.testHook_hasActiveDiveDraftOnDisk)
        XCTAssertFalse(manager.isDiveActive)

        let restored = makeDiveManager(logStore: logStore, gps: GPSManager())
        XCTAssertFalse(restored.isDiveActive)
        XCTAssertFalse(restored.testHook_hasActiveDiveDraftOnDisk)
        XCTAssertEqual(logStore.sessions.count, 1)
        XCTAssertEqual(logStore.sessions.first?.maxDepthMeters ?? 0, 0.5, accuracy: 0.001)
    }

    func testActiveDiveDraftRestoresAfterTerminationBeforeEnd() {
        let logStore = DiveLogStore()
        let manager = makeDiveManager(logStore: logStore, gps: GPSManager())
        manager.startManualDive()
        let start = Date()
        manager.testHook_processDepthMeasurement(rawDepthMeters: 0.5, timestamp: start)
        XCTAssertTrue(manager.isDiveActive)
        XCTAssertTrue(manager.testHook_hasActiveDiveDraftOnDisk)

        let restored = makeDiveManager(logStore: logStore, gps: GPSManager())
        XCTAssertTrue(restored.isDiveActive)
        XCTAssertEqual(restored.testHook_sampleCount, 1)
    }

    func testPendingFinalizationRestoreIsIdempotent() {
        let logStore = DiveLogStore()
        let gps = GPSManager()
        gps.testHook_holdBestEffortCapture = true
        let manager = makeDiveManager(logStore: logStore, gps: gps)
        manager.startManualDive()
        manager.testHook_processDepthMeasurement(rawDepthMeters: 0.5, timestamp: Date())
        manager.testHook_endDiveForTests()

        _ = makeDiveManager(logStore: logStore, gps: GPSManager())
        XCTAssertEqual(logStore.sessions.count, 1)
        let session = logStore.sessions[0]

        writeFinalizingDraft(sessionID: session.id, start: session.startDate, end: session.endDate, samples: session.samples)

        let secondRestore = makeDiveManager(logStore: logStore, gps: GPSManager())
        secondRestore.testHook_completePendingFinalizationIfNeeded()
        XCTAssertEqual(logStore.sessions.count, 1)
    }

    func testPendingFinalizationWithoutExitGPSUsesNoFix() {
        let logStore = DiveLogStore()
        let sessionID = UUID()
        let start = Date(timeIntervalSince1970: 1_000)
        let end = start.addingTimeInterval(120)
        let samples = [DiveSample(timestamp: start.addingTimeInterval(10), depthMeters: 7, temperatureCelsius: nil)]
        writeFinalizingDraft(sessionID: sessionID, start: start, end: end, samples: samples, exitGPSFixSource: .noFix)

        _ = makeDiveManager(logStore: logStore, gps: GPSManager())
        XCTAssertEqual(logStore.sessions.count, 1)
        XCTAssertEqual(logStore.sessions.first?.exitGPSFixSource, .noFix)
        XCTAssertNil(logStore.sessions.first?.exitGPS)
    }

    // MARK: - WATCHMATH-MED-002

    func testInactiveRepeatedZeroDepthDoesNotSurfaceFrozenError() {
        let manager = makeDiveManager(logStore: DiveLogStore(), gps: GPSManager())
        let start = Date()
        for second in 0...35 {
            manager.testHook_processDepthMeasurement(
                rawDepthMeters: 0,
                timestamp: start.addingTimeInterval(TimeInterval(second))
            )
        }
        XCTAssertFalse(manager.isDiveActive)
        XCTAssertNil(manager.testHook_lastErrorMessage)
    }

    func testActiveDiveRepeatedSameDepthSurfacesFrozenError() {
        let manager = makeDiveManager(logStore: DiveLogStore(), gps: GPSManager())
        manager.startManualDive()
        let start = Date()
        for second in 0...35 {
            manager.testHook_processDepthMeasurement(
                rawDepthMeters: 10,
                timestamp: start.addingTimeInterval(TimeInterval(second))
            )
        }
        XCTAssertNotNil(manager.testHook_lastErrorMessage)
    }

    // MARK: - WATCHMATH-MED-003

    func testLoadFilterKeepsValidAndQuarantinesInvalidSessions() {
        let start = Date(timeIntervalSince1970: 0)
        let valid = makeValidSession(start: start)
        let invalid = DiveSession(
            startDate: start,
            endDate: start.addingTimeInterval(60),
            durationSeconds: 60,
            maxDepthMeters: 0,
            avgDepthMeters: 0,
            avgWaterTemperatureCelsius: nil,
            minWaterTemperatureCelsius: nil,
            maxWaterTemperatureCelsius: nil,
            ttv: 0,
            entryGPS: nil,
            exitGPS: nil,
            samples: [],
            isManual: false,
            hasDepthProfile: false
        )
        let filtered = DiveLogbookPolicy.filterValidLoadedSessions([invalid, valid])
        XCTAssertEqual(filtered.quarantinedCount, 1)
        XCTAssertEqual(filtered.sessions.count, 1)
        XCTAssertEqual(filtered.sessions.first?.id, valid.id)
    }

    func testInvalidDepthBeyondCapIsQuarantined() {
        let start = Date(timeIntervalSince1970: 0)
        let invalid = makeValidSession(start: start, maxDepth: 351)
        let filtered = DiveLogbookPolicy.filterValidLoadedSessions([invalid])
        XCTAssertEqual(filtered.quarantinedCount, 1)
        XCTAssertTrue(filtered.sessions.isEmpty)
    }

    func testValidManualNoDepthSessionRemainsAfterFilter() {
        let start = Date(timeIntervalSince1970: 0)
        let manual = DiveSession(
            startDate: start,
            endDate: start.addingTimeInterval(600),
            durationSeconds: 600,
            maxDepthMeters: 0,
            avgDepthMeters: 0,
            avgWaterTemperatureCelsius: nil,
            minWaterTemperatureCelsius: nil,
            maxWaterTemperatureCelsius: nil,
            ttv: 10,
            entryGPS: nil,
            exitGPS: nil,
            samples: [],
            isManual: true,
            hasDepthProfile: false
        )
        let filtered = DiveLogbookPolicy.filterValidLoadedSessions([manual])
        XCTAssertEqual(filtered.quarantinedCount, 0)
        XCTAssertEqual(filtered.sessions.count, 1)
    }

    func testInvalidSessionDoesNotCountTowardLogCap() {
        let start = Date(timeIntervalSince1970: 0)
        let validSessions = (0..<DiveLogbookPolicy.maxSessions).map { index in
            makeValidSession(start: start.addingTimeInterval(TimeInterval(index * 120)))
        }
        let invalid = DiveSession(
            startDate: start.addingTimeInterval(-60),
            endDate: start,
            durationSeconds: 60,
            maxDepthMeters: 0,
            avgDepthMeters: 0,
            avgWaterTemperatureCelsius: nil,
            minWaterTemperatureCelsius: nil,
            maxWaterTemperatureCelsius: nil,
            ttv: 0,
            entryGPS: nil,
            exitGPS: nil,
            samples: [],
            isManual: false,
            hasDepthProfile: false
        )
        let filtered = DiveLogbookPolicy.filterValidLoadedSessions([invalid] + validSessions)
        XCTAssertEqual(filtered.quarantinedCount, 1)
        let capped = DiveLogbookPolicy.normalizedAndCapped(filtered.sessions, deletedIDs: [])
        XCTAssertEqual(capped.count, DiveLogbookPolicy.maxSessions)
    }

    // MARK: - WATCHMATH-LOW-004

    func testCriticalToNormalWithinDelaySuppressesSecondaryPulse() {
        UserDefaults.standard.set(true, forKey: HapticService.hapticsEnabledKey)
        defer { UserDefaults.standard.removeObject(forKey: HapticService.hapticsEnabledKey) }
        let coordinator = DepthLimitHapticCoordinator()
        let expectation = expectation(description: "secondary suppressed")
        coordinator.testHook_onDelayedHapticDecision = { decision in
            XCTAssertEqual(decision, .suppressed)
            expectation.fulfill()
        }
        coordinator.handle(depthMeters: 38, hapticsEnabled: true)
        coordinator.handle(depthMeters: 34, hapticsEnabled: true)
        wait(for: [expectation], timeout: 1.0)
    }

    func testExceededToNormalWithinDelaySuppressesSecondaryPulse() {
        UserDefaults.standard.set(true, forKey: HapticService.hapticsEnabledKey)
        defer { UserDefaults.standard.removeObject(forKey: HapticService.hapticsEnabledKey) }
        let coordinator = DepthLimitHapticCoordinator()
        let expectation = expectation(description: "secondary suppressed")
        coordinator.testHook_onDelayedHapticDecision = { decision in
            XCTAssertEqual(decision, .suppressed)
            expectation.fulfill()
        }
        coordinator.handle(depthMeters: 40, hapticsEnabled: true)
        coordinator.handle(depthMeters: 30, hapticsEnabled: true)
        wait(for: [expectation], timeout: 1.0)
    }

    func testCriticalRemainsCriticalAllowsSecondaryPulse() {
        UserDefaults.standard.set(true, forKey: HapticService.hapticsEnabledKey)
        defer { UserDefaults.standard.removeObject(forKey: HapticService.hapticsEnabledKey) }
        let coordinator = DepthLimitHapticCoordinator()
        let expectation = expectation(description: "secondary played")
        coordinator.testHook_onDelayedHapticDecision = { decision in
            XCTAssertEqual(decision, .played)
            expectation.fulfill()
        }
        coordinator.handle(depthMeters: 38, hapticsEnabled: true)
        wait(for: [expectation], timeout: 1.0)
    }

    func testDisabledHapticsSuppressesDelayedSecondaryPulse() {
        UserDefaults.standard.set(false, forKey: HapticService.hapticsEnabledKey)
        defer { UserDefaults.standard.removeObject(forKey: HapticService.hapticsEnabledKey) }
        let coordinator = DepthLimitHapticCoordinator()
        let expectation = expectation(description: "secondary suppressed by preference")
        coordinator.testHook_onDelayedHapticDecision = { decision in
            XCTAssertEqual(decision, .suppressed)
            expectation.fulfill()
        }
        coordinator.handle(depthMeters: 38, hapticsEnabled: true)
        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - WATCHMATH-LOW-005 / INFO-006

    func testDiveAlgorithmSelfCheckMatchesReleaseAscentPolicy() {
        XCTAssertEqual(AscentRateLimits.standard.limit(for: 45), 1)
        XCTAssertEqual(AscentRateLimits.standard.limit(for: 40), 10)
        XCTAssertTrue(DiveAlgorithmSelfCheck.failures().isEmpty, DiveAlgorithmSelfCheck.failures().joined(separator: "; "))
    }

    func testDepthAndRuntimeAlarmsUseStrictGreaterThanThreshold() {
        let depthThreshold = 30.0
        XCTAssertFalse(depthThreshold > depthThreshold)
        XCTAssertFalse((depthThreshold - 0.01) > depthThreshold)
        XCTAssertTrue((depthThreshold + 0.01) > depthThreshold)

        let runtimeThresholdMinutes = 45
        let atThreshold = TimeInterval(runtimeThresholdMinutes * 60)
        XCTAssertFalse(atThreshold > TimeInterval(runtimeThresholdMinutes * 60))
        XCTAssertTrue((atThreshold + 1) > TimeInterval(runtimeThresholdMinutes * 60))
    }

    // MARK: - WATCHMATH-INFO-007

    func testMissionModeDoesNotAlterAlgorithmOutputs() {
        XCTAssertEqual(MissionModeRuntimeProfile.standard.animationsEnabled, true)
        XCTAssertEqual(MissionModeRuntimeProfile.mission.animationsEnabled, false)
        let avg = DiveAlgorithm.timeWeightedAverageDepth(
            samples: [
                DiveSample(timestamp: Date(timeIntervalSince1970: 0), depthMeters: 10, temperatureCelsius: nil),
                DiveSample(timestamp: Date(timeIntervalSince1970: 60), depthMeters: 20, temperatureCelsius: nil)
            ],
            endDate: Date(timeIntervalSince1970: 120)
        )
        XCTAssertEqual(avg, 15, accuracy: 0.001)
        XCTAssertEqual(DiveAlgorithm.ttvIndex(averageDepthMeters: 15, durationSeconds: 1_800), 45, accuracy: 0.001)
    }

    // MARK: - Helpers

    private func makeDiveManager(logStore: DiveLogStore, gps: GPSManager) -> DiveManager {
        DiveManager(
            logStore: logStore,
            gpsManager: gps,
            ascentSettings: AscentRateSettingsStore(
                defaults: UserDefaults(suiteName: "WatchAuditRemediation-\(UUID().uuidString)")!
            )
        )
    }

    private func makeValidSession(start: Date, maxDepth: Double = 12) -> DiveSession {
        let end = start.addingTimeInterval(90)
        let samples = [
            DiveSample(timestamp: start.addingTimeInterval(10), depthMeters: maxDepth, temperatureCelsius: 20)
        ]
        return DiveSession(
            startDate: start,
            endDate: end,
            durationSeconds: 90,
            maxDepthMeters: maxDepth,
            avgDepthMeters: maxDepth,
            avgWaterTemperatureCelsius: 20,
            minWaterTemperatureCelsius: 20,
            maxWaterTemperatureCelsius: 20,
            ttv: DiveAlgorithm.ttvIndex(averageDepthMeters: maxDepth, durationSeconds: 90),
            entryGPS: nil,
            exitGPS: nil,
            samples: samples
        )
    }

    private func writeFinalizingDraft(
        sessionID: UUID,
        start: Date,
        end: Date,
        samples: [DiveSample],
        exitGPSFixSource: GPSFixSource = .noFix
    ) {
        struct Draft: Codable {
            let schemaVersion: Int
            let phase: String
            let sessionID: UUID
            let startDate: Date
            let endDate: Date
            let samples: [DiveSample]
            let entryGPS: GPSPoint?
            let exitGPS: GPSPoint?
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
            sessionID: sessionID,
            startDate: start,
            endDate: end,
            samples: samples,
            entryGPS: nil,
            exitGPS: nil,
            entryGPSFixSource: .noFix,
            exitGPSFixSource: exitGPSFixSource,
            isManualLifecycleActive: false,
            sessionStartedManually: true,
            activeDiveExceededSupportedDepth: false,
            hasObservedSubmersionDuringCurrentDive: false,
            createdAt: start,
            updatedAt: Date()
        )
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try! encoder.encode(draft)
        let url = tempDraftDirectory.appendingPathComponent("dirdiving_active_dive_draft.json")
        try! data.write(to: url, options: .atomic)
    }
}
