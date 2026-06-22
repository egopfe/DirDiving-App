import SwiftUI

struct IOSCompanionActivitySelectionView: View {
    @EnvironmentObject private var activityStore: CompanionActivityPreferenceStore
    @EnvironmentObject private var watchSync: WatchSyncService
    @State private var unavailableMode: DIRActivityMode?

    private let modes: [DIRActivityMode] = [.diving, .apnea, .snorkeling]

    var body: some View {
        DIRScreenContainer {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    header
                    ForEach(modes) { mode in
                        activityCard(mode)
                    }
                    safetyCard
                    settingsReminder
                }
                .padding(.horizontal, 18)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
            .dirCompanionScrollSurface()
        }
        .sheet(item: $unavailableMode) { mode in
            IOSCompanionActivityComingSoonView(mode: mode)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(DIRIOSLocalizer.string("brand.name"))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(DIRTheme.muted)
                .tracking(1.2)
            Text(DIRIOSLocalizer.string("companion.activitySelection.title"))
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(3)
                .minimumScaleFactor(0.85)
            Text(DIRIOSLocalizer.string("companion.activitySelection.subtitle"))
                .font(.callout)
                .foregroundStyle(DIRTheme.muted)
                .lineLimit(4)
                .minimumScaleFactor(0.85)
        }
        .accessibilityElement(children: .combine)
        .accessibilitySortPriority(100)
    }

    private func activityCard(_ mode: DIRActivityMode) -> some View {
        let isAvailable = CompanionActivityAvailability.isAvailable(mode)
        let isLastUsed = activityStore.isLastUsedMode(mode)
        let accent = CompanionActivityPresentation.accent(for: mode)
        return Button {
            handleSelection(mode)
        } label: {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    Circle()
                        .fill(accent.opacity(isAvailable ? 0.18 : 0.08))
                        .frame(width: 52, height: 52)
                    Circle()
                        .stroke(accent.opacity(isAvailable ? 0.85 : 0.35), lineWidth: 1)
                        .frame(width: 52, height: 52)
                    Image(systemName: CompanionActivityPresentation.icon(for: mode))
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(isAvailable ? accent : DIRTheme.muted)
                }

                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text(CompanionActivityPresentation.title(for: mode))
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(isAvailable ? .white : DIRTheme.muted)
                        if isLastUsed {
                            Text(CompanionActivityCopy.lastUsedBadge())
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(accent)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(
                                    Capsule()
                                        .fill(accent.opacity(0.16))
                                        .overlay(
                                            Capsule()
                                                .stroke(accent.opacity(0.55), lineWidth: 1)
                                        )
                                )
                                .accessibilityHidden(true)
                        }
                    }
                    Text(CompanionActivityPresentation.subtitle(for: mode))
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(DIRTheme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                    ForEach(CompanionActivityPresentation.features(for: mode), id: \.self) { feature in
                        Label(feature, systemImage: "checkmark.circle.fill")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(isAvailable ? accent.opacity(0.95) : DIRTheme.muted.opacity(0.7))
                            .labelStyle(.titleAndIcon)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: isLastUsed ? "checkmark.circle.fill" : "chevron.right")
                    .font(isLastUsed ? .body.weight(.bold) : .caption.weight(.bold))
                    .foregroundStyle(isAvailable ? accent : DIRTheme.muted.opacity(0.5))
                    .padding(.top, 8)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: DIRTheme.cardRadius)
                    .fill(Color.black.opacity(isLastUsed ? 0.62 : 0.55))
                    .overlay(
                        RoundedRectangle(cornerRadius: DIRTheme.cardRadius)
                            .stroke(
                                accent.opacity(isAvailable ? (isLastUsed ? 0.95 : 0.65) : 0.25),
                                lineWidth: isLastUsed ? 2 : 1
                            )
                    )
            )
            .opacity(isAvailable ? 1 : 0.72)
        }
        .buttonStyle(.plain)
        .disabled(!isAvailable)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(CompanionActivityPresentation.accessibilitySummary(for: mode, isLastUsed: isLastUsed))
        .accessibilityHint(CompanionActivityPresentation.accessibilityHint(for: mode, isAvailable: isAvailable))
        .accessibilityAddTraits(.isButton)
    }

    private var safetyCard: some View {
        DIRCard(
            DIRIOSLocalizer.string("companion.activitySelection.safety.title"),
            icon: "checkmark.shield.fill",
            accent: DIRTheme.safetyInfo
        ) {
            Text(DIRIOSLocalizer.string("companion.activitySelection.safety.body"))
                .font(.callout)
                .foregroundStyle(DIRTheme.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }

    private var settingsReminder: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "gearshape.fill")
                .foregroundStyle(DIRTheme.muted)
            Text(DIRIOSLocalizer.string("companion.activitySelection.settingsReminder"))
                .font(.footnote)
                .foregroundStyle(DIRTheme.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, 4)
        .accessibilityElement(children: .combine)
    }

    private func handleSelection(_ mode: DIRActivityMode) {
        guard CompanionActivityAvailability.isAvailable(mode) else {
            unavailableMode = mode
            return
        }
        let watchActive = watchSync.userVisibleState == DIRIOSLocalizer.string("sync.status.watch_session_active")
        _ = activityStore.select(mode, watchReportsActiveSession: watchActive)
    }
}

struct IOSCompanionActivityComingSoonView: View {
    let mode: DIRActivityMode
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            DIRScreenContainer {
                VStack(alignment: .leading, spacing: 16) {
                    Text(CompanionActivityPresentation.title(for: mode))
                        .dirScreenTitleStyle()
                    Text(DIRIOSLocalizer.string("companion.activitySelection.unavailable"))
                        .font(.callout)
                        .foregroundStyle(DIRTheme.muted)
                    Spacer()
                }
                .padding(18)
            }
            .navigationTitle(DIRIOSLocalizer.string("companion.activitySelection.unavailable"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(DIRIOSLocalizer.string("common.ok")) { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
    }
}