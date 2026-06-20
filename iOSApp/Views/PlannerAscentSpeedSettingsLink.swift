import SwiftUI

/// Contextual entry to canonical global ascent-speed settings (stored in PlannerAscentSpeedSettings).
struct PlannerAscentSpeedSettingsLink: View {
    var body: some View {
        NavigationLink {
            PlannerAscentSpeedSettingsView()
        } label: {
            HStack {
                Label(
                    DIRIOSLocalizer.string("settings.planner_ascent_speeds.title"),
                    systemImage: "arrow.up.circle"
                )
                .foregroundStyle(DIRTheme.cyan)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(DIRTheme.muted)
            }
            .font(.callout.weight(.semibold))
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(DIRIOSLocalizer.string("settings.planner_ascent_speeds.title"))
        .accessibilityHint(DIRIOSLocalizer.string("planner.ascent_speeds.link.a11y.hint"))
        .accessibilityIdentifier("planner.ascent_speeds.link")
    }
}
