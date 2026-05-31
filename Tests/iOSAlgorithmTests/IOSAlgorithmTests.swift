import XCTest
@testable import DIRDivingiOS

final class IOSAlgorithmTests: XCTestCase {
    private func gasPlan(
        depth: Double = 30,
        minutes: Double = 20,
        bottomGas: GasMix = GasMix(name: "Air", oxygen: 0.21, helium: 0, maxPPO2: 1.40)
    ) -> GasPlanInput {
        var input = GasPlanInput()
        input.plannedDepthMeters = depth
        input.plannedBottomMinutes = minutes
        input.bottomGas = bottomGas
        input.decoGas1 = GasMix(name: "EAN50", oxygen: 0.50, helium: 0, maxPPO2: 1.60)
        input.decoGas2 = GasMix(name: "Oxygen", oxygen: 1.0, helium: 0, maxPPO2: 1.60)
        return input
    }

    private func session(
        samples: [DiveSample],
        start: Date = Date(timeIntervalSince1970: 1_000),
        end: Date? = nil,
        maxDepth: Double? = nil,
        averageDepth: Double? = nil,
        ttv: Double? = nil,
        entryGPS: GPSPoint? = nil,
        exitGPS: GPSPoint? = nil
    ) -> DiveSession {
        let fallbackEnd = end ?? samples.last?.timestamp ?? start
        let metrics = DiveProfileMath.derivedMetrics(samples: samples, fallbackStart: start, fallbackEnd: fallbackEnd)
        return DiveSession(
            startDate: metrics.startDate,
            endDate: fallbackEnd,
            durationSeconds: metrics.durationSeconds,
            maxDepthMeters: maxDepth ?? metrics.maxDepthMeters,
            avgDepthMeters: averageDepth ?? metrics.avgDepthMeters,
            avgWaterTemperatureCelsius: metrics.avgWaterTemperatureCelsius,
            minWaterTemperatureCelsius: metrics.minWaterTemperatureCelsius,
            maxWaterTemperatureCelsius: metrics.maxWaterTemperatureCelsius,
            ttv: ttv ?? metrics.ttv,
            entryGPS: entryGPS,
            exitGPS: exitGPS,
            samples: samples,
            siteName: "Test"
        )
    }

    func testPlannerAcceptsValidatedAirReferenceAt30Meters() {
        let plan = PlannerService.makePlan(input: gasPlan(depth: 30, minutes: 20))

        XCTAssertTrue(plan.ndlMinutes.isFinite)
        XCTAssertTrue(plan.states.contains(.validReference))
        XCTAssertTrue(plan.states.contains(.simplifiedReferenceOnly))
        XCTAssertEqual(plan.modelState, .simplifiedReferenceOnly)
    }

    func testPlannerAcceptsNitrox32At30Meters() {
        let gas = GasMix(name: "EAN32", oxygen: 0.32, helium: 0, maxPPO2: 1.40)
        let plan = PlannerService.makePlan(input: gasPlan(depth: 30, minutes: 20, bottomGas: gas))

        XCTAssertTrue(plan.ndlMinutes.isFinite)
        XCTAssertTrue(plan.states.contains(.validReference))
        XCTAssertFalse(plan.states.contains(.MODExceeded))
    }

    func testInvalidGasFractionsAreRejected() {
        let gas = GasMix(name: "Invalid", oxygen: 0.80, helium: 0.30, maxPPO2: 1.40)

        XCTAssertTrue(PlannerInputValidator.errorMessage(for: gasPlan(bottomGas: gas)) != nil)
        if case .failure(.fractionsExceedOne) = GasMixValidator.validate(gas) {
            XCTAssertTrue(true)
        } else {
            XCTFail("O2 + He above 100% must be rejected.")
        }
    }

    func testPlannerRejectsInvalidNumericInputs() {
        var zeroCylinder = gasPlan()
        zeroCylinder.cylinderVolumeLiters = 0
        XCTAssertTrue(PlannerInputValidator.errorMessage(for: zeroCylinder) != nil)

        var zeroSAC = gasPlan()
        zeroSAC.sacLitersPerMinute = 0
        XCTAssertTrue(PlannerInputValidator.errorMessage(for: zeroSAC) != nil)

        var negativeDepth = gasPlan()
        negativeDepth.plannedDepthMeters = -1
        XCTAssertTrue(PlannerInputValidator.errorMessage(for: negativeDepth) != nil)

        var unsupportedDepth = gasPlan()
        unsupportedDepth.plannedDepthMeters = IOSAlgorithmConfiguration.maximumPlannerDepthMeters + 1
        XCTAssertTrue(PlannerInputValidator.errorMessage(for: unsupportedDepth) != nil)
    }

