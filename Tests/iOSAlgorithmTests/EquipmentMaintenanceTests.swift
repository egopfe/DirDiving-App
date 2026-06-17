import XCTest

final class EquipmentMaintenanceTests: XCTestCase {
    func testMaintenanceOverdueStatus() {
        let item = EquipmentMaintenanceItem(
            title: "Hydro",
            kind: .cylinderHydro,
            dueDate: Calendar.current.date(byAdding: .day, value: -1, to: Date())
        )
        XCTAssertEqual(EquipmentStructuredSupport.maintenanceStatus(for: item), .overdue)
    }

    func testMaintenanceDueSoonStatus() {
        let item = EquipmentMaintenanceItem(
            title: "Visual",
            kind: .cylinderVisual,
            dueDate: Calendar.current.date(byAdding: .day, value: 14, to: Date())
        )
        XCTAssertEqual(EquipmentStructuredSupport.maintenanceStatus(for: item), .dueSoon)
    }

    func testCompletedMaintenanceIsNotOverdue() {
        let item = EquipmentMaintenanceItem(
            title: "Analyzer",
            kind: .oxygenAnalyzerCalibration,
            dueDate: Calendar.current.date(byAdding: .day, value: -10, to: Date()),
            isCompleted: true
        )
        XCTAssertEqual(EquipmentStructuredSupport.maintenanceStatus(for: item), .ok)
    }

    @MainActor
    func testAddDueMaintenanceToChecklist() {
        let store = EquipmentStore(cloudSync: nil)
        store.addMaintenanceItem(
            EquipmentMaintenanceItem(
                title: "Reg overdue",
                kind: .regulatorService,
                dueDate: Calendar.current.date(byAdding: .day, value: -3, to: Date())
            )
        )
        let added = store.addDueMaintenanceToChecklist()
        XCTAssertEqual(added, 1)
        XCTAssertFalse(store.profile.checklistItems.isEmpty)
    }
}
