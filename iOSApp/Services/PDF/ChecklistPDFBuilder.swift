import UIKit

enum ChecklistPDFBuilder {
    static func build(profile: EquipmentProfile, unitPreference: IOSUnitPreference = .metric) -> Data {
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        let disclaimer = DIRIOSLocalizer.string("pdf.export.disclaimer")
        let title = DIRIOSLocalizer.string("pdf.export.section.checklist")
        let yesLabel = DIRIOSLocalizer.string("pdf.export.checklist.yes")
        let noLabel = DIRIOSLocalizer.string("pdf.export.checklist.no")

        return renderer.pdfData { pdf in
            let page = PDFPageContext()
            page.attach(pdf, title: title, generatedAt: Date())

            page.drawSectionTitle(DIRIOSLocalizer.string("checklist.title"))
            page.drawParagraph(DIRIOSLocalizer.string("pdf.export.checklist.instructions"))

            for kind in ChecklistItemKind.sectionOrder {
                let items = profile.migratedChecklistItems.filter { $0.kind == kind }
                guard !items.isEmpty else { continue }
                page.drawSectionTitle(kind.localizedSectionTitle)
                for item in items {
                    let line = checklistLine(for: item, unitPreference: unitPreference)
                    page.drawChecklistRow(yesLabel: yesLabel, noLabel: noLabel, itemText: line)
                }
            }

            page.finish(disclaimer: disclaimer)
        }
    }

    static func exportLine(for item: EquipmentChecklistItem, unitPreference: IOSUnitPreference = .metric) -> String {
        checklistLine(for: item, unitPreference: unitPreference)
    }

    private static func checklistLine(for item: EquipmentChecklistItem, unitPreference: IOSUnitPreference) -> String {
        var parts: [String] = []
        parts.append(item.title)
        parts.append(
            item.isRequired
                ? DIRIOSLocalizer.string("checklist.item.required")
                : DIRIOSLocalizer.string("checklist.item.optional")
        )
        parts.append(
            item.isReady
                ? DIRIOSLocalizer.string("pdf.export.checklist.completed")
                : DIRIOSLocalizer.string("pdf.export.checklist.not_completed")
        )
        if let completedAt = item.completedAt, item.isReady {
            parts.append(ChecklistItemSupport.completedAtLabel(for: completedAt))
        }
        if !item.note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            parts.append(item.note)
        }
        if item.usesGas {
            parts.append(gasDetails(for: item, unitPreference: unitPreference))
        }
        return parts.joined(separator: " — ")
    }

    private static func gasDetails(for item: EquipmentChecklistItem, unitPreference: IOSUnitPreference) -> String {
        var parts = [item.tankSize.rawValue]
        parts.append(item.gasMixKind.plannerPickerTitle)
        if !item.gasText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            parts.append(item.gasText)
        } else {
            parts.append("O₂ — He —")
        }
        if let role = item.gasRole ?? ChecklistPlannerSyncMapper.resolvedRole(for: item) {
            parts.append(role.localizedTitle)
        }
        if let switchDepth = item.switchDepthMeters, switchDepth.isFinite, switchDepth > 0,
           let role = item.gasRole ?? ChecklistPlannerSyncMapper.resolvedRole(for: item),
           role == .deco || role == .travel {
            let depthText = Formatters.depth(switchDepth, units: unitPreference).text
            parts.append(
                String(
                    format: String(
                        localized: "equipment.checklist.switch_depth_format",
                        defaultValue: "switch @ %@"
                    ),
                    depthText
                )
            )
        }
        if !item.pressureText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            parts.append("\(item.pressureText) \(item.pressureUnit.rawValue)")
        }
        return parts.joined(separator: " / ")
    }
}
