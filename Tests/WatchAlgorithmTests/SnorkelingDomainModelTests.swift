import XCTest

final class SnorkelingDomainModelTests: XCTestCase {
    func testSessionCodableRoundTrip() throws {
        let session = makeSampleSession()
        let data = try JSONEncoder().encode(session)
        let decoded = try JSONDecoder().decode(SnorkelingSession.self, from: data)
        XCTAssertEqual(decoded, session)
        XCTAssertEqual(decoded.schemaVersion, SnorkelingSession.currentSchemaVersion)
    }

    func testMissingSchemaVersionMigratesToV1() throws {
        var session = makeSampleSession()
        session.schemaVersion = 0
        session.warnings = []
        let encoded = try JSONEncoder().encode(session)
        var object = try JSONSerialization.jsonObject(with: encoded) as! [String: Any]
        object.removeValue(forKey: "schemaVersion")
        let stripped = try JSONSerialization.data(withJSONObject: object)

        let decoded = try JSONDecoder().decode(SnorkelingSession.self, from: stripped)
        XCTAssertEqual(decoded.schemaVersion, SnorkelingSession.currentSchemaVersion)
        XCTAssertTrue(decoded.warnings.contains(.schemaMigrated))
    }

    func testFutureSchemaVersionDecodesWithMigrationWarning() throws {
        let sessionID = UUID()
        let json = """
        {
          "id": "\(sessionID.uuidString)",
          "schemaVersion": 2,
          "startMode": "watch",
          "state": "active",
          "createdAt": 1718539200,
          "trackPoints": [],
          "dips": [],
          "markers": [],
          "alarms": [],
          "events": [],
          "routePlans": [],
          "statistics": {
            "dipCount": 0,
            "totalDipSeconds": 0,
            "sessionMaxDepthMeters": 0,
            "totalDistanceMeters": 0,
            "averageSpeedMetersPerSecond": 0,
            "markerCount": 0,
            "eventCount": 0,
            "sessionDurationSeconds": 0
          },
          "warnings": []
        }
        """
        let decoded = try makeDecoder().decode(SnorkelingSession.self, from: Data(json.utf8))
        XCTAssertEqual(decoded.id, sessionID)
        XCTAssertEqual(decoded.schemaVersion, SnorkelingSession.currentSchemaVersion)
        XCTAssertTrue(decoded.warnings.contains(.schemaMigrated))
    }

    func testRoutePlanCodableRoundTrip() throws {
        let plan = SnorkelingRoutePlan(
            name: "Reef loop",
            waypoints: [
                SnorkelingWaypoint(name: "Entry", category: .reef, latitude: 44.1, longitude: 8.2, routeOrder: 0)
            ],
            offlineCacheReady: true
        )
        let decoded = try JSONDecoder().decode(SnorkelingRoutePlan.self, from: try JSONEncoder().encode(plan))
        XCTAssertEqual(decoded, plan)
        XCTAssertEqual(decoded.schemaVersion, SnorkelingRoutePlan.currentSchemaVersion)
    }

    func testNonFiniteDepthRejected() {
        let sample = SnorkelingDipSample(monotonicRelativeTimestampSeconds: 1, depthMeters: .nan)
        XCTAssertTrue(SnorkelingDomainValidator.validate(dipSample: sample).contains(.nonFinite(field: "dipSample.depthMeters")))
    }

    func testInvalidCoordinateRejected() {
        let marker = SnorkelingMarker(
            category: .reef,
            monotonicRelativeTimestampSeconds: 0,
            positionQuality: .measured,
            latitude: 120,
            longitude: 8
        )
        XCTAssertTrue(SnorkelingDomainValidator.validate(marker: marker).contains(.invalidCoordinate(field: "marker.coordinate")))
    }

    func testTrackPointOrderingAndDuplicateRemoval() {
        let firstID = UUID()
        let duplicateID = UUID()
        let points = [
            SnorkelingTrackPoint(id: duplicateID, monotonicRelativeTimestampSeconds: 3, latitude: 44.1, longitude: 8.2, gpsQuality: .measured),
            SnorkelingTrackPoint(id: firstID, monotonicRelativeTimestampSeconds: 1, latitude: 44.0, longitude: 8.1, gpsQuality: .measured),
            SnorkelingTrackPoint(id: duplicateID, monotonicRelativeTimestampSeconds: 2, latitude: 44.05, longitude: 8.15, gpsQuality: .measured),
        ]
        let normalized = SnorkelingDomainSupport.normalizedTrackPoints(points)
        XCTAssertEqual(normalized.map(\.id), [firstID, duplicateID])
        XCTAssertEqual(normalized.map(\.monotonicRelativeTimestampSeconds), [1, 2])
    }

    func testNonMonotonicTrackPointsFlagged() {
        let points = [
            SnorkelingTrackPoint(monotonicRelativeTimestampSeconds: 0, latitude: 44, longitude: 8, gpsQuality: .measured),
            SnorkelingTrackPoint(monotonicRelativeTimestampSeconds: 2, latitude: 44.01, longitude: 8.01, gpsQuality: .measured),
            SnorkelingTrackPoint(monotonicRelativeTimestampSeconds: 1.5, latitude: 44.005, longitude: 8.005, gpsQuality: .measured),
        ]
        XCTAssertTrue(SnorkelingDomainValidator.validate(session: SnorkelingSession(startMode: .watch, state: .active, trackPoints: points)).contains(.nonMonotonicTrackPoints))
    }

