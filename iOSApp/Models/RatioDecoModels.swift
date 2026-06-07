import Foundation

enum PlannerDecompressionMethod: String, CaseIterable, Identifiable, Codable {
    case buhlmann
    case ratioDeco
    case comparison

    var id: String { rawValue }

    var localizedTitle: String {
        switch self {
        case .buhlmann: return String(localized: "planner.deco_method.buhlmann")
        case .ratioDeco: return String(localized: "planner.deco_method.ratio_deco")
        case .comparison: return String(localized: "planner.deco_method.comparison")
        }
    }
}

enum RatioDecoRatioType: String, Codable, CaseIterable, Identifiable {
    case oneToOne
    case twoToOne
    case custom

    var id: String { rawValue }

    var localizedTitle: String {
        switch self {
        case .oneToOne: return String(localized: "planner.ratio_deco.ratio.1_1")
        case .twoToOne: return String(localized: "planner.ratio_deco.ratio.2_1")
        case .custom: return String(localized: "planner.ratio_deco.ratio.custom")
        }
    }
}

enum RatioDecoDistributionMode: String, Codable, CaseIterable, Identifiable {
    case balanced
    case shallowWeighted
    case linear

    var id: String { rawValue }

    var localizedTitle: String {
        switch self {
        case .balanced: return String(localized: "planner.ratio_deco.distribution.balanced")
        case .shallowWeighted: return String(localized: "planner.ratio_deco.distribution.shallow_weighted")
        case .linear: return String(localized: "planner.ratio_deco.distribution.linear")
        }
    }
}

struct RatioDecoPreset: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var ratioType: RatioDecoRatioType
    var customRatioDenominator: Double
    var firstStopDepthMeters: Double
    var stopStepMeters: Double
    var minimumStopMinutes: Double
    var distributionMode: RatioDecoDistributionMode
    var deepStopsEnabled: Bool
    var notes: String

    static let builtIn1to1ID = UUID(uuidString: "00000000-0000-4000-8000-000000000001")!
    static let builtIn2to1ID = UUID(uuidString: "00000000-0000-4000-8000-000000000002")!
    static let customPresetID = UUID(uuidString: "00000000-0000-4000-8000-000000000003")!

    static var preset1to1: RatioDecoPreset {
        RatioDecoPreset(
            id: builtIn1to1ID,
            name: String(localized: "planner.ratio_deco.preset.1_1"),
            ratioType: .oneToOne,
            customRatioDenominator: 1,
            firstStopDepthMeters: 21,
            stopStepMeters: 3,
            minimumStopMinutes: 1,
            distributionMode: .balanced,
            deepStopsEnabled: false,
            notes: ""
        )
    }

    static var preset2to1: RatioDecoPreset {
        RatioDecoPreset(
            id: builtIn2to1ID,
            name: String(localized: "planner.ratio_deco.preset.2_1"),
            ratioType: .twoToOne,
            customRatioDenominator: 2,
            firstStopDepthMeters: 21,
            stopStepMeters: 3,
            minimumStopMinutes: 1,
            distributionMode: .balanced,
            deepStopsEnabled: false,
            notes: ""
        )
    }

    static var customDefault: RatioDecoPreset {
        RatioDecoPreset(
            id: customPresetID,
            name: String(localized: "planner.ratio_deco.preset.custom"),
            ratioType: .custom,
            customRatioDenominator: 1.5,
            firstStopDepthMeters: 21,
            stopStepMeters: 3,
            minimumStopMinutes: 1,
            distributionMode: .balanced,
            deepStopsEnabled: false,
            notes: ""
        )
    }

    var isBuiltIn: Bool {
        id == Self.builtIn1to1ID || id == Self.builtIn2to1ID
    }

    /// V1 heuristic: 1:1 → total deco ≈ bottom time; 2:1 → total deco ≈ bottom time / 2; custom uses denominator.
    func estimatedTotalDecoMinutes(bottomTimeMinutes: Double) -> Double {
        let bottom = max(0, bottomTimeMinutes)
        switch ratioType {
        case .oneToOne:
            return bottom
        case .twoToOne:
            return bottom / 2
        case .custom:
            let denominator = max(0.1, customRatioDenominator)
            return bottom / denominator
        }
    }
}

struct RatioDecoStop: Identifiable, Hashable {
    let id = UUID()
    let depthMeters: Double
    let durationMinutes: Double
    let gasLabel: String
    let gasMix: GasMix?
    let ppO2: Double
    let runtimeMinute: Double
}

enum RatioDecoWarning: Hashable {
    case unavailableInBaseMode
    case noDecoGases
    case modViolation(depthMeters: Double, gasLabel: String)
    case gasAssignmentFallback(depthMeters: Double)
    case deepStopAdded(depthMeters: Double)
}

struct RatioDecoSchedule: Hashable {
    let stops: [RatioDecoStop]
    let totalDecoMinutes: Double
    let totalRuntimeMinutes: Double
    let firstStopDepthMeters: Double
    let presetName: String
    let warnings: [RatioDecoWarning]
    let depthProfilePoints: [DepthProfilePoint]
    let ascentTableRows: [PlannerAscentTableRow]

    var ttsMinutes: Int {
        Int(totalRuntimeMinutes.rounded())
    }
}

enum RatioDecoValidationWarning: Hashable {
    case unavailableInBaseMode
    case ceilingViolation(requiredCeilingMeters: Double, stopDepthMeters: Double, runtimeMinute: Double)
    case modExceeded(depthMeters: Double, gasLabel: String)
    case decoDepthLimitExceeded
}

struct RatioDecoValidationResult: Hashable {
    let isBuhlmannCompatible: Bool
    let warnings: [RatioDecoValidationWarning]
    let firstViolationRuntime: Double?
    let firstViolationDepthMeters: Double?
    let requiredCeilingMeters: Double?

    var localizedStatusTitle: String {
        if warnings.contains(where: {
            if case .ceilingViolation = $0 { return true }
            return false
        }) {
            return String(localized: "planner.ratio_deco.validation.ceiling_violation")
        }
        if warnings.isEmpty && isBuhlmannCompatible {
            return String(localized: "planner.ratio_deco.validation.validated")
        }
        return String(localized: "planner.ratio_deco.validation.warning")
    }
}

struct RatioDecoPlanningBundle: Hashable {
    let schedule: RatioDecoSchedule
    let validation: RatioDecoValidationResult
    let method: PlannerDecompressionMethod
    let preset: RatioDecoPreset
}
