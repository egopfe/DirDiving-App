import Foundation

enum PressureUnit: String, CaseIterable, Identifiable, Codable {
    case bar = "BAR"
    case psi = "PSI"
    var id: String { rawValue }
}

enum PlannerMode: String, CaseIterable, Identifiable, Codable {
    case base
    case deco
    case technical
    case ccr

    var id: String { rawValue }

    /// Open-circuit modes only (Base / Deco / Technical).
    static var openCircuitModes: [PlannerMode] { [.base, .deco, .technical] }

    /// Persisted raw values for Codable; legacy values decode to the new three-mode model.
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        switch raw {
        case PlannerMode.base.rawValue, "Ricreativa", "recreational":
            self = .base
        case PlannerMode.deco.rawValue, "Avanzata", "advanced":
            self = .deco
        case PlannerMode.technical.rawValue, "Tecnica", "technical", "Cave/Wreck", "overhead":
            self = .technical
        case PlannerMode.ccr.rawValue, "CCR", "ccr":
            self = .ccr
        default:
            self = .base
        }
    }

    var localizedTabTitle: String {
        switch self {
        case .base: return DIRIOSLocalizer.string("planner.mode.base")
        case .deco: return DIRIOSLocalizer.string("planner.mode.deco")
        case .technical: return DIRIOSLocalizer.string("planner.mode.technical")
        case .ccr: return DIRIOSLocalizer.string("planner.mode.ccr")
        }
    }

    var localizedDescription: String {
        switch self {
        case .base: return DIRIOSLocalizer.string("planner.mode.base.description")
        case .deco: return DIRIOSLocalizer.string("planner.mode.deco.description")
        case .technical: return DIRIOSLocalizer.string("planner.mode.technical.description")
        case .ccr: return DIRIOSLocalizer.string("planner.mode.ccr.description")
        }
    }

    var localizedResultTitle: String {
        switch self {
        case .base: return DIRIOSLocalizer.string("planner.result.base.title")
        case .deco: return DIRIOSLocalizer.string("planner.result.deco.title")
        case .technical: return DIRIOSLocalizer.string("planner.result.technical.title")
        case .ccr: return DIRIOSLocalizer.string("planner.result.ccr.title")
        }
    }

    var isCCR: Bool { self == .ccr }
    var isOpenCircuit: Bool { !isCCR }
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
    case ccrDiluent = "CCR Diluent"
    case ccrBailout = "CCR Bailout"
    var id: String { rawValue }

    var localizedTitle: String {
        switch self {
        case .travel: return DIRIOSLocalizer.string("gas.role.travel")
        case .bottom: return DIRIOSLocalizer.string("gas.role.bottom")
        case .deco: return DIRIOSLocalizer.string("gas.role.deco")
        case .bailout: return DIRIOSLocalizer.string("gas.role.bailout")
        case .ccrDiluent: return DIRIOSLocalizer.string("gas.role.ccr_diluent")
        case .ccrBailout: return DIRIOSLocalizer.string("gas.role.ccr_bailout")
        }
    }

    var isOpenCircuitRole: Bool {
        switch self {
        case .bottom, .travel, .deco, .bailout: return true
        case .ccrDiluent, .ccrBailout: return false
        }
    }
}

enum PlanningDepthReference: String, CaseIterable, Identifiable, Codable {
    case maximumDepth
    case averageDepth
    var id: String { rawValue }
}

enum PlannerSwitchDepthRoundingPolicy {
    case floorToMeter
}

enum GasMixKind: String, CaseIterable, Identifiable, Codable {
    case air
    case ean
    case trimix
    case oxygen
    var id: String { rawValue }

    var localizedTitle: String {
        switch self {
        case .air: return DIRIOSLocalizer.string("gas.mix.air")
        case .ean: return DIRIOSLocalizer.string("gas.mix.ean")
        case .trimix: return DIRIOSLocalizer.string("gas.mix.trimix")
        case .oxygen: return DIRIOSLocalizer.string("gas.mix.oxygen")
        }
    }

    /// Short label for compact planner rows (e.g. TX, O₂).
    var plannerPickerTitle: String {
        switch self {
        case .air: return DIRIOSLocalizer.string("gas.mix.air")
        case .ean: return DIRIOSLocalizer.string("gas.mix.ean")
        case .trimix: return DIRIOSLocalizer.string("gas.mix.trimix.short")
        case .oxygen: return DIRIOSLocalizer.string("gas.mix.oxygen.short")
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
        case .ccrDiluent: return 0
        case .ccrBailout: return 6
        }
    }

    /// Maximum safe switch depth derived from environment-aware MOD (whole meters, floored).
    func usableSwitchDepthMeters(
        environment: PlannerEnvironment,
        rounding: PlannerSwitchDepthRoundingPolicy = .floorToMeter
    ) -> Double {
        let mod = modMeters(environment: environment)
        guard mod.isFinite, mod > 0 else { return 0 }
        switch rounding {
        case .floorToMeter:
            return max(0, floor(mod))
        }
    }

