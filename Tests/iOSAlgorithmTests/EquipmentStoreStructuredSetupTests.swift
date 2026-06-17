import XCTest

@MainActor
final class EquipmentStoreStructuredSetupTests: XCTestCase {
    func testAddUpdateDeleteStructuredCylinder() {
        let store = EquipmentStore(cloudSync: nil)
        let cylinder = EquipmentGasCylinder(
            name: "Back",
            role: .bottom,
            tankSize: .liters12,
            gas: EquipmentStructuredSupport.defaultBottomGas(named: "TRIMIX 18/45")
        )
        store.addCylinder(cylinder)
        XCTAssertEqual(store.profile.structuredCylinders.count, 1)

        var updated = cylinder
        updated.startPressureBar = 220
        store.updateCylinder(updated)
        XCTAssertEqual(store.profile.structuredCylinders.first?.startPressureBar, 220)

        store.deleteCylinder(id: cylinder.id)
        XCTAssertTrue(store.profile.structuredCylinders.isEmpty)
    }

    func testAddUpdateDeleteMaintenanceItem() {
        let store = EquipmentStore(cloudSync: nil)
        let item = EquipmentMaintenanceItem(title: "Reg service", kind: .regulatorService)
        store.addMaintenanceItem(item)
        XCTAssertEqual(store.profile.maintenanceItems.count, 1)

        var updated = item
        updated.title = "Annual reg service"
        store.updateMaintenanceItem(updated)
        XCTAssertEqual(store.profile.maintenanceItems.first?.title, "Annual reg service")

        store.markMaintenanceItem(id: item.id, completed: true)
        XCTAssertTrue(store.profile.maintenanceItems.first?.isCompleted == true)

        store.deleteMaintenanceItem(id: item.id)
        XCTAssertTrue(store.profile.maintenanceItems.isEmpty)
    }

    func testResetStructuredCylindersFromLegacy() {
        let store = EquipmentStore(cloudSync: nil)
        store.profile.structuredCylinders = []
        store.profile.bottomGas = "Air"
        store.profile.decoGas1 = "EAN50"
        store.resetStructuredCylindersFromLegacy()
        XCTAssertGreaterThanOrEqual(store.profile.structuredCylinders.count, 2)
    }

    func testGenerateChecklistFromCurrentSetupDoesNotDeleteUserItems() {
        let store = EquipmentStore(cloudSync: nil)
        store.profile.checklistItems = [
            EquipmentChecklistItem(title: "Custom user task", kind: .custom)
        ]
        store.profile.structuredCylinders = [
            EquipmentGasCylinder(
                name: "Back",
                role: .bottom,
                tankSize: .liters12,
                gas: EquipmentStructuredSupport.defaultBottomGas(named: "Air")
            )
        ]
        let before = store.profile.checklistItems.count
        let added = store.generateChecklistFromCurrentSetup(mergeStrategy: .appendMissing)
        XCTAssertGreaterThan(added, 0)
        XCTAssertGreaterThan(store.profile.checklistItems.count, before)
        XCTAssertTrue(store.profile.checklistItems.contains(where: { $0.title == "Custom user task" }))
    }
}
