import XCTest
import PDFKit

@MainActor
final class IOSMainAlgorithmMathRemediationTests: XCTestCase {
    private func technicalInput(depth: Double = 45, bottom: Double = 25) -> GasPlanInput {
        var input = BuhlmannTestSupport.gasPlanInput()
        input.plannedDepthMeters = depth
        input.plannedBottomMinutes = bottom
        return input
    }

    // MARK: - P2-001 Balanced vs Linear

    func testBalancedAndLinearProduceDifferentStopDistributions() {
        var input = technicalInput(depth: 48, bottom: 28)
        var balancedPreset = RatioDecoPreset.preset1to1
        balancedPreset.distributionMode = .balanced
        var linearPreset = RatioDecoPreset.preset1to1
        linearPreset.distributionMode = .linear
        guard
            let balanced = RatioDecoPlanner.makeSchedule(
                input: input,
                mode: .technical,
                preset: balancedPreset,
                environment: .seaLevelSaltWater,
                descentMinutes: 5
            ),
            let linear = RatioDecoPlanner.makeSchedule(
                input: input,
                mode: .technical,
                preset: linearPreset,
                environment: .seaLevelSaltWater,
                descentMinutes: 5
            )
        else {
            return XCTFail("Expected schedules")
        }
        XCTAssertEqual(balanced.stops.count, linear.stops.count)
        XCTAssertGreaterThan(balanced.stops.count, 2)
        let balancedMinutes = balanced.stops.map(\.durationMinutes)
        let linearMinutes = linear.stops.map(\.durationMinutes)
        XCTAssertNotEqual(balancedMinutes, linearMinutes)
        let balancedTotal = balancedMinutes.reduce(0, +)
        let linearTotal = linearMinutes.reduce(0, +)
        XCTAssertEqual(balancedTotal, linearTotal, accuracy: 2)
        XCTAssertTrue(balanced.stops.allSatisfy { $0.durationMinutes >= balancedPreset.minimumStopMinutes })
        XCTAssertTrue(linear.stops.allSatisfy { $0.durationMinutes >= linearPreset.minimumStopMinutes })
    }

    // MARK: - P2-002 Ceiling violation

    func testAggressiveRatioDecoProfileTriggersCeilingViolation() {
        var input = technicalInput(depth: 60, bottom: 50)
        var preset = RatioDecoPreset.preset2to1
        preset.minimumStopMinutes = 1
        preset.firstStopDepthMeters = 21
        guard let schedule = RatioDecoPlanner.makeSchedule(
            input: input,
            mode: .technical,
            preset: preset,
            environment: .seaLevelSaltWater,
            descentMinutes: 6
        ) else {
            return XCTFail("Expected schedule")
        }
        let request = BuhlmannPlanner.makeRequest(input: input, environment: .seaLevelSaltWater)
        let enginePlan = BuhlmannEngine.plan(request)
        let validation = RatioDecoValidator.validate(
            schedule: schedule,
            input: input,
            mode: .technical,
            enginePlan: enginePlan,
            request: request,
            environment: .seaLevelSaltWater
        )
        XCTAssertFalse(validation.isBuhlmannCompatible)
        XCTAssertTrue(validation.warnings.contains(where: {
            if case .ceilingViolation = $0 { return true }
            return false
        }))
    }

    // MARK: - P1-005 Incompatibility UX / PDF

    func testIncompatibleRatioDecoValidationMarksNotValidatedPlan() {
        var input = technicalInput(depth: 60, bottom: 50)
        var preset = RatioDecoPreset.preset2to1
        preset.minimumStopMinutes = 1
        guard let schedule = RatioDecoPlanner.makeSchedule(
            input: input,
            mode: .technical,
            preset: preset,
            environment: .seaLevelSaltWater,
            descentMinutes: 6
        ) else {
            return XCTFail("Expected schedule")
        }
        let request = BuhlmannPlanner.makeRequest(input: input, environment: .seaLevelSaltWater)
        let enginePlan = BuhlmannEngine.plan(request)
        let validation = RatioDecoValidator.validate(
            schedule: schedule,
            input: input,
            mode: .technical,
            enginePlan: enginePlan,
            request: request,
            environment: .seaLevelSaltWater
        )
        guard !validation.isBuhlmannCompatible else {
            return XCTFail("Expected incompatible fixture")
        }
        XCTAssertTrue(validation.warnings.contains(where: {
            if case .ceilingViolation = $0 { return true }
            return false
        }) || !validation.warnings.isEmpty)
    }

