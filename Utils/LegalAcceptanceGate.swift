import Foundation

enum LegalAcceptanceGateError: LocalizedError, Equatable {
    case notAccepted

    var errorDescription: String? {
        String(localized: "shortcut.error.legal_acceptance_required")
    }
}

/// Non-UI legal/safety gate for App Intents and services (SEC-P1-001).
enum LegalAcceptanceGate {
    private enum Key {
        static let timestamp = "dirdiving_legal_acceptance_timestamp"
        static let appMajorVersion = "dirdiving_legal_acceptance_major_version"
        static let legalRevision = "dirdiving_legal_acceptance_revision"
        static let depthLimitsAcknowledged = "dirdiving_legal_depth_limits_acknowledged"
    }

    static func requiresAcceptance(defaults: UserDefaults = .standard) -> Bool {
        guard defaults.object(forKey: Key.timestamp) != nil else { return true }
        let major = defaults.string(forKey: Key.appMajorVersion) ?? ""
        let revision = defaults.string(forKey: Key.legalRevision) ?? ""
        if major != currentMajorVersion { return true }
        if revision != LegalAcceptanceStore.legalRevision { return true }
        if !defaults.bool(forKey: Key.depthLimitsAcknowledged) { return true }
        return false
    }

    static func requireAccepted(defaults: UserDefaults = .standard) throws {
        guard !requiresAcceptance(defaults: defaults) else {
            throw LegalAcceptanceGateError.notAccepted
        }
    }

    private static var currentMajorVersion: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        return version.split(separator: ".").first.map(String.init) ?? version
    }
}
