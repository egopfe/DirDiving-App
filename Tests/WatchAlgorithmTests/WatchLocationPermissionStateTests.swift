import CoreLocation
import XCTest

final class WatchLocationPermissionStateTests: XCTestCase {
    func testMapsAuthorizedWhenInUse() {
        XCTAssertEqual(WatchLocationPermissionState.map(.authorizedWhenInUse), .authorized)
    }

    func testMapsAuthorizedAlways() {
        XCTAssertEqual(WatchLocationPermissionState.map(.authorizedAlways), .authorized)
    }

    func testMapsNotDetermined() {
        XCTAssertEqual(WatchLocationPermissionState.map(.notDetermined), .notDetermined)
    }

    func testMapsDenied() {
        XCTAssertEqual(WatchLocationPermissionState.map(.denied), .denied)
    }

    func testMapsRestricted() {
        XCTAssertEqual(WatchLocationPermissionState.map(.restricted), .restricted)
    }

    func testIsAuthorizedAndDeniedFlags() {
        XCTAssertTrue(WatchLocationPermissionState.authorized.isAuthorized)
        XCTAssertFalse(WatchLocationPermissionState.notDetermined.isAuthorized)
        XCTAssertTrue(WatchLocationPermissionState.denied.isDeniedOrRestricted)
        XCTAssertTrue(WatchLocationPermissionState.restricted.isDeniedOrRestricted)
    }
}
