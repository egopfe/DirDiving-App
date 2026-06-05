import SwiftUI

struct MissionModeIndicatorView: View {
    var isActive: Bool

    var body: some View {
        Image(systemName: isActive ? "bolt.fill" : "bolt")
            .font(.system(size: 10, weight: .black, design: .rounded))
            .foregroundStyle(isActive ? DiveUI.cyan.opacity(0.88) : DiveUI.secondaryText.opacity(0.72))
            .symbolRenderingMode(.hierarchical)
            .accessibilityLabel(
                isActive
                    ? String(localized: "mission_mode.a11y.active")
                    : String(localized: "mission_mode.a11y.inactive")
            )
            .accessibilityHint(String(localized: "mission_mode.a11y.hint"))
            .accessibilitySortPriority(-1)
    }
}
