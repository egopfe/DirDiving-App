import XCTest

final class ApneaDomainModelTests: XCTestCase {
    func testSessionCodableRoundTrip() throws {
        let session = makeSampleSession()
        let data = try JSONEncoder().encode(session)
        let decoded = try JSONDecoder().decode(ApneaSession.self, from: data)
        XCTAssertEqual(decoded, session)
        XCTAssertEqual(decoded.schemaVersion, ApneaSession.currentSchemaVersion)
    }

    func testMissingSchemaVersionMigratesToV1() throws {
        var session = makeSampleSession()
        session.schemaVersion = 0
        session.warnings = []
        let encoded = try JSONEncoder().encode(session)
        var object = try JSONSerialization.jsonObject(with: encoded) as! [String: Any]
        object.removeValue(forKey: "schemaVersion")
        let stripped = try JSONSerialization.data(withJSONObject: object)

        let decoded = try JSONDecoder().decode(ApneaSession.self, from: stripped)
        XCTAssertEqual(decoded.schemaVersion, ApneaSession.currentSchemaVersion)
        XCTAssertTrue(decoded.warnings.contains(.schemaMigrated))
        XCTAssertEqual(decoded.dives.count, session.dives.count)
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
          "dives": [],
          "statistics": {
            "diveCount": 0,
            "totalUnderwaterSeconds": 0,
            "sessionMaxDepthMeters": 0,
            "averageDiveDurationSeconds": 0,
            "totalRecoverySeconds": 0
          },
          "surfaceGPSPoints": [],
          "warnings": []
        }
        """
        let decoded = try makeDecoder().decode(ApneaSession.self, from: Data(json.utf8))
        XCTAssertEqual(decoded.id, sessionID)
        XCTAssertEqual(decoded.schemaVersion, ApneaSession.currentSchemaVersion)
        XCTAssertTrue(decoded.warnings.contains(.schemaMigrated))
    }

    func testNonFiniteDepthRejected() {
        let sample = ApneaSample(
            monotonicRelativeTimestampSeconds: 1,
            depthMeters: .nan,
            verticalSpeedMetersPerSecond: 0
        )
        XCTAssertTrue(ApneaDomainValidator.validate(sample: sample).contains(.nonFinite(field: "sample.depthMeters")))

        var dive = makeSampleDive(maxDepthMeters: 10)
        dive.maxDepthMeters = .infinity
        XCTAssertTrue(ApneaDomainValidator.validate(dive: dive).contains(.nonFinite(field: "dive.maxDepthMeters")))
    }

    func testSampleOrderingAndDuplicateRemoval() {
        let firstID = UUID()
        let duplicateID = UUID()
        let samples = [
            ApneaSample(id: duplicateID, monotonicRelativeTimestampSeconds: 3, depthMeters: 8),
            ApneaSample(id: firstID, monotonicRelativeTimestampSeconds: 1, depthMeters: 2),
            ApneaSample(id: duplicateID, monotonicRelativeTimestampSeconds: 2, depthMeters: 5),
        ]
        let normalized = ApneaDomainSupport.normalizedSamples(samples)
        XCTAssertEqual(normalized.map(\.id), [firstID, duplicateID])
        XCTAssertEqual(normalized.map(\.monotonicRelativeTimestampSeconds), [1, 2])
    }

    func testNonMonotonicSamplesFlagged() {
        let samples = [
            ApneaSample(monotonicRelativeTimestampSeconds: 0, depthMeters: 0),
            ApneaSample(monotonicRelativeTimestampSeconds: 2, depthMeters: 5),
            ApneaSample(monotonicRelativeTimestampSeconds: 1.5, depthMeters: 4),
        ]
        let dive = ApneaDive(startedAtMonotonicSeconds: 0, samples: samples)
        XCTAssertTrue(ApneaDomainValidator.validate(dive: dive).contains(.nonMonotonicSamples))
    }

    func testDuplicateSampleIDsFlagged() {
        let sharedID = UUID()
        let samples = [
            ApneaSample(id: sharedID, monotonicRelativeTimestampSeconds: 0, depthMeters: 0),
            ApneaSample(id: sharedID, monotonicRelativeTimestampSeconds: 1, depthMeters: 1),
        ]
        let dive = ApneaDive(startedAtMonotonicSeconds: 0, samples: samples)
        XCTAssertTrue(ApneaDomainValidator.validate(dive: dive).contains(.duplicateSampleID(sharedID)))
    }

    func testDiveSessionAndPersonalBestDepthsAreDistinct() {
        let diveA = ApneaDive(
            startedAtMonotonicSeconds: 0,
            durationSeconds: 60,
            maxDepthMeters: 20,
            averageDepthMeters: 12
        )
        let diveB = ApneaDive(
            startedAtMonotonicSeconds: 100,
            durationSeconds: 45,
            maxDepthMeters: 15,
            averageDepthMeters: 10
        )
        let profile = ApneaProfile(
            displayName: "Test",
            personalBestMaxDepthMeters: 32
        )
        let session = ApneaSession(
            startMode: .manual,
            state: .completed,
            dives: [diveA, diveB],
            profile: profile
        )

        XCTAssertEqual(diveA.maxDepthMeters, 20)
        XCTAssertEqual(diveB.maxDepthMeters, 15)
        XCTAssertEqual(session.statistics.sessionMaxDepthMeters, 20)
        XCTAssertEqual(session.profile?.personalBestMaxDepthMeters, 32)
        XCTAssertNotEqual(session.statistics.sessionMaxDepthMeters, profile.personalBestMaxDepthMeters)
    }

    func testLegacyDiveRecordMigration() {
        let legacyID = UUID()
        let dive = ApneaSchemaMigration.migrateLegacyDiveRecord(
            id: legacyID,
            durationSeconds: 82,
            maxDepthMeters: 24,
            recoverySeconds: 110
        )
        XCTAssertEqual(dive.id, legacyID)
        XCTAssertEqual(dive.durationSeconds, 82)
        XCTAssertEqual(dive.maxDepthMeters, 24)
        XCTAssertEqual(dive.recoveryAfter?.completedSeconds, 110)
        XCTAssertTrue(ApneaDomainValidator.isValid(session: ApneaSession(startMode: .imported, state: .completed, dives: [dive])))
    }

    func testSessionStatisticsAggregate() {
        let dives = [
            ApneaDive(startedAtMonotonicSeconds: 0, durationSeconds: 60, maxDepthMeters: 18, averageDepthMeters: 10),
            ApneaDive(startedAtMonotonicSeconds: 200, durationSeconds: 40, maxDepthMeters: 12, averageDepthMeters: 8),
        ]
        let stats = ApneaSessionStatistics.aggregate(from: dives)
        XCTAssertEqual(stats.diveCount, 2)
        XCTAssertEqual(stats.totalUnderwaterSeconds, 100)
        XCTAssertEqual(stats.sessionMaxDepthMeters, 18)
        XCTAssertEqual(stats.averageDiveDurationSeconds, 50)
    }

    func testDiveDepthMetricsRecomputedFromSamples() {
        let samples = [
            ApneaSample(monotonicRelativeTimestampSeconds: 0, depthMeters: 0),
            ApneaSample(monotonicRelativeTimestampSeconds: 1, depthMeters: 10),
            ApneaSample(monotonicRelativeTimestampSeconds: 2, depthMeters: 20),
            ApneaSample(monotonicRelativeTimestampSeconds: 3, depthMeters: 5),
        ]
        let dive = ApneaDive(startedAtMonotonicSeconds: 0, samples: samples)
        let metrics = dive.recomputedDepthMetrics()
        XCTAssertEqual(metrics.maxDepthMeters, 20)
        XCTAssertEqual(metrics.averageDepthMeters, 8.75, accuracy: 0.001)
    }

    // MARK: - Fixtures

    private func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }

    private func makeSampleDive(maxDepthMeters: Double) -> ApneaDive {
        ApneaDive(
            startedAtMonotonicSeconds: 0,
            endedAtMonotonicSeconds: 60,
            durationSeconds: 60,
            maxDepthMeters: maxDepthMeters,
            averageDepthMeters: maxDepthMeters / 2,
            samples: [
                ApneaSample(monotonicRelativeTimestampSeconds: 0, depthMeters: 0),
                ApneaSample(monotonicRelativeTimestampSeconds: 30, depthMeters: maxDepthMeters),
            ],
            events: [
                ApneaEvent(kind: .descentStart, monotonicRelativeTimestampSeconds: 1),
                ApneaEvent(kind: .maxDepthReached, monotonicRelativeTimestampSeconds: 30, depthMeters: maxDepthMeters),
            ],
            targets: [
                ApneaTarget(kind: .depth, label: "Plate", targetDepthMeters: maxDepthMeters, wasReached: true)
            ],
            markers: [
                ApneaDepthMarker(label: "Plate", depthMeters: maxDepthMeters)
            ],
            reachedTargetIDs: [],
            reachedMarkerIDs: []
        )
    }

    private func makeSampleSession() -> ApneaSession {
        let dive = makeSampleDive(maxDepthMeters: 16)
        return ApneaSession(
            startMode: .manual,
            state: .completed,
            startedAtMonotonicSeconds: 0,
            endedAtMonotonicSeconds: 120,
            dives: [dive],
            surfaceGPSPoints: [
                ApneaSurfaceGPSPoint(latitude: 44.1, longitude: 9.8, horizontalAccuracyMeters: 4)
            ],
            buddy: ApneaBuddyInfo(name: "Buddy", isSafetyDiverPresent: true),
            equipment: ApneaEquipmentProfile(weightKilograms: 3),
            profile: ApneaProfile(displayName: "Athlete", personalBestMaxDepthMeters: 30),
            warnings: []
        )
    }
}
