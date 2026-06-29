import XCTest
@testable import DIRDivingiOSApp

@MainActor
final class IOSSnorkelingSettingsStoreTests: XCTestCase {
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: "IOSSnorkelingSettingsStoreMapTypeTests")!
        defaults.removePersistentDomain(forName: "IOSSnorkelingSettingsStoreMapTypeTests")
        IOSSnorkelingSettingsStore.testHook_defaults = defaults
    }

    override func tearDown() {
        IOSSnorkelingSettingsStore.testHook_defaults = nil
        defaults.removePersistentDomain(forName: "IOSSnorkelingSettingsStoreMapTypeTests")
        defaults = nil
        super.tearDown()
    }

    func testEmptyUserDefaultsDefaultsToSatellite() {
        let store = IOSSnorkelingSettingsStore()
        XCTAssertEqual(store.mapType, .satellite)
    }

    func testPersistedSatelliteLoads() {
        defaults.set(SnorkelingMapType.satellite.rawValue, forKey: SnorkelingMapTypeStorage.storageKey)
        let store = IOSSnorkelingSettingsStore()
        XCTAssertEqual(store.mapType, .satellite)
    }

    func testPersistedExploreLoads() {
        defaults.set(SnorkelingMapType.explore.rawValue, forKey: SnorkelingMapTypeStorage.storageKey)
        let store = IOSSnorkelingSettingsStore()
        XCTAssertEqual(store.mapType, .explore)
    }

    func testInvalidUserDefaultsFallsBackToSatellite() {
        defaults.set("hybrid", forKey: SnorkelingMapTypeStorage.storageKey)
        let store = IOSSnorkelingSettingsStore()
        XCTAssertEqual(store.mapType, .satellite)
    }

    func testSetMapTypePersistsAndReloads() {
        let store = IOSSnorkelingSettingsStore()
        store.setMapType(.explore)
        let reloaded = IOSSnorkelingSettingsStore()
        XCTAssertEqual(reloaded.mapType, .explore)
    }

    func testResetToDefaultsRestoresSatelliteMapType() {
        let store = IOSSnorkelingSettingsStore()
        store.setMapType(.explore)
        store.resetToDefaults()
        XCTAssertEqual(store.mapType, .satellite)
        let reloaded = IOSSnorkelingSettingsStore()
        XCTAssertEqual(reloaded.mapType, .satellite)
    }
}
