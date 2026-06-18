import XCTest

final class SnorkelingNavigationReturnEngineTests: XCTestCase {
    private let startDate = Date(timeIntervalSince1970: 1_700_000_000)

    // MARK: - Geodesy

    func testBearingAcrossDateline() {
        let bearing = SnorkelingDomainSupport.bearingDegrees(
            from: (latitude: 0, longitude: 179.5),
            to: (latitude: 0, longitude: -179.5)
        )
        XCTAssertNotNil(bearing)
        XCTAssertEqual(bearing ?? 0, 90, accuracy: 2)
    }

    func testBearingWrapAndSignedDelta() {
        let bearing = SnorkelingDomainSupport.bearingDegrees(
            from: (latitude: 44.4, longitude: 8.94),
            to: (latitude: 44.401, longitude: 8.95)
        )
        XCTAssertNotNil(bearing)
        let delta = SnorkelingDomainSupport.signedAngularDeltaDegrees(heading: 350, bearing: 10)
        XCTAssertEqual(delta, 20, accuracy: 0.1)
        let wrapped = SnorkelingDomainSupport.signedAngularDeltaDegrees(heading: 10, bearing: 350)
        XCTAssertEqual(wrapped, -20, accuracy: 0.1)
    }

    func testNormalizeDegreesWrapsCorrectly() {
        XCTAssertEqual(SnorkelingDomainSupport.normalizeDegrees(370), 10, accuracy: 0.001)
        XCTAssertEqual(SnorkelingDomainSupport.normalizeDegrees(-10), 350, accuracy: 0.001)
    }

    // MARK: - Navigation engine

    func testNoFixProducesUnavailableTurnGuidance() {
        var state = SnorkelingNavigationRuntimeState.initial
        let plan = routePlan(waypoints: [waypoint(order: 0, lat: 44.4002, lon: 8.9402)])
        let snapshot = SnorkelingNavigationEngine.evaluateWaypointNavigation(
            routePlan: plan,
            state: state,
            position: .unavailable,
            heading: SnorkelingNavigationHeadingInput(headingDegrees: 90, ageSeconds: 1),
            configuration: testNavigationConfiguration()
        )
        XCTAssertEqual(snapshot.snapshot.turnInstruction, .unavailable)
        XCTAssertNil(snapshot.snapshot.targetBearingDegrees)
    }

    func testStaleHeadingDisablesPreciseTurnGuidance() {
        var state = SnorkelingNavigationRuntimeState.initial
        let plan = routePlan(waypoints: [waypoint(order: 0, lat: 44.4002, lon: 8.9402)])
        let snapshot = SnorkelingNavigationEngine.evaluateWaypointNavigation(
            routePlan: plan,
            state: state,
            position: measuredPosition(lat: 44.4000, lon: 8.9400),
            heading: SnorkelingNavigationHeadingInput(headingDegrees: 45, ageSeconds: 30),
            configuration: testNavigationConfiguration()
        )
        XCTAssertEqual(snapshot.snapshot.headingQuality, .stale)
        XCTAssertEqual(snapshot.snapshot.turnInstruction, .unavailable)
        XCTAssertNotNil(snapshot.snapshot.distanceToTargetMeters)
    }

    func testMeasuredGPSProducesTurnLeftOrRight() {
        var state = SnorkelingNavigationRuntimeState.initial
        let plan = routePlan(waypoints: [waypoint(order: 0, lat: 44.4010, lon: 8.9410)])
        let snapshot = SnorkelingNavigationEngine.evaluateWaypointNavigation(
            routePlan: plan,
            state: state,
            position: measuredPosition(lat: 44.4000, lon: 8.9400),
            heading: SnorkelingNavigationHeadingInput(headingDegrees: 0, ageSeconds: 1),
            configuration: testNavigationConfiguration()
        )
        XCTAssertNotEqual(snapshot.snapshot.turnInstruction, .unavailable)
        XCTAssertNotNil(snapshot.snapshot.targetBearingDegrees)
        XCTAssertNotNil(snapshot.snapshot.signedAngularDeltaDegrees)
    }

    func testOnLineWithinTolerance() {
        var state = SnorkelingNavigationRuntimeState.initial
        let plan = routePlan(waypoints: [waypoint(order: 0, lat: 44.40012, lon: 8.94012)])
        let bearing = SnorkelingDomainSupport.bearingDegrees(
            from: (latitude: 44.40000, longitude: 8.94000),
            to: (latitude: 44.40012, longitude: 8.94012)
        ) ?? 0
        let snapshot = SnorkelingNavigationEngine.evaluateWaypointNavigation(
            routePlan: plan,
            state: state,
            position: measuredPosition(lat: 44.40000, lon: 8.94000),
            heading: SnorkelingNavigationHeadingInput(headingDegrees: bearing, ageSeconds: 1),
            configuration: testNavigationConfiguration()
        )
        XCTAssertEqual(snapshot.snapshot.turnInstruction, .onLine)
    }

