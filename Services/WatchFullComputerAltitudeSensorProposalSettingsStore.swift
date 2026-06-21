import Foundation
import Combine

/// Watch-only Full Computer altitude sensor proposal policy (not synced to iPhone).
enum FullComputerAltitudeSensorProposalMode: String, Codable, CaseIterable, Identifiable {
    case automatic
    case manualOnly
    case askBeforeSampling

    var id: String { rawValue }

    var localizationKeyTitle: String {
        switch self {
        case .automatic: return "fc.altitude_sensor.mode.automatic.title"
        case .manualOnly: return "fc.altitude_sensor.mode.manual_only.title"
        case .askBeforeSampling: return "fc.altitude_sensor.mode.ask_before.title"
        }
    }

    var localizationKeySubtitle: String {
        switch self {
        case .automatic: return "fc.altitude_sensor.mode.automatic.subtitle"
        case .manualOnly: return "fc.altitude_sensor.mode.manual_only.subtitle"
        case .askBeforeSampling: return "fc.altitude_sensor.mode.ask_before.subtitle"
        }
    }

    var accessibilityHintKey: String {
        switch self {
        case .automatic: return "fc.altitude_sensor.mode.automatic.a11y_hint"
        case .manualOnly: return "fc.altitude_sensor.mode.manual_only.a11y_hint"
        case .askBeforeSampling: return "fc.altitude_sensor.mode.ask_before.a11y_hint"
        }
    }
}

@MainActor
final class WatchFullComputerAltitudeSensorProposalSettingsStore: ObservableObject {
    static let shared = WatchFullComputerAltitudeSensorProposalSettingsStore()

    static let storageKey = "dirdiving_watch_fc_altitude_sensor_proposal_mode_v1"

    @Published private(set) var mode: FullComputerAltitudeSensorProposalMode

    private init() {
        if let raw = UserDefaults.standard.string(forKey: Self.storageKey),
           let stored = FullComputerAltitudeSensorProposalMode(rawValue: raw) {
            mode = stored
        } else {
            mode = .automatic
        }
    }

    func setMode(_ newMode: FullComputerAltitudeSensorProposalMode) {
        guard mode != newMode else { return }
        mode = newMode
        UserDefaults.standard.set(newMode.rawValue, forKey: Self.storageKey)
    }

    #if DEBUG
    func resetForTests() {
        mode = .automatic
        UserDefaults.standard.removeObject(forKey: Self.storageKey)
    }
    #endif
}
