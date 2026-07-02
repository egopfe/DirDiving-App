import XCTest

final class SnorkelingWatchRuntimeBatteryTests: XCTestCase {
    func testBatteryFractionPolicyPositiveLevel() {
        let fraction = SnorkelingWatchBatteryFractionPolicy.fraction(fromBatteryLevel: 0.75)
        XCTAssertNotNil(fraction)
        XCTAssertEqual(fraction ?? 0, 0.75, accuracy: 0.001)
    }

    func testBatteryFractionPolicyUnknownLevel() {
        XCTAssertNil(SnorkelingWatchBatteryFractionPolicy.fraction(fromBatteryLevel: -1))
    }

    func testRuntimeStoreUsesBatteryFractionPolicy() throws {
        let source = try String(
            contentsOf: repositoryRoot().appendingPathComponent("Services/SnorkelingWatchRuntimeStore.swift")
        )
        XCTAssertTrue(source.contains("SnorkelingWatchBatteryFractionPolicy.fraction(fromBatteryLevel:"))
        XCTAssertTrue(source.contains("lastBatteryFraction = fraction"))
    }

    func testUnknownBatteryShowsUnknownPresentationCopy() {
        var input = SnorkelingWatchBatteryPresentationTestsFixtures.baseInput()
        input.batteryFraction = nil
        let output = SnorkelingWatchPresentation.make(input)
        XCTAssertEqual(output.batteryText, DIRWatchLocalizer.string("snorkeling.watch.ready.battery_unknown"))
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}

enum SnorkelingWatchBatteryPresentationTestsFixtures {
    static func baseInput() -> SnorkelingWatchPresentationInput {
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
            importedRoutePresentation: .missing,
            microMapPresentation: .unavailable
        )
    }
}
