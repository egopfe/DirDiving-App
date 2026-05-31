import XCTest

final class WatchManualNoDepthSyncTests: XCTestCase {
    func testManualNoDepthSessionPassesIOSValidationForSync() throws {
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        let session = DiveSession(
            startDate: start,
            endDate: start.addingTimeInterval(900),
            durationSeconds: 900,
            maxDepthMeters: 0,
            avgDepthMeters: 0,
            avgWaterTemperatureCelsius: nil,
            ttv: 15,
            entryGPS: nil,
            exitGPS: nil,
            samples: [],
            isManual: true,
            hasDepthProfile: false
        )

        let normalized = try DiveSessionAlgorithmValidator.normalizedForStorage(
            session,
            allowEmptySamples: session.isManual && !session.hasDepthProfile
        )
        XCTAssertTrue(normalized.isManual)
        XCTAssertFalse(normalized.hasDepthProfile)
        XCTAssertTrue(normalized.samples.isEmpty)
    }

    func testEmptyNonManualSessionRejectedForSync() {
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        let session = DiveSession(
            startDate: start,
            endDate: start.addingTimeInterval(900),
            durationSeconds: 900,
            maxDepthMeters: 0,
            avgDepthMeters: 0,
            avgWaterTemperatureCelsius: nil,
            ttv: 15,
            entryGPS: nil,
            exitGPS: nil,
            samples: [],
            isManual: false,
            hasDepthProfile: false
        )

        XCTAssertThrowsError(
            try DiveSessionAlgorithmValidator.normalizedForStorage(session, allowEmptySamples: false)
        )
    }
}
