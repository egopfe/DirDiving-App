import Foundation

enum PlannerGFPreset: String, CaseIterable, Identifiable {
    case conservative
    case standard
    case aggressive

    var id: String { rawValue }

    var gfLow: Double {
        switch self {
        case .conservative: return 20
        case .standard: return 30
        case .aggressive: return 40
        }
    }

    var gfHigh: Double {
        switch self {
        case .conservative: return 70
        case .standard: return 80
        case .aggressive: return 85
        }
    }

    var localizedTitle: String {
        switch self {
        case .conservative: return DIRIOSLocalizer.string("planner.gf.preset.conservative")
        case .standard: return DIRIOSLocalizer.string("planner.gf.preset.standard")
        case .aggressive: return DIRIOSLocalizer.string("planner.gf.preset.aggressive")
        }
    }
}

enum BuhlmannResultPresentation: Equatable {
    case hidden
    case simplifiedSummary
    case fullCurve
}

struct PlannerResultPresentation: Equatable {
    let showsFullAscentTable: Bool
    let showsSimplifiedAscentTable: Bool
    let showsGasLedger: Bool
    let showsContingency: Bool
    let showsTeamMatch: Bool
    let showsBriefing: Bool
    let showsGFComparison: Bool
    let showsSegmentTimeline: Bool
    let showsNDLCurveTab: Bool
    let showsChartsTab: Bool
    let buhlmannPresentation: BuhlmannResultPresentation
    let showsExtendedAnalysisTiles: Bool
    let showsReserveCard: Bool
    let showsRepetitivePlanning: Bool
    let showsTeamPreview: Bool
    let showsManualGFControls: Bool
    let showsGFPresets: Bool

    static func presentation(for mode: PlannerMode) -> PlannerResultPresentation {
        switch mode {
        case .base:
            return PlannerResultPresentation(
                showsFullAscentTable: false,
                showsSimplifiedAscentTable: false,
                showsGasLedger: false,
                showsContingency: false,
                showsTeamMatch: false,
                showsBriefing: false,
                showsGFComparison: false,
                showsSegmentTimeline: false,
                showsNDLCurveTab: false,
                showsChartsTab: false,
                buhlmannPresentation: .hidden,
                showsExtendedAnalysisTiles: false,
                showsReserveCard: false,
                showsRepetitivePlanning: false,
                showsTeamPreview: false,
                showsManualGFControls: false,
                showsGFPresets: false
            )
        case .deco:
            return PlannerResultPresentation(
                showsFullAscentTable: false,
                showsSimplifiedAscentTable: true,
                showsGasLedger: true,
                showsContingency: false,
                showsTeamMatch: false,
                showsBriefing: true,
                showsGFComparison: false,
                showsSegmentTimeline: true,
                showsNDLCurveTab: true,
                showsChartsTab: false,
                buhlmannPresentation: .simplifiedSummary,
                showsExtendedAnalysisTiles: true,
                showsReserveCard: true,
                showsRepetitivePlanning: false,
                showsTeamPreview: false,
                showsManualGFControls: false,
                showsGFPresets: true
            )
        case .technical:
            return PlannerResultPresentation(
                showsFullAscentTable: true,
                showsSimplifiedAscentTable: false,
                showsGasLedger: true,
                showsContingency: true,
                showsTeamMatch: true,
                showsBriefing: true,
                showsGFComparison: true,
                showsSegmentTimeline: true,
                showsNDLCurveTab: true,
                showsChartsTab: true,
                buhlmannPresentation: .fullCurve,
                showsExtendedAnalysisTiles: true,
                showsReserveCard: true,
                showsRepetitivePlanning: true,
                showsTeamPreview: true,
                showsManualGFControls: true,
                showsGFPresets: false
            )
        case .ccr:
            return PlannerResultPresentation(
                showsFullAscentTable: true,
                showsSimplifiedAscentTable: false,
                showsGasLedger: false,
                showsContingency: false,
                showsTeamMatch: false,
                showsBriefing: true,
                showsGFComparison: false,
                showsSegmentTimeline: true,
                showsNDLCurveTab: false,
                showsChartsTab: true,
                buhlmannPresentation: .fullCurve,
                showsExtendedAnalysisTiles: true,
                showsReserveCard: false,
                showsRepetitivePlanning: false,
                showsTeamPreview: false,
                showsManualGFControls: true,
                showsGFPresets: false
            )
        }
    }
}

