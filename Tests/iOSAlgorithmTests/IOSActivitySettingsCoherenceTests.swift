import XCTest

final class IOSActivitySettingsCoherenceTests: XCTestCase {
    func testSettingsVisibilityRegistryHasNoCrossScopeLeakage() {
        XCTAssertTrue(ActivitySettingsVisibility.verifyNoCrossScopeLeakage().isEmpty)
    }

    func testDivingOnlyKeysNotVisibleInApneaOrSnorkeling() {
        let divingOnly = ActivitySettingsVisibility.registry.filter { $0.scope == .diving }
        for descriptor in divingOnly {
            XCTAssertFalse(descriptor.visibleInApnea, descriptor.key)
            XCTAssertFalse(descriptor.visibleInSnorkeling, descriptor.key)
        }
    }

    func testApneaSettingsNamespaceIsolatedFromDivingAndSnorkeling() {
        let apnea = ActivitySettingsVisibility.registry.first { $0.key == "dirdiving_ios_apnea_settings_v1" }
        XCTAssertEqual(apnea?.scope, .apnea)
        XCTAssertTrue(apnea?.visibleInApnea == true)
        XCTAssertFalse(apnea?.visibleInDiving == true)
        XCTAssertFalse(apnea?.visibleInSnorkeling == true)
    }

    func testSnorkelingSettingsNamespaceIsolated() {
        let snorkeling = ActivitySettingsVisibility.registry.first { $0.key == SnorkelingCompanionSettings.storageNamespace }
        XCTAssertEqual(snorkeling?.scope, .snorkeling)
        XCTAssertTrue(snorkeling?.visibleInSnorkeling == true)
        XCTAssertFalse(snorkeling?.visibleInDiving == true)
        XCTAssertFalse(snorkeling?.visibleInApnea == true)
    }

    func testSharedSettingsVisibleInAllActivities() {
        let shared = ActivitySettingsVisibility.registry.filter { $0.scope == .shared }
        XCTAssertFalse(shared.isEmpty)
        for descriptor in shared {
            XCTAssertTrue(descriptor.visibleInDiving)
            XCTAssertTrue(descriptor.visibleInApnea)
            XCTAssertTrue(descriptor.visibleInSnorkeling)
        }
    }

    @MainActor
    func testSharedIOSSettingsStorePersistsUnits() {
        let suite = "IOSActivitySettingsCoherenceTests-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        SharedIOSSettingsStore.testHook_defaults = defaults
        defer {
            SharedIOSSettingsStore.testHook_defaults = nil
            defaults.removePersistentDomain(forName: suite)
        }

        let store = SharedIOSSettingsStore()
        store.units = .imperial
        let reloaded = SharedIOSSettingsStore()
        XCTAssertEqual(reloaded.units, .imperial)
    }

    @MainActor
    func testSnorkelingSettingsStoreRoundTrip() {
        let suite = "IOSActivitySettingsCoherenceTests-snorkel-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        IOSSnorkelingSettingsStore.testHook_defaults = defaults
        defer {
            IOSSnorkelingSettingsStore.testHook_defaults = nil
            defaults.removePersistentDomain(forName: suite)
        }

        let store = IOSSnorkelingSettingsStore()
        store.settings.returnToEntryDistanceMeters = 120
        store.persist()
        let reloaded = IOSSnorkelingSettingsStore()
        XCTAssertEqual(reloaded.settings.returnToEntryDistanceMeters, 120, accuracy: 0.01)
    }
}
