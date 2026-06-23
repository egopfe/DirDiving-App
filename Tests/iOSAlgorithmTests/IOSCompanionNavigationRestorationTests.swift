import XCTest

@MainActor
final class IOSCompanionNavigationRestorationTests: XCTestCase {
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        let suite = "IOSCompanionNavigationRestorationTests-\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        IOSCompanionNavigationPersistence.resetForTesting(defaults: defaults)
    }

    func testDivingTabTokenPersistsAcrossRelaunch() {
        IOSCompanionNavigationPersistence.persistDivingTabToken("analysis", defaults: defaults)
        XCTAssertEqual(IOSCompanionNavigationPersistence.restoreDivingTabToken(defaults: defaults), "analysis")
    }

    func testSettingsScopeRestoresAfterSimulatedRelaunch() {
        IOSCompanionNavigationPersistence.persistSettingsScopeToken(DIRActivityMode.apnea.rawValue, defaults: defaults)
        let scope = IOSCompanionSettingsScopeStore(defaults: defaults)
        XCTAssertEqual(scope.displayedMode, .apnea)
    }

    func testApneaTabTokenPersistsAcrossRelaunch() {
        IOSCompanionNavigationPersistence.persistApneaTabToken("sessions", defaults: defaults)
        XCTAssertEqual(IOSCompanionNavigationPersistence.restoreApneaTabToken(defaults: defaults), "sessions")
    }

    func testSnorkelingTabTokenPersistsAcrossRelaunch() {
        IOSCompanionNavigationPersistence.persistSnorkelingTabToken("routePlanner", defaults: defaults)
        XCTAssertEqual(IOSCompanionNavigationPersistence.restoreSnorkelingTabToken(defaults: defaults), "routePlanner")
    }

    func testCrossActivitySessionDetailDeepLinkRejected() {
        XCTAssertFalse(IOSCompanionDeepLinkPolicy.allowsSessionDetail(requestedActivity: .apnea, activeActivity: .diving))
        XCTAssertFalse(IOSCompanionDeepLinkPolicy.allowsSessionDetail(requestedActivity: .snorkeling, activeActivity: .apnea))
        XCTAssertFalse(IOSCompanionDeepLinkPolicy.allowsSessionDetail(requestedActivity: .diving, activeActivity: nil))
    }

    func testSameActivitySessionDetailDeepLinkAllowed() {
        XCTAssertTrue(IOSCompanionDeepLinkPolicy.allowsSessionDetail(requestedActivity: .apnea, activeActivity: .apnea))
        XCTAssertTrue(IOSCompanionDeepLinkPolicy.allowsSessionDetail(requestedActivity: .snorkeling, activeActivity: .snorkeling))
        XCTAssertTrue(IOSCompanionDeepLinkPolicy.allowsSessionDetail(requestedActivity: .diving, activeActivity: .diving))
    }

    func testSettingsScopeDoesNotMutateCompanionActivity() {
        let activityDefaults = UserDefaults(suiteName: "IOSCompanionNavigationRestorationTests-activity-\(UUID().uuidString)")!
        activityDefaults.removePersistentDomain(forName: activityDefaults.description)
        defer { activityDefaults.removePersistentDomain(forName: activityDefaults.description) }

        let scope = IOSCompanionSettingsScopeStore(defaults: defaults)
        let activity = CompanionActivityPreferenceStore(defaults: activityDefaults)
        scope.setDisplayedMode(.snorkeling)
        XCTAssertNil(activity.selectedMode)
    }
}
