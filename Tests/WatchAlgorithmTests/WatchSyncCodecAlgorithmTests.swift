import XCTest

final class WatchSyncCodecAlgorithmTests: XCTestCase {
    func testManualNoDepthSessionPassesValidator() throws {
        let start = Date(timeIntervalSince1970: 0)
        let session = DiveSession(
            startDate: start,
            endDate: start.addingTimeInterval(600),
            durationSeconds: 600,
            maxDepthMeters: 0,
            avgDepthMeters: 0,
            avgWaterTemperatureCelsius: nil,
            minWaterTemperatureCelsius: nil,
            maxWaterTemperatureCelsius: nil,
            ttv: 10,
            entryGPS: nil,
            exitGPS: nil,
            samples: [],
            isManual: true,
            hasDepthProfile: false
        )
        XCTAssertNoThrow(try DiveSessionAlgorithmValidator.validate(session))
        XCTAssertTrue(DiveSessionPersistenceClass.classify(session).allowsSync)
        XCTAssertFalse(DiveSessionPersistenceClass.classify(session).allowsExport)
    }

    func testExcessiveDepthRejectedByValidator() {
        let start = Date(timeIntervalSince1970: 0)
        let session = DiveSession(
            startDate: start,
            endDate: start.addingTimeInterval(60),
            durationSeconds: 60,
            maxDepthMeters: 400,
            avgDepthMeters: 10,
            avgWaterTemperatureCelsius: nil,
            minWaterTemperatureCelsius: nil,
            maxWaterTemperatureCelsius: nil,
            ttv: 11,
            entryGPS: nil,
            exitGPS: nil,
            samples: [DiveSample(timestamp: start, depthMeters: 400, temperatureCelsius: nil)]
        )
        XCTAssertThrowsError(try DiveSessionAlgorithmValidator.validate(session))
    }

    func testExportTimeSecondsRelativeToSessionStart() {
        let start = Date(timeIntervalSince1970: 1_000)
        let session = DiveSession(
            startDate: start,
            endDate: start.addingTimeInterval(120),
            durationSeconds: 120,
            maxDepthMeters: 20,
            avgDepthMeters: 15,
            avgWaterTemperatureCelsius: nil,
            minWaterTemperatureCelsius: nil,
            maxWaterTemperatureCelsius: nil,
            ttv: 17,
            entryGPS: nil,
            exitGPS: nil,
            samples: [
                DiveSample(timestamp: start.addingTimeInterval(5), depthMeters: 10, temperatureCelsius: nil),
                DiveSample(timestamp: start.addingTimeInterval(60), depthMeters: 20, temperatureCelsius: nil)
            ]
        )
        let csv = SubsurfaceExportService.makeCSV(for: session)!
        XCTAssertTrue(csv.contains("\n0,10.00"))
        XCTAssertTrue(csv.contains("\n55,20.00"))
    }
}
