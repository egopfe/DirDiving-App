import UIKit

enum ChecklistPDFBuilder {
    static func build(profile: EquipmentProfile) -> Data {
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        let disclaimer = String(localized: "pdf.export.disclaimer")
        let title = String(localized: "pdf.export.section.checklist")
        let yesLabel = String(localized: "pdf.export.checklist.yes")
        let noLabel = String(localized: "pdf.export.checklist.no")

        return renderer.pdfData { pdf in
            let page = PDFPageContext()
            page.attach(pdf, title: title, generatedAt: Date())

            page.drawSectionTitle(String(localized: "equipment.card.checklist"))
            page.drawParagraph(String(localized: "pdf.export.checklist.instructions"))

            for item in profile.checklistItems {
                let line = checklistLine(for: item)
                page.drawChecklistRow(yesLabel: yesLabel, noLabel: noLabel, itemText: line)
            }

            page.finish(disclaimer: disclaimer)
        }
    }

    static func exportLine(for item: EquipmentChecklistItem) -> String {
        checklistLine(for: item)
    }

    private static func checklistLine(for item: EquipmentChecklistItem) -> String {
        if !item.usesGas {
            return item.title
        }
        var parts = [item.title]
        parts.append(item.tankSize.rawValue)
        parts.append(item.gasMixKind.plannerPickerTitle)
        if !item.gasText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            parts.append(item.gasText)
        } else {
            parts.append("O₂ — He —")
        }
        if let role = item.gasRole ?? ChecklistPlannerSyncMapper.resolvedRole(for: item) {
            parts.append(role.localizedTitle)
        }
        if !item.pressureText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            parts.append("\(item.pressureText) \(item.pressureUnit.rawValue)")
        }
        return parts.joined(separator: " — ")
    }
}
