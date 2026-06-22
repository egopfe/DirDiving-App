import SwiftUI

enum WatchInModeSettingsAccessPolicy {
    static func canPresentSettings(isSessionActive: Bool) -> Bool {
        !isSessionActive
    }
}

struct WatchInModeSettingsAccessButton: View {
    @EnvironmentObject private var navigation: AppNavigationStore

    let isSessionActive: Bool
    let accessibilityLabelKey: String

    var body: some View {
        if WatchInModeSettingsAccessPolicy.canPresentSettings(isSessionActive: isSessionActive) {
            Button {
                HapticService.shared.confirm()
                navigation.selectedPage = .settings
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.cyan)
                    .frame(minWidth: 32, minHeight: 32)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(String(localized: String.LocalizationValue(accessibilityLabelKey)))
            .accessibilityHint(String(localized: "settings.in_mode.a11y.hint"))
        }
    }
}
