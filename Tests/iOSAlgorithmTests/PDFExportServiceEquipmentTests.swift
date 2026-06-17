import XCTest
import PDFKit

final class PDFExportServiceEquipmentTests: XCTestCase {
    private func sampleProfile() -> EquipmentProfile {
        var profile = EquipmentProfile()
        profile.activeSetupName = "DIR Twin"
        profile.structuredCylinders = [
            EquipmentGasCylinder(
                name: "Back",
                role: .bottom,
                tankSize: .liters12,
                gas: EquipmentStructuredSupport.defaultBottomGas(named: "TRIMIX 18/45")
            )
        ]
        profile.maintenanceItems = [
            EquipmentMaintenanceItem(title: "Reg service", kind: .regulatorService)
        ]
        profile.checklistItems = [
            EquipmentChecklistItem(title: "Mask", kind: .equipment)
        ]
        return profile
    }

    private func pdfText(_ data: Data) -> String {
        guard let document = PDFDocument(data: data) else { return "" }
        return (0..<document.pageCount)
            .compactMap { document.page(at: $0)?.string }
            .joined(separator: "\n")
    }

    func testEquipmentPDFExportDoesNotCrash() throws {
        let profile = sampleProfile()
        let data = EquipmentSetupPDFBuilder.build(profile: profile)
        XCTAssertFalse(data.isEmpty)
        XCTAssertTrue(String(data: data.prefix(5), encoding: .ascii)?.hasPrefix("%PDF") == true)
        let url = try PDFExportService.exportEquipmentSetup(profile: profile)
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
        let text = pdfText(data)
        XCTAssertTrue(text.contains(DIRIOSLocalizer.string("equipment.export.reference_note")))
    }

    func testChecklistPDFExportStillWorks() throws {
        let profile = sampleProfile()
        let data = ChecklistPDFBuilder.build(profile: profile)
        XCTAssertFalse(data.isEmpty)
        let url = try PDFExportService.exportChecklist(profile: profile)
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
    }

    func testEquipmentLocalizationKeysExist() {
        let keys = [
            "equipment.card.setup",
            "equipment.card.cylinders",
            "equipment.card.gases",
            "equipment.use_in_planner",
            "equipment.generate_checklist",
            "equipment.export.sheet",
            "equipment.setup_mode.dir_twinset",
            "equipment.maintenance.kind.regulator"
        ]
        for key in keys {
            XCTAssertFalse(DIRIOSLocalizer.string(key, language: .english).isEmpty, key)
            XCTAssertFalse(DIRIOSLocalizer.string(key, language: .italian).isEmpty, key)
        }
    }
}
