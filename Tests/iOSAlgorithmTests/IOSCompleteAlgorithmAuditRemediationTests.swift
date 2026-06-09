import XCTest

/// Regression coverage for `Docs/IOS_MAIN_COMPLETE_ALGORITHM_AUDIT_CURRENT.md` remediation.
final class IOSCompleteAlgorithmAuditRemediationTests: XCTestCase {
    func testCCRChecklistExportCoordinatorPromptRequiresValidPlan() {
        var input = CCRPlanInput.default
        input.bailoutGases = [CCRBailoutGas(mixKind: .ean, oxygenPercent: 32)]
        let emptyChecklist: [EquipmentChecklistItem] = []
        XCTAssertTrue(
            CCRChecklistExportCoordinator.shouldPromptExport(
                input: input,
                checklist: emptyChecklist,
                planIsValid: true
            )
        )
        XCTAssertFalse(
            CCRChecklistExportCoordinator.shouldPromptExport(
                input: input,
                checklist: emptyChecklist,
                planIsValid: false
            )
        )
    }

    func testCCRChecklistExportProducesDiluentAndBailoutRoles() {
        var input = CCRPlanInput.default
        input.diluent = CCRDiluent(mixKind: .ean, oxygenPercent: 32, heliumPercent: 0)
        input.bailoutGases = [CCRBailoutGas(mixKind: .oxygen, switchDepthMeters: 6)]
        let items = ChecklistPlannerSyncMapper.ccrChecklistItems(from: input)
        XCTAssertEqual(items.filter { $0.gasRole == .ccrDiluent }.count, 1)
        XCTAssertEqual(items.filter { $0.gasRole == .ccrBailout }.count, 1)
        XCTAssertFalse(items.contains { $0.gasRole == .bottom || $0.gasRole == .bailout })
    }

    func testCCRChecklistExportAllUsesCCRMapperNotOCCylinders() {
        var input = CCRPlanInput.default
        input.bailoutGases = [CCRBailoutGas(mixKind: .air, switchDepthMeters: 0)]
        var checklist: [EquipmentChecklistItem] = []
        CCRChecklistExportCoordinator.exportAll(input: input, to: &checklist)
        XCTAssertTrue(checklist.contains { $0.gasRole == .ccrDiluent })
        XCTAssertTrue(checklist.contains { $0.gasRole == .ccrBailout })
        XCTAssertFalse(checklist.contains { $0.gasRole == .bottom })
    }

    func testCCRChecklistExportDedupesMatchingDiluentLabel() {
        var input = CCRPlanInput.default
        input.diluent = .air
        var checklist: [EquipmentChecklistItem] = [
            EquipmentChecklistItem(
                title: "Existing diluent",
                isReady: true,
                usesGas: true,
                gasText: "AIR",
                gasRole: .ccrDiluent
            )
        ]
        CCRChecklistExportCoordinator.exportAll(input: input, to: &checklist)
        XCTAssertEqual(checklist.filter { $0.gasRole == .ccrDiluent }.count, 1)
        XCTAssertTrue(checklist[0].isReady)
    }

    func testCCRChecklistSelectedExportSkipsDeselectedItems() {
        var input = CCRPlanInput.default
        input.bailoutGases = [
            CCRBailoutGas(mixKind: .air, switchDepthMeters: 0),
            CCRBailoutGas(mixKind: .oxygen, switchDepthMeters: 6)
        ]
        var candidates = ChecklistPlannerSyncMapper.ccrExportCandidates(input: input, checklist: [])
        XCTAssertEqual(candidates.count, 3)
        candidates[2].isSelected = false
        var checklist: [EquipmentChecklistItem] = []
        CCRChecklistExportCoordinator.exportSelected(candidates: candidates, to: &checklist)
        XCTAssertEqual(checklist.filter { $0.gasRole == .ccrBailout }.count, 1)
    }

    func testLoopVolumeLitersDoesNotAlterCCRPlanMath() {
        var baseline = CCRPlanInput.default
        baseline.bailoutGases = [CCRBailoutGas()]
        var withLoopVolume = baseline
        withLoopVolume.loopVolumeLiters = 5.5
        let basePlan = CCRPlannerService.makePlan(input: baseline)
        let loopPlan = CCRPlannerService.makePlan(input: withLoopVolume)
        XCTAssertEqual(basePlan.ttsMinutes, loopPlan.ttsMinutes)
        XCTAssertEqual(basePlan.cnsFullPlanPercent, loopPlan.cnsFullPlanPercent, accuracy: 0.01)
        XCTAssertEqual(basePlan.schedule.count, loopPlan.schedule.count)
    }

    func testLongOCTechnicalProfileProducesFinitePlan() {
        var input = GasPlanInput()
        input.ensurePlannerCylindersFromLegacy()
        input.plannedDepthMeters = 55
        input.plannedBottomMinutes = 25
        input.gfLow = 30
        input.gfHigh = 70
        let active = PlannerModePolicy.activePlanInput(from: input, mode: .technical)
        let plan = BuhlmannPlanner.enginePlan(input: active)
        let stops = BuhlmannPlanner.decoStops(from: plan)
        XCTAssertGreaterThan(plan.ttsMinutes, 0)
        XCTAssertFalse(stops.isEmpty)
        for stop in stops {
            XCTAssertTrue(stop.depthMeters.isFinite)
            XCTAssertFalse(stop.depthMeters.isNaN)
            XCTAssertGreaterThanOrEqual(stop.minutes, 0)
        }
    }

