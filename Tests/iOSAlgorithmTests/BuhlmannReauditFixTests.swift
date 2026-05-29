import XCTest

final class BuhlmannReauditFixTests: XCTestCase {
    func testNDLChangesWithEnvironment() throws {
        let sea = PlannerEnvironment.seaLevelSaltWater
        guard case .success(let fresh) = PlannerEnvironment.make(altitudeMeters: 0, salinity: .fresh),
              case .success(let altitudeFresh) = PlannerEnvironment.make(altitudeMeters: 1_500, salinity: .fresh),
              case .success(let altitudeSalt) = PlannerEnvironment.make(altitudeMeters: 1_500, salinity: .salt) else {
            return XCTFail("Expected valid environments")
        }
        let gas = BuhlmannTestSupport.air(switchDepth: 30)
        let ndlSea = BuhlmannEngine.noDecompressionLimit(depthMeters: 30, gas: gas, gfHigh: 85, plannerEnvironment: sea)
        let ndlFresh = BuhlmannEngine.noDecompressionLimit(depthMeters: 30, gas: gas, gfHigh: 85, plannerEnvironment: fresh)
        let ndlAltitudeSalt = BuhlmannEngine.noDecompressionLimit(depthMeters: 30, gas: gas, gfHigh: 85, plannerEnvironment: altitudeSalt)
        let ndlAltitudeFresh = BuhlmannEngine.noDecompressionLimit(depthMeters: 30, gas: gas, gfHigh: 85, plannerEnvironment: altitudeFresh)

        XCTAssertNotNil(ndlSea)
        XCTAssertNotNil(ndlFresh)
        XCTAssertNotNil(ndlAltitudeSalt)
        XCTAssertNotNil(ndlAltitudeFresh)
        XCTAssertNotEqual(ndlSea, ndlFresh)
        XCTAssertNotEqual(ndlAltitudeSalt, ndlAltitudeFresh)
    }

    func testDuplicateGasLabelsDoNotCrashLedger() throws {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 40, bottomMinutes: 20)
        let sharedMix = GasMix(name: "EAN50", role: .deco, oxygen: 0.50, helium: 0, maxPPO2: 1.6)
        let first = PlannerCylinderEntry(role: .deco, tankSize: .liters12, gas: sharedMix, switchDepthMeters: 21)
        var second = PlannerCylinderEntry(role: .deco, tankSize: .liters12, gas: sharedMix, switchDepthMeters: 21)
        second.gas = GasMix(id: UUID(), name: "EAN50 backup", role: .deco, oxygen: 0.50, helium: 0, maxPPO2: 1.6)
        input.plannerCylinders.append(first)
        input.plannerCylinders.append(second)

