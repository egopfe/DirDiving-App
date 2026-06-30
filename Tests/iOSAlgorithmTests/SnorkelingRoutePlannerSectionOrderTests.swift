import XCTest

final class SnorkelingRoutePlannerSectionOrderTests: XCTestCase {
    func testRoutePlannerSectionOrderIsMapThenPointsThenProfiles() throws {
        let root = repositoryRoot()
        let source = try String(contentsOf: root.appendingPathComponent("iOSApp/Views/Snorkeling/IOSSnorkelingRoutePlannerView.swift"))
        let mapIndex = try XCTUnwrap(source.range(of: "mapSection")?.lowerBound)
        let pointsIndex = try XCTUnwrap(source.range(of: "waypointList", range: mapIndex..<source.endIndex)?.lowerBound)
        let safetyIndex = try XCTUnwrap(source.range(of: "routeSafetySection", range: pointsIndex..<source.endIndex)?.lowerBound)
        let profilesIndex = try XCTUnwrap(source.range(of: "profilesSection", range: safetyIndex..<source.endIndex)?.lowerBound)
        let transferIndex = try XCTUnwrap(source.range(of: "transferSection", range: profilesIndex..<source.endIndex)?.lowerBound)
        XCTAssertLessThan(mapIndex, pointsIndex)
        XCTAssertLessThan(pointsIndex, safetyIndex)
        XCTAssertLessThan(safetyIndex, profilesIndex)
        XCTAssertLessThan(profilesIndex, transferIndex)
        XCTAssertTrue(source.contains("routeSafetySection"))
        XCTAssertTrue(source.contains("checklistSection"))
        XCTAssertTrue(source.contains("exportSection"))
    }

    func testRoutePlannerIncludesCenterLocationAndResetControls() throws {
        let root = repositoryRoot()
        let source = try String(contentsOf: root.appendingPathComponent("iOSApp/Views/Snorkeling/IOSSnorkelingRoutePlannerView.swift"))
        XCTAssertTrue(source.contains("location.north.fill"))
        XCTAssertTrue(source.contains("snorkeling.map.center_current_location"))
        XCTAssertTrue(source.contains("snorkeling.route_points.reset_map"))
        XCTAssertTrue(source.contains("resetCurrentRoutePoints"))
        XCTAssertTrue(source.contains("centerMapOnCurrentLocation"))
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
