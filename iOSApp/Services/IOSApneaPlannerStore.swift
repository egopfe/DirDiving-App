import Combine
import Foundation

@MainActor
final class IOSApneaPlannerStore: ObservableObject {
    static var testHook_defaults: UserDefaults?

    @Published var draftPlan: ApneaSessionPlan
    @Published private(set) var validationIssues: [ApneaSessionPlanValidationIssue] = []
    @Published private(set) var lastSavedAt: Date?

    private let storageKey = "dirdiving_ios_apnea_planner_draft_v1"
    private var defaults: UserDefaults { Self.testHook_defaults ?? .standard }

    init() {
        let defaults = Self.testHook_defaults ?? UserDefaults.standard
        if let data = defaults.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode(ApneaSessionPlan.self, from: data) {
            draftPlan = decoded
        } else {
            draftPlan = ApneaSessionPlan(kind: .pyramid, title: "Planned session", entries: Self.defaultPyramidEntries())
        }
        refreshValidation()
    }

    func applyProfile(_ profile: ApneaCompanionProfile) {
        draftPlan.profileID = profile.id
        draftPlan.recoveryPolicy = profile.recoveryPolicy
        draftPlan.alarms = profile.alarms
        draftPlan.markers = profile.markers
        if let depth = profile.targetDepthMeters, draftPlan.entries.isEmpty {
            draftPlan.entries = [
                ApneaPlannedDiveEntry(orderIndex: 0, targetDepthMeters: depth, targetDurationSeconds: profile.targetDurationSeconds ?? 60, plannedRecoverySeconds: 60)
            ]
        }
        persist()
    }

    func setKind(_ kind: ApneaSessionPlanKind) {
        draftPlan.kind = kind
        if kind == .pyramid, draftPlan.entries.count < 3 {
            draftPlan.entries = Self.defaultPyramidEntries()
        }
        persist()
    }

    func addEntry() {
        let nextIndex = (draftPlan.entries.map(\.orderIndex).max() ?? -1) + 1
        let lastDepth = draftPlan.entries.last?.targetDepthMeters ?? 10
        draftPlan.entries.append(
            ApneaPlannedDiveEntry(
                orderIndex: nextIndex,
                targetDepthMeters: lastDepth,
                targetDurationSeconds: 60,
                plannedRecoverySeconds: 60
            )
        )
        persist()
    }

    func removeEntry(id: UUID) {
        draftPlan.entries.removeAll { $0.id == id }
        reindexEntries()
        persist()
    }

    func refreshValidation() {
        validationIssues = ApneaSessionPlanValidator.validate(draftPlan)
    }

    var isValid: Bool { validationIssues.isEmpty }

    func persist() {
        draftPlan.updatedAt = Date()
        refreshValidation()
        if let data = try? JSONEncoder().encode(draftPlan) {
            defaults.set(data, forKey: storageKey)
            lastSavedAt = Date()
        }
    }

    static func defaultPyramidEntries() -> [ApneaPlannedDiveEntry] {
        [
            ApneaPlannedDiveEntry(orderIndex: 0, targetDepthMeters: 10, targetDurationSeconds: 60, plannedRecoverySeconds: 60),
            ApneaPlannedDiveEntry(orderIndex: 1, targetDepthMeters: 15, targetDurationSeconds: 75, plannedRecoverySeconds: 90),
            ApneaPlannedDiveEntry(orderIndex: 2, targetDepthMeters: 20, targetDurationSeconds: 90, plannedRecoverySeconds: 120),
            ApneaPlannedDiveEntry(orderIndex: 3, targetDepthMeters: 15, targetDurationSeconds: 75, plannedRecoverySeconds: 90),
            ApneaPlannedDiveEntry(orderIndex: 4, targetDepthMeters: 10, targetDurationSeconds: 60, plannedRecoverySeconds: 60),
        ]
    }

    private func reindexEntries() {
        let sorted = draftPlan.entries.sorted { $0.orderIndex < $1.orderIndex }
        draftPlan.entries = sorted.enumerated().map { index, entry in
            var copy = entry
            copy.orderIndex = index
            return copy
        }
    }

    #if DEBUG
    func resetForTesting() {
        defaults.removeObject(forKey: storageKey)
        draftPlan = ApneaSessionPlan(kind: .pyramid, title: "Test", entries: Self.defaultPyramidEntries())
        refreshValidation()
    }
    #endif
}
