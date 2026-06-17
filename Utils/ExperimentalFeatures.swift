import Foundation

enum ExperimentalFeatures {
    /// Buddy Assist uses experimental BLE and is not production-ready.
    /// Experimental BLE relay; enable for lab builds on `codex/experimental-features` only.
    static let buddyAssistEnabled = true

    /// Apnea integration (Watch engine + iOS companion + WC sync) on `integration/full-computer`.
    /// Watch UI (`ApneaView`) remains excluded from MAIN target until promotion review.
    static let apneaIntegrationEnabled = true
}
