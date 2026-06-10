import XCTest

final class PlannerTechnicalAverageDepthGasConsumptionTests: XCTestCase {
    func testDefaultIsConservativeOff() {
        let input = GasPlanInput()
        XCTAssertNil(input.usesAverageDepthForGasConsumption)
        XCTAssertFalse(input.averageDepthGasConsumptionEnabled)
        XCTAssertEqual(input.gasConsumptionReferenceDepthMeters(for: .technical), input.plannedDepthMeters, accuracy: 0.01)
    }

    func testTechnicalOffUsesMaxDepthForGasConsumption() {
        var input = GasPlanInput()
        input.plannedDepthMeters = 60
        input.plannedAverageDepthMeters = 30
        input.usesAverageDepthForGasConsumption = false
        input.ensurePlannerCylindersFromLegacy()

        XCTAssertEqual(input.gasConsumptionReferenceDepthMeters(for: .technical), 60, accuracy: 0.01)
    }

    func testTechnicalOnUsesAverageDepthForGasConsumption() {
        var input = GasPlanInput()
        input.plannedDepthMeters = 60
        input.plannedAverageDepthMeters = 30
        input.usesAverageDepthForGasConsumption = true
        input.ensurePlannerCylindersFromLegacy()

        XCTAssertEqual(input.gasConsumptionReferenceDepthMeters(for: .technical), 30, accuracy: 0.01)
    }

    func testDecompressionUnaffectedByAverageDepthGasToggle() {
        var offInput = BuhlmannTestSupport.gasPlanInput(depth: 55, bottomMinutes: 25)
        offInput.plannedAverageDepthMeters = 30
        offInput.usesAverageDepthForGasConsumption = false

        var onInput = offInput
        onInput.usesAverageDepthForGasConsumption = true

        let offPlan = PlannerService.makePlan(input: offInput, mode: .technical)
        let onPlan = PlannerService.makePlan(input: onInput, mode: .technical)

        XCTAssertEqual(offPlan.ttsMinutes, onPlan.ttsMinutes)
        XCTAssertEqual(offPlan.totalRuntimeMinutes, onPlan.totalRuntimeMinutes)
        XCTAssertEqual(offPlan.decoStops.count, onPlan.decoStops.count)
        zip(offPlan.decoStops, onPlan.decoStops).forEach { lhs, rhs in
            XCTAssertEqual(lhs.depthMeters, rhs.depthMeters, accuracy: 0.01)
            XCTAssertEqual(lhs.minutes, rhs.minutes)
            XCTAssertEqual(lhs.gas, rhs.gas)
        }

        let offAnalysis = GasPlanningService.analyze(input: offInput, mode: .technical)
        let onAnalysis = GasPlanningService.analyze(input: onInput, mode: .technical)
        XCTAssertGreaterThan(offAnalysis.consumptionLiters, onAnalysis.consumptionLiters)
    }

    func testTechnicalUIHasGasConsumptionToggleWithoutDecoToggle() throws {
        let source = try String(contentsOfFile: plannerViewSourcePath(), encoding: .utf8)
        XCTAssertTrue(source.contains("planner.technical.average_depth.gas_toggle"))
        XCTAssertTrue(source.contains("showsAverageDepthGasConsumptionToggle"))
        XCTAssertFalse(source.localizedCaseInsensitiveContains("average depth for deco"))
        XCTAssertFalse(source.localizedCaseInsensitiveContains("profondità media per la deco"))
    }

    func testBaseAndDecoDoNotExposeTechnicalGasToggle() {
        XCTAssertFalse(PlannerResultPresentation.presentation(for: .base).showsAverageDepthGasConsumptionToggle)
        XCTAssertFalse(PlannerResultPresentation.presentation(for: .deco).showsAverageDepthGasConsumptionToggle)
    }

    func testDecompressionSourcesDoNotReferenceGasConsumptionToggle() throws {
        let forbidden = [
            "usesAverageDepthForGasConsumption",
            "averageDepthGasConsumptionEnabled",
            "gasConsumptionReferenceDepthMeters"
        ]
        let sources = [
            "iOSApp/Services/BuhlmannPlanner.swift",
            "iOSApp/Services/PlannerService.swift",
            "iOSApp/Services/RepetitiveDivePlannerService.swift",
            "iOSApp/Services/PlannerAscentTableBuilder.swift",
            "iOSApp/Services/OxygenExposureModels.swift",
            "iOSApp/Services/CCR/CCRPlannerEngine.swift"
        ]
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .path

        for relativePath in sources {
            let source = try String(contentsOfFile: root + "/" + relativePath, encoding: .utf8)
            for token in forbidden {
                XCTAssertFalse(source.contains(token), "\(relativePath) must not reference \(token)")
            }
        }
    }

    func testPersistenceDecodesMissingToggleAsFalse() throws {
        var object = try JSONSerialization.jsonObject(with: JSONEncoder().encode(GasPlanInput())) as? [String: Any] ?? [:]
        object.removeValue(forKey: "usesAverageDepthForGasConsumption")
        object["plannedAverageDepthMeters"] = 28
        let data = try JSONSerialization.data(withJSONObject: object)
        let decoded = try JSONDecoder().decode(GasPlanInput.self, from: data)
        XCTAssertNil(decoded.usesAverageDepthForGasConsumption)
        XCTAssertFalse(decoded.averageDepthGasConsumptionEnabled)
        XCTAssertEqual(decoded.plannedAverageDepthMeters, 28, accuracy: 0.01)
    }

    private func plannerViewSourcePath() -> String {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("iOSApp/Views/PlannerView.swift")
            .path
    }
}
