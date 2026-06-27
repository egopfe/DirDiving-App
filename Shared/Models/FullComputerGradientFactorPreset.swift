import Foundation

enum FullComputerGradientFactorPreset: String, CaseIterable, Codable, Identifiable, Sendable {
    case conservative2080
    case standard3070
    case moderate4085

    var id: String { rawValue }

    static let watchDefault: FullComputerGradientFactorPreset = .standard3070

    var gfLow: Int {
        switch self {
        case .conservative2080: return 20
        case .standard3070: return 30
        case .moderate4085: return 40
        }
    }

    var gfHigh: Int {
        switch self {
        case .conservative2080: return 80
        case .standard3070: return 70
        case .moderate4085: return 85
        }
    }

    var valueText: String {
        "GF \(gfLow)/\(gfHigh)"
    }

    var displayNameKey: String {
        switch self {
        case .conservative2080: return "full_computer.gradient_factors.conservative.title"
        case .standard3070: return "full_computer.gradient_factors.standard.title"
        case .moderate4085: return "full_computer.gradient_factors.moderate.title"
        }
    }

    var valueLocalizationKey: String {
        switch self {
        case .conservative2080: return "full_computer.gradient_factors.conservative.value"
        case .standard3070: return "full_computer.gradient_factors.standard.value"
        case .moderate4085: return "full_computer.gradient_factors.moderate.value"
        }
    }

    var subtitleKey: String {
        switch self {
        case .conservative2080: return "full_computer.gradient_factors.conservative.subtitle"
        case .standard3070: return "full_computer.gradient_factors.standard.subtitle"
        case .moderate4085: return "full_computer.gradient_factors.moderate.subtitle"
        }
    }

    var indicatorColorName: String {
        switch self {
        case .conservative2080: return "red"
        case .standard3070: return "blue"
        case .moderate4085: return "orange"
        }
    }

    var localizedTitle: String {
        String(localized: String.LocalizationValue(displayNameKey))
    }

    var localizedValue: String {
        String(localized: String.LocalizationValue(valueLocalizationKey))
    }

    var localizedSubtitle: String {
        String(localized: String.LocalizationValue(subtitleKey))
    }

    var settingsSummary: String {
        "\(localizedTitle) (\(valueText))"
    }

    var confirmSummary: String {
        String(
            format: String(localized: "full_computer.gradient_factors.confirm.summary_format"),
            localizedTitle,
            valueText
        )
    }

    static func load(from rawValue: String?) -> FullComputerGradientFactorPreset {
        guard let rawValue, let preset = FullComputerGradientFactorPreset(rawValue: rawValue) else {
            return .watchDefault
        }
        return preset
    }

    static func matching(low: Double, high: Double) -> FullComputerGradientFactorPreset? {
        matching(low: Int(low.rounded()), high: Int(high.rounded()))
    }

    static func matching(low: Int, high: Int) -> FullComputerGradientFactorPreset? {
        allCases.first { $0.gfLow == low && $0.gfHigh == high }
    }

    static func matching(package: DivePlanPackage) -> FullComputerGradientFactorPreset? {
        if let raw = package.body.gradientFactorPreset {
            return FullComputerGradientFactorPreset(rawValue: raw)
        }
        return matching(low: package.body.gfLow, high: package.body.gfHigh)
    }
}

enum FullComputerGradientFactorSource: String, Codable, Sendable {
    case watchSettings
    case iosPlan

    var localizationKey: String {
        switch self {
        case .watchSettings: return "full_computer.gradient_factors.source.watch_settings"
        case .iosPlan: return "full_computer.gradient_factors.source.ios_plan"
        }
    }

    var localizedLabel: String {
        String(localized: String.LocalizationValue(localizationKey))
    }
}

enum FullComputerGradientFactorLockReason: String, Codable, Sendable {
    case activeDive
    case importedIOSPlan
    case fullComputerRuntimeStarted

    var localizationKey: String {
        switch self {
        case .activeDive: return "full_computer.gradient_factors.locked.active_dive"
        case .importedIOSPlan: return "full_computer.gradient_factors.locked.ios_plan"
        case .fullComputerRuntimeStarted: return "full_computer.gradient_factors.locked.runtime_started"
        }
    }

    var localizedMessage: String {
        String(localized: String.LocalizationValue(localizationKey))
    }
}

struct FullComputerResolvedGradientFactors: Codable, Equatable, Sendable {
    let preset: FullComputerGradientFactorPreset
    let low: Int
    let high: Int
    let source: FullComputerGradientFactorSource
    let isLocked: Bool
    let lockReason: FullComputerGradientFactorLockReason?

    var valueText: String {
        "GF \(low)/\(high)"
    }

    var confirmSummary: String {
        preset.confirmSummary
    }

    var sourceLine: String {
        String(
            format: String(localized: "full_computer.gradient_factors.source.line_format"),
            source.localizedLabel
        )
    }

    var logbookSummary: String {
        confirmSummary
    }

    static func watchSettings(preset: FullComputerGradientFactorPreset) -> FullComputerResolvedGradientFactors {
        FullComputerResolvedGradientFactors(
            preset: preset,
            low: preset.gfLow,
            high: preset.gfHigh,
            source: .watchSettings,
            isLocked: false,
            lockReason: nil
        )
    }

    static func iosPlan(preset: FullComputerGradientFactorPreset) -> FullComputerResolvedGradientFactors {
        FullComputerResolvedGradientFactors(
            preset: preset,
            low: preset.gfLow,
            high: preset.gfHigh,
            source: .iosPlan,
            isLocked: true,
            lockReason: .importedIOSPlan
        )
    }

    static func lockedSnapshot(
        preset: FullComputerGradientFactorPreset,
        source: FullComputerGradientFactorSource,
        reason: FullComputerGradientFactorLockReason
    ) -> FullComputerResolvedGradientFactors {
        FullComputerResolvedGradientFactors(
            preset: preset,
            low: preset.gfLow,
            high: preset.gfHigh,
            source: source,
            isLocked: true,
            lockReason: reason
        )
    }
}

enum FullComputerGradientFactorLockContext {
    static func isAnySessionActive(
        isDiveActive: Bool,
        isApneaActive: Bool,
        isSnorkelingActive: Bool
    ) -> Bool {
        isDiveActive || isApneaActive || isSnorkelingActive
    }

    static func isFullComputerRuntimeStarted(
        fullComputerPrediveConfirmed: Bool,
        hasFullComputerEngine: Bool,
        sessionConfigured: Bool,
        divingMode: DIRDivingMode?
    ) -> Bool {
        if hasFullComputerEngine { return true }
        if fullComputerPrediveConfirmed { return true }
        if sessionConfigured, divingMode == .fullComputer { return true }
        return false
    }
}
