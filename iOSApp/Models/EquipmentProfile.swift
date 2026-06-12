import Foundation

struct EquipmentChecklistItem: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var title: String
    var isReady: Bool = false
    var usesGas: Bool = false
    var gasMixKind: GasMixKind = .air
    var gasText: String = ""
    /// Optional gas-switch depth (meters) for deco/travel checklist items synced from the planner.
    var switchDepthMeters: Double? = nil
    var pressureText: String = ""
    var pressureUnit: PressureUnit = .bar
    var tankSize: TankSize = .liters12
    var gasRole: GasRole? = nil
    var kind: ChecklistItemKind = .equipment
    var isRequired: Bool = true
    var completedAt: Date? = nil
    var note: String = ""

    init(
        id: UUID = UUID(),
        title: String,
        isReady: Bool = false,
        usesGas: Bool = false,
        gasMixKind: GasMixKind = .air,
        gasText: String = "",
        switchDepthMeters: Double? = nil,
        pressureText: String = "",
        pressureUnit: PressureUnit = .bar,
        tankSize: TankSize = .liters12,
        gasRole: GasRole? = nil,
        kind: ChecklistItemKind = .equipment,
        isRequired: Bool = true,
        completedAt: Date? = nil,
        note: String = ""
    ) {
        self.id = id
        self.title = title
        self.isReady = isReady
        self.usesGas = usesGas
        self.gasMixKind = gasMixKind
        self.gasText = gasText
        self.switchDepthMeters = switchDepthMeters
        self.pressureText = pressureText
        self.pressureUnit = pressureUnit
        self.tankSize = tankSize
        self.gasRole = gasRole
        self.kind = kind
        self.isRequired = isRequired
        self.completedAt = completedAt
        self.note = note
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        title = try container.decode(String.self, forKey: .title)
        isReady = try container.decodeIfPresent(Bool.self, forKey: .isReady) ?? false
        usesGas = try container.decodeIfPresent(Bool.self, forKey: .usesGas) ?? false
        gasMixKind = try container.decodeIfPresent(GasMixKind.self, forKey: .gasMixKind) ?? .air
        gasText = try container.decodeIfPresent(String.self, forKey: .gasText) ?? ""
        switchDepthMeters = try container.decodeIfPresent(Double.self, forKey: .switchDepthMeters)
        pressureText = try container.decodeIfPresent(String.self, forKey: .pressureText) ?? ""
        pressureUnit = try container.decodeIfPresent(PressureUnit.self, forKey: .pressureUnit) ?? .bar
        tankSize = try container.decodeIfPresent(TankSize.self, forKey: .tankSize) ?? .liters12
        gasRole = try container.decodeIfPresent(GasRole.self, forKey: .gasRole)
        kind = try container.decodeIfPresent(ChecklistItemKind.self, forKey: .kind) ?? .equipment
        isRequired = try container.decodeIfPresent(Bool.self, forKey: .isRequired) ?? true
        completedAt = try container.decodeIfPresent(Date.self, forKey: .completedAt)
        note = try container.decodeIfPresent(String.self, forKey: .note) ?? ""
    }
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

    var requiredChecklistItems: [EquipmentChecklistItem] {
        migratedChecklistItems.filter(\.isRequired)
    }

    var optionalChecklistItems: [EquipmentChecklistItem] {
        migratedChecklistItems.filter { !$0.isRequired }
    }

    var requiredReadyCount: Int {
        requiredChecklistItems.filter(\.isReady).count
    }

    var optionalReadyCount: Int {
        optionalChecklistItems.filter(\.isReady).count
    }

    var isRequiredChecklistComplete: Bool {
        let required = requiredChecklistItems
        guard !required.isEmpty else { return checklistReadyCount == migratedChecklistItems.count }
        return required.allSatisfy(\.isReady)
    }

    var migratedChecklistItems: [EquipmentChecklistItem] {
        if !checklistItems.isEmpty { return checklistItems }
        return [
            EquipmentChecklistItem(title: "Backup mask", isReady: backupMaskReady),
            EquipmentChecklistItem(title: "Spool / SMB", isReady: spoolReady),
            EquipmentChecklistItem(title: "Computer backup", isReady: backupComputerReady)
        ]
    }

    var isDIRConfigurationComplete: Bool {
        DIRChecklistConfigurationEvaluator.isComplete(self)
    }

    mutating func syncLegacyChecklistFlags() {
        guard checklistItems.isEmpty else { return }
        checklistItems = migratedChecklistItems
    }
}