    func testRouteReorderIsDeterministic() {
        let first = waypoint(order: 2, lat: 44.401, lon: 8.941, name: "C")
        let second = waypoint(order: 0, lat: 44.400, lon: 8.940, name: "A")
        let third = waypoint(order: 1, lat: 44.4005, lon: 8.9405, name: "B")
        let ordered = SnorkelingDomainSupport.orderedWaypoints([first, second, third])
        XCTAssertEqual(ordered.map(\.name), ["A", "B", "C"])
    }

    func testAutoSwitchAdvancesToNextWaypoint() {
        var state = SnorkelingNavigationRuntimeState.initial
        var config = testNavigationConfiguration()
        config.waypointReachedRadiusMeters = 500
        config.autoAdvanceToNextWaypoint = true
        let w1 = waypoint(order: 0, lat: 44.40000, lon: 8.94000, name: "A")
        let w2 = waypoint(order: 1, lat: 44.40100, lon: 8.94100, name: "B")
        let plan = routePlan(waypoints: [w1, w2])
        let result = SnorkelingNavigationEngine.evaluateWaypointNavigation(
            routePlan: plan,
            state: state,
            position: measuredPosition(lat: 44.40000, lon: 8.94000),
            heading: SnorkelingNavigationHeadingInput(headingDegrees: 45, ageSeconds: 1),
            configuration: config
        )
        XCTAssertTrue(result.snapshot.waypointReached)
        XCTAssertEqual(result.state.currentWaypointID, w2.id)
        XCTAssertTrue(result.state.completedWaypointIDs.contains(w1.id))
    }

    func testSkipWaypointAndManualSelection() {
        var state = SnorkelingNavigationRuntimeState.initial
        let w1 = waypoint(order: 0, lat: 44.4000, lon: 8.9400, name: "A")
        let w2 = waypoint(order: 1, lat: 44.4010, lon: 8.9410, name: "B")
        let plan = routePlan(waypoints: [w1, w2])
        SnorkelingNavigationEngine.skipWaypoint(id: w1.id, routePlan: plan, state: &state)
        SnorkelingNavigationEngine.selectWaypoint(id: w2.id, state: &state)
        let result = SnorkelingNavigationEngine.evaluateWaypointNavigation(
            routePlan: plan,
            state: state,
            position: measuredPosition(lat: 44.4000, lon: 8.9400),
            heading: SnorkelingNavigationHeadingInput(headingDegrees: 45, ageSeconds: 1),
            configuration: testNavigationConfiguration()
        )
        XCTAssertEqual(result.snapshot.waypointID, w2.id)
        XCTAssertTrue(result.snapshot.skippedWaypointIDs.contains(w1.id))
    }

    func testUnderwaterGPSDoesNotProduceMeasuredWaypointReach() {
        var state = SnorkelingNavigationRuntimeState.initial
        var config = testNavigationConfiguration()
        config.waypointReachedRadiusMeters = 1_000
        let plan = routePlan(waypoints: [waypoint(order: 0, lat: 44.4000, lon: 8.9400)])
        var position = measuredPosition(lat: 44.4000, lon: 8.9400)
        position.isUnderwater = true
        position.gpsPresentationState = .underwaterUnavailable
        let result = SnorkelingNavigationEngine.evaluateWaypointNavigation(
            routePlan: plan,
            state: state,
            position: position,
            heading: SnorkelingNavigationHeadingInput(headingDegrees: 45, ageSeconds: 1),
            configuration: config
        )
        XCTAssertFalse(result.snapshot.waypointReached)
        XCTAssertEqual(result.snapshot.turnInstruction, .unavailable)
    }

    // MARK: - Return advisor

    func testEntryOverrideUpdatesReturnTarget() {
        var state = SnorkelingNavigationRuntimeState.initial
        let entry = SnorkelingEntryPoint(
            latitude: 44.3990,
            longitude: 8.9390,
            capturedAt: startDate,
            monotonicRelativeTimestampSeconds: 0,
            gpsQuality: .measured,
            horizontalAccuracyMeters: 8
        )
        SnorkelingReturnAdvisor.overrideEntryPoint(entry, state: &state)
        XCTAssertEqual(state.entryPoint?.latitude, 44.3990)
    }

