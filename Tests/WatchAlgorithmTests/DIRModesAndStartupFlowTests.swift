import XCTest
@testable import DIRDivingWatchApp

@MainActor
final class DIRModesAndStartupFlowTests: XCTestCase {
    override func setUp() {
        super.setUp()
        #if DEBUG
        DIRStartupSelectionPolicy.resetForTests()
        DeveloperSettings.resetShallowDepthDivingTestingForTests()
        UserDefaults.standard.removeObject(forKey: SensorSourceMode.storageKey)
        #endif
    }

    override func tearDown() {
        #if DEBUG
        DeveloperSettings.resetShallowDepthDivingTestingForTests()
        UserDefaults.standard.removeObject(forKey: SensorSourceMode.storageKey)
        #endif
        super.tearDown()
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
        DeveloperSettings.setShallowGaugeTestingEnabled(true)
        DIRStartupSelectionPolicy.showActivitySelectionAtLaunch = false
        DIRStartupSelectionPolicy.defaultActivityMode = .diving
        DIRStartupSelectionPolicy.defaultDivingMode = .gauge
        XCTAssertEqual(
            DIRStartupSelectionPolicy.resolveLaunchStep(),
            .ready(activity: .diving, divingMode: .gauge)
        )
    }

    func testAutomaticFullComputerRequiresConfiguration() {
        DeveloperSettings.setShallowDepthDivingTestingEnabled(true)
        DIRStartupSelectionPolicy.showActivitySelectionAtLaunch = false
        DIRStartupSelectionPolicy.defaultDivingMode = .fullComputer
        XCTAssertEqual(
            DIRStartupSelectionPolicy.resolveLaunchStep(),
            .fullComputerPrediveConfiguration
        )
    }

    func testApneaRoutesToReady() {
        XCTAssertEqual(
            DIRStartupSelectionPolicy.nextStepAfterActivitySelection(.apnea),
            .ready(activity: .apnea, divingMode: .gauge)
        )
    }

    func testSnorkelingRoutesToReady() {
        XCTAssertEqual(
            DIRStartupSelectionPolicy.nextStepAfterActivitySelection(.snorkeling),
            .ready(activity: .snorkeling, divingMode: .gauge)
        )
    }

    func testWatchLaunchabilityPolicyAllowsSnorkelingOnMAIN() {
        XCTAssertTrue(DIRActivityMode.diving.isLaunchableOnWatchMAIN)
        XCTAssertTrue(DIRActivityMode.apnea.isLaunchableOnWatchMAIN)
        XCTAssertTrue(DIRActivityMode.snorkeling.isLaunchableOnWatchMAIN)
    }

    func testPermanentModeTabHiddenOnMAIN() {
        XCTAssertFalse(WatchModeSelectionPreferences.hasMultipleStableModes)
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
        DeveloperSettings.setShallowDepthDivingTestingEnabled(true)
        FullComputerPrediveConfigurationStore.shared.resetForTests()
        FullComputerPrediveConfigurationStore.shared.setDraftEnvironment(
            altitudeMeters: 0,
            salinity: .salt,
            source: .watchSettingsManual
        )
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
        DeveloperSettings.setShallowGaugeTestingEnabled(true)
        let store = DIRActivitySelectionStore()
        store.selectActivity(.diving)
        store.selectDivingMode(.gauge)
        XCTAssertNil(store.startupStep)
        XCTAssertTrue(store.sessionConfigured)
        XCTAssertFalse(store.selection.fullComputerPrediveConfirmed)
    }
}
