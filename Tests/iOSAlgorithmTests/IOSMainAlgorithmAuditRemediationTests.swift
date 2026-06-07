import XCTest

final class IOSMainAlgorithmAuditRemediationTests: XCTestCase {
    // MARK: - HIGH-002 / MED-002 / HIGH-001 remediation @ ecad0d9 audit

    func testBaseInvalidAltitudeFailsValidation() {
        var input = GasPlanInput()
        input.plannedDepthMeters = 30
        input.plannedBottomMinutes = 20
        input.altitudeMeters = 5_000
        let result = PlannerInputValidator.validate(input, mode: .base)
        XCTAssertTrue(result.states.contains(.invalidEnvironment))
    }

    func testDecoInvalidAltitudeFailsValidation() {
        var input = GasPlanInput()
        input.plannedDepthMeters = 30
        input.plannedBottomMinutes = 20
        input.altitudeMeters = 5_000
        let result = PlannerInputValidator.validate(input, mode: .deco)
        XCTAssertTrue(result.states.contains(.invalidEnvironment))
    }

    func testProfileDivergenceDetectedForDifferentDepthAtSameTimestamp() {
        let start = Date(timeIntervalSince1970: 1_000)
        let end = start.addingTimeInterval(120)
        let local = DiveSession(
            startDate: start,
            endDate: end,
            durationSeconds: 120,
            maxDepthMeters: 18,
            avgDepthMeters: 10,
            avgWaterTemperatureCelsius: nil,
            ttv: 1,
            entryGPS: nil,
            exitGPS: nil,
            samples: [
                DiveSample(timestamp: start, depthMeters: 0, temperatureCelsius: nil),
                DiveSample(timestamp: end, depthMeters: 18, temperatureCelsius: nil)
            ]
        )
        let cloud = DiveSession(
            id: local.id,
            startDate: start,
            endDate: end,
            durationSeconds: 120,
            maxDepthMeters: 22,
            avgDepthMeters: 11,
            avgWaterTemperatureCelsius: nil,
            ttv: 1,
            entryGPS: nil,
            exitGPS: nil,
            samples: [
                DiveSample(timestamp: start, depthMeters: 0, temperatureCelsius: nil),
                DiveSample(timestamp: end, depthMeters: 22, temperatureCelsius: nil)
            ]
        )
        XCTAssertTrue(DiveSessionProfileDivergence.profilesDiverge(local, cloud))
    }

    // MARK: - IOS-AUDIT-003 NDL environment tissue seeding

    func testPreviewNDLUsesEnvironmentSaturatedTissueAtAltitude() {
        let gas = GasMix(name: "Air", oxygen: 0.21, helium: 0, maxPPO2: 1.4)
        let sea = BuhlmannPlanner.plan(depthMeters: 30, bottomGas: gas, environment: .seaLevelSaltWater)
        guard case .success(let altitudeEnv) = PlannerEnvironment.make(altitudeMeters: 2_000, salinity: .salt) else {
            return XCTFail("Expected altitude environment")
        }
        let altitude = BuhlmannPlanner.plan(depthMeters: 30, bottomGas: gas, environment: altitudeEnv)
        XCTAssertNotEqual(sea.ndlMinutes, altitude.ndlMinutes)
    }

    func testPreviewNDLMatchesEngineNoDecompressionLimitWithEnvironmentTissue() {
        guard case .success(let environment) = PlannerEnvironment.make(altitudeMeters: 1_500, salinity: .fresh) else {
            return XCTFail("Expected environment")
        }
        let mix = GasMix(name: "Air", oxygen: 0.21, helium: 0, maxPPO2: 1.4)
        let gas = BuhlmannGas(gas: mix, role: .bottom, switchDepthMeters: 24)
        let tissue = BuhlmannTissueState.airSaturated(surfacePressureBar: environment.surfacePressureBar)
        let preview = BuhlmannPlanner.plan(depthMeters: 24, bottomGas: mix, environment: environment)
        let engineNDL = BuhlmannEngine.noDecompressionLimit(
            depthMeters: 24,
            gas: gas,
            gfHigh: 85,
            initialTissueState: tissue,
            plannerEnvironment: environment
        )
        XCTAssertEqual(preview.ndlMinutes, engineNDL ?? 0, accuracy: 0.1)
    }