    func testReturnDistanceThresholdActivatesAdvisor() {
        var state = SnorkelingNavigationRuntimeState.initial
        state.entryPoint = SnorkelingEntryPoint(
            latitude: 44.40000,
            longitude: 8.94000,
            capturedAt: startDate,
            monotonicRelativeTimestampSeconds: 0,
            gpsQuality: .measured
        )
        var config = SnorkelingReturnAdvisorConfiguration.default
        config.adviseReturnDistanceMeters = 100
        let result = SnorkelingReturnAdvisor.evaluateReturnNavigation(
            state: state,
            position: measuredPosition(lat: 44.40250, lon: 8.94250),
            heading: SnorkelingNavigationHeadingInput(headingDegrees: 180, ageSeconds: 1),
            sessionElapsedSeconds: 60,
            batteryFraction: 0.8,
            now: startDate.addingTimeInterval(60),
            configuration: config
        )
        XCTAssertEqual(result.snapshot.advisorReason, .distanceThreshold)
        XCTAssertTrue(result.snapshot.advisorActive)
        XCTAssertEqual(result.snapshot.informationalMessageKey, "snorkeling.return.advisor.distance")
    }

    func testReturnDurationAndBatteryThresholds() {
        var state = SnorkelingNavigationRuntimeState.initial
        state.entryPoint = SnorkelingEntryPoint(
            latitude: 44.40000,
            longitude: 8.94000,
            capturedAt: startDate,
            monotonicRelativeTimestampSeconds: 0,
            gpsQuality: .measured
        )
        var durationConfig = SnorkelingReturnAdvisorConfiguration.default
        durationConfig.adviseReturnDurationSeconds = 100
        let durationResult = SnorkelingReturnAdvisor.evaluateReturnNavigation(
            state: state,
            position: measuredPosition(lat: 44.40001, lon: 8.94001),
            heading: SnorkelingNavigationHeadingInput(headingDegrees: 0, ageSeconds: 1),
            sessionElapsedSeconds: 200,
            batteryFraction: 0.8,
            now: startDate.addingTimeInterval(200),
            configuration: durationConfig
        )
        XCTAssertEqual(durationResult.snapshot.advisorReason, .durationThreshold)

        var batteryConfig = SnorkelingReturnAdvisorConfiguration.default
        batteryConfig.adviseReturnBatteryFraction = 0.25
        let batteryResult = SnorkelingReturnAdvisor.evaluateReturnNavigation(
            state: state,
            position: measuredPosition(lat: 44.40001, lon: 8.94001),
            heading: SnorkelingNavigationHeadingInput(headingDegrees: 0, ageSeconds: 1),
            sessionElapsedSeconds: 10,
            batteryFraction: 0.15,
            now: startDate.addingTimeInterval(10),
            configuration: batteryConfig
        )
        XCTAssertEqual(batteryResult.snapshot.advisorReason, .batteryThreshold)
    }

    func testStaleGPSReturnShowsDegradedStateWithoutPreciseTurns() {
        var state = SnorkelingNavigationRuntimeState.initial
        state.entryPoint = SnorkelingEntryPoint(
            latitude: 44.40000,
            longitude: 8.94000,
            capturedAt: startDate,
            monotonicRelativeTimestampSeconds: 0,
            gpsQuality: .measured
        )
        var position = measuredPosition(lat: 44.40050, lon: 8.94050)
        position.gpsPresentationState = .stale
        position.gpsQuality = .stale
        let result = SnorkelingReturnAdvisor.evaluateReturnNavigation(
            state: state,
            position: position,
            heading: SnorkelingNavigationHeadingInput(headingDegrees: 45, ageSeconds: 1),
            sessionElapsedSeconds: 10,
            batteryFraction: 0.8,
            now: startDate.addingTimeInterval(10)
        )
        XCTAssertEqual(result.snapshot.turnInstruction, .unavailable)
        XCTAssertEqual(result.snapshot.informationalMessageKey, "snorkeling.return.gps.degraded")
    }

    // MARK: - Session engine integration

