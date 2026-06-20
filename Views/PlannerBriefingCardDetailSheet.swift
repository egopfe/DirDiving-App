import SwiftUI

struct PlannerBriefingCardDetailSheet: View {
    let card: PlannerBriefingCardMetadata
    let imagePath: String?
    let freshnessState: PlannerBriefingFreshnessState
    let isDiveActive: Bool
    let onDelete: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirm = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text(card.title)
                    .font(DiveUI.Typography.screenTitle)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)

                Text(String(localized: "watch.planner_briefing.ref_only"))
                    .font(.caption2)
                    .foregroundStyle(DiveUI.yellow)

                if let warning = PlannerBriefingFreshnessPolicy.localizedWarning(for: freshnessState) {
                    Text(warning)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(DiveUI.yellow)
                        .accessibilityLabel(
                            PlannerBriefingFreshnessPolicy.accessibilityLabel(for: freshnessState) ?? warning
                        )
                }

                if let imagePath, let image = UIImage(contentsOfFile: imagePath) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .accessibilityLabel(
                            String(format: String(localized: "watch.planner_briefing.card_detail.a11y"), card.title)
                        )
                } else {
                    Text(String(localized: "watch.planner_briefing.card_detail.missing_image"))
                        .font(.caption)
                        .foregroundStyle(DiveUI.orange)
                }

                Button(role: .destructive) {
                    showDeleteConfirm = true
                } label: {
                    Text(String(localized: "watch.planner_briefing.delete"))
                        .font(.callout.weight(.semibold))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
                .disabled(isDiveActive)
                .accessibilityLabel(String(localized: "watch.planner_briefing.delete"))
                .accessibilityHint(
                    isDiveActive
                        ? String(localized: "watch.planner_briefing.delete.disabled_dive.a11y")
                        : String(localized: "watch.planner_briefing.delete.a11y.hint")
                )
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
        }
        .confirmationDialog(
            String(localized: "watch.planner_briefing.delete.confirm.title"),
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button(String(localized: "watch.planner_briefing.delete.confirm.action"), role: .destructive) {
                onDelete()
                dismiss()
            }
            Button(String(localized: "common.cancel"), role: .cancel) {}
        }
    }
}
