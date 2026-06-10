import XCTest

final class PlannerAverageDepthPolicyTests: XCTestCase {
    func testPresentationPolicyHidesAverageDepthInBaseAndDeco() {
        XCTAssertFalse(PlannerResultPresentation.presentation(for: .base).showsAverageDepthInput)
        XCTAssertFalse(PlannerResultPresentation.presentation(for: .deco).showsAverageDepthInput)
    }

    func testPresentationPolicyShowsAverageDepthInTechnicalOnlyForOCProfileCard() {
        XCTAssertFalse(PlannerResultPresentation.presentation(for: .technical).showsAverageDepthInput)
        XCTAssertTrue(PlannerResultPresentation.presentation(for: .technical).showsAverageDepthGasConsumptionToggle)
        XCTAssertFalse(PlannerResultPresentation.presentation(for: .ccr).showsAverageDepthGasConsumptionToggle)
    }

    func testDecoActiveInputUsesMaxDepthForConsumptionReference() {
        var input = GasPlanInput()
        input.plannedDepthMeters = 40
        input.plannedAverageDepthMeters = 20
        input.planningDepthReference = .averageDepth
        input.ensurePlannerCylindersFromLegacy()

        let active = PlannerModePolicy.activePlanInput(from: input, mode: .deco)

        XCTAssertEqual(active.plannedAverageDepthMeters, 40, accuracy: 0.01)
        XCTAssertEqual(active.planningDepthReference, .maximumDepth)
        XCTAssertEqual(active.effectivePlanningDepthMeters, 40, accuracy: 0.01)
    }

    func testTechnicalActiveInputUsesAverageDepthOnlyWhenToggleEnabled() {
        var input = GasPlanInput()
        input.plannedDepthMeters = 60
        input.plannedAverageDepthMeters = 35
        input.planningDepthReference = .averageDepth
        input.usesAverageDepthForGasConsumption = true
        input.ensurePlannerCylindersFromLegacy()

        let active = PlannerModePolicy.activePlanInput(from: input, mode: .technical)

        XCTAssertEqual(active.gasConsumptionReferenceDepthMeters(for: .technical), 35, accuracy: 0.01)
        XCTAssertEqual(active.effectivePlanningDepthMeters, 35, accuracy: 0.01)
    }

    func testTechnicalActiveInputUsesMaxDepthWhenToggleDisabled() {
        var input = GasPlanInput()
        input.plannedDepthMeters = 60
        input.plannedAverageDepthMeters = 35
        input.planningDepthReference = .averageDepth
        input.usesAverageDepthForGasConsumption = false
        input.ensurePlannerCylindersFromLegacy()

        let active = PlannerModePolicy.activePlanInput(from: input, mode: .technical)

        XCTAssertEqual(active.gasConsumptionReferenceDepthMeters(for: .technical), 60, accuracy: 0.01)
        XCTAssertEqual(active.effectivePlanningDepthMeters, 60, accuracy: 0.01)
    }

    func testDecoGasConsumptionUsesConservativeMaxDepthDespiteStaleDraftAverage() {
        var input = GasPlanInput()
        input.plannedDepthMeters = 40
        input.plannedAverageDepthMeters = 20
        input.planningDepthReference = .averageDepth
        input.ensurePlannerCylindersFromLegacy()
        if let index = input.plannerCylinders.firstIndex(where: { $0.role == .bottom }) {
            input.plannerCylinders[index].gas = GasMix(name: "Air", mixKind: .air, oxygen: 0.21, helium: 0, maxPPO2: 1.4)
        }

        let conservative = GasPlanningService.analyze(input: input, mode: .deco)

        var maxReference = input
        maxReference.plannedAverageDepthMeters = 40
        maxReference.planningDepthReference = .maximumDepth
        let explicitMax = GasPlanningService.analyze(input: maxReference, mode: .deco)

        XCTAssertEqual(conservative.consumptionLiters, explicitMax.consumptionLiters, accuracy: 0.01)
        XCTAssertGreaterThan(conservative.consumptionLiters, 0)
    }

    func testDecompressionSourcesDoNotReferenceAverageDepthFields() throws {
        let forbidden = ["averageDepthMeters", "plannedAverageDepthMeters", "avgDepth", "meanDepth"]
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
                XCTAssertFalse(
                    source.contains(token),
                    "\(relativePath) must not reference \(token) in decompression paths"
                )
            }
        }
    }

    func testPlannerViewUsesAverageDepthPolicyGuard() throws {
        let source = try String(contentsOfFile: plannerViewSourcePath(), encoding: .utf8)
        XCTAssertTrue(source.contains("showsAverageDepthGasConsumptionToggle"))
        XCTAssertTrue(source.contains("planner.technical.average_depth.gas_toggle"))
        guard let policyRange = source.range(of: "if modePresentation.showsAverageDepthGasConsumptionToggle"),
              let avgDepthRange = source.range(of: "planner.field.avg_depth") else {
            return XCTFail("Expected average depth UI guarded by technical gas toggle")
        }
        XCTAssertLessThan(policyRange.lowerBound, avgDepthRange.lowerBound)
    }

    func testPlannerViewStillShowsAverageDepthForTechnicalViaPolicy() throws {
        let source = try String(contentsOfFile: plannerViewSourcePath(), encoding: .utf8)
        XCTAssertTrue(source.contains("planner.field.avg_depth"))
        XCTAssertTrue(source.contains("averageDepthGasConsumptionEnabled"))
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
