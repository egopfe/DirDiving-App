import XCTest

final class SnorkelingSensorGPSIngestionTests: XCTestCase {
    private let baseDate = Date(timeIntervalSince1970: 1_700_000_000)

    // MARK: - Depth feed

    func testDepthFeedAcceptsSurfaceSampleWithTemperature() {
        var state = SnorkelingDepthFeedState.initial
        let raw = DepthMeasurementRaw(
            depthMeters: 0.2,
            sensorTimestamp: baseDate,
            receivedAt: baseDate,
            temperatureCelsius: 24.5
        )
        let result = SnorkelingDepthFeed.ingest(
            raw: raw,
            monotonicRelativeTimestampSeconds: 0,
            state: &state
        )
        XCTAssertEqual(result.depthFeedQuality, .accepted)
        XCTAssertEqual(result.snorkelingQuality, .measured)
        XCTAssertEqual(result.presentationState, .valid)
        XCTAssertEqual(result.temperatureCelsius, 24.5)
        XCTAssertFalse(result.isUnderwater)
        XCTAssertEqual(state.rawAuditTrail.count, 1)
    }

    func testDepthFeedRejectsSpike() {
        var state = SnorkelingDepthFeedState.initial
        _ = SnorkelingDepthFeed.ingest(
            raw: DepthMeasurementRaw(depthMeters: 1, sensorTimestamp: baseDate, receivedAt: baseDate),
            monotonicRelativeTimestampSeconds: 0,
            state: &state
        )
        let spike = SnorkelingDepthFeed.ingest(
            raw: DepthMeasurementRaw(
                depthMeters: 8,
                sensorTimestamp: baseDate.addingTimeInterval(0.5),
                receivedAt: baseDate.addingTimeInterval(0.5)
            ),
            monotonicRelativeTimestampSeconds: 0.5,
            state: &state
        )
        XCTAssertEqual(spike.depthFeedQuality, .spikeRejected)
        XCTAssertEqual(spike.snorkelingQuality, .invalid)
        XCTAssertEqual(spike.presentationState, .degraded)
    }

    func testDepthFeedMarksUnderwaterAndDegradedQuality() {
        var state = SnorkelingDepthFeedState.initial
        var timestamp = baseDate
        for (index, depth) in [0.2, 0.8, 1.2, 2.0].enumerated() {
            _ = SnorkelingDepthFeed.ingest(
                raw: DepthMeasurementRaw(depthMeters: depth, sensorTimestamp: timestamp, receivedAt: timestamp),
                monotonicRelativeTimestampSeconds: TimeInterval(index),
                state: &state
            )
            timestamp = timestamp.addingTimeInterval(2)
        }
        XCTAssertTrue(state.isUnderwater)
        XCTAssertEqual(state.lastAcceptedDepthMeters, 2.0)
    }

    func testDepthFeedRejectsRegressiveTimestamp() {
        var state = SnorkelingDepthFeedState.initial
        _ = SnorkelingDepthFeed.ingest(
            raw: DepthMeasurementRaw(depthMeters: 1, sensorTimestamp: baseDate.addingTimeInterval(2), receivedAt: baseDate.addingTimeInterval(2)),
            monotonicRelativeTimestampSeconds: 2,
            state: &state
        )
        let regressive = SnorkelingDepthFeed.ingest(
            raw: DepthMeasurementRaw(depthMeters: 1.2, sensorTimestamp: baseDate.addingTimeInterval(1), receivedAt: baseDate.addingTimeInterval(1)),
            monotonicRelativeTimestampSeconds: 1,
            state: &state
        )
        XCTAssertEqual(regressive.depthFeedQuality, .regressiveTimestamp)
    }

    // MARK: - GPS feed

    func testGPSReplayBuildsGeodeticDistance() {
        var state = SnorkelingGPSFeedState.initial
        let first = ingestGPS(
            state: &state,
            monotonic: 0,
            offset: 0,
            latitude: 44.40000,
            longitude: 8.94000,
            accuracy: 8
        )
        let second = ingestGPS(
            state: &state,
            monotonic: 5,
            offset: 5,
            latitude: 44.40012,
            longitude: 8.94012,
            accuracy: 8
        )
        XCTAssertEqual(first.presentationState, .tracking)
        XCTAssertEqual(second.gpsQuality, .measured)
        XCTAssertGreaterThan(second.accumulatedDistanceMeters, 10)
        XCTAssertLessThan(second.accumulatedDistanceMeters, 30)
        XCTAssertGreaterThan(second.accepted?.segmentDistanceMeters ?? 0, 0)
    }

    func testGPSRejectsLowAccuracyFix() {
        var state = SnorkelingGPSFeedState.initial
        let result = ingestGPS(
            state: &state,
            monotonic: 0,
            offset: 0,
            latitude: 44.4,
            longitude: 8.94,
            accuracy: 80
        )
        XCTAssertEqual(result.rejectionReason, .lowAccuracy)
        XCTAssertEqual(result.presentationState, .unavailable)
        XCTAssertNil(result.accepted)
    }

