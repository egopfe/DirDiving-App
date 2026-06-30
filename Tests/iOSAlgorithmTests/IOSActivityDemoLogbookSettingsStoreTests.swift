import XCTest
@testable import DIRDivingiOSApp

@MainActor
final class IOSActivityDemoLogbookSettingsStoreTests: XCTestCase {
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: "IOSActivityDemoLogbookSettingsStoreTests")!
        defaults.removePersistentDomain(forName: "IOSActivityDemoLogbookSettingsStoreTests")
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: "IOSActivityDemoLogbookSettingsStoreTests")
        defaults = nil
        super.tearDown()
    }

    func testDefaultsAreFalse() {
        let store = IOSActivityDemoLogbookSettingsStore(userDefaults: defaults)
        XCTAssertFalse(store.isApneaFakeLogbookEnabled)
        XCTAssertFalse(store.isSnorkelingFakeLogbookEnabled)
    }

    func testApneaTogglePersists() {
        let store = IOSActivityDemoLogbookSettingsStore(userDefaults: defaults)
        store.setApneaFakeLogbookEnabled(true)
        let reloaded = IOSActivityDemoLogbookSettingsStore(userDefaults: defaults)
        XCTAssertTrue(reloaded.isApneaFakeLogbookEnabled)
        store.setApneaFakeLogbookEnabled(false)
        XCTAssertFalse(IOSActivityDemoLogbookSettingsStore(userDefaults: defaults).isApneaFakeLogbookEnabled)
    }

    func testSnorkelingTogglePersists() {
        let store = IOSActivityDemoLogbookSettingsStore(userDefaults: defaults)
        store.setSnorkelingFakeLogbookEnabled(true)
        let reloaded = IOSActivityDemoLogbookSettingsStore(userDefaults: defaults)
        XCTAssertTrue(reloaded.isSnorkelingFakeLogbookEnabled)
    }

    func testTogglesAreIndependent() {
        let store = IOSActivityDemoLogbookSettingsStore(userDefaults: defaults)
        store.setApneaFakeLogbookEnabled(true)
        XCTAssertFalse(store.isSnorkelingFakeLogbookEnabled)
        store.setSnorkelingFakeLogbookEnabled(true)
        XCTAssertTrue(store.isApneaFakeLogbookEnabled)
    }

    func testResetClearsBoth() {
        let store = IOSActivityDemoLogbookSettingsStore(userDefaults: defaults)
        store.setApneaFakeLogbookEnabled(true)
        store.setSnorkelingFakeLogbookEnabled(true)
        store.resetDemoLogbookSettings()
        XCTAssertFalse(store.isApneaFakeLogbookEnabled)
        XCTAssertFalse(store.isSnorkelingFakeLogbookEnabled)
    }
}
