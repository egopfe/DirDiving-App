import XCTest

final class IOSMainAlgorithmReadinessTests: XCTestCase {
    func testNDLCurveUsesDepthAndNDLAxes() {
        let point = NDLPoint(depthMeters: 30, ndlMinutes: 25, compartmentGroup: "5-8")
        XCTAssertEqual(point.depthMeters, 30)
        XCTAssertEqual(point.ndlMinutes, 25)
        XCTAssertFalse(point.ndlMinutes == max(0, 100 - point.depthMeters * 1.5))
    }

    func testStoredProfileDepthCapUnifiedAt350() {
        XCTAssertEqual(IOSAlgorithmConfiguration.maxImportExportDepthMeters, 350)
        XCTAssertEqual(IOSAlgorithmConfiguration.maxSyncDepthMeters, 350)
        XCTAssertEqual(IOSAlgorithmConfiguration.maxStoredProfileDepthMeters, 350)
        XCTAssertLessThan(IOSAlgorithmConfiguration.maxPlannerDepthMeters, IOSAlgorithmConfiguration.maxStoredProfileDepthMeters)
    }

    func testDepth350AcceptedForImportExport() throws {
        let depth = 350.0
        XCTAssertNotNil(DiveProfileMath.sanitizedDepthMeters(depth, maxDepthMeters: IOSAlgorithmConfiguration.maxImportExportDepthMeters))
        XCTAssertNil(DiveProfileMath.sanitizedDepthMeters(351, maxDepthMeters: IOSAlgorithmConfiguration.maxImportExportDepthMeters))
    }

    func testManualDiveImperialDefaultsMatchMetricIntent() {
        let imperialMax = ManualDiveEditorDefaults.defaultMaxDepthInput(units: .imperial)
        let imperialAvg = ManualDiveEditorDefaults.defaultAverageDepthInput(units: .imperial)
        XCTAssertEqual(imperialMax, 98, accuracy: 1)
        XCTAssertEqual(imperialAvg, 59, accuracy: 1)
        let storedMax = ManualDiveEditorDefaults.depthMeters(fromInput: imperialMax, units: .imperial)
        XCTAssertEqual(storedMax, 30, accuracy: 0.5)
    }

    func testManualDiveMetricDefaults() {
        XCTAssertEqual(ManualDiveEditorDefaults.defaultMaxDepthInput(units: .metric), 30)
        XCTAssertEqual(ManualDiveEditorDefaults.defaultAverageDepthInput(units: .metric), 18)
    }

    func testEmptyProfileMergeDoesNotUnderReportAverage() {
        let older = makeManualSession(
            end: Date(timeIntervalSince1970: 100),
            maxDepth: 20,
            avgDepth: 12
        )
        let newer = makeManualSession(
            end: Date(timeIntervalSince1970: 200),
            maxDepth: 25,
            avgDepth: 18
        )
        let merged = DiveSessionMerge.preferred(older, newer)
        XCTAssertEqual(merged.avgDepthMeters, 18, accuracy: 0.001)
    }

    func testAnalysisDashboardExcludesDemoByDefault() {
        let demo = makeSession(maxDepth: 10, avgDepth: 8, isDemo: true)
        let real = makeSession(maxDepth: 20, avgDepth: 15)
        let filtered = AnalysisDashboardMath.sessionsForAnalysis(all: [demo, real], includeDemo: false)
        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(AnalysisDashboardMath.summary(from: filtered).diveCount, 1)
    }

    func testAnalysisMeanSACIgnoresNil() {
        let withSAC = makeSession(maxDepth: 10, avgDepth: 8, sacLitersMinute: 20)
        let withoutSAC = makeSession(maxDepth: 12, avgDepth: 10, sacLitersMinute: nil)
        let summary = AnalysisDashboardMath.summary(from: [withSAC, withoutSAC])
        XCTAssertEqual(summary.averageSACLitersPerMinute ?? 0, 20, accuracy: 0.001)
    }

