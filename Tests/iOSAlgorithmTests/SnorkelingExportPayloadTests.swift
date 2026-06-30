import XCTest
@testable import DIRDivingiOSApp

final class SnorkelingExportPayloadTests: XCTestCase {
    func testShareTextIncludesDistanceDurationAndSafetyCopy() {
        var draft = SnorkelingRoutePlannerDraft(name: "Reef loop", routeType: .roundTrip)
        draft.entryPoint = SnorkelingRoutePlannerPoint(name: "Entry", role: .entry, latitude: 44.40, longitude: 8.94)
        draft.waypoints = [
            SnorkelingRoutePlannerPoint(name: "Reef", role: .waypoint, latitude: 44.401, longitude: 8.941, routeOrder: 0),
        ]
        let validation = SnorkelingRouteValidator.validate(draft: draft, profile: nil)
        let text = SnorkelingRoutePlanExportFormatter.shareText(draft: draft, profile: nil, validation: validation)
        XCTAssertTrue(text.contains("Reef loop"))
        XCTAssertTrue(text.contains("Estimated distance:"))
        XCTAssertTrue(text.contains("Estimated duration:"))
        XCTAssertTrue(text.contains("Route check: \(validation.status.rawValue)"))
        XCTAssertTrue(text.contains("GPS-based orientation aid"))
    }

    func testShareTextListsWaypointsAndExitForDifferentExit() {
        var draft = SnorkelingRoutePlannerDraft(name: "Coastal", routeType: .differentExit)
        draft.entryPoint = SnorkelingRoutePlannerPoint(name: "Beach", role: .entry, latitude: 44.40, longitude: 8.94)
        draft.exitPoint = SnorkelingRoutePlannerPoint(name: "Pier", role: .exit, latitude: 44.41, longitude: 8.95)
        draft.waypoints = [
            SnorkelingRoutePlannerPoint(name: "Rock", role: .waypoint, latitude: 44.405, longitude: 8.945, routeOrder: 0),
        ]
        let validation = SnorkelingRouteValidator.validate(draft: draft, profile: nil)
        let text = SnorkelingRoutePlanExportFormatter.shareText(draft: draft, profile: nil, validation: validation)
        XCTAssertTrue(text.contains("Entry:"))
        XCTAssertTrue(text.contains("Rock:"))
        XCTAssertTrue(text.contains("Exit:"))
        XCTAssertTrue(text.contains("differentExit"))
    }

    func testWarningStatusIncludedInExport() {
        var draft = SnorkelingRoutePlannerDraft(name: "Long", routeProfileKind: .photoReefObservation)
        draft.entryPoint = SnorkelingRoutePlannerPoint(name: "A", role: .entry, latitude: 0, longitude: 0)
        draft.exitPoint = SnorkelingRoutePlannerPoint(name: "B", role: .exit, latitude: 0, longitude: 0.04)
        let validation = SnorkelingRouteValidator.validate(draft: draft, profile: nil)
        let text = SnorkelingRoutePlanExportFormatter.shareText(draft: draft, profile: nil, validation: validation)
        XCTAssertEqual(validation.status, .warning)
        XCTAssertTrue(text.contains("Warnings:"))
    }

    @MainActor
    func testFakeLogbookDoesNotPolluteRealStoreStatistics() {
        let store = IOSSnorkelingLogbookStore()
        let beforeCount = store.sessions.count
        _ = FakeSnorkelingLogbookProvider.entries()
        XCTAssertEqual(store.sessions.count, beforeCount)
        for session in FakeSnorkelingLogbookProvider.entries() {
            XCTAssertTrue(DemoSnorkelingSessionCatalog.isDemoSession(id: session.id))
        }
    }
}
