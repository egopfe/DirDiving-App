import XCTest

final class ManualDiveEditorLogicTests: XCTestCase {
    func testDepthOrderValidationRejectsAverageGreaterThanMax() {
        XCTAssertNotNil(ManualDiveEditorValidation.depthOrderError(maxMeters: 20, avgMeters: 25))
    }

    func testDepthOrderValidationAcceptsValidDepths() {
        XCTAssertNil(ManualDiveEditorValidation.depthOrderError(maxMeters: 30, avgMeters: 18))
    }

    func testDepthOrderValidationRejectsNonFiniteDepths() {
        XCTAssertNotNil(ManualDiveEditorValidation.depthOrderError(maxMeters: .nan, avgMeters: 18))
        XCTAssertNotNil(ManualDiveEditorValidation.depthOrderError(maxMeters: 30, avgMeters: 0))
    }

    func testDurationClamping() {
        XCTAssertEqual(ManualDiveEditorValidation.clampedDurationMinutes(2), 5)
        XCTAssertEqual(ManualDiveEditorValidation.clampedDurationMinutes(45), 45)
        XCTAssertEqual(ManualDiveEditorValidation.clampedDurationMinutes(500), 300)
    }

    func testSyntheticSessionIncludesProfilePressuresAndDecoNotes() throws {
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        let result = ManualDiveEditorValidation.makeSyntheticSession(
            existing: nil,
            startDate: start,
            durationMinutes: 45,
            maxMeters: 30,
            avgMeters: 18,
            siteName: "Test Site",
            entryLatitude: "44.4056",
            entryLongitude: "8.9463",
            exitLatitude: "44.4057",
            exitLongitude: "8.9464",
            equipmentUsed: "Twinset",
            entryPressureText: "200",
            exitPressureText: "50",
            decompressionNotes: "No stops",
            notes: "Calm day",
            gasLabel: .nitrox,
            unitPreference: .metric
        )
        let session = try XCTUnwrap(result.get())
        XCTAssertEqual(session.siteName, "Test Site")
        XCTAssertEqual(session.maxDepthMeters, 30, accuracy: 0.01)
        XCTAssertFalse(session.samples.isEmpty)
        XCTAssertEqual(session.entryPressureText, "200")
        XCTAssertEqual(session.exitPressureText, "50")
        XCTAssertEqual(session.decompressionNotes, "No stops")
        XCTAssertEqual(session.equipmentUsed, "Twinset")
        XCTAssertNotNil(session.entryGPS)
        XCTAssertNotNil(session.exitGPS)
        XCTAssertTrue(session.isManual)
    }

    func testInvalidDepthOrderDoesNotProduceSession() {
        let result = ManualDiveEditorValidation.makeSyntheticSession(
            existing: nil,
            startDate: Date(),
            durationMinutes: 45,
            maxMeters: 18,
            avgMeters: 30,
            siteName: "",
            entryLatitude: "",
            entryLongitude: "",
            exitLatitude: "",
            exitLongitude: "",
            equipmentUsed: "",
            entryPressureText: "",
            exitPressureText: "",
            decompressionNotes: "",
            notes: "",
            gasLabel: .oc,
            unitPreference: .metric
        )
        switch result {
        case .success:
            XCTFail("Expected validation failure")
        case .failure(let error):
            XCTAssertFalse(error.errorDescription?.isEmpty ?? true)
        }
    }

    func testManualDiveSampleBuilderProducesMonotonicProfile() {
        let start = Date()
        let end = start.addingTimeInterval(45 * 60)
        let samples = ManualDiveSampleBuilder.makeSamples(
            startDate: start,
            endDate: end,
            maxDepthMeters: 30,
            avgDepthMeters: 18
        )
        XCTAssertEqual(samples.count, 4)
        XCTAssertEqual(samples.first?.depthMeters ?? -1, 0, accuracy: 0.01)
        XCTAssertEqual(samples.map(\.depthMeters).max() ?? -1, 30, accuracy: 0.01)
    }

    func testImperialDepthConversionRoundTrip() {
        let meters = ManualDiveEditorDefaults.depthMeters(fromInput: 98.4, units: .imperial)
        XCTAssertEqual(meters, 30, accuracy: 0.5)
    }
}
