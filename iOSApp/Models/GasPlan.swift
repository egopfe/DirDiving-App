import Foundation

enum PressureUnit: String, CaseIterable, Identifiable, Codable {
    case bar = "BAR"
    case psi = "PSI"
    var id: String { rawValue }
}

enum PlannerMode: String, CaseIterable, Identifiable, Codable {
    case recreational = "Ricreativa"
    case advanced = "Avanzata"
    case technical = "Tecnica"
    case overhead = "Cave/Wreck"
    var id: String { rawValue }
}

enum SalinityMode: String, CaseIterable, Identifiable, Codable {
    case fresh = "Dolce"
    case salt = "Salata"
    var id: String { rawValue }
}

enum GasRole: String, CaseIterable, Identifiable, Codable {
    case bottom = "Fondo"
    case travel = "Travel"
    case deco = "Deco"
    case bailout = "Bailout"
    var id: String { rawValue }

    var localizedTitle: String {
        switch self {
        case .travel: return String(localized: "gas.role.travel")
        case .bottom: return String(localized: "gas.role.bottom")
        case .deco: return String(localized: "gas.role.deco")
        case .bailout: return String(localized: "gas.role.bailout")
        }
    }
}

enum PlanningDepthReference: String, CaseIterable, Identifiable, Codable {
    case maximumDepth
    case averageDepth
    var id: String { rawValue }
}

enum GasMixKind: String, CaseIterable, Identifiable, Codable {
    case air
    case ean
    case trimix
    var id: String { rawValue }

    var localizedTitle: String {
        switch self {
        case .air: return String(localized: "gas.mix.air")
        case .ean: return String(localized: "gas.mix.ean")
        case .trimix: return String(localized: "gas.mix.trimix")
        }
    }
}

struct PlannerCylinderEntry: Identifiable, Codable, Hashable {
    var id = UUID()
    var role: GasRole = .bottom
    var tankSize: TankSize = .liters12
    var gas: GasMix
    /// Gas switch depth (m). Used for deco/travel cylinders; bottom uses planned max depth.
    var switchDepthMeters: Double = 21
    var startPressure: Double = 200
    var reservePressure: Double = 50
    var pressureUnit: PressureUnit = .bar

    init(
        id: UUID = UUID(),
        role: GasRole = .bottom,
        tankSize: TankSize = .liters12,
        gas: GasMix,
        switchDepthMeters: Double? = nil,
        startPressure: Double = 200,
        reservePressure: Double = 50,
        pressureUnit: PressureUnit = .bar
    ) {
        self.id = id
        self.role = role
        self.tankSize = tankSize
        self.gas = gas
        self.switchDepthMeters = switchDepthMeters ?? Self.defaultSwitchDepth(for: role)
        self.startPressure = startPressure
        self.reservePressure = reservePressure
        self.pressureUnit = pressureUnit
    }

    static func defaultSwitchDepth(for role: GasRole) -> Double {
        switch role {
        case .bottom: return 0
        case .travel: return 30
        case .deco: return 21
        case .bailout: return 6
        }
    }

    /// Sea-level saltwater MOD for legacy callers; prefer `modMeters(environment:)`.
    var modMeters: Double {
        modMeters(environment: .seaLevelSaltWater)
    }

    func modMeters(environment: PlannerEnvironment) -> Double {
        PlannerMODValidator.modMeters(oxygenFraction: gas.oxygen, maxPPO2: gas.maxPPO2, environment: environment)
    }

    var isSwitchDepthBeyondMOD: Bool {
        isSwitchDepthBeyondMOD(environment: .seaLevelSaltWater)
    }

    func isSwitchDepthBeyondMOD(environment: PlannerEnvironment) -> Bool {
        switch role {
        case .bottom:
            return false
        case .travel, .deco, .bailout:
            return switchDepthMeters > modMeters(environment: environment) + 0.05
        }
    }

    var cylinder: Cylinder {
        Cylinder(
            name: tankSize.rawValue,
            volumeLiters: tankSize.volumeLiters,
            startPressure: startPressure,
            reservePressure: reservePressure,
            pressureUnit: pressureUnit
        )
    }
}

