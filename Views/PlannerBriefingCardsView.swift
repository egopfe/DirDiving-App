import SwiftUI

struct PlannerBriefingCardsView: View {
    @EnvironmentObject private var briefingStore: PlannerBriefingCardStore
    @EnvironmentObject private var dive: DiveManager
    @State private var selectedCard: PlannerBriefingCardMetadata?

    private var freshnessState: PlannerBriefingFreshnessState {
        PlannerBriefingFreshnessPolicy.evaluate(
            manifest: briefingStore.manifest,
            isPackageIncomplete: briefingStore.isPackageIncomplete
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text(String(localized: "watch.planner_briefing.title"))
                    .font(DiveUI.Typography.screenTitle)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)

                Text(String(localized: "watch.planner_briefing.ref_only"))
                    .font(.caption2)
                    .foregroundStyle(DiveUI.yellow)
                    .frame(maxWidth: .infinity)

                if briefingStore.isPackageIncomplete {
                    Text(String(format: String(localized: "watch.planner_briefing.incomplete_format"), briefingStore.missingCardCount, briefingStore.expectedCardCount))
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(DiveUI.yellow)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if let warning = PlannerBriefingFreshnessPolicy.localizedWarning(for: freshnessState) {
                    Text(warning)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(DiveUI.yellow)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityLabel(
                            PlannerBriefingFreshnessPolicy.accessibilityLabel(for: freshnessState) ?? warning
                        )
                }

                if let sessionId = briefingStore.manifest?.plannerSessionId {
                    Text(String(format: String(localized: "watch.planner_briefing.session_format"), String(sessionId.uuidString.prefix(8))))
                        .font(.caption2)
                        .foregroundStyle(.gray)
                }

                if let manifest = briefingStore.manifest, !briefingStore.sortedCards.isEmpty {
                    Text(manifest.modeLabel)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.85))
                    Text(PlannerBriefingFreshnessPolicy.formattedGeneratedAt(manifest.generatedAt))
                        .font(.caption2)
                        .foregroundStyle(.gray)

                    ForEach(briefingStore.sortedCards) { card in
                        if let path = briefingStore.imagePaths[card.id],
                           let image = UIImage(contentsOfFile: path) {
                            Button {
                                selectedCard = card
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(card.title)
                                        .font(.caption2.weight(.semibold))
                                        .foregroundStyle(DiveUI.cyan)
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxWidth: .infinity)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(
                                String(format: String(localized: "watch.planner_briefing.card_inventory.a11y"), card.title)
                            )
                            .accessibilityHint(String(localized: "watch.planner_briefing.card_detail.open.a11y"))
                        }
                    }

                    Button(role: .destructive) {
                        try? briefingStore.deleteBriefing()
                    } label: {
                        Text(String(localized: "watch.planner_briefing.delete"))
                            .font(.callout.weight(.semibold))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                    .disabled(dive.isDiveActive)
                } else {
                    Text(String(localized: "watch.planner_briefing.empty.title"))
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.white)
                    Text(String(localized: "watch.planner_briefing.empty.message"))
                        .font(.caption2)
                        .foregroundStyle(.gray)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
        }
        .onAppear {
            briefingStore.reload()
        }
        .sheet(item: $selectedCard) { card in
            PlannerBriefingCardDetailSheet(
                card: card,
                imagePath: briefingStore.imagePaths[card.id],
                freshnessState: freshnessState,
                isDiveActive: dive.isDiveActive,
                onDelete: { try? briefingStore.deleteBriefing() }
            )
        }
    }
}

extension PlannerBriefingCardStore {
    var sortedCards: [PlannerBriefingCardMetadata] {
        (manifest?.cards ?? []).sorted { $0.order < $1.order }
    }
}
