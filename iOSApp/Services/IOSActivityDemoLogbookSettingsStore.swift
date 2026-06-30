import Combine
import Foundation

@MainActor
final class IOSActivityDemoLogbookSettingsStore: ObservableObject {
    static let apneaFakeLogbookKey = "dirdiving.ios.apnea.fakeLogbook.enabled"
    static let snorkelingFakeLogbookKey = "dirdiving.ios.snorkeling.fakeLogbook.enabled"

    @Published var isApneaFakeLogbookEnabled: Bool {
        didSet {
            userDefaults.set(isApneaFakeLogbookEnabled, forKey: Self.apneaFakeLogbookKey)
        }
    }

    @Published var isSnorkelingFakeLogbookEnabled: Bool {
        didSet {
            userDefaults.set(isSnorkelingFakeLogbookEnabled, forKey: Self.snorkelingFakeLogbookKey)
        }
    }

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        isApneaFakeLogbookEnabled = userDefaults.bool(forKey: Self.apneaFakeLogbookKey)
        isSnorkelingFakeLogbookEnabled = userDefaults.bool(forKey: Self.snorkelingFakeLogbookKey)
    }

    func setApneaFakeLogbookEnabled(_ enabled: Bool) {
        isApneaFakeLogbookEnabled = enabled
    }

    func setSnorkelingFakeLogbookEnabled(_ enabled: Bool) {
        isSnorkelingFakeLogbookEnabled = enabled
    }

    func resetDemoLogbookSettings() {
        isApneaFakeLogbookEnabled = false
        isSnorkelingFakeLogbookEnabled = false
    }
}
