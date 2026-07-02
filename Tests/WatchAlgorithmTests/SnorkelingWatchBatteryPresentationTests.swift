import XCTest

final class SnorkelingWatchBatteryPresentationTests: XCTestCase {
    func testBatteryFractionSurfacesInPresentation() {
        var input = baseInput()
        input.batteryFraction = 0.62
        let output = SnorkelingWatchPresentation.make(input)
        XCTAssertEqual(
            output.batteryText,
            String(format: DIRWatchLocalizer.string("snorkeling.watch.ready.battery"), 62)
        )
        XCTAssertEqual(output.batteryColorToken, .green)
    }

    func testLowBatteryWarningBelowThreshold() {
        var input = baseInput()
        input.batteryFraction = 0.15
        let output = SnorkelingWatchPresentation.make(input)
        XCTAssertEqual(
            output.batteryText,
            String(format: DIRWatchLocalizer.string("snorkeling.watch.ready.battery_low"), 15)
        )
        XCTAssertEqual(output.batteryColorToken, .yellow)
        XCTAssertTrue(
            SnorkelingWatchReadyPresentationPolicy.batteryPresentation(fraction: 0.15).isLow
        )
    }

    private func baseInput() -> SnorkelingWatchPresentationInput {
        SnorkelingWatchPresentationInput(
            phase: .ready,
            isSessionArmed: false,
            isSessionStarted: false,
            showSessionSummary: false,
            showSaveMarker: false,
            currentDepthMeters: nil,
            currentTemperatureCelsius: nil,
            verticalSpeedMetersPerSecond: 0,
            sessionElapsedSeconds: 0,
            surfaceElapsedSeconds: 0,
            underwaterTimeSeconds: 0,
            activeDipElapsedSeconds: 0,
            dipCount: 0,
            sessionMaxDepthMeters: 0,
            activeDipMaxDepthMeters: 0,
            accumulatedDistanceMeters: 0,
            averageSpeedMetersPerSecond: 0,
            gpsPresentationState: .tracking,
            depthPresentationState: .valid,
            sensorHealth: .available,
            entryPointCaptured: false,
            entryDistanceMeters: nil,
            targetDurationSeconds: nil,
            maxDistanceMeters: nil,
            missionModeEnabled: false,
            hapticsEnabled: true,
            buddyReminderEnabled: false,
            batteryFraction: nil,
            markerCount: 0,
            minimumWaterTemperatureCelsius: nil,
            waypointNavigation: .unavailable,
            returnNavigation: .unavailable,
            activeOverlays: [],
            isUnderwater: false,
            animationsEnabled: true,
            selectedMarkerCategory: .reef,
            markerPositionQualityLabel: "",
            markerDistanceFromEntryText: nil,
            sessionSaveState: .notSaved,
            isRecoveredSession: false,
            recoveryWarning: nil,
            gpsQualityBand: nil,
            routeProgressPercent: nil,
            offRouteDistanceMeters: nil,
            isOffRoute: false,
            offRouteWarningPaused: false,
            plannedReturnAlertActive: false,
            importedRoutePresentation: .missing
        )
    }
}
