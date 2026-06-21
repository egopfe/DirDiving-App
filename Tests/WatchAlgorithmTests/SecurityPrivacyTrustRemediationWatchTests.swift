import XCTest

final class SecurityPrivacyTrustRemediationWatchTests: XCTestCase {
    func testWatchSubsurfaceExportOmitsGPSByDefault() {
        let sample = DiveSample(timestamp: Date(), depthMeters: 10, temperatureCelsius: 20)
        let session = DiveSession(
            startDate: Date(),
            endDate: Date().addingTimeInterval(60),
            durationSeconds: 60,
            maxDepthMeters: 10,
            avgDepthMeters: 8,
            avgWaterTemperatureCelsius: 20,
            minWaterTemperatureCelsius: 20,
            maxWaterTemperatureCelsius: 20,
            ttv: 1,
            entryGPS: GPSPoint(latitude: 45.1, longitude: 9.1, horizontalAccuracy: 5, timestamp: Date()),
            exitGPS: GPSPoint(latitude: 45.2, longitude: 9.2, horizontalAccuracy: 5, timestamp: Date()),
            samples: [sample]
        )
        let csv = SubsurfaceExportService.makeCSV(for: session, privacyOptions: .default)
        XCTAssertNotNil(csv)
        XCTAssertFalse(csv?.contains("45.100000") ?? true)
        XCTAssertTrue(csv?.contains("dirdiving_export_location_precision: omitted") ?? false)
    }

    func testWatchSubsurfaceExportTagsSimulation() {
        let sample = DiveSample(timestamp: Date(), depthMeters: 5, temperatureCelsius: nil)
        let session = DiveSession(
            startDate: Date(),
            endDate: Date().addingTimeInterval(30),
            durationSeconds: 30,
            maxDepthMeters: 5,
            avgDepthMeters: 4,
            avgWaterTemperatureCelsius: nil,
            minWaterTemperatureCelsius: nil,
            maxWaterTemperatureCelsius: nil,
            ttv: 1,
            entryGPS: nil,
            exitGPS: nil,
            samples: [sample],
            depthSensorSourceTag: DivingRecordEligibilityPolicy.simulatedSourceTag
        )
        let csv = SubsurfaceExportService.makeCSV(for: session)
        XCTAssertTrue(csv?.contains("dirdiving_depth_sensor_source: simulation") ?? false)
    }
}
