import XCTest

@MainActor
final class DiveReminderIntegrationTests: XCTestCase {
    private var diveManager: DiveManager!
    private var userDefaultsSuite: UserDefaults!

    override func setUp() async throws {
        try await super.setUp()
        DiveManager.testHook_suppressDepthSensorProvider = true
        let suiteName = "DiveReminderIntegration-\(UUID().uuidString)"
        userDefaultsSuite = UserDefaults(suiteName: suiteName)!
        userDefaultsSuite.removePersistentDomain(forName: suiteName)
        DiveReminderSettingsStore.testHook_defaults = userDefaultsSuite
        diveManager = DiveManager(
            logStore: DiveLogStore(),
            gpsManager: GPSManager(),
            ascentSettings: AscentRateSettingsStore(defaults: userDefaultsSuite)
        )
        diveManager.testHook_setDepthAutomationAvailableForTests(true)
    }

    override func tearDown() async throws {
        diveManager?.testHook_shutdownTimersForTests()
        DiveReminderSettingsStore.testHook_defaults = nil
        DiveManager.testHook_suppressDepthSensorProvider = false
        diveManager = nil
        try await super.tearDown()
    }

    private func saveSettings(_ settings: DiveReminderSettings) {
        let data = try! JSONEncoder().encode(settings)
        userDefaultsSuite.set(data, forKey: DiveReminderSettingsStore.storageKey)
    }

    private func singleReminder(minute: Int, message: String) -> DiveReminder {
        DiveReminder(
            id: UUID(),
            enabled: true,
            type: .single,
            triggerMinute: minute,
            repeatEveryMinutes: nil,
            message: message,
            hapticEnabled: true
        )
    }

    func testReminderStartsFromManualDiveStart() {
        saveSettings(DiveReminderSettings(
            remindersEnabled: true,
            reminders: [singleReminder(minute: 1, message: "Check gas")]
        ))
        diveManager.startManualDive()
        XCTAssertNil(diveManager.diveReminderOverlay)

        diveManager.testHook_setRuntimeForTests(59)
        diveManager.testHook_evaluateDiveRemindersForTests()
        XCTAssertNil(diveManager.diveReminderOverlay)

        diveManager.testHook_setRuntimeForTests(60)
        diveManager.testHook_evaluateDiveRemindersForTests()
        XCTAssertNotNil(diveManager.diveReminderOverlay)
        XCTAssertEqual(diveManager.diveReminderOverlay?.messages, ["Check gas"])
    }

    func testReminderStartsFromAutomaticDiveStart() {
        saveSettings(DiveReminderSettings(
            remindersEnabled: true,
            reminders: [singleReminder(minute: 1, message: "Check buddy")]
        ))
        let start = Date()
        diveManager.testHook_processDepthMeasurement(rawDepthMeters: 1.1, timestamp: start)
        diveManager.testHook_processDepthMeasurement(rawDepthMeters: 1.2, timestamp: start.addingTimeInterval(1))
        XCTAssertTrue(diveManager.isDiveActive)

        diveManager.testHook_setRuntimeForTests(60)
        diveManager.testHook_evaluateDiveRemindersForTests()
        XCTAssertEqual(diveManager.diveReminderOverlay?.messages, ["Check buddy"])
    }

    func testNoRemindersBeforeDiveStart() {
        saveSettings(DiveReminderSettings(
            remindersEnabled: true,
            reminders: [singleReminder(minute: 1, message: "Check gas")]
        ))
        diveManager.testHook_setRuntimeForTests(120)
        diveManager.testHook_evaluateDiveRemindersForTests()
        XCTAssertNil(diveManager.diveReminderOverlay)
    }

    func testNoRemindersAfterDiveEnd() {
        saveSettings(DiveReminderSettings(
            remindersEnabled: true,
            reminders: [singleReminder(minute: 1, message: "Check gas")]
        ))
        diveManager.startManualDive()
        diveManager.testHook_endDiveForTests()
        diveManager.testHook_setRuntimeForTests(120)
        diveManager.testHook_evaluateDiveRemindersForTests()
        XCTAssertNil(diveManager.diveReminderOverlay)
    }

    func testDiveStartResetsReminderRuntimeState() {
        saveSettings(DiveReminderSettings(
            remindersEnabled: true,
            reminders: [singleReminder(minute: 1, message: "Check gas")]
        ))
        diveManager.startManualDive()
        diveManager.testHook_setRuntimeForTests(60)
        diveManager.testHook_evaluateDiveRemindersForTests()
        XCTAssertFalse(diveManager.testHook_diveReminderRuntimeState.firedSingleReminderIDs.isEmpty)

        diveManager.testHook_endDiveForTests()
        diveManager.startManualDive()
        XCTAssertTrue(diveManager.testHook_diveReminderRuntimeState.firedSingleReminderIDs.isEmpty)
    }

    func testCriticalDepthAlarmSuppressesReminderOverlay() {
        let enabledKey = "dirdiving_watch_alarm_depth_enabled"
        let thresholdKey = "dirdiving_watch_alarm_depth_threshold_m"
        let priorEnabled = UserDefaults.standard.object(forKey: enabledKey)
        let priorThreshold = UserDefaults.standard.object(forKey: thresholdKey)
        defer {
            if let priorEnabled { UserDefaults.standard.set(priorEnabled, forKey: enabledKey) }
            else { UserDefaults.standard.removeObject(forKey: enabledKey) }
            if let priorThreshold { UserDefaults.standard.set(priorThreshold, forKey: thresholdKey) }
            else { UserDefaults.standard.removeObject(forKey: thresholdKey) }
        }
        UserDefaults.standard.set(true, forKey: enabledKey)
        UserDefaults.standard.set(30.0, forKey: thresholdKey)

        saveSettings(DiveReminderSettings(
            remindersEnabled: true,
            reminders: [singleReminder(minute: 1, message: "Check gas")]
        ))
        diveManager.testHook_shutdownTimersForTests()
        diveManager = DiveManager(
            logStore: DiveLogStore(),
            gpsManager: GPSManager(),
            ascentSettings: AscentRateSettingsStore(defaults: userDefaultsSuite)
        )
        diveManager.testHook_setDepthAutomationAvailableForTests(true)
        diveManager.startManualDive()
        diveManager.testHook_processDepthMeasurement(rawDepthMeters: 35, timestamp: Date())
        XCTAssertNotNil(diveManager.testHook_alarmWarningMessage)

        diveManager.testHook_setRuntimeForTests(60)
        diveManager.testHook_evaluateDiveRemindersForTests()
        XCTAssertNil(diveManager.diveReminderOverlay, "Critical depth alarm must suppress reminder overlay")
    }
}