struct GasMix: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var role: GasRole = .bottom
    var mixKind: GasMixKind = .trimix
    var oxygen: Double
    var helium: Double
    var maxPPO2: Double
    var isOxygenNarcotic: Bool = true
    var nitrogen: Double { 1.0 - oxygen - helium }
    /// Sea-level saltwater MOD for legacy callers; prefer `modMeters(environment:)`.
    var modMeters: Double { modMeters(environment: .seaLevelSaltWater) }

    func modMeters(environment: PlannerEnvironment) -> Double {
        PlannerMODValidator.modMeters(oxygenFraction: oxygen, maxPPO2: maxPPO2, environment: environment)
    }
    var isValidMix: Bool {
        GasMixValidator.validate(oxygen: oxygen, helium: helium, maxPPO2: maxPPO2)
            .states
            .filter { [.invalidInput, .unsupportedGas].contains($0) }
            .isEmpty
    }
    var canEditOxygen: Bool { mixKind != .air }
    var canEditHelium: Bool { mixKind == .trimix }

    static func inferredKind(oxygen: Double, helium: Double) -> GasMixKind {
        if helium > 0.001 { return .trimix }
        if abs(oxygen - 0.21) < 0.005 { return .air }
        return .ean
    }

    mutating func syncMixKindFromComposition() {
        mixKind = Self.inferredKind(oxygen: oxygen, helium: helium)
    }

    mutating func applyMixKind(_ kind: GasMixKind) {
        mixKind = kind
        switch kind {
        case .air:
            oxygen = 0.21
            helium = 0
        case .ean:
            helium = 0
        case .trimix:
            break
        }
        normalizeMixAndPPO2()
    }

    mutating func normalizeMixAndPPO2() {
        maxPPO2 = (maxPPO2 * 10).rounded() / 10
        maxPPO2 = min(max(1.0, maxPPO2), 1.6)
        switch mixKind {
        case .air:
            oxygen = 0.21
            helium = 0
        case .ean:
            helium = 0
            oxygen = min(max(oxygen, 0.10), 1.0)
        case .trimix:
            helium = min(max(helium, 0), 1.0)
            oxygen = min(max(oxygen, 0.10), max(0.10, 1.0 - helium))
        }
    }

    mutating func setOxygenFraction(_ value: Double) {
        guard canEditOxygen else { return }
        switch mixKind {
        case .air:
            break
        case .ean:
            oxygen = min(max(value, 0.10), 1.0)
        case .trimix:
            let capped = min(max(value, 0.10), 1.0 - helium)
            oxygen = capped
        }
    }

    mutating func setHeliumFraction(_ value: Double) {
        guard canEditHelium else { return }
        helium = min(max(value, 0), 1.0 - oxygen)
    }

    mutating func setMaxPPO2(_ value: Double) {
        maxPPO2 = min(max(1.0, (value * 10).rounded() / 10), 1.6)
    }

    enum CodingKeys: String, CodingKey {
        case id, name, role, mixKind, oxygen, helium, maxPPO2, isOxygenNarcotic
    }

    init(
        id: UUID = UUID(),
        name: String,
        role: GasRole = .bottom,
        mixKind: GasMixKind? = nil,
        oxygen: Double,
        helium: Double,
        maxPPO2: Double,
        isOxygenNarcotic: Bool = true
    ) {
        self.id = id
        self.name = name
        self.role = role
        self.oxygen = oxygen
        self.helium = helium
        self.maxPPO2 = maxPPO2
        self.isOxygenNarcotic = isOxygenNarcotic
        self.mixKind = mixKind ?? Self.inferredKind(oxygen: oxygen, helium: helium)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try container.decode(String.self, forKey: .name)
        role = try container.decodeIfPresent(GasRole.self, forKey: .role) ?? .bottom
        oxygen = try container.decode(Double.self, forKey: .oxygen)
        helium = try container.decode(Double.self, forKey: .helium)
        maxPPO2 = try container.decode(Double.self, forKey: .maxPPO2)
        isOxygenNarcotic = try container.decodeIfPresent(Bool.self, forKey: .isOxygenNarcotic) ?? true
        if let decodedKind = try container.decodeIfPresent(GasMixKind.self, forKey: .mixKind) {
            mixKind = decodedKind
        } else {
            mixKind = Self.inferredKind(oxygen: oxygen, helium: helium)
        }
    }
    var surfaceDensityGramsLiter: Double {
        guard isValidMix else { return 0 }
        return oxygen * 1.429 + nitrogen * 1.251 + helium * 0.1786
    }
    var label: String {
        if helium > 0 { return "TX \(Int(oxygen*100))/\(Int(helium*100))" }
        if oxygen > 0.985 { return "O2" }
        if oxygen > 0.21 { return "EAN\(Int(oxygen*100))" }
        return "AIR"
    }
}

struct Cylinder: Codable, Hashable {
    var name: String = "Back gas"
    var volumeLiters: Double = 12
    var startPressure: Double = 200
    var reservePressure: Double = 50
    var pressureUnit: PressureUnit = .bar