    func testGPSRejectsSpeedSpike() {
        var state = SnorkelingGPSFeedState.initial
        _ = ingestGPS(
            state: &state,
            monotonic: 0,
            offset: 0,
            latitude: 44.4000,
            longitude: 8.9400,
            accuracy: 8
        )
        let jump = ingestGPS(
            state: &state,
            monotonic: 1,
            offset: 1,
            latitude: 44.4200,
            longitude: 8.9600,
            accuracy: 8
        )
        XCTAssertEqual(jump.rejectionReason, .speedOutlier)
        XCTAssertEqual(jump.gpsQuality, .invalid)
    }

    func testGPSMarksStaleFix() {
        var state = SnorkelingGPSFeedState.initial
        let now = baseDate.addingTimeInterval(120)
        let result = SnorkelingGPSFeed.ingest(
            raw: SnorkelingGPSRawFix(
                latitude: 44.4,
                longitude: 8.94,
                horizontalAccuracyMeters: 10,
                sensorTimestamp: baseDate,
                receivedAt: baseDate
            ),
            monotonicRelativeTimestampSeconds: 0,
            isUnderwater: false,
            state: &state,
            now: now
        )
        XCTAssertEqual(result.rejectionReason, .fixTooOld)
        XCTAssertEqual(result.presentationState, .stale)
        XCTAssertEqual(result.gpsQuality, .stale)
    }

    func testGPSUnavailableUnderwater() {
        var state = SnorkelingGPSFeedState.initial
        let result = ingestGPS(
            state: &state,
            monotonic: 0,
            offset: 0,
            latitude: 44.4,
            longitude: 8.94,
            accuracy: 8,
            isUnderwater: true
        )
        XCTAssertEqual(result.presentationState, .underwaterUnavailable)
        XCTAssertEqual(result.rejectionReason, .underwater)
        XCTAssertNil(result.accepted)
    }

    func testGPSGapPolicyResetsBridge() {
        var state = SnorkelingGPSFeedState.initial
        var config = SnorkelingGPSFeedConfiguration.snorkelingDefault
        config.gapUnavailableSeconds = 10
        _ = ingestGPS(
            state: &state,
            monotonic: 0,
            offset: 0,
            latitude: 44.40000,
            longitude: 8.94000,
            accuracy: 8,
            configuration: config
        )
        let afterGap = SnorkelingGPSFeed.ingest(
            raw: SnorkelingGPSRawFix(
                latitude: 44.40012,
                longitude: 8.94012,
                horizontalAccuracyMeters: 8,
                sensorTimestamp: baseDate.addingTimeInterval(20),
                receivedAt: baseDate.addingTimeInterval(20)
            ),
            monotonicRelativeTimestampSeconds: 20,
            isUnderwater: false,
            state: &state,
            configuration: config,
            now: baseDate.addingTimeInterval(20)
        )
        XCTAssertEqual(afterGap.rejectionReason, .gapExceeded)
        XCTAssertNil(state.lastAcceptedFix)
    }

    func testGPSResumesOnSurfaceAfterUnderwaterGap() {
        var depthState = SnorkelingDepthFeedState.initial
        var gpsState = SnorkelingGPSFeedState.initial

        _ = ingestGPS(
            state: &gpsState,
            monotonic: 0,
            offset: 0,
            latitude: 44.4000,
            longitude: 8.9400,
            accuracy: 8,
            depthState: &depthState,
            depth: 0.1
        )
        _ = ingestGPS(
            state: &gpsState,
            monotonic: 2,
            offset: 2,
            latitude: 44.4000,
            longitude: 8.9400,
            accuracy: 8,
            isUnderwater: true
        )
        XCTAssertEqual(gpsState.rawAuditTrail.last?.presentationState, .underwaterUnavailable)

        let resumed = ingestGPS(
            state: &gpsState,
            monotonic: 20,
            offset: 20,
            latitude: 44.40012,
            longitude: 8.94012,
            accuracy: 8,
            depthState: &depthState,
            depth: 0.1
        )
        XCTAssertEqual(resumed.presentationState, .tracking)
        XCTAssertNotNil(resumed.accepted)
    }

    func testDepthGPSConcurrencyPreservesIndependentAuditTrails() {
        var depthState = SnorkelingDepthFeedState.initial
        var gpsState = SnorkelingGPSFeedState.initial
        var timestamp = baseDate
        for second in 0..<6 {
            let depth = second < 3 ? 0.2 : 1.5
            let depthResult = SnorkelingDepthFeed.ingest(
                raw: DepthMeasurementRaw(depthMeters: depth, sensorTimestamp: timestamp, receivedAt: timestamp),
                monotonicRelativeTimestampSeconds: TimeInterval(second),
                state: &depthState
            )
            _ = SnorkelingGPSFeed.ingest(
                raw: SnorkelingGPSRawFix(
                    latitude: 44.4000 + Double(second) * 0.0001,
                    longitude: 8.9400,
                    horizontalAccuracyMeters: 8,
                    sensorTimestamp: timestamp,
                    receivedAt: timestamp
                ),
                monotonicRelativeTimestampSeconds: TimeInterval(second),
                isUnderwater: depthResult.isUnderwater,
                state: &gpsState,
                now: timestamp
            )
            timestamp = timestamp.addingTimeInterval(2)
        }
        XCTAssertEqual(depthState.rawAuditTrail.count, 6)
        XCTAssertEqual(gpsState.rawAuditTrail.count, 6)
        XCTAssertTrue(gpsState.rawAuditTrail.contains { $0.presentationState == .underwaterUnavailable })
        XCTAssertTrue(gpsState.rawAuditTrail.contains { $0.presentationState == .tracking })
    }

