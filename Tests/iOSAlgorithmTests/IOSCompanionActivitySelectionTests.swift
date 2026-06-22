import XCTest

@MainActor
final class IOSCompanionActivitySelectionTests: XCTestCase {
    private var defaults: UserDefaults!
    private let suiteName = "IOSCompanionActivitySelectionTests"

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        IOSCompanionPostLegalEntry.resetForTesting()
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        IOSCompanionPostLegalEntry.resetForTesting()
        super.tearDown()
    }

    func testInitialPreferenceRequiresSelectionScreen() {
        let store = CompanionActivityPreferenceStore(defaults: defaults)
        XCTAssertFalse(store.preference.hasCompletedPostOnboardingSelection)
        XCTAssertNil(store.preference.selectedMode)
        XCTAssertTrue(store.preference.showActivitySelectionAtLaunch)
        XCTAssertTrue(store.shouldPresentSelectionScreen)
    }

    func testLegacyUserWithLegalAcceptanceMigratesToDivingAndShowsLaunchSelection() {
        defaults.set(Date().timeIntervalSince1970, forKey: "dirdiving_legal_acceptance_timestamp")
        let store = CompanionActivityPreferenceStore(defaults: defaults)
        XCTAssertEqual(store.preference.selectedMode, .diving)
        XCTAssertTrue(store.preference.hasCompletedPostOnboardingSelection)
        XCTAssertTrue(store.preference.showActivitySelectionAtLaunch)
        XCTAssertTrue(store.shouldPresentSelectionScreen)
        XCTAssertTrue(store.isLastUsedMode(.diving))
    }

    func testCorruptPreferenceFallsBackWithoutCrashing() {
        defaults.set(Data([0xFF, 0x00, 0xAB]), forKey: "dirdiving_ios_companion_activity_preference_v1")
        let store = CompanionActivityPreferenceStore(defaults: defaults)
        XCTAssertFalse(store.preference.hasCompletedPostOnboardingSelection)
        XCTAssertTrue(store.shouldPresentSelectionScreen)
    }

    func testDivingSelectionPersistsAndMarksPlannerLanding() {
        let store = CompanionActivityPreferenceStore(defaults: defaults)
        XCTAssertTrue(store.select(.diving))
        XCTAssertEqual(store.preference.selectedMode, .diving)
        XCTAssertTrue(store.preference.hasCompletedPostOnboardingSelection)
        XCTAssertFalse(store.shouldPresentSelectionScreen)

        let reloaded = CompanionActivityPreferenceStore(defaults: defaults)
        XCTAssertEqual(reloaded.preference.selectedMode, .diving)
        XCTAssertTrue(reloaded.shouldPresentSelectionScreen)
        XCTAssertTrue(IOSCompanionPostLegalEntry.consumePendingPlannerLanding())
    }

    func testRelaunchSameModeDoesNotMarkPlannerLandingAgain() {
        let store = CompanionActivityPreferenceStore(defaults: defaults)
        XCTAssertTrue(store.select(.diving))
        XCTAssertTrue(IOSCompanionPostLegalEntry.consumePendingPlannerLanding())

        let relaunched = CompanionActivityPreferenceStore(defaults: defaults)
        XCTAssertTrue(relaunched.shouldPresentSelectionScreen)
        XCTAssertTrue(relaunched.select(.diving))
        XCTAssertFalse(IOSCompanionPostLegalEntry.consumePendingPlannerLanding())
    }

    func testApneaAndSnorkelingCanBeSelectedOnIOSCompanion() {
        let store = CompanionActivityPreferenceStore(defaults: defaults)
        XCTAssertTrue(DIRActivityMode.apnea.isLaunchableOnIOSCompanionMAIN)
        XCTAssertTrue(DIRActivityMode.snorkeling.isLaunchableOnIOSCompanionMAIN)
        XCTAssertTrue(CompanionActivityAvailability.isAvailable(.apnea))
        XCTAssertTrue(CompanionActivityAvailability.isAvailable(.snorkeling))
        XCTAssertTrue(store.select(.apnea))
        XCTAssertEqual(store.preference.selectedMode, .apnea)

        let snorkelingStore = CompanionActivityPreferenceStore(defaults: defaults)
        snorkelingStore.resetForTesting()
        XCTAssertTrue(snorkelingStore.select(.snorkeling))
        XCTAssertEqual(snorkelingStore.preference.selectedMode, .snorkeling)
        XCTAssertTrue(IOSCompanionPostLegalEntry.consumePendingSnorkelingLanding())
    }

    func testShowAtLaunchPolicy() {
        var preference = CompanionActivityPreference.legacyDivingMigration()
        preference.showActivitySelectionAtLaunch = true
        let store = CompanionActivityPreferenceStore(defaults: defaults)
        store.applyPreferenceForTesting(preference)
        XCTAssertTrue(store.shouldPresentSelectionScreen)

        store.dismissSelectionScreenAfterChoice()
        XCTAssertFalse(store.shouldPresentSelectionScreen)
    }

    func testOpenLastModeDirectlySkipsLaunchSelection() {
        var preference = CompanionActivityPreference.legacyDivingMigration()
        preference.showActivitySelectionAtLaunch = false
        let store = CompanionActivityPreferenceStore(defaults: defaults)
        store.applyPreferenceForTesting(preference)
        XCTAssertFalse(store.shouldPresentSelectionScreen)
    }

    func testSavedV1PreferenceMigratesToLaunchSelectionPolicy() throws {
        let legacy = CompanionActivityPreference(
            selectedMode: .apnea,
            showActivitySelectionAtLaunch: false,
            hasCompletedPostOnboardingSelection: true,
            schemaVersion: 1
        )
        let data = try JSONEncoder().encode(legacy)
        defaults.set(data, forKey: "dirdiving_ios_companion_activity_preference_v1")

        let store = CompanionActivityPreferenceStore(defaults: defaults)
        XCTAssertEqual(store.preference.selectedMode, .apnea)
        XCTAssertTrue(store.preference.showActivitySelectionAtLaunch)
        XCTAssertEqual(store.preference.schemaVersion, 2)
        XCTAssertTrue(store.shouldPresentSelectionScreen)
    }

    func testSettingsCanReopenSelection() {
        let store = CompanionActivityPreferenceStore(defaults: defaults)
        XCTAssertTrue(store.select(.diving))
        store.requestActivitySelectionFromSettings()
        XCTAssertTrue(store.shouldPresentSelectionScreen)
    }

    func testWatchActiveSessionShowsNoteWithoutBlockingSelection() {
        let store = CompanionActivityPreferenceStore(defaults: defaults)
        XCTAssertTrue(store.select(.diving, watchReportsActiveSession: true))
        XCTAssertNotNil(store.watchActiveSessionNote)
        XCTAssertFalse(store.watchActiveSessionNote?.isEmpty ?? true)
    }

    func testWatchSessionGuardDefersSyncOnly() {
        XCTAssertTrue(
            CompanionActivityWatchSessionGuard.shouldDeferPreferenceSync(watchReportsActiveSession: true)
        )
        XCTAssertFalse(
            CompanionActivityWatchSessionGuard.shouldDeferPreferenceSync(watchReportsActiveSession: false)
        )
    }

    func testLegalAcceptanceMarksPendingActivitySelection() {
        XCTAssertFalse(IOSCompanionPostLegalEntry.consumePendingActivitySelection())
        IOSCompanionPostLegalEntry.markPendingActivitySelection()
        XCTAssertTrue(IOSCompanionPostLegalEntry.consumePendingActivitySelection())
        XCTAssertFalse(IOSCompanionPostLegalEntry.consumePendingActivitySelection())
    }

    func testCompanionActivityLocalizationKeysExist() throws {
        let keys = [
            "companion.activitySelection.title",
            "companion.activitySelection.subtitle",
            "companion.activity.diving.title",
            "companion.activity.apnea.title",
            "companion.activity.snorkeling.title",
            "companion.activitySelection.safety.body",
            "companion.activitySelection.settingsReminder",
            "companion.activitySelection.lastUsed",
            "companion.activitySelection.unavailable",
            "companion.activitySelection.watch_active_note",
            "companion.settings.activity.title",
            "companion.settings.activity.change",
            "companion.settings.activity.showAtLaunch",
        ]
        let en = try loadIOSStrings(named: "en")
        let it = try loadIOSStrings(named: "it")
        for key in keys {
            XCTAssertFalse(en[key, default: ""].isEmpty, "Missing EN \(key)")
            XCTAssertFalse(it[key, default: ""].isEmpty, "Missing IT \(key)")
            XCTAssertNotEqual(en[key], key)
            XCTAssertNotEqual(it[key], key)
        }
    }

    private func loadIOSStrings(named locale: String) throws -> [String: String] {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let path = root.appendingPathComponent("iOSApp/Resources/\(locale).lproj/Localizable.strings").path
        let text = try String(contentsOfFile: path, encoding: .utf8)
        var result: [String: String] = [:]
        let pattern = #"^\s*\"([^\"]+)\"\s*=\s*\"((?:\\.|[^\"\\])*)\"\s*;"#
        let regex = try NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines])
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        regex.enumerateMatches(in: text, range: range) { match, _, _ in
            guard let match,
                  let keyRange = Range(match.range(at: 1), in: text),
                  let valueRange = Range(match.range(at: 2), in: text) else { return }
            result[String(text[keyRange])] = String(text[valueRange])
        }
        return result
    }
}
