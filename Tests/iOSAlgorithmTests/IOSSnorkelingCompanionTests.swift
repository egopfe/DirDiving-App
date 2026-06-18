import XCTest

@MainActor
final class IOSSnorkelingCompanionTests: XCTestCase {
    private var defaults: UserDefaults!
    private let suiteName = "IOSSnorkelingCompanionTests"

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        IOSSnorkelingProfileStore.testHook_defaults = defaults
        IOSSnorkelingRoutePlannerStore.testHook_defaults = defaults
    }

    override func tearDown() {
        IOSSnorkelingProfileStore.testHook_defaults = nil
        IOSSnorkelingRoutePlannerStore.testHook_defaults = nil
        defaults.removePersistentDomain(forName: suiteName)
        super.tearDown()
    }

    func testProfileStoreCRUDDuplicateAndDelete() {
        let store = IOSSnorkelingProfileStore()
        XCTAssertGreaterThanOrEqual(store.allProfiles().count, 7)

        let custom = SnorkelingCompanionProfile(
            displayName: "Coastal custom",
            discipline: .custom,
            maxDepthMeters: 4
        )
        store.add(custom)
        XCTAssertNotNil(store.profile(id: custom.id))

        let duplicate = store.duplicate(custom)
        XCTAssertNotEqual(duplicate.id, custom.id)

        store.delete(id: custom.id)
        XCTAssertNil(store.profile(id: custom.id))
    }

    func testPresetCannotBeDeletedFromUserStore() {
        let store = IOSSnorkelingProfileStore()
        let preset = store.allProfiles().first { $0.isPreset }!
        store.delete(id: preset.id)
        XCTAssertNotNil(store.profile(id: preset.id))
    }

    func testPresetOpensAsEditableCopy() {
        let store = IOSSnorkelingProfileStore()
        let preset = store.allProfiles().first { $0.isPreset }!
        XCTAssertFalse(SnorkelingCompanionProfilePolicy.canEditInPlace(preset))
        let copy = store.duplicate(preset)
        XCTAssertFalse(copy.isPreset)
    }

    func testPlannerPersistenceRoundTrip() {
        let store = IOSSnorkelingRoutePlannerStore()
        store.draft.name = "Reef loop"
        store.setEntry(latitude: 44.10, longitude: 9.82)
        store.setExit(latitude: 44.11, longitude: 9.83)
        store.persistDraft()
        let reloaded = IOSSnorkelingRoutePlannerStore()
        XCTAssertEqual(reloaded.draft.name, "Reef loop")
        XCTAssertNotNil(reloaded.draft.entryPoint)
        XCTAssertNotNil(reloaded.draft.exitPoint)
    }

    func testSnorkelingLaunchableOnIOSCompanion() {
        XCTAssertTrue(DIRActivityMode.snorkeling.isLaunchableOnIOSCompanionMAIN)
    }
}
