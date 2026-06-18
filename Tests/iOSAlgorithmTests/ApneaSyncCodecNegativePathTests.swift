import XCTest

/// Plan package negative-path codec coverage (iOS target — validate/decode only).
final class ApneaSyncCodecNegativePathTests: XCTestCase {
    // MARK: - Future / unsupported schema

    func testFuturePlanSchemaIsRejected() throws {
        var package = try makeValidPackage(revision: 1)
        package.body.schemaVersion = ApneaSyncCodec.currentSchemaVersion + 1
        package.payloadChecksumSHA256 = try ApneaSyncCodec.checksum(for: package.body)
        XCTAssertThrowsError(try ApneaSyncCodec.validate(package)) { error in
            XCTAssertEqual(error as? ApneaSyncValidationError, .futureSchema)
        }
    }

    func testMissingPlanSchemaIsRejected() throws {
        var package = try makeValidPackage(revision: 2)
        package.body.schemaVersion = 0
        package.payloadChecksumSHA256 = try ApneaSyncCodec.checksum(for: package.body)
        XCTAssertThrowsError(try ApneaSyncCodec.validate(package)) { error in
            XCTAssertEqual(error as? ApneaSyncValidationError, .unsupportedSchema)
        }
    }

    func testUnsupportedPlanSchemaIsRejectedWithoutPersistence() throws {
        var package = try makeValidPackage(revision: 3)
        package.body.schemaVersion = -1
        package.payloadChecksumSHA256 = try ApneaSyncCodec.checksum(for: package.body)
        XCTAssertThrowsError(try ApneaSyncCodec.validate(package)) { error in
            XCTAssertEqual(error as? ApneaSyncValidationError, .unsupportedSchema)
        }
    }

    // MARK: - Corrupt / truncated packages

    func testEmptyPlanPackageDataFailsDecode() {
        XCTAssertThrowsError(try ApneaSyncCodec.decode(Data()))
    }

    func testTruncatedPlanPackageFailsDecode() throws {
        let activeData = try ApneaSyncCodec.encode(try makeValidPackage(revision: 10))
        let truncated = Data(activeData.prefix(max(1, activeData.count / 2)))
        XCTAssertThrowsError(try ApneaSyncCodec.decode(truncated))
    }

    func testMalformedJSONPlanPackageFailsDecode() {
        XCTAssertThrowsError(try ApneaSyncCodec.decode(Data("{not-json".utf8)))
    }

    func testChecksumMismatchRejected() throws {
        var package = try makeValidPackage(revision: 4)
        package.payloadChecksumSHA256 = "0".padding(toLength: 64, withPad: "0", startingAt: 0)
        XCTAssertThrowsError(try ApneaSyncCodec.validate(package)) { error in
            XCTAssertEqual(error as? ApneaSyncValidationError, .checksumMismatch)
        }
    }

    func testInvalidChecksumFormatRejected() throws {
        var package = try makeValidPackage(revision: 5)
        package.payloadChecksumSHA256 = "not-a-hex-digest"
        XCTAssertThrowsError(try ApneaSyncCodec.validate(package)) { error in
            XCTAssertEqual(error as? ApneaSyncValidationError, .checksumMismatch)
        }
    }

    func testExpiredPackageRejected() throws {
        var package = try makeValidPackage(revision: 6, expiresAt: Date().addingTimeInterval(-60))
        package.payloadChecksumSHA256 = try ApneaSyncCodec.checksum(for: package.body)
        XCTAssertThrowsError(try ApneaSyncCodec.validate(package)) { error in
            XCTAssertEqual(error as? ApneaSyncValidationError, .expired)
        }
    }

    func testInvalidPlanTitleRejected() throws {
        var package = try makeValidPackage(revision: 7, title: "")
        package.payloadChecksumSHA256 = try ApneaSyncCodec.checksum(for: package.body)
        XCTAssertThrowsError(try ApneaSyncCodec.validate(package)) { error in
            XCTAssertEqual(error as? ApneaSyncValidationError, .invalidPlan)
        }
    }

    func testInvalidPyramidMonotonicityRejected() throws {
        let plan = ApneaSessionPlan(
            kind: .pyramid,
            title: "Bad pyramid",
            entries: [
                ApneaPlannedDiveEntry(orderIndex: 0, targetDepthMeters: 15, targetDurationSeconds: 60, plannedRecoverySeconds: 60),
                ApneaPlannedDiveEntry(orderIndex: 1, targetDepthMeters: 10, targetDurationSeconds: 60, plannedRecoverySeconds: 60),
                ApneaPlannedDiveEntry(orderIndex: 2, targetDepthMeters: 20, targetDurationSeconds: 60, plannedRecoverySeconds: 60),
            ]
        )
        let package = try ApneaSyncPackageBuilder.build(
            plan: plan,
            profile: nil,
            settings: .default,
            packageID: UUID(),
            revision: 8
        )
        XCTAssertThrowsError(try ApneaSyncCodec.validate(package)) { error in
            XCTAssertEqual(error as? ApneaSyncValidationError, .invalidPlan)
        }
    }

    func testCanonicalBodyTamperedAfterSealingRejected() throws {
        var package = try makeValidPackage(revision: 9)
        package.body.revision = 99
        XCTAssertThrowsError(try ApneaSyncCodec.validate(package)) { error in
            XCTAssertEqual(error as? ApneaSyncValidationError, .checksumMismatch)
        }
    }

    func testTruncatedPlanPackageIsRejectedWithoutReplacingPendingOrActivePlan() throws {
        let valid = try makeValidPackage(revision: 11)
        let data = try ApneaSyncCodec.encode(valid)
        let truncated = Data(data.prefix(max(1, data.count / 2)))
        XCTAssertThrowsError(try ApneaSyncCodec.decode(truncated))
        XCTAssertNoThrow(try ApneaSyncCodec.validate(valid))
    }

    private func makeValidPackage(revision: Int, title: String = "Valid", expiresAt: Date? = nil) throws -> ApneaSyncPackage {
        try ApneaSyncPackageBuilder.build(
            plan: ApneaSessionPlan(
                kind: .custom,
                title: title,
                entries: [
                    ApneaPlannedDiveEntry(orderIndex: 0, targetDepthMeters: 15, targetDurationSeconds: 60, plannedRecoverySeconds: 60)
                ]
            ),
            profile: nil,
            settings: .default,
            packageID: UUID(),
            revision: revision,
            expiresAt: expiresAt ?? Date().addingTimeInterval(ApneaSyncCodec.defaultTTL)
        )
    }
}
