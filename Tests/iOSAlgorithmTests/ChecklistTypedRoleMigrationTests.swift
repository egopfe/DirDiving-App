import XCTest

final class ChecklistTypedRoleMigrationTests: XCTestCase {
    func testLegacyTitleMigrationPersistsGasRole() {
        var items = [
            EquipmentChecklistItem(title: "Back gas", usesGas: true, gasText: "Air"),
            EquipmentChecklistItem(title: "Deco stage", usesGas: true, gasText: "EAN50"),
            EquipmentChecklistItem(title: "Custom cylinder", usesGas: true, gasText: "Air"),
        ]
        let migrated = ChecklistRoleMigration.migrateLegacyRoles(in: &items)
        XCTAssertEqual(migrated, 2)
        XCTAssertEqual(items[0].gasRole, .bottom)
        XCTAssertEqual(items[1].gasRole, .deco)
        XCTAssertNil(items[2].gasRole)
    }

    func testResolvedRoleDoesNotInferFromLocalizedTitle() {
        let item = EquipmentChecklistItem(title: "Attrezzatura personalizzata", usesGas: true, gasText: "Air")
        XCTAssertNil(ChecklistPlannerSyncMapper.resolvedRole(for: item))
        var migrated = [item]
        ChecklistRoleMigration.migrateLegacyRoles(in: &migrated)
        XCTAssertNil(migrated[0].gasRole)
    }

    func testCCRRolesRemainDistinctAfterMigration() {
        var items = [
            EquipmentChecklistItem(title: "CCR diluent", usesGas: true, gasRole: .ccrDiluent),
            EquipmentChecklistItem(title: "Bailout 1", usesGas: true, gasRole: .ccrBailout),
        ]
        ChecklistRoleMigration.migrateLegacyRoles(in: &items)
        XCTAssertEqual(items[0].gasRole, .ccrDiluent)
        XCTAssertEqual(items[1].gasRole, .ccrBailout)
    }

    @MainActor
    func testEquipmentStoreTemplatesHaveTypedGasRoles() {
        let store = EquipmentStore(cloudSync: nil)
        let tec = store.templates.first { $0.name == DIRIOSLocalizer.string("equipment.template.tec") }
        XCTAssertNotNil(tec)
        let back = tec!.checklistItems.first { $0.title == "Back gas" }
        let deco = tec!.checklistItems.first { $0.title == "Deco stage" }
        XCTAssertEqual(back?.gasRole, .bottom)
        XCTAssertEqual(deco?.gasRole, .deco)
    }
}
