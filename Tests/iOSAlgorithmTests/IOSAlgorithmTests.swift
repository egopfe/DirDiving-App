import Foundation
import XCTest

final class IOSAlgorithmTests: XCTestCase {
    func testAirAndNitroxPlannerReturnFiniteReferencePlans() {
        let air = PlannerService.makePlan(input: plannerInput(depth: 30, bottomMinutes: 20, gas: GasMix(name: "Air", oxygen: 0.21, helium: 0, maxPPO2: 1.4)))
        XCTAssertGreaterThan(air.ndlMinutes, 0)
        XCTAssertFalse(air.states.contains(.invalidInput))
        XCTAssertTrue(air.states.contains(.validReference) || air.states.contains(.nonCertifiedReference))

        let nitrox = PlannerService.makePlan(input: plannerInput(depth: 30, bottomMinutes: 20, gas: GasMix(name: "EAN32", oxygen: 0.32, helium: 0, maxPPO2: 1.4)))
        XCTAssertGreaterThan(nitrox.gasAnalysis.ppO2AtDepth, 0)
        XCTAssertFalse(nitrox.states.contains(.invalidInput))
    }

    func testInvalidGasMixesAreRejected() {
        XCTAssertFalse(PlannerInputValidator.validate(plannerInput(gas: GasMix(name: "Bad", oxygen: 0, helium: 0, maxPPO2: 1.4))).isValid)
        XCTAssertFalse(PlannerInputValidator.validate(plannerInput(gas: GasMix(name: "Bad", oxygen: 1.1, helium: 0, maxPPO2: 1.4))).isValid)
        XCTAssertFalse(PlannerInputValidator.validate(plannerInput(gas: GasMix(name: "Bad", oxygen: 0.6, helium: 0.5, maxPPO2: 1.4))).isValid)
        XCTAssertFalse(PlannerInputValidator.validate(plannerInput(gas: GasMix(name: "Bad", oxygen: 0.21, helium: -0.1, maxPPO2: 1.4))).isValid)
    }

    func testInvalidPlannerInputsAreRejected() {
        var zeroCylinder = plannerInput()
        zeroCylinder.cylinder.volumeLiters = 0
        XCTAssertFalse(PlannerInputValidator.validate(zeroCylinder).isValid)

        var zeroSAC = plannerInput()
        zeroSAC.sacLitersPerMinute = 0
        XCTAssertFalse(PlannerInputValidator.validate(zeroSAC).isValid)

        var badPressure = plannerInput()
        badPressure.cylinder.startPressure = 50
        badPressure.cylinder.reservePressure = 50
        XCTAssertFalse(PlannerInputValidator.validate(badPressure).isValid)

        var negativeDepth = plannerInput()
        negativeDepth.plannedDepthMeters = -1
        XCTAssertFalse(PlannerInputValidator.validate(negativeDepth).isValid)

        var deep = plannerInput()
        deep.plannedDepthMeters = IOSAlgorithmConfiguration.maxPlannerDepthMeters + 1
        XCTAssertFalse(PlannerInputValidator.validate(deep).isValid)
    }

    func testTrimixDoesNotUseN2OnlyBuhlmannOutput() {
        let trimix = GasMix(name: "TX 18/45", oxygen: 0.18, helium: 0.45, maxPPO2: 1.4)
        let buhlmann = BuhlmannPlanner.plan(depthMeters: 40, bottomGas: trimix)
        XCTAssertEqual(buhlmann.modelState, .validReference)
        XCTAssertGreaterThanOrEqual(buhlmann.ndlMinutes, 0)
        XCTAssertLessThan(buhlmann.ndlMinutes, 999)

        let plan = PlannerService.makePlan(input: plannerInput(depth: 40, bottomMinutes: 20, gas: trimix))
        XCTAssertFalse(plan.states.contains(.unsupportedTrimix))
        XCTAssertTrue(plan.states.contains(.nonCertifiedReference))
    }

