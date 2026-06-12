import XCTest

@MainActor
final class ChecklistItemKindTests: XCTestCase {
    func testLegacyChecklistItemDecodingDefaultsToEquipment() throws {
        let json = """
        {"id":"A1B2C3D4-E5F6-7890-ABCD-EF1234567890","title":"Backup mask","isReady":true}
        """
        let item = try JSONDecoder().decode(EquipmentChecklistItem.self, from: Data(json.utf8))
        XCTAssertEqual(item.kind, .equipment)
        XCTAssertTrue(item.isRequired)
        XCTAssertNil(item.completedAt)
        XCTAssertEqual(item.note, "")
    }

    func testChecklistItemCanRepresentOperationalTask() {
        let item = EquipmentChecklistItem(
            title: "Analyze gas",
            isReady: false,
            kind: .task,
            isRequired: true
        )
        XCTAssertEqual(item.kind, .task)
        XCTAssertFalse(item.isReady)
        XCTAssertTrue(item.isRequired)
    }

    func testDefaultTemplatesIncludeOperationalTasks() {
        let store = EquipmentStore(cloudSync: nil)
        XCTAssertFalse(store.templates.isEmpty)
        for template in store.templates {
            XCTAssertTrue(
                template.checklistItems.contains { $0.kind == .task || $0.kind == .gas || $0.kind == .safety },
                "Template \(template.name) should include operational tasks"
            )
        }
    }

    func testChecklistSectionsGroupByKind() {
        let items = [
            EquipmentChecklistItem(title: "Mask", kind: .equipment),
            EquipmentChecklistItem(title: "Analyze gas", kind: .gas),
            EquipmentChecklistItem(title: "Team briefing", kind: .task),
            EquipmentChecklistItem(title: "Bubble check", kind: .safety),
        ]
        let grouped = ChecklistItemSupport.groupedIndices(in: items)
        XCTAssertEqual(grouped[.equipment], [0])
        XCTAssertEqual(grouped[.gas], [1])
        XCTAssertEqual(grouped[.task], [2])
        XCTAssertEqual(grouped[.safety], [3])
        XCTAssertEqual(ChecklistItemKind.sectionOrder.first, .equipment)
    }

    func testRequiredCompletionDoesNotCountOptionalAsBlocking() {
        var profile = EquipmentProfile()
        profile.checklistItems = [
            EquipmentChecklistItem(title: "Required task", isReady: true, kind: .task, isRequired: true),
            EquipmentChecklistItem(title: "Optional task", isReady: false, kind: .task, isRequired: false),
        ]
        XCTAssertTrue(profile.isRequiredChecklistComplete)
        XCTAssertEqual(profile.requiredReadyCount, 1)
        XCTAssertEqual(profile.optionalReadyCount, 0)
    }

    func testCompletionTimestampSetAndCleared() {
        var item = EquipmentChecklistItem(title: "Bubble check", kind: .safety)
        XCTAssertNil(item.completedAt)
        ChecklistItemSupport.applyReadyChange(true, to: &item)
        XCTAssertTrue(item.isReady)
        XCTAssertNotNil(item.completedAt)
        ChecklistItemSupport.applyReadyChange(false, to: &item)
        XCTAssertFalse(item.isReady)
        XCTAssertNil(item.completedAt)
    }

    func testDIREvaluatorIgnoresTaskOnlyItemsForGasConfigured() {
        var profile = EquipmentProfile()
        profile.checklistItems = completeDIRChecklist().filter {
            !normalized($0.title).contains("back gas")
        } + [
            EquipmentChecklistItem(title: "Analyze gas", isReady: true, usesGas: false, kind: .task),
        ]
        XCTAssertFalse(DIRChecklistConfigurationEvaluator.isComplete(profile))

        profile.checklistItems = completeDIRChecklist()
        XCTAssertTrue(DIRChecklistConfigurationEvaluator.isComplete(profile))
    }

    func testGasLinkedItemsStillMapToPlanner() {
        let item = EquipmentChecklistItem(
            title: "Back gas",
            usesGas: true,
            gasText: "TMX 18/45",
            kind: .equipment
        )
        XCTAssertEqual(ChecklistPlannerSyncMapper.resolvedRole(for: item), .bottom)
        let line = ChecklistPDFBuilder.exportLine(for: item, unitPreference: .metric)
        XCTAssertTrue(line.contains("Back gas"))
    }

    func testLocalizationKeysExist() throws {
        let en = try loadStrings(named: "en")
        let it = try loadStrings(named: "it")
        let keys = [
            "checklist.title",
            "checklist.subtitle",
            "checklist.section.equipment",
            "checklist.section.gas",
            "checklist.section.task",
            "checklist.quick.analyze_gas",
            "checklist.quick.send_watch_briefing",
            "checklist.status.required_badge_format",
        ]
        for key in keys {
            XCTAssertEqual(en[key], en[key])
            XCTAssertEqual(it[key], it[key])
            XCTAssertFalse(en[key, default: ""].isEmpty, "Missing EN key \(key)")
            XCTAssertFalse(it[key, default: ""].isEmpty, "Missing IT key \(key)")
        }
        XCTAssertEqual(en["checklist.title"], "Pre-Dive Checklist")
        XCTAssertEqual(it["checklist.title"], "Checklist pre-immersione")
    }

    func testPDFExportStillHandlesChecklist() throws {
        var profile = EquipmentProfile()
        profile.checklistItems = [
            EquipmentChecklistItem(title: "Mask", isReady: false, kind: .equipment),
            EquipmentChecklistItem(title: "Analyze gas", isReady: false, kind: .gas),
            EquipmentChecklistItem(title: "Bubble check", isReady: true, kind: .safety, completedAt: Date()),
        ]
        let data = ChecklistPDFBuilder.build(profile: profile)
        XCTAssertFalse(data.isEmpty)
        let url = try PDFExportService.exportChecklist(profile: profile)
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
    }

    private func completeDIRChecklist() -> [EquipmentChecklistItem] {
        [
            EquipmentChecklistItem(title: "Bibo configurato", isReady: true, kind: .equipment),
            EquipmentChecklistItem(title: "Backup mask", isReady: true, kind: .equipment),
            EquipmentChecklistItem(title: "SMB", isReady: true, kind: .equipment),
            EquipmentChecklistItem(title: "Spool", isReady: true, kind: .equipment),
            EquipmentChecklistItem(title: "Back gas", isReady: true, usesGas: true, gasText: "TMX 18/45", pressureText: "200", kind: .equipment),
            EquipmentChecklistItem(title: "Wet notes", isReady: true, kind: .equipment),
            EquipmentChecklistItem(title: "Pallone segnalamento con spool", isReady: true, kind: .equipment),
        ]
    }

    private func normalized(_ text: String) -> String {
        text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .lowercased()
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