    func testNDLCurveUsesEnvironmentTissueState() {
        guard case .success(let environment) = PlannerEnvironment.make(altitudeMeters: 2_000, salinity: .salt) else {
            return XCTFail("Expected environment")
        }
        let result = BuhlmannPlanner.plan(depthMeters: 30, bottomGas: GasMix(name: "EAN32", oxygen: 0.32, helium: 0, maxPPO2: 1.4), environment: environment)
        XCTAssertFalse(result.curve.isEmpty)
        XCTAssertGreaterThan(result.curve.first?.ndlMinutes ?? 0, 0)
    }

    // MARK: - IOS-AUDIT-004 ascent/deco preflight

    func testOxygenSwitchedTooDeepRejectedBeforeSchedule() {
        let request = BuhlmannTestSupport.request(
            depth: 40,
            bottomMinutes: 20,
            bottomGas: BuhlmannTestSupport.trimix1845(switchDepth: 40),
            decoGases: [BuhlmannTestSupport.oxygen(switchDepth: 12)]
        )
        let issues = BuhlmannPlanPreflightValidator.validate(request)
        XCTAssertTrue(issues.contains(where: {
            if case .gasSwitchTooDeep = $0 { return true }
            if case .ppo2Exceeded = $0 { return true }
            if case .gasNotOperationalInSegment = $0 { return true }
            return false
        }))
    }

    func testDuplicateGasLabelWithSameCompositionDoesNotFailPreflight() {
        let shared = BuhlmannGas(name: "Deco", role: .deco, oxygenFraction: 0.50, heliumFraction: 0, maxPPO2Bar: 1.6, switchDepthMeters: 21)
        let request = BuhlmannTestSupport.request(
            depth: 45,
            bottomMinutes: 20,
            bottomGas: BuhlmannTestSupport.trimix1845(switchDepth: 45),
            decoGases: [shared, BuhlmannGas(name: "Deco", role: .deco, oxygenFraction: 0.50, heliumFraction: 0, maxPPO2Bar: 1.6, switchDepthMeters: 6)]
        )
        XCTAssertTrue(BuhlmannPlanPreflightValidator.validate(request).isEmpty)
    }

    // MARK: - IOS-AUDIT-005 END/EAD environment conversion

    func testENDEADSeaLevelSaltwaterStable() {
        var input = GasPlanInput()
        input.plannedDepthMeters = 30
        input.bottomGas = GasMix(name: "EAN32", oxygen: 0.32, helium: 0, maxPPO2: 1.4)
        let analysis = GasPlanningService.analyze(input: input)
        XCTAssertGreaterThan(analysis.endMeters, 0)
        XCTAssertNotNil(analysis.eadMeters)
    }

    func testENDUsesAmbientPressureModelForConversion() {
        guard case .success(let fresh) = PlannerEnvironment.make(altitudeMeters: 0, salinity: .fresh) else {
            return XCTFail("Expected freshwater environment")
        }
        let mix = GasMix(name: "EAN32", oxygen: 0.32, helium: 0, maxPPO2: 1.4)
        let depth = 35.0
        let ambient = AmbientPressureModel.ambientPressureBar(depthMeters: depth, environment: fresh) ?? fresh.surfacePressureBar
        let narcoticFraction = mix.nitrogen + (mix.isOxygenNarcotic ? mix.oxygen : 0)
        let airNarcoticFraction = 0.79 + (mix.isOxygenNarcotic ? 0.21 : 0)
        let equivalentAmbient = ambient * narcoticFraction / max(airNarcoticFraction, 0.01)
        let modeledEND = AmbientPressureModel.depthMeters(ambientPressureBar: equivalentAmbient, environment: fresh) ?? 0
        let legacyApproximation = max(0, (equivalentAmbient - 1.0) * 10.0)
        var input = GasPlanInput()
        input.plannedDepthMeters = depth
        input.salinity = .fresh
        input.bottomGas = mix
        let analysis = GasPlanningService.analyze(input: input)
        XCTAssertEqual(analysis.endMeters, modeledEND, accuracy: 0.05)
        XCTAssertNotEqual(analysis.endMeters, legacyApproximation, accuracy: 0.05)
    }