    var startPressureBar: Double { pressureUnit == .bar ? startPressure : IOSUnitConversions.bar(fromPSI: startPressure) }
    var reservePressureBar: Double { pressureUnit == .bar ? reservePressure : IOSUnitConversions.bar(fromPSI: reservePressure) }
    var availableGasLiters: Double {
        guard volumeLiters.isFinite,
              volumeLiters > 0,
              startPressureBar.isFinite,
              reservePressureBar.isFinite,
              startPressureBar > reservePressureBar else {
            return 0
        }
        return volumeLiters * (startPressureBar - reservePressureBar)
    }
}

struct TeamMember: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var sacLitersPerMinute: Double
    var cylinder: Cylinder
}

struct TechnicalGasAnalysis: Hashable {
    let gas: GasMix
    let ppO2AtDepth: Double
    let densityAtDepth: Double
    let densityRating: GasDensityRating
    let endMeters: Double
    let eadMeters: Double?
    let consumptionLiters: Double
    let remainingLiters: Double
    let remainingBar: Double
    let rockBottomLiters: Double
    let minimumGasBar: Double
    let turnPressureBar: Double
    let cnsPercent: Double
    /// CNS% integrated only over descent + bottom planner segments (informational; planner-only 15% rule).
    let cnsDescentBottomPercent: Double
    let otu: Double
    let cnsDailyPercent: Double
    let otuDaily24h: Double
    let otuWeekly: Double
    let airBreakRecoveryApplied: Bool
    let warnings: [String]
    let states: [PlannerResultState]
    /// True when consumption/remaining omit ascent/deco schedule (bottom-phase estimate only).
    let usesBottomPhaseConsumptionEstimate: Bool

    var cnsPercentDisplay: String {
        OxygenExposureDisplay.formatCNSPercent(cnsPercent)
    }

    var cnsDailyPercentDisplay: String {
        OxygenExposureDisplay.formatCNSPercent(cnsDailyPercent)
    }

    func cnsDescentBottomExceedsPlannerThreshold(checkEnabled: Bool) -> Bool {
        checkEnabled && CNSDescentBottomPlannerRule.exceedsPlannerThreshold(percent: cnsDescentBottomPercent)
    }

    /// Derived presentation-only difference (full-plan CNS minus descent+bottom); not a separate gas-by-gas model.
    var cnsAscentDecoEstimatePercent: Double {
        let delta = cnsPercent - cnsDescentBottomPercent
        guard delta.isFinite else { return 0 }
        return min(300, max(0, delta))
    }
}

enum GasDensityRating: String, Hashable {
    case green = "GREEN"
    case yellow = "WARNING"
    case red = "DANGER"
}

struct GasPlanInput: Codable, Hashable {
    var cylinder = Cylinder()
    var sacLitersPerMinute: Double = 18
    var emergencySacLitersPerMinute: Double = 30
    var teamSize: Double = 2
    var plannedDepthMeters: Double = 40
    var plannedAverageDepthMeters: Double = 20
    var planningDepthReference: PlanningDepthReference = .maximumDepth
    var plannerCylinders: [PlannerCylinderEntry] = []
    var plannedBottomMinutes: Double = 20
    var waterTemperatureCelsius: Double = 24
    var salinity: SalinityMode = .salt
    var altitudeMeters: Double = 0
    var gfLow: Double = 30
    var gfHigh: Double = 70
    var densityWarningLimit: Double = 5.2
    var densityDangerLimit: Double = 6.2
    var bottomGas = GasMix(name: "Gas di Fondo", role: .bottom, oxygen: 0.18, helium: 0.45, maxPPO2: 1.40)
    var decoGas1 = GasMix(name: "Gas Deco 1", role: .deco, oxygen: 0.50, helium: 0.0, maxPPO2: 1.60)
    var decoGas2 = GasMix(name: "Gas Deco 2", role: .deco, oxygen: 0.80, helium: 0.0, maxPPO2: 1.60)
    var teamMembers: [TeamMember] = [
        TeamMember(name: "Diver A", sacLitersPerMinute: 18, cylinder: Cylinder(name: "Back gas", volumeLiters: 12, startPressure: 200, reservePressure: 50, pressureUnit: .bar)),
        TeamMember(name: "Diver B", sacLitersPerMinute: 20, cylinder: Cylinder(name: "Back gas", volumeLiters: 12, startPressure: 190, reservePressure: 50, pressureUnit: .bar))
    ]
    var startPressureBar: Double { primaryCylinder.startPressureBar }
    var reservePressureBar: Double { primaryCylinder.reservePressureBar }
    var availableGasLiters: Double { primaryCylinder.availableGasLiters }
    var primaryCylinder: Cylinder {
        plannerCylinders.first(where: { $0.role == .bottom })?.cylinder ?? cylinder
    }

