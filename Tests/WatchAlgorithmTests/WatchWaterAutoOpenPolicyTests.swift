import XCTest
@testable import DIRDivingWatchApp

@MainActor
final class WatchWaterAutoOpenPolicyTests: XCTestCase {
    override func setUp() {
        super.setUp()
        #if DEBUG
        DIRStartupSelectionPolicy.resetForTests()
        WatchWaterAutoOpenPolicy.resetForTests()
        #endif
    }

    func testDefaultModeIsDisabled() {
        XCTAssertEqual(WatchWaterAutoOpenPolicy.mode, .disabled)
    }

    func testDefaultPreferredDestinationIsValid() {
        let preferred = WatchWaterAutoOpenPolicy.preferredDestination
        XCTAssertEqual(preferred.activity, .diving)
        XCTAssertEqual(preferred.divingMode, .gauge)
    }

    func testCorruptStoredModeFallsBackToDisabled() {
        UserDefaults.standard.set("not-a-mode", forKey: WatchWaterAutoOpenPolicy.modeKey)
        UserDefaults.standard.set(true, forKey: WatchWaterAutoOpenPolicy.migratedKey)
        XCTAssertEqual(WatchWaterAutoOpenPolicy.mode, .disabled)
    }

    func testCorruptStoredActivityFallsBackToDiving() {
        UserDefaults.standard.set("invalid", forKey: WatchWaterAutoOpenPolicy.preferredActivityKey)
        UserDefaults.standard.set(true, forKey: WatchWaterAutoOpenPolicy.migratedKey)
        XCTAssertEqual(WatchWaterAutoOpenPolicy.preferredDestination.activity, .diving)
    }

    func testCorruptStoredDivingModeFallsBackToGauge() {
        UserDefaults.standard.set("invalid", forKey: WatchWaterAutoOpenPolicy.preferredDivingModeKey)
        UserDefaults.standard.set(true, forKey: WatchWaterAutoOpenPolicy.migratedKey)
        XCTAssertEqual(WatchWaterAutoOpenPolicy.preferredDestination.divingMode, .gauge)
    }

    func testRecordSelectedDestinationStoresDivingGauge() {
        WatchWaterAutoOpenPolicy.recordSelectedDestination(activity: .diving, divingMode: .gauge)
        XCTAssertEqual(WatchWaterAutoOpenPolicy.lastSelectedDestination.activity, .diving)
        XCTAssertEqual(WatchWaterAutoOpenPolicy.lastSelectedDestination.divingMode, .gauge)
    }

    func testRecordSelectedDestinationStoresDivingFullComputer() {
        WatchWaterAutoOpenPolicy.recordSelectedDestination(activity: .diving, divingMode: .fullComputer)
        XCTAssertEqual(WatchWaterAutoOpenPolicy.lastSelectedDestination.divingMode, .fullComputer)
    }

    func testRecordSelectedDestinationStoresApnea() {
        WatchWaterAutoOpenPolicy.recordSelectedDestination(activity: .apnea, divingMode: .gauge)
        XCTAssertEqual(WatchWaterAutoOpenPolicy.lastSelectedDestination.activity, .apnea)
    }

    func testRecordSelectedDestinationStoresSnorkeling() {
        WatchWaterAutoOpenPolicy.recordSelectedDestination(activity: .snorkeling, divingMode: .gauge)
        XCTAssertEqual(WatchWaterAutoOpenPolicy.lastSelectedDestination.activity, .snorkeling)
    }

    func testLastSelectedModeResolvesToStoredDestination() {
        WatchWaterAutoOpenPolicy.recordSelectedDestination(activity: .apnea, divingMode: .gauge)
        WatchWaterAutoOpenPolicy.mode = .lastSelectedMode
        XCTAssertEqual(
            DIRStartupSelectionPolicy.resolveWaterAutoLaunchStep(),
            .ready(activity: .apnea, divingMode: .gauge)
        )
    }

    func testPreferredDivingGaugeResolvesToReady() {
        WatchWaterAutoOpenPolicy.mode = .preferredMode
        WatchWaterAutoOpenPolicy.preferredDestination = WatchWaterPreferredLaunchDestination(
            activity: .diving,
            divingMode: .gauge
        )
        XCTAssertEqual(
            DIRStartupSelectionPolicy.resolveWaterAutoLaunchStep(),
            .ready(activity: .diving, divingMode: .gauge)
        )
    }

    func testPreferredDivingFullComputerResolvesToPrediveConfiguration() {
        WatchWaterAutoOpenPolicy.mode = .preferredMode
        WatchWaterAutoOpenPolicy.preferredDestination = WatchWaterPreferredLaunchDestination(
            activity: .diving,
            divingMode: .fullComputer
        )
        XCTAssertEqual(
            DIRStartupSelectionPolicy.resolveWaterAutoLaunchStep(),
            .fullComputerPrediveConfiguration
        )
    }

    func testPreferredApneaResolvesToReady() {
        WatchWaterAutoOpenPolicy.mode = .preferredMode
        WatchWaterAutoOpenPolicy.preferredDestination = WatchWaterPreferredLaunchDestination(
            activity: .apnea,
            divingMode: .gauge
        )
        XCTAssertEqual(
            DIRStartupSelectionPolicy.resolveWaterAutoLaunchStep(),
            .ready(activity: .apnea, divingMode: .gauge)
        )
    }