    func testRouteBearingFirstOfManyScope() {
        let entry = GPSPoint(latitude: 44, longitude: 8, horizontalAccuracy: 10, timestamp: Date())
        let exit = GPSPoint(latitude: 44.01, longitude: 8.01, horizontalAccuracy: 10, timestamp: Date())
        let session = makeSession(maxDepth: 10, avgDepth: 8, entryGPS: entry, exitGPS: exit)
        let aggregate = RouteSummaryAggregation.aggregate(from: [session, session])
        if case .firstOfMany(let count) = aggregate.bearingScope {
            XCTAssertEqual(count, 2)
        } else {
            XCTFail("Expected firstOfMany bearing scope")
        }
    }

    func testCNSDisplayCapShowsGreaterThan300() {
        XCTAssertEqual(OxygenExposureDisplay.formatCNSPercent(350), ">300%")
        XCTAssertEqual(OxygenExposureDisplay.formatCNSPercent(50), "50.0")
    }

    func testMODValidatorMatchesStopGasLabel() {
        let gas = GasMix(name: "O2 80", role: .deco, oxygen: 0.80, helium: 0, maxPPO2: 1.6)
        let stop = DecoStop(depthMeters: 20, minutes: 5, gas: "O2 80", ppO2: 1.5, maxPPO2: 1.6)
        let wrongOrder = [GasMix(name: "Air", role: .bottom, oxygen: 0.21, helium: 0, maxPPO2: 1.4)]
        let issuesWrong = PlannerMODValidator.validateDecoStops(stops: [stop], gases: wrongOrder)
        let issuesRight = PlannerMODValidator.validateDecoStops(stops: [stop], gases: [gas])
        XCTAssertTrue(issuesWrong.isEmpty)
        XCTAssertFalse(issuesRight.isEmpty)
    }

    func testGasMixValidatorMODUsesEnvironmentPressure() throws {
        let modSea = GasMixValidator.modMeters(oxygenFraction: 0.32, maxPPO2: 1.4, environment: .seaLevelSaltWater) ?? 0
        let highEnv = try XCTUnwrap(PlannerEnvironment.make(altitudeMeters: 2_000, salinity: .salt).get())
        let modHigh = GasMixValidator.modMeters(oxygenFraction: 0.32, maxPPO2: 1.4, environment: highEnv) ?? 0
        XCTAssertGreaterThan(modHigh, modSea)
    }

    // MARK: - Helpers

    private func makeManualSession(
        end: Date,
        maxDepth: Double,
        avgDepth: Double
    ) -> DiveSession {
        DiveSession(
            startDate: Date(timeIntervalSince1970: 0),
            endDate: end,
            durationSeconds: end.timeIntervalSince1970,
            maxDepthMeters: maxDepth,
            avgDepthMeters: avgDepth,
            avgWaterTemperatureCelsius: nil,
            ttv: DiveProfileMath.ttvIndex(averageDepthMeters: avgDepth, durationSeconds: end.timeIntervalSince1970),
            entryGPS: nil,
            exitGPS: nil,
            samples: [],
            isManual: true,
            hasDepthProfile: false
        )
    }

    private func makeSession(
        maxDepth: Double,
        avgDepth: Double,
        sacLitersMinute: Double? = nil,
        isDemo: Bool = false,
        entryGPS: GPSPoint? = nil,
        exitGPS: GPSPoint? = nil
    ) -> DiveSession {
        let start = Date()
        let end = start.addingTimeInterval(60)
        return DiveSession(
            startDate: start,
            endDate: end,
            durationSeconds: 60,
            maxDepthMeters: maxDepth,
            avgDepthMeters: avgDepth,
            avgWaterTemperatureCelsius: nil,
            ttv: DiveProfileMath.ttvIndex(averageDepthMeters: avgDepth, durationSeconds: 60),
            entryGPS: entryGPS,
            exitGPS: exitGPS,
            samples: [],
            sacLitersMinute: sacLitersMinute,
            isDemo: isDemo
        )
    }
}
