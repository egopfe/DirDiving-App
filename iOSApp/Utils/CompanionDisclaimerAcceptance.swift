import Foundation

/// Persists companion disclaimer acceptance; re-shown only when revision changes.
enum CompanionDisclaimerAcceptance {
    static let currentRevision = "2026-05-24"

    private static let revisionKey = "dirdiving_companion_disclaimer_revision"

    static var requiresDisplay: Bool {
        UserDefaults.standard.string(forKey: revisionKey) != currentRevision
    }

    static func accept() {
        UserDefaults.standard.set(currentRevision, forKey: revisionKey)
    }
}
