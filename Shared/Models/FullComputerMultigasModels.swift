import Foundation

enum FullComputerBottomGasKind: String, Codable, CaseIterable, Identifiable, Hashable {
    case air
    case ean
    case trimix

    var id: String { rawValue }
}

enum FullComputerGasAvailability: String, Codable, Hashable {
    case available
    case disabled
    case unavailable
}

enum FullComputerFutureGasTTSPolicy: String, Codable, Hashable {
    /// Enabled deco/travel gases with switch depths feed TTS projection.
    case enabledSwitchGasesOnly
    /// TTS uses active bottom gas only (conservative).
    case activeGasOnly
}

/// Shared multigas definition for Watch Full Computer pre-dive and runtime.
struct FullComputerConfiguredGas: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var role: GasRole
    var oxygenFraction: Double
    var heliumFraction: Double
    var maxPPO2Bar: Double
    var switchDepthMeters: Double
    var isEnabled: Bool
    var availability: FullComputerGasAvailability
    var sortOrder: Int

    var nitrogenFraction: Double {
        max(0, 1.0 - oxygenFraction - heliumFraction)
    }

    init(
        id: UUID = UUID(),
        name: String,
        role: GasRole,
        oxygenFraction: Double,
        heliumFraction: Double,
        maxPPO2Bar: Double,
        switchDepthMeters: Double = 0,
        isEnabled: Bool = true,
        availability: FullComputerGasAvailability = .available,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.name = name
        self.role = role
        self.oxygenFraction = oxygenFraction
        self.heliumFraction = heliumFraction
        self.maxPPO2Bar = maxPPO2Bar
        self.switchDepthMeters = switchDepthMeters
        self.isEnabled = isEnabled
        self.availability = availability
        self.sortOrder = sortOrder
    }

    func toBuhlmannGas() -> BuhlmannGas {
        BuhlmannGas(
            name: name,
            role: role,
            oxygenFraction: oxygenFraction,
            heliumFraction: heliumFraction,
            maxPPO2Bar: maxPPO2Bar,
            switchDepthMeters: switchDepthMeters,
            gasMixId: id
        )
    }

    var displayName: String {
        if !name.isEmpty { return name }
        return toBuhlmannGas().label
    }

    func modMeters(environment: PlannerEnvironment = .seaLevelSaltWater) -> Double? {
        toBuhlmannGas().modMeters(environment: environment)
    }
}

struct FullComputerGasProfile: Codable, Hashable {
    static let currentSchemaVersion = 1

    var schemaVersion: Int
    var bottomGasKind: FullComputerBottomGasKind
    var bottomGas: FullComputerConfiguredGas
    var decoGases: [FullComputerConfiguredGas]
    var travelGases: [FullComputerConfiguredGas]
    var bailoutGases: [FullComputerConfiguredGas]
    var gfLow: Double
    var gfHigh: Double
    var futureGasTTSPolicy: FullComputerFutureGasTTSPolicy

    static var defaultAirGF3070: FullComputerGasProfile {
        FullComputerGasProfile(
            schemaVersion: currentSchemaVersion,
            bottomGasKind: .air,
            bottomGas: .defaultBottomAir,
            decoGases: [],
            travelGases: [],
            bailoutGases: [],
            gfLow: 30,
            gfHigh: 70,
            futureGasTTSPolicy: .enabledSwitchGasesOnly
        )
    }

    var enabledDecoGases: [FullComputerConfiguredGas] {
        decoGases
            .filter { $0.isEnabled && $0.availability != .unavailable }
            .sorted { $0.switchDepthMeters > $1.switchDepthMeters }
    }

    var enabledTravelGases: [FullComputerConfiguredGas] {
        travelGases
            .filter { $0.isEnabled && $0.availability != .unavailable }
            .sorted { $0.switchDepthMeters > $1.switchDepthMeters }
    }

    mutating func applyBottomGasKind(_ kind: FullComputerBottomGasKind) {
        bottomGasKind = kind
        switch kind {
        case .air:
            bottomGas.oxygenFraction = BuhlmannConstants.oxygenFractionAir
            bottomGas.heliumFraction = 0
            bottomGas.name = "Air"
        case .ean:
            if bottomGas.heliumFraction > 0.001 { bottomGas.heliumFraction = 0 }
            if bottomGas.oxygenFraction <= BuhlmannConstants.oxygenFractionAir {
                bottomGas.oxygenFraction = 0.32
            }
            if bottomGas.name.isEmpty || bottomGas.name == "Air" {
                bottomGas.name = "EAN\(Int((bottomGas.oxygenFraction * 100).rounded()))"
            }
        case .trimix:
            if bottomGas.name.isEmpty || bottomGas.name == "Air" {
                bottomGas.name = "Trimix"
            }
        }
        bottomGas.role = .bottom
        bottomGas.switchDepthMeters = 0
    }

    mutating func normalizeSortOrders() {
        let sorted = decoGases.sorted { $0.switchDepthMeters > $1.switchDepthMeters }
        for (index, gas) in sorted.enumerated() {
            if let originalIndex = decoGases.firstIndex(where: { $0.id == gas.id }) {
                decoGases[originalIndex].sortOrder = index
            }
        }
    }
}

extension FullComputerConfiguredGas {
    static var defaultBottomAir: FullComputerConfiguredGas {
        FullComputerConfiguredGas(
            id: UUID(uuidString: "A1B2C3D4-E5F6-4789-A012-3456789ABCDE")!,
            name: "Air",
            role: .bottom,
            oxygenFraction: BuhlmannConstants.oxygenFractionAir,
            heliumFraction: 0,
            maxPPO2Bar: 1.4,
            switchDepthMeters: 0,
            sortOrder: 0
        )
    }

    static func ean50(at depth: Double) -> FullComputerConfiguredGas {
        FullComputerConfiguredGas(
            name: "EAN50",
            role: .deco,
            oxygenFraction: 0.50,
            heliumFraction: 0,
            maxPPO2Bar: 1.6,
            switchDepthMeters: depth,
            sortOrder: 0
        )
    }

    static func oxygen(at depth: Double) -> FullComputerConfiguredGas {
        FullComputerConfiguredGas(
            name: "O2",
            role: .deco,
            oxygenFraction: 0.99,
            heliumFraction: 0,
            maxPPO2Bar: 1.6,
            switchDepthMeters: depth,
            sortOrder: 1
        )
    }
}
