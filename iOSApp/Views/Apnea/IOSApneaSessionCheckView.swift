import SwiftUI

struct IOSApneaSessionCheckView: View {
    @EnvironmentObject private var profileStore: IOSApneaProfileStore
    @EnvironmentObject private var settingsStore: IOSApneaSettingsStore
    @EnvironmentObject private var buddyStore: IOSApneaBuddySafetyStore

    @State private var selectedProfileID: UUID?

    private var selectedProfile: ApneaCompanionProfile? {
        guard let id = selectedProfileID else { return profileStore.allProfiles().first }
        return profileStore.profile(id: id)
    }

    private var checkResult: ApneaSessionCheckResult {
        let profile = selectedProfile.map(ApneaSessionProfileBridge.fromCompanion)
        return ApneaSessionCheckEvaluator.evaluate(
            ApneaSessionCheckEvaluator.Input(
                profile: profile,
                recoveryPolicy: selectedProfile?.recoveryPolicy ?? .default,
                recoveryAlertsEnabled: settingsStore.settings.hapticsEnabled,
                buddyReminderShown: true,
                buddyChecklistConfirmed: buddyStore.profile.preSessionConfirmation.isConfirmed,
                watchBatteryLow: nil,
                depthSensorAvailable: nil,
                heartRateAvailable: nil
            )
        )
    }

    var body: some View {
        DIRScreenContainer {
            List {
                Section(DIRIOSLocalizer.string("apnea.session_check.title")) {
                    Picker(DIRIOSLocalizer.string("apnea.ios.profiles.title"), selection: Binding(
                        get: { selectedProfileID ?? profileStore.allProfiles().first?.id },
                        set: { selectedProfileID = $0 }
                    )) {
                        ForEach(profileStore.allProfiles()) { profile in
                            Text(profile.isPreset ? DIRIOSLocalizer.string(profile.displayName) : profile.displayName)
                                .tag(Optional(profile.id))
                        }
                    }

                    statusRow(
                        DIRIOSLocalizer.string("apnea.recovery.title"),
                        checkResult.recoveryAlertsEnabled
                            ? DIRIOSLocalizer.string("apnea.session_check.enabled")
                            : DIRIOSLocalizer.string("apnea.session_check.disabled")
                    )
                    statusRow(
                        DIRIOSLocalizer.string("apnea.checklist.buddy"),
                        checkResult.buddyReminderShown
                            ? DIRIOSLocalizer.string("apnea.session_check.ready")
                            : DIRIOSLocalizer.string("apnea.session_check.incomplete")
                    )
                    statusRow(
                        DIRIOSLocalizer.string("apnea.session_check.status"),
                        statusLabel(for: checkResult.status)
                    )
                }

                if !checkResult.issues.isEmpty {
                    Section(DIRIOSLocalizer.string("apnea.session_check.warning")) {
                        ForEach(checkResult.issues) { issue in
                            Text(DIRIOSLocalizer.string(issue.localizationKey))
                                .foregroundStyle(DIRTheme.orange)
                                .font(.caption)
                        }
                    }
                }

                Section {
                    Text(DIRIOSLocalizer.string("apnea.disclaimer.training_aid"))
                        .font(.caption)
                        .foregroundStyle(DIRTheme.muted)
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle(DIRIOSLocalizer.string("apnea.session_check.title"))
        .onAppear {
            if selectedProfileID == nil {
                selectedProfileID = profileStore.allProfiles().first?.id
            }
        }
    }

    private func statusRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title).foregroundStyle(DIRTheme.muted)
            Spacer()
            Text(value).foregroundStyle(.white)
        }
    }

    private func statusLabel(for status: ApneaSessionCheckStatus) -> String {
        switch status {
        case .ready: return DIRIOSLocalizer.string("apnea.session_check.ready")
        case .warning: return DIRIOSLocalizer.string("apnea.session_check.warning")
        case .incomplete: return DIRIOSLocalizer.string("apnea.session_check.incomplete")
        case .blocked: return DIRIOSLocalizer.string("apnea.session_check.incomplete")
        }
    }
}
