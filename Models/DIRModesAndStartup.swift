import Foundation

/// Stable activity modes with explicit Watch MAIN vs iOS Companion launch policies.
enum DIRActivityMode: String, Codable, CaseIterable, Identifiable, Hashable, Sendable {
    case diving
    case apnea
    case snorkeling

    var id: String { rawValue }

    /// Watch MAIN: Diving, Apnea, and Snorkeling.
    var isLaunchableOnWatchMAIN: Bool {
        switch self {
        case .diving, .apnea, .snorkeling: return true
        }
    }

    /// iOS Companion: Apnea preparatory flows are selectable; Snorkeling remains unavailable on MAIN.
    var isLaunchableOnIOSCompanionMAIN: Bool {
        switch self {
        case .diving, .apnea: return true
        case .snorkeling: return false
        }
    }
}

/// Diving sub-mode: Gauge (existing runtime) or Full Computer (pre-dive + future Bühlmann runtime).
enum DIRDivingMode: String, Codable, CaseIterable, Identifiable, Hashable, Sendable {
    case gauge
    case fullComputer

    var id: String { rawValue }
}

/// Resolved startup destination after applying user preferences.
enum DIRStartupLaunchStep: Equatable, Hashable, Sendable {
    case activitySelection
    case divingModeSelection(activity: DIRActivityMode)
    case fullComputerPrediveConfiguration
    case fullComputerConfirmation
    case comingSoon(activity: DIRActivityMode)
    case ready(activity: DIRActivityMode, divingMode: DIRDivingMode)
}

/// In-memory selection for the current app session (restored from preferences on cold launch).
struct DIRActivitySelectionState: Equatable, Codable, Sendable {
    var activity: DIRActivityMode
    var divingMode: DIRDivingMode
    var fullComputerPrediveConfirmed: Bool

    static let gaugeDefault = DIRActivitySelectionState(
        activity: .diving,
        divingMode: .gauge,
        fullComputerPrediveConfirmed: false
    )
}
