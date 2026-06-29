import XCTest

@MainActor
final class SnorkelingMapTypeWatchSettingsTests: XCTestCase {
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: "SnorkelingMapTypeWatchSettingsTests")!
        defaults.removePersistentDomain(forName: "SnorkelingMapTypeWatchSettingsTests")
        SnorkelingMapTypeSettingsStore.testHook_defaults = defaults
    }

    override func tearDown() {
        SnorkelingMapTypeSettingsStore.testHook_defaults = nil
        defaults.removePersistentDomain(forName: "SnorkelingMapTypeWatchSettingsTests")
        defaults = nil
        super.tearDown()
    }

    func testWatchStoreDefaultsToSatellite() {
        let store = SnorkelingMapTypeSettingsStore()
        XCTAssertEqual(store.mapType, .satellite)
    }

    func testWatchStoreSetMapTypePersists() {
        let store = SnorkelingMapTypeSettingsStore()
        store.setMapType(.explore)
        let reloaded = SnorkelingMapTypeSettingsStore()
        XCTAssertEqual(reloaded.mapType, .explore)
    }

    func testWatchSettingsSectionUsesMapTypeStore() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("Views/WatchActivitySettingsSections.swift"))
        XCTAssertTrue(source.contains("SnorkelingMapTypeSettingsStore"))
        XCTAssertTrue(source.contains("snorkeling.map_type.title"))
    }

    func testMapTypeDoesNotLeakIntoDivingSettings() throws {
        let divingSettings = try String(contentsOf: repositoryRoot().appendingPathComponent("Views/SettingsView.swift"))
        XCTAssertFalse(divingSettings.contains("SnorkelingMapType.allCases"))
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
