import XCTest

final class SnorkelingChecklistTests: XCTestCase {
    func testDefaultChecklistIsIncomplete() {
        let checklist = SnorkelingPreSnorkelingChecklist.default
        XCTAssertEqual(checklist.completedCount, 0)
    }

    func testCompletedCountTracksCheckedItems() {
        var checklist = SnorkelingPreSnorkelingChecklist.default
        checklist.weatherChecked = true
        checklist.buddyPresent = true
        checklist.watchCharged = true
        XCTAssertEqual(checklist.completedCount, 3)
    }

    func testAllItemsComplete() {
        let checklist = SnorkelingPreSnorkelingChecklist(
            weatherChecked: true,
            currentAssessed: true,
            exitConfirmed: true,
            buddyPresent: true,
            surfaceMarkerBuoy: true,
            watchCharged: true
        )
        XCTAssertEqual(checklist.completedCount, 6)
    }

    func testPlanningMetadataIncludesChecklistCount() {
        var draft = SnorkelingRoutePlannerDraft(name: "Checklist", routeType: .roundTrip)
        draft.entryPoint = SnorkelingRoutePlannerPoint(name: "Entry", role: .entry, latitude: 44.40, longitude: 8.94)
        draft.waypoints = [
            SnorkelingRoutePlannerPoint(name: "WP", role: .waypoint, latitude: 44.401, longitude: 8.941, routeOrder: 0),
        ]
        draft.checklist = SnorkelingPreSnorkelingChecklist(
            weatherChecked: true,
            currentAssessed: true,
            exitConfirmed: false,
            buddyPresent: true,
            surfaceMarkerBuoy: false,
            watchCharged: true
        )
        let metadata = SnorkelingRoutePlanningMetadata.make(from: draft, profile: nil)
        XCTAssertEqual(metadata.checklistCompletedCount, 4)
    }

    func testChecklistRoundTripEncoding() throws {
        var draft = SnorkelingRoutePlannerDraft(name: "Encode")
        draft.checklist = SnorkelingPreSnorkelingChecklist(
            weatherChecked: true,
            currentAssessed: false,
            exitConfirmed: true,
            buddyPresent: false,
            surfaceMarkerBuoy: true,
            watchCharged: false
        )
        let data = try JSONEncoder().encode(draft)
        let restored = try JSONDecoder().decode(SnorkelingRoutePlannerDraft.self, from: data)
        XCTAssertEqual(restored.resolvedChecklist.completedCount, 3)
    }
}