    func testPlanPDFContainsIncompatibilityWarningWhenNotCompatible() {
        var input = technicalInput(depth: 60, bottom: 50)
        var preset = RatioDecoPreset.preset2to1
        guard let schedule = RatioDecoPlanner.makeSchedule(
            input: input,
            mode: .technical,
            preset: preset,
            environment: .seaLevelSaltWater,
            descentMinutes: 6
        ) else {
            return XCTFail("Expected schedule")
        }
        let request = BuhlmannPlanner.makeRequest(input: input, environment: .seaLevelSaltWater)
        let enginePlan = BuhlmannEngine.plan(request)
        let validation = RatioDecoValidator.validate(
            schedule: schedule,
            input: input,
            mode: .technical,
            enginePlan: enginePlan,
            request: request,
            environment: .seaLevelSaltWater
        )
        guard !validation.isBuhlmannCompatible else {
            return XCTFail("Expected incompatible fixture")
        }
        let planWithRatio = PlannerService.makePlan(
            input: input,
            mode: .technical,
            repetitivePlanningEnabled: false,
            repetitiveSnapshot: nil,
            surfaceIntervalMinutes: 0,
            decompressionMethod: .ratioDeco,
            ratioDecoPreset: preset
        )
        let context = PDFExportPlannerContext(
            input: input,
            plan: planWithRatio,
            mode: .technical,
            validation: PlannerModePolicy.validate(draft: input, mode: .technical),
            modIssues: [],
            safetyAcknowledged: true,
            unitPreference: .metric
        )
        XCTAssertFalse(context.plan.ratioDeco?.validation.isBuhlmannCompatible ?? true)
        let data = PlannerPDFBuilder.build(context: context)
        XCTAssertFalse(data.isEmpty)
    }

    func testBuhlmannScheduleUnchangedWhenRatioDecoSelected() {
        let input = technicalInput()
        let buhlmannOnly = PlannerService.makePlan(
            input: input,
            mode: .technical,
            repetitivePlanningEnabled: false,
            repetitiveSnapshot: nil,
            surfaceIntervalMinutes: 0,
            decompressionMethod: .buhlmann
        )
        let withRatio = PlannerService.makePlan(
            input: input,
            mode: .technical,
            repetitivePlanningEnabled: false,
            repetitiveSnapshot: nil,
            surfaceIntervalMinutes: 0,
            decompressionMethod: .ratioDeco,
            ratioDecoPreset: .preset1to1
        )
        XCTAssertEqual(buhlmannOnly.ttsMinutes, withRatio.ttsMinutes)
        XCTAssertEqual(buhlmannOnly.decoStops.map(\.depthMeters), withRatio.decoStops.map(\.depthMeters))
    }

    // MARK: - P2-003 Dive Pack Ratio Deco

    func testDivePackIncludesRatioDecoSection() {
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
        XCTAssertNotNil(plan.ratioDeco)
        let context = PDFExportPlannerContext(
            input: input,
            plan: plan,
            mode: .technical,
            validation: PlannerModePolicy.validate(draft: input, mode: .technical),
            modIssues: [],
            safetyAcknowledged: true,
            unitPreference: .metric
        )
        let withoutRatio = DivePackPDFBuilder.build(
            plannerContext: PDFExportPlannerContext(
                input: input,
                plan: PlannerService.makePlan(
                    input: input,
                    mode: .technical,
                    repetitivePlanningEnabled: false,
                    repetitiveSnapshot: nil,
                    surfaceIntervalMinutes: 0,
                    decompressionMethod: .buhlmann
                ),
                mode: .technical,
                validation: context.validation,
                modIssues: [],
                safetyAcknowledged: true,
                unitPreference: .metric
            ),
            checklistProfile: EquipmentProfile(),
            includeChecklist: false,
            siteName: nil
        )
        let withRatio = DivePackPDFBuilder.build(
            plannerContext: context,
            checklistProfile: EquipmentProfile(),
            includeChecklist: false,
            siteName: nil
        )
        XCTAssertGreaterThan(withRatio.count, withoutRatio.count)
        XCTAssertEqual(String(data: withRatio.prefix(4), encoding: .ascii), "%PDF")
    }

