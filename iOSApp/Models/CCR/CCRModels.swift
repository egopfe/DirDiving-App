import Foundation

enum CCRSetpointMode: String, CaseIterable, Identifiable, Codable {
    case automatic
    case manual

    var id: String { rawValue }

    var localizedTitle: String {
        switch self {
        case .automatic: return DIRIOSLocalizer.string("ccr.setpoint.mode.automatic")
        case .manual: return DIRIOSLocalizer.string("ccr.setpoint.mode.manual")
        }
    }
}

enum CCRBailoutScenarioKind: String, CaseIterable, Identifiable, Codable {
    case lostLoop
    case floodedLoop
    case hypoxia
    case hyperoxia
    case manualBailoutAtMaxDepth

    var id: String { rawValue }

    var localizedTitle: String {
        switch self {
        case .lostLoop: return DIRIOSLocalizer.string("ccr.bailout.scenario.lost_loop")
        case .floodedLoop: return DIRIOSLocalizer.string("ccr.bailout.scenario.flooded_loop")
        case .hypoxia: return DIRIOSLocalizer.string("ccr.bailout.scenario.hypoxia")
        case .hyperoxia: return DIRIOSLocalizer.string("ccr.bailout.scenario.hyperoxia")
        case .manualBailoutAtMaxDepth: return DIRIOSLocalizer.string("ccr.bailout.scenario.manual_max_depth")
        }
    }
}

struct CCRDiluent: Codable, Hashable {
    var mixKind: GasMixKind = .air
    var oxygenPercent: Int = 21
    var heliumPercent: Int = 0

    var oxygenFraction: Double { Double(oxygenPercent) / 100.0 }
    var heliumFraction: Double { Double(heliumPercent) / 100.0 }
    var nitrogenFraction: Double { max(0, 1.0 - oxygenFraction - heliumFraction) }

    var label: String {
        switch mixKind {
        case .trimix:
            return "TX \(oxygenPercent)/\(heliumPercent)"
        case .ean where oxygenPercent > 21:
            return "EAN\(oxygenPercent)"
        default:
            return "AIR"
        }
    }

    static let air = CCRDiluent(mixKind: .air, oxygenPercent: 21, heliumPercent: 0)

    mutating func applyMixKind(_ kind: GasMixKind) {
        mixKind = kind
        switch kind {
        case .air:
            oxygenPercent = 21
            heliumPercent = 0
        case .ean:
            heliumPercent = 0
            if oxygenPercent < 22 { oxygenPercent = 32 }
        case .trimix:
            if oxygenPercent < 10 { oxygenPercent = 18 }
            if heliumPercent < 1 { heliumPercent = 35 }
        case .oxygen:
            oxygenPercent = 100
            heliumPercent = 0
        }
    }
}

struct CCRBailoutGas: Identifiable, Codable, Hashable {
    var id = UUID()
    var mixKind: GasMixKind = .air
    var oxygenPercent: Int = 21
    var heliumPercent: Int = 0
    var tankSize: TankSize = .liters12
    var startPressure: Double = 200
    var reservePressure: Double = 50
    var pressureUnit: PressureUnit = .bar
    var switchDepthMeters: Double = 0
    var notes: String = ""

    var oxygenFraction: Double { Double(oxygenPercent) / 100.0 }
    var heliumFraction: Double { Double(heliumPercent) / 100.0 }

    var gasMix: GasMix {
        GasMix(
            name: label,
            role: .bailout,
            mixKind: mixKind,
            oxygen: oxygenFraction,
            helium: heliumFraction,
            maxPPO2: mixKind == .oxygen ? 1.6 : 1.4
        )
    }

    var label: String {
        switch mixKind {
        case .oxygen: return "O2"
        case .trimix: return "TX \(oxygenPercent)/\(heliumPercent)"
        case .ean where oxygenPercent > 21: return "EAN\(oxygenPercent)"
        default: return "AIR"
        }
    }

    var availableGasLiters: Double {
        let startBar = pressureUnit == .bar ? startPressure : IOSUnitConversions.bar(fromPSI: startPressure)
        let reserveBar = pressureUnit == .bar ? reservePressure : IOSUnitConversions.bar(fromPSI: reservePressure)
        guard startBar > reserveBar else { return 0 }
        return tankSize.volumeLiters * (startBar - reserveBar)
    }
}

