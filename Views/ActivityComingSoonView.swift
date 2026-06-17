import SwiftUI

struct ActivityComingSoonView: View {
    let activity: DIRActivityMode
    @EnvironmentObject private var activitySelection: DIRActivitySelectionStore

    var body: some View {
        VStack(spacing: DiveUI.spaceL) {
            Spacer(minLength: 8)

            DiveScreenHeader(
                localizedTitle,
                subtitle: String(localized: "startup.coming_soon.subtitle"),
                accent: DiveUI.cyan,
                systemImage: "hourglass"
            )

            DivePanel(stroke: DiveUI.yellow) {
                Text(String(localized: "startup.coming_soon.body"))
                    .font(DiveUI.Typography.rowSubtitle)
                    .foregroundStyle(DiveUI.secondaryText)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Button {
                HapticService.shared.confirm()
                activitySelection.dismissComingSoon()
            } label: {
                Text(String(localized: "startup.coming_soon.back"))
                    .font(DiveUI.Typography.commandButton)
                    .foregroundStyle(DiveUI.cyan)
                    .frame(maxWidth: .infinity, minHeight: DiveUI.Layout.commandButtonMinHeight)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(DiveUI.cyan.opacity(0.75), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, DiveUI.screenPadding)
    }

    private var localizedTitle: String {
        switch activity {
        case .apnea: return String(localized: "startup.activity.apnea")
        case .snorkeling: return String(localized: "startup.activity.snorkeling")
        case .diving: return String(localized: "startup.activity.diving")
        }
    }
}