    func testGPSDegradedAccuracyStillAcceptedWithoutDistanceCredit() {
        var state = SnorkelingGPSFeedState.initial
        _ = ingestGPS(state: &state, monotonic: 0, offset: 0, latitude: 44.4000, longitude: 8.9400, accuracy: 8)
        let degraded = ingestGPS(
            state: &state,
            monotonic: 5,
            offset: 5,
            latitude: 44.40012,
            longitude: 8.94012,
            accuracy: 30
        )
        XCTAssertEqual(degraded.presentationState, .degraded)
        XCTAssertEqual(degraded.gpsQuality, .estimated)
        XCTAssertEqual(degraded.accepted?.segmentDistanceMeters, 0)
        XCTAssertEqual(degraded.accumulatedDistanceMeters, 0)
    }

    // MARK: - Helpers

    @discardableResult
    private func ingestGPS(
        state: inout SnorkelingGPSFeedState,
        monotonic: TimeInterval,
        offset: TimeInterval,
        latitude: Double,
        longitude: Double,
        accuracy: Double,
        isUnderwater: Bool = false,
        configuration: SnorkelingGPSFeedConfiguration = .snorkelingDefault
    ) -> SnorkelingGPSIngestResult {
        ingestGPS(
            state: &state,
            monotonic: monotonic,
            offset: offset,
            latitude: latitude,
            longitude: longitude,
            accuracy: accuracy,
            isUnderwater: isUnderwater,
            configuration: configuration,
            depthState: nil,
            depth: nil
        )
    }

    @discardableResult
    private func ingestGPS(
        state: inout SnorkelingGPSFeedState,
        monotonic: TimeInterval,
        offset: TimeInterval,
        latitude: Double,
        longitude: Double,
        accuracy: Double,
        isUnderwater: Bool,
        configuration: SnorkelingGPSFeedConfiguration,
        depthState: SnorkelingDepthFeedState?,
        depth: Double?
    ) -> SnorkelingGPSIngestResult {
        let underwater: Bool
        if isUnderwater {
            underwater = true
        } else if var depthState, let depth {
            let depthResult = SnorkelingDepthFeed.ingest(
                raw: DepthMeasurementRaw(
                    depthMeters: depth,
                    sensorTimestamp: baseDate.addingTimeInterval(offset),
                    receivedAt: baseDate.addingTimeInterval(offset)
                ),
                monotonicRelativeTimestampSeconds: monotonic,
                state: &depthState
            )
            underwater = depthResult.isUnderwater
        } else {
            underwater = false
        }

        return SnorkelingGPSFeed.ingest(
            raw: SnorkelingGPSRawFix(
                latitude: latitude,
                longitude: longitude,
                horizontalAccuracyMeters: accuracy,
                sensorTimestamp: baseDate.addingTimeInterval(offset),
                receivedAt: baseDate.addingTimeInterval(offset),
                source: .replay
            ),
            monotonicRelativeTimestampSeconds: monotonic,
            isUnderwater: underwater,
            state: &state,
            configuration: configuration,
            now: baseDate.addingTimeInterval(offset)
        )
    }

    @discardableResult
    private func ingestGPS(
        state: inout SnorkelingGPSFeedState,
        monotonic: TimeInterval,
        offset: TimeInterval,
        latitude: Double,
        longitude: Double,
        accuracy: Double,
        depthState: inout SnorkelingDepthFeedState,
        depth: Double,
        configuration: SnorkelingGPSFeedConfiguration = .snorkelingDefault
    ) -> SnorkelingGPSIngestResult {
        let depthResult = SnorkelingDepthFeed.ingest(
            raw: DepthMeasurementRaw(
                depthMeters: depth,
                sensorTimestamp: baseDate.addingTimeInterval(offset),
                receivedAt: baseDate.addingTimeInterval(offset)
            ),
            monotonicRelativeTimestampSeconds: monotonic,
            state: &depthState
        )
        return SnorkelingGPSFeed.ingest(
            raw: SnorkelingGPSRawFix(
                latitude: latitude,
                longitude: longitude,
                horizontalAccuracyMeters: accuracy,
                sensorTimestamp: baseDate.addingTimeInterval(offset),
                receivedAt: baseDate.addingTimeInterval(offset),
                source: .replay
            ),
            monotonicRelativeTimestampSeconds: monotonic,
            isUnderwater: depthResult.isUnderwater,
            state: &state,
            configuration: configuration,
            now: baseDate.addingTimeInterval(offset)
        )
    }
}