enum PlannerModePolicy {
    /// Fixed internal PPO₂ max for Base recreational gas/depth compatibility (not exposed as a user planning control).
    /// MOD remains a derived safety limit via `PlannerMODValidator`.
    static let baseBottomGasMaxPPO2: Double = 1.4

    static func baseDerivedMODMeters(for gas: GasMix, environment: PlannerEnvironment) -> Double {
        PlannerMODValidator.modMeters(
            oxygenFraction: gas.oxygen,
            maxPPO2: baseBottomGasMaxPPO2,
            environment: environment
        )
    }

    static func activePlanInput(from draft: GasPlanInput, mode: PlannerMode) -> GasPlanInput {
        var projected = draft
        projected.ensurePlannerCylindersFromLegacy()
        projected.syncLegacyGasesFromPlannerCylinders()

        switch mode {
        case .base:
            projected = projectBaseInput(projected)
        case .deco:
            projected = projectDecoInput(projected)
        case .technical, .ccr:
            break
        }

        projected.syncLegacyGasesFromPlannerCylinders()
        return projected
    }

    static func validate(draft: GasPlanInput, mode: PlannerMode) -> PlannerValidationResult {
        guard mode.isOpenCircuit else {
            var result = PlannerValidationResult()
            result.add(.validReference)
            return result
        }
        let active = activePlanInput(from: draft, mode: mode)
        var result = PlannerInputValidator.validate(active, mode: mode)

        switch mode {
        case .base:
            result.merge(validateBaseDraft(draft))
            result.merge(PlannerModeLimits.validateBasicLimits(for: draft))
        case .deco:
            result.merge(validateDecoDraft(draft))
            result.merge(PlannerModeLimits.validateDecoDepthLimits(for: draft))
        case .technical, .ccr:
            break
        }

        if result.states.isEmpty {
            result.add(.validReference)
        }
        return result
    }

    static func modeGuidance(
        mode: PlannerMode,
        enginePlan: BuhlmannEngineResult,
        stops: [DecoStop]
    ) -> PlannerUserFacingMessage? {
        guard mode == .base else { return nil }
        let requiresDeco = !stops.isEmpty
            || (enginePlan.ndlMinutes.map { $0 < enginePlan.bottomMinutes + 0.01 } ?? false)
        guard requiresDeco else { return nil }
        return PlannerUserFacingCopy.localized(
            id: "planner.base.exceeds_mode",
            titleKey: "planner.mode.basic.no_deco.title",
            messageKey: "planner.mode.basic.no_deco.message",
            hintKey: "planner.mode.basic.no_deco.hint",
            severity: .warning
        )
    }

    static func allowedMixKinds(for mode: PlannerMode) -> [GasMixKind] {
        switch mode {
        case .base:
            return [.air, .ean]
        case .deco, .technical:
            return GasMixKind.allCases
        case .ccr:
            return [.air, .ean, .trimix]
        }
    }

    static func maxDecoCylinderCount(for mode: PlannerMode) -> Int {
        switch mode {
        case .base: return 0
        case .deco: return 1
        case .technical: return Int.max
        case .ccr: return 0
        }
    }

    static func allowsTravelGas(for mode: PlannerMode) -> Bool {
        mode == .technical
    }

    static func allowsBailoutGas(for mode: PlannerMode) -> Bool {
        mode == .technical
    }

    static func allowsTrimix(for mode: PlannerMode) -> Bool {
        mode == .technical || mode == .ccr
    }

