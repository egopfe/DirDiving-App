import XCTest
@testable import DIRDivingWatchApp

@MainActor
final class WatchLaunchRoutingPolicyTests: XCTestCase {
    override func setUp() {
        super.setUp()
        #if DEBUG
        DIRStartupSelectionPolicy.resetForTests()
        WatchWaterAutoOpenPolicy.resetForTests()
        #endif
    }

    func testColdLaunchDoesNotUseWaterAutoOpenWhenModeDisabled() {
        WatchWaterAutoOpenPolicy.mode = .disabled
        WatchWaterAutoOpenPolicy.preferredDestination = WatchWaterPreferredLaunchDestination(
            activity: .apnea,
            divingMode: .gauge
        )
        XCTAssertFalse(WatchLaunchRoutingPolicy.shouldApplyWaterAutoOpenRouting(entry: .userColdLaunch))
        XCTAssertEqual(
            WatchLaunchRoutingPolicy.resolveColdLaunchEntryPoint(isSubmergedAtLaunch: true),
            .userColdLaunch
        )
    }

    func testSystemWaterAutoLaunchUsesWaterRoutingWhenEnabled() {
        WatchWaterAutoOpenPolicy.mode = .preferredMode
        WatchWaterAutoOpenPolicy.preferredDestination = WatchWaterPreferredLaunchDestination(
            activity: .apnea,
            divingMode: .gauge
        )
        XCTAssertTrue(WatchLaunchRoutingPolicy.shouldApplyWaterAutoOpenRouting(entry: .systemWaterAutoLaunch))
        let store = DIRActivitySelectionStore()
        store.beginInitialLaunch(entry: .systemWaterAutoLaunch)
        XCTAssertEqual(store.selectedActivity, .apnea)
        XCTAssertTrue(store.sessionConfigured)
    }

    func testResolveColdLaunchEntryPointRoutesWhenSubmergedAndEnabled() {
        WatchWaterAutoOpenPolicy.mode = .preferredMode
        XCTAssertEqual(
            WatchLaunchRoutingPolicy.resolveColdLaunchEntryPoint(isSubmergedAtLaunch: true),
            .systemWaterAutoLaunch
        )
        XCTAssertEqual(
            WatchLaunchRoutingPolicy.resolveColdLaunchEntryPoint(isSubmergedAtLaunch: false),
            .userColdLaunch
        )
    }

    func testWaterAutoOpenIntentUsesWaterRoutingWhenEnabled() {
        WatchWaterAutoOpenPolicy.mode = .preferredMode
        WatchWaterAutoOpenPolicy.preferredDestination = WatchWaterPreferredLaunchDestination(
            activity: .apnea,
            divingMode: .gauge
        )
        XCTAssertTrue(WatchLaunchRoutingPolicy.shouldApplyWaterAutoOpenRouting(entry: .waterAutoLaunchIntent))
        let store = DIRActivitySelectionStore()
        store.beginInitialLaunch(entry: .waterAutoLaunchIntent)
        XCTAssertEqual(store.selectedActivity, .apnea)
        XCTAssertTrue(store.sessionConfigured)
    }

    func testWaterAutoOpenIntentFallsBackWhenDisabled() {
        WatchWaterAutoOpenPolicy.mode = .disabled
        XCTAssertFalse(WatchLaunchRoutingPolicy.shouldApplyWaterAutoOpenRouting(entry: .waterAutoLaunchIntent))
    }

    func testWaterAutoOpenPreferredFullComputerRoutesPrediveConfiguration() {
        WatchWaterAutoOpenPolicy.mode = .preferredMode
        WatchWaterAutoOpenPolicy.preferredDestination = WatchWaterPreferredLaunchDestination(
            activity: .diving,
            divingMode: .fullComputer
        )
        let store = DIRActivitySelectionStore()
        store.beginInitialLaunch(entry: .waterAutoLaunchIntent)
        XCTAssertEqual(store.startupStep, .fullComputerPrediveConfiguration)
    }
}
