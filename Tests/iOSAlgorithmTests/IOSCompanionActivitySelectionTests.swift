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
        XCTAssertTrue(store.shouldPresentSelectionScreen)
    }

    func testLegacyUserWithLegalAcceptanceMigratesToDivingWithoutSelection() {
        defaults.set(Date().timeIntervalSince1970, forKey: "dirdiving_legal_acceptance_timestamp")
        let store = CompanionActivityPreferenceStore(defaults: defaults)
        XCTAssertEqual(store.preference.selectedMode, .diving)
        XCTAssertTrue(store.preference.hasCompletedPostOnboardingSelection)
        XCTAssertFalse(store.shouldPresentSelectionScreen)
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
        XCTAssertTrue(IOSCompanionPostLegalEntry.consumePendingPlannerLanding())
    }

    func testApneaCanBeSelectedWhileSnorkelingRemainsUnavailable() {
        let store = CompanionActivityPreferenceStore(defaults: defaults)
        XCTAssertTrue(DIRActivityMode.apnea.isLaunchableOnIOSCompanionMAIN)
        XCTAssertFalse(DIRActivityMode.snorkeling.isLaunchableOnIOSCompanionMAIN)
        XCTAssertTrue(CompanionActivityAvailability.isAvailable(.apnea))
        XCTAssertFalse(CompanionActivityAvailability.isAvailable(.snorkeling))
        XCTAssertTrue(store.select(.apnea))
        XCTAssertFalse(store.select(.snorkeling))
        XCTAssertEqual(store.preference.selectedMode, .apnea)
    }

    func testUnavailableSnorkelingCannotBeSelected() {
        let store = CompanionActivityPreferenceStore(defaults: defaults)
        XCTAssertFalse(store.select(.snorkeling))
        XCTAssertNil(store.preference.selectedMode)
        XCTAssertTrue(store.shouldPresentSelectionScreen)
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