    static func applyGFPreset(_ preset: PlannerGFPreset, to input: inout GasPlanInput) {
        input.gfLow = preset.gfLow
        input.gfHigh = preset.gfHigh
    }

    static func matchingGFPreset(for input: GasPlanInput) -> PlannerGFPreset? {
        PlannerGFPreset.allCases.first { $0.gfLow == input.gfLow && $0.gfHigh == input.gfHigh }
    }

    private static func projectBaseInput(_ input: GasPlanInput) -> GasPlanInput {
        var projected = input
        projected.ensurePlannerCylindersFromLegacy()

        var bottomEntry = projected.plannerCylinders.first(where: { $0.role == .bottom })
            ?? PlannerCylinderEntry(role: .bottom, gas: projected.bottomGas)

        bottomEntry.role = .bottom
        bottomEntry.gas.role = .bottom

        switch bottomEntry.gas.mixKind {
        case .air:
            bottomEntry.gas.applyMixKind(.air)
        case .ean:
            bottomEntry.gas.helium = 0
            bottomEntry.gas.normalizeMixAndPPO2()
        case .trimix, .oxygen:
            bottomEntry.gas.applyMixKind(.air)
        }

        bottomEntry.gas.helium = 0
        bottomEntry.gas.maxPPO2 = baseBottomGasMaxPPO2
        bottomEntry.gas.normalizeMixAndPPO2()

        projected.plannerCylinders = [bottomEntry]
        projected.bottomGas = bottomEntry.gas
        projected.gfLow = PlannerGFPreset.standard.gfLow
        projected.gfHigh = PlannerGFPreset.standard.gfHigh
        return projected
    }

    private static func projectDecoInput(_ input: GasPlanInput) -> GasPlanInput {
        var projected = input
        let bottom = projected.plannerCylinders.filter { $0.role == .bottom }
        let deco = projected.plannerCylinders
            .filter { $0.role == .deco }
            .sorted { $0.switchDepthMeters > $1.switchDepthMeters }
        projected.plannerCylinders = bottom + Array(deco.prefix(1))
        if projected.gfLow >= projected.gfHigh {
            applyGFPreset(.standard, to: &projected)
        }
        projected.syncLegacyGasesFromPlannerCylinders()
        return projected
    }

    private static func validateBaseDraft(_ draft: GasPlanInput) -> PlannerValidationResult {
        var result = PlannerValidationResult()
        var working = draft
        working.ensurePlannerCylindersFromLegacy()

        if draft.plannerCylinders.contains(where: { $0.role != .bottom }) {
            // Hidden technical gases are allowed in draft; calculation ignores them.
        }

        let bottomGas = working.plannerCylinders.first(where: { $0.role == .bottom })?.gas ?? working.bottomGas
        if bottomGas.mixKind == .trimix || bottomGas.helium > 0.001 {
            result.add(.unsupportedTrimix, message: DIRIOSLocalizer.string("planner.base.trimix_not_allowed"))
        }
        if bottomGas.mixKind == .air || bottomGas.mixKind == .ean {
            // allowed
        } else if bottomGas.helium <= 0.001, bottomGas.oxygen >= 0.10 {
            // treated as EAN-like
        }

        return result
    }

    private static func validateDecoDraft(_ draft: GasPlanInput) -> PlannerValidationResult {
        var result = PlannerValidationResult()
        var working = draft
        working.ensurePlannerCylindersFromLegacy()

        let bottomGas = working.plannerCylinders.first(where: { $0.role == .bottom })?.gas ?? working.bottomGas
        if bottomGas.mixKind == .trimix || bottomGas.helium > 0.001 {
            result.add(.unsupportedTrimix, message: DIRIOSLocalizer.string("planner.deco.trimix_technical_only"))
        }

        for gas in working.plannerCylinders.filter({ $0.role == .bottom || $0.role == .deco }).map(\.gas) where gas.mixKind == .trimix {
            result.add(.unsupportedTrimix, message: DIRIOSLocalizer.string("planner.deco.trimix_technical_only"))
        }

        return result
    }
}
