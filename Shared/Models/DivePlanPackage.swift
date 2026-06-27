import Foundation

struct DivePlanEnvironmentPayload: Codable, Hashable {
    var altitudeMeters: Double
    var salinityRaw: String
    var surfacePressureBar: Double?

    init(altitudeMeters: Double, salinityRaw: String, surfacePressureBar: Double? = nil) {
        self.altitudeMeters = altitudeMeters
        self.salinityRaw = salinityRaw
        self.surfacePressureBar = surfacePressureBar
    }
}

struct DivePlanGasPayload: Codable, Hashable, Identifiable {
    let id: UUID
    var name: String
    var role: GasRole
    var oxygenFraction: Double
    var heliumFraction: Double
    var maxPPO2Bar: Double
    var switchDepthMeters: Double?
    var sortOrder: Int

    init(
        id: UUID = UUID(),
        name: String,
        role: GasRole,
        oxygenFraction: Double,
        heliumFraction: Double,
        maxPPO2Bar: Double,
        switchDepthMeters: Double? = nil,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.name = name
        self.role = role
        self.oxygenFraction = oxygenFraction
        self.heliumFraction = heliumFraction
        self.maxPPO2Bar = maxPPO2Bar
        self.switchDepthMeters = switchDepthMeters
        self.sortOrder = sortOrder
    }
}

struct DivePlanBottomSegmentPayload: Codable, Hashable, Identifiable {
    let id: UUID
    var depthMeters: Double
    var durationMinutes: Double
    var order: Int

    init(id: UUID = UUID(), depthMeters: Double, durationMinutes: Double, order: Int) {
        self.id = id
        self.depthMeters = depthMeters
        self.durationMinutes = durationMinutes
        self.order = order
    }
}

struct DivePlanGasSwitchPayload: Codable, Hashable, Identifiable {
    let id: UUID
    var gasID: UUID
    var switchDepthMeters: Double
    var order: Int

    init(id: UUID = UUID(), gasID: UUID, switchDepthMeters: Double, order: Int) {
        self.id = id
        self.gasID = gasID
        self.switchDepthMeters = switchDepthMeters
        self.order = order
    }
}

struct DivePlanSummaryPayload: Codable, Hashable {
    var modeLabel: String
    var planKind: String
    var maxDepthMeters: Double
    var bottomMinutes: Double
    var totalRuntimeMinutes: Int
    var requiresDeco: Bool
    var decoStopCount: Int
}

struct DivePlanFeatureCapabilities: Codable, Hashable {
    var supportsMultigas: Bool
    var supportsMultilevel: Bool
    var minimumWatchSchemaVersion: Int
    var minimumAlgorithmVersion: String

    static let current = DivePlanFeatureCapabilities(
        supportsMultigas: true,
        supportsMultilevel: true,
        minimumWatchSchemaVersion: 1,
        minimumAlgorithmVersion: DivePlanPackageCodec.algorithmVersion
    )
}

struct DivePlanPackageBody: Codable, Hashable {
    var schemaVersion: Int
    var algorithmVersion: String
    var planID: UUID
    var revision: Int
    var createdAt: Date
    var expiresAt: Date?
    var environment: DivePlanEnvironmentPayload
    var gfLow: Double
    var gfHigh: Double
    /// Optional Watch preset id (`conservative2080`, `standard3070`, `moderate4085`). Legacy packages omit this field.
    var gradientFactorPreset: String?
    var gases: [DivePlanGasPayload]
    var bottomSegments: [DivePlanBottomSegmentPayload]
    var plannedSwitches: [DivePlanGasSwitchPayload]
    var plannerSummary: DivePlanSummaryPayload
    var capabilities: DivePlanFeatureCapabilities
}

struct DivePlanPackage: Codable, Hashable {
    var body: DivePlanPackageBody
    var payloadChecksumSHA256: String
}

enum DivePlanPackageValidationError: Error, Equatable {
    case futureSchema
    case unsupportedSchema
    case checksumMismatch
    case expired
    case invalidGradientFactors
    case invalidGases
    case unsupportedCapabilities
    case decodeFailed
    case invalidEnvironment
}

extension FullComputerGasProfile {
    init(importing package: DivePlanPackage) throws {
        guard let bottomPayload = package.body.gases.first(where: { $0.role == .bottom }) else {
            throw DivePlanPackageValidationError.invalidGases
        }
        let bottomKind = Self.inferBottomKind(from: bottomPayload)
        let bottomGas = FullComputerConfiguredGas(
            id: bottomPayload.id,
            name: bottomPayload.name,
            role: .bottom,
            oxygenFraction: bottomPayload.oxygenFraction,
            heliumFraction: bottomPayload.heliumFraction,
            maxPPO2Bar: bottomPayload.maxPPO2Bar,
            switchDepthMeters: 0,
            isEnabled: true,
            availability: .available,
            sortOrder: 0
        )
        let decoGases: [FullComputerConfiguredGas] = package.body.gases
            .filter { $0.role == .deco }
            .sorted { ($0.switchDepthMeters ?? 0) > ($1.switchDepthMeters ?? 0) }
            .enumerated()
            .map { index, gas in
                FullComputerConfiguredGas(
                    id: gas.id,
                    name: gas.name,
                    role: .deco,
                    oxygenFraction: gas.oxygenFraction,
                    heliumFraction: gas.heliumFraction,
                    maxPPO2Bar: gas.maxPPO2Bar,
                    switchDepthMeters: gas.switchDepthMeters ?? 0,
                    isEnabled: true,
                    availability: .available,
                    sortOrder: index + 1
                )
            }
        self.init(
            schemaVersion: FullComputerGasProfile.currentSchemaVersion,
            bottomGasKind: bottomKind,
            bottomGas: bottomGas,
            decoGases: decoGases,
            travelGases: [],
            bailoutGases: [],
            gfLow: package.body.gfLow,
            gfHigh: package.body.gfHigh,
            futureGasTTSPolicy: .enabledSwitchGasesOnly
        )
    }

    private static func inferBottomKind(from gas: DivePlanGasPayload) -> FullComputerBottomGasKind {
        if gas.heliumFraction > 0.001 { return .trimix }
        if abs(gas.oxygenFraction - 0.21) < 0.01 { return .air }
        return .ean
    }
}
