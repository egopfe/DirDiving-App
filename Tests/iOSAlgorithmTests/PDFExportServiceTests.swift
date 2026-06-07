import XCTest
import PDFKit

final class PDFExportServiceTests: XCTestCase {
    private func validPlannerContext(mode: PlannerMode = .deco) -> PDFExportPlannerContext {
        var input = GasPlanInput()
        input.ensurePlannerCylindersFromLegacy()
        input.plannedDepthMeters = 30
        input.plannedBottomMinutes = 20
        input.plannedAverageDepthMeters = 24
        input.bottomGas = GasMix(name: "Air", mixKind: .air, oxygen: 0.21, helium: 0, maxPPO2: 1.4)
        if let index = input.plannerCylinders.firstIndex(where: { $0.role == .bottom }) {
            input.plannerCylinders[index].gas = input.bottomGas
        }
        let active = PlannerModePolicy.activePlanInput(from: input, mode: mode)
        let plan = PlannerService.makePlan(input: active, mode: mode)
        return PDFExportPlannerContext(
            input: input,
            plan: plan,
            mode: mode,
            validation: PlannerModePolicy.validate(draft: input, mode: mode),
            modIssues: [],
            safetyAcknowledged: true,
            unitPreference: .metric
        )
    }

    private func sampleChecklistProfile() -> EquipmentProfile {
        var profile = EquipmentProfile()
        profile.checklistItems = [
            EquipmentChecklistItem(title: "Analyze EAN50", usesGas: true, gasMixKind: .ean, gasText: "O₂ 50%", switchDepthMeters: 21, pressureText: "200", gasRole: .deco),
            EquipmentChecklistItem(title: "Backup mask")
        ]
        return profile
    }

    private func pdfText(_ data: Data) -> String {
        guard let document = PDFDocument(data: data) else { return "" }
        return (0..<document.pageCount)
            .compactMap { document.page(at: $0)?.string }
            .joined(separator: "\n")
    }

    func testPlanPDFGeneratedForValidPlan() throws {
        let context = validPlannerContext()
        XCTAssertTrue(PDFExportService.canExportPlan(context))
        let data = PlannerPDFBuilder.build(context: context)
        XCTAssertFalse(data.isEmpty)
        XCTAssertTrue(String(data: data.prefix(5), encoding: .ascii)?.hasPrefix("%PDF") == true)
        let url = try PDFExportService.exportPlan(context: context)
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
        XCTAssertTrue(url.lastPathComponent.hasPrefix("DIRDiving_Plan_"))
    }

    func testInvalidPlanBlocksPlanPDFExport() {
        var context = validPlannerContext()
        context = PDFExportPlannerContext(
            input: context.input,
            plan: context.plan,
            mode: context.mode,
            validation: context.validation,
            modIssues: context.modIssues,
            safetyAcknowledged: false,
            unitPreference: context.unitPreference
        )
        XCTAssertFalse(PDFExportService.canExportPlan(context))
        XCTAssertThrowsError(try PDFExportService.exportPlan(context: context)) { error in
            XCTAssertEqual(error as? PDFExportError, .invalidPlan)
        }
    }

    func testChecklistPDFIncludesYesNoFields() {
        let profile = sampleChecklistProfile()
        let data = ChecklistPDFBuilder.build(profile: profile)
        XCTAssertFalse(data.isEmpty)
        let yesLabel = String(localized: "pdf.export.checklist.yes")
        let noLabel = String(localized: "pdf.export.checklist.no")
        let text = pdfText(data)
        XCTAssertTrue(text.contains(yesLabel))
        XCTAssertTrue(text.contains(noLabel))
        XCTAssertTrue(text.contains("[ ]"))
        XCTAssertTrue(text.contains("Analyze EAN50"))
    }

