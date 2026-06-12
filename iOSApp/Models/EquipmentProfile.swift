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
    var activeSetupName: String = "Default Setup"
    var setupMode: EquipmentSetupMode = .dirTwinset
    var structuredCylinders: [EquipmentGasCylinder] = []
    var maintenanceItems: [EquipmentMaintenanceItem] = []

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

    init(
        cylinders: String = "2 x 12 L",
        configuration: String = "Backmount DIR",
        bottomGas: String = "TRIMIX 18/45",
        decoGas1: String = "EAN50",
        decoGas2: String = "EAN80",
        sacLitersMinute: Double = 18,
        backupMaskReady: Bool = true,
        spoolReady: Bool = true,
        backupComputerReady: Bool = true,
        checklistItems: [EquipmentChecklistItem] = [],
        activeSetupName: String = "Default Setup",
        setupMode: EquipmentSetupMode = .dirTwinset,
        structuredCylinders: [EquipmentGasCylinder] = [],
        maintenanceItems: [EquipmentMaintenanceItem] = []
    ) {
        self.cylinders = cylinders
        self.configuration = configuration
        self.bottomGas = bottomGas
        self.decoGas1 = decoGas1
        self.decoGas2 = decoGas2
        self.sacLitersMinute = sacLitersMinute
        self.backupMaskReady = backupMaskReady
        self.spoolReady = spoolReady
        self.backupComputerReady = backupComputerReady
        self.checklistItems = checklistItems
        self.activeSetupName = activeSetupName
        self.setupMode = setupMode
        self.structuredCylinders = structuredCylinders
        self.maintenanceItems = maintenanceItems
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        cylinders = try container.decodeIfPresent(String.self, forKey: .cylinders) ?? "2 x 12 L"
        configuration = try container.decodeIfPresent(String.self, forKey: .configuration) ?? "Backmount DIR"
        bottomGas = try container.decodeIfPresent(String.self, forKey: .bottomGas) ?? "TRIMIX 18/45"
        decoGas1 = try container.decodeIfPresent(String.self, forKey: .decoGas1) ?? "EAN50"
        decoGas2 = try container.decodeIfPresent(String.self, forKey: .decoGas2) ?? "EAN80"
        sacLitersMinute = try container.decodeIfPresent(Double.self, forKey: .sacLitersMinute) ?? 18
        backupMaskReady = try container.decodeIfPresent(Bool.self, forKey: .backupMaskReady) ?? true
        spoolReady = try container.decodeIfPresent(Bool.self, forKey: .spoolReady) ?? true
        backupComputerReady = try container.decodeIfPresent(Bool.self, forKey: .backupComputerReady) ?? true
        checklistItems = try container.decodeIfPresent([EquipmentChecklistItem].self, forKey: .checklistItems) ?? []
        activeSetupName = try container.decodeIfPresent(String.self, forKey: .activeSetupName) ?? "Default Setup"
        setupMode = try container.decodeIfPresent(EquipmentSetupMode.self, forKey: .setupMode) ?? .dirTwinset
        structuredCylinders = try container.decodeIfPresent([EquipmentGasCylinder].self, forKey: .structuredCylinders) ?? []
        maintenanceItems = try container.decodeIfPresent([EquipmentMaintenanceItem].self, forKey: .maintenanceItems) ?? []
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(cylinders, forKey: .cylinders)
        try container.encode(configuration, forKey: .configuration)
        try container.encode(bottomGas, forKey: .bottomGas)
        try container.encode(decoGas1, forKey: .decoGas1)
        try container.encode(decoGas2, forKey: .decoGas2)
        try container.encode(sacLitersMinute, forKey: .sacLitersMinute)
        try container.encode(backupMaskReady, forKey: .backupMaskReady)
        try container.encode(spoolReady, forKey: .spoolReady)
        try container.encode(backupComputerReady, forKey: .backupComputerReady)
        try container.encode(checklistItems, forKey: .checklistItems)
        try container.encode(activeSetupName, forKey: .activeSetupName)
        try container.encode(setupMode, forKey: .setupMode)
        try container.encode(structuredCylinders, forKey: .structuredCylinders)
        try container.encode(maintenanceItems, forKey: .maintenanceItems)
    }

    private enum CodingKeys: String, CodingKey {
        case cylinders, configuration, bottomGas, decoGas1, decoGas2, sacLitersMinute
        case backupMaskReady, spoolReady, backupComputerReady, checklistItems
        case activeSetupName, setupMode, structuredCylinders, maintenanceItems
    }
}
