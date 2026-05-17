import Foundation

enum ExperimentalFeatures {
    /// Buddy Assist uses experimental BLE and is not production-ready.
    /// Disabled until the watchOS peer relay is replaced by a reliable production architecture.
    static let buddyAssistEnabled = false
    static let buddyAssistDisabledReason = "LAB-ONLY: relay BLE Watch non disponibile. Pairing e invio messaggi sono disabilitati."
}
