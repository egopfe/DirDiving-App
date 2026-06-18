import XCTest

final class SnorkelingBoundedDataTests: XCTestCase {
    private let startDate = Date(timeIntervalSince1970: 1_700_000_000)

    func testRawDepthAuditCappedAt2048() {
        var state = SnorkelingDepthFeedState.initial
        for index in 0..<(SnorkelingDepthFeed.maximumRawAuditEntries + 10) {
            let timestamp = startDate.addingTimeInterval(TimeInterval(index))
            _ = SnorkelingDepthFeed.ingest(
                raw: DepthMeasurementRaw(depthMeters: 0.2, sensorTimestamp: timestamp, receivedAt: timestamp),
                monotonicRelativeTimestampSeconds: TimeInterval(index),
                state: &state
            )
        }
        XCTAssertEqual(state.rawAuditTrail.count, SnorkelingDepthFeed.maximumRawAuditEntries)
        XCTAssertEqual(state.rawAuditTrail.first?.monotonicRelativeTimestampSeconds, 10)
    }

    func testRawGPSAuditCappedAt2048() {
        var state = SnorkelingGPSFeedState.initial
        for index in 0..<(SnorkelingGPSFeed.maximumRawAuditEntries + 10) {
            let timestamp = startDate.addingTimeInterval(TimeInterval(index))
            _ = SnorkelingGPSFeed.ingest(
                raw: SnorkelingGPSRawFix(
                    latitude: 44.40000 + Double(index) * 0.000001,
                    longitude: 8.94000,
                    horizontalAccuracyMeters: 8,
                    sensorTimestamp: timestamp,
                    receivedAt: timestamp,
                    source: .replay
                ),
                monotonicRelativeTimestampSeconds: TimeInterval(index),
                isUnderwater: false,
                state: &state,
                now: timestamp
            )
        }
        XCTAssertEqual(state.rawAuditTrail.count, SnorkelingGPSFeed.maximumRawAuditEntries)
        XCTAssertEqual(state.rawAuditTrail.first?.monotonicRelativeTimestampSeconds, 10)
    }

    func testDeterministicAuditEvictionOrder() {
        var first = SnorkelingDepthFeedState.initial
        var second = SnorkelingDepthFeedState.initial
        for index in 0..<2100 {
            let timestamp = startDate.addingTimeInterval(TimeInterval(index))
            let raw = DepthMeasurementRaw(depthMeters: 0.2, sensorTimestamp: timestamp, receivedAt: timestamp)
            _ = SnorkelingDepthFeed.ingest(raw: raw, monotonicRelativeTimestampSeconds: TimeInterval(index), state: &first)
            _ = SnorkelingDepthFeed.ingest(raw: raw, monotonicRelativeTimestampSeconds: TimeInterval(index), state: &second)
        }
        XCTAssertEqual(first.rawAuditTrail, second.rawAuditTrail)
    }

    func testManyDipsRemainDeterministic() {
        var engineA = makeEngine()
        var engineB = makeEngine()
        let depths = [0.2, 0.8, 1.4, 0.2, 0.1, 0.2, 0.9, 1.3, 0.2, 0.1, 0.2, 0.8, 1.1, 0.2, 0.1]
        replay(&engineA, depths: depths, interval: 3)
        replay(&engineB, depths: depths, interval: 3)
        XCTAssertEqual(engineA.snapshot.dipCount, engineB.snapshot.dipCount)
        XCTAssertEqual(engineA.snapshot.session.dips.count, engineB.snapshot.session.dips.count)
    }

    func testCheckpointExportStaysWithinDocumentedBudget() {
        var engine = makeEngine()
        engine.armSession(at: startDate)
        engine.startSession(at: startDate)
        for index in 0..<50 {
            ingest(&engine, depth: index.isMultiple(of: 2) ? 0.2 : 1.0, offset: TimeInterval(index))
        }
        let data = try? JSONEncoder().encode(engine.exportCheckpoint())
        XCTAssertLessThan((data?.count ?? 0), 512_000)
    }

    // MARK: - Helpers

    private func makeEngine() -> SnorkelingSessionEngine {
        var config = SnorkelingLifecycleConfiguration.default
        config.dipStartDebounceSeconds = 0.8
        config.surfaceStableDwellSeconds = 2
        config.minimumDipDurationSeconds = 2
        return SnorkelingSessionEngine(configuration: config, sessionStart: startDate)
    }

    private func replay(_ engine: inout SnorkelingSessionEngine, depths: [Double], interval: TimeInterval) {
        for (index, depth) in depths.enumerated() {
            ingest(&engine, depth: depth, offset: TimeInterval(index) * interval)
        }
    }

    private func ingest(_ engine: inout SnorkelingSessionEngine, depth: Double, offset: TimeInterval) {
        let timestamp = startDate.addingTimeInterval(offset)
        engine.ingest(
            depthRaw: DepthMeasurementRaw(depthMeters: depth, sensorTimestamp: timestamp, receivedAt: timestamp),
            wallClock: timestamp
        )
    }
}
