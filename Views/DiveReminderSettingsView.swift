import SwiftUI

struct DiveReminderSettingsView: View {
    @EnvironmentObject private var reminderSettings: DiveReminderSettingsStore

    var body: some View {
        ZStack {
            DiveScreenBackground()

            ScrollView {
                VStack(spacing: 6) {
                    header

                    Text(String(localized: "dive_reminder.header.title"))
                        .font(DiveUI.Typography.hintCaption)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)

                    toggleRow(
                        String(localized: "dive_reminder.row.global_enabled"),
                        isOn: $reminderSettings.settings.remindersEnabled
                    )

                    Text(String(localized: "watch.reminder.suppression.note"))
                        .font(DiveUI.Typography.rowSubtitle)
                        .foregroundStyle(DiveUI.secondaryText)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityLabel(String(localized: "watch.reminder.suppression.note"))

                    if reminderSettings.canAddReminder {
                        NavigationLink {
                            DiveReminderEditorView(reminder: DiveReminder.makeNew(), isNew: true)
                        } label: {
                            addReminderRow
                        }
                        .buttonStyle(.plain)
                    } else {
                        Text(String(localized: "dive_reminder.error.max_reached"))
                            .font(DiveUI.Typography.rowSubtitle)
                            .foregroundStyle(DiveUI.yellow)
                            .multilineTextAlignment(.center)
                    }

                    if reminderSettings.settings.reminders.isEmpty {
                        Text(String(localized: "dive_reminder.empty_state"))
                            .font(DiveUI.Typography.rowSubtitle)
                            .foregroundStyle(DiveUI.secondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.top, 4)
                    } else {
                        ForEach(reminderSettings.settings.reminders) { reminder in
                            reminderRow(reminder)
                        }
                    }
                }
                .padding(.horizontal, 11)
                .padding(.top, 9)
                .padding(.bottom, 8)
            }
        }
        .navigationTitle(String(localized: "dive_reminder.nav.title"))
        .watchSubscreenBackToolbar()
    }

    private var header: some View {
        HStack(alignment: .center) {
            HStack(spacing: 5) {
                DiveOctopusLogo(accent: DiveUI.yellow)
                    .frame(width: 23, height: 22, alignment: .leading)
                    .scaleEffect(0.68)
                Text(DIRBrandPresentation.displayName)
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundStyle(DiveUI.yellow)
                    .lineLimit(1)
            }
            Spacer()
            DiveClockText(size: 14)
        }
    }

    private var addReminderRow: some View {
        HStack(spacing: 8) {
            Image(systemName: "plus.circle.fill")
                .foregroundStyle(DiveUI.green)
            Text(String(localized: "dive_reminder.action.add"))
                .font(DiveUI.Typography.rowTitle)
                .foregroundStyle(.white)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(DiveUI.secondaryText)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 7)
        .background(
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(DiveUI.green.opacity(0.10))
                .overlay(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .stroke(DiveUI.green.opacity(0.45), lineWidth: 1)
                )
        )
    }

    private func reminderRow(_ reminder: DiveReminder) -> some View {
        HStack(spacing: 8) {
            NavigationLink {
                DiveReminderEditorView(reminder: reminder, isNew: false)
            } label: {
                VStack(alignment: .leading, spacing: 2) {
                    Text(reminder.message.isEmpty ? String(localized: "dive_reminder.row.untitled") : reminder.message)
                        .font(DiveUI.Typography.rowTitle)
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text(reminderSummary(reminder))
                        .font(DiveUI.Typography.rowSubtitle)
                        .foregroundStyle(DiveUI.secondaryText)
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)

            Toggle("", isOn: binding(for: reminder))
                .labelsHidden()
                .tint(DiveUI.green)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .frame(minHeight: DiveUI.Layout.settingsRowInteractiveMinHeight)
        .background(
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(Color.black.opacity(0.52))
                .overlay(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .stroke(reminder.enabled ? DiveUI.yellow.opacity(0.45) : .white.opacity(0.24), lineWidth: 1)
                )
        )
    }

    private func binding(for reminder: DiveReminder) -> Binding<Bool> {
        Binding(
            get: { reminderSettings.reminder(with: reminder.id)?.enabled ?? reminder.enabled },
            set: { newValue in
                guard var updated = reminderSettings.reminder(with: reminder.id) else { return }
                updated.enabled = newValue
                _ = reminderSettings.updateReminder(updated)
            }
        )
    }

    private func reminderSummary(_ reminder: DiveReminder) -> String {
        let minuteText = "\(reminder.intervalMinutes) \(String(localized: "dive_reminder.unit.min"))"
        switch reminder.type {
        case .single:
            return "\(reminder.type.localizedTitle) · \(String(localized: "dive_reminder.label.after")) \(minuteText)"
        case .recurring:
            return "\(reminder.type.localizedTitle) · \(String(localized: "dive_reminder.label.every")) \(minuteText)"
        }
    }

    private func toggleRow(_ title: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Text(title)
                .font(DiveUI.Typography.rowTitle)
                .foregroundStyle(.white)
            Spacer()
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(DiveUI.green)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .frame(minHeight: DiveUI.Layout.settingsRowInteractiveMinHeight)
        .background(
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(Color.black.opacity(0.52))
                .overlay(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .stroke(.white.opacity(0.24), lineWidth: 1)
                )
        )
    }
}
