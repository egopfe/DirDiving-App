import XCTest

final class ApneaWatchSensorQualityTests: XCTestCase {
    func testUnavailableHRIsNotFatal() {
        let labels = ApneaSensorQualityEvaluator.compactLabels(for: .init(depth: .good, heartRate: .unavailable, spO2: .unavailable))
        XCTAssertTrue(labels.contains("apnea.watch.hr_unavailable"))
    }
}
