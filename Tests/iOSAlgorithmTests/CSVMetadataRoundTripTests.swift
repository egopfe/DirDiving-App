import XCTest

final class CSVMetadataRoundTripTests: XCTestCase {
    func testExportImportRoundTripPreservesMetadata() throws {
        let sessionID = UUID()
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        let end = start.addingTimeInterval(3_600)
        let session = DiveSession(
            id: sessionID,
            startDate: start,
            endDate: end,
            durationSeconds: 3_600,
            maxDepthMeters: 32,
            avgDepthMeters: 18,
            avgWaterTemperatureCelsius: 22,
            ttv: 48,
            entryGPS: nil,
            exitGPS: nil,
            samples: [
                DiveSample(timestamp: start, depthMeters: 0, temperatureCelsius: 22),
                DiveSample(timestamp: end, depthMeters: 32, temperatureCelsius: 21)
            ],
            siteName: "Grotta Azzurra",
            buddy: "Marco",
            gasLabel: .trimix,
            sacLitersMinute: 18.5,
            isManual: true,
            equipmentUsed: "Twin 12L",
            entryPressureText: "230 bar",
            exitPressureText: "90 bar",
            decompressionNotes: "Deco planned"
        )

        let csv = try XCTUnwrap(SubsurfaceExportService.makeCSV(for: session))
        XCTAssertTrue(csv.contains("# dirdiving_session_id: \(sessionID.uuidString)"))
        XCTAssertTrue(csv.contains("# dirdiving_start_date:"))
        XCTAssertTrue(csv.contains("# dirdiving_site_name: Grotta Azzurra"))

        let url = try temporaryCSV(csv)
        let result = DiveImportService.importCSV(from: url)
        guard case .success(let summary) = result else {
            return XCTFail("Expected successful import")
        }

        XCTAssertEqual(summary.session.id, sessionID)
        XCTAssertEqual(summary.session.startDate.timeIntervalSince1970, start.timeIntervalSince1970, accuracy: 1)
        XCTAssertEqual(summary.session.siteName, "Grotta Azzurra")
        XCTAssertEqual(summary.session.buddy, "Marco")
        XCTAssertEqual(summary.session.gasLabel, .trimix)
        XCTAssertEqual(summary.session.sacLitersMinute ?? 0, 18.5, accuracy: 0.01)
        XCTAssertTrue(summary.session.isManual)
        XCTAssertEqual(summary.session.equipmentUsed, "Twin 12L")
        XCTAssertEqual(summary.session.entryPressureText, "230 bar")
        XCTAssertEqual(summary.session.exitPressureText, "90 bar")
        XCTAssertEqual(summary.session.decompressionNotes, "Deco planned")
        XCTAssertTrue(summary.sourceDatePreserved)
    }

    func testLegacySessionMetaRowStillImportsManualFields() throws {
        let start = Date(timeIntervalSince1970: 1_600_000_000)
        let csv = """
        time_seconds,depth_m,temperature_c,entry_lat,entry_lon,exit_lat,exit_lon,is_manual,equipment,entry_pressure,exit_pressure,deco_notes
        # session_meta,1,Legacy Rig,200 bar,80 bar,Legacy deco
        0,0,20,,,,,
        60,12,20,,,,,
        """
        let url = try temporaryCSV(csv)
        let result = DiveImportService.importCSV(from: url)
        guard case .success(let summary) = result else {
            return XCTFail("Expected successful legacy import")
        }
        XCTAssertTrue(summary.session.isManual)
        XCTAssertEqual(summary.session.equipmentUsed, "Legacy Rig")
        XCTAssertEqual(summary.session.entryPressureText, "200 bar")
        XCTAssertEqual(summary.session.exitPressureText, "80 bar")
        XCTAssertEqual(summary.session.decompressionNotes, "Legacy deco")
    }

    func testCommentRowsAreSkippedDuringSampleParsing() throws {
        let start = Date(timeIntervalSince1970: 1_500_000_000)
        let formatter = ISO8601DateFormatter()
        let csv = """
        time_seconds,depth_m,temperature_c,entry_lat,entry_lon,exit_lat,exit_lon
        # session_meta
        # dirdiving_start_date: \(formatter.string(from: start))
        0,0,20,,,,,
        120,15,19,,,,,
        """
        let url = try temporaryCSV(csv)
        let result = DiveImportService.importCSV(from: url)
        guard case .success(let summary) = result else {
            return XCTFail("Expected successful import")
        }
        XCTAssertEqual(summary.session.samples.count, 2)
        XCTAssertEqual(summary.session.startDate.timeIntervalSince1970, start.timeIntervalSince1970, accuracy: 1)
    }

    private func temporaryCSV(_ contents: String) throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("CSVMetadataRoundTripTests-\(UUID().uuidString).csv")
        try contents.write(to: url, atomically: true, encoding: .utf8)
        return url
    }
}
