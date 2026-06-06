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
        modIssues: [MODValidationIssue]
    ) -> PDFExportPlannerContext {
        PDFExportPlannerContext(
            input: store.input,
            plan: store.plan,
            mode: store.mode,
            validation: PlannerModePolicy.validate(draft: store.input, mode: store.mode),
            modIssues: modIssues,
            safetyAcknowledged: safetyAcknowledged,
            unitPreference: unitPreference
        )
    }

    static func invalidPlanMessage() -> String {
        String(localized: "pdf.export.error.invalid_plan")
    }

    static func emptyChecklistMessage() -> String {
        String(localized: "pdf.export.error.empty_checklist")
    }
}
