import XCTest

final class SnorkelingWatchGPSCaptureTests: XCTestCase {
    func testMeasuredSurfaceFixCreatesEntryPoint() {
        var engine = SnorkelingSessionEngine()
        engine.armSession()
        engine.startSession()
        let now = Date()
        engine.ingest(
            depthRaw: DepthMeasurementRaw(depthMeters: 0, sensorTimestamp: now, receivedAt: now, temperatureCelsius: 22),
            gpsRaw: SnorkelingGPSRawFix(
                latitude: 44.40,
                longitude: 8.93,
                horizontalAccuracyMeters: 6,
                sensorTimestamp: now,
                receivedAt: now,
                source: .live
            ),
            wallClock: now
        )
        XCTAssertNotNil(engine.snapshot.session.entryPoint)
        XCTAssertGreaterThan(engine.snapshot.session.trackPoints.count, 0)
        XCTAssertEqual(engine.snapshot.session.trackPoints.first?.gpsQuality, .measured)
    }

    func testUnderwaterWithoutGPSDoesNotCreateMeasuredCoordinate() {
        var engine = SnorkelingSessionEngine()
        engine.armSession()
        engine.startSession()
        let now = Date()
        engine.ingest(
            depthRaw: DepthMeasurementRaw(depthMeters: 4, sensorTimestamp: now, receivedAt: now, temperatureCelsius: 20),
            gpsRaw: nil,
            wallClock: now
        )
        XCTAssertTrue(engine.snapshot.session.trackPoints.allSatisfy { $0.gpsQuality != .measured || $0.latitude == nil })
    }

    func testTrackDistanceIgnoresUnavailableCoordinates() {
        let points = [
            SnorkelingTrackPoint(monotonicRelativeTimestampSeconds: 0, latitude: 44.0, longitude: 9.0, gpsQuality: .measured, isUnderwater: false),
            SnorkelingTrackPoint(monotonicRelativeTimestampSeconds: 1, latitude: nil, longitude: nil, gpsQuality: .unavailable, isUnderwater: true),
            SnorkelingTrackPoint(monotonicRelativeTimestampSeconds: 2, latitude: 44.001, longitude: 9.001, gpsQuality: .measured, isUnderwater: false),
        ]
        let distance = SnorkelingDomainSupport.trackDistanceMeters(points)
        XCTAssertGreaterThan(distance, 0)
    }
}