    func testMODExceededIsRejectedBeforePlanning() {
        let gas = GasMix(name: "EAN50", oxygen: 0.50, helium: 0, maxPPO2: 1.40)
        var input = gasPlan(depth: 30, bottomGas: gas)

        if case .failure(.modExceeded) = PlannerInputValidator.validate(input) {
            XCTAssertTrue(true)
        } else {
            XCTFail("Depth beyond MOD must be rejected.")
        }
        input.plannedDepthMeters = 18
        XCTAssertNil(PlannerInputValidator.errorMessage(for: input))
    }

    func testTrimixReturnsUnsupportedState() {
        let trimix = GasMix(name: "TX 18/45", oxygen: 0.18, helium: 0.45, maxPPO2: 1.40)
        let plan = PlannerService.makePlan(input: gasPlan(depth: 40, minutes: 20, bottomGas: trimix))

        XCTAssertEqual(plan.ndlMinutes, 0)
        XCTAssertEqual(plan.modelState, .unsupportedTrimix)
        XCTAssertTrue(plan.states.contains(.unsupportedTrimix))
        XCTAssertTrue(plan.states.contains(.modelIncomplete))
    }

    func testBuhlmannDoesNotReturnFake999MinuteNDL() {
        let unsupported = BuhlmannPlanner.plan(
            depthMeters: 40,
            gas: GasMix(name: "TX", oxygen: 0.18, helium: 0.45, maxPPO2: 1.40)
        )

        XCTAssertEqual(unsupported.ndlMinutes, 0)
        XCTAssertEqual(unsupported.modelState, .unsupportedTrimix)
        XCTAssertFalse(unsupported.ndlMinutes == 999)
    }

    func testStopPPO2OverLimitIsExposedNotClipped() {
        var input = gasPlan(depth: 40, minutes: 60)
        input.decoGas2 = GasMix(name: "O2 Low Limit", oxygen: 1.0, helium: 0, maxPPO2: 1.0)

        let plan = PlannerService.makePlan(input: input)
        XCTAssertTrue(plan.states.contains(.PPO2Exceeded))
        XCTAssertTrue(plan.decoStops.contains { $0.isPPO2Exceeded && $0.ppO2 > $0.maxPPO2 })
    }

    func testGasAnalysisExposesPPN2EADEndAndDensity() throws {
        let analysis = try XCTUnwrap(GasMixValidator.analysis(
            for: GasMix(name: "EAN32", oxygen: 0.32, helium: 0, maxPPO2: 1.40),
            depthMeters: 30
        ))

        XCTAssertEqual(analysis.ppO2, 1.28, accuracy: 0.001)
        XCTAssertEqual(analysis.ppN2, 2.72, accuracy: 0.001)
        XCTAssertNotNil(analysis.eadMeters)
        XCTAssertNotNil(analysis.endMeters)
        XCTAssertTrue(analysis.gasDensityGramsPerLiter.isFinite)
    }

    func testUnitConversionsRoundTrip() {
        XCTAssertEqual(IOSUnitConversions.meters(fromFeet: IOSUnitConversions.feet(fromMeters: 30)), 30, accuracy: 0.0001)
        XCTAssertEqual(IOSUnitConversions.bar(fromPSI: IOSUnitConversions.psi(fromBar: 200)), 200, accuracy: 0.0001)
        XCTAssertEqual(IOSUnitConversions.liters(fromCubicFeet: IOSUnitConversions.cubicFeet(fromLiters: 12)), 12, accuracy: 0.0001)
        XCTAssertEqual(IOSUnitConversions.celsius(fromFahrenheit: IOSUnitConversions.fahrenheit(fromCelsius: 24)), 24, accuracy: 0.0001)
        XCTAssertEqual(IOSUnitConversions.meters(fromKilometers: IOSUnitConversions.kilometers(fromMeters: 2_000)), 2_000, accuracy: 0.0001)
        XCTAssertEqual(IOSUnitConversions.meters(fromMiles: IOSUnitConversions.miles(fromMeters: 1_609.344)), 1_609.344, accuracy: 0.0001)
    }

    func testTimeWeightedAverageWithIrregularSamples() {
        let start = Date(timeIntervalSince1970: 2_000)
        let samples = [
            DiveSample(timestamp: start, depthMeters: 10, temperatureCelsius: 20),
            DiveSample(timestamp: start.addingTimeInterval(10), depthMeters: 20, temperatureCelsius: 19),
            DiveSample(timestamp: start.addingTimeInterval(40), depthMeters: 0, temperatureCelsius: 21)
        ]

        let average = DiveProfileMath.timeWeightedAverageDepth(samples: samples, endDate: start.addingTimeInterval(40))
        XCTAssertEqual(average, 17.5, accuracy: 0.001)
        XCTAssertEqual(DiveProfileMath.timeWeightedAverageDepth(samples: [samples[0]]), 10)
        XCTAssertEqual(DiveProfileMath.timeWeightedAverageDepth(samples: []), 0)
    }