    func testBuhlmannNoLongerReturns999AsValidNDL() {
        XCTAssertNil(BuhlmannPlanner.ndl(depthMeters: 0, nitrogenFraction: 0.79))
        let invalid = BuhlmannPlanner.plan(depthMeters: 30, o2Fraction: 1.2, heliumFraction: 0)
        XCTAssertEqual(invalid.modelState, .invalidInput)
        XCTAssertEqual(invalid.ndlMinutes, 0)
    }

    func testPPO2MODAndGasDensityStatesAreExplicit() {
        let gas = GasMix(name: "EAN32", oxygen: 0.32, helium: 0, maxPPO2: 1.4)
        let input = plannerInput(depth: 40, bottomMinutes: 20, gas: gas)
        let plan = PlannerService.makePlan(input: input)
        XCTAssertTrue(plan.states.contains(.PPO2Exceeded))
        XCTAssertTrue(plan.states.contains(.MODExceeded))

        let stopGas = GasMix(name: "EAN80", role: .deco, oxygen: 0.80, helium: 0, maxPPO2: 1.6)
        let stop = PlannerGasSchedule.makeDecoStop(depthMeters: 21, minutes: 1, gas: stopGas)
        XCTAssertGreaterThan(stop.ppO2, stop.maxPPO2)
        XCTAssertTrue(stop.states.contains(.PPO2Exceeded))

        let densityInput = plannerInput(depth: 60, bottomMinutes: 20, gas: gas)
        let analysis = GasPlanningService.analyze(input: densityInput)
        XCTAssertTrue(analysis.states.contains(.gasDensityWarning) || analysis.states.contains(.gasDensityDanger))
    }

    func testUnitConversionsRoundTrip() {
        XCTAssertEqual(IOSUnitConversions.meters(fromFeet: IOSUnitConversions.feet(fromMeters: 42)), 42, accuracy: 0.0001)
        XCTAssertEqual(IOSUnitConversions.bar(fromPSI: IOSUnitConversions.psi(fromBar: 200)), 200, accuracy: 0.0001)
        XCTAssertEqual(IOSUnitConversions.liters(fromCubicFeet: IOSUnitConversions.cubicFeet(fromLiters: 12)), 12, accuracy: 0.0001)
        XCTAssertEqual(IOSUnitConversions.celsius(fromFahrenheit: IOSUnitConversions.fahrenheit(fromCelsius: 24)), 24, accuracy: 0.0001)
        XCTAssertEqual(IOSUnitConversions.metersPerMinute(fromFeetPerMinute: IOSUnitConversions.feetPerMinute(fromMetersPerMinute: 9)), 9, accuracy: 0.0001)
    }

    func testTimeWeightedProfileMathAndCanonicalTTV() {
        let start = Date(timeIntervalSince1970: 1_000)
        let samples = [
            DiveSample(timestamp: start, depthMeters: 10, temperatureCelsius: 20),
            DiveSample(timestamp: start.addingTimeInterval(30), depthMeters: 30, temperatureCelsius: 21),
            DiveSample(timestamp: start.addingTimeInterval(90), depthMeters: 0, temperatureCelsius: 22)
        ]
        let avg = DiveProfileMath.timeWeightedAverageDepth(samples: samples)
        XCTAssertEqual(avg, 70.0 / 3.0, accuracy: 0.001)
        XCTAssertEqual(DiveProfileMath.ttvIndex(averageDepthMeters: 20, durationSeconds: 30 * 60), 50, accuracy: 0.001)
    }

    func testImportSortsSamplesAndRejectsInvalidRows() throws {
        let csv = """
        time_seconds,depth_m,temperature_c,entry_lat,entry_lon,exit_lat,exit_lon
        0,10,20,44.0,9.0,44.1,9.1
        60,20,20,,,,
        """
        let url = try temporaryCSV(csv)
        let result = DiveImportService.importCSV(from: url)
        guard case .success(let summary) = result else {
            XCTFail("Expected valid import")
            return
        }
        XCTAssertEqual(summary.session.samples.first?.timestamp, summary.session.startDate)
        XCTAssertGreaterThanOrEqual(summary.session.entryGPS?.horizontalAccuracy ?? -1, 0)
        XCTAssertGreaterThan(summary.session.avgDepthMeters, 0)
    }

