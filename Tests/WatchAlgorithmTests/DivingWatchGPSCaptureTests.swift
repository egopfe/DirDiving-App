import XCTest

final class DivingWatchGPSCaptureTests: XCTestCase {
    func testValidEntryAndExitGPSPreservedInSession() {
        let start = Date(timeIntervalSince1970: 1_000)
        let entry = GPSPoint(latitude: 44.4, longitude: 8.9, horizontalAccuracy: 6, timestamp: start)
        let exit = GPSPoint(latitude: 44.41, longitude: 8.91, horizontalAccuracy: 8, timestamp: start.addingTimeInterval(600))
        let session = DiveSession(
            startDate: start,
            endDate: start.addingTimeInterval(600),
            durationSeconds: 600,
            maxDepthMeters: 18,
            avgDepthMeters: 10,
            avgWaterTemperatureCelsius: nil,
            minWaterTemperatureCelsius: nil,
            maxWaterTemperatureCelsius: nil,
            ttv: 12,
            entryGPS: entry,
            exitGPS: exit,
            entryGPSFixSource: .fix,
            exitGPSFixSource: .fix,
            samples: [DiveSample(timestamp: start, depthMeters: 18, temperatureCelsius: 20)]
        )
        XCTAssertEqual(session.entryGPS?.latitude ?? 0, 44.4, accuracy: 0.0001)
        XCTAssertEqual(session.exitGPS?.longitude ?? 0, 8.91, accuracy: 0.0001)
        XCTAssertTrue(ActivityGPSLogbookPolicy.divingSessionRemainsValidWithoutGPS(
            makeSessionWithoutGPS(start: start)
        ))
    }

    private func makeSessionWithoutGPS(start: Date) -> DiveSession {
        let end = start.addingTimeInterval(60)
        let samples = [
            DiveSample(timestamp: start, depthMeters: 0, temperatureCelsius: nil),
            DiveSample(timestamp: end, depthMeters: 10, temperatureCelsius: nil),
        ]
        return DiveSessionMerge.preferred(
            DiveSession(
                startDate: start,
                endDate: end,
                durationSeconds: 60,
                maxDepthMeters: 10,
                avgDepthMeters: 5,
                avgWaterTemperatureCelsius: nil,
                minWaterTemperatureCelsius: nil,
                maxWaterTemperatureCelsius: nil,
                ttv: 3,
                entryGPS: nil,
                exitGPS: nil,
                samples: samples
            ),
            DiveSession(
                startDate: start,
                endDate: end,
                durationSeconds: 60,
                maxDepthMeters: 10,
                avgDepthMeters: 5,
                avgWaterTemperatureCelsius: nil,
                minWaterTemperatureCelsius: nil,
                maxWaterTemperatureCelsius: nil,
                ttv: 3,
                entryGPS: nil,
                exitGPS: nil,
                samples: samples
            )
        )
    }

    func testMergePreservesValidEntryGPS() {
        let id = UUID()
        let start = Date()
        let gps = GPSPoint(latitude: 40, longitude: 9, horizontalAccuracy: 5, timestamp: start)
        let winner = DiveSession(
            id: id,
            startDate: start,
            endDate: start.addingTimeInterval(60),
            durationSeconds: 60,
            maxDepthMeters: 12,
            avgDepthMeters: 8,
            avgWaterTemperatureCelsius: nil,
            minWaterTemperatureCelsius: nil,
            maxWaterTemperatureCelsius: nil,
            ttv: 4,
            entryGPS: gps,
            exitGPS: nil,
            entryGPSFixSource: .fix,
            exitGPSFixSource: .noFix,
            samples: []
        )
        let merged = DiveSessionMerge.preferred(winner, winner)
        XCTAssertEqual(merged.entryGPS?.latitude ?? 0, 40, accuracy: 0.0001)
    }
}
