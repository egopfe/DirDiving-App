import XCTest
@testable import DIRDivingWatchApp

@MainActor
final class DIRModesAndStartupFlowTests: XCTestCase {
    override func setUp() {
        super.setUp()
        #if DEBUG
        DIRStartupSelectionPolicy.resetForTests()
        #endif
    }

    func testDefaultPreferences() {
        XCTAssertTrue(DIRStartupSelectionPolicy.showActivitySelectionAtLaunch)
        XCTAssertEqual(DIRStartupSelectionPolicy.defaultActivityMode, .diving)
        XCTAssertEqual(DIRStartupSelectionPolicy.defaultDivingMode, .gauge)
        XCTAssertFalse(DIRStartupSelectionPolicy.gaugeShowsTTV)
    }

    func testLegacySkipMigrationInvertsShowActivitySelection() {
        UserDefaults.standard.set(true, forKey: WatchModeSelectionPreferences.skipWhenSingleModeKey)
        UserDefaults.standard.removeObject(forKey: "dirdiving_watch_startup_preferences_migrated_v1")
        XCTAssertFalse(DIRStartupSelectionPolicy.showActivitySelectionAtLaunch)
    }

    func testColdLaunchShowsActivityWhenEnabled() {
        DIRStartupSelectionPolicy.showActivitySelectionAtLaunch = true
        XCTAssertEqual(DIRStartupSelectionPolicy.resolveLaunchStep(), .activitySelection)
    }

    func testAutomaticGaugeReadySkipsActivityUI() {
        DIRStartupSelectionPolicy.showActivitySelectionAtLaunch = false
        DIRStartupSelectionPolicy.defaultActivityMode = .diving
        DIRStartupSelectionPolicy.defaultDivingMode = .gauge
        XCTAssertEqual(
            DIRStartupSelectionPolicy.resolveLaunchStep(),
            .ready(activity: .diving, divingMode: .gauge)
        )
    }

    func testAutomaticFullComputerRequiresConfiguration() {
        DIRStartupSelectionPolicy.showActivitySelectionAtLaunch = false
        DIRStartupSelectionPolicy.defaultDivingMode = .fullComputer
        XCTAssertEqual(
            DIRStartupSelectionPolicy.resolveLaunchStep(),
            .fullComputerPrediveConfiguration
        )
    }

    func testApneaRoutesToComingSoon() {
        XCTAssertEqual(
            DIRStartupSelectionPolicy.nextStepAfterActivitySelection(.apnea),
            .comingSoon(activity: .apnea)
        )
    }

    func testDivingRoutesToModeSelection() {
        XCTAssertEqual(
            DIRStartupSelectionPolicy.nextStepAfterActivitySelection(.diving),
            .divingModeSelection(activity: .diving)
        )
    }

    func testFullComputerAlwaysRequiresPrediveConfirmationFlag() {
        XCTAssertTrue(DIRStartupSelectionPolicy.requiresFullComputerPrediveConfirmation(divingMode: .fullComputer))
        XCTAssertFalse(DIRStartupSelectionPolicy.requiresFullComputerPrediveConfirmation(divingMode: .gauge))
    }

    func testActivitySelectionStoreBlocksModeChangeWhenDiveActive() {
        let logStore = DiveLogStore()
        let gps = GPSManager()
        let ascent = AscentRateSettingsStore()
        let dive = DiveManager(logStore: logStore, gpsManager: gps, ascentSettings: ascent)
        let store = DIRActivitySelectionStore()
        dive.isDiveActive = true

        store.selectActivity(.apnea)
        XCTAssertNotNil(store.modeChangeBlockedToast)
        XCTAssertFalse(store.sessionConfigured)
        _ = dive
    }

    func testFullComputerCompletionRequiresExplicitConfirm() {
        FullComputerPrediveConfigurationStore.shared.resetForTests()
        let store = DIRActivitySelectionStore()
        store.selectActivity(.diving)
        store.selectDivingMode(.fullComputer)
        XCTAssertEqual(store.startupStep, .fullComputerPrediveConfiguration)
        XCTAssertFalse(store.sessionConfigured)

        store.proceedToFullComputerConfirmation()
        XCTAssertEqual(store.startupStep, .fullComputerConfirmation)

        store.confirmFullComputerPredive()
        XCTAssertNil(store.startupStep)
        XCTAssertTrue(store.sessionConfigured)
        XCTAssertTrue(store.selection.fullComputerPrediveConfirmed)
        XCTAssertNotNil(FullComputerPrediveConfigurationStore.shared.confirmedProfile)
    }

    func testGaugePathCompletesWithoutPrediveConfirm() {
        let store = DIRActivitySelectionStore()
        store.selectActivity(.diving)
        store.selectDivingMode(.gauge)
        XCTAssertNil(store.startupStep)
        XCTAssertTrue(store.sessionConfigured)
        XCTAssertFalse(store.selection.fullComputerPrediveConfirmed)
    }
}
