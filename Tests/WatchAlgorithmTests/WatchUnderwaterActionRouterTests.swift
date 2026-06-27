import XCTest
@testable import DIRDivingWatchApp

final class WatchUnderwaterActionResolverTests: XCTestCase {
    private func context(
        page: AppPage = .live,
        activity: DIRActivityMode = .diving,
        divingMode: DIRDivingMode = .gauge,
        isSessionActive: Bool = true,
        alarm: String? = nil,
        apneaOverlay: Bool = false,
        stopwatchRunning: Bool = false,
        stopwatchHidden: Bool = false,
        bearing: Double? = nil,
        hasImages: Bool = true
    ) -> WatchUnderwaterActionContext {
        WatchUnderwaterActionContext(
            selectedPage: page,
            selectedActivity: activity,
            selectedDivingMode: divingMode,
            isSessionActive: isSessionActive,
            alarmWarningMessage: alarm,
            apneaOperationalOverlayPresent: apneaOverlay,
            isStopwatchRunning: stopwatchRunning,
            stopwatchHiddenByFullComputer: stopwatchHidden,
            bearingDegrees: bearing,
            hasUserImages: hasImages
        )
    }

    func testAlarmPresentReturnsAcknowledge() {
        XCTAssertEqual(
            WatchUnderwaterActionResolver.resolvedPrimaryAction(context: context(alarm: "DEPTH")),
            .acknowledgeAlarm
        )
    }

    func testApneaOverlayReturnsAcknowledge() {
        XCTAssertEqual(
            WatchUnderwaterActionResolver.resolvedPrimaryAction(context: context(apneaOverlay: true)),
            .acknowledgeAlarm
        )
    }

    func testLiveStopwatchStoppedReturnsStart() {
        XCTAssertEqual(
            WatchUnderwaterActionResolver.resolvedPrimaryAction(context: context(stopwatchRunning: false)),
            .liveStopwatchStart
        )
    }

    func testLiveStopwatchRunningReturnsStop() {
        XCTAssertEqual(
            WatchUnderwaterActionResolver.resolvedPrimaryAction(context: context(stopwatchRunning: true)),
            .liveStopwatchStop
        )
    }

    func testCompassPageReturnsSetOrUpdateBearing() {
        XCTAssertEqual(
            WatchUnderwaterActionResolver.resolvedPrimaryAction(context: context(page: .compass)),
            .compassSetOrUpdateBearing
        )
    }

    func testCompassNotDefaultClearBearing() {
        let action = WatchUnderwaterActionResolver.resolvedPrimaryAction(context: context(page: .compass, bearing: 90))
        XCTAssertEqual(action, .compassSetOrUpdateBearing)
        XCTAssertNotEqual(action, .unavailable(reasonKey: "watch.hardware.action.unavailable"))
    }

    func testSettingsPageReturnsDashboard() {
        XCTAssertEqual(
            WatchUnderwaterActionResolver.resolvedPrimaryAction(context: context(page: .settings)),
            .returnToDashboard
        )
    }

    func testUserImagesPageReturnsNextWhenImagesExist() {
        XCTAssertEqual(
            WatchUnderwaterActionResolver.resolvedPrimaryAction(context: context(page: .userImages, hasImages: true)),
            .userImagesNext
        )
    }

    func testUserImagesUnavailableWithoutImages() {
        XCTAssertEqual(
            WatchUnderwaterActionResolver.resolvedPrimaryAction(context: context(page: .userImages, hasImages: false)),
            .unavailable(reasonKey: "watch.hardware.action.unavailable")
        )
    }

    func testApneaLiveDoesNotStartStopwatch() {
        XCTAssertEqual(
            WatchUnderwaterActionResolver.resolvedPrimaryAction(context: context(activity: .apnea)),
            .unavailable(reasonKey: "watch.hardware.action.unavailable")
        )
    }

    func testFullComputerHiddenStopwatchUnavailableOnLive() {
        XCTAssertEqual(
            WatchUnderwaterActionResolver.resolvedPrimaryAction(
                context: context(divingMode: .fullComputer, stopwatchHidden: true)
            ),
            .unavailable(reasonKey: "watch.hardware.action.unavailable")
        )
    }

    func testInactiveSessionUnavailableOnLive() {
        XCTAssertEqual(
            WatchUnderwaterActionResolver.resolvedPrimaryAction(context: context(isSessionActive: false)),
            .unavailable(reasonKey: "watch.hardware.action.unavailable")
        )
    }

    func testDiveLogPageReturnsDashboard() {
        XCTAssertEqual(
            WatchUnderwaterActionResolver.resolvedPrimaryAction(context: context(page: .diveLog)),
            .returnToDashboard
        )
    }

    func testUnderwaterPrimaryIntentRequiresLegalAcceptanceInSource() throws {
        let repoRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let source = try String(
            contentsOf: repoRoot.appendingPathComponent("Services/ActionButtonIntents.swift"),
            encoding: .utf8
        )
        let pattern = "struct ExecuteUnderwaterPrimaryActionIntent[\\s\\S]*?requireLegalAcceptanceForSafetyIntent\\(\\)"
        let regex = try NSRegularExpression(pattern: pattern)
        let range = NSRange(source.startIndex..<source.endIndex, in: source)
        XCTAssertNotNil(regex.firstMatch(in: source, range: range))
        let blockPattern = "struct ExecuteUnderwaterPrimaryActionIntent[\\s\\S]*?\\n\\}"
        let block = try NSRegularExpression(pattern: blockPattern)
            .firstMatch(in: source, range: range)
            .flatMap { Range($0.range, in: source) }
            .map { String(source[$0]) } ?? ""
        XCTAssertFalse(block.contains("startManualDive()"))
        XCTAssertFalse(block.contains("resetStopwatch()"))
        XCTAssertFalse(block.contains("clearBearing()"))
    }
}

@MainActor
final class WatchUnderwaterActionRouterExecutionTests: XCTestCase {
    func testExecuteStartStopwatchDoesNotReset() {
        let navigation = AppNavigationStore()
        let dive = DiveManager(
            logStore: DiveLogStore(),
            gpsManager: GPSManager(),
            ascentSettings: AscentRateSettingsStore()
        )
        dive.isDiveActive = true
        let router = WatchUnderwaterActionRouter(
            navigation: navigation,
            dive: dive,
            compass: CompassManager(),
            activitySelection: DIRActivitySelectionStore(),
            apneaRuntime: ApneaWatchRuntimeStore(),
            imageStore: UserImageStore()
        )
        dive.startStopwatch()
        XCTAssertTrue(dive.isStopwatchRunning)
        try? router.executePrimaryAction()
        XCTAssertTrue(dive.stopwatchTime > 0)
        dive.stopStopwatch()
        XCTAssertFalse(dive.isStopwatchRunning)
    }
}
