import XCTest

/// Gauge mathematical completion: avg depth, TTV isolation, ascent, lifecycle edges.
final class WatchGaugeMathCompletionTests: XCTestCase {
    func testZeroDurationAverageDepthUsesSingleSample() {
        let sample = DiveSample(timestamp: Date(), depthMeters: 12, temperatureCelsius: nil)
        let avg = DiveAlgorithm.timeWeightedAverageDepth(samples: [sample], endDate: sample.timestamp)
        XCTAssertEqual(avg, 12, accuracy: 0.001)
    }

    func testVeryLongSessionAverageDepthStable() {
        let start = Date(timeIntervalSince1970: 0)
        var samples: [DiveSample] = []
        for index in 0..<3_600 {
            samples.append(DiveSample(
                timestamp: start.addingTimeInterval(TimeInterval(index)),
                depthMeters: 15,
                temperatureCelsius: nil
            ))
        }
        let avg = DiveAlgorithm.timeWeightedAverageDepth(samples: samples, endDate: start.addingTimeInterval(3_599))
        XCTAssertEqual(avg, 15, accuracy: 0.001)
    }

    func testTTVRemainsIsolatedFromFullComputerPlan() {
        let ttv = DiveAlgorithm.ttvIndex(averageDepthMeters: 20, durationSeconds: 1_200)
        XCTAssertEqual(ttv, 40, accuracy: 0.001)
        let readiness = FullComputerRuntimeEngine.canStart()
        XCTAssertTrue(readiness.ready)
        XCTAssertNotEqual(ttv, Double(readiness.diagnostics.count))
    }

    func testAscentRateSignPositiveWhenAscending() {
        let start = Date(timeIntervalSince1970: 0)
        let samples = [
            DiveSample(timestamp: start, depthMeters: 20, temperatureCelsius: nil),
            DiveSample(timestamp: start.addingTimeInterval(30), depthMeters: 10, temperatureCelsius: nil),
        ]
        let rate = DiveAlgorithm.ascentRateMetersPerMinute(samples: samples, current: samples[1])
        XCTAssertGreaterThan(rate ?? 0, 0)
    }
}