    /// Depth used for planning consumption / END / density (not emergency gas).
    var effectivePlanningDepthMeters: Double {
        switch planningDepthReference {
        case .maximumDepth:
            return plannedDepthMeters
        case .averageDepth:
            return min(plannedAverageDepthMeters, plannedDepthMeters)
        }
    }

    /// Conservative depth fed into Buhlmann/MOD safety paths. Average depth is only for consumption summaries.
    var buhlmannPlanningDepthMeters: Double {
        plannedDepthMeters
    }

    var plannerEnvironment: PlannerEnvironment {
        switch PlannerEnvironment.make(altitudeMeters: altitudeMeters, salinity: salinity) {
        case .success(let environment):
            return environment
        case .failure:
            return .seaLevelSaltWater
        }
    }

    var ambientPressureBar: Double {
        if case .success(let environment) = PlannerEnvironment.make(altitudeMeters: altitudeMeters, salinity: salinity),
           let pressure = IOSUnitConversions.ambientPressureBar(depthMeters: effectivePlanningDepthMeters, environment: environment) {
            return pressure
        }
        return IOSUnitConversions.displayOnlyAmbientPressureBar(depthMeters: effectivePlanningDepthMeters)
    }
    var estimatedConsumptionLiters: Double { sacLitersPerMinute * ambientPressureBar * plannedBottomMinutes }
    var estimatedRemainingLiters: Double { availableGasLiters - estimatedConsumptionLiters }
    var estimatedRemainingBar: Double {
        primaryCylinder.volumeLiters > 0 ? estimatedRemainingLiters / primaryCylinder.volumeLiters : 0
    }
    var estimatedRemainingPSI: Double { IOSUnitConversions.psi(fromBar: estimatedRemainingBar) }
    var allGases: [GasMix] {
        if plannerCylinders.isEmpty {
            return [bottomGas, decoGas1, decoGas2]
        }
        return plannerCylinders.map(\.gas)
    }

    mutating func ensurePlannerCylindersFromLegacy() {
        guard plannerCylinders.isEmpty else { return }
        plannerCylinders = [
            PlannerCylinderEntry(
                role: .bottom,
                tankSize: TankSize.nearest(toVolumeLiters: cylinder.volumeLiters),
                gas: bottomGas,
                startPressure: cylinder.startPressure,
                reservePressure: cylinder.reservePressure,
                pressureUnit: cylinder.pressureUnit
            ),
            PlannerCylinderEntry(role: .deco, tankSize: .liters12, gas: decoGas1, switchDepthMeters: 21),
            PlannerCylinderEntry(role: .deco, tankSize: .liters12, gas: decoGas2, switchDepthMeters: 9)
        ]
    }

    mutating func syncLegacyGasesFromPlannerCylinders() {
        ensurePlannerCylindersFromLegacy()
        for index in plannerCylinders.indices {
            plannerCylinders[index].gas.role = plannerCylinders[index].role
        }
        if let bottom = plannerCylinders.first(where: { $0.role == .bottom }) {
            bottomGas = bottom.gas
            cylinder = bottom.cylinder
        }
        let deco = plannerCylinders
            .filter { $0.role == .deco }
            .sorted { $0.switchDepthMeters > $1.switchDepthMeters }
        if deco.indices.contains(0) { decoGas1 = deco[0].gas }
        if deco.indices.contains(1) { decoGas2 = deco[1].gas }
    }

    mutating func normalizeAllPlannerGases() {
        ensurePlannerCylindersFromLegacy()
        for index in plannerCylinders.indices {
            plannerCylinders[index].gas.normalizeMixAndPPO2()
        }
        bottomGas.normalizeMixAndPPO2()
        decoGas1.normalizeMixAndPPO2()
        decoGas2.normalizeMixAndPPO2()
    }

    var hasInvalidGasMix: Bool {
        if plannerCylinders.isEmpty {
            return !bottomGas.isValidMix || !decoGas1.isValidMix || !decoGas2.isValidMix
        }
        return plannerCylinders.contains { !$0.gas.isValidMix }
    }

    /// True when any planner gas is trimix (shows Bühlmann helium limitation disclaimer).
    var includesTrimixGas: Bool {
        if bottomGas.mixKind == .trimix { return true }
        return plannerCylinders.contains { $0.gas.mixKind == .trimix }
    }

    /// Back gas used for simplified Bühlmann NDL (role `.bottom` or legacy `bottomGas`).
    var buhlmannBackGas: GasMix {
        plannerCylinders.first(where: { $0.role == .bottom })?.gas ?? bottomGas
    }

    var buhlmannUsesTrimixBackGas: Bool {
        buhlmannBackGas.mixKind == .trimix
    }
}
