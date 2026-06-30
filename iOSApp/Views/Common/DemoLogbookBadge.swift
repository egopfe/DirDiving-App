import SwiftUI

struct DemoLogbookBadge: View {
    var body: some View {
        Text(DIRIOSLocalizer.string("settings.demo_logbook.badge"))
            .font(.caption2.weight(.bold))
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(DIRTheme.orange.opacity(0.2))
            .foregroundStyle(DIRTheme.orange)
            .clipShape(Capsule())
            .accessibilityLabel(DIRIOSLocalizer.string("settings.demo_logbook.badge"))
    }
}
