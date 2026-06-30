import XCTest

final class ApneaWatchProfileRuntimeLayoutTests: XCTestCase {
    func testStaticLayoutShowsHoldAndRecovery() {
        let layout = ApneaWatchProfileLayoutPresentation.make(
            layout: .staticHoldRecovery,
            holdSeconds: 134,
            recoveryElapsed: 80,
            recoveryTarget: 268,
            recoveryRemaining: 188,
            currentDepthMeters: 0,
            maxDepthMeters: 0,
            repetitionCount: 3,
            maxRepetitions: 6,
            sensorLabels: ["apnea.watch.sensors_ok"]
        )
        XCTAssertEqual(layout.primaryValue, "2:14")
        XCTAssertEqual(layout.repetitionText, "3/6")
    }

    func testDepthLayoutShowsDepthMetrics() {
        let layout = ApneaWatchProfileLayoutPresentation.make(
            layout: .depthMetrics,
            holdSeconds: 65,
            recoveryElapsed: 0,
            recoveryTarget: 130,
            recoveryRemaining: 130,
            currentDepthMeters: 12.4,
            maxDepthMeters: 18.2,
            repetitionCount: 1,
            maxRepetitions: nil,
            sensorLabels: []
        )
        XCTAssertEqual(layout.primaryValue, "12.4 m")
        XCTAssertEqual(layout.secondaryValue, "18.2 m")
    }
}
