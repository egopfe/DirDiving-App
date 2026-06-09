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
}
