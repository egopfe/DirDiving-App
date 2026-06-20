import SwiftUI

struct DiveReminderEditorView: View {
    @EnvironmentObject private var reminderSettings: DiveReminderSettingsStore
    @Environment(\.dismiss) private var dismiss

    @State private var draft: DiveReminder
    @State private var validationMessage: String?
    private let isNew: Bool

    init(reminder: DiveReminder, isNew: Bool) {
        _draft = State(initialValue: reminder)
        self.isNew = isNew
    }

    var body: some View {
        ZStack {
            DiveScreenBackground()

            ScrollView {
                VStack(spacing: 6) {
                    header

                    toggleRow(String(localized: "dive_reminder.row.enabled"), isOn: $draft.enabled)

                    typePicker

                    minuteStepper

                    messageField

                    presetButtons

                    toggleRow(String(localized: "dive_reminder.row.haptic"), isOn: $draft.hapticEnabled)

                    if let validationMessage {
                        Text(validationMessage)
                            .font(DiveUI.Typography.rowSubtitle)
                            .foregroundStyle(DiveUI.red)
                            .multilineTextAlignment(.center)
                    }

                    DiveCommandButton(String(localized: "dive_reminder.action.save"), systemImage: "checkmark", color: DiveUI.green) {
                        saveReminder()
                    }

                    if !isNew {
                        DiveCommandButton(String(localized: "dive_reminder.action.delete"), systemImage: "trash", color: DiveUI.red) {
                            reminderSettings.deleteReminder(id: draft.id)
                            dismiss()
                        }
                    }
                }
                .padding(.horizontal, 11)
                .padding(.top, 9)
                .padding(.bottom, 8)
            }
        }
        .navigationTitle(String(localized: isNew ? "dive_reminder.nav.add" : "dive_reminder.nav.edit"))
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

    private var typePicker: some View {
        VStack(spacing: 5) {
            ForEach(DiveReminderType.allCases) { type in
                Button {
                    draft.type = type
                    if type == .recurring, draft.repeatEveryMinutes == nil {
                        draft.repeatEveryMinutes = draft.triggerMinute
                    }
                } label: {
                    HStack {
                        Text(type.localizedTitle)
                            .font(DiveUI.Typography.rowTitle)
                            .foregroundStyle(.white)
                        Spacer()
                        if draft.type == type {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(DiveUI.green)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 7)
                    .background(
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .fill(Color.black.opacity(0.52))
                            .overlay(
                                RoundedRectangle(cornerRadius: 7, style: .continuous)
                                    .stroke(draft.type == type ? DiveUI.yellow.opacity(0.65) : .white.opacity(0.24), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var minuteStepper: some View {
        let binding = Binding(
            get: { Double(draft.intervalMinutes) },
            set: { value in
                let minute = DiveReminderValidation.clampedMinute(Int(value.rounded()))
                if draft.type == .single {
                    draft.triggerMinute = minute
                } else {
                    draft.repeatEveryMinutes = minute
                    draft.triggerMinute = minute
                }
            }
        )
        let title = draft.type == .single
            ? String(localized: "dive_reminder.row.after_minutes")
            : String(localized: "dive_reminder.row.every_minutes")
        return crownMinuteStepper(
            title: title,
            value: binding,
            display: "\(draft.intervalMinutes) \(String(localized: "dive_reminder.unit.min"))"
        )
    }

    private var messageField: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(String(localized: "dive_reminder.row.message"))
                    .font(DiveUI.Typography.rowTitle)
                    .foregroundStyle(.white)
                Spacer()
                Text("\(draft.message.count)/\(DiveReminderLimits.maxMessageLength)")
                    .font(DiveUI.Typography.rowSubtitle)
                    .foregroundStyle(DiveUI.secondaryText)
            }
            TextField(String(localized: "dive_reminder.row.message"), text: $draft.message)
                .foregroundStyle(.white)
                .font(DiveUI.Typography.rowTitle)
                .onChange(of: draft.message) { _, newValue in
                    if newValue.count > DiveReminderLimits.maxMessageLength {
                        draft.message = String(newValue.prefix(DiveReminderLimits.maxMessageLength))
                    }
                }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 7)
        .background(
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(Color.black.opacity(0.52))
                .overlay(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .stroke(.white.opacity(0.24), lineWidth: 1)
                )
        )
    }

    private var presetButtons: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(DiveReminderPreset.allCases, id: \.self) { preset in
                Button {
                    draft.message = preset.localizedMessage
                } label: {
                    Text(preset.localizedMessage)
                        .font(DiveUI.Typography.rowSubtitle)
                        .foregroundStyle(DiveUI.cyan)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(DiveUI.cyan.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .stroke(DiveUI.cyan.opacity(0.35), lineWidth: 1)
                )
        )
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

    private func crownMinuteStepper(title: String, value: Binding<Double>, display: String) -> some View {
        HStack(spacing: 7) {
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(DiveUI.Typography.rowTitle)
                    .foregroundStyle(.white)
                    .lineLimit(2)
                Text(display)
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(DiveUI.yellow)
                    .monospacedDigit()
            }
            Spacer(minLength: 0)
            Button {
                value.wrappedValue = max(Double(DiveReminderLimits.minuteRange.lowerBound), value.wrappedValue - 1)
            } label: {
                Image(systemName: "minus")
                    .font(.system(size: 13, weight: .black))
                    .frame(width: 40, height: DiveUI.Layout.alarmStepperMinHeight)
                    .background(RoundedRectangle(cornerRadius: 9, style: .continuous).fill(DiveUI.yellow.opacity(0.18)))
            }
            .buttonStyle(.plain)
            .foregroundStyle(DiveUI.yellow)
            Button {
                value.wrappedValue = min(Double(DiveReminderLimits.minuteRange.upperBound), value.wrappedValue + 1)
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 13, weight: .black))
                    .frame(width: 40, height: DiveUI.Layout.alarmStepperMinHeight)
                    .background(RoundedRectangle(cornerRadius: 9, style: .continuous).fill(DiveUI.yellow.opacity(0.18)))
            }
            .buttonStyle(.plain)
            .foregroundStyle(DiveUI.yellow)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .frame(minHeight: 46)
        .background(
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(DiveUI.yellow.opacity(0.10))
                .overlay(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .stroke(DiveUI.yellow.opacity(0.45), lineWidth: 1)
                )
        )
        .focusable(true)
        .digitalCrownRotation(
            value,
            from: Double(DiveReminderLimits.minuteRange.lowerBound),
            through: Double(DiveReminderLimits.minuteRange.upperBound),
            by: 1,
            sensitivity: .medium,
            isContinuous: false,
            isHapticFeedbackEnabled: true
        )
    }

    private func saveReminder() {
        guard DiveReminderValidation.sanitizedMessage(draft.message) != nil else {
            validationMessage = String(localized: "dive_reminder.error.message_required")
            return
        }
        validationMessage = nil
        let saved = isNew ? reminderSettings.addReminder(draft) : reminderSettings.updateReminder(draft)
        guard saved else {
            validationMessage = String(localized: "dive_reminder.error.message_too_long")
            return
        }
        dismiss()
    }
}
