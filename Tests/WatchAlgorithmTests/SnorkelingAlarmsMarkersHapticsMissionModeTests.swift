import XCTest

final class SnorkelingAlarmsMarkersHapticsMissionModeTests: XCTestCase {
    private let startDate = Date(timeIntervalSince1970: 1_700_000_000)

    func testDepthAlarmThresholdWithHysteresis() {
        var state = SnorkelingOperationalEventState.initial
        let alarm = SnorkelingAlarm(
            kind: .maxDepth,
            label: "Depth 5m",
            thresholdDepthMeters: 5,
            hysteresisMeters: 0.5,
            minimumRepeatSeconds: 2
        )

        let first = evaluate(alarms: [alarm], depth: 5.2, verticalSpeed: 0.2, state: &state, elapsed: 1)
        XCTAssertEqual(first.events.filter { $0.kind == .alarmTriggered }.count, 1)

        let oscillation = evaluate(alarms: [alarm], depth: 5.1, verticalSpeed: 0.1, state: &state, elapsed: 1.5)
        XCTAssertTrue(oscillation.events.isEmpty)

        let rearmed = evaluate(alarms: [alarm], depth: 4.3, verticalSpeed: -0.3, state: &state, elapsed: 2)
        XCTAssertTrue(rearmed.events.isEmpty)
        let refire = evaluate(alarms: [alarm], depth: 5.3, verticalSpeed: 0.4, state: &state, elapsed: 4)
        XCTAssertEqual(refire.events.filter { $0.kind == .alarmTriggered }.count, 1)
    }

    func testSimultaneousAlarmsEmitDistinctEventsWithRateLimit() {
        var state = SnorkelingOperationalEventState.initial
        let depthAlarm = SnorkelingAlarm(kind: .maxDepth, label: "Depth", thresholdDepthMeters: 4, minimumRepeatSeconds: 2)
        let durationAlarm = SnorkelingAlarm(kind: .maxDuration, label: "Time", thresholdDurationSeconds: 60, minimumRepeatSeconds: 2)

        let first = evaluate(
            alarms: [depthAlarm, durationAlarm],
            depth: 4.5,
            verticalSpeed: 0.1,
            state: &state,
            elapsed: 61
        )
        XCTAssertEqual(first.events.filter { $0.kind == .alarmTriggered }.count, 2)

        let throttled = evaluate(
            alarms: [depthAlarm, durationAlarm],
            depth: 4.6,
            verticalSpeed: 0.1,
            state: &state,
            elapsed: 62
        )
        XCTAssertTrue(throttled.events.isEmpty)
        XCTAssertEqual(throttled.overlays.count, 2)
    }

    func testMarkerWithoutFixCanBeSavedWhenAllowed() {
        let result = SnorkelingMarkerCaptureEngine.capture(
            request: SnorkelingMarkerCaptureRequest(
                category: .reef,
                note: "No GPS",
                allowSaveWithoutCoordinates: true
            ),
            monotonicNow: 10,
            wallClockNow: startDate,
            sessionID: UUID(),
            depthMeters: 1.2,
            temperatureCelsius: 22,
            headingDegrees: nil,
            isUnderwater: false,
            gpsAcceptedFix: nil,
            gpsPresentationState: .unavailable,
            entryPoint: nil,
            hapticsEnabled: true,
            missionModeEnabled: false
        )
        XCTAssertNotNil(result.marker)
        XCTAssertEqual(result.marker?.positionQuality, .noFix)
        XCTAssertNil(result.marker?.latitude)
        XCTAssertTrue(SnorkelingDomainValidator.validate(marker: result.marker!).isEmpty)
    }

    func testMarkerWithoutFixRejectedWhenCoordinatesRequired() {
        let result = SnorkelingMarkerCaptureEngine.capture(
            request: SnorkelingMarkerCaptureRequest(
                category: .photoSpot,
                allowSaveWithoutCoordinates: false
            ),
            monotonicNow: 10,
            wallClockNow: startDate,
            sessionID: UUID(),
            depthMeters: 0.5,
            temperatureCelsius: nil,
            headingDegrees: nil,
            isUnderwater: false,
            gpsAcceptedFix: nil,
            gpsPresentationState: .unavailable,
            entryPoint: nil,
            hapticsEnabled: true,
            missionModeEnabled: false
        )
        XCTAssertEqual(result.rejection, .coordinateRequired)
    }

