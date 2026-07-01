import Combine
import Foundation

/// Per-activity iOS-only toggles for read-only aggregated logbook presentation.
@MainActor
final class IOSActivityLogbookVisibilitySettingsStore: ObservableObject {
    static let divingKey = "dirdiving.ios.diving.logbook.showAllActivities"
    static let snorkelingKey = "dirdiving.ios.snorkeling.logbook.showAllActivities"
    static let apneaKey = "dirdiving.ios.apnea.logbook.showAllActivities"

    static var testHook_defaults: UserDefaults?

    @Published var showAllActivitiesInDivingLogbook: Bool {
        didSet { persist(Self.divingKey, showAllActivitiesInDivingLogbook) }
    }

    @Published var showAllActivitiesInSnorkelingLogbook: Bool {
        didSet { persist(Self.snorkelingKey, showAllActivitiesInSnorkelingLogbook) }
    }

    @Published var showAllActivitiesInApneaLogbook: Bool {
        didSet { persist(Self.apneaKey, showAllActivitiesInApneaLogbook) }
    }

    private var defaults: UserDefaults { Self.testHook_defaults ?? .standard }

    init(userDefaults: UserDefaults? = nil) {
        let resolved = userDefaults ?? Self.testHook_defaults ?? .standard
        showAllActivitiesInDivingLogbook = resolved.bool(forKey: Self.divingKey)
        showAllActivitiesInSnorkelingLogbook = resolved.bool(forKey: Self.snorkelingKey)
        showAllActivitiesInApneaLogbook = resolved.bool(forKey: Self.apneaKey)
    }

    func showAllActivitiesInLogbook(for activity: DIRActivityMode) -> Bool {
        switch activity {
        case .diving: return showAllActivitiesInDivingLogbook
        case .snorkeling: return showAllActivitiesInSnorkelingLogbook
        case .apnea: return showAllActivitiesInApneaLogbook
        }
    }

    func setShowAllActivitiesInLogbook(_ enabled: Bool, for activity: DIRActivityMode) {
        switch activity {
        case .diving: showAllActivitiesInDivingLogbook = enabled
        case .snorkeling: showAllActivitiesInSnorkelingLogbook = enabled
        case .apnea: showAllActivitiesInApneaLogbook = enabled
        }
    }

    func resetForTesting() {
        showAllActivitiesInDivingLogbook = false
        showAllActivitiesInSnorkelingLogbook = false
        showAllActivitiesInApneaLogbook = false
    }

    private func persist(_ key: String, _ value: Bool) {
        defaults.set(value, forKey: key)
    }
}