struct CCRSetpointProfile: Codable, Hashable {
    var lowSetpoint: Double = 0.7
    var highSetpoint: Double = 1.3
    var switchDepthMeters: Double = 20
    var mode: CCRSetpointMode = .automatic
    /// Reserved for a future manual setpoint timeline. Ignored by the CCR engine in this release.
    var runtimeSegments: [CCRSetpointSegment] = []
    /// Manual mode: revert to low setpoint during shallow ascent (reference profile only).
    var useLowSetpointOnShallowAscent: Bool = false
    var shallowAscentSetpointDepthMeters: Double = 6

    func activeSetpointBar(depthMeters: Double, isAscent: Bool = false) -> Double {
        if mode == .manual, useLowSetpointOnShallowAscent, isAscent,
           depthMeters <= shallowAscentSetpointDepthMeters + 0.001 {
            return lowSetpoint
        }
        return depthMeters + 0.001 >= switchDepthMeters ? highSetpoint : lowSetpoint
    }
}

struct CCRSetpointSegment: Identifiable, Codable, Hashable {
    var id = UUID()
    var runtimeMinutes: Double
    var depthMeters: Double
    var setpointBar: Double
    var note: String = ""
}

struct CCRPlanInput: Codable, Hashable {
    var diveMode: String = "ccr"
    var maxDepthMeters: Double = 40
    var averageDepthMeters: Double = 30
    var bottomTimeMinutes: Double = 30
    var gfLow: Double = 30
    var gfHigh: Double = 80
    var setpointProfile: CCRSetpointProfile = CCRSetpointProfile()
    var diluent: CCRDiluent = .air
    var bailoutGases: [CCRBailoutGas] = []
    var rebreatherModel: String = ""
    /// Metadata / persistence only — not used by CCR planner engine math in this release.
    var loopVolumeLiters: Double?
    var oxygenCylinderNotes: String = ""
    var notes: String = ""
    var altitudeMeters: Double = 0
    var salinity: SalinityMode = .salt
    var bailoutSACLitersPerMinute: Double = 25
    var bailoutStressMultiplier: Double = 1.5
    var ascentRateMetersPerMinute: Double = BuhlmannConstants.defaultAscentRateMetersPerMinute
    var descentRateMetersPerMinute: Double = BuhlmannConstants.defaultDescentRateMetersPerMinute

    static let `default` = CCRPlanInput(
        bailoutGases: [CCRBailoutGas(mixKind: .air, switchDepthMeters: 0)]
    )

    var buhlmannPlanningDepthMeters: Double { maxDepthMeters }
}

struct CCRScheduleRow: Identifiable, Hashable {
    let id = UUID()
    let runtimeMinutes: Double
    let depthMeters: Double
    let activeSetpointBar: Double
    let diluentLabel: String
    let ppO2Bar: Double
    let ppN2Bar: Double
    let ppHeBar: Double
    let ceilingMeters: Double?
    let gradientFactor: Double?
    let phase: DiveSegmentKind
    let note: String
}

struct CCRTimelineSample: Hashable {
    let runtimeMinutes: Double
    let depthMeters: Double
    let ppO2Bar: Double
    let ppN2Bar: Double
    let endMeters: Double
    let gasDensityResult: CCRGasDensityResult

    var gasDensityGramsPerLiter: Double? { gasDensityResult.gramsPerLiter }
}

struct CCRCNSTimelineSample: Hashable {
    let runtimeMinutes: Double
    let cnsPercent: Double
}

enum CCRBailoutCalculationMethod: String, Codable, Hashable {
    case heuristic
}

struct CCRBailoutScenarioResult: Identifiable, Hashable {
    let id = UUID()
    let kind: CCRBailoutScenarioKind
    let bailoutStartDepthMeters: Double
    let requiredGasLitersByCylinder: [UUID: Double]
    let availableGasLitersByCylinder: [UUID: Double]
    let status: CCRBailoutScenarioStatus
    let warnings: [String]
    let gasSwitchSequence: [String]
    let referenceNotes: String
    let method: CCRBailoutCalculationMethod
    let limitations: [String]
    let assumptions: [String]
    /// SAC-based reserve estimate — not a Bühlmann OC bailout decompression schedule.
    var isHeuristic: Bool { method == .heuristic }
}

