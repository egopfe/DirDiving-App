import XCTest

final class BuhlmannExternalValidationMetadataTests: XCTestCase {
    func testAllFixturesDeclareValidationMetadata() throws {
        let fixtures = try FixtureLoader.loadAll()
        XCTAssertFalse(fixtures.isEmpty)
        for fixture in fixtures {
            XCTAssertFalse(fixture.validationStatus.isEmpty, fixture.id)
            XCTAssertFalse(fixture.referenceSource.isEmpty, fixture.id)
            XCTAssertFalse(fixture.validationNotes.isEmpty, fixture.id)
            if fixture.isValid {
                XCTAssertGreaterThan(fixture.toleranceMinutes, 0, fixture.id)
            } else {
                XCTAssertGreaterThanOrEqual(fixture.toleranceMinutes, 0, fixture.id)
            }
            XCTAssertFalse(fixture.claimsExternalReference, "Fixture \(fixture.id) must not claim external validation without campaign")
            XCTAssertFalse(
                fixture.validationNotes.localizedCaseInsensitiveContains("certified equivalence"),
                fixture.id
            )
        }
    }

    func testInternalRegressionFixturesDefaultStatus() throws {
        let fixtures = try FixtureLoader.loadAll()
        for fixture in fixtures where !fixture.isPendingExternalValidation {
            XCTAssertEqual(fixture.validationStatus, "internal_regression", fixture.id)
            XCTAssertEqual(fixture.referenceSource, "internal-ios-buhlmann-suite", fixture.id)
        }
    }

    func testValidFixturesDeclareExpectedRangesWhenPresent() throws {
        let fixtures = try FixtureLoader.loadAll().filter(\.isValid)
        for fixture in fixtures where fixture.expectedTTSRangeMinutes != nil {
            let range = try XCTUnwrap(fixture.expectedTTSRangeMinutes)
            XCTAssertLessThanOrEqual(range.min, range.max, fixture.id)
        }
    }

    func testPendingExternalValidationFixtureTemplateParses() throws {
        let json = """
        {
          "id": "pending-external-template",
          "isValid": true,
          "depthMeters": 30,
          "bottomMinutes": 20,
          "gfLow": 30,
          "gfHigh": 70,
          "gases": [{"name":"Air","role":"bottom","oxygen":0.21,"helium":0.0,"maxPPO2":1.4,"switchDepthMeters":30}],
          "expectedTTSRangeMinutes": {"min": 0, "max": 999},
          "toleranceMinutes": 15,
          "validationStatus": "pending_external_validation",
          "referenceSource": "pending-third-party-reference",
          "validationNotes": "Placeholder metadata only. No certified reference values loaded."
        }
        """.data(using: .utf8)!
        let fixture = try JSONDecoder().decode(PlannerFixture.self, from: json)
        XCTAssertTrue(fixture.isPendingExternalValidation)
        XCTAssertFalse(fixture.claimsExternalReference)
    }
}
