import XCTest

@MainActor
final class ApneaChecklistPersistenceTests: XCTestCase {
    private var defaults: UserDefaults!
    private let suiteName = "ApneaChecklistPersistenceTests"

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        IOSApneaSettingsStore.testHook_defaults = defaults
    }

    override func tearDown() {
        IOSApneaSettingsStore.testHook_defaults = nil
        defaults.removePersistentDomain(forName: suiteName)
        super.tearDown()
    }

    func testDefaultChecklistHasSevenUncheckedItems() {
        let store = IOSApneaSettingsStore()
        XCTAssertEqual(store.checklistTotalCount, 7)
        XCTAssertEqual(store.checklistCompletedCount, 0)
        XCTAssertFalse(store.isChecklistComplete)
    }

    func testTogglingItemPersistsAcrossReload() throws {
        let store = IOSApneaSettingsStore()
        let itemID = try XCTUnwrap(store.settings.preApneaChecklist.first?.id)
        store.setChecklistItem(id: itemID, isChecked: true)

        let reloaded = IOSApneaSettingsStore()
        XCTAssertTrue(reloaded.settings.preApneaChecklist.first(where: { $0.id == itemID })?.isChecked == true)
    }

    func testResetChecklistClearsChecks() throws {
        let store = IOSApneaSettingsStore()
        let itemID = try XCTUnwrap(store.settings.preApneaChecklist.first?.id)
        store.setChecklistItem(id: itemID, isChecked: true)
        store.resetChecklist()

        XCTAssertEqual(store.checklistCompletedCount, 0)
        XCTAssertFalse(store.settings.preApneaChecklist.contains(where: \.isChecked))
    }

    func testResetSettingsRestoresDefaultChecklist() throws {
        let store = IOSApneaSettingsStore()
        let itemID = try XCTUnwrap(store.settings.preApneaChecklist.first?.id)
        store.setChecklistItem(id: itemID, isChecked: true)
        store.resetToDefaults()

        XCTAssertEqual(store.checklistTotalCount, 7)
        XCTAssertFalse(store.isChecklistComplete)
    }

    func testBuddyChecklistConfirmedTracksBuddyItemOnly() throws {
        let store = IOSApneaSettingsStore()
        let buddyID = try XCTUnwrap(
            store.settings.preApneaChecklist.first(where: { $0.localizationKey == "apnea.checklist.buddy" })?.id
        )
        XCTAssertFalse(store.buddyChecklistConfirmed)
        store.setChecklistItem(id: buddyID, isChecked: true)
        XCTAssertTrue(store.buddyChecklistConfirmed)
    }

    func testLegacySettingsDecodeAddsDefaultChecklist() throws {
        let legacyJSON = """
        {"schemaVersion":1,"descentDetectionDepthMeters":0.8,"surfaceDetectionDepthMeters":0.5,"minimumRecoverySeconds":60,"useMetricUnits":true,"missionModeEnabled":false,"hapticsEnabled":true,"soundsEnabled":true}
        """
        let decoded = try JSONDecoder().decode(ApneaCompanionSettings.self, from: Data(legacyJSON.utf8))
        XCTAssertEqual(decoded.preApneaChecklist.count, 7)
        XCTAssertTrue(decoded.preApneaChecklist.allSatisfy { !$0.isChecked })
    }
}
