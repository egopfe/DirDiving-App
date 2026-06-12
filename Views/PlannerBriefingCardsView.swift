import SwiftUI

struct PlannerBriefingCardsView: View {
    @EnvironmentObject private var briefingStore: PlannerBriefingCardStore
    @EnvironmentObject private var dive: DiveManager

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

                if let manifest = briefingStore.manifest, !briefingStore.sortedCards.isEmpty {
                    Text(manifest.modeLabel)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.85))
                    Text(Self.generatedAtLabel(manifest.generatedAt))
                        .font(.caption2)
                        .foregroundStyle(.gray)

                    ForEach(briefingStore.sortedCards) { card in
                        if let path = briefingStore.imagePaths[card.id],
                           let image = UIImage(contentsOfFile: path) {
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
    }

    private static func generatedAtLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

extension PlannerBriefingCardStore {
    var sortedCards: [PlannerBriefingCardMetadata] {
        (manifest?.cards ?? []).sorted { $0.order < $1.order }
    }
}