    func testPreferredSnorkelingResolvesToReady() {
        WatchWaterAutoOpenPolicy.mode = .preferredMode
        WatchWaterAutoOpenPolicy.preferredDestination = WatchWaterPreferredLaunchDestination(
            activity: .snorkeling,
            divingMode: .gauge
        )
        XCTAssertEqual(
            DIRStartupSelectionPolicy.resolveWaterAutoLaunchStep(),
            .ready(activity: .snorkeling, divingMode: .gauge)
        )
    }

    func testDisabledUsesNormalResolveLaunchStep() {
        DIRStartupSelectionPolicy.showActivitySelectionAtLaunch = true
        WatchWaterAutoOpenPolicy.mode = .disabled
        XCTAssertEqual(
            DIRStartupSelectionPolicy.resolveWaterAutoLaunchStep(),
            DIRStartupSelectionPolicy.resolveLaunchStep()
        )
    }

    func testBeginWaterAutoLaunchBlockedWhenDiveActive() {
        let logStore = DiveLogStore()
        let gps = GPSManager()
        let ascent = AscentRateSettingsStore()
        let dive = DiveManager(logStore: logStore, gpsManager: gps, ascentSettings: ascent)
        let store = DIRActivitySelectionStore()
        dive.isDiveActive = true
        WatchWaterAutoOpenPolicy.mode = .preferredMode
        WatchWaterAutoOpenPolicy.preferredDestination = WatchWaterPreferredLaunchDestination(
            activity: .apnea,
            divingMode: .gauge
        )

        store.beginWaterAutoLaunch()
        XCTAssertNotNil(store.modeChangeBlockedToast)
        XCTAssertFalse(store.sessionConfigured)
        _ = dive
    }

    func testBeginWaterAutoLaunchBlockedWhenApneaSessionActive() {
        let store = DIRActivitySelectionStore()
        let apnea = ApneaWatchRuntimeStore()
        apnea.armSession()
        WatchWaterAutoOpenPolicy.mode = .preferredMode
        WatchWaterAutoOpenPolicy.preferredDestination = WatchWaterPreferredLaunchDestination(
            activity: .snorkeling,
            divingMode: .gauge
        )

        store.beginWaterAutoLaunch()
        XCTAssertNotNil(store.modeChangeBlockedToast)
        XCTAssertFalse(store.sessionConfigured)
        _ = apnea
    }

    func testBeginWaterAutoLaunchBlockedWhenSnorkelingSessionActive() {
        let store = DIRActivitySelectionStore()
        let snorkeling = SnorkelingWatchRuntimeStore()
        snorkeling.armSession()
        snorkeling.startSession()
        WatchWaterAutoOpenPolicy.mode = .preferredMode
        WatchWaterAutoOpenPolicy.preferredDestination = WatchWaterPreferredLaunchDestination(
            activity: .apnea,
            divingMode: .gauge
        )

        store.beginWaterAutoLaunch()
        XCTAssertNotNil(store.modeChangeBlockedToast)
        XCTAssertFalse(store.sessionConfigured)
        _ = snorkeling
    }

    func testBeginWaterAutoLaunchRoutesPreferredApneaWhenIdle() {
        let store = DIRActivitySelectionStore()
        WatchWaterAutoOpenPolicy.mode = .preferredMode
        WatchWaterAutoOpenPolicy.preferredDestination = WatchWaterPreferredLaunchDestination(
            activity: .apnea,
            divingMode: .gauge
        )

        store.beginWaterAutoLaunch()
        XCTAssertNil(store.startupStep)
        XCTAssertTrue(store.sessionConfigured)
        XCTAssertEqual(store.selectedActivity, .apnea)
    }

    func testCompleteStartupRecordsLastSelectedDestination() {
        let store = DIRActivitySelectionStore()
        store.selectActivity(.snorkeling)
        XCTAssertEqual(WatchWaterAutoOpenPolicy.lastSelectedDestination.activity, .snorkeling)
    }

    func testOpenWaterAutoLaunchIntentRequiresLegalAcceptanceInSource() throws {
        let repoRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let source = try String(
            contentsOf: repoRoot.appendingPathComponent("Services/ActionButtonIntents.swift"),
            encoding: .utf8
        )
        let pattern = "struct OpenWaterAutoLaunchModeIntent[\\s\\S]*?requireLegalAcceptanceForSafetyIntent\\(\\)"
        let regex = try NSRegularExpression(pattern: pattern)
        let range = NSRange(source.startIndex..<source.endIndex, in: source)
        XCTAssertNotNil(regex.firstMatch(in: source, range: range))
        let intentBlockPattern = "struct OpenWaterAutoLaunchModeIntent[\\s\\S]*?\\n\\}"
        let blockRegex = try NSRegularExpression(pattern: intentBlockPattern)
        let block = blockRegex.firstMatch(in: source, range: range).flatMap {
            Range($0.range, in: source).map { String(source[$0]) }
        } ?? ""
        XCTAssertFalse(block.contains("startManualDive()"))
        XCTAssertTrue(block.contains("beginWaterAutoLaunch()"))
    }
}
