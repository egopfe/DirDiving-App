import Foundation

enum DiveReminderType: String, Codable, CaseIterable, Identifiable {
    case single
    case recurring

    var id: String { rawValue }

    var localizedTitle: String {
        switch self {
        case .single:
            return String(localized: "dive_reminder.type.single")
        case .recurring:
            return String(localized: "dive_reminder.type.recurring")
        }
    }
}

struct DiveReminder: Identifiable, Codable, Hashable {
    var id: UUID
    var enabled: Bool
    var type: DiveReminderType
    var triggerMinute: Int
    var repeatEveryMinutes: Int?
    var message: String
    var hapticEnabled: Bool

    static func makeNew() -> DiveReminder {
        DiveReminder(
            id: UUID(),
            enabled: true,
            type: .single,
            triggerMinute: 5,
            repeatEveryMinutes: nil,
            message: "",
            hapticEnabled: true
        )
    }

    var intervalMinutes: Int {
        switch type {
        case .single:
            return triggerMinute
        case .recurring:
            return repeatEveryMinutes ?? triggerMinute
        }
    }
}

struct DiveReminderSettings: Codable, Equatable {
    var remindersEnabled: Bool = false
    var reminders: [DiveReminder] = []
}

enum DiveReminderLimits {
    static let maxReminders = 10
    static let maxMessageLength = 24
    static let minuteRange = 1...120
}

enum DiveReminderValidation {
    static func sanitizedMessage(_ raw: String) -> String? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed.count <= DiveReminderLimits.maxMessageLength else { return nil }
        return trimmed
    }

    static func clampedMinute(_ value: Int) -> Int {
        min(DiveReminderLimits.minuteRange.upperBound, max(DiveReminderLimits.minuteRange.lowerBound, value))
    }

    static func normalized(_ reminder: DiveReminder) -> DiveReminder? {
        guard let message = sanitizedMessage(reminder.message) else { return nil }
        var copy = reminder
        copy.message = message
        copy.triggerMinute = clampedMinute(copy.triggerMinute)
        switch copy.type {
        case .single:
            copy.repeatEveryMinutes = nil
        case .recurring:
            let interval = clampedMinute(copy.repeatEveryMinutes ?? copy.triggerMinute)
            copy.repeatEveryMinutes = interval
            copy.triggerMinute = interval
        }
        return copy
    }

    static func canAddReminder(to settings: DiveReminderSettings) -> Bool {
        settings.reminders.count < DiveReminderLimits.maxReminders
    }
}

struct DiveReminderRuntimeState: Equatable {
    var firedSingleReminderIDs: Set<UUID> = []
    var lastFiredMinuteByReminderID: [UUID: Int] = [:]

    mutating func reset() {
        firedSingleReminderIDs = []
        lastFiredMinuteByReminderID = [:]
    }
}

struct DiveReminderOverlayContent: Equatable {
    let title: String
    let messages: [String]
    let hiddenCount: Int
    let runtimeMinute: Int
    let shouldHaptic: Bool
}

enum DiveReminderPreset: CaseIterable {
    case checkGas
    case checkBuddy
    case checkRuntime
    case checkTrim
    case checkDeco

    var localizedMessage: String {
        switch self {
        case .checkGas:
            return String(localized: "dive_reminder.preset.check_gas")
        case .checkBuddy:
            return String(localized: "dive_reminder.preset.check_buddy")
        case .checkRuntime:
            return String(localized: "dive_reminder.preset.check_runtime")
        case .checkTrim:
            return String(localized: "dive_reminder.preset.check_trim")
        case .checkDeco:
            return String(localized: "dive_reminder.preset.check_deco")
        }
    }
}