    func testENDInvalidEquivalentPressureReturnsZero() {
        var input = GasPlanInput()
        input.plannedDepthMeters = 0
        input.bottomGas = GasMix(name: "Invalid", oxygen: 0, helium: 0, maxPPO2: 1.4)
        let analysis = GasPlanningService.analyze(input: input)
        XCTAssertEqual(analysis.endMeters, 0)
    }

    // MARK: - IOS-AUDIT-006 manual pressure units

    func testPressureEnteredInBarDisplaysConvertedInPSI() {
        let displayUnits = PressureDisplayMath.consumedPressureInDisplayUnits(entryBar: 200, exitBar: 50, units: .imperial)
        XCTAssertEqual(displayUnits ?? 0, IOSUnitConversions.psi(fromBar: 150), accuracy: 0.1)
        let consumed = PressureDisplayMath.consumedDisplay(entryBar: 200, exitBar: 50, units: .imperial)
        XCTAssertNotNil(consumed)
    }

    func testLegacyTextOnlyPressureInfersUnitSafely() {
        XCTAssertEqual(PressureDisplayMath.inferLegacyPressureUnit(entryText: "230 bar", exitText: "90 bar"), .bar)
        let consumed = PressureDisplayMath.consumedDisplay(
            entryText: "230 bar",
            exitText: "90 bar",
            entryBar: nil,
            exitBar: nil,
            units: .imperial
        )
        XCTAssertNotNil(consumed)
        let expected = IOSUnitConversions.psi(fromBar: 140)
        let entryBar = PressureDisplayMath.parsePressureBar(from: "230 bar", inputUnit: .bar) ?? 0
        let exitBar = PressureDisplayMath.parsePressureBar(from: "90 bar", inputUnit: .bar) ?? 0
        XCTAssertEqual(
            PressureDisplayMath.consumedPressureInDisplayUnits(entryBar: entryBar, exitBar: exitBar, units: .imperial) ?? 0,
            expected,
            accuracy: 0.1
        )
    }

    func testInvalidPressureStringsHandledSafely() {
        XCTAssertNil(PressureDisplayMath.consumedDisplay(
            entryText: "abc",
            exitText: "90",
            entryBar: nil,
            exitBar: nil,
            units: .metric
        ))
    }

    // MARK: - IOS-AUDIT-010 analysis arithmetic semantics

    func testAnalysisDashboardUsesArithmeticMeanAcrossSessions() {
        let s1 = makeSession(sac: 15, temp: 20, duration: 60)
        let s2 = makeSession(sac: 21, temp: 24, duration: 120)
        let summary = AnalysisDashboardMath.summary(from: [s1, s2])
        XCTAssertEqual(summary.averageSACLitersPerMinute ?? 0, 18, accuracy: 0.001)
        XCTAssertEqual(summary.averageWaterTemperatureCelsius ?? 0, 22, accuracy: 0.001)
    }

    // MARK: - IOS-AUDIT-011 high PPO2 warning dominance

    func testHighPPO2ScheduleSurfacesPPO2ExceededState() {
        var input = GasPlanInput()
        input.plannedDepthMeters = 40
        input.bottomGas = GasMix(name: "Air", oxygen: 0.21, helium: 0, maxPPO2: 1.0)
        let analysis = GasPlanningService.analyze(input: input)
        XCTAssertTrue(analysis.states.contains(.PPO2Exceeded))
        XCTAssertFalse(analysis.states == [.validReference, .nonCertifiedReference])
    }

