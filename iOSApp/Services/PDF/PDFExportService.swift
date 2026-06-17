import Foundation

enum PDFExportError: Error, Equatable {
    case invalidPlan
    case emptyChecklist
    case generationFailed
}

struct PDFExportPlannerContext {
    let input: GasPlanInput
    let plan: DivePlanResult
    let mode: PlannerMode
    let validation: PlannerValidationResult
    let modIssues: [MODValidationIssue]
    let safetyAcknowledged: Bool
    let unitPreference: IOSUnitPreference
    let pressureUnitPreference: PressureUnit
}

struct PDFExportCCRPlannerContext {
    let input: CCRPlanInput
    let plan: CCRPlanResult
    let safetyAcknowledged: Bool
    let unitPreference: IOSUnitPreference
}

enum PDFExportService {
    static func canExportPlan(_ context: PDFExportPlannerContext) -> Bool {
        PDFExportGate.canExportPlanner(context)
    }

    static func canExportCCRPlan(_ context: PDFExportCCRPlannerContext) -> Bool {
        PDFExportGate.canExportCCR(context)
    }

    static func plannerExportBlockReasons(_ context: PDFExportPlannerContext) -> [PDFExportBlockReason] {
        PDFExportGate.plannerBlockReasons(context)
    }

    static func ccrExportBlockReasons(_ context: PDFExportCCRPlannerContext) -> [PDFExportBlockReason] {
        PDFExportGate.ccrBlockReasons(context)
    }

    static func hasExportableChecklist(_ profile: EquipmentProfile) -> Bool {
        !profile.migratedChecklistItems.isEmpty
    }

    static func exportCCRPlan(context: PDFExportCCRPlannerContext, siteName: String? = nil) throws -> URL {
        guard canExportCCRPlan(context) else { throw PDFExportError.invalidPlan }
        let data = CCRPlannerPDFBuilder.build(context: context)
        guard !data.isEmpty else { throw PDFExportError.generationFailed }
        let filename = PDFExportFilename.make(prefix: "DIRDiving_CCR_Plan", siteName: siteName)
        return try PDFExportFilename.write(data: data, filename: filename)
    }

    static func exportPlan(context: PDFExportPlannerContext, siteName: String? = nil) throws -> URL {
        guard canExportPlan(context) else { throw PDFExportError.invalidPlan }
        let data = PlannerPDFBuilder.build(context: context)
        guard !data.isEmpty else { throw PDFExportError.generationFailed }
        let filename = PDFExportFilename.make(prefix: "DIRDiving_Plan", siteName: siteName)
        return try PDFExportFilename.write(data: data, filename: filename)
    }

    static func exportBriefing(context: PDFExportPlannerContext, siteName: String? = nil) throws -> URL {
        guard canExportPlan(context) else { throw PDFExportError.invalidPlan }
        let data = BriefingPDFBuilder.build(context: context, siteName: siteName)
        guard !data.isEmpty else { throw PDFExportError.generationFailed }
        let filename = PDFExportFilename.make(prefix: "DIRDiving_Briefing", siteName: siteName)
        return try PDFExportFilename.write(data: data, filename: filename)
    }

    static func exportEquipmentSetup(profile: EquipmentProfile, unitPreference: IOSUnitPreference = .metric) throws -> URL {
        let data = EquipmentSetupPDFBuilder.build(profile: profile, unitPreference: unitPreference)
        guard !data.isEmpty else { throw PDFExportError.generationFailed }
        let filename = PDFExportFilename.make(prefix: "DIRDiving_Equipment")
        return try PDFExportFilename.write(data: data, filename: filename)
    }

    static func exportChecklist(profile: EquipmentProfile, unitPreference: IOSUnitPreference = .metric) throws -> URL {
        var migrated = profile
        migrated.syncLegacyChecklistFlags()
        guard hasExportableChecklist(migrated) else { throw PDFExportError.emptyChecklist }
        let data = ChecklistPDFBuilder.build(profile: migrated, unitPreference: unitPreference)
        guard !data.isEmpty else { throw PDFExportError.generationFailed }
        let filename = PDFExportFilename.make(prefix: "DIRDiving_Checklist")
        return try PDFExportFilename.write(data: data, filename: filename)
    }

    static func exportDivePack(
        plannerContext: PDFExportPlannerContext,
        checklistProfile: EquipmentProfile,
        siteName: String? = nil
    ) throws -> URL {
        guard canExportPlan(plannerContext) else { throw PDFExportError.invalidPlan }
        var migratedChecklist = checklistProfile
        migratedChecklist.syncLegacyChecklistFlags()
        let includeChecklist = hasExportableChecklist(migratedChecklist)
        let data = DivePackPDFBuilder.build(
            plannerContext: plannerContext,
            checklistProfile: migratedChecklist,
            includeChecklist: includeChecklist,
            siteName: siteName
        )
        guard !data.isEmpty else { throw PDFExportError.generationFailed }
        let filename = PDFExportFilename.make(prefix: "DIRDiving_DivePack", siteName: siteName)
        return try PDFExportFilename.write(data: data, filename: filename)
    }
}
