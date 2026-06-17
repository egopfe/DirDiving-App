import Foundation

/// Presentation-only layout policy for Gauge Live Dive top metrics (no algorithm changes).
struct GaugeLivePresentationPolicy: Equatable, Sendable {
    enum TopPanel: Equatable, Sendable {
        case hidden
        case ttvAndRuntime
        case runtimeAndTemperature
    }

    let topPanel: TopPanel

    static func evaluate(isGaugeMode: Bool, showsTTV: Bool) -> GaugeLivePresentationPolicy {
        guard isGaugeMode else {
            return GaugeLivePresentationPolicy(topPanel: .hidden)
        }
        if showsTTV {
            return GaugeLivePresentationPolicy(topPanel: .ttvAndRuntime)
        }
        return GaugeLivePresentationPolicy(topPanel: .runtimeAndTemperature)
    }
}
