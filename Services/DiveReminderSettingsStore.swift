import Foundation
import Combine

@MainActor
final class DiveReminderSettingsStore: ObservableObject {
    static let storageKey = "dirdiving_watch_dive_reminder_settings"
    static var testHook_defaults: UserDefaults?

    @Published var settings: DiveReminderSettings {
        didSet { save() }
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults? = nil) {
        let resolved = defaults ?? Self.testHook_defaults ?? .standard
        self.defaults = resolved
        settings = Self.load(from: resolved)
    }

    static func load(from defaults: UserDefaults? = nil) -> DiveReminderSettings {
        let resolved = defaults ?? testHook_defaults ?? .standard
        guard let data = resolved.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode(DiveReminderSettings.self, from: data) else {
            return DiveReminderSettings()
        }
        return decoded
    }

    var canAddReminder: Bool {
        DiveReminderValidation.canAddReminder(to: settings)
    }

    func addReminder(_ reminder: DiveReminder) -> Bool {
        guard canAddReminder, let normalized = DiveReminderValidation.normalized(reminder) else { return false }
        settings.reminders.append(normalized)
        return true
    }

    @discardableResult
    func updateReminder(_ reminder: DiveReminder) -> Bool {
        guard let normalized = DiveReminderValidation.normalized(reminder),
              let index = settings.reminders.firstIndex(where: { $0.id == reminder.id }) else { return false }
        settings.reminders[index] = normalized
        return true
    }

    func deleteReminder(id: UUID) {
        settings.reminders.removeAll { $0.id == id }
    }

    func reminder(with id: UUID) -> DiveReminder? {
        settings.reminders.first { $0.id == id }
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(settings) else { return }
        defaults.set(data, forKey: Self.storageKey)
    }
}
