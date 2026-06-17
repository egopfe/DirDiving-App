import Foundation

enum PDFExportBlockReason: String, CaseIterable, Equatable, Sendable {
    case missingSafetyAcknowledgement
    case invalidValidation
    case modViolation
    case invalidPlanState
    case unavailablePlanState
    case missingOxygenExposure
    case missingCalculatedResult
    case emptyChecklist
    case unsupportedExportMode
}

enum PDFExportGate {
    static func plannerBlockReasons(_ context: PDFExportPlannerContext) -> [PDFExportBlockReason] {
        var reasons: [PDFExportBlockReason] = []
        if !context.safetyAcknowledged {
            reasons.append(.missingSafetyAcknowledgement)
        }
        if !context.validation.isValid {
            reasons.append(.invalidValidation)
        }
        if !context.modIssues.isEmpty {
            reasons.append(.modViolation)
        }
        switch context.plan.buhlmannState {
        case .invalidInput:
            reasons.append(.invalidPlanState)
        case .unavailable:
            reasons.append(.unavailablePlanState)
        default:
            break
        }
        return reasons
    }

    static func ccrBlockReasons(_ context: PDFExportCCRPlannerContext) -> [PDFExportBlockReason] {
        var reasons: [PDFExportBlockReason] = []
        if !context.safetyAcknowledged {
            reasons.append(.missingSafetyAcknowledgement)
        }
        if !context.plan.validationResult.isValid {
            reasons.append(.invalidValidation)
        }
        switch context.plan.buhlmannState {
        case .invalidInput:
            reasons.append(.invalidPlanState)
        case .unavailable:
            reasons.append(.unavailablePlanState)
        default:
            break
        }
        if !context.plan.hasAvailableOxygenExposure {
            reasons.append(.missingOxygenExposure)
        }
        return reasons
    }

    static func canExportPlanner(_ context: PDFExportPlannerContext) -> Bool {
        plannerBlockReasons(context).isEmpty
    }

    static func canExportCCR(_ context: PDFExportCCRPlannerContext) -> Bool {
        ccrBlockReasons(context).isEmpty
    }

    static func primaryMessage(for reasons: [PDFExportBlockReason]) -> String {
        guard let first = reasons.first else {
            return DIRIOSLocalizer.string("pdf.export.error.invalid_plan")
        }
        return DIRIOSLocalizer.string("pdf.export.error.\(first.rawValue)")
    }

    static func detailMessage(for reasons: [PDFExportBlockReason]) -> String {
        guard !reasons.isEmpty else {
            return DIRIOSLocalizer.string("pdf.export.error.invalid_plan")
        }
        if reasons.count == 1 {
            return primaryMessage(for: reasons)
        }
        let lines = reasons.map { DIRIOSLocalizer.string("pdf.export.error.\($0.rawValue)") }
        return lines.joined(separator: "\n")
    }
}
