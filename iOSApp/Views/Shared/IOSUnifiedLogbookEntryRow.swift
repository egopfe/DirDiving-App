import SwiftUI

struct IOSUnifiedLogbookEntryRow: View {
    let entry: IOSUnifiedLogbookEntry

    private var accent: Color {
        CompanionActivityPresentation.accent(for: entry.activity.dirActivityMode)
    }

    private var badgeText: String {
        switch entry.activity {
        case .diving: return DIRIOSLocalizer.string("logbook.activity.badge.diving")
        case .snorkeling: return DIRIOSLocalizer.string("logbook.activity.badge.snorkeling")
        case .apnea: return DIRIOSLocalizer.string("logbook.activity.badge.apnea")
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(badgeText)
                        .font(DIRTypography.microBadge)
                        .foregroundStyle(accent)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(accent.opacity(0.8), lineWidth: 1)
                        )
                        .accessibilityLabel(badgeText)
                    Text(entry.title)
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                }
                Text(entry.subtitle)
                    .font(.caption)
                    .foregroundStyle(DIRTheme.muted)
                    .lineLimit(2)
                HStack(spacing: 12) {
                    metricLabel(entry.primaryMetric)
                    if let secondary = entry.secondaryMetric, !secondary.isEmpty {
                        metricLabel(secondary)
                    }
                    if let tertiary = entry.tertiaryMetric, !tertiary.isEmpty {
                        metricLabel(tertiary)
                    }
                }
            }
            Spacer(minLength: 4)
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.72))
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(DIRTheme.surface.opacity(0.8))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(DIRTheme.hairline, lineWidth: 1))
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilitySummary)
    }

    private func metricLabel(_ text: String) -> some View {
        Text(text)
            .font(.caption.monospacedDigit())
            .foregroundStyle(.white.opacity(0.86))
    }

    private var accessibilitySummary: String {
        [
            badgeText,
            entry.title,
            entry.subtitle,
            entry.primaryMetric,
            entry.secondaryMetric,
            entry.tertiaryMetric
        ]
        .compactMap { $0 }
        .filter { !$0.isEmpty }
        .joined(separator: ", ")
    }
}
