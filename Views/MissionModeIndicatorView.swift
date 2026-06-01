import SwiftUI

struct MissionModeIndicatorView: View {
    var body: some View {
        Image(systemName: "bolt.fill")
            .font(.system(size: 8, weight: .black))
            .foregroundStyle(DiveUI.cyan.opacity(0.88))
            .symbolRenderingMode(.hierarchical)
            .accessibilityLabel(String(localized: "mission_mode.a11y.active"))
            .accessibilitySortPriority(-1)
    }
}
