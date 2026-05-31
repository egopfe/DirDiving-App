import SwiftUI

struct MissionModeIndicatorView: View {
    var body: some View {
        Image(systemName: "bolt.fill")
            .font(.system(size: 7.5, weight: .black))
            .foregroundStyle(DiveUI.cyan.opacity(0.82))
            .symbolRenderingMode(.hierarchical)
            .accessibilityLabel("Mission Mode Active")
            .accessibilitySortPriority(-1)
    }
}
