import Foundation

enum EquipmentSetupMode: String, Codable, Hashable, CaseIterable {
    case recreationalOC
    case dirTwinset
    case technicalOC
    case ccrAirDiluent
    case ccrTrimix
    case sidemount
    case custom

    var localizationKey: String {
        switch self {
        case .recreationalOC: return "equipment.setup_mode.recreational_oc"
        case .dirTwinset: return "equipment.setup_mode.dir_twinset"
        case .technicalOC: return "equipment.setup_mode.technical_oc"
        case .ccrAirDiluent: return "equipment.setup_mode.ccr_air_diluent"
        case .ccrTrimix: return "equipment.setup_mode.ccr_trimix"
        case .sidemount: return "equipment.setup_mode.sidemount"
        case .custom: return "equipment.setup_mode.custom"
        }
    }

    var localizedTitle: String {
        DIRIOSLocalizer.string(localizationKey)
    }

    var isCCR: Bool {
        switch self {
        case .ccrAirDiluent, .ccrTrimix: return true
        default: return false
        }
    }
}

enum EquipmentMaintenanceKind: String, Codable, Hashable, CaseIterable {
    case regulatorService
    case cylinderHydro
    case cylinderVisual
    case oxygenAnalyzerCalibration
    case computerBattery
    case torchBattery
    case ccrOxygenSensors
    case ccrScrubber
    case custom

    var localizationKey: String {
        switch self {
        case .regulatorService: return "equipment.maintenance.kind.regulator"
        case .cylinderHydro: return "equipment.maintenance.kind.cylinder_hydro"
        case .cylinderVisual: return "equipment.maintenance.kind.cylinder_visual"
        case .oxygenAnalyzerCalibration: return "equipment.maintenance.kind.o2_analyzer"
        case .computerBattery: return "equipment.maintenance.kind.computer_battery"
        case .torchBattery: return "equipment.maintenance.kind.torch_battery"
        case .ccrOxygenSensors: return "equipment.maintenance.kind.ccr_o2_sensors"
        case .ccrScrubber: return "equipment.maintenance.kind.ccr_scrubber"
        case .custom: return "equipment.maintenance.kind.custom"
        }
    }

    var localizedTitle: String {
        DIRIOSLocalizer.string(localizationKey)
    }
}

enum EquipmentMaintenanceStatus: Equatable {
    case ok
    case dueSoon
    case overdue
}

struct EquipmentGasCylinder: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var role: GasRole
    var tankSize: TankSize
    var gas: GasMix
    var startPressureBar: Double
    var reservePressureBar: Double
    var switchDepthMeters: Double?
    var isEnabled: Bool = true
    var notes: String = ""

    init(
        id: UUID = UUID(),
        name: String,
        role: GasRole,
        tankSize: TankSize = .liters12,
        gas: GasMix,
        startPressureBar: Double = 200,
        reservePressureBar: Double = 50,
        switchDepthMeters: Double? = nil,
        isEnabled: Bool = true,
        notes: String = ""
    ) {
        self.id = id
        self.name = name
        self.role = role
        self.tankSize = tankSize
        self.gas = gas
        self.startPressureBar = startPressureBar
        self.reservePressureBar = reservePressureBar
        self.switchDepthMeters = switchDepthMeters
        self.isEnabled = isEnabled
        self.notes = notes
    }

    var isPressureValid: Bool {
        startPressureBar.isFinite && startPressureBar >= 0
            && reservePressureBar.isFinite && reservePressureBar >= 0
            && reservePressureBar <= startPressureBar
    }

    var isSwitchDepthValid: Bool {
        guard let switchDepthMeters else { return true }
        return switchDepthMeters.isFinite && switchDepthMeters >= 0
    }
}

struct EquipmentMaintenanceItem: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var title: String
    var kind: EquipmentMaintenanceKind
    var dueDate: Date?
    var lastCheckedAt: Date?
    var isRequired: Bool = true
    var isCompleted: Bool = false
    var notes: String = ""

    init(
        id: UUID = UUID(),
        title: String,
        kind: EquipmentMaintenanceKind,
        dueDate: Date? = nil,
        lastCheckedAt: Date? = nil,
        isRequired: Bool = true,
        isCompleted: Bool = false,
        notes: String = ""
    ) {
        self.id = id
        self.title = title
        self.kind = kind
        self.dueDate = dueDate
        self.lastCheckedAt = lastCheckedAt
        self.isRequired = isRequired
        self.isCompleted = isCompleted
        self.notes = notes
    }
}

enum ChecklistMergeStrategy: Equatable {
    case replace
    case appendMissing
}

struct EquipmentPlannerApplyResult: Equatable {
    let appliedCylinderCount: Int
    let ignoredRoles: [GasRole]
}
