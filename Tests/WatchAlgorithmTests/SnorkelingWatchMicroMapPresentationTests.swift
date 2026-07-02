import XCTest

final class SnorkelingWatchMicroMapPresentationTests: XCTestCase {
    func testMicroMapUnavailableWhenGPSUnavailable() {
        let presentation = SnorkelingWatchMicroMapPresentationPolicy.make(
            routeCoordinates: sampleRoute(),
            current: SnorkelingCoordinate(latitude: 44.10, longitude: 8.90),
            entry: nil,
            nextWaypoint: nil,
            headingDegrees: 90,
            headingQuality: .valid,
            gpsPresentationState: .unavailable,
            isUnderwater: false
        )
        XCTAssertFalse(presentation.isAvailable)
        XCTAssertEqual(presentation.unavailableReasonKey, "snorkeling.watch.micro_map.unavailable")
    }

    func testMicroMapUnavailableWhenUnderwater() {
        let presentation = SnorkelingWatchMicroMapPresentationPolicy.make(
            routeCoordinates: sampleRoute(),
            current: SnorkelingCoordinate(latitude: 44.10, longitude: 8.90),
            entry: nil,
            nextWaypoint: nil,
            headingDegrees: 90,
            headingQuality: .valid,
            gpsPresentationState: .tracking,
            isUnderwater: true
        )
        XCTAssertFalse(presentation.isAvailable)
    }

    func testMicroMapAvailableWithRouteAndTrackingGPS() {
        let waypoint = SnorkelingWaypoint(
            name: "Reef",
            category: .reef,
            latitude: 44.101,
            longitude: 8.901
        )
        let presentation = SnorkelingWatchMicroMapPresentationPolicy.make(
            routeCoordinates: sampleRoute(),
            current: SnorkelingCoordinate(latitude: 44.10, longitude: 8.90),
            entry: SnorkelingEntryPoint(
                latitude: 44.099,
                longitude: 8.899,
                capturedAt: Date(),
                monotonicRelativeTimestampSeconds: 0,
                gpsQuality: .measured
            ),
            nextWaypoint: waypoint,
            headingDegrees: 45,
            headingQuality: .valid,
            gpsPresentationState: .tracking,
            isUnderwater: false
        )
        XCTAssertTrue(presentation.isAvailable)
        XCTAssertFalse(presentation.routeLine.isEmpty)
        XCTAssertNotNil(presentation.entryDirectionDegrees)
        XCTAssertNotNil(presentation.nextWaypointPoint)
    }

    func testMicroMapDownsamplesLongRoute() {
        var coordinates: [SnorkelingCoordinate] = []
        for index in 0..<80 {
            coordinates.append(
                SnorkelingCoordinate(
                    latitude: 44.10 + Double(index) * 0.0001,
                    longitude: 8.90 + Double(index) * 0.0001
                )
            )
        }
        let presentation = SnorkelingWatchMicroMapPresentationPolicy.make(
            routeCoordinates: coordinates,
            current: coordinates.last,
            entry: nil,
            nextWaypoint: nil,
            headingDegrees: 0,
            headingQuality: .valid,
            gpsPresentationState: .tracking,
            isUnderwater: false
        )
        XCTAssertTrue(presentation.isAvailable)
        XCTAssertLessThan(presentation.routeLine.count, coordinates.count)
        XCTAssertLessThanOrEqual(presentation.routeLine.count, SnorkelingWatchMicroMapPresentationPolicy.maxRoutePoints + 4)
    }

    private func sampleRoute() -> [SnorkelingCoordinate] {
        [
            SnorkelingCoordinate(latitude: 44.10, longitude: 8.90),
            SnorkelingCoordinate(latitude: 44.101, longitude: 8.901),
            SnorkelingCoordinate(latitude: 44.102, longitude: 8.902),
        ]
    }
}