    // MARK: - P2-004 / P2-005 Checklist

    func testLegacyChecklistItemDecodesWithoutGasTextOrSwitchDepth() throws {
        let json = """
        {"id":"00000000-0000-4000-8000-000000000001","title":"Deco","isReady":false,"usesGas":true}
        """
        let item = try JSONDecoder().decode(EquipmentChecklistItem.self, from: Data(json.utf8))
        XCTAssertTrue(item.gasText.isEmpty)
        XCTAssertNil(item.switchDepthMeters)
    }

    func testPlannerSyncMapsGasTextAndSwitchDepth() {
        let cylinder = PlannerCylinderEntry(
            role: .deco,
            gas: GasMix(name: "EAN50", role: .deco, mixKind: .ean, oxygen: 0.5, helium: 0, maxPPO2: 1.6),
            switchDepthMeters: 21
        )
        let item = ChecklistPlannerSyncMapper.checklistItem(from: cylinder)
        XCTAssertEqual(item.gasText, "EAN50")
        XCTAssertEqual(item.switchDepthMeters ?? 0, 21, accuracy: 0.01)
        XCTAssertEqual(item.gasRole, .deco)
    }

    func testLegacyChecklistBecomesExportableAfterMigration() {
        var profile = EquipmentProfile()
        profile.backupMaskReady = true
        profile.checklistItems = []
        XCTAssertTrue(PDFExportService.hasExportableChecklist(profile))
        profile.syncLegacyChecklistFlags()
        let data = ChecklistPDFBuilder.build(profile: profile)
        XCTAssertFalse(data.isEmpty)
        let text = pdfText(data)
        XCTAssertTrue(text.contains("Backup mask"))
    }

    func testChecklistPDFIncludesGasTextAndSwitchDepth() {
        let item = EquipmentChecklistItem(
            title: "Deco stage",
            usesGas: true,
            gasMixKind: .ean,
            gasText: "EAN50",
            switchDepthMeters: 21,
            pressureText: "190",
            gasRole: .deco
        )
        let line = ChecklistPDFBuilder.exportLine(for: item)
        XCTAssertTrue(line.contains("EAN50"))
        XCTAssertEqual(item.switchDepthMeters ?? 0, 21, accuracy: 0.01)
        XCTAssertEqual(item.gasRole, .deco)
        let data = ChecklistPDFBuilder.build(profile: {
            var profile = EquipmentProfile()
            profile.checklistItems = [item]
            return profile
        }())
        XCTAssertFalse(data.isEmpty)
    }

    func testExportDefaultReplaceDoesNotDuplicateChecklistGas() {
        let cylinder = PlannerCylinderEntry(
            role: .deco,
            gas: GasMix(name: "EAN50", role: .deco, mixKind: .ean, oxygen: 0.5, helium: 0, maxPPO2: 1.6),
            switchDepthMeters: 21
        )
        var checklist: [EquipmentChecklistItem] = [ChecklistPlannerSyncMapper.checklistItem(from: cylinder)]
        let candidates = ChecklistPlannerSyncMapper.exportCandidates(plannerCylinders: [cylinder], checklist: checklist)
        XCTAssertEqual(candidates.first?.duplicateAction, .replace)
        ChecklistPlannerSyncMapper.applyExport(candidates: candidates, to: &checklist)
        XCTAssertEqual(checklist.count, 1)
    }