    func testExportRejectsEmptyAndProducesMonotonicCSV() {
        let empty = makeSession(samples: [])
        XCTAssertNil(SubsurfaceExportService.makeCSV(for: empty))
        if case .failure(.emptySamples) = SubsurfaceExportService.writeCSV(for: empty) {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected empty profile export rejection")
        }

        let start = Date(timeIntervalSince1970: 10)
        let unsorted = makeSession(start: start, samples: [
            DiveSample(timestamp: start.addingTimeInterval(60), depthMeters: 12, temperatureCelsius: 20),
            DiveSample(timestamp: start, depthMeters: 0, temperatureCelsius: 20)
        ])
        let csv = SubsurfaceExportService.makeCSV(for: unsorted)
        XCTAssertNotNil(csv)
        XCTAssertFalse(csv?.contains("-") ?? true)
    }

    func testInvalidDepthTemperatureAndGPSAreRejected() {
        XCTAssertNil(DiveProfileMath.sanitizedDepthMeters(.nan))
        XCTAssertNil(DiveProfileMath.sanitizedDepthMeters(.infinity))
        XCTAssertNil(DiveProfileMath.sanitizedTemperatureCelsius(-10))
        XCTAssertNil(DiveProfileMath.sanitizedTemperatureCelsius(50))
        XCTAssertFalse(DiveProfileMath.isValidGPS(GPSPoint(latitude: 91, longitude: 9, horizontalAccuracy: 5, timestamp: Date())))
        XCTAssertFalse(DiveProfileMath.isValidGPS(GPSPoint(latitude: 44, longitude: 181, horizontalAccuracy: 5, timestamp: Date())))
    }

    func testMergeRecomputesDerivedFieldsAndLogCapDropsOldest() {
        let start = Date(timeIntervalSince1970: 100)
        let first = makeSession(
            id: UUID(),
            start: start,
            samples: [
                DiveSample(timestamp: start, depthMeters: 10, temperatureCelsius: 20),
                DiveSample(timestamp: start.addingTimeInterval(30), depthMeters: 12, temperatureCelsius: 20)
            ]
        )
        let second = makeSession(
            id: first.id,
            start: start,
            samples: [DiveSample(timestamp: start.addingTimeInterval(60), depthMeters: 20, temperatureCelsius: 21)]
        )
        let merged = DiveSessionMerge.preferred(first, second)
        XCTAssertGreaterThanOrEqual(merged.samples.count, 1)
        XCTAssertEqual(merged.maxDepthMeters, 20, accuracy: 0.001)
        XCTAssertEqual(merged.ttv, DiveProfileMath.ttvIndex(averageDepthMeters: merged.avgDepthMeters, durationSeconds: merged.durationSeconds), accuracy: 0.001)

        let sessions = (0..<41).map { index in
            makeSession(id: UUID(), start: Date(timeIntervalSince1970: Double(index) * 60))
        }
        let capped = IOSDiveLogbookPolicy.normalizeAndCap(sessions)
        XCTAssertEqual(capped.count, IOSAlgorithmConfiguration.maxLogSessions)
        XCTAssertEqual(capped.first?.startDate, Date(timeIntervalSince1970: 40 * 60))
        XCTAssertFalse(capped.contains { $0.startDate == Date(timeIntervalSince1970: 0) })
    }

