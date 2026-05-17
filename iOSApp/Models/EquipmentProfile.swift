import Foundation

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

    var checklistReadyCount: Int {
        [backupMaskReady, spoolReady, backupComputerReady].filter { $0 }.count
    }
}
