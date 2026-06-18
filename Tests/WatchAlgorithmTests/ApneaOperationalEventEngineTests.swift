import XCTest

final class ApneaOperationalEventEngineTests: XCTestCase {
    private let t0 = Date(timeIntervalSince1970: 1_700_000_000)

    func testFastCrossingFiresSingleMarkerEvent() {
        var state = ApneaOperationalEventState.initial
        let marker = ApneaDepthMarker(label: "20m", depthMeters: 20, toleranceMeters: 0.5, direction: .descending)

        let output = ApneaOperationalEventEngine.evaluate(
            previousDepthMeters: 18,
            currentDepthMeters: 22,
            verticalSpeedMetersPerSecond: 1.6,
            alarms: [],
            targets: [],
            markers: [marker],
            state: &state,
            context: context(at: 10)
        )

        XCTAssertEqual(output.events.filter { $0.kind == .markerReached }.count, 1)
        XCTAssertEqual(output.reachedMarkerIDs, [marker.id])
        XCTAssertEqual(output.overlays.first?.kind, .markerReached)
    }

    func testThresholdOscillationDoesNotRefireWithoutHysteresisRearm() {
        var state = ApneaOperationalEventState.initial
        let marker = ApneaDepthMarker(label: "10m", depthMeters: 10, toleranceMeters: 1, direction: .both)

        _ = ApneaOperationalEventEngine.evaluate(
            previousDepthMeters: 9.2,
            currentDepthMeters: 10.1,
            verticalSpeedMetersPerSecond: 0.8,
            alarms: [],
            targets: [],
            markers: [marker],
            state: &state,
            context: context(at: 1)
        )

        let oscillation = ApneaOperationalEventEngine.evaluate(
            previousDepthMeters: 9.9,
            currentDepthMeters: 10.2,
            verticalSpeedMetersPerSecond: 0.3,
            alarms: [],
            targets: [],
            markers: [marker],
            state: &state,
            context: context(at: 2)
        )

        XCTAssertTrue(oscillation.events.isEmpty)

        _ = ApneaOperationalEventEngine.evaluate(
            previousDepthMeters: 8.9,
            currentDepthMeters: 8.7,
            verticalSpeedMetersPerSecond: -0.8,
            alarms: [],
            targets: [],
            markers: [marker],
            state: &state,
            context: context(at: 3)
        )

        let rearmedFire = ApneaOperationalEventEngine.evaluate(
            previousDepthMeters: 8.7,
            currentDepthMeters: 10.5,
            verticalSpeedMetersPerSecond: 1.0,
            alarms: [],
            targets: [],
            markers: [marker],
            state: &state,
            context: context(at: 4)
        )

        XCTAssertEqual(rearmedFire.events.filter { $0.kind == .markerReached }.count, 1)
    }

    func testMultipleMarkersAndTargetCanFireInSingleSample() {
        var state = ApneaOperationalEventState.initial
        let m10 = ApneaDepthMarker(label: "10m", depthMeters: 10, direction: .descending)
        let m20 = ApneaDepthMarker(label: "20m", depthMeters: 20, direction: .descending)
        let target = ApneaTarget(kind: .depth, label: "Target 20", targetDepthMeters: 20, direction: .descending, reachedMessage: "TARGET RAGGIUNTO")

        let output = ApneaOperationalEventEngine.evaluate(
            previousDepthMeters: 8,
            currentDepthMeters: 21,
            verticalSpeedMetersPerSecond: 2,
            alarms: [],
            targets: [target],
            markers: [m10, m20],
            state: &state,
            context: context(at: 5)
        )

        XCTAssertEqual(output.events.filter { $0.kind == .markerReached }.count, 2)
        XCTAssertEqual(output.events.filter { $0.kind == .targetReached }.count, 1)
    }

