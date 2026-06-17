import XCTest

final class EquipmentProfileStructuredModelTests: XCTestCase {
    func testLegacyEquipmentProfileDecodesWithStructuredDefaults() throws {
        let json = """
        {
          "cylinders": "2 x 12 L",
          "configuration": "Backmount DIR",
          "bottomGas": "TRIMIX 18/45",
          "decoGas1": "EAN50",
          "decoGas2": "EAN80",
          "sacLitersMinute": 18,
          "backupMaskReady": true,
          "spoolReady": true,
          "backupComputerReady": true,
          "checklistItems": []
        }
        """
        let data = try XCTUnwrap(json.data(using: .utf8))
        let profile = try JSONDecoder().decode(EquipmentProfile.self, from: data)
        XCTAssertEqual(profile.cylinders, "2 x 12 L")
        XCTAssertEqual(profile.bottomGas, "TRIMIX 18/45")
        XCTAssertTrue(profile.structuredCylinders.isEmpty)
        XCTAssertTrue(profile.maintenanceItems.isEmpty)
        XCTAssertEqual(profile.setupMode, .dirTwinset)
    }

    func testEffectiveCylindersUsesStructuredWhenAvailable() {
        var profile = EquipmentProfile()
        let cylinder = EquipmentGasCylinder(
            name: "Back",
            role: .bottom,
            tankSize: .liters12,
            gas: EquipmentStructuredSupport.defaultBottomGas(named: "Air"),
            startPressureBar: 200,
            reservePressureBar: 50
        )
        profile.structuredCylinders = [cylinder]
        XCTAssertEqual(profile.effectiveCylinders.count, 1)
        XCTAssertEqual(profile.effectiveCylinders.first?.name, "Back")
        XCTAssertTrue(profile.hasStructuredSetup)
    }

    func testEffectiveCylindersFallbackDoesNotCrashWithLegacyStrings() {
        var profile = EquipmentProfile()
        profile.structuredCylinders = []
        profile.bottomGas = "Air"
        profile.decoGas1 = "EAN50"
        let derived = profile.effectiveCylinders
        XCTAssertGreaterThanOrEqual(derived.count, 2)
        XCTAssertFalse(profile.hasStructuredSetup)
    }

    func testEnabledCylindersFiltersDisabled() {
        var profile = EquipmentProfile()
        profile.structuredCylinders = [
            EquipmentGasCylinder(
                name: "Back",
                role: .bottom,
                tankSize: .liters12,
                gas: EquipmentStructuredSupport.defaultBottomGas(named: "Air"),
                isEnabled: true
            ),
            EquipmentGasCylinder(
                name: "Stage",
                role: .deco,
                tankSize: .liters12,
                gas: EquipmentStructuredSupport.defaultDecoGas(named: "EAN50", oxygen: 0.5),
                isEnabled: false
            )
        ]
        XCTAssertEqual(profile.enabledCylinders.count, 1)
    }

    func testMaintenanceStatusOverdueDueSoonAndOk() {
        let calendar = Calendar.current
        let overdue = EquipmentMaintenanceItem(
            title: "Reg",
            kind: .regulatorService,
            dueDate: calendar.date(byAdding: .day, value: -2, to: Date())
        )
        let dueSoon = EquipmentMaintenanceItem(
            title: "Hydro",
            kind: .cylinderHydro,
            dueDate: calendar.date(byAdding: .day, value: 10, to: Date())
        )
        let ok = EquipmentMaintenanceItem(
            title: "Battery",
            kind: .computerBattery,
            dueDate: calendar.date(byAdding: .day, value: 90, to: Date())
        )
        XCTAssertEqual(EquipmentStructuredSupport.maintenanceStatus(for: overdue), .overdue)
        XCTAssertEqual(EquipmentStructuredSupport.maintenanceStatus(for: dueSoon), .dueSoon)
        XCTAssertEqual(EquipmentStructuredSupport.maintenanceStatus(for: ok), .ok)
    }

    func testCompletedMaintenanceIsNotOverdue() {
        let item = EquipmentMaintenanceItem(
            title: "Reg",
            kind: .regulatorService,
            dueDate: Calendar.current.date(byAdding: .day, value: -5, to: Date()),
            isCompleted: true
        )
        XCTAssertEqual(EquipmentStructuredSupport.maintenanceStatus(for: item), .ok)
    }
}
