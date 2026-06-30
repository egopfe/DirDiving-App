import XCTest

final class SnorkelingRouteValidatorTests: XCTestCase {
    func testIncompleteWithoutEntry() {
        var draft = SnorkelingRoutePlannerDraft(name: "No entry")
        draft.exitPoint = SnorkelingRoutePlannerPoint(name: "Exit", role: .exit, latitude: 44.41, longitude: 8.95)
        let result = SnorkelingRouteValidator.validate(draft: draft, profile: nil)
        XCTAssertEqual(result.status, .incomplete)
        XCTAssertTrue(result.issues.contains(.missingEntry))
    }

    func testIncompleteWithoutExitForDifferentExit() {
        var draft = SnorkelingRoutePlannerDraft(name: "No exit", routeType: .differentExit)
        draft.entryPoint = SnorkelingRoutePlannerPoint(name: "Entry", role: .entry, latitude: 44.40, longitude: 8.94)
        let result = SnorkelingRouteValidator.validate(draft: draft, profile: nil)
        XCTAssertEqual(result.status, .incomplete)
        XCTAssertTrue(result.issues.contains(.missingExit))
    }

    func testReadyForRoundTripWithEntryOnly() {
        var draft = SnorkelingRoutePlannerDraft(name: "Round", routeType: .roundTrip)
        draft.entryPoint = SnorkelingRoutePlannerPoint(name: "Entry", role: .entry, latitude: 44.40, longitude: 8.94)
        draft.waypoints = [
            SnorkelingRoutePlannerPoint(name: "WP", role: .waypoint, latitude: 44.401, longitude: 8.941, routeOrder: 0),
        ]
        let result = SnorkelingRouteValidator.validate(draft: draft, profile: nil)
        XCTAssertEqual(result.status, .ready)
        XCTAssertTrue(result.allowsWatchTransfer)
        XCTAssertGreaterThanOrEqual(draft.routingPoints.count, 2)
    }

    func testWarningWhenDistanceExceedsProfileLimit() {
        var draft = SnorkelingRoutePlannerDraft(name: "Long", routeProfileKind: .relaxBeginner)
        draft.entryPoint = SnorkelingRoutePlannerPoint(name: "A", role: .entry, latitude: 0, longitude: 0)
        draft.exitPoint = SnorkelingRoutePlannerPoint(name: "B", role: .exit, latitude: 0, longitude: 0.05)
        let result = SnorkelingRouteValidator.validate(draft: draft, profile: nil)
        XCTAssertEqual(result.status, .warning)
        XCTAssertTrue(result.warnings.contains(.exceedsProfileDistance))
        XCTAssertTrue(result.allowsWatchTransfer)
    }

    func testBlockedForInvalidCoordinate() {
        var draft = SnorkelingRoutePlannerDraft(name: "Bad")
        draft.entryPoint = SnorkelingRoutePlannerPoint(name: "A", role: .entry, latitude: 91, longitude: 0)
        draft.exitPoint = SnorkelingRoutePlannerPoint(name: "B", role: .exit, latitude: 0, longitude: 0)
        let result = SnorkelingRouteValidator.validate(draft: draft, profile: nil)
        XCTAssertEqual(result.status, .blocked)
        XCTAssertFalse(result.allowsWatchTransfer)
    }

    func testExitFarFromEntryAddsWarning() {
        var draft = SnorkelingRoutePlannerDraft(name: "Far exit", routeType: .differentExit, routeProfileKind: .relaxBeginner)
        draft.entryPoint = SnorkelingRoutePlannerPoint(name: "Entry", role: .entry, latitude: 44.40, longitude: 8.94)
        draft.exitPoint = SnorkelingRoutePlannerPoint(name: "Exit", role: .exit, latitude: 44.50, longitude: 9.04)
        let result = SnorkelingRouteValidator.validate(draft: draft, profile: nil)
        XCTAssertTrue(result.warnings.contains(.exitFarFromEntry))
    }
}