    mutating func clampSwitchDepthToMOD(
        environment: PlannerEnvironment,
        rounding: PlannerSwitchDepthRoundingPolicy = .floorToMeter
    ) {
        guard role != .bottom else { return }
        let maxAllowed = usableSwitchDepthMeters(environment: environment, rounding: rounding)
        if switchDepthMeters > maxAllowed + 0.05 {
            switchDepthMeters = maxAllowed
        }
    }

    mutating func updateSwitchDepthAfterGasOrPPO2Change(
        environment: PlannerEnvironment,
        shouldInitializeToMOD: Bool = true,
        rounding: PlannerSwitchDepthRoundingPolicy = .floorToMeter
    ) {
        guard role != .bottom else { return }
        let maxAllowed = usableSwitchDepthMeters(environment: environment, rounding: rounding)
        if shouldInitializeToMOD {
            switchDepthMeters = maxAllowed
        } else {
            clampSwitchDepthToMOD(environment: environment, rounding: rounding)
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
        case .bottom, .ccrDiluent:
            return false
        case .travel, .deco, .bailout, .ccrBailout:
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
    var canEditOxygen: Bool { mixKind == .ean || mixKind == .trimix }
    var canEditHelium: Bool { mixKind == .trimix }

    static func inferredKind(oxygen: Double, helium: Double) -> GasMixKind {
        if helium > 0.001 { return .trimix }
        if oxygen > 0.985 { return .oxygen }
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
        case .oxygen:
            oxygen = 1.0
            helium = 0
        }
        normalizeMixAndPPO2()
    }

    mutating func normalizeMixAndPPO2() {
        maxPPO2 = PlannerGasEditingSupport.normalizePPO2(maxPPO2)
        switch mixKind {
        case .air:
            oxygen = 0.21
            helium = 0
        case .ean:
            helium = 0
            oxygen = PlannerGasEditingSupport.clampOxygenFraction(oxygen, heliumFraction: 0)
        case .trimix:
            helium = PlannerGasEditingSupport.clampHeliumFraction(helium, oxygenFraction: oxygen)
            oxygen = PlannerGasEditingSupport.clampOxygenFraction(oxygen, heliumFraction: helium)
        case .oxygen:
            oxygen = 1.0
            helium = 0
        }
    }

    mutating func setOxygenFraction(_ value: Double) {
        guard canEditOxygen else { return }
        switch mixKind {
        case .air, .oxygen:
            break
        case .ean:
            oxygen = PlannerGasEditingSupport.clampOxygenFraction(value, heliumFraction: 0)
        case .trimix:
            oxygen = PlannerGasEditingSupport.clampOxygenFraction(value, heliumFraction: helium)
        }
    }

    mutating func setOxygenPercent(_ percent: Int) {
        setOxygenFraction(Double(percent) / 100.0)
    }

    mutating func setHeliumFraction(_ value: Double) {
        guard canEditHelium else { return }
        helium = PlannerGasEditingSupport.clampHeliumFraction(value, oxygenFraction: oxygen)
        oxygen = PlannerGasEditingSupport.clampOxygenFraction(oxygen, heliumFraction: helium)
    }

    mutating func setHeliumPercent(_ percent: Int) {
        setHeliumFraction(Double(percent) / 100.0)
    }

    mutating func setMaxPPO2(_ value: Double) {
        maxPPO2 = PlannerGasEditingSupport.normalizePPO2(value)
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

    func cnsDescentBottomExceedsPlannerThreshold(
        checkEnabled: Bool,
        thresholdPercent: Double = PlannerCNSDescentBottomCheckSettings.thresholdPercentDouble
    ) -> Bool {
        checkEnabled && CNSDescentBottomPlannerRule.exceedsPlannerThreshold(
            percent: cnsDescentBottomPercent,
            thresholdPercent: thresholdPercent
        )
    }

    var showsFullPlanOxygenExposureWarning: Bool {
        states.contains(.oxygenExposureElevated)
            || states.contains(.cnsSingleElevated)
            || states.contains(.cnsDailyElevated)
            || states.contains(.otuDiveElevated)
            || states.contains(.otuDailyElevated)
    }

    var showsWeeklyOTUElevatedWarning: Bool {
        states.contains(.otuWeeklyElevated)
    }

    var showsWeeklyOTUMetric: Bool {
        otuWeekly.isFinite && otuWeekly >= 0
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

    /// Clamps non-bottom switch depths to environment-aware MOD; optionally sets changed gas to MOD after O2/PPO2 edit.
    mutating func normalizeSwitchDepthsToMOD(
        environment: PlannerEnvironment? = nil,
        changedCylinderID: UUID? = nil,
        updateChangedGasToMOD: Bool = false
    ) {
        ensurePlannerCylindersFromLegacy()
        let resolvedEnvironment = environment ?? plannerEnvironment
        for index in plannerCylinders.indices {
            if let changedCylinderID, plannerCylinders[index].id != changedCylinderID {
                continue
            }
            if updateChangedGasToMOD {
                plannerCylinders[index].updateSwitchDepthAfterGasOrPPO2Change(
                    environment: resolvedEnvironment,
                    shouldInitializeToMOD: true
                )
            } else {
                plannerCylinders[index].clampSwitchDepthToMOD(environment: resolvedEnvironment)
            }
        }
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
