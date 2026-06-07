import XCTest

final class WatchSyncServiceIntegrationTests: XCTestCase {
    func testMergedPendingOutboundPreservesPreferredSessionSamples() {
        let id = UUID()
        let start = Date(timeIntervalSince1970: 1_000)
        let localEnd = start.addingTimeInterval(120)
        let outboundEnd = start.addingTimeInterval(180)
        let local = makeSession(id: id, start: start, end: localEnd, maxDepth: 18)
        let outbound = DiveSession(
            id: id,
            startDate: start,
            endDate: outboundEnd,
            durationSeconds: 180,
            maxDepthMeters: 25,
            avgDepthMeters: 12,
            avgWaterTemperatureCelsius: 20,
            ttv: 1,
            entryGPS: nil,
            exitGPS: nil,
            samples: [
                DiveSample(timestamp: start, depthMeters: 0, temperatureCelsius: 20),
                DiveSample(timestamp: outboundEnd, depthMeters: 25, temperatureCelsius: 20)
            ]
        )

        var byID: [UUID: DiveSession] = [local.id: local]
        for session in [outbound] {
            if let existing = byID[session.id] {
                byID[session.id] = DiveSessionMerge.preferred(existing, session)
            } else {
                byID[session.id] = session
            }
        }
        let merged = byID[id]
        XCTAssertEqual(merged?.samples.count, 2)
        XCTAssertEqual(merged?.samples.last?.depthMeters ?? 0, 25, accuracy: 0.01)
        XCTAssertEqual(merged?.endDate, outboundEnd)
    }

    func testWatchSyncCodecValidatesAndNormalizesSessionRoundTrip() throws {
        let session = makeSession(start: Date(timeIntervalSince1970: 2_000), end: Date(timeIntervalSince1970: 2_000).addingTimeInterval(90), maxDepth: 22)
        let normalized = try WatchDiveSyncCodec.validateForSync(session)
        XCTAssertEqual(normalized.id, session.id)
        XCTAssertEqual(normalized.samples.count, session.samples.count)
        XCTAssertEqual(normalized.maxDepthMeters, session.maxDepthMeters, accuracy: 0.01)
    }

    func testDuplicateSessionIDMergeDoesNotDropSamples() {
        let id = UUID()
        let start = Date(timeIntervalSince1970: 3_000)
        let first = makeSession(id: id, start: start, end: start.addingTimeInterval(60), maxDepth: 15)
        let second = makeSession(id: id, start: start, end: start.addingTimeInterval(120), maxDepth: 18)
        let merged = DiveSessionMerge.preferred(first, second)
        XCTAssertFalse(merged.samples.isEmpty)
        XCTAssertGreaterThanOrEqual(merged.maxDepthMeters, 15)
    }

    func testBoundedImportedSessionStoreCapsDuplicates() {
        var ids: Set<UUID> = []
        let repeated = UUID()
        for _ in 0..<600 {
            ids = WatchSyncBoundedIDStore.merge(repeated, into: ids, maxCount: 512)
        }
        XCTAssertLessThanOrEqual(ids.count, WatchSyncBoundedIDStore.maxImportedSessionIDs)
        XCTAssertTrue(ids.contains(repeated))
    }

    private func makeSession(
        id: UUID = UUID(),
        start: Date,
        end: Date,
        maxDepth: Double
    ) -> DiveSession {
        let samples = [
            DiveSample(timestamp: start, depthMeters: 0, temperatureCelsius: 20),
            DiveSample(timestamp: end, depthMeters: maxDepth, temperatureCelsius: 20)
        ]
        let summary = DiveProfileMath.summary(samples: samples, startDate: start, endDate: end)
        return DiveSession(
            id: id,
            startDate: start,
            endDate: end,
            durationSeconds: summary.durationSeconds,
            maxDepthMeters: summary.maxDepthMeters,
            avgDepthMeters: summary.averageDepthMeters,
            avgWaterTemperatureCelsius: summary.averageTemperatureCelsius,
            ttv: summary.ttv,
            entryGPS: nil,
            exitGPS: nil,
            samples: samples
        )
    }
}
