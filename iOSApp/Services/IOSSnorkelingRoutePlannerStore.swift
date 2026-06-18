import Combine
import Foundation

@MainActor
final class IOSSnorkelingRoutePlannerStore: ObservableObject {
    static var testHook_defaults: UserDefaults?

    @Published var draft: SnorkelingRoutePlannerDraft
    @Published private(set) var savedPlans: [SnorkelingRoutePlannerDraft] = []
    @Published private(set) var loadErrorMessage: String?

    private let draftKey = "dirdiving_ios_snorkeling_route_draft_v1"
    private let plansKey = "dirdiving_ios_snorkeling_route_plans_v1"
    private var defaults: UserDefaults { Self.testHook_defaults ?? .standard }

    init() {
        draft = SnorkelingRoutePlannerDraft(name: "")
        load()
    }

    var validationIssues: [SnorkelingRouteValidationIssue] {
        SnorkelingRoutePlanValidator.validationIssues(for: draft)
    }

    var estimatedDistanceMeters: Double {
        SnorkelingRoutePlanValidator.routeDistanceMeters(draft.orderedPoints)
    }

    var estimatedDurationSeconds: TimeInterval {
        SnorkelingRoutePlanValidator.estimatedDurationSeconds(for: draft)
    }

    func setProfileID(_ profileID: UUID?) {
        draft.profileID = profileID
        if let profileID,
           let profile = SnorkelingCompanionProfilePresets.bundledPresets().first(where: { $0.id == profileID }) {
            draft.maxDistanceLimitMeters = profile.maxDistanceMeters
        }
        persistDraft()
    }

    func setEntry(latitude: Double, longitude: Double, name: String = "") {
        draft.entryPoint = SnorkelingRoutePlannerPoint(
            name: name.isEmpty ? "snorkeling.route.entry" : name,
            role: .entry,
            latitude: latitude,
            longitude: longitude,
            routeOrder: 0
        )
        persistDraft()
    }

    func setExit(latitude: Double, longitude: Double, name: String = "") {
        draft.exitPoint = SnorkelingRoutePlannerPoint(
            name: name.isEmpty ? "snorkeling.route.exit" : name,
            role: .exit,
            latitude: latitude,
            longitude: longitude,
            routeOrder: 0
        )
        persistDraft()
    }

    func addWaypoint(latitude: Double, longitude: Double, name: String = "") {
        let order = draft.waypoints.count
        draft.waypoints.append(
            SnorkelingRoutePlannerPoint(
                name: name.isEmpty ? "snorkeling.route.waypoint" : name,
                role: .waypoint,
                latitude: latitude,
                longitude: longitude,
                routeOrder: order
            )
        )
        persistDraft()
    }

    func removeWaypoint(id: UUID) {
        draft.waypoints.removeAll { $0.id == id }
        draft.waypoints = draft.waypoints.enumerated().map { index, point in
            var copy = point
            copy.routeOrder = index
            return copy
        }
        persistDraft()
    }

    func moveWaypoint(from source: Int, to destination: Int) {
        SnorkelingRoutePlanValidator.moveWaypoint(in: &draft, from: source, to: destination)
        persistDraft()
    }

    func resetDraft() {
        draft = SnorkelingRoutePlannerDraft(name: "")
        persistDraft()
    }

    func loadDraft(id: UUID) {
        guard let plan = savedPlans.first(where: { $0.id == id }) else { return }
        draft = plan
        persistDraft()
    }

    @discardableResult
    func saveCurrentPlan() -> Bool {
        guard SnorkelingRoutePlanValidator.isValid(draft: draft) else { return false }
        var copy = draft
        copy.updatedAt = Date()
        savedPlans.removeAll { $0.id == copy.id }
        savedPlans.insert(copy, at: 0)
        persistPlans()
        return true
    }

    func deleteSavedPlan(id: UUID) {
        savedPlans.removeAll { $0.id == id }
        persistPlans()
    }

    func persistDraft() {
        draft.updatedAt = Date()
        guard let data = try? JSONEncoder().encode(draft) else { return }
        defaults.set(data, forKey: draftKey)
    }

    private func persistPlans() {
        guard let data = try? JSONEncoder().encode(savedPlans) else { return }
        defaults.set(data, forKey: plansKey)
    }

    private func load() {
        if let data = defaults.data(forKey: draftKey),
           let decoded = try? JSONDecoder().decode(SnorkelingRoutePlannerDraft.self, from: data) {
            draft = decoded
        }
        if let data = defaults.data(forKey: plansKey) {
            do {
                savedPlans = try JSONDecoder().decode([SnorkelingRoutePlannerDraft].self, from: data)
            } catch {
                loadErrorMessage = error.localizedDescription
                savedPlans = []
            }
        }
    }

    #if DEBUG
    func resetForTesting() {
        draft = SnorkelingRoutePlannerDraft(name: "")
        savedPlans = []
        defaults.removeObject(forKey: draftKey)
        defaults.removeObject(forKey: plansKey)
    }
    #endif
}
