import XCTest

final class SnorkelingMapTypeTests: XCTestCase {
    func testDefaultValueIsSatellite() {
        XCTAssertEqual(SnorkelingMapType.defaultValue, .satellite)
    }

    func testAllCasesAreSatelliteAndExploreOnly() {
        XCTAssertEqual(SnorkelingMapType.allCases, [.satellite, .explore])
    }

    func testRawValues() {
        XCTAssertEqual(SnorkelingMapType.satellite.rawValue, "satellite")
        XCTAssertEqual(SnorkelingMapType.explore.rawValue, "explore")
    }

    func testDisplayAndDescriptionKeys() {
        XCTAssertEqual(SnorkelingMapType.satellite.displayNameKey, "snorkeling.map_type.satellite")
        XCTAssertEqual(SnorkelingMapType.explore.displayNameKey, "snorkeling.map_type.explore")
        XCTAssertEqual(SnorkelingMapType.satellite.descriptionKey, "snorkeling.map_type.satellite.description")
        XCTAssertEqual(SnorkelingMapType.explore.descriptionKey, "snorkeling.map_type.explore.description")
    }

    func testStyleMapperSatelliteUsesHybrid() {
        XCTAssertEqual(SnorkelingMapStyleMapper.styleKind(for: .satellite), .hybrid)
    }

    func testStyleMapperExploreUsesStandard() {
        XCTAssertEqual(SnorkelingMapStyleMapper.styleKind(for: .explore), .standard)
    }
}
