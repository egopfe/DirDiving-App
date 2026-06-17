import XCTest

final class DivePlanPackageCodecTests: XCTestCase {
    func testRoundTripSealAndValidate() throws {
        let body = sampleBody(revision: 1)
        let package = try DivePlanPackageCodec.seal(body)
        try DivePlanPackageCodec.validate(package)
        let data = try DivePlanPackageCodec.encode(package)
        let decoded = try DivePlanPackageCodec.decode(data)
        XCTAssertEqual(decoded.payloadChecksumSHA256, package.payloadChecksumSHA256)
        XCTAssertEqual(decoded.body.planID, package.body.planID)
        XCTAssertEqual(decoded.body.revision, package.body.revision)
    }

    func testChecksumRejectsTamperedPayload() throws {
        let package = try DivePlanPackageCodec.seal(sampleBody(revision: 2))
        var tampered = package
        tampered.body.gfHigh = 99
        XCTAssertThrowsError(try DivePlanPackageCodec.validate(tampered)) { error in
            XCTAssertEqual(error as? DivePlanPackageValidationError, .checksumMismatch)
        }
    }

    func testExpiredPlanRejected() throws {
        var body = sampleBody(revision: 3)
        body.expiresAt = Date().addingTimeInterval(-60)
        let package = try DivePlanPackageCodec.seal(body)
        XCTAssertThrowsError(try DivePlanPackageCodec.validate(package)) { error in
            XCTAssertEqual(error as? DivePlanPackageValidationError, .expired)
        }
    }

    func testFutureSchemaRejected() throws {
        var body = sampleBody(revision: 4)
        body.schemaVersion = DivePlanPackageCodec.currentSchemaVersion + 1
        let package = try DivePlanPackageCodec.seal(body)
        XCTAssertThrowsError(try DivePlanPackageCodec.validate(package)) { error in
            XCTAssertEqual(error as? DivePlanPackageValidationError, .futureSchema)
        }
    }

    func testImportProfileMapping() throws {
        let package = try DivePlanPackageCodec.seal(sampleBody(revision: 5))
        let profile = try FullComputerGasProfile(importing: package)
        XCTAssertEqual(profile.gfLow, 30)
        XCTAssertEqual(profile.gfHigh, 70)
        XCTAssertEqual(profile.bottomGas.oxygenFraction, 0.18, accuracy: 0.001)
        XCTAssertEqual(profile.decoGases.count, 1)
        XCTAssertTrue(profile.travelGases.isEmpty)
        XCTAssertTrue(profile.bailoutGases.isEmpty)
    }

    func testCanonicalChecksumDeterministic() throws {
        let body = sampleBody(revision: 6)
        let first = try DivePlanPackageCodec.checksum(for: body)
        let second = try DivePlanPackageCodec.checksum(for: body)
        XCTAssertEqual(first, second)
    }

    func testChecksumChangesWhenCanonicalFieldChanges() throws {
        let body = sampleBody(revision: 7)
        let original = try DivePlanPackageCodec.checksum(for: body)
        var changed = body
        changed.gfHigh = 75
        let updated = try DivePlanPackageCodec.checksum(for: changed)
        XCTAssertNotEqual(original, updated)
    }

    func testExactExpiryBoundaryRejected() throws {
        var body = sampleBody(revision: 8)
        body.expiresAt = Date()
        let package = try DivePlanPackageCodec.seal(body)
        XCTAssertThrowsError(try DivePlanPackageCodec.validate(package, now: Date().addingTimeInterval(1))) { error in
            XCTAssertEqual(error as? DivePlanPackageValidationError, .expired)
        }
    }

    private func sampleBody(revision: Int, planID: UUID = UUID()) -> DivePlanPackageBody {
        let bottomID = UUID()
        let decoID = UUID()
        return DivePlanPackageBody(
            schemaVersion: DivePlanPackageCodec.currentSchemaVersion,
            algorithmVersion: DivePlanPackageCodec.algorithmVersion,
            planID: planID,
            revision: revision,
            createdAt: Date(),
            expiresAt: Date().addingTimeInterval(3600),
            environment: DivePlanEnvironmentPayload(altitudeMeters: 0, salinityRaw: SalinityMode.salt.rawValue),
            gfLow: 30,
            gfHigh: 70,
            gases: [
                DivePlanGasPayload(
                    id: bottomID,
                    name: "Trimix 18/45",
                    role: .bottom,
                    oxygenFraction: 0.18,
                    heliumFraction: 0.45,
                    maxPPO2Bar: 1.4,
                    switchDepthMeters: nil,
                    sortOrder: 0
                ),
                DivePlanGasPayload(
                    id: decoID,
                    name: "EAN50",
                    role: .deco,
                    oxygenFraction: 0.50,
                    heliumFraction: 0,
                    maxPPO2Bar: 1.6,
                    switchDepthMeters: 21,
                    sortOrder: 1
                ),
            ],
            bottomSegments: [
                DivePlanBottomSegmentPayload(depthMeters: 45, durationMinutes: 20, order: 0)
            ],
            plannedSwitches: [
                DivePlanGasSwitchPayload(gasID: decoID, switchDepthMeters: 21, order: 0)
            ],
            plannerSummary: DivePlanSummaryPayload(
                modeLabel: "Deco",
                planKind: "single",
                maxDepthMeters: 45,
                bottomMinutes: 20,
                totalRuntimeMinutes: 55,
                requiresDeco: true,
                decoStopCount: 2
            ),
            capabilities: .current
        )
    }
}
