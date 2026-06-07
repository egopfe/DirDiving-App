import Foundation
import XCTest

final class WatchReadinessAlgorithmTests: XCTestCase {
    func testDepthCallbackSilenceThresholdUsesStaleConfiguration() {
        XCTAssertEqual(
            DiveAlgorithmConfiguration.activeDepthCallbackSilenceSeconds,
            DiveAlgorithmConfiguration.staleDepthSampleSeconds
        )
    }

    func testGPSConfirmationPresentationStateMachine() {
        let fixPoint = GPSPoint(latitude: 44.1, longitude: 9.2, horizontalAccuracy: 8, timestamp: Date())
        XCTAssertEqual(GPSConfirmationPresentation.from(point: fixPoint, fallback: false), .fix)
        XCTAssertEqual(GPSConfirmationPresentation.from(point: fixPoint, fallback: true), .fallback)
        XCTAssertEqual(GPSConfirmationPresentation.from(point: nil, fallback: false), .noFix)
        XCTAssertEqual(GPSConfirmationPresentation.from(point: nil, fallback: true), .noFix)
    }

    func testManualNoDepthSessionClassifiesAndSyncs() throws {
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

        XCTAssertEqual(DiveSessionPersistenceClass.classify(session), .manualNoDepth)
        XCTAssertTrue(DiveSessionPersistenceClass.classify(session).allowsSync)
        XCTAssertFalse(DiveSessionPersistenceClass.classify(session).allowsExport)
        XCTAssertNoThrow(try DiveSessionAlgorithmValidator.validate(session))
    }

    func testAutoStartSampleRetainedWhenSessionStartMatchesTriggerTimestamp() {
        let trigger = Date(timeIntervalSince1970: 100)
        let sessionStart = trigger
        let sample = DiveSample(timestamp: trigger, depthMeters: 1.2, temperatureCelsius: nil)
        let merged = DiveSessionMerge.preferred(
            DiveSession(
                startDate: sessionStart,
                endDate: trigger.addingTimeInterval(120),
                durationSeconds: 120,
                maxDepthMeters: 1.2,
                avgDepthMeters: 1.2,
                avgWaterTemperatureCelsius: nil,
                minWaterTemperatureCelsius: nil,
                maxWaterTemperatureCelsius: nil,
                ttv: 3.2,
                entryGPS: nil,
                exitGPS: nil,
                samples: [sample]
            ),
            DiveSession(
                startDate: sessionStart,
                endDate: trigger.addingTimeInterval(120),
                durationSeconds: 120,
                maxDepthMeters: 1.2,
                avgDepthMeters: 1.2,
                avgWaterTemperatureCelsius: nil,
                minWaterTemperatureCelsius: nil,
                maxWaterTemperatureCelsius: nil,
                ttv: 3.2,
                entryGPS: nil,
                exitGPS: nil,
                samples: [sample]
            )
        )

        XCTAssertEqual(merged.samples.count, 1)
        XCTAssertEqual(merged.samples.first?.timestamp, trigger)
        XCTAssertEqual(merged.maxDepthMeters, 1.2, accuracy: 0.001)
    }

    func testExportCSVUsesFirstSampleAsTimeOrigin() {
        let start = Date(timeIntervalSince1970: 0)
        let session = DiveSession(
            startDate: start,
            endDate: start.addingTimeInterval(120),
            durationSeconds: 120,
            maxDepthMeters: 10,
            avgDepthMeters: 10,
            avgWaterTemperatureCelsius: nil,
            minWaterTemperatureCelsius: nil,
            maxWaterTemperatureCelsius: nil,
            ttv: 12,
            entryGPS: nil,
            exitGPS: nil,
            samples: [DiveSample(timestamp: start.addingTimeInterval(5), depthMeters: 10, temperatureCelsius: nil)]
        )

        let csv = SubsurfaceExportService.makeCSV(for: session)!
        XCTAssertTrue(csv.contains("\n0,10.00"))
        XCTAssertFalse(csv.contains("\n5,10.00"))
    }

    func testMonotonicElapsedClockDoesNotDecreaseOnBackwardWallClock() {
        let anchor = Date(timeIntervalSince1970: 1_000)
        var clock = MonotonicElapsedClock()
        clock.reset(anchorDate: anchor, uptime: 100)

        let first = clock.elapsed(now: anchor.addingTimeInterval(30), uptime: 130)
        let second = clock.elapsed(now: anchor.addingTimeInterval(10), uptime: 140)

        XCTAssertEqual(first, 30, accuracy: 0.001)
        XCTAssertEqual(second, 40, accuracy: 0.001)
    }

    func testMonotonicElapsedClockRejectsLargeForwardWallClockSkew() {
        let anchor = Date(timeIntervalSince1970: 1_000)
        var clock = MonotonicElapsedClock()
        clock.reset(anchorDate: anchor, uptime: 100)

        let elapsed = clock.elapsed(now: anchor.addingTimeInterval(600), uptime: 130)
        XCTAssertEqual(elapsed, 30, accuracy: 0.001)
    }

    func testAscentGaugeZoneMatchesAscentStatusAtBoundaries() {
        let limit = AscentStatus.make(rate: 0, depth: 3).limitMetersPerMinute
        XCTAssertEqual(AscentStatus.greenThresholdRatio, 0.70)
        XCTAssertEqual(AscentStatus.redThresholdRatio, 1.0)
        XCTAssertEqual(AscentStatus.make(rate: limit * 0.50, depth: 3).zone, .green)
        XCTAssertEqual(AscentStatus.make(rate: limit * 0.70, depth: 3).zone, .green)
        XCTAssertEqual(AscentStatus.make(rate: limit * 0.80, depth: 3).zone, .yellow)
        XCTAssertEqual(AscentStatus.make(rate: limit, depth: 3).zone, .yellow)
        XCTAssertEqual(AscentStatus.make(rate: limit * 1.01, depth: 3).zone, .red)
        XCTAssertEqual(AscentStatus.zone(forRate: limit * 0.70, limit: limit), .green)
        XCTAssertEqual(AscentStatus.zone(forRate: limit * 0.71, limit: limit), .yellow)
    }

    func testImperialAscentBannerUsesFeetPerMinute() {
        let display = DIRUnitPreference.imperial.ascentRateDisplay(metersPerMinute: 3)
        XCTAssertEqual(display.unit, "ft/min")
        XCTAssertEqual(display.value, 9.8, accuracy: 0.1)
    }

    func testDepthSafetyBoundaryAt40MetersIsExceeded() {
        XCTAssertEqual(DepthSafetyState.from(depthMeters: 40.0), .exceeded)
        XCTAssertEqual(AscentRateLimits.standard.limit(for: 40.0), 10)
        XCTAssertEqual(AscentRateLimits.standard.limit(for: 40.01), 1)
    }

    func testInvalidSessionRejectedByPersistenceClass() {
        let start = Date(timeIntervalSince1970: 0)
        let invalid = DiveSession(
            startDate: start,
            endDate: start.addingTimeInterval(-10),
            durationSeconds: -10,
            maxDepthMeters: 0,
            avgDepthMeters: 0,
            avgWaterTemperatureCelsius: nil,
            minWaterTemperatureCelsius: nil,
            maxWaterTemperatureCelsius: nil,
            ttv: 0,
            entryGPS: nil,
            exitGPS: nil,
            samples: []
        )

        if case .invalid = DiveSessionPersistenceClass.classify(invalid) {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected invalid classification")
        }
    }
}
