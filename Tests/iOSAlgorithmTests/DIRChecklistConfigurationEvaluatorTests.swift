import XCTest

final class DIRChecklistConfigurationEvaluatorTests: XCTestCase {
    func testDIRIncompleteWhenChecklistEmpty() {
        var profile = EquipmentProfile()
        profile.checklistItems = []
        profile.backupMaskReady = false
        profile.spoolReady = false
        XCTAssertFalse(DIRChecklistConfigurationEvaluator.isComplete(profile))
    }

    func testDIRIncompleteWhenOneRequiredItemMissing() {
        var profile = EquipmentProfile()
        profile.checklistItems = completeDIRChecklist(missing: "wet note")
        XCTAssertFalse(DIRChecklistConfigurationEvaluator.isComplete(profile))
    }

    func testDIRCompleteWhenAllRequiredItemsReady() {
        var profile = EquipmentProfile()
        profile.checklistItems = completeDIRChecklist()
        XCTAssertTrue(DIRChecklistConfigurationEvaluator.isComplete(profile))
        XCTAssertTrue(profile.isDIRConfigurationComplete)
    }

    func testDIRIncompleteWhenRequiredItemsExistButNotReady() {
        var profile = EquipmentProfile()
        profile.checklistItems = completeDIRChecklist().map {
            var item = $0
            item.isReady = false
            return item
        }
        XCTAssertFalse(DIRChecklistConfigurationEvaluator.isComplete(profile))
    }

    func testGasRequirementTrueForReadyGasItem() {
        var profile = EquipmentProfile()
        profile.checklistItems = completeDIRChecklist().filter { item in
            !normalized(item.title).contains("back gas")
        } + [
            EquipmentChecklistItem(title: "Back gas", isReady: true, usesGas: true)
        ]
        XCTAssertTrue(DIRChecklistConfigurationEvaluator.isComplete(profile))
    }

    func testSignalingBuoyWithSpoolInSameItem() {
        var profile = EquipmentProfile()
        profile.checklistItems = completeDIRChecklist().filter {
            !normalized($0.title).contains("pallone") && !normalized($0.title).contains("smb")
        } + [
            EquipmentChecklistItem(title: "SMB with spool", isReady: true)
        ]
        XCTAssertTrue(DIRChecklistConfigurationEvaluator.isComplete(profile))
    }

    func testSignalingBuoyWithSeparateReadySpoolItems() {
        var profile = EquipmentProfile()
        profile.checklistItems = completeDIRChecklist().filter {
            !normalized($0.title).contains("pallone") && !normalized($0.title).contains("smb")
        } + [
            EquipmentChecklistItem(title: "DSMB", isReady: true),
            EquipmentChecklistItem(title: "Spool", isReady: true)
        ]
        XCTAssertTrue(DIRChecklistConfigurationEvaluator.isComplete(profile))
    }

    func testBiboViaConfigurationAndReadyGas() {
        var profile = EquipmentProfile()
        profile.configuration = "Backmount DIR twinset"
        profile.checklistItems = completeDIRChecklist().filter {
            !normalized($0.title).contains("bibo")
        }
        XCTAssertTrue(DIRChecklistConfigurationEvaluator.isComplete(profile))
    }

    private func completeDIRChecklist(missing: String? = nil) -> [EquipmentChecklistItem] {
        var items = [
            EquipmentChecklistItem(title: "Bibo configurato", isReady: true),
            EquipmentChecklistItem(title: "Backup mask", isReady: true),
            EquipmentChecklistItem(title: "SMB", isReady: true),
            EquipmentChecklistItem(title: "Spool", isReady: true),
            EquipmentChecklistItem(title: "Back gas", isReady: true, usesGas: true, gasText: "TMX 18/45", pressureText: "200"),
            EquipmentChecklistItem(title: "Wet notes", isReady: true),
            EquipmentChecklistItem(title: "Pallone segnalamento con spool", isReady: true)
        ]
        if let missing {
            let needle = normalized(missing)
            items.removeAll { normalized($0.title).contains(needle) }
        }
        return items
    }

    private func normalized(_ text: String) -> String {
        text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .lowercased()
    }
}