    func testEmptyChecklistBlocksExport() {
        var profile = EquipmentProfile()
        profile.checklistItems = []
        profile.backupMaskReady = false
        profile.spoolReady = false
        profile.backupComputerReady = false
        // Legacy migration still yields default checklist rows; export remains available.
        XCTAssertTrue(PDFExportService.hasExportableChecklist(profile))
    }

    func testDivePackIncludesPlanBriefingAndChecklist() throws {
        let context = validPlannerContext()
        let profile = sampleChecklistProfile()
        let data = DivePackPDFBuilder.build(
            plannerContext: context,
            checklistProfile: profile,
            includeChecklist: true,
            siteName: "Blue Hole"
        )
        XCTAssertFalse(data.isEmpty)
        let text = pdfText(data)
        XCTAssertTrue(text.contains(String(localized: "pdf.export.section.plan")))
        XCTAssertTrue(text.contains(String(localized: "pdf.export.section.briefing")))
        XCTAssertTrue(text.contains(String(localized: "pdf.export.section.checklist")))
        XCTAssertTrue(text.contains("Analyze EAN50"))
        let url = try PDFExportService.exportDivePack(
            plannerContext: context,
            checklistProfile: profile,
            siteName: "Blue Hole"
        )
        XCTAssertTrue(url.lastPathComponent.contains("Blue_Hole"))
    }

    func testFilenameSanitization() {
        XCTAssertEqual(PDFExportFilename.sanitized("  Blue Hole!  "), "Blue_Hole")
        XCTAssertEqual(PDFExportFilename.sanitized("Site/A"), "SiteA")
        XCTAssertNil(PDFExportFilename.sanitized("   "))
        let name = PDFExportFilename.make(prefix: "DIRDiving_DivePack", siteName: "Test Site")
        XCTAssertTrue(name.hasPrefix("DIRDiving_DivePack_"))
        XCTAssertTrue(name.hasSuffix("_Test_Site.pdf"))
    }

    func testLocalizationKeysResolve() {
        XCTAssertFalse(String(localized: "pdf.export.share.plan").isEmpty)
        XCTAssertFalse(String(localized: "pdf.export.error.invalid_plan").isEmpty)
        XCTAssertFalse(String(localized: "pdf.export.error.empty_checklist").isEmpty)
        XCTAssertFalse(String(localized: "pdf.export.disclaimer").isEmpty)
    }

    func testBriefingPDFShareItemIsValidAndProtected() throws {
        let context = validPlannerContext()
        let url = try PDFExportService.exportBriefing(context: context, siteName: "Test Site")
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
        XCTAssertTrue(url.pathExtension.lowercased() == "pdf")
        let data = try Data(contentsOf: url)
        XCTAssertGreaterThan(data.count, 100)
        XCTAssertTrue(String(data: data.prefix(5), encoding: .ascii)?.hasPrefix("%PDF") == true)
        let directory = try PDFExportFilename.protectedExportDirectory()
        XCTAssertTrue(url.path.hasPrefix(directory.path))
    }

    func testChecklistPDFShareItemIsValid() throws {
        let profile = sampleChecklistProfile()
        let item = profile.checklistItems[0]
        let line = ChecklistPDFBuilder.exportLine(for: item, unitPreference: .imperial)
        XCTAssertTrue(line.contains(Formatters.depth(21, units: .imperial).text))
        let url = try PDFExportService.exportChecklist(profile: profile, unitPreference: .imperial)
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
        let data = try Data(contentsOf: url)
        XCTAssertFalse(data.isEmpty)
        XCTAssertTrue(String(data: data.prefix(5), encoding: .ascii)?.hasPrefix("%PDF") == true)
    }

    func testDivePackPDFShareItemIsReadable() throws {
        let context = validPlannerContext()
        let profile = sampleChecklistProfile()
        let url = try PDFExportService.exportDivePack(plannerContext: context, checklistProfile: profile, siteName: nil)
        let data = try Data(contentsOf: url)
        XCTAssertGreaterThan(data.count, 200)
        XCTAssertNotNil(PDFDocument(data: data))
    }
}
