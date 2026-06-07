import XCTest

@MainActor
final class DiveManagerAlgorithmIntegrationTests: XCTestCase {
    private var diveManager: DiveManager!
    private var logStore: DiveLogStore!
    private var tempDirectory: URL!
    private var userDefaultsSuite: UserDefaults!

    override func setUp() async throws {
        try await super.setUp()
        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("DiveManagerAlgorithmIntegration-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)

        DiveManager.testHook_draftDirectoryURL = tempDirectory
        DiveLogStore.testHook_storageDirectoryURL = tempDirectory
        DiveManager.testHook_suppressDepthSensorProvider = true

        let suiteName = "DiveManagerAlgorithmIntegration-\(UUID().uuidString)"
        userDefaultsSuite = UserDefaults(suiteName: suiteName)!
        userDefaultsSuite.removePersistentDomain(forName: suiteName)

        logStore = DiveLogStore()
        diveManager = DiveManager(
            logStore: logStore,
            gpsManager: GPSManager(),
            ascentSettings: AscentRateSettingsStore(defaults: userDefaultsSuite)
        )
        diveManager.testHook_setDepthAutomationAvailableForTests(true)
    }

    override func tearDown() async throws {
        diveManager?.testHook_shutdownTimersForTests()
        diveManager?.testHook_stopDepthSensorForTests()
        diveManager?.testHook_clearActiveDiveDraft()
        DiveManager.testHook_suppressDepthSensorProvider = false
        DiveManager.testHook_draftDirectoryURL = nil
        DiveLogStore.testHook_storageDirectoryURL = nil
        if let tempDirectory {
            try? FileManager.default.removeItem(at: tempDirectory)
        }
        diveManager = nil
        logStore = nil
        try await super.tearDown()
    }

    func testAutoStartAddsTriggeringSampleOnce() {
        let start = Date()
        diveManager.testHook_processDepthMeasurement(rawDepthMeters: 1.1, timestamp: start)
        XCTAssertFalse(diveManager.isDiveActive)
        XCTAssertEqual(diveManager.testHook_sampleCount, 0)

        diveManager.testHook_processDepthMeasurement(rawDepthMeters: 1.2, timestamp: start.addingTimeInterval(1))
        XCTAssertTrue(diveManager.isDiveActive)
        XCTAssertEqual(diveManager.testHook_sampleCount, 1)
        XCTAssertNil(diveManager.testHook_lastErrorMessage)

        diveManager.testHook_processDepthMeasurement(rawDepthMeters: 1.3, timestamp: start.addingTimeInterval(2))
        XCTAssertEqual(diveManager.testHook_sampleCount, 2)
        XCTAssertNil(diveManager.testHook_lastErrorMessage)
    }

    func testManualStartThenSamplesAccumulate() {
        diveManager.startManualDive()
        XCTAssertTrue(diveManager.isDiveActive)
        XCTAssertEqual(diveManager.testHook_sampleCount, 0)

        let start = Date()
        diveManager.testHook_processDepthMeasurement(rawDepthMeters: 3, timestamp: start)
        diveManager.testHook_processDepthMeasurement(rawDepthMeters: 4, timestamp: start.addingTimeInterval(5))
        XCTAssertEqual(diveManager.testHook_sampleCount, 2)
    }

    func testFreshTemperatureAttachedToDepthSample() {
        let start = Date()
        diveManager.testHook_setCurrentTemperatureForTests(19.5, receivedAt: start)
        diveManager.startManualDive()
        diveManager.testHook_processDepthMeasurement(
            rawDepthMeters: 5,
            timestamp: start.addingTimeInterval(1),
            temperatureCelsius: nil
        )
        XCTAssertEqual(diveManager.testHook_sampleCount, 1)
        XCTAssertEqual(diveManager.testHook_samples.first?.temperatureCelsius, 19.5)
    }

    func testStaleTemperatureNotAttachedToDepthSample() {
        let start = Date()
        diveManager.testHook_setCurrentTemperatureForTests(19.5, receivedAt: start.addingTimeInterval(-60))
        diveManager.startManualDive()
        diveManager.testHook_processDepthMeasurement(
            rawDepthMeters: 5,
            timestamp: start,
            temperatureCelsius: nil
        )
        XCTAssertNil(diveManager.testHook_samples.first?.temperatureCelsius)
    }

    func testDepthCallbackSilenceMarksStaleDuringActiveDive() {
        let start = Date()
        diveManager.testHook_processDepthMeasurement(rawDepthMeters: 1.1, timestamp: start)
        diveManager.testHook_processDepthMeasurement(rawDepthMeters: 1.2, timestamp: start.addingTimeInterval(1))
        XCTAssertTrue(diveManager.isDiveActive)

        let lastSampleTime = start.addingTimeInterval(1)
        diveManager.testHook_evaluateDepthCallbackFreshness(
            at: lastSampleTime.addingTimeInterval(DiveAlgorithmConfiguration.activeDepthCallbackSilenceSeconds + 0.5)
        )
        XCTAssertTrue(diveManager.testHook_isDepthDataStale)
    }

    func testDepthSafetyStatesDuringManualDive() {
        diveManager.startManualDive()
        let start = Date()
        diveManager.testHook_processDepthMeasurement(rawDepthMeters: 34.9, timestamp: start)
        XCTAssertEqual(diveManager.depthSafetyState, .normal)

        diveManager.testHook_processDepthMeasurement(rawDepthMeters: 35, timestamp: start.addingTimeInterval(2))
        XCTAssertEqual(diveManager.depthSafetyState, .caution)

        diveManager.testHook_processDepthMeasurement(rawDepthMeters: 38, timestamp: start.addingTimeInterval(4))
        XCTAssertEqual(diveManager.depthSafetyState, .critical)

        diveManager.testHook_processDepthMeasurement(rawDepthMeters: 40, timestamp: start.addingTimeInterval(6))
        XCTAssertEqual(diveManager.depthSafetyState, .exceeded)
        XCTAssertTrue(diveManager.exceededSupportedDepthRange)
    }

    func testDescendingDepthYieldsZeroAscentRate() {
        diveManager.startManualDive()
        let start = Date()
        diveManager.testHook_processDepthMeasurement(rawDepthMeters: 10, timestamp: start)
        diveManager.testHook_processDepthMeasurement(rawDepthMeters: 12, timestamp: start.addingTimeInterval(10))
        XCTAssertEqual(diveManager.ascentStatus.currentRateMetersPerMinute, 0, accuracy: 0.001)
        XCTAssertFalse(diveManager.ascentStatus.isOverLimit)
    }

    func testFastAscentProducesRedZone() {
        diveManager.startManualDive()
        let start = Date()
        diveManager.testHook_processDepthMeasurement(rawDepthMeters: 20, timestamp: start)
        diveManager.testHook_processDepthMeasurement(rawDepthMeters: 10, timestamp: start.addingTimeInterval(10))
        XCTAssertEqual(diveManager.ascentStatus.zone, .red)
        XCTAssertTrue(diveManager.ascentStatus.isOverLimit)
    }

    func testMissionModeActiveStillAppendsSamples() {
        let start = Date()
        diveManager.testHook_processDepthMeasurement(rawDepthMeters: 1.1, timestamp: start)
        diveManager.testHook_processDepthMeasurement(rawDepthMeters: 1.2, timestamp: start.addingTimeInterval(1))
        diveManager.enableMissionModeManually()
        XCTAssertTrue(diveManager.isMissionModeActive)
        diveManager.testHook_processDepthMeasurement(rawDepthMeters: 1.4, timestamp: start.addingTimeInterval(3))
        XCTAssertEqual(diveManager.testHook_sampleCount, 2)
        XCTAssertEqual(diveManager.maxDepthMeters, 1.4, accuracy: 0.001)
    }
}