    func testUnderwaterMeasuredGPSRejected() {
        let point = SnorkelingTrackPoint(
            monotonicRelativeTimestampSeconds: 1,
            latitude: 44,
            longitude: 8,
            gpsQuality: .measured,
            isUnderwater: true
        )
        XCTAssertTrue(SnorkelingDomainValidator.validate(trackPoint: point).contains(.underwaterMeasuredGPS))
    }

    func testEstimatedUnderwaterTrackDoesNotCountAsMeasuredDistance() {
        let points = [
            SnorkelingTrackPoint(monotonicRelativeTimestampSeconds: 0, latitude: 44.0, longitude: 8.0, gpsQuality: .measured, isUnderwater: false),
            SnorkelingTrackPoint(monotonicRelativeTimestampSeconds: 1, latitude: nil, longitude: nil, gpsQuality: .estimated, isUnderwater: true),
            SnorkelingTrackPoint(monotonicRelativeTimestampSeconds: 2, latitude: 44.001, longitude: 8.001, gpsQuality: .measured, isUnderwater: false),
        ]
        XCTAssertGreaterThan(SnorkelingDomainSupport.trackDistanceMeters(points), 0)
        let underwaterOnly = [
            SnorkelingTrackPoint(monotonicRelativeTimestampSeconds: 0, latitude: 44.0, longitude: 8.0, gpsQuality: .estimated, isUnderwater: true),
            SnorkelingTrackPoint(monotonicRelativeTimestampSeconds: 1, latitude: 44.01, longitude: 8.01, gpsQuality: .estimated, isUnderwater: true),
        ]
        XCTAssertEqual(SnorkelingDomainSupport.trackDistanceMeters(underwaterOnly), 0)
    }

    func testDuplicateDipSampleIDsFlagged() {
        let sharedID = UUID()
        let samples = [
            SnorkelingDipSample(id: sharedID, monotonicRelativeTimestampSeconds: 0, depthMeters: 1),
            SnorkelingDipSample(id: sharedID, monotonicRelativeTimestampSeconds: 1, depthMeters: 2),
        ]
        let dip = SnorkelingDip(startedAtMonotonicSeconds: 0, samples: samples)
        XCTAssertTrue(SnorkelingDomainValidator.validate(dip: dip).contains(.duplicateDipSampleID(sharedID)))
    }

    func testSessionStatisticsAggregateDistinctDepths() {
        let dip = SnorkelingDip(
            startedAtMonotonicSeconds: 0,
            durationSeconds: 30,
            maxDepthMeters: 4,
            averageDepthMeters: 3,
            samples: [
                SnorkelingDipSample(monotonicRelativeTimestampSeconds: 0, depthMeters: 2),
                SnorkelingDipSample(monotonicRelativeTimestampSeconds: 10, depthMeters: 4),
            ]
        )
        let profile = SnorkelingProfile(displayName: "Snorkeler", personalBestMaxDepthMeters: 12)
        let session = SnorkelingSession(
            startMode: .watch,
            state: .completed,
            dips: [dip],
            profile: profile
        )
        XCTAssertEqual(session.statistics.dipCount, 1)
        XCTAssertEqual(session.statistics.sessionMaxDepthMeters, 4)
        XCTAssertEqual(session.profile?.personalBestMaxDepthMeters, 12)
    }

    // MARK: - Helpers

    private func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }

    private func makeSampleSession() -> SnorkelingSession {
        let entry = SnorkelingTrackPoint(
            monotonicRelativeTimestampSeconds: 0,
            wallClockTimestamp: Date(timeIntervalSince1970: 1_700_000_000),
            latitude: 44.4056,
            longitude: 8.9463,
            horizontalAccuracyMeters: 4,
            gpsQuality: .measured,
            depthMeters: 0,
            depthQuality: .measured,
            isUnderwater: false
        )
        let dip = SnorkelingDip(
            startedAtMonotonicSeconds: 10,
            endedAtMonotonicSeconds: 40,
            durationSeconds: 30,
            maxDepthMeters: 3.5,
            averageDepthMeters: 2.5,
            samples: [
                SnorkelingDipSample(monotonicRelativeTimestampSeconds: 10, depthMeters: 1),
                SnorkelingDipSample(monotonicRelativeTimestampSeconds: 25, depthMeters: 3.5),
            ]
        )
        let marker = SnorkelingMarker(
            category: .marineLife,
            monotonicRelativeTimestampSeconds: 50,
            latitude: 44.4058,
            longitude: 8.9465,
            depthMeters: 0.5
        )
        return SnorkelingSession(
            startMode: .watch,
            state: .active,
            createdAt: Date(timeIntervalSince1970: 1_700_000_000),
            startedAtMonotonicSeconds: 0,
            entryPoint: entry,
            trackPoints: [entry],
            dips: [dip],
            markers: [marker],
            alarms: [
                SnorkelingAlarm(kind: .maxDepth, label: "Depth", thresholdDepthMeters: 5)
            ],
            events: [
                SnorkelingEvent(kind: .sessionStarted, monotonicRelativeTimestampSeconds: 0)
            ],
            routePlans: [
                SnorkelingRoutePlan(name: "Coast", waypoints: [
                    SnorkelingWaypoint(name: "Buoy", category: .buoy, latitude: 44.41, longitude: 8.95, routeOrder: 0)
                ])
            ],
            profile: SnorkelingProfile(displayName: "Test"),
            buddy: SnorkelingBuddyInfo(name: "Buddy", isBuddyPresent: true)
        )
    }
}
