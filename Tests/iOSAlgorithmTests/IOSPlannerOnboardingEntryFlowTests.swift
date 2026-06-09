import XCTest
@testable import DIRDivingiOSApp

@MainActor
final class IOSPlannerOnboardingEntryFlowTests: XCTestCase {
    func testPreparePostLegalOnboardingEntryShowsModeSelection() {
        let planner = PlannerStore(cloudSync: nil)
        planner.plannerShowsModeSelection = false
        planner.preparePostLegalOnboardingEntry()
        XCTAssertTrue(planner.plannerShowsModeSelection)
    }

    func testFreshPlannerStoreDefaultsToModeSelectionWithoutSavedState() {
        let planner = PlannerStore(cloudSync: nil)
        XCTAssertTrue(planner.plannerShowsModeSelection)
    }

    func testSelectPlannerModeHidesModeSelection() {
        let planner = PlannerStore(cloudSync: nil)
        planner.selectPlannerMode(.deco)
        XCTAssertFalse(planner.plannerShowsModeSelection)
        XCTAssertEqual(planner.mode, .deco)
    }

    func testReturnToPlannerModeSelectionShowsCardsAgain() {
        let planner = PlannerStore(cloudSync: nil)
        planner.selectPlannerMode(.technical)
        planner.returnToPlannerModeSelection()
        XCTAssertTrue(planner.plannerShowsModeSelection)
    }
}
