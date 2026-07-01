import XCTest
@testable import DIRDivingiOSApp

final class DivingCSVExportRegressionTests: XCTestCase {
    func testMakeCSVStillWorks() throws {
        let session = makeExportSession()
        let csv = try XCTUnwrap(SubsurfaceExportService.makeCSV(for: session))
        XCTAssertTrue(csv.contains("time_seconds,depth_m"))
        XCTAssertTrue(csv.contains("# dirdiving_session_id:"))
    }

    func testWriteCSVStillWorks() throws {
        let session = makeExportSession()
        switch SubsurfaceExportService.writeCSV(for: session) {
        case .success(let url):
            XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
            let contents = try String(contentsOf: url, encoding: .utf8)
            XCTAssertTrue(contents.contains("time_seconds,depth_m"))
        case .failure(let error):
            XCTFail("Expected success: \(error)")
        }
    }

    private func makeExportSession() -> DiveSession {
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        let end = start.addingTimeInterval(600)
        return DiveSession(
            id: UUID(),
            startDate: start,
            endDate: end,
            durationSeconds: 600,
            maxDepthMeters: 24,
            avgDepthMeters: 12,
            avgWaterTemperatureCelsius: 22,
            ttv: 10,
            entryGPS: nil,
            exitGPS: nil,
            samples: [
                DiveSample(timestamp: start, depthMeters: 0, temperatureCelsius: 22),
                DiveSample(timestamp: end, depthMeters: 24, temperatureCelsius: 21)
            ],
            siteName: "Test Site"
        )
    }
}
