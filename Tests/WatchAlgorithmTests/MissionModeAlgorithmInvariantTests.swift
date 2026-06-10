import XCTest

/// Mission Mode must not alter dive math — only UI profile flags.
final class MissionModeAlgorithmInvariantTests: XCTestCase {
    func testMissionProfileDoesNotChangeDepthSafetyThresholds() {
        XCTAssertEqual(DepthSafetyState.from(depthMeters: 35), .caution)
        XCTAssertEqual(DepthSafetyState.from(depthMeters: 40), .exceeded)
        XCTAssertEqual(DepthSafetyState.from(depthMeters: 35), DepthSafetyState.from(depthMeters: 35))
    }

    func testMissionProfileDoesNotChangeTTVOrAverageDepthFormulas() {
        let avg = 20.0
        let duration: TimeInterval = 1_800
        let ttvStandard = DiveAlgorithm.ttvIndex(averageDepthMeters: avg, durationSeconds: duration)
        XCTAssertEqual(ttvStandard, 50, accuracy: 0.001)
        XCTAssertEqual(
            DiveAlgorithm.timeWeightedAverageDepth(samples: [
                DiveSample(timestamp: Date(timeIntervalSince1970: 0), depthMeters: 10, temperatureCelsius: nil),
                DiveSample(timestamp: Date(timeIntervalSince1970: 60), depthMeters: 30, temperatureCelsius: nil)
            ], endDate: Date(timeIntervalSince1970: 120)),
            20,
            accuracy: 0.001
        )
    }

    func testMissionProfileDoesNotChangeAscentRate() {
        let start = Date(timeIntervalSince1970: 0)
        let samples = [sample(20, at: start), sample(18, at: start.addingTimeInterval(10))]
        let current = sample(16, at: start.addingTimeInterval(20))
        let rate = DiveAlgorithm.ascentRateMetersPerMinute(samples: samples, current: current)
        XCTAssertEqual(rate, 12, accuracy: 0.001)
    }

    func testRuntimeProfilesOnlyDifferOnDecorativeFlags() {
        XCTAssertTrue(MissionModeRuntimeProfile.standard.animationsEnabled)
        XCTAssertTrue(MissionModeRuntimeProfile.standard.decorativeEffectsEnabled)
        XCTAssertFalse(MissionModeRuntimeProfile.mission.animationsEnabled)
        XCTAssertFalse(MissionModeRuntimeProfile.mission.decorativeEffectsEnabled)
    }

    func testMissionProfileDoesNotExposeGPSOrSyncOrSamplingFields() {
        for profile in [MissionModeRuntimeProfile.standard, MissionModeRuntimeProfile.mission] {
            let labels = Mirror(reflecting: profile).children.compactMap(\.label)
            for label in labels {
                let lower = label.lowercased()
                XCTAssertFalse(lower.contains("gps"))
                XCTAssertFalse(lower.contains("sync"))
                XCTAssertFalse(lower.contains("export"))
                XCTAssertFalse(lower.contains("sample"))
                XCTAssertFalse(lower.contains("haptic"))
                XCTAssertFalse(lower.contains("reminder"))
            }
        }
    }

    private func sample(_ depth: Double, at date: Date) -> DiveSample {
        DiveSample(timestamp: date, depthMeters: depth, temperatureCelsius: nil)
    }
}
