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

/// Persists CCR planner safety acknowledgment independently from generic OC/Technical planner ack.
enum CCRPlannerSafetyAcknowledgment {
    static let currentRevision = "2026-07-02-ccr-planner-indicative-v1"
    static let storageKey = "dirdiving_ios_ccr_planner_safety_ack_revision"

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

/// Pure UI gate policy — no algorithmic logic.
enum PlannerSafetyGatePolicy {
    static func isAcknowledged(
        mode: PlannerMode,
        genericAcknowledged: Bool,
        ccrAcknowledged: Bool
    ) -> Bool {
        mode.isCCR ? ccrAcknowledged : genericAcknowledged
    }
}
