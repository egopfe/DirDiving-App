import XCTest
@testable import DIRDivingiOSApp

final class DiveSessionGPSSyncTests: XCTestCase {
    override func setUp() {
        super.setUp()
        WatchSyncAuth.resetPeerTrust()
        WatchDiveSyncCodec.resetTestHooks()
        WatchDiveSyncCodec.testHook_bypassConnectivityChecks = true
        WatchSyncTestSupport.installDeterministicSecrets()
        WatchSyncTestSupport.requirePeerSecret()
    }

    override func tearDown() {
        WatchDiveSyncCodec.resetTestHooks()
        WatchSyncTestSupport.resetSecrets()
        super.tearDown()
    }

    func testEntryAndExitGPSSurviveWatchTransportRoundTrip() throws {
        let start = Date(timeIntervalSince1970: 2_000)
        let entry = GPSPoint(latitude: 44.40, longitude: 8.93, horizontalAccuracy: 6, timestamp: start)
        let exit = GPSPoint(latitude: 44.41, longitude: 8.94, horizontalAccuracy: 8, timestamp: start.addingTimeInterval(600))
        let session = makeSession(
            start: start,
            entryGPS: entry,
            exitGPS: exit,
            entrySource: .fix,
            exitSource: .fix
        )

        let payload = try WatchDiveSyncCodec.makeTestWatchTransport(session: session)
        let parsed = try WatchDiveSyncCodec.parsePayload(from: payload).session

        XCTAssertEqual(parsed.entryGPS?.latitude ?? 0, 44.40, accuracy: 0.0001)
        XCTAssertEqual(parsed.exitGPS?.longitude ?? 0, 8.94, accuracy: 0.0001)
        XCTAssertEqual(parsed.entryGPSFixSource, .fix)
        XCTAssertEqual(parsed.exitGPSFixSource, .fix)
    }

    func testInvalidEntryGPSStrippedByValidatorWithoutInvalidatingSession() throws {
        let start = Date(timeIntervalSince1970: 2_100)
        let invalidEntry = GPSPoint(latitude: 999, longitude: 8.9, horizontalAccuracy: 5, timestamp: start)
        let session = makeSession(start: start, entryGPS: invalidEntry, exitGPS: nil, entrySource: .fix, exitSource: .noFix)

        let validated = try WatchDiveSyncCodec.validateForSync(session)
        XCTAssertNil(validated.entryGPS)
        XCTAssertTrue(ActivityGPSLogbookPolicy.divingSessionRemainsValidWithoutGPS(validated))
    }

    func testMissingGPSDoesNotInvalidateDiveSession() throws {
        let session = makeSession(start: Date(timeIntervalSince1970: 2_200))
        let validated = try WatchDiveSyncCodec.validateForSync(session)
        XCTAssertNil(validated.entryGPS)
        XCTAssertNil(validated.exitGPS)
        XCTAssertTrue(ActivityGPSLogbookPolicy.divingSessionRemainsValidWithoutGPS(validated))
    }

    func testMergePreservesValidEntryGPSAfterSync() {
        let id = UUID()
        let start = Date(timeIntervalSince1970: 2_300)
        let gps = GPSPoint(latitude: 40.1, longitude: 9.2, horizontalAccuracy: 5, timestamp: start)
        let local = makeSession(id: id, start: start, entryGPS: gps, exitGPS: nil, entrySource: .fix, exitSource: .noFix)
        let remote = makeSession(id: id, start: start, entryGPS: nil, exitGPS: nil, entrySource: .noFix, exitSource: .noFix)
        let merged = DiveSessionMerge.preferred(local, remote)
        XCTAssertEqual(merged.entryGPS?.latitude ?? 0, 40.1, accuracy: 0.0001)
    }

    private func makeSession(
        id: UUID = UUID(),
        start: Date,
        entryGPS: GPSPoint? = nil,
        exitGPS: GPSPoint? = nil,
        entrySource: GPSFixSource = .noFix,
        exitSource: GPSFixSource = .noFix
    ) -> DiveSession {
        let end = start.addingTimeInterval(120)
        let samples = [
            DiveSample(timestamp: start, depthMeters: 0, temperatureCelsius: 20),
            DiveSample(timestamp: end, depthMeters: 18, temperatureCelsius: 19),
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
            entryGPS: entryGPS,
            exitGPS: exitGPS,
            entryGPSFixSource: entrySource,
            exitGPSFixSource: exitSource,
            samples: samples
        )
    }
}
