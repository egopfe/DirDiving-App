import UIKit

enum EquipmentSetupPDFBuilder {
    static func build(profile: EquipmentProfile, unitPreference: IOSUnitPreference = .metric) -> Data {
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        let disclaimer = DIRIOSLocalizer.string("pdf.export.disclaimer")
        let title = DIRIOSLocalizer.string("equipment.export.sheet")
        let referenceNote = DIRIOSLocalizer.string("equipment.export.reference_note")

        return renderer.pdfData { pdf in
            let page = PDFPageContext()
            page.attach(pdf, title: title, generatedAt: Date())

            page.drawSectionTitle(DIRIOSLocalizer.string("equipment.title"))
            page.drawLine(DIRIOSLocalizer.string("equipment.setup.name"), value: profile.activeSetupName)
            page.drawLine(DIRIOSLocalizer.string("equipment.setup.mode"), value: profile.setupMode.localizedTitle)
            page.drawLine(DIRIOSLocalizer.string("equipment.row.configuration"), value: profile.configuration)
            page.drawLine(DIRIOSLocalizer.string("equipment.sac_default"), value: Formatters.sac(profile.sacLitersMinute, units: unitPreference).text)

            let cylinders = profile.effectiveCylinders
            if !cylinders.isEmpty {
                page.drawSectionTitle(DIRIOSLocalizer.string("equipment.card.cylinders"))
                for cylinder in cylinders {
                    let enabled = cylinder.isEnabled
                        ? DIRIOSLocalizer.string("equipment.cylinder.enabled")
                        : DIRIOSLocalizer.string("equipment.cylinder.disabled")
                    page.drawLine(cylinder.name, value: "\(cylinder.role.localizedTitle) — \(cylinder.tankSize.rawValue) — \(enabled)")
                    page.drawLine(
                        DIRIOSLocalizer.string("equipment.cylinder.start_pressure"),
                        value: Formatters.zero(cylinder.startPressureBar) + " bar"
                    )
                    page.drawLine(
                        DIRIOSLocalizer.string("equipment.cylinder.reserve_pressure"),
                        value: Formatters.zero(cylinder.reservePressureBar) + " bar"
                    )
                }
            }

            page.drawSectionTitle(DIRIOSLocalizer.string("equipment.card.gases"))
            if cylinders.isEmpty {
                page.drawLine(DIRIOSLocalizer.string("equipment.row.bottom_gas"), value: profile.bottomGas)
                page.drawLine(DIRIOSLocalizer.string("equipment.row.deco1"), value: profile.decoGas1)
                page.drawLine(DIRIOSLocalizer.string("equipment.row.deco2"), value: profile.decoGas2)
            } else {
                for cylinder in cylinders where cylinder.isEnabled {
                    var gasLine = cylinder.displayGasLabel
                    gasLine += " — O₂ \(Formatters.zero(cylinder.gas.oxygen * 100))%"
                    if cylinder.gas.helium > 0.001 {
                        gasLine += " He \(Formatters.zero(cylinder.gas.helium * 100))%"
                    }
                    if let switchDepth = cylinder.switchDepthMeters, switchDepth > 0 {
                        gasLine += " — \(Formatters.depth(switchDepth, units: unitPreference).text)"
                    }
                    page.drawLine(cylinder.role.localizedTitle, value: gasLine)
                }
            }

            if !profile.maintenanceItems.isEmpty {
                page.drawSectionTitle(DIRIOSLocalizer.string("equipment.card.maintenance"))
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .none
                for item in profile.maintenanceItems {
                    var status = item.isCompleted
                        ? DIRIOSLocalizer.string("equipment.maintenance.completed")
                        : maintenanceStatusLabel(for: item)
                    if let dueDate = item.dueDate {
                        status += " — \(formatter.string(from: dueDate))"
                    }
                    page.drawLine(item.title, value: status)
                }
            }

            let checklist = profile.migratedChecklistItems
            if !checklist.isEmpty {
                page.drawSectionTitle(DIRIOSLocalizer.string("equipment.card.checklist_link"))
                page.drawLine(
                    DIRIOSLocalizer.string("checklist.title"),
                    value: String(format: DIRIOSLocalizer.string("equipment.export.checklist_count"), checklist.count)
                )
            }

            page.drawParagraph(referenceNote)
            page.finish(disclaimer: disclaimer)
        }
    }

    private static func maintenanceStatusLabel(for item: EquipmentMaintenanceItem) -> String {
        switch EquipmentStructuredSupport.maintenanceStatus(for: item) {
        case .ok: return DIRIOSLocalizer.string("equipment.maintenance.status.ok")
        case .dueSoon: return DIRIOSLocalizer.string("equipment.maintenance.due_soon")
        case .overdue: return DIRIOSLocalizer.string("equipment.maintenance.overdue")
        }
    }
}
