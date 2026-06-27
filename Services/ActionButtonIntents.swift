import AppIntents
import Foundation

@MainActor
private func requireLegalAcceptanceForSafetyIntent() throws {
    do {
        try ActionButtonSafetyGate.requireLegalAcceptance()
    } catch LegalAcceptanceGateError.notAccepted {
        throw DIRDivingShortcutError.legalAcceptanceRequired
    }
}

struct ToggleStopwatchIntent: AppIntent {
    static var title: LocalizedStringResource = "intent.toggle_stopwatch.title"
    static var description: IntentDescription {
        IntentDescription(LocalizedStringResource("intent.toggle_stopwatch.description"))
    }

    func perform() async throws -> some IntentResult {
        try await MainActor.run {
            try requireLegalAcceptanceForSafetyIntent()
            if try WatchIntentSafetyPolicy.routePrimaryActionIfUnderwaterSession() {
                return
            }
            guard let manager = DiveManager.shared else {
                throw DIRDivingShortcutError.appStateUnavailable
            }
            manager.toggleStopwatch()
        }
        return .result()
    }
}

struct ResetStopwatchIntent: AppIntent {
    static var title: LocalizedStringResource = "intent.reset_stopwatch.title"
    static var description: IntentDescription {
        IntentDescription(LocalizedStringResource("intent.reset_stopwatch.description"))
    }

    func perform() async throws -> some IntentResult {
        try await MainActor.run {
            try requireLegalAcceptanceForSafetyIntent()
            try WatchIntentSafetyPolicy.requireNoActiveUnderwaterSessionForLegacyIntent()
            guard let manager = DiveManager.shared else {
                throw DIRDivingShortcutError.appStateUnavailable
            }
            if manager.stopwatchTime > 0 {
                throw DIRDivingShortcutError.stopwatchResetBlocked
            }
            manager.resetStopwatch()
        }
        return .result()
    }
}

struct StartManualDiveIntent: AppIntent {
    static var title: LocalizedStringResource = "intent.start_manual_dive.title"
    static var description: IntentDescription {
        IntentDescription(LocalizedStringResource("intent.start_manual_dive.description"))
    }

    func perform() async throws -> some IntentResult {
        try await MainActor.run {
            try requireLegalAcceptanceForSafetyIntent()
            try WatchIntentSafetyPolicy.requireNoActiveUnderwaterSessionForLegacyIntent()
            guard let manager = DiveManager.shared else {
                throw DIRDivingShortcutError.appStateUnavailable
            }
            manager.startManualDive()
        }
        return .result()
    }
}

struct EndManualDiveIntent: AppIntent {
    static var title: LocalizedStringResource = "intent.end_manual_dive.title"
    static var description: IntentDescription {
        IntentDescription(LocalizedStringResource("intent.end_manual_dive.description"))
    }

    func perform() async throws -> some IntentResult {
        try await MainActor.run {
            try requireLegalAcceptanceForSafetyIntent()
            try WatchIntentSafetyPolicy.requireActiveDivingSessionForEndManualDive()
            guard let manager = DiveManager.shared else {
                throw DIRDivingShortcutError.appStateUnavailable
            }
            manager.endManualDive()
        }
        return .result()
    }
}

struct SetBearingIntent: AppIntent {
    static var title: LocalizedStringResource = "intent.set_bearing.title"
    static var description: IntentDescription {
        IntentDescription(LocalizedStringResource("intent.set_bearing.description"))
    }

    func perform() async throws -> some IntentResult {
        try await MainActor.run {
            try requireLegalAcceptanceForSafetyIntent()
            if try WatchIntentSafetyPolicy.routePrimaryActionIfUnderwaterSession() {
                return
            }
            guard let compass = CompassManager.shared else {
                throw DIRDivingShortcutError.appStateUnavailable
            }
            compass.setBearing()
            HapticService.shared.confirm()
        }
        return .result()
    }
}

struct ClearBearingIntent: AppIntent {
    static var title: LocalizedStringResource = "intent.clear_bearing.title"
    static var description: IntentDescription {
        IntentDescription(LocalizedStringResource("intent.clear_bearing.description"))
    }

    func perform() async throws -> some IntentResult {
        try await MainActor.run {
            try requireLegalAcceptanceForSafetyIntent()
            try WatchIntentSafetyPolicy.requireNoActiveUnderwaterSessionForLegacyIntent()
            guard let compass = CompassManager.shared else {
                throw DIRDivingShortcutError.appStateUnavailable
            }
            compass.clearBearing()
            HapticService.shared.confirm()
        }
        return .result()
    }
}