    func testSimultaneousAlarmsEmitDistinctEventsWithRateLimit() {
        var state = ApneaOperationalEventState.initial
        let depthAlarm = ApneaAlarm(kind: .depth, label: "Depth 20", thresholdDepthMeters: 20, minimumRepeatSeconds: 2)
        let durationAlarm = ApneaAlarm(kind: .duration, label: "Time 60", thresholdDurationSeconds: 60, minimumRepeatSeconds: 2)

        let first = ApneaOperationalEventEngine.evaluate(
            previousDepthMeters: 19,
            currentDepthMeters: 21,
            verticalSpeedMetersPerSecond: 1,
            alarms: [depthAlarm, durationAlarm],
            targets: [],
            markers: [],
            state: &state,
            context: context(at: 100, diveElapsed: 61)
        )
        XCTAssertEqual(first.events.filter { $0.kind == .alarmTriggered }.count, 2)

        let throttled = ApneaOperationalEventEngine.evaluate(
            previousDepthMeters: 20.5,
            currentDepthMeters: 21,
            verticalSpeedMetersPerSecond: 0.2,
            alarms: [depthAlarm, durationAlarm],
            targets: [],
            markers: [],
            state: &state,
            context: context(at: 101, diveElapsed: 62)
        )
        XCTAssertTrue(throttled.events.isEmpty)
    }

    func testHapticsDisabledStillKeepsVisualFallback() {
        var state = ApneaOperationalEventState.initial
        let marker = ApneaDepthMarker(label: "20m", depthMeters: 20, direction: .descending)

        let output = ApneaOperationalEventEngine.evaluate(
            previousDepthMeters: 19,
            currentDepthMeters: 20.2,
            verticalSpeedMetersPerSecond: 0.8,
            alarms: [],
            targets: [],
            markers: [marker],
            state: &state,
            context: context(at: 10, hapticsEnabled: false)
        )

        XCTAssertFalse(output.overlays.isEmpty)
        XCTAssertTrue(output.hapticCues.isEmpty)
    }

    func testMissionModeDoesNotDisableEventOrHapticEngine() {
        var state = ApneaOperationalEventState.initial
        let target = ApneaTarget(kind: .depth, label: "Target 25", targetDepthMeters: 25, direction: .descending)

        let output = ApneaOperationalEventEngine.evaluate(
            previousDepthMeters: 24,
            currentDepthMeters: 25.2,
            verticalSpeedMetersPerSecond: 0.6,
            alarms: [],
            targets: [target],
            markers: [],
            state: &state,
            context: context(at: 12, missionMode: true)
        )

        XCTAssertEqual(output.events.first?.kind, .targetReached)
        XCTAssertEqual(output.hapticCues.first?.pattern, .targetReached)
    }

    func testDeterministicReplayProducesStableEventSequence() {
        let marker10 = ApneaDepthMarker(label: "10m", depthMeters: 10, direction: .descending)
        let marker20 = ApneaDepthMarker(label: "20m", depthMeters: 20, direction: .descending)
        let target25 = ApneaTarget(kind: .depth, label: "Target", targetDepthMeters: 25, direction: .descending)
        let alarm = ApneaAlarm(kind: .depth, label: "Depth 20", thresholdDepthMeters: 20, minimumRepeatSeconds: 1)

        func replay() -> [ApneaEventKind] {
            var state = ApneaOperationalEventState.initial
            var previous: Double? = nil
            let profile = [0.0, 6, 11, 19, 21, 26, 21, 14, 7, 0]
            var kinds: [ApneaEventKind] = []
            for (i, depth) in profile.enumerated() {
                let out = ApneaOperationalEventEngine.evaluate(
                    previousDepthMeters: previous,
                    currentDepthMeters: depth,
                    verticalSpeedMetersPerSecond: (previous.map { depth - $0 } ?? 0),
                    alarms: [alarm],
                    targets: [target25],
                    markers: [marker10, marker20],
                    state: &state,
                    context: context(at: Double(i), diveElapsed: Double(i) * 5)
                )
                kinds.append(contentsOf: out.events.map(\.kind))
                previous = depth
            }
            return kinds
        }

        XCTAssertEqual(replay(), replay())
    }