    func testCustomCategoryRequiresLabel() {
        let result = SnorkelingMarkerCaptureEngine.capture(
            request: SnorkelingMarkerCaptureRequest(
                category: .custom,
                customCategoryLabel: " ",
                allowSaveWithoutCoordinates: true
            ),
            monotonicNow: 1,
            wallClockNow: startDate,
            sessionID: UUID(),
            depthMeters: 0.2,
            temperatureCelsius: nil,
            headingDegrees: nil,
            isUnderwater: false,
            gpsAcceptedFix: nil,
            gpsPresentationState: .unavailable,
            entryPoint: nil,
            hapticsEnabled: true,
            missionModeEnabled: false
        )
        XCTAssertEqual(result.rejection, .invalidCustomCategory)
    }

    func testMeasuredMarkerIncludesEntryDistanceAndBearing() {
        let entry = SnorkelingEntryPoint(
            latitude: 44.40000,
            longitude: 8.94000,
            capturedAt: startDate,
            monotonicRelativeTimestampSeconds: 0,
            gpsQuality: .measured
        )
        let fix = acceptedFix(lat: 44.40012, lon: 8.94012, offset: 5)
        let result = SnorkelingMarkerCaptureEngine.capture(
            request: SnorkelingMarkerCaptureRequest(category: .marineLife, allowSaveWithoutCoordinates: false),
            monotonicNow: 5,
            wallClockNow: startDate.addingTimeInterval(5),
            sessionID: UUID(),
            depthMeters: 0.4,
            temperatureCelsius: 23,
            headingDegrees: 90,
            isUnderwater: false,
            gpsAcceptedFix: fix,
            gpsPresentationState: .tracking,
            entryPoint: entry,
            hapticsEnabled: true,
            missionModeEnabled: false
        )
        XCTAssertEqual(result.marker?.positionQuality, .measured)
        XCTAssertGreaterThan(result.marker?.distanceFromEntryMeters ?? 0, 0)
        XCTAssertNotNil(result.marker?.bearingFromEntryDegrees)
    }

    func testHapticsDisabledStillProvidesVisualFallback() {
        var state = SnorkelingOperationalEventState.initial
        let alarm = SnorkelingAlarm(kind: .maxDepth, label: "Depth", thresholdDepthMeters: 3)
        let output = evaluate(
            alarms: [alarm],
            depth: 3.5,
            verticalSpeed: 0,
            state: &state,
            elapsed: 1,
            hapticsEnabled: false
        )
        XCTAssertFalse(output.overlays.isEmpty)
        XCTAssertTrue(output.hapticCues.isEmpty)
    }

    func testMissionModeDoesNotDisableAlarmsOrHaptics() {
        var state = SnorkelingOperationalEventState.initial
        let alarm = SnorkelingAlarm(kind: .batteryLow, label: "Battery", thresholdBatteryPercent: 0.2)
        let output = evaluate(
            alarms: [alarm],
            depth: 1,
            verticalSpeed: 0,
            state: &state,
            elapsed: 1,
            batteryFraction: 0.15,
            missionMode: true
        )
        XCTAssertEqual(output.events.first?.kind, .alarmTriggered)
        XCTAssertEqual(output.hapticCues.first?.pattern, .alarmCritical)
    }

    func testMissionModeReducesPresentationRefreshInterval() {
        XCTAssertGreaterThan(
            SnorkelingMissionModePresentationProfile.mission.minimumPresentationRefreshSeconds,
            SnorkelingMissionModePresentationProfile.standard.minimumPresentationRefreshSeconds
        )
        XCTAssertFalse(SnorkelingMissionModePresentationProfile.mission.animationsEnabled)
    }

    func testDeterministicOperationalReplay() {
        let alarm = SnorkelingAlarm(kind: .maxDepth, label: "Depth", thresholdDepthMeters: 3, minimumRepeatSeconds: 1)
        func replay() -> [SnorkelingEventKind] {
            var state = SnorkelingOperationalEventState.initial
            var kinds: [SnorkelingEventKind] = []
            for index in 0..<6 {
                let depth = [0.5, 1.5, 2.8, 3.2, 2.0, 3.4][index]
                let output = evaluate(
                    alarms: [alarm],
                    depth: depth,
                    verticalSpeed: depth > 2 ? 0.5 : -0.2,
                    state: &state,
                    elapsed: TimeInterval(index)
                )
                kinds.append(contentsOf: output.events.map(\.kind))
            }
            return kinds
        }
        XCTAssertEqual(replay(), replay())
    }

