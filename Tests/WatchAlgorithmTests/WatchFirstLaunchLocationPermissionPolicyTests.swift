import CoreLocation
import XCTest

final class WatchFirstLaunchLocationPermissionPolicyTests: XCTestCase {
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: "WatchFirstLaunchLocationPermissionPolicyTests")!
        defaults.removePersistentDomain(forName: "WatchFirstLaunchLocationPermissionPolicyTests")
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: "WatchFirstLaunchLocationPermissionPolicyTests")
        defaults = nil
        super.tearDown()
    }

    func testDoesNotPresentWhenLegalNotAccepted() {
        XCTAssertFalse(
            WatchFirstLaunchLocationPermissionPolicy.shouldPresentFirstLaunchPermissionFlow(
                authorizationStatus: .notDetermined,
                legalAccepted: false,
                userDefaults: defaults
            )
        )
    }

    func testPresentsWhenLegalAcceptedNotDeterminedNotPresented() {
        XCTAssertTrue(
            WatchFirstLaunchLocationPermissionPolicy.shouldPresentFirstLaunchPermissionFlow(
                authorizationStatus: .notDetermined,
                legalAccepted: true,
                userDefaults: defaults
            )
        )
    }

    func testDoesNotPresentWhenAlreadyPresented() {
        WatchFirstLaunchLocationPermissionPolicy.markPresented(userDefaults: defaults)
        XCTAssertFalse(
            WatchFirstLaunchLocationPermissionPolicy.shouldPresentFirstLaunchPermissionFlow(
                authorizationStatus: .notDetermined,
                legalAccepted: true,
                userDefaults: defaults
            )
        )
    }

    func testDoesNotPresentWhenAuthorized() {
        XCTAssertFalse(
            WatchFirstLaunchLocationPermissionPolicy.shouldPresentFirstLaunchPermissionFlow(
                authorizationStatus: .authorizedWhenInUse,
                legalAccepted: true,
                userDefaults: defaults
            )
        )
    }

    func testDoesNotPresentWhenDenied() {
        XCTAssertFalse(
            WatchFirstLaunchLocationPermissionPolicy.shouldPresentFirstLaunchPermissionFlow(
                authorizationStatus: .denied,
                legalAccepted: true,
                userDefaults: defaults
            )
        )
    }

    func testMarkPresentedPersistsFlag() {
        WatchFirstLaunchLocationPermissionPolicy.markPresented(userDefaults: defaults)
        XCTAssertTrue(defaults.bool(forKey: WatchFirstLaunchLocationPermissionPolicy.hasPresentedLocationPermissionPromptKey))
    }
}