    func testLongCCRProfileProducesFiniteOutputs() {
        var input = CCRPlanInput.default
        input.maxDepthMeters = 60
        input.bottomTimeMinutes = 40
        input.bailoutGases = [
            CCRBailoutGas(mixKind: .ean, oxygenPercent: 32, switchDepthMeters: 0),
            CCRBailoutGas(mixKind: .oxygen, switchDepthMeters: 6),
            CCRBailoutGas(mixKind: .trimix, oxygenPercent: 18, heliumPercent: 45, switchDepthMeters: 21)
        ]
        let plan = CCRPlannerService.makePlan(input: input)
        XCTAssertGreaterThan(plan.ttsMinutes, 0)
        XCTAssertTrue(plan.cnsFullPlanPercent.isFinite)
        XCTAssertFalse(plan.depthProfilePoints.isEmpty)
        for point in plan.depthProfilePoints {
            XCTAssertTrue(point.depthMeters.isFinite)
        }
        for scenario in plan.bailoutScenarios {
            XCTAssertTrue(scenario.isHeuristic)
        }
    }

    func testCCRPlannerUsesDedicatedPDFExportPathNotOCDivePack() {
        var input = CCRPlanInput.default
        input.bailoutGases = [CCRBailoutGas()]
        let plan = CCRPlannerService.makePlan(input: input)
        let context = PDFExportCCRPlannerContext(
            input: input,
            plan: plan,
            safetyAcknowledged: true,
            unitPreference: .metric
        )
        XCTAssertTrue(PDFExportService.canExportCCRPlan(context))
    }

    func testRatioDecoRemainsUnavailableInCCRMode() {
        let schedule = RatioDecoPlanner.makeSchedule(
            input: GasPlanInput(),
            mode: .ccr,
            preset: .preset1to1,
            environment: .seaLevelSaltWater,
            descentMinutes: 2
        )
        XCTAssertEqual(schedule?.warnings, [.unavailableInCCRMode])
    }
}

final class SubsurfaceExportServiceRemediationTests: XCTestCase {
    func testOCExportOmitsCCRMetadataKeys() throws {
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        let session = DiveSession(
            startDate: start,
            endDate: start.addingTimeInterval(600),
            durationSeconds: 600,
            maxDepthMeters: 30,
            avgDepthMeters: 22,
            avgWaterTemperatureCelsius: 19,
            ttv: 40,
            entryGPS: nil,
            exitGPS: nil,
            samples: [
                DiveSample(timestamp: start, depthMeters: 10, temperatureCelsius: 20),
                DiveSample(timestamp: start.addingTimeInterval(300), depthMeters: 28, temperatureCelsius: 18)
            ],
            gasLabel: .oc
        )
        let csv = try XCTUnwrap(SubsurfaceExportService.makeCSV(for: session))
        let lower = csv.lowercased()
        XCTAssertFalse(lower.contains("dirdiving_ccr"))
        XCTAssertTrue(lower.contains("time_seconds,depth_m"))
    }

    func testCCRExportIncludesMetadataOnlyWhenCCRLogbookPresent() throws {
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        let session = DiveSession(
            startDate: start,
            endDate: start.addingTimeInterval(300),
            durationSeconds: 300,
            maxDepthMeters: 35,
            avgDepthMeters: 28,
            avgWaterTemperatureCelsius: nil,
            ttv: 35,
            entryGPS: nil,
            exitGPS: nil,
            samples: [DiveSample(timestamp: start, depthMeters: 30, temperatureCelsius: nil)],
            gasLabel: .ccr,
            ccrLogbookMetadata: CCRLogbookMetadata(
                rebreatherModel: "Test CCR",
                lowSetpoint: 0.7,
                highSetpoint: 1.3,
                setpointSwitchDepthMeters: 20,
                diluentLabel: "AIR",
                bailoutLabels: ["EAN32"]
            )
        )
        let csv = try XCTUnwrap(SubsurfaceExportService.makeCSV(for: session))
        XCTAssertTrue(csv.contains("dirdiving_ccr_rebreather_model"))
        XCTAssertTrue(csv.contains("dirdiving_ccr_low_setpoint"))
        XCTAssertFalse(csv.contains("certified"))
        XCTAssertFalse(csv.contains("life-support"))
    }

    func testExportTimeSecondsMonotonicFromFirstSample() throws {
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        let session = DiveSession(
            startDate: start,
            endDate: start.addingTimeInterval(120),
            durationSeconds: 120,
            maxDepthMeters: 18,
            avgDepthMeters: 12,
            avgWaterTemperatureCelsius: nil,
            ttv: 15,
            entryGPS: nil,
            exitGPS: nil,
            samples: [
                DiveSample(timestamp: start.addingTimeInterval(10), depthMeters: 5, temperatureCelsius: nil),
                DiveSample(timestamp: start.addingTimeInterval(70), depthMeters: 15, temperatureCelsius: nil)
            ]
        )
        let csv = try XCTUnwrap(SubsurfaceExportService.makeCSV(for: session))
        let dataRows = csv.split(separator: "\n").filter { !$0.hasPrefix("#") && !$0.hasPrefix("time_seconds") }
        let seconds = dataRows.compactMap { Int($0.split(separator: ",").first ?? "") }
        XCTAssertEqual(seconds, [0, 60])
    }
}