    func testHighPPO2ExposureRemainsFinite() {
        var input = GasPlanInput()
        input.plannedDepthMeters = 35
        input.bottomGas = GasMix(name: "O2", oxygen: 1.0, helium: 0, maxPPO2: 1.6)
        let analysis = GasPlanningService.analyze(input: input)
        XCTAssertTrue(analysis.cnsPercent.isFinite)
        XCTAssertTrue(analysis.otu.isFinite)
        XCTAssertTrue(analysis.states.contains(.PPO2Exceeded))
    }

    // MARK: - IOS-AUDIT-009 Subsurface export regression

    func testSubsurfaceExportManualSessionMetadataAndMonotonicSeconds() throws {
        let start = Date(timeIntervalSince1970: 1_700_000)
        let end = start.addingTimeInterval(600)
        let session = DiveSession(
            startDate: start,
            endDate: end,
            durationSeconds: 600,
            maxDepthMeters: 18,
            avgDepthMeters: 12,
            avgWaterTemperatureCelsius: nil,
            ttv: 1.2,
            entryGPS: GPSPoint(latitude: 44.1, longitude: 8.9, horizontalAccuracy: 5, timestamp: start),
            exitGPS: nil,
            samples: [
                DiveSample(timestamp: start, depthMeters: 0, temperatureCelsius: nil),
                DiveSample(timestamp: start.addingTimeInterval(300), depthMeters: 18, temperatureCelsius: nil),
                DiveSample(timestamp: end, depthMeters: 0, temperatureCelsius: nil)
            ],
            siteName: "Test",
            isManual: true,
            equipmentUsed: "Twin 12",
            entryPressureText: "230 bar",
            exitPressureText: "80 bar",
            entryPressureBar: 230,
            exitPressureBar: 80
        )
        let csv = try XCTUnwrap(SubsurfaceExportService.makeCSV(for: session))
        XCTAssertTrue(csv.contains("# dirdiving_entry_pressure"))
        XCTAssertTrue(csv.contains("230 bar"))
        XCTAssertTrue(csv.contains(",,") == false || csv.contains("temperature_c"))
        let dataLines = csv.split(separator: "\n").filter { !$0.hasPrefix("#") && !$0.hasPrefix("time_seconds") && !$0.hasPrefix("session_meta") }
        var previous = -1
        for line in dataLines {
            let seconds = Int(line.split(separator: ",").first ?? "0") ?? 0
            XCTAssertGreaterThanOrEqual(seconds, previous)
            previous = seconds
        }
    }

    func testSubsurfaceExportRejectsEmptyProfile() {
        let empty = DiveSession(
            startDate: Date(),
            endDate: Date(),
            durationSeconds: 0,
            maxDepthMeters: 0,
            avgDepthMeters: 0,
            avgWaterTemperatureCelsius: nil,
            ttv: 0,
            entryGPS: nil,
            exitGPS: nil,
            samples: []
        )
        XCTAssertNil(SubsurfaceExportService.makeCSV(for: empty))
    }

    // MARK: - Helpers

    private func makeSession(sac: Double, temp: Double, duration: TimeInterval) -> DiveSession {
        let start = Date(timeIntervalSince1970: 1_000)
        let end = start.addingTimeInterval(duration)
        let samples = [
            DiveSample(timestamp: start, depthMeters: 0, temperatureCelsius: temp),
            DiveSample(timestamp: end, depthMeters: 18, temperatureCelsius: temp)
        ]
        let summary = DiveProfileMath.summary(samples: samples, startDate: start, endDate: end)
        return DiveSession(
            startDate: start,
            endDate: end,
            durationSeconds: summary.durationSeconds,
            maxDepthMeters: summary.maxDepthMeters,
            avgDepthMeters: summary.averageDepthMeters,
            avgWaterTemperatureCelsius: temp,
            ttv: summary.ttv,
            entryGPS: nil,
            exitGPS: nil,
            samples: samples,
            sacLitersMinute: sac
        )
    }
}
