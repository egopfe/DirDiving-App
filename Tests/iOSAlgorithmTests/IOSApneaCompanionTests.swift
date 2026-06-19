import XCTest

@MainActor
final class IOSApneaCompanionTests: XCTestCase {
    private var defaults: UserDefaults!
    private let suiteName = "IOSApneaCompanionTests"

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        IOSApneaProfileStore.testHook_defaults = defaults
        IOSApneaPlannerStore.testHook_defaults = defaults
        IOSApneaSettingsStore.testHook_defaults = defaults
    }

    override func tearDown() {
        IOSApneaProfileStore.testHook_defaults = nil
        IOSApneaPlannerStore.testHook_defaults = nil
        IOSApneaSettingsStore.testHook_defaults = nil
        defaults.removePersistentDomain(forName: suiteName)
        super.tearDown()
    }

    func testProfileStoreCRUDDuplicateAndDelete() {
        let store = IOSApneaProfileStore()
        XCTAssertGreaterThanOrEqual(store.allProfiles().count, 6)

        let custom = ApneaCompanionProfile(displayName: "My profile", discipline: .custom, targetDepthMeters: 18)
        store.add(custom)
        XCTAssertNotNil(store.profile(id: custom.id))

        let duplicate = store.duplicate(custom)
        XCTAssertNotEqual(duplicate.id, custom.id)

        store.delete(id: custom.id)
        XCTAssertNil(store.profile(id: custom.id))
    }

    func testPresetCannotBeDeletedFromUserStore() {
        let store = IOSApneaProfileStore()
        let preset = store.allProfiles().first { $0.isPreset }!
        store.delete(id: preset.id)
        XCTAssertNotNil(store.profile(id: preset.id))
    }

    func testPlannerValidationRejectsEmptyTitle() {
        var plan = ApneaSessionPlan(kind: .pyramid, title: "", entries: IOSApneaPlannerStore.defaultPyramidEntries())
        XCTAssertTrue(ApneaSessionPlanValidator.validate(plan).contains(.emptyTitle))
        plan.title = "Pyramid"
        XCTAssertTrue(ApneaSessionPlanValidator.isValid(plan))
    }

    func testPlannerValidationRejectsInvalidPyramid() {
        let entries = [
            ApneaPlannedDiveEntry(orderIndex: 0, targetDepthMeters: 15, targetDurationSeconds: 60, plannedRecoverySeconds: 60),
            ApneaPlannedDiveEntry(orderIndex: 1, targetDepthMeters: 10, targetDurationSeconds: 60, plannedRecoverySeconds: 60),
            ApneaPlannedDiveEntry(orderIndex: 2, targetDepthMeters: 20, targetDurationSeconds: 60, plannedRecoverySeconds: 60),
        ]
        let plan = ApneaSessionPlan(kind: .pyramid, title: "Bad", entries: entries)
        XCTAssertFalse(ApneaSessionPlanValidator.isValid(plan))
        XCTAssertTrue(ApneaSessionPlanValidator.validate(plan).contains(.nonMonotonicPyramid(index: 0)))
    }

    func testPlannerStorePersistsDraft() {
        let store = IOSApneaPlannerStore()
        store.draftPlan.title = "Morning pyramid"
        store.persist()
        let reloaded = IOSApneaPlannerStore()
        XCTAssertEqual(reloaded.draftPlan.title, "Morning pyramid")
    }

    func testSettingsMigrationAndReset() {
        let store = IOSApneaSettingsStore()
        store.settings.minimumRecoverySeconds = 120
        store.persist()
        let reloaded = IOSApneaSettingsStore()
        XCTAssertEqual(reloaded.settings.minimumRecoverySeconds, 120)
        reloaded.resetToDefaults()
        XCTAssertEqual(reloaded.settings.minimumRecoverySeconds, ApneaCompanionSettings.default.minimumRecoverySeconds)
    }

    func testDashboardPresentationUsesLastSession() {
        let session = ApneaSession(
            startMode: .watch,
            state: .completed,
            dives: [
                ApneaDive(startedAtMonotonicSeconds: 0, durationSeconds: 88, maxDepthMeters: 24.7, averageDepthMeters: 14)
            ]
        )
        var normalized = session
        normalized.statistics = session.refreshedStatistics()
        let presentation = IOSApneaDashboardPresentationMapper.make(
            lastSession: normalized,
            aggregate: .empty,
            watchConnectivityText: "Active",
            watchConnectivityIsPositive: true
        )
        XCTAssertTrue(presentation.hasLastSession)
        XCTAssertEqual(presentation.diveCountText, "1")
        XCTAssertEqual(presentation.maxDepthText, "24.7 m")
    }

    func testApneaAndSnorkelingSelectionAvailableOnIOSCompanion() {
        XCTAssertTrue(CompanionActivityAvailability.isAvailable(.apnea))
        XCTAssertTrue(CompanionActivityAvailability.isAvailable(.snorkeling))
        XCTAssertTrue(DIRActivityMode.apnea.isLaunchableOnIOSCompanionMAIN)
        XCTAssertTrue(DIRActivityMode.snorkeling.isLaunchableOnIOSCompanionMAIN)
    }

    func testApneaSelectionPersists() {
        let store = CompanionActivityPreferenceStore(defaults: defaults)
        XCTAssertTrue(store.select(.apnea))
        XCTAssertEqual(store.preference.selectedMode, .apnea)
        XCTAssertTrue(IOSCompanionPostLegalEntry.consumePendingApneaLanding())
    }
}
