import XCTest
@testable import DIRDivingiOSApp

@MainActor
final class IOSActivityLogbookVisibilitySettingsTests: XCTestCase {
    private var suiteName: String!
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        suiteName = "IOSActivityLogbookVisibilitySettingsTests-\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        IOSActivityLogbookVisibilitySettingsStore.testHook_defaults = defaults
    }

    override func tearDown() {
        IOSActivityLogbookVisibilitySettingsStore.testHook_defaults = nil
        defaults.removePersistentDomain(forName: suiteName)
        super.tearDown()
    }

    func testDivingShowAllActivitiesDefaultFalse() {
        let store = IOSActivityLogbookVisibilitySettingsStore()
        XCTAssertFalse(store.showAllActivitiesInDivingLogbook)
    }

    func testSnorkelingShowAllActivitiesDefaultFalse() {
        let store = IOSActivityLogbookVisibilitySettingsStore()
        XCTAssertFalse(store.showAllActivitiesInSnorkelingLogbook)
    }

    func testApneaShowAllActivitiesDefaultFalse() {
        let store = IOSActivityLogbookVisibilitySettingsStore()
        XCTAssertFalse(store.showAllActivitiesInApneaLogbook)
    }

    func testTogglePersistsIndependentlyPerActivity() {
        let store = IOSActivityLogbookVisibilitySettingsStore()
        store.showAllActivitiesInDivingLogbook = true
        store.showAllActivitiesInSnorkelingLogbook = true
        store.showAllActivitiesInApneaLogbook = false

        let reloaded = IOSActivityLogbookVisibilitySettingsStore()
        XCTAssertTrue(reloaded.showAllActivitiesInDivingLogbook)
        XCTAssertTrue(reloaded.showAllActivitiesInSnorkelingLogbook)
        XCTAssertFalse(reloaded.showAllActivitiesInApneaLogbook)
    }

    func testDivingToggleDoesNotChangeSnorkelingToggle() {
        let store = IOSActivityLogbookVisibilitySettingsStore()
        store.showAllActivitiesInDivingLogbook = true
        XCTAssertFalse(store.showAllActivitiesInSnorkelingLogbook)
        XCTAssertFalse(store.showAllActivitiesInApneaLogbook)
    }

    func testSnorkelingToggleDoesNotChangeApneaToggle() {
        let store = IOSActivityLogbookVisibilitySettingsStore()
        store.showAllActivitiesInSnorkelingLogbook = true
        XCTAssertFalse(store.showAllActivitiesInDivingLogbook)
        XCTAssertFalse(store.showAllActivitiesInApneaLogbook)
    }

    func testApneaToggleDoesNotChangeDivingToggle() {
        let store = IOSActivityLogbookVisibilitySettingsStore()
        store.showAllActivitiesInApneaLogbook = true
        XCTAssertFalse(store.showAllActivitiesInDivingLogbook)
        XCTAssertFalse(store.showAllActivitiesInSnorkelingLogbook)
    }

    func testActivityScopedAccessorRoundTrip() {
        let store = IOSActivityLogbookVisibilitySettingsStore()
        store.setShowAllActivitiesInLogbook(true, for: .snorkeling)
        XCTAssertTrue(store.showAllActivitiesInLogbook(for: .snorkeling))
        XCTAssertFalse(store.showAllActivitiesInLogbook(for: .diving))
    }
}
