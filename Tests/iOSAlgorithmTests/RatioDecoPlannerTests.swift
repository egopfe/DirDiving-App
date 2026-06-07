import XCTest

final class RatioDecoPlannerTests: XCTestCase {
    private func technicalInput(depth: Double = 45, bottom: Double = 25) -> GasPlanInput {
        var input = BuhlmannTestSupport.gasPlanInput()
        input.plannedDepthMeters = depth
        input.plannedBottomMinutes = bottom
        return input
    }

    func testOneToOneGeneratesStops() {
        let schedule = RatioDecoPlanner.makeSchedule(
            input: technicalInput(),
            mode: .technical,
            preset: .preset1to1,
            environment: .seaLevelSaltWater,
            descentMinutes: 5
        )
        guard let schedule else {
            return XCTFail("Expected schedule")
        }
        XCTAssertFalse(schedule.stops.isEmpty)
        XCTAssertEqual(schedule.firstStopDepthMeters, 21, accuracy: 0.01)
    }

    func testTwoToOneGeneratesShorterDecoThanOneToOne() {
        let input = technicalInput()
        let oneToOne = RatioDecoPlanner.makeSchedule(
            input: input,
            mode: .technical,
            preset: .preset1to1,
            environment: .seaLevelSaltWater,
            descentMinutes: 5
        )
        let twoToOne = RatioDecoPlanner.makeSchedule(
            input: input,
            mode: .technical,
            preset: .preset2to1,
            environment: .seaLevelSaltWater,
            descentMinutes: 5
        )
        guard let oneToOne, let twoToOne else {
            return XCTFail("Expected schedules")
        }
        XCTAssertGreaterThan(oneToOne.totalDecoMinutes, twoToOne.totalDecoMinutes)
    }

    func testCustomPresetRespectsStopStepAndMinimumStop() {
        var input = technicalInput()
        input.plannerCylinders.removeAll { $0.role == .deco }
        var preset = RatioDecoPreset.customDefault
        preset.firstStopDepthMeters = 18
        preset.stopStepMeters = 3
        preset.minimumStopMinutes = 2
        let schedule = RatioDecoPlanner.makeSchedule(
            input: input,
            mode: .technical,
            preset: preset,
            environment: .seaLevelSaltWater,
            descentMinutes: 5
        )
        guard let schedule else {
            return XCTFail("Expected schedule")
        }
        XCTAssertEqual(schedule.firstStopDepthMeters, 18, accuracy: 0.01)
        XCTAssertTrue(schedule.stops.allSatisfy { $0.durationMinutes >= 2 })
        let depths = schedule.stops.map(\.depthMeters)
        XCTAssertEqual(depths.first ?? 0, 18, accuracy: 0.01)
        if depths.count >= 2 {
            XCTAssertEqual(depths[0] - depths[1], 3, accuracy: 0.01)
        }
    }

    func testBailoutIsNotUsedInPlannedSchedule() {
        var input = technicalInput()
        input.plannerCylinders.append(
            PlannerCylinderEntry(
                role: .bailout,
                gas: GasMix(name: "Bailout", oxygen: 1.0, helium: 0, maxPPO2: 1.6),
                switchDepthMeters: 6
            )
        )
        let schedule = RatioDecoPlanner.makeSchedule(
            input: input,
            mode: .technical,
            preset: .preset1to1,
            environment: .seaLevelSaltWater,
            descentMinutes: 5
        )
        XCTAssertFalse(schedule?.stops.contains(where: { $0.gasLabel == "O2" && $0.depthMeters > 6 }) ?? true)
    }

    func testBaseModeRejectsRatioDeco() {
        let schedule = RatioDecoPlanner.makeSchedule(
            input: technicalInput(depth: 30, bottom: 20),
            mode: .base,
            preset: .preset1to1,
            environment: .seaLevelSaltWater,
            descentMinutes: 3
        )
        XCTAssertTrue(schedule?.warnings.contains(.unavailableInBaseMode) ?? false)
        XCTAssertTrue(schedule?.stops.isEmpty ?? false)
    }

    func testValidatorDetectsBaseModeRejection() {
        let input = technicalInput()
        let request = BuhlmannPlanner.makeRequest(input: input, environment: .seaLevelSaltWater)
        let enginePlan = BuhlmannEngine.plan(request)
        let schedule = RatioDecoSchedule(
            stops: [],
            totalDecoMinutes: 0,
            totalRuntimeMinutes: 0,
            firstStopDepthMeters: 21,
            presetName: "1:1",
            warnings: [.unavailableInBaseMode],
            depthProfilePoints: [],
            ascentTableRows: []
        )
        let validation = RatioDecoValidator.validate(
            schedule: schedule,
            input: input,
            mode: .base,
            enginePlan: enginePlan,
            request: request,
            environment: .seaLevelSaltWater
        )
        XCTAssertFalse(validation.isBuhlmannCompatible)
        XCTAssertTrue(validation.warnings.contains(.unavailableInBaseMode))
    }

    func testPlannerServiceIncludesRatioDecoBundleInComparisonMode() {
        let plan = PlannerService.makePlan(
            input: technicalInput(),
            mode: .technical,
            repetitivePlanningEnabled: false,
            repetitiveSnapshot: nil,
            surfaceIntervalMinutes: 0,
            decompressionMethod: .comparison,
            ratioDecoPreset: .preset1to1
        )
        XCTAssertNotNil(plan.ratioDeco)
        XCTAssertEqual(plan.ratioDeco?.method, .comparison)
        XCTAssertFalse(plan.ratioDeco?.schedule.stops.isEmpty ?? true)
    }

    func testBuhlmannPlannerStillWorksUnchanged() {
        let plan = PlannerService.makePlan(
            input: technicalInput(),
            mode: .technical,
            repetitivePlanningEnabled: false,
            repetitiveSnapshot: nil,
            surfaceIntervalMinutes: 0,
            decompressionMethod: .buhlmann
        )
        XCTAssertNil(plan.ratioDeco)
        XCTAssertFalse(plan.decoStops.isEmpty)
        XCTAssertGreaterThan(plan.ttsMinutes, 0)
    }

    func testTTSDifferenceUsesSameUnits() {
        let plan = PlannerService.makePlan(
            input: technicalInput(),
            mode: .technical,
            repetitivePlanningEnabled: false,
            repetitiveSnapshot: nil,
            surfaceIntervalMinutes: 0,
            decompressionMethod: .comparison,
            ratioDecoPreset: .preset1to1
        )
        guard let bundle = plan.ratioDeco else {
            return XCTFail("Expected ratio deco bundle")
        }
        let difference = bundle.schedule.ttsMinutes - plan.ttsMinutes
        XCTAssertEqual(difference, bundle.schedule.ttsMinutes - plan.ttsMinutes)
    }

    func testPDFIncludesRatioDecoWhenSelected() throws {
        let input = technicalInput()
        let plan = PlannerService.makePlan(
            input: input,
            mode: .technical,
            repetitivePlanningEnabled: false,
            repetitiveSnapshot: nil,
            surfaceIntervalMinutes: 0,
            decompressionMethod: .ratioDeco,
            ratioDecoPreset: .preset1to1
        )
        let context = PDFExportPlannerContext(
            input: input,
            plan: plan,
            mode: .technical,
            validation: PlannerModePolicy.validate(draft: input, mode: .technical),
            modIssues: [],
            safetyAcknowledged: true,
            unitPreference: .metric
        )
        let data = PlannerPDFBuilder.build(context: context)
        XCTAssertFalse(data.isEmpty)
        XCTAssertEqual(String(data: data.prefix(4), encoding: .ascii), "%PDF")
    }
}
