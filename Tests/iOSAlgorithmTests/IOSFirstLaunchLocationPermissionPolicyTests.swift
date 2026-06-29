import CoreLocation
import XCTest
@testable import DIRDivingiOSApp

final class IOSFirstLaunchLocationPermissionPolicyTests: XCTestCase {
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: "IOSFirstLaunchLocationPermissionPolicyTests")!
        defaults.removePersistentDomain(forName: "IOSFirstLaunchLocationPermissionPolicyTests")
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: "IOSFirstLaunchLocationPermissionPolicyTests")
        defaults = nil
        super.tearDown()
    }

    func testShouldPresentWhenFlagFalseAndNotDetermined() {
        XCTAssertTrue(
            IOSFirstLaunchLocationPermissionPolicy.shouldPresentFirstLaunchPermissionFlow(
                authorizationStatus: .notDetermined,
                userDefaults: defaults
            )
        )
    }

    func testShouldNotPresentWhenFlagTrueAndNotDetermined() {
        IOSFirstLaunchLocationPermissionPolicy.markPresented(userDefaults: defaults)
        XCTAssertFalse(
            IOSFirstLaunchLocationPermissionPolicy.shouldPresentFirstLaunchPermissionFlow(
                authorizationStatus: .notDetermined,
                userDefaults: defaults
            )
        )
    }

    func testShouldNotPresentWhenAuthorizedWhenInUse() {
        XCTAssertFalse(
            IOSFirstLaunchLocationPermissionPolicy.shouldPresentFirstLaunchPermissionFlow(
                authorizationStatus: .authorizedWhenInUse,
                userDefaults: defaults
            )
        )
    }

    func testShouldNotPresentWhenDenied() {
        XCTAssertFalse(
            IOSFirstLaunchLocationPermissionPolicy.shouldPresentFirstLaunchPermissionFlow(
                authorizationStatus: .denied,
                userDefaults: defaults
            )
        )
    }

    func testMarkPresentedPersistsFlag() {
        IOSFirstLaunchLocationPermissionPolicy.markPresented(userDefaults: defaults)
        XCTAssertTrue(defaults.bool(forKey: IOSFirstLaunchLocationPermissionPolicy.hasPresentedLocationPermissionPromptKey))
    }
}