    func testProfileSanitizationRejectsNaNInfinityAndInvalidTemperature() {
        let start = Date(timeIntervalSince1970: 3_000)
        let samples = [
            DiveSample(timestamp: start, depthMeters: Double.nan, temperatureCelsius: 20),
            DiveSample(timestamp: start.addingTimeInterval(1), depthMeters: Double.infinity, temperatureCelsius: 20),
            DiveSample(timestamp: start.addingTimeInterval(2), depthMeters: 12, temperatureCelsius: 200)
        ]

        let sanitized = DiveProfileMath.sanitizedSamples(samples)
        XCTAssertEqual(sanitized.count, 1)
        XCTAssertNil(sanitized[0].temperatureCelsius)
    }

    func testMergeRecomputesDerivedValuesFromCanonicalSamples() {
        let start = Date(timeIntervalSince1970: 4_000)
        let samples = [
            DiveSample(timestamp: start, depthMeters: 10, temperatureCelsius: 20),
            DiveSample(timestamp: start.addingTimeInterval(60), depthMeters: 20, temperatureCelsius: 18)
        ]
        let corrupted = session(samples: samples, maxDepth: 99, averageDepth: 99, ttv: 99)

        let merged = DiveSessionMerge.preferred(corrupted, corrupted)
        XCTAssertEqual(merged.maxDepthMeters, 20, accuracy: 0.001)
        XCTAssertNotEqual(merged.avgDepthMeters, 99)
        XCTAssertEqual(merged.ttv, DiveProfileMath.ttvIndex(averageDepthMeters: merged.avgDepthMeters, durationSeconds: merged.durationSeconds), accuracy: 0.001)
    }

    func testLogLimitKeepsNewest40Sessions() {
        let start = Date(timeIntervalSince1970: 5_000)
        let sessions = (0..<41).map { offset in
            session(
                samples: [DiveSample(timestamp: start.addingTimeInterval(Double(offset)), depthMeters: 1, temperatureCelsius: nil)],
                start: start.addingTimeInterval(Double(offset))
            )
        }

        let trimmed = DiveProfileMath.trimToLogLimit(sessions)
        XCTAssertEqual(trimmed.count, IOSAlgorithmConfiguration.maxLogSessions)
        XCTAssertEqual(trimmed.first?.startDate, start.addingTimeInterval(40))
        XCTAssertFalse(trimmed.contains { $0.startDate == start })
    }

    func testExportRejectsEmptyProfileAndSortsElapsedSeconds() throws {
        let start = Date(timeIntervalSince1970: 6_000)
        let empty = session(samples: [], start: start)
        if case .success = SubsurfaceExportService.makeCSV(for: empty) {
            XCTFail("Empty profile must not produce a header-only export.")
        }

        let unsorted = session(samples: [
            DiveSample(timestamp: start.addingTimeInterval(30), depthMeters: 12, temperatureCelsius: nil),
            DiveSample(timestamp: start, depthMeters: 2, temperatureCelsius: nil)
        ])
        let csv = try SubsurfaceExportService.makeCSV(for: unsorted).get()
        let rows = csv.split(separator: "\n").dropFirst()
        let elapsed = rows.compactMap { Int($0.split(separator: ",")[0]) }
        XCTAssertEqual(elapsed, [0, 30])
    }

    func testSyncValidatorRejectsCorruptedSessions() {
        let start = Date(timeIntervalSince1970: 7_000)
        let outside = DiveSession(
            startDate: start,
            endDate: start.addingTimeInterval(60),
            durationSeconds: 60,
            maxDepthMeters: 3,
            avgDepthMeters: 3,
            avgWaterTemperatureCelsius: nil,
            ttv: 4,
            entryGPS: nil,
            exitGPS: nil,
            samples: [DiveSample(timestamp: start.addingTimeInterval(-1), depthMeters: 3, temperatureCelsius: nil)]
        )
        XCTAssertThrowsError(try DiveSessionAlgorithmValidator.validate(outside))

        let invalidGPS = GPSPoint(latitude: 500, longitude: 13, horizontalAccuracy: 10, timestamp: start)
        let gpsSession = session(
            samples: [DiveSample(timestamp: start, depthMeters: 3, temperatureCelsius: nil)],
            start: start,
            entryGPS: invalidGPS
        )
        XCTAssertThrowsError(try DiveSessionAlgorithmValidator.validate(gpsSession))
    }

    func testRouteMathRejectsInvalidCoordinates() {
        let start = GPSPoint(latitude: 91, longitude: 13, horizontalAccuracy: 10, timestamp: Date())
        let end = GPSPoint(latitude: 45, longitude: 14, horizontalAccuracy: 10, timestamp: Date())

        XCTAssertNil(RouteSummaryService.distance(from: start, to: end))
        XCTAssertNil(RouteSummaryService.bearing(from: start, to: end))
    }

    func testImportRejectsMalformedCSVProfile() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("dirdiving_invalid_import.csv")
        try "time_seconds,depth_m,temperature_c\n0,NaN,20\n".write(to: url, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: url) }

        if case .success = DiveImportService.importCSV(from: url) {
            XCTFail("Malformed CSV must not import as a valid dive.")
        }
    }
}
