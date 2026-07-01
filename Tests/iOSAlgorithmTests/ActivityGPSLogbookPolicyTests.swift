import XCTest
@testable import DIRDivingiOSApp

final class ActivityGPSLogbookPolicyTests: XCTestCase {
    func testDivingGPSFieldsDoNotAppearInSnorkelingSession() {
        let diveGPS = GPSPoint(latitude: 44.4, longitude: 8.9, horizontalAccuracy: 5, timestamp: Date())
        let dive = DiveSession(
            startDate: Date(),
            endDate: Date().addingTimeInterval(60),
            durationSeconds: 60,
            maxDepthMeters: 15,
            avgDepthMeters: 10,
            avgWaterTemperatureCelsius: nil,
            ttv: 5,
            entryGPS: diveGPS,
            exitGPS: diveGPS,
            samples: []
        )
        var snorkel = SnorkelingSession(startMode: .watch, state: .completed, dips: [])
        snorkel.trackPoints = []

        let diveMirror = Mirror(reflecting: dive)
        let snorkelMirror = Mirror(reflecting: snorkel)
        XCTAssertNotNil(diveMirror.children.first(where: { $0.label == "entryGPS" }))
        XCTAssertNil(snorkelMirror.children.first(where: { $0.label == "entryGPS" }))
        XCTAssertNil(snorkelMirror.children.first(where: { $0.label == "exitGPS" }))
        XCTAssertTrue(snorkel.trackPoints.isEmpty)
        _ = dive
    }

    func testSnorkelingTrackPointsDoNotAppearInApneaSession() {
        var snorkel = SnorkelingSession(startMode: .watch, state: .completed, dips: [])
        snorkel.trackPoints = [
            SnorkelingTrackPoint(monotonicRelativeTimestampSeconds: 0, latitude: 44.0, longitude: 9.0, gpsQuality: .measured, isUnderwater: false)
        ]
        let apnea = ApneaSession(
            startMode: .watch,
            state: .completed,
            dives: [ApneaDive(startedAtMonotonicSeconds: 0, durationSeconds: 60, maxDepthMeters: 10, averageDepthMeters: 8)]
        )

        let apneaMirror = Mirror(reflecting: apnea)
        XCTAssertNil(apneaMirror.children.first(where: { $0.label == "trackPoints" }))
        XCTAssertNil(apneaMirror.children.first(where: { $0.label == "entryPoint" }))
        XCTAssertTrue(apnea.surfaceGPSPoints.isEmpty)
        XCTAssertEqual(snorkel.trackPoints.count, 1)
    }

    func testApneaSurfaceGPSPointsDoNotAppearInDiveSession() {
        var apnea = ApneaSession(
            startMode: .watch,
            state: .completed,
            dives: [ApneaDive(startedAtMonotonicSeconds: 0, durationSeconds: 60, maxDepthMeters: 10, averageDepthMeters: 8)]
        )
        apnea.surfaceGPSPoints = [
            ApneaSurfaceGPSPoint(latitude: 45.0, longitude: 9.0, horizontalAccuracyMeters: 5, capturedAt: Date())
        ]
        let dive = DiveSession(
            startDate: Date(),
            endDate: Date().addingTimeInterval(60),
            durationSeconds: 60,
            maxDepthMeters: 12,
            avgDepthMeters: 8,
            avgWaterTemperatureCelsius: nil,
            ttv: 4,
            entryGPS: nil,
            exitGPS: nil,
            samples: []
        )

        let diveMirror = Mirror(reflecting: dive)
        XCTAssertNil(diveMirror.children.first(where: { $0.label == "surfaceGPSPoints" }))
        XCTAssertTrue(dive.entryGPS == nil && dive.exitGPS == nil)
        XCTAssertEqual(apnea.surfaceGPSPoints.count, 1)
    }

    func testMissingGPSDoesNotInvalidateAnyActivitySession() {
        let start = Date(timeIntervalSince1970: 4_000)
        let end = start.addingTimeInterval(60)
        let samples = [
            DiveSample(timestamp: start, depthMeters: 0, temperatureCelsius: 20),
            DiveSample(timestamp: end, depthMeters: 10, temperatureCelsius: 19),
        ]
        let summary = DiveProfileMath.summary(samples: samples, startDate: start, endDate: end)
        let dive = DiveSession(
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
        var snorkel = SnorkelingSession(
            startMode: .watch,
            state: .completed,
            dips: [SnorkelingDip(startedAtMonotonicSeconds: 0, durationSeconds: 60, maxDepthMeters: 4, averageDepthMeters: 3)]
        )
        snorkel.trackPoints = []
        snorkel.statistics = snorkel.refreshedStatistics()
        var apnea = ApneaSession(
            startMode: .watch,
            state: .completed,
            dives: [ApneaDive(startedAtMonotonicSeconds: 0, durationSeconds: 60, maxDepthMeters: 12, averageDepthMeters: 8)]
        )
        apnea.statistics = apnea.refreshedStatistics()

        XCTAssertTrue(ActivityGPSLogbookPolicy.divingSessionRemainsValidWithoutGPS(dive), "diving")
        XCTAssertTrue(ActivityGPSLogbookPolicy.snorkelingSessionRemainsValidWithoutGPS(snorkel), "snorkeling")
        XCTAssertTrue(ActivityGPSLogbookPolicy.apneaSessionRemainsValidWithoutGPS(apnea), "apnea")
    }

    func testSnorkelTrackCountsSeparateQualities() {
        let points = [
            SnorkelingTrackPoint(monotonicRelativeTimestampSeconds: 0, latitude: 44, longitude: 9, gpsQuality: .measured, isUnderwater: false),
            SnorkelingTrackPoint(monotonicRelativeTimestampSeconds: 1, latitude: 44.001, longitude: 9.001, gpsQuality: .stale, isUnderwater: false),
            SnorkelingTrackPoint(monotonicRelativeTimestampSeconds: 2, latitude: nil, longitude: nil, gpsQuality: .unavailable, isUnderwater: true),
        ]
        let counts = ActivityGPSLogbookPresentation.snorkelTrackCounts(points)
        XCTAssertEqual(counts.measured, 1)
        XCTAssertEqual(counts.stale, 1)
        XCTAssertEqual(counts.unavailable, 1)
    }

    func testApneaStartEndAvailabilityPresentation() {
        let empty = ActivityGPSLogbookPresentation.apneaStartEndAvailability(points: [])
        XCTAssertEqual(empty.start, "gps.status.unavailable")
        XCTAssertEqual(empty.end, "gps.status.unavailable")

        let startOnly = [
            ApneaSurfaceGPSPoint(latitude: 44, longitude: 9, horizontalAccuracyMeters: 5, capturedAt: Date())
        ]
        let partial = ActivityGPSLogbookPresentation.apneaStartEndAvailability(points: startOnly)
        XCTAssertEqual(partial.start, "gps.status.available")
        XCTAssertEqual(partial.end, "gps.status.unavailable")
    }
}