    func testSessionEngineSaveMarkerAddsMarkerAndOverlay() {
        var engine = makeEngine()
        engine.armSession(at: startDate)
        engine.startSession(at: startDate)
        ingest(&engine, depth: 0.2, offset: 0, gps: gps(offset: 0))
        let result = engine.saveMarker(
            request: SnorkelingMarkerCaptureRequest(category: .buoy, note: "Test", allowSaveWithoutCoordinates: false),
            at: startDate.addingTimeInterval(1)
        )
        XCTAssertNotNil(result.marker)
        XCTAssertEqual(engine.snapshot.session.markers.count, 1)
        XCTAssertEqual(engine.snapshot.session.events.last?.kind, .markerPlaced)
    }

    func testAscentRateAndGPSSensorAlarms() {
        var state = SnorkelingOperationalEventState.initial
        let ascent = SnorkelingAlarm(kind: .maxAscentRate, label: "Ascent", thresholdAscentRateMetersPerSecond: 0.8)
        let gps = SnorkelingAlarm(kind: .gpsLost, label: "GPS", minimumRepeatSeconds: 1)
        let ascentOut = evaluate(
            alarms: [ascent],
            depth: 2,
            verticalSpeed: -1.2,
            state: &state,
            elapsed: 1,
            gpsPresentation: .tracking
        )
        XCTAssertEqual(ascentOut.events.filter { $0.kind == .alarmTriggered }.count, 1)
        let gpsOut = evaluate(
            alarms: [gps],
            depth: 0.2,
            verticalSpeed: 0,
            state: &state,
            elapsed: 2,
            gpsPresentation: .unavailable
        )
        XCTAssertEqual(gpsOut.events.filter { $0.kind == .alarmTriggered }.count, 1)
    }

    // MARK: - Helpers

    private func evaluate(
        alarms: [SnorkelingAlarm],
        depth: Double,
        verticalSpeed: Double,
        state: inout SnorkelingOperationalEventState,
        elapsed: TimeInterval,
        batteryFraction: Double? = nil,
        gpsPresentation: SnorkelingGPSPresentationState = .tracking,
        hapticsEnabled: Bool = true,
        missionMode: Bool = false
    ) -> SnorkelingOperationalEventOutput {
        SnorkelingOperationalEventEngine.evaluate(
            alarms: alarms,
            depthMeters: depth,
            verticalSpeedMetersPerSecond: verticalSpeed,
            state: &state,
            context: SnorkelingOperationalEventContext(
                monotonicNow: elapsed,
                wallClockNow: startDate.addingTimeInterval(elapsed),
                sessionElapsedSeconds: elapsed,
                activeDipElapsedSeconds: elapsed,
                distanceFromEntryMeters: nil,
                batteryFraction: batteryFraction,
                temperatureCelsius: nil,
                gpsPresentationState: gpsPresentation,
                sensorHealth: .available,
                missionModeEnabled: missionMode,
                hapticsEnabled: hapticsEnabled
            )
        )
    }

    private func acceptedFix(lat: Double, lon: Double, offset: TimeInterval) -> SnorkelingGPSAcceptedFix {
        SnorkelingGPSAcceptedFix(
            latitude: lat,
            longitude: lon,
            horizontalAccuracyMeters: 8,
            sensorTimestamp: startDate.addingTimeInterval(offset),
            receivedAt: startDate.addingTimeInterval(offset),
            monotonicRelativeTimestampSeconds: offset,
            fixAgeSeconds: 1,
            source: .replay,
            segmentDistanceMeters: 0,
            impliedSpeedMetersPerSecond: 0,
            gpsQuality: .measured,
            presentationState: .tracking
        )
    }

    private func makeEngine() -> SnorkelingSessionEngine {
        SnorkelingSessionEngine(configuration: .default, sessionStart: startDate)
    }

    private func ingest(
        _ engine: inout SnorkelingSessionEngine,
        depth: Double,
        offset: TimeInterval,
        gps: SnorkelingGPSRawFix? = nil
    ) {
        let timestamp = startDate.addingTimeInterval(offset)
        engine.ingest(
            depthRaw: DepthMeasurementRaw(depthMeters: depth, sensorTimestamp: timestamp, receivedAt: timestamp),
            gpsRaw: gps,
            wallClock: timestamp
        )
    }

    private func gps(offset: TimeInterval) -> SnorkelingGPSRawFix {
        SnorkelingGPSRawFix(
            latitude: 44.40012,
            longitude: 8.94012,
            horizontalAccuracyMeters: 8,
            sensorTimestamp: startDate.addingTimeInterval(offset),
            receivedAt: startDate.addingTimeInterval(offset),
            source: .replay
        )
    }
}
