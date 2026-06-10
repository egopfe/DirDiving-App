import SwiftUI
import UIKit

struct ShareSheetView: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct ShareablePDFItem: Identifiable {
    let id = UUID()
    let url: URL
}

@MainActor
enum PDFShareActions {
    static func plannerContext(
        store: PlannerStore,
        safetyAcknowledged: Bool,
        unitPreference: IOSUnitPreference,
        pressureUnitPreference: PressureUnit,
        modIssues: [MODValidationIssue]
    ) -> PDFExportPlannerContext {
        PDFExportPlannerContext(
            input: PlannerModePolicy.activePlanInput(from: store.input, mode: store.mode),
            plan: store.plan,
            mode: store.mode,
            validation: PlannerModePolicy.validate(draft: store.input, mode: store.mode),
            modIssues: modIssues,
            safetyAcknowledged: safetyAcknowledged,
            unitPreference: unitPreference,
            pressureUnitPreference: pressureUnitPreference
        )
    }

    static func ccrContext(
        store: PlannerStore,
        safetyAcknowledged: Bool,
        unitPreference: IOSUnitPreference
    ) -> PDFExportCCRPlannerContext {
        PDFExportCCRPlannerContext(
            input: store.ccrInput,
            plan: store.ccrPlan,
            safetyAcknowledged: safetyAcknowledged,
            unitPreference: unitPreference
        )
    }

    static func invalidPlanMessage() -> String {
        DIRIOSLocalizer.string("pdf.export.error.invalid_plan")
    }

    static func emptyChecklistMessage() -> String {
        DIRIOSLocalizer.string("pdf.export.error.empty_checklist")
    }
}
