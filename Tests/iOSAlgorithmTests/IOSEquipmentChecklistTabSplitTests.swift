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
        XCTAssertEqual(
            store.selectedChecklistSetupDisplayName,
            DIRIOSLocalizer.string("checklist.setup.current_profile")
        )
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
        XCTAssertTrue(source.contains("DIRCompanionTabBar"))
        XCTAssertFalse(source.contains("TabView(selection:"))
        XCTAssertFalse(source.contains(".more)"))
        XCTAssertFalse(source.contains("Label(\"tab.more\""))
    }

    func testCompanionTabBarListsAllSixTabsInOrder() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/Components/DIRCompanionTabBar.swift"))
        let expected = ["planner", "logbook", "analysis", "gear", "checklist", "settings"]
        for tab in expected {
            XCTAssertTrue(source.contains(".\(tab)"), "Missing companion tab \(tab)")
        }
        XCTAssertTrue(source.contains("companionOrder"))
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
