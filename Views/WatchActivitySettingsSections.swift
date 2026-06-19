import SwiftUI

/// Activity-scoped Watch Settings surfaces (Command 15 AUDIT15-UX-004).
enum WatchActivitySettingsScope {
    static func isDivingOnlySettingVisible(for activity: DIRActivityMode) -> Bool {
        activity == .diving
    }

    static func isApneaOnlySettingVisible(for activity: DIRActivityMode) -> Bool {
        activity == .apnea
    }

    static func isSnorkelingOnlySettingVisible(for activity: DIRActivityMode) -> Bool {
        activity == .snorkeling
    }
}

struct WatchApneaActivitySettingsSection: View {
    @EnvironmentObject private var dive: DiveManager

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            WatchSettingsSectionHeader(title: String(localized: "settings.section.apnea"))

            settingsInfoRow(
                icon: "lungs.fill",
                iconColor: DiveUI.cyan,
                title: String(localized: "settings.apnea.recovery.title"),
                subtitle: String(localized: "settings.apnea.recovery.subtitle")
            )

            settingsInfoRow(
                icon: "iphone.and.arrow.forward",
                iconColor: DiveUI.cyan,
                title: String(localized: "settings.apnea.companion.title"),
                subtitle: String(localized: "settings.apnea.companion.subtitle")
            )

            Text(String(localized: "settings.apnea.scope.note"))
                .font(DiveUI.Typography.hintCaption)
                .foregroundStyle(DiveUI.mutedText)
                .multilineTextAlignment(.leading)
        }
        .disabled(dive.isDiveActive)
    }

    private func settingsInfoRow(icon: String, iconColor: Color, title: String, subtitle: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(iconColor)
                .frame(width: 26)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(DiveUI.Typography.rowTitle)
                    .foregroundStyle(.white)
                    .lineLimit(2)
                Text(subtitle)
                    .font(DiveUI.Typography.rowSubtitle)
                    .foregroundStyle(DiveUI.secondaryText)
                    .lineLimit(3)
            }
            Spacer(minLength: 0)
        }
        .frame(minHeight: DiveUI.Layout.settingsRowInteractiveMinHeight)
        .padding(.horizontal, 9)
        .padding(.vertical, 7)
        .background(
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(Color.black.opacity(0.52))
                .overlay(RoundedRectangle(cornerRadius: 7, style: .continuous).stroke(.white.opacity(0.24), lineWidth: 1))
        )
        .accessibilityElement(children: .combine)
    }
}

struct WatchSnorkelingActivitySettingsSection: View {
    @EnvironmentObject private var dive: DiveManager
    @EnvironmentObject private var gps: GPSManager

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            WatchSettingsSectionHeader(title: String(localized: "settings.section.snorkeling"))

            settingsInfoRow(
                icon: "location.fill",
                iconColor: gps.authorizationStatus == .denied ? DiveUI.red : DiveUI.green,
                title: String(localized: "settings.snorkeling.gps.title"),
                subtitle: String(localized: "settings.snorkeling.gps.subtitle")
            )

            settingsInfoRow(
                icon: "map.fill",
                iconColor: DiveUI.cyan,
                title: String(localized: "settings.snorkeling.route.title"),
                subtitle: String(localized: "settings.snorkeling.route.subtitle")
            )

            settingsInfoRow(
                icon: "arrow.uturn.backward.circle.fill",
                iconColor: DiveUI.cyan,
                title: String(localized: "settings.snorkeling.return.title"),
                subtitle: String(localized: "settings.snorkeling.return.subtitle")
            )

            Text(String(localized: "settings.snorkeling.scope.note"))
                .font(DiveUI.Typography.hintCaption)
                .foregroundStyle(DiveUI.mutedText)
                .multilineTextAlignment(.leading)
        }
        .disabled(dive.isDiveActive)
    }

    private func settingsInfoRow(icon: String, iconColor: Color, title: String, subtitle: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(iconColor)
                .frame(width: 26)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(DiveUI.Typography.rowTitle)
                    .foregroundStyle(.white)
                    .lineLimit(2)
                Text(subtitle)
                    .font(DiveUI.Typography.rowSubtitle)
                    .foregroundStyle(DiveUI.secondaryText)
                    .lineLimit(3)
            }
            Spacer(minLength: 0)
        }
        .frame(minHeight: DiveUI.Layout.settingsRowInteractiveMinHeight)
        .padding(.horizontal, 9)
        .padding(.vertical, 7)
        .background(
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(Color.black.opacity(0.52))
                .overlay(RoundedRectangle(cornerRadius: 7, style: .continuous).stroke(.white.opacity(0.24), lineWidth: 1))
        )
        .accessibilityElement(children: .combine)
    }
}
