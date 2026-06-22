import SwiftUI

/// Activity-scoped Settings mode picker — visibility only, not runtime routing.
struct IOSCompanionSettingsModeSwitcher: View {
    @Binding var selection: DIRActivityMode

    private let modes: [DIRActivityMode] = [.diving, .apnea, .snorkeling]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(DIRIOSLocalizer.string("settings.mode_switch.title"))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(DIRTheme.muted)
            Picker(
                DIRIOSLocalizer.string("settings.mode_switch.a11y.label"),
                selection: $selection
            ) {
                ForEach(modes) { mode in
                    Text(label(for: mode)).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .accessibilityLabel(DIRIOSLocalizer.string("settings.mode_switch.a11y.label"))
            .accessibilityValue(label(for: selection))
            .accessibilityHint(DIRIOSLocalizer.string("settings.mode_switch.a11y.hint"))
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .contain)
    }

    private func label(for mode: DIRActivityMode) -> String {
        switch mode {
        case .diving:
            return DIRIOSLocalizer.string("settings.mode_switch.diving")
        case .apnea:
            return DIRIOSLocalizer.string("settings.mode_switch.apnea")
        case .snorkeling:
            return DIRIOSLocalizer.string("settings.mode_switch.snorkeling")
        }
    }
}
