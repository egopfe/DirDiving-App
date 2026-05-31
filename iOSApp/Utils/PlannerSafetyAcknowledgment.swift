import Foundation

/// Persists planner safety acknowledgment; re-required when disclaimer revision changes.
enum PlannerSafetyAcknowledgment {
    static let currentRevision = "2026-05-24"
    static let storageKey = "dirdiving_planner_safety_ack_revision"

    static var isAcknowledged: Bool {
        UserDefaults.standard.string(forKey: storageKey) == currentRevision
    }

    static func acknowledge() {
        UserDefaults.standard.set(currentRevision, forKey: storageKey)
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
}
