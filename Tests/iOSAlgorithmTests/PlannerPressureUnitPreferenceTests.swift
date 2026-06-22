import XCTest

final class PlannerPressureUnitPreferenceTests: XCTestCase {
    func testGlobalPressureUnitDefaultsToBarWhenMissing() {
        XCTAssertEqual(IOSPressureUnitPreference.fromStorage(""), .bar)
        XCTAssertEqual(IOSPressureUnitPreference.fromStorage("unknown"), .bar)
    }

    func testGlobalPressureUnitPersistsPSIValue() {
        let stored = IOSPressureUnitPreference.storageValue(for: .psi)
        XCTAssertEqual(IOSPressureUnitPreference.fromStorage(stored), .psi)
    }

    func testDisplayWorkingPressureUsesGlobalBarUnit() {
        var entry = PlannerCylinderEntry(
            role: .bottom,
            gas: GasMix(name: "Air", mixKind: .air, oxygen: 0.21, helium: 0, maxPPO2: 1.4),
            startPressure: 200,
            pressureUnit: .bar
        )
        XCTAssertEqual(PlannerGasEditingSupport.displayWorkingPressure(entry, unit: .bar), 200)
    }

    func testDisplayWorkingPressureUsesGlobalPSIUnit() {
        var entry = PlannerCylinderEntry(
            role: .bottom,
            gas: GasMix(name: "Air", mixKind: .air, oxygen: 0.21, helium: 0, maxPPO2: 1.4),
            startPressure: 200,
            pressureUnit: .bar
        )
        let psi = PlannerGasEditingSupport.displayWorkingPressure(entry, unit: .psi)
        XCTAssertEqual(psi, 2901, accuracy: 1)
    }

    func testApplyWorkingPressureStoresCanonicalBarWithoutDoubleConversion() {
        var entry = PlannerCylinderEntry(
            role: .bottom,
            gas: GasMix(name: "Air", mixKind: .air, oxygen: 0.21, helium: 0, maxPPO2: 1.4),
            startPressure: 200,
            pressureUnit: .bar
        )
        PlannerGasEditingSupport.applyWorkingPressure(3000, unit: .psi, to: &entry)
        XCTAssertEqual(entry.pressureUnit, .psi)
        XCTAssertEqual(entry.cylinder.startPressureBar, 206.8, accuracy: 0.2)
    }

    func testFormattersPressureConversionFromBar() {
        let measurement = Formatters.pressure(fromBar: 200, unit: .psi)
        XCTAssertEqual(measurement.unit, "PSI")
        XCTAssertEqual(Double(measurement.value) ?? 0, 2901, accuracy: 1)
    }

    func testPlannerEditorNoLongerContainsLocalPressureUnitPicker() throws {
        let source = try String(contentsOfFile: plannerEditorSourcePath(), encoding: .utf8)
        XCTAssertFalse(source.contains("pressureUnitBinding"))
        XCTAssertFalse(source.contains("ForEach(PressureUnit.allCases)"))
    }

    func testMoreViewContainsGlobalPressureUnitSelector() throws {
        let source = try String(contentsOfFile: divingSettingsSourcePath(), encoding: .utf8)
        XCTAssertTrue(source.contains("settings.units.pressure.title"))
        XCTAssertTrue(source.contains("sharedSettings.pressureUnit"))
    }

    func testPlannerEditorStillContainsWorkingPressureSection() throws {
        let source = try String(contentsOfFile: plannerEditorSourcePath(), encoding: .utf8)
        XCTAssertTrue(source.contains("planner.gas.editor.working_pressure_section"))
        XCTAssertTrue(source.contains("pressureUnitPreference"))
    }

    private func plannerEditorSourcePath() -> String {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("iOSApp/Views/PlannerCylinderGasEditorView.swift")
            .path
    }

    private func divingSettingsSourcePath() -> String {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("iOSApp/Views/IOSDivingSettingsEmbeddedContent.swift")
            .path
    }

    private func moreViewSourcePath() -> String {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("iOSApp/Views/MoreView.swift")
            .path
    }
}
