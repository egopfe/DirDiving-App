import Foundation

struct EquipmentChecklistItem: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var title: String
    var isReady: Bool = false
    var usesGas: Bool = false
    var gasText: String = ""
    var pressureText: String = ""
    var tankSize: TankSize = .liters12
}

struct EquipmentTemplate: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var checklistItems: [EquipmentChecklistItem]
}

struct EquipmentProfile: Codable, Hashable {
    var cylinders: String = "2 x 12 L"
    var configuration: String = "Backmount DIR"
    var bottomGas: String = "TRIMIX 18/45"
    var decoGas1: String = "EAN50"
    var decoGas2: String = "EAN80"
    var sacLitersMinute: Double = 18
    var backupMaskReady: Bool = true
    var spoolReady: Bool = true
    var backupComputerReady: Bool = true
    var checklistItems: [EquipmentChecklistItem] = []

    var checklistReadyCount: Int {
        migratedChecklistItems.filter(\.isReady).count
    }

    var migratedChecklistItems: [EquipmentChecklistItem] {
        if !checklistItems.isEmpty { return checklistItems }
        return [
            EquipmentChecklistItem(title: "Backup mask", isReady: backupMaskReady),
            EquipmentChecklistItem(title: "Spool / SMB", isReady: spoolReady),
            EquipmentChecklistItem(title: "Computer backup", isReady: backupComputerReady)
        ]
    }

    mutating func syncLegacyChecklistFlags() {
        guard checklistItems.isEmpty else { return }
        checklistItems = migratedChecklistItems
    }
}
