import XCTest

final class ContingencyEngineTests: XCTestCase {
    func testContingencyPlansUseEngineDerivedTTS() throws {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 42, bottomMinutes: 25)
        input.bottomGas = GasMix(name: "EAN32", role: .bottom, oxygen: 0.32, helium: 0, maxPPO2: 1.4)
        guard case .success(let environment) = PlannerEnvironment.make(altitudeMeters: 0, salinity: .salt) else {
            return XCTFail("Expected environment")
        }

        let baseRequest = BuhlmannPlanner.makeRequest(input: input, environment: environment)
        let baseEngine = BuhlmannEngine.plan(baseRequest)
        let analysis = GasPlanningService.analyze(input: input, enginePlan: baseEngine)
        let contingencies = GasPlanningService.contingencyPlans(
            input: input,
            baseAnalysis: analysis,
            baseTTS: baseEngine.ttsMinutes,
            environment: environment
        )

        XCTAssertEqual(contingencies.count, 3)

        var delayed = baseRequest
        delayed.bottomMinutes += 5
        let delayedTTS = BuhlmannEngine.plan(delayed).ttsMinutes
        XCTAssertEqual(contingencies.first(where: { $0.scenario == .delayedAscent })?.ttsMinutes, delayedTTS)

        var extended = baseRequest
        extended.bottomMinutes += 10
        var deeper = baseRequest
        deeper.maxDepthMeters += 3
        let sourceBottom = deeper.bottomGas
        deeper.bottomGas = BuhlmannGas(
            name: sourceBottom.name,
            role: sourceBottom.role,
            oxygenFraction: sourceBottom.oxygenFraction,
            heliumFraction: sourceBottom.heliumFraction,
            maxPPO2Bar: sourceBottom.maxPPO2Bar,
            switchDepthMeters: deeper.maxDepthMeters,
            gasMixId: sourceBottom.gasMixId,
            cylinderId: sourceBottom.cylinderId
        )
        let stressTTS = max(BuhlmannEngine.plan(extended).ttsMinutes, BuhlmannEngine.plan(deeper).ttsMinutes)
        XCTAssertEqual(contingencies.first(where: { $0.scenario == .extendedBottom })?.ttsMinutes, stressTTS)
    }

    func testLostGasContingencyUsesRockBottomLiters() throws {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 35, bottomMinutes: 20)
        input.bottomGas = GasMix(name: "Air", role: .bottom, oxygen: 0.21, helium: 0, maxPPO2: 1.4)
        guard case .success(let environment) = PlannerEnvironment.make(altitudeMeters: 0, salinity: .salt) else {
            return XCTFail("Expected environment")
        }
        let engine = BuhlmannEngine.plan(BuhlmannPlanner.makeRequest(input: input, environment: environment))
        let analysis = GasPlanningService.analyze(input: input, enginePlan: engine)
        let contingencies = GasPlanningService.contingencyPlans(
            input: input,
            baseAnalysis: analysis,
            baseTTS: engine.ttsMinutes,
            environment: environment
        )
        let lostGas = try XCTUnwrap(contingencies.first(where: { $0.scenario == .lostGas }))
        XCTAssertEqual(lostGas.gasRequiredLiters, analysis.rockBottomLiters, accuracy: 0.01)
    }
}
