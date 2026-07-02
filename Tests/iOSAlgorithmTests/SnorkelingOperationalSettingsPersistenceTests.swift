import XCTest
@testable import DIRDivingiOSApp

@MainActor
final class SnorkelingOperationalSettingsPersistenceTests: XCTestCase {
    override func tearDown() {
        IOSSnorkelingSettingsStore.testHook_defaults = nil
        super.tearDown()
    }

    func testOperationalSettingsPersistAndDecodeV1Payload() throws {
        let defaults = UserDefaults(suiteName: "SnorkelingOperationalSettingsPersistenceTests")!
        defaults.removePersistentDomain(forName: "SnorkelingOperationalSettingsPersistenceTests")
        IOSSnorkelingSettingsStore.testHook_defaults = defaults

        let legacy = """
        {"schemaVersion":1,"autoWaterDetectionEnabled":true,"dipThresholdMeters":0.8,"surfaceDebounceSeconds":2,"gpsTrackingEnabled":true,"returnToEntryDistanceMeters":50,"sessionDurationAlertMinutes":90,"hapticsEnabled":true,"missionModeEnabled":false}
        """
        defaults.set(Data(legacy.utf8), forKey: SnorkelingCompanionSettings.storageNamespace)

        let store = IOSSnorkelingSettingsStore()
        XCTAssertEqual(store.settings.maxSessionDurationMinutes, SnorkelingCompanionSettings.default.maxSessionDurationMinutes)
        XCTAssertEqual(store.settings.offRouteThresholdMeters, SnorkelingCompanionSettings.default.offRouteThresholdMeters)

        store.settings.maxDistanceMeters = 900
        store.settings.buddyReminderEnabled = true
        store.persist()

        let reloaded = IOSSnorkelingSettingsStore()
        XCTAssertEqual(reloaded.settings.maxDistanceMeters, 900)
        XCTAssertTrue(reloaded.settings.buddyReminderEnabled)
    }

    func testOperationalSettingsDoNotUseDivingNamespace() {
        XCTAssertEqual(SnorkelingCompanionSettings.storageNamespace, "dirdiving.settings.snorkeling.v1")
        XCTAssertNotEqual(SnorkelingCompanionSettings.storageNamespace, "dirdiving.settings.diving.v1")
    }
}
