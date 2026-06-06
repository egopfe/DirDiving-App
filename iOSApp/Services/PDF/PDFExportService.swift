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
}

enum PDFExportService {
    static func canExportPlan(_ context: PDFExportPlannerContext) -> Bool {
        context.safetyAcknowledged
            && context.validation.isValid
            && context.modIssues.isEmpty
            && context.plan.buhlmannState != .invalidInput
            && context.plan.buhlmannState != .unavailable
    }

    static func hasExportableChecklist(_ profile: EquipmentProfile) -> Bool {
        !profile.checklistItems.isEmpty
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

    static func exportChecklist(profile: EquipmentProfile) throws -> URL {
        guard hasExportableChecklist(profile) else { throw PDFExportError.emptyChecklist }
        let data = ChecklistPDFBuilder.build(profile: profile)
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
        let includeChecklist = hasExportableChecklist(checklistProfile)
        let data = DivePackPDFBuilder.build(
            plannerContext: plannerContext,
            checklistProfile: checklistProfile,
            includeChecklist: includeChecklist,
            siteName: siteName
        )
        guard !data.isEmpty else { throw PDFExportError.generationFailed }
        let filename = PDFExportFilename.make(prefix: "DIRDiving_DivePack", siteName: siteName)
        return try PDFExportFilename.write(data: data, filename: filename)
    }
}