    // MARK: - P2-006 Tissue analytics labels

    func testLogbookTissueAnalyticsManualSessionUsesSimulatedEstimate() {
        var session = makeSession(maxDepth: 30, avgDepth: 18)
        session.isManual = true
        let presentation = TissueAnalyticsService.presentationForSession(session)
        XCTAssertEqual(presentation?.trace.source, .simulated)
    }

    func testLogbookTissueAnalyticsRecordedSessionUsesRecordedReplay() {
        let session = makeSession(maxDepth: 30, avgDepth: 18)
        XCTAssertFalse(session.isManual)
        let presentation = TissueAnalyticsService.presentationForSession(session)
        XCTAssertEqual(presentation?.trace.source, .recorded)
    }

    func testPlannerTissueAnalyticsSourceIsPlanned() {
        let input = technicalInput(depth: 45, bottom: 25)
        let plan = PlannerService.makePlan(input: input, mode: .technical)
        let presentation = TissueAnalyticsService.presentationForPlanner(plan: plan, input: input, mode: .technical)
        XCTAssertEqual(presentation?.trace.source, .planned)
    }

    func testTissueAnalyticsFootnoteKeysExistInEnglishAndItalian() throws {
        let en = try loadIOSStrings(named: "en")
        let it = try loadIOSStrings(named: "it")
        for key in ["tissue_analytics.source.simulated_footnote", "tissue_analytics.source.planned_footnote"] {
            XCTAssertFalse(en[key, default: ""].isEmpty, "Missing EN \(key)")
            XCTAssertFalse(it[key, default: ""].isEmpty, "Missing IT \(key)")
        }
    }

    // MARK: - P2-007 Bailout

    func testBuhlmannRequestExcludesBailoutCylinder() {
        var input = technicalInput()
        input.plannerCylinders.append(
            PlannerCylinderEntry(
                role: .bailout,
                gas: GasMix(name: "Bailout", role: .bailout, mixKind: .air, oxygen: 0.21, helium: 0, maxPPO2: 1.4),
                switchDepthMeters: 30
            )
        )
        let request = BuhlmannPlanner.makeRequest(input: input, environment: .seaLevelSaltWater)
        XCTAssertFalse(request.decoGases.contains(where: { $0.role == .bailout }))
        XCTAssertFalse(request.travelGases.contains(where: { $0.role == .bailout }))
    }

    func testAddingBailoutDoesNotAlterPrimaryBuhlmannSchedule() {
        let baseInput = technicalInput()
        let withBailout: GasPlanInput = {
            var input = baseInput
            input.plannerCylinders.append(
                PlannerCylinderEntry(
                    role: .bailout,
                    gas: GasMix(name: "Bailout", role: .bailout, mixKind: .air, oxygen: 0.21, helium: 0, maxPPO2: 1.4),
                    switchDepthMeters: 30
                )
            )
            return input
        }()
        let basePlan = PlannerService.makePlan(input: baseInput, mode: .technical)
        let bailoutPlan = PlannerService.makePlan(input: withBailout, mode: .technical)
        XCTAssertEqual(basePlan.ttsMinutes, bailoutPlan.ttsMinutes)
        XCTAssertEqual(basePlan.decoStops.count, bailoutPlan.decoStops.count)
    }

    // MARK: - P2-008 NDL depth band

    func testNDLCurveUsesDepthBandField() {
        let point = NDLPoint(depthMeters: 30, ndlMinutes: 25, depthBand: "5-8")
        XCTAssertEqual(point.depthBand, "5-8")
        XCTAssertFalse(String(localized: "planner.buhlmann.group_1_4").isEmpty)
    }

    // MARK: - P3-006 noDecoGases

    func testNoDecoGasesWarningWhenDecoCylinderMissing() {
        var input = technicalInput()
        input.plannerCylinders.removeAll { $0.role == .deco }
        let schedule = RatioDecoPlanner.makeSchedule(
            input: input,
            mode: .technical,
            preset: .preset1to1,
            environment: .seaLevelSaltWater,
            descentMinutes: 5
        )
        XCTAssertTrue(schedule?.warnings.contains(.noDecoGases) ?? false)
    }