    func testWatchSyncValidationRejectsCorruptedSessionsAndNormalizesDerivedValues() throws {
        let valid = makeSession()
        XCTAssertNoThrow(try WatchDiveSyncCodec.validateForSync(valid))

        let corrupted = makeSession(samples: [DiveSample(timestamp: Date(), depthMeters: .nan, temperatureCelsius: 20)])
        XCTAssertThrowsError(try WatchDiveSyncCodec.validateForSync(corrupted))

        let invalidGPS = DiveSession(
            id: UUID(),
            startDate: valid.startDate,
            endDate: valid.endDate,
            durationSeconds: valid.durationSeconds,
            maxDepthMeters: valid.maxDepthMeters,
            avgDepthMeters: valid.avgDepthMeters,
            avgWaterTemperatureCelsius: valid.avgWaterTemperatureCelsius,
            ttv: valid.ttv,
            entryGPS: GPSPoint(latitude: 200, longitude: 9, horizontalAccuracy: 10, timestamp: valid.startDate),
            exitGPS: nil,
            samples: valid.samples
        )
        let sanitizedInvalidGPS = try XCTUnwrap(try? WatchDiveSyncCodec.validateForSync(invalidGPS))
        XCTAssertNil(sanitizedInvalidGPS.entryGPS)

        let staleDerived = DiveSession(
            id: valid.id,
            startDate: valid.startDate,
            endDate: valid.endDate,
            durationSeconds: valid.durationSeconds,
            maxDepthMeters: 1,
            avgDepthMeters: 1,
            avgWaterTemperatureCelsius: valid.avgWaterTemperatureCelsius,
            ttv: 1,
            entryGPS: nil,
            exitGPS: nil,
            samples: valid.samples
        )
        let normalized = try? WatchDiveSyncCodec.validateForSync(staleDerived)
        XCTAssertEqual(normalized?.maxDepthMeters ?? 0, valid.maxDepthMeters, accuracy: 0.001)
    }

    func testRouteMathRejectsInvalidGPSAndHandlesIdenticalPoints() {
        let valid = GPSPoint(latitude: 44, longitude: 9, horizontalAccuracy: 5, timestamp: Date())
        XCTAssertEqual(RouteSummaryService.distance(from: valid, to: valid), 0, accuracy: 0.001)
        XCTAssertNil(RouteSummaryService.bearing(from: valid, to: valid))

        let invalid = GPSPoint(latitude: .nan, longitude: 9, horizontalAccuracy: 5, timestamp: Date())
        XCTAssertEqual(RouteSummaryService.distance(from: invalid, to: valid), 0, accuracy: 0.001)
        XCTAssertNil(RouteSummaryService.bearing(from: invalid, to: valid))
    }

    private func plannerInput(depth: Double = 30, bottomMinutes: Double = 20, gas: GasMix = GasMix(name: "Air", oxygen: 0.21, helium: 0, maxPPO2: 1.4)) -> GasPlanInput {
        var input = GasPlanInput()
        input.plannedDepthMeters = depth
        input.plannedAverageDepthMeters = min(depth, max(1, depth * 0.6))
        input.plannedBottomMinutes = bottomMinutes
        input.bottomGas = gas
        input.cylinder = Cylinder(volumeLiters: 12, startPressure: 200, reservePressure: 50, pressureUnit: .bar)
        input.plannerCylinders = []
        input.decoGas1 = GasMix(name: "EAN50", role: .deco, oxygen: 0.50, helium: 0, maxPPO2: 1.6)
        input.decoGas2 = GasMix(name: "EAN80", role: .deco, oxygen: 0.80, helium: 0, maxPPO2: 1.6)
        input.sacLitersPerMinute = 18
        input.emergencySacLitersPerMinute = 30
        return input
    }

    private func makeSession(
        id: UUID = UUID(),
        start: Date = Date(timeIntervalSince1970: 1_000),
        samples: [DiveSample]? = nil
    ) -> DiveSession {
        let profile = samples ?? [
            DiveSample(timestamp: start, depthMeters: 0, temperatureCelsius: 20),
            DiveSample(timestamp: start.addingTimeInterval(60), depthMeters: 20, temperatureCelsius: 20),
            DiveSample(timestamp: start.addingTimeInterval(120), depthMeters: 0, temperatureCelsius: 21)
        ]
        let end = profile.map(\.timestamp).max() ?? start
        let summary = DiveProfileMath.summary(samples: profile, startDate: start, endDate: end)
        return DiveSession(
            id: id,
            startDate: start,
            endDate: end,
            durationSeconds: summary.durationSeconds,
            maxDepthMeters: summary.maxDepthMeters,
            avgDepthMeters: summary.averageDepthMeters,
            avgWaterTemperatureCelsius: summary.averageTemperatureCelsius,
            ttv: summary.ttv,
            entryGPS: nil,
            exitGPS: nil,
            samples: profile
        )
    }

    private func temporaryCSV(_ contents: String) throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("DIRDivingTest_\(UUID().uuidString).csv")
        try contents.write(to: url, atomically: true, encoding: .utf8)
        return url
    }
}
