import XCTest

final class SnorkelingRoutePlannerMapUXTests: XCTestCase {
    func testAuthorizedWithCoordinateCentersMap() {
        let outcome = SnorkelingRoutePlannerMapCenterPolicy.resolve(
            permissionState: .authorized,
            currentLatitude: 44.405,
            currentLongitude: 8.946
        )
        guard case .center(let region) = outcome else {
            return XCTFail("Expected center outcome")
        }
        XCTAssertEqual(region.latitude, 44.405, accuracy: 0.0001)
        XCTAssertEqual(region.longitude, 8.946, accuracy: 0.0001)
        XCTAssertEqual(region.latitudeDelta, SnorkelingMapCenterRegion.plannerDefaultSpan, accuracy: 0.0001)
    }

    func testAuthorizedWithoutCoordinateShowsUnavailableNotice() {
        let outcome = SnorkelingRoutePlannerMapCenterPolicy.resolve(
            permissionState: .authorized,
            currentLatitude: nil,
            currentLongitude: nil
        )
        guard case .notice(let key) = outcome else {
            return XCTFail("Expected notice outcome")
        }
        XCTAssertEqual(key, "snorkeling.map.current_location_unavailable")
    }

    func testDeniedShowsPermissionRequiredNotice() {
        let outcome = SnorkelingRoutePlannerMapCenterPolicy.resolve(
            permissionState: .denied,
            currentLatitude: 44.4,
            currentLongitude: 8.9
        )
        guard case .notice(let key) = outcome else {
            return XCTFail("Expected notice outcome")
        }
        XCTAssertEqual(key, "snorkeling.map.location_permission_required_to_center")
    }

    func testNotDeterminedRequestsPermission() {
        let outcome = SnorkelingRoutePlannerMapCenterPolicy.resolve(
            permissionState: .notDetermined,
            currentLatitude: nil,
            currentLongitude: nil
        )
        guard case .requestPermission = outcome else {
            return XCTFail("Expected requestPermission outcome")
        }
    }
}
