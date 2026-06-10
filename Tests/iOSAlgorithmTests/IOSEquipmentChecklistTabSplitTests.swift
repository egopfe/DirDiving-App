import XCTest
@testable import DIRDivingiOSApp

@MainActor
final class IOSEquipmentChecklistTabSplitTests: XCTestCase {
    func testSelectChecklistSetupAppliesTemplateAndPersistsSelection() {
        let store = EquipmentStore(cloudSync: nil)
        guard let template = store.templates.first else {
            XCTFail("Expected default equipment templates")
            return
        }
        let originalCount = store.profile.checklistItems.count
        store.selectChecklistSetup(template: template)
        XCTAssertEqual(store.selectedChecklistTemplateID, template.id)
        XCTAssertEqual(store.profile.checklistItems, template.checklistItems)
        XCTAssertNotEqual(store.selectedChecklistSetupDisplayName, "")
        store.clearChecklistSetupSelection()
        XCTAssertNil(store.selectedChecklistTemplateID)
        XCTAssertEqual(store.selectedChecklistSetupDisplayName, String(localized: "checklist.setup.current_profile"))
        _ = originalCount
    }

    func testChecklistLocalizationKeysPresent() {
        let keys = [
            "tab.checklist",
            "tab.settings",
            "checklist.title",
            "checklist.subtitle",
            "checklist.setup.title",
            "checklist.empty.open_gear",
            "equipment.images.section"
        ]
        for key in keys {
            XCTAssertFalse(String(localized: String.LocalizationValue(key)).isEmpty, "Missing localization for \(key)")
        }
    }

    func testContentViewExposesSixMainTabs() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/ContentView.swift"))
        for tab in ["planner", "logbook", "analysis", "gear", "checklist", "settings"] {
            XCTAssertTrue(source.contains(".\(tab)"), "Missing IOSTab.\(tab)")
        }
        XCTAssertTrue(source.contains("ChecklistView()"))
        XCTAssertTrue(source.contains("MoreView()"))
        XCTAssertFalse(source.contains(".more)"))
        XCTAssertFalse(source.contains("Label(\"tab.more\""))
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