    func testSessionEngineNavigationPhaseExposesWaypointSnapshot() {
        var engine = makeEngine()
        let w1 = waypoint(order: 0, lat: 44.40020, lon: 8.94020)
        let plan = routePlan(waypoints: [w1])
        engine.setRoutePlans([plan], activePlanID: plan.id)
        engine.armSession(at: startDate)
        engine.startSession(at: startDate)
        ingest(&engine, depth: 0.2, offset: 0, gps: gps(offset: 0))
        engine.updateHeading(degrees: 45, ageSeconds: 1)
        engine.enterNavigation(at: startDate.addingTimeInterval(1))
        XCTAssertEqual(engine.snapshot.phase, .navigation)
        XCTAssertEqual(engine.snapshot.waypointNavigation.waypointID, w1.id)
        XCTAssertNotNil(engine.snapshot.waypointNavigation.distanceToTargetMeters)
    }

    func testSessionEngineReturnModeExposesReturnSnapshot() {
        var engine = makeEngine()
        engine.armSession(at: startDate)
        engine.startSession(at: startDate)
        ingest(&engine, depth: 0.2, offset: 0, gps: gps(offset: 0))
        engine.updateHeading(degrees: 90, ageSeconds: 1)
        engine.enterReturnMode(at: startDate.addingTimeInterval(1))
        XCTAssertEqual(engine.snapshot.phase, .returnMode)
        XCTAssertEqual(engine.snapshot.returnNavigation.advisorReason, .manualActivation)
        XCTAssertNotNil(engine.snapshot.returnNavigation.entryPoint)
    }

    func testNavigationCheckpointRoundTripPreservesRuntimeState() {
        var engine = makeEngine()
        let w1 = waypoint(order: 0, lat: 44.40020, lon: 8.94020)
        let plan = routePlan(waypoints: [w1])
        engine.setRoutePlans([plan], activePlanID: plan.id)
        engine.armSession(at: startDate)
        engine.startSession(at: startDate)
        ingest(&engine, depth: 0.2, offset: 0, gps: gps(offset: 0))
        engine.enterNavigation(at: startDate.addingTimeInterval(1))
        let checkpoint = engine.exportCheckpoint(now: startDate.addingTimeInterval(2))
        var restored = SnorkelingSessionEngine(checkpoint: checkpoint)
        XCTAssertEqual(restored.snapshot.phase, .navigation)
        XCTAssertEqual(restored.snapshot.waypointNavigation.waypointID, w1.id)
        XCTAssertEqual(restored.exportCheckpoint().navigationRuntimeState.currentWaypointID, checkpoint.navigationRuntimeState.currentWaypointID)
        XCTAssertEqual(restored.exportCheckpoint().navigationRuntimeState.activeRoutePlanID, plan.id)
    }

    // MARK: - Helpers

    private func testNavigationConfiguration() -> SnorkelingNavigationConfiguration {
        var config = SnorkelingNavigationConfiguration.default
        config.onLineToleranceDegrees = 12
        config.turnThresholdDegrees = 12
        return config
    }

    private func makeEngine() -> SnorkelingSessionEngine {
        SnorkelingSessionEngine(configuration: .default, sessionStart: startDate)
    }

    private func routePlan(waypoints: [SnorkelingWaypoint]) -> SnorkelingRoutePlan {
        SnorkelingRoutePlan(name: "Test Route", waypoints: waypoints)
    }

    private func waypoint(order: Int, lat: Double, lon: Double, name: String = "WP") -> SnorkelingWaypoint {
        SnorkelingWaypoint(
            name: name,
            category: .buoy,
            latitude: lat,
            longitude: lon,
            routeOrder: order
        )
    }

    private func measuredPosition(lat: Double, lon: Double) -> SnorkelingNavigationPositionInput {
        SnorkelingNavigationPositionInput(
            latitude: lat,
            longitude: lon,
            gpsQuality: .measured,
            gpsPresentationState: .tracking,
            isUnderwater: false,
            surfaceSpeedMetersPerSecond: 0.8,
            fixAgeSeconds: 1
        )
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

    private func gps(offset: TimeInterval, lat: Double = 44.40000, lon: Double = 8.94000) -> SnorkelingGPSRawFix {
        SnorkelingGPSRawFix(
            latitude: lat,
            longitude: lon,
            horizontalAccuracyMeters: 8,
            sensorTimestamp: startDate.addingTimeInterval(offset),
            receivedAt: startDate.addingTimeInterval(offset),
            source: .replay
        )
    }
}

private extension SnorkelingNavigationPositionInput {
    static let unavailable = SnorkelingNavigationPositionInput(
        latitude: nil,
        longitude: nil,
        gpsQuality: .unavailable,
        gpsPresentationState: .unavailable,
        isUnderwater: false,
        surfaceSpeedMetersPerSecond: nil,
        fixAgeSeconds: nil
    )
}