        let plan = PlannerService.makePlan(input: input)
        XCTAssertFalse(plan.states.contains(.gasAllocationIncomplete))
        XCTAssertGreaterThan(plan.gasAnalysis.remainingBar, 0)
    }

    func testRepetitivePlanningUsesCanonicalEngineResult() throws {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 30, bottomMinutes: 18)
        input.bottomGas = GasMix(name: "Air", role: .bottom, oxygen: 0.21, helium: 0, maxPPO2: 1.4)
        input.plannerCylinders = [
            PlannerCylinderEntry(role: .bottom, tankSize: .liters12, gas: input.bottomGas, startPressure: 230, reservePressure: 50, pressureUnit: .bar)
        ]

        let clean = PlannerService.makePlan(input: input)
        guard case .success(let environment) = PlannerEnvironment.make(altitudeMeters: input.altitudeMeters, salinity: input.salinity) else {
            return XCTFail("Expected valid environment")
        }
        let baseRequest = BuhlmannPlanner.makeRequest(input: input, environment: environment)
        let firstEngine = BuhlmannEngine.plan(baseRequest)
        guard let snapshot = RepetitiveDivePlannerService.makeSnapshot(from: firstEngine, environment: environment) else {
            return XCTFail("Expected tissue snapshot")
        }

        let repetitive = PlannerService.makePlan(input: input, repetitiveSnapshot: snapshot, surfaceIntervalMinutes: 45)
        XCTAssertGreaterThanOrEqual(repetitive.ndlMinutes, 0)
        XCTAssertLessThan(repetitive.ndlMinutes, 999)
        if let cleanNDL = Optional(clean.ndlMinutes), cleanNDL > 0, repetitive.ndlMinutes > 0 {
            XCTAssertLessThanOrEqual(repetitive.ndlMinutes, cleanNDL + 0.1)
        }
    }

    func testSurfaceIntervalOffGassingUsesEnvironment() throws {
        guard case .success(let sea) = PlannerEnvironment.make(altitudeMeters: 0, salinity: .salt),
              case .success(let altitude) = PlannerEnvironment.make(altitudeMeters: 1_500, salinity: .salt) else {
            return XCTFail("Expected valid environments")
        }
        let loaded = BuhlmannTissueState.airSaturated(surfacePressureBar: sea.surfacePressureBar)
            .loadedConstantDepth(depthMeters: 30, minutes: 20, gas: BuhlmannTestSupport.air(switchDepth: 30), environment: sea)
        let interval = SurfaceIntervalModel(minutes: 60)
        let offSea = interval.offGas(loaded, environment: sea)!
        let offAltitude = interval.offGas(loaded, environment: altitude)!
        XCTAssertNotEqual(offSea, offAltitude)
    }

    func testRockBottomUsesEnvironment() throws {
        guard case .success(let sea) = PlannerEnvironment.make(altitudeMeters: 0, salinity: .salt),
              case .success(let altitude) = PlannerEnvironment.make(altitudeMeters: 1_500, salinity: .salt) else {
            return XCTFail("Expected valid environments")
        }
        let input = BuhlmannTestSupport.gasPlanInput()
        let seaRock = ScheduleGasConsumptionService.rockBottomLiters(input: input, environment: sea)
        let altitudeRock = ScheduleGasConsumptionService.rockBottomLiters(input: input, environment: altitude)
        XCTAssertLessThan(altitudeRock, seaRock)
    }

    func testOxygenExposureValidationAndMonotonicity() throws {
        let environment = PlannerEnvironment.seaLevelSaltWater
        let low = BuhlmannRuntimeSegment(kind: .bottom, depthMeters: 18, minutes: 20, gas: BuhlmannTestSupport.air(switchDepth: 18), note: "bottom")
        let deco = BuhlmannRuntimeSegment(kind: .stop, depthMeters: 6, minutes: 10, gas: BuhlmannTestSupport.ean50(), note: "stop")
        let o2 = BuhlmannRuntimeSegment(kind: .stop, depthMeters: 6, minutes: 8, gas: BuhlmannTestSupport.oxygen(), note: "o2")

        switch OxygenExposureModel.from(segments: [low], environment: environment) {
        case .success(let lowExposure):
            switch OxygenExposureModel.from(segments: [low, deco, o2], environment: environment) {
            case .success(let fullExposure):
                XCTAssertGreaterThan(fullExposure.cnsPercent, lowExposure.cnsPercent)
                XCTAssertGreaterThan(fullExposure.otu, lowExposure.otu)
            case .failure:
                XCTFail("Expected full exposure")
            }
        case .failure:
            XCTFail("Expected low exposure")
        }

        let invalid = BuhlmannRuntimeSegment(kind: .bottom, depthMeters: .nan, minutes: 10, gas: BuhlmannTestSupport.air(), note: "invalid")
        if case .success = OxygenExposureModel.from(segments: [invalid], environment: environment) {
            XCTFail("Expected invalid exposure to fail closed")
        }
    }

    func testGFComparisonsShareSeededTissueState() throws {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 45, bottomMinutes: 20)
        guard case .success(let environment) = PlannerEnvironment.make(altitudeMeters: input.altitudeMeters, salinity: input.salinity) else {
            return XCTFail("Expected valid environment")
        }
        var base = BuhlmannPlanner.makeRequest(input: input, environment: environment)
        base.initialTissueState = BuhlmannTissueState.airSaturated(surfacePressureBar: environment.surfacePressureBar)
            .loadedConstantDepth(depthMeters: 20, minutes: 30, gas: base.bottomGas, environment: environment)
        let comparisons = BuhlmannPlanner.gfComparisons(baseRequest: base)
        XCTAssertEqual(comparisons.count, 4)
        XCTAssertGreaterThan(comparisons[0].ttsMinutes, 0)
    }
}