    func testTargetNotReachedDoesNotEmitTargetEvent() {
        var state = ApneaOperationalEventState.initial
        let target = ApneaTarget(kind: .depth, label: "Target 25", targetDepthMeters: 25, direction: .descending)
        let profile = [0.0, 6, 11, 16, 21, 24, 23, 18, 10, 0]
        var previous: Double? = nil
        var targetEvents = 0
        for (index, depth) in profile.enumerated() {
            let output = ApneaOperationalEventEngine.evaluate(
                previousDepthMeters: previous,
                currentDepthMeters: depth,
                verticalSpeedMetersPerSecond: (previous.map { depth - $0 } ?? 0),
                alarms: [],
                targets: [target],
                markers: [],
                state: &state,
                context: context(at: Double(index), diveElapsed: Double(index) * 4)
            )
            targetEvents += output.events.filter { $0.kind == .targetReached }.count
            previous = depth
        }
        XCTAssertEqual(targetEvents, 0)
    }

    func testRejectedDepthSpikeCannotTriggerTargetEvent() {
        var state = ApneaOperationalEventState.initial
        let target = ApneaTarget(kind: .depth, label: "Target 20", targetDepthMeters: 20, direction: .descending)

        let output = ApneaOperationalEventEngine.evaluate(
            previousDepthMeters: 5,
            currentDepthMeters: 22,
            verticalSpeedMetersPerSecond: -2.5,
            alarms: [],
            targets: [target],
            markers: [],
            state: &state,
            context: context(at: 8)
        )

        XCTAssertTrue(output.events.filter { $0.kind == .targetReached }.isEmpty)
    }

    func testTargetDisabledDoesNotEmitTargetEvent() {
        var state = ApneaOperationalEventState.initial
        let target = ApneaTarget(kind: .depth, label: "Target 20", targetDepthMeters: 20, direction: .descending, isEnabled: false)

        let output = ApneaOperationalEventEngine.evaluate(
            previousDepthMeters: 18,
            currentDepthMeters: 21,
            verticalSpeedMetersPerSecond: 1.2,
            alarms: [],
            targets: [target],
            markers: [],
            state: &state,
            context: context(at: 3)
        )

        XCTAssertTrue(output.events.filter { $0.kind == .targetReached }.isEmpty)
    }

    func testTargetOscillationBelowThresholdDoesNotRefire() {
        var state = ApneaOperationalEventState.initial
        let target = ApneaTarget(kind: .depth, label: "Target 20", targetDepthMeters: 20, direction: .descending, hysteresisMeters: 0.5)

        _ = ApneaOperationalEventEngine.evaluate(
            previousDepthMeters: 18,
            currentDepthMeters: 20.2,
            verticalSpeedMetersPerSecond: 1.0,
            alarms: [],
            targets: [target],
            markers: [],
            state: &state,
            context: context(at: 1)
        )

        let oscillation = ApneaOperationalEventEngine.evaluate(
            previousDepthMeters: 19.9,
            currentDepthMeters: 20.1,
            verticalSpeedMetersPerSecond: 0.2,
            alarms: [],
            targets: [target],
            markers: [],
            state: &state,
            context: context(at: 2)
        )

        XCTAssertEqual(oscillation.events.filter { $0.kind == .targetReached }.count, 0)
    }

    private func context(
        at monotonic: TimeInterval,
        diveElapsed: TimeInterval = 20,
        missionMode: Bool = false,
        hapticsEnabled: Bool = true
    ) -> ApneaOperationalEventContext {
        ApneaOperationalEventContext(
            monotonicNow: monotonic,
            wallClockNow: t0.addingTimeInterval(monotonic),
            diveElapsedSeconds: diveElapsed,
            sessionElapsedSeconds: monotonic,
            recoveryCompleted: false,
            batteryPercent: 0.5,
            sensorDegraded: false,
            missionModeEnabled: missionMode,
            hapticsEnabled: hapticsEnabled
        )
    }
}