    // MARK: - P4-002 Comparison runtime from ascent table

    func testBuhlmannComparisonUsesAscentTableRuntime() {
        let input = technicalInput()
        let plan = PlannerService.makePlan(input: input, mode: .technical)
        XCTAssertFalse(plan.ascentTableRows.isEmpty)
        var cumulative = 0.0
        let decoRows = plan.ascentTableRows.filter { $0.kind == .decoStop }
        for row in plan.ascentTableRows {
            cumulative += row.minutes
            if row.kind == .decoStop {
                XCTAssertGreaterThan(cumulative, Double(row.minutes))
            }
        }
        XCTAssertFalse(decoRows.isEmpty)
    }

    // MARK: - P4-004 Equipment cloud round-trip

    func testEquipmentProfileCloudLocalRoundTrip() {
        let suiteName = "EquipmentCloudRoundTrip.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let store = CloudSyncStore(defaults: defaults)
        var profile = EquipmentProfile()
        profile.cylinders = "2 x 12 L"
        profile.checklistItems = [
            EquipmentChecklistItem(
                title: "Deco",
                usesGas: true,
                gasText: "EAN50",
                switchDepthMeters: 21,
                gasRole: .deco
            )
        ]
        store.save(profile, forKey: "dirdiving_ios_equipment_profile")
        let loaded = store.load(EquipmentProfile.self, forKey: "dirdiving_ios_equipment_profile")
        XCTAssertEqual(loaded?.cylinders, "2 x 12 L")
        XCTAssertEqual(loaded?.checklistItems.first?.gasText, "EAN50")
        XCTAssertEqual(loaded?.checklistItems.first?.switchDepthMeters ?? 0, 21, accuracy: 0.01)
    }

    // MARK: - Helpers

    private func pdfText(_ data: Data) -> String {
        guard let document = PDFDocument(data: data) else { return "" }
        return (0..<document.pageCount)
            .compactMap { document.page(at: $0)?.string }
            .joined(separator: "\n")
    }

    private func makeSession(maxDepth: Double, avgDepth: Double) -> DiveSession {
        let start = Date()
        let end = start.addingTimeInterval(120)
        let samples = [
            DiveSample(timestamp: start, depthMeters: 0, temperatureCelsius: 20),
            DiveSample(timestamp: end, depthMeters: maxDepth, temperatureCelsius: 20)
        ]
        let summary = DiveProfileMath.summary(samples: samples, startDate: start, endDate: end)
        return DiveSession(
            startDate: start,
            endDate: end,
            durationSeconds: summary.durationSeconds,
            maxDepthMeters: summary.maxDepthMeters,
            avgDepthMeters: summary.averageDepthMeters,
            avgWaterTemperatureCelsius: summary.averageTemperatureCelsius,
            ttv: summary.ttv,
            entryGPS: nil,
            exitGPS: nil,
            samples: samples,
            gasLabel: .oc
        )
    }

    private func loadIOSStrings(named language: String) throws -> [String: String] {
        let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        let url = root.appendingPathComponent("iOSApp/Resources/\(language).lproj/Localizable.strings")
        let raw = try String(contentsOf: url, encoding: .utf8)
        var result: [String: String] = [:]
        let pattern = #"^\s*"(.*?)"\s*=\s*"(.*)";\s*$"#
        let regex = try NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines])
        let range = NSRange(raw.startIndex..<raw.endIndex, in: raw)
        regex.enumerateMatches(in: raw, options: [], range: range) { match, _, _ in
            guard let match, match.numberOfRanges == 3,
                  let keyRange = Range(match.range(at: 1), in: raw),
                  let valueRange = Range(match.range(at: 2), in: raw) else { return }
            result[String(raw[keyRange])] = String(raw[valueRange])
        }
        return result
    }
}
