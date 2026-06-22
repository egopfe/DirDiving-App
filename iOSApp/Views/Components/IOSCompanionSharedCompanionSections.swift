import SwiftUI

/// Shared companion sections shown at the bottom of unified Settings surfaces.
struct IOSCompanionSharedCompanionSections: View {
    @EnvironmentObject private var companionActivity: CompanionActivityPreferenceStore

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            IOSCompanionActivitySettingsCard()
            NavigationLink {
                IOSLegalSafetyView()
            } label: {
                HStack {
                    Label(DIRIOSLocalizer.string("more.legal_safety"), systemImage: "checkmark.shield")
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
            .accessibilityLabel(DIRIOSLocalizer.string("more.legal_safety"))
        }
    }
}
