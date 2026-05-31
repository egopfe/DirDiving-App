import XCTest

final class AnalysisDemoIsolationTests: XCTestCase {
    private func session(
        maxDepth: Double,
        isDemo: Bool = false,
        gas: DiveGasLabel = .oc
    ) -> DiveSession {
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        let end = start.addingTimeInterval(3600)
        return DiveSession(
            startDate: start,
            endDate: end,
            durationSeconds: 3600,
            maxDepthMeters: maxDepth,
            avgDepthMeters: maxDepth * 0.6,
            avgWaterTemperatureCelsius: nil,
            ttv: maxDepth + 60,
            entryGPS: nil,
            exitGPS: nil,
            samples: [],
            gasLabel: gas,
            isDemo: isDemo
        )
    }

    func testDemoSessionsAreIdentifiable() {
        XCTAssertTrue(session(maxDepth: 30, isDemo: true).isDemoDive)
    }

    func testAnalysisAggregateExcludesDemoByDefault() {
        let real = session(maxDepth: 24, gas: .nitrox)
        let demo = session(maxDepth: 42, isDemo: true, gas: .trimix)
        let analysisSessions = [real, demo].filter { !$0.isDemoDive }
        XCTAssertEqual(analysisSessions.count, 1)
        XCTAssertEqual(analysisSessions.first?.maxDepthMeters, 24)
    }
}
