import XCTest

final class EquipmentItemPresentationPolicyTests: XCTestCase {
    func testGenericEquipmentDoesNotShowGasToggle() {
        let mask = EquipmentChecklistItem(title: "Mask", kind: .equipment)
        XCTAssertFalse(EquipmentItemPresentationPolicy.shouldShowGasToggle(for: mask))
        XCTAssertFalse(EquipmentItemPresentationPolicy.shouldShowGasEditor(for: mask))
        XCTAssertEqual(EquipmentItemPresentationPolicy.presentationSection(for: mask), .equipment)
        XCTAssertEqual(EquipmentItemPresentationPolicy.sectionKind(for: mask), .equipment)
    }

    func testGasCylinderItemsShowGasEditorAndGasSection() {
        let backGas = EquipmentChecklistItem(
            title: "Back gas",
            usesGas: true,
            gasText: "TMX 18/45",
            kind: .equipment
        )
        XCTAssertFalse(EquipmentItemPresentationPolicy.shouldShowGasToggle(for: backGas))
        XCTAssertTrue(EquipmentItemPresentationPolicy.shouldShowGasEditor(for: backGas))
        XCTAssertEqual(EquipmentItemPresentationPolicy.presentationSection(for: backGas), .gasAndCylinders)
        XCTAssertEqual(EquipmentItemPresentationPolicy.sectionKind(for: backGas), .gas)
    }

    func testProceduralGasTasksStayInGasSectionWithoutCylinderEditor() {
        let analyze = EquipmentChecklistItem(title: "Analyze gas", kind: .gas)
        XCTAssertFalse(EquipmentItemPresentationPolicy.shouldShowGasEditor(for: analyze))
        XCTAssertEqual(EquipmentItemPresentationPolicy.sectionKind(for: analyze), .gas)
        XCTAssertEqual(EquipmentItemPresentationPolicy.presentationSection(for: analyze), .gasAndCylinders)
    }

    func testGroupingMovesGasLinkedEquipmentToGasSection() {
        let items = [
            EquipmentChecklistItem(title: "Mask", kind: .equipment),
            EquipmentChecklistItem(title: "Back gas", usesGas: true, kind: .equipment),
            EquipmentChecklistItem(title: "Analyze gas", kind: .gas),
            EquipmentChecklistItem(title: "Bubble check", kind: .safety),
        ]
        let grouped = ChecklistItemSupport.groupedIndices(in: items)
        XCTAssertEqual(grouped[.equipment], [0])
        XCTAssertEqual(grouped[.gas]?.sorted(), [1, 2])
        XCTAssertEqual(grouped[.safety], [3])
    }

    func testPersistedGasItemsRemainGasCylinderItems() {
        let json = """
        {"id":"A1B2C3D4-E5F6-7890-ABCD-EF1234567890","title":"Deco stage","usesGas":true,"kind":"equipment","gasText":"EAN50"}
        """
        let item = try! JSONDecoder().decode(EquipmentChecklistItem.self, from: Data(json.utf8))
        XCTAssertTrue(item.usesGas)
        XCTAssertTrue(EquipmentItemPresentationPolicy.shouldShowGasEditor(for: item))
        XCTAssertEqual(EquipmentItemPresentationPolicy.sectionKind(for: item), .gas)
    }

    func testPersistedNonGasItemsRemainGenericEquipment() {
        let json = """
        {"id":"A1B2C3D4-E5F6-7890-ABCD-EF1234567890","title":"Fins","usesGas":false,"kind":"equipment"}
        """
        let item = try! JSONDecoder().decode(EquipmentChecklistItem.self, from: Data(json.utf8))
        XCTAssertFalse(item.usesGas)
        XCTAssertFalse(EquipmentItemPresentationPolicy.shouldShowGasEditor(for: item))
        XCTAssertEqual(EquipmentItemPresentationPolicy.sectionKind(for: item), .equipment)
    }

    func testNewGenericItemCreationPathDoesNotEnableGas() {
        let item = EquipmentChecklistItem(
            title: "Torch",
            isReady: false,
            usesGas: false,
            kind: .equipment,
            isRequired: true
        )
        XCTAssertFalse(item.usesGas)
        XCTAssertFalse(EquipmentItemPresentationPolicy.shouldShowGasToggle(for: item))
    }

    func testNewGasCylinderCreationPathEnablesGasEditor() {
        let item = EquipmentChecklistItem(
            title: "Stage",
            isReady: false,
            usesGas: true,
            kind: .equipment,
            isRequired: true
        )
        XCTAssertTrue(item.usesGas)
        XCTAssertTrue(EquipmentItemPresentationPolicy.shouldShowGasEditor(for: item))
        XCTAssertEqual(EquipmentItemPresentationPolicy.sectionKind(for: item), .gas)
    }

    func testLocalizationKeysExist() throws {
        let en = try loadStrings(named: "en")
        let it = try loadStrings(named: "it")
        let keys = [
            "equipment.add.generic_item",
            "equipment.add.gas_cylinder",
            "equipment.item.gas_cylinder",
            "equipment.item.generic",
            "equipment.gas_separation_notice",
            "checklist.section.gas",
            "checklist.section.equipment",
        ]
        for key in keys {
            XCTAssertFalse(en[key, default: ""].isEmpty, "Missing EN key \(key)")
            XCTAssertFalse(it[key, default: ""].isEmpty, "Missing IT key \(key)")
        }
        XCTAssertEqual(en["equipment.add.gas_cylinder"], "Add gas / cylinder item")
        XCTAssertEqual(it["equipment.add.gas_cylinder"], "Aggiungi gas / bombola")
        XCTAssertEqual(en["checklist.section.gas"], "Gas & Cylinders")
        XCTAssertEqual(it["checklist.section.gas"], "Gas e bombole")
    }

    private func loadStrings(named language: String) throws -> [String: String] {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let url = root.appendingPathComponent("iOSApp/Resources/\(language).lproj/Localizable.strings")
        let contents = try String(contentsOf: url, encoding: .utf8)
        var map: [String: String] = [:]
        let pattern = #""([^"]+)"\s*=\s*"((?:\\.|[^"\\])*)";"#
        let regex = try NSRegularExpression(pattern: pattern)
        let range = NSRange(contents.startIndex..<contents.endIndex, in: contents)
        regex.enumerateMatches(in: contents, range: range) { match, _, _ in
            guard let match, match.numberOfRanges == 3,
                  let keyRange = Range(match.range(at: 1), in: contents),
                  let valueRange = Range(match.range(at: 2), in: contents) else { return }
            map[String(contents[keyRange])] = String(contents[valueRange])
        }
        return map
    }
}