enum CCRBailoutScenarioStatus: String, Hashable {
    case pass
    case warning
    case fail

    var localizedTitle: String {
        switch self {
        case .pass: return DIRIOSLocalizer.string("ccr.bailout.status.pass")
        case .warning: return DIRIOSLocalizer.string("ccr.bailout.status.warning")
        case .fail: return DIRIOSLocalizer.string("ccr.bailout.status.fail")
        }
    }
}

struct CCRPlanValidationResult: Hashable {
    var issues: [CCRPlanIssue] = []
    var isValid: Bool { !issues.contains(where: \.isBlocking) }
}

enum CCRPlanIssue: Hashable {
    case invalidDepth(String)
    case invalidSetpoint(String)
    case invalidGradientFactor(String)
    case invalidDiluent(String)
    case hypoxicDiluent(String)
    case hyperoxicSetpoint(String)
    case ambientBelowSetpoint(String)
    case invalidBailout(String)
    case bailoutMODExceeded(String)
    case missingBailout(String)

    var isBlocking: Bool { true }

    var localizedMessage: String {
        switch self {
        case .invalidDepth(let m), .invalidSetpoint(let m), .invalidGradientFactor(let m), .invalidDiluent(let m),
             .hypoxicDiluent(let m), .hyperoxicSetpoint(let m), .ambientBelowSetpoint(let m),
             .invalidBailout(let m), .bailoutMODExceeded(let m), .missingBailout(let m):
            return m
        }
    }
}

struct CCRPlanResult: Hashable {
    let schedule: [CCRScheduleRow]
    let bailoutScenarios: [CCRBailoutScenarioResult]
    let tissueTrace: BuhlmannTissueHistory
    let oxygenExposure: CCROxygenExposureState
    let ppO2Timeline: [CCRTimelineSample]
    let ppN2Timeline: [CCRTimelineSample]
    let endTimeline: [CCRTimelineSample]
    let gasDensityTimeline: [CCRTimelineSample]
    let cnsTimeline: [CCRCNSTimelineSample]
    let warnings: [PlannerUserFacingMessage]
    let validationResult: CCRPlanValidationResult
    let engineSegments: [BuhlmannRuntimeSegment]
    let ttsMinutes: Int
    let totalRuntimeMinutes: Int
    let decoStops: [DecoStop]
    let depthProfilePoints: [DepthProfilePoint]
    let buhlmannState: BuhlmannModelState

    var cnsFullPlanPercent: Double { oxygenExposure.cnsPercent ?? 0 }
    var cnsDescentBottomPercent: Double { oxygenExposure.descentBottomCNSPercent ?? 0 }
    var otuFullPlan: Double { oxygenExposure.otu ?? 0 }
    var hasAvailableOxygenExposure: Bool { oxygenExposure.isAvailable }

    static let empty = CCRPlanResult(
        schedule: [],
        bailoutScenarios: [],
        tissueTrace: .empty,
        oxygenExposure: .unavailable(reason: .invalidInput),
        ppO2Timeline: [],
        ppN2Timeline: [],
        endTimeline: [],
        gasDensityTimeline: [],
        cnsTimeline: [],
        warnings: [],
        validationResult: CCRPlanValidationResult(),
        engineSegments: [],
        ttsMinutes: 0,
        totalRuntimeMinutes: 0,
        decoStops: [],
        depthProfilePoints: [],
        buhlmannState: .invalidInput
    )
}

struct CCRLogbookMetadata: Codable, Hashable {
    var rebreatherModel: String = ""
    var lowSetpoint: Double = 0.7
    var highSetpoint: Double = 1.3
    var setpointSwitchDepthMeters: Double = 20
    var diluentLabel: String = "AIR"
    var bailoutLabels: [String] = []
    var scrubberNotes: String = ""
    var oxygenSensorNotes: String = ""
    var loopNotes: String = ""
    var bailoutScenarioNotes: String = ""
}