struct AcknowledgeAlarmIntent: AppIntent {
    static var title: LocalizedStringResource = "intent.ack_alarm.title"
    static var description: IntentDescription {
        IntentDescription(LocalizedStringResource("intent.ack_alarm.description"))
    }

    func perform() async throws -> some IntentResult {
        try await MainActor.run {
            try requireLegalAcceptanceForSafetyIntent()
            if try WatchIntentSafetyPolicy.routePrimaryActionIfUnderwaterSession() {
                return
            }
            guard let manager = DiveManager.shared else {
                throw DIRDivingShortcutError.appStateUnavailable
            }
            manager.dismissAlarmWarning()
        }
        return .result()
    }
}

struct OpenWaterAutoLaunchModeIntent: AppIntent {
    static var title: LocalizedStringResource = "intent.water_auto_open.title"
    static var description: IntentDescription {
        IntentDescription(LocalizedStringResource("intent.water_auto_open.description"))
    }
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        try await MainActor.run {
            try requireLegalAcceptanceForSafetyIntent()
            guard WatchWaterAutoOpenPolicy.mode != .disabled else {
                throw DIRDivingShortcutError.waterAutoOpenModeDisabled
            }
            guard let selection = DIRActivitySelectionStore.shared else {
                throw DIRDivingShortcutError.appStateUnavailable
            }
            selection.beginWaterAutoLaunch()
        }
        return .result()
    }
}

struct ExecuteUnderwaterPrimaryActionIntent: AppIntent {
    static var title: LocalizedStringResource = "intent.underwater_primary_action.title"
    static var description: IntentDescription {
        IntentDescription(LocalizedStringResource("intent.underwater_primary_action.description"))
    }
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        try await MainActor.run {
            try requireLegalAcceptanceForSafetyIntent()
            guard let router = WatchUnderwaterActionRouter.shared else {
                throw DIRDivingShortcutError.appStateUnavailable
            }
            try router.executePrimaryAction()
        }
        return .result()
    }
}

struct DIRDivingAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ExecuteUnderwaterPrimaryActionIntent(),
            phrases: [
                "Execute underwater action in \(.applicationName)",
                "Press DIR Diving action in \(.applicationName)",
                "Run primary water action in \(.applicationName)"
            ],
            shortTitle: LocalizedStringResource("intent.shortcut.underwater_primary_action"),
            systemImageName: "button.programmable"
        )
        AppShortcut(
            intent: OpenWaterAutoLaunchModeIntent(),
            phrases: [
                "Open water mode in \(.applicationName)",
                "Open last water mode in \(.applicationName)",
                "Open preferred water mode in \(.applicationName)"
            ],
            shortTitle: LocalizedStringResource("intent.shortcut.water_auto_open"),
            systemImageName: "drop.fill"
        )
        AppShortcut(
            intent: ToggleStopwatchIntent(),
            phrases: [
                "Toggle stopwatch in \(.applicationName)",
                "Start or stop stopwatch in \(.applicationName)"
            ],
            shortTitle: LocalizedStringResource("intent.shortcut.stopwatch"),
            systemImageName: "stopwatch"
        )
        AppShortcut(
            intent: ResetStopwatchIntent(),
            phrases: [
                "Reset stopwatch in \(.applicationName)",
                "Reset DIR stopwatch in \(.applicationName)"
            ],
            shortTitle: LocalizedStringResource("intent.shortcut.reset_stopwatch"),
            systemImageName: "arrow.counterclockwise"
        )
        AppShortcut(
            intent: StartManualDiveIntent(),
            phrases: ["Start manual dive in \(.applicationName)"],
            shortTitle: LocalizedStringResource("intent.shortcut.manual_start"),
            systemImageName: "figure.water.fitness"
        )
        AppShortcut(
            intent: EndManualDiveIntent(),
            phrases: ["End manual dive in \(.applicationName)"],
            shortTitle: LocalizedStringResource("intent.shortcut.manual_end"),
            systemImageName: "figure.water.fitness"
        )
        AppShortcut(
            intent: SetBearingIntent(),
            phrases: ["Set bearing in \(.applicationName)"],
            shortTitle: LocalizedStringResource("intent.shortcut.set_bearing"),
            systemImageName: "location.north.line"
        )
        AppShortcut(
            intent: ClearBearingIntent(),
            phrases: ["Clear bearing in \(.applicationName)"],
            shortTitle: LocalizedStringResource("intent.shortcut.clear_bearing"),
            systemImageName: "location.slash"
        )
        AppShortcut(
            intent: AcknowledgeAlarmIntent(),
            phrases: ["Acknowledge alarm in \(.applicationName)"],
            shortTitle: LocalizedStringResource("intent.shortcut.ack_alarm"),
            systemImageName: "bell.slash"
        )
    }
}
