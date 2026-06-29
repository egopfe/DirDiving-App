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
    @ObservedObject private var importedPlan = ApneaImportedPlanStore.shared

    private var presentation: ApneaWatchImportedPlanPresentation {
        importedPlan.readyPresentation
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            WatchSettingsSectionHeader(title: String(localized: "settings.section.apnea"))

            settingsInfoRow(
                icon: "lungs.fill",
                iconColor: DiveUI.cyan,
                title: String(localized: "settings.apnea.recovery.title"),
                subtitle: presentation.hasImportedPlan
                    ? presentation.recoveryPolicyLabel
                    : String(localized: "settings.apnea.recovery.subtitle")
            )

            if presentation.hasImportedPlan {
                settingsInfoRow(
                    icon: "target",
                    iconColor: DiveUI.blue,
                    title: String(localized: "settings.apnea.target_depth.title"),
                    subtitle: String(format: String(localized: "settings.apnea.target_depth.value"), Int(presentation.targetDepthMeters))
                )
                settingsInfoRow(
                    icon: "bell.badge.fill",
                    iconColor: DiveUI.green,
                    title: String(localized: "settings.apnea.alarms.title"),
                    subtitle: presentation.enabledAlarmLabels.isEmpty
                        ? String(localized: "settings.apnea.alarms.none")
                        : presentation.enabledAlarmLabels.joined(separator: ", ")
                )
                settingsInfoRow(
                    icon: "moon.stars.fill",
                    iconColor: presentation.missionModeEnabled ? DiveUI.yellow : DiveUI.mutedText,
                    title: String(localized: "settings.apnea.mission_mode.title"),
                    subtitle: presentation.missionModeEnabled
                        ? String(localized: "settings.apnea.mission_mode.on")
                        : String(localized: "settings.apnea.mission_mode.off")
                )
            }

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
    @ObservedObject private var importedRoute = SnorkelingImportedRouteStore.shared
    @AppStorage(MissionModeSettings.autoEnableOnDiveStartKey) private var missionModeAutoEnableOnDiveStart = false

    private var routePlan: SnorkelingRoutePlan? {
        importedRoute.activeRoutePlan
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            WatchSettingsSectionHeader(title: String(localized: "settings.section.snorkeling"))

            settingsInfoRow(
                icon: "location.fill",
                iconColor: gps.locationPermissionState.isAuthorized ? DiveUI.green : DiveUI.red,
                title: String(localized: "settings.snorkeling.gps.title"),
                subtitle: gpsStatusSubtitle
            )

            settingsInfoRow(
                icon: "map.fill",
                iconColor: DiveUI.cyan,
                title: String(localized: "settings.snorkeling.route.title"),
                subtitle: routePlan?.name ?? String(localized: "settings.snorkeling.route.subtitle")
            )

            if let routePlan {
                settingsInfoRow(
                    icon: "mappin.and.ellipse",
                    iconColor: DiveUI.cyan,
                    title: String(localized: "settings.snorkeling.waypoints.title"),
                    subtitle: String(format: String(localized: "settings.snorkeling.waypoints.count"), routePlan.waypoints.count)
                )
            }

            settingsInfoRow(
                icon: "arrow.uturn.backward.circle.fill",
                iconColor: DiveUI.cyan,
                title: String(localized: "settings.snorkeling.return.title"),
                subtitle: String(localized: "settings.snorkeling.return.subtitle")
            )

            settingsInfoRow(
                icon: "moon.stars.fill",
                iconColor: missionModeAutoEnableOnDiveStart ? DiveUI.yellow : DiveUI.mutedText,
                title: String(localized: "settings.snorkeling.mission_mode.title"),
                subtitle: missionModeAutoEnableOnDiveStart
                    ? String(localized: "settings.snorkeling.mission_mode.on")
                    : String(localized: "settings.snorkeling.mission_mode.off")
            )

            Text(String(localized: "settings.snorkeling.scope.note"))
                .font(DiveUI.Typography.hintCaption)
                .foregroundStyle(DiveUI.mutedText)
                .multilineTextAlignment(.leading)
        }
        .disabled(dive.isDiveActive)
    }

    private var gpsStatusSubtitle: String {
        switch gps.locationPermissionState {
        case .authorized:
            return String(localized: "settings.snorkeling.gps.authorized")
        case .denied, .restricted:
            return String(localized: "settings.snorkeling.gps.denied")
        case .notDetermined:
            return String(localized: "settings.snorkeling.gps.subtitle")
        }
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
