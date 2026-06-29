import CoreLocation
import XCTest
@testable import DIRDivingiOSApp

final class IOSLocationPermissionServiceTests: XCTestCase {
    func testMapsAuthorizedWhenInUse() {
        XCTAssertEqual(IOSLocationPermissionService.map(.authorizedWhenInUse), .authorized)
    }

    func testMapsAuthorizedAlways() {
        XCTAssertEqual(IOSLocationPermissionService.map(.authorizedAlways), .authorized)
    }

    func testMapsDenied() {
        XCTAssertEqual(IOSLocationPermissionService.map(.denied), .denied)
    }

    func testMapsRestricted() {
        XCTAssertEqual(IOSLocationPermissionService.map(.restricted), .restricted)
    }

    func testMapsNotDetermined() {
        XCTAssertEqual(IOSLocationPermissionService.map(.notDetermined), .notDetermined)
    }
}
