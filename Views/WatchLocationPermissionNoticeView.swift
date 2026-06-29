import SwiftUI

struct WatchLocationPermissionNoticeView: View {
    @EnvironmentObject private var gps: GPSManager

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(String(localized: "watch.location.permission.gps_unavailable.title"))
                .font(DiveUI.Typography.hintCaptionBold)
                .foregroundStyle(DiveUI.orange)
            Text(String(localized: "watch.location.permission.gps_unavailable.body"))
                .font(DiveUI.Typography.hintCaption)
                .foregroundStyle(DiveUI.secondaryText)
                .fixedSize(horizontal: false, vertical: true)

            if gps.locationPermissionState == .notDetermined {
                Button(String(localized: "watch.location.first_launch.allow")) {
                    gps.requestWhenInUseFromOnboarding()
                }
                .font(DiveUI.Typography.hintCaptionBold)
            } else if gps.locationPermissionState.isDeniedOrRestricted {
                Text(String(localized: "watch.location.permission.enable_in_settings"))
                    .font(DiveUI.Typography.hintCaptionBold)
                    .foregroundStyle(DiveUI.cyan)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(DiveUI.orange.opacity(0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(DiveUI.orange.opacity(0.55), lineWidth: 1)
                )
        )
        .accessibilityIdentifier("watch.location.permission.notice")
        .onAppear {
            gps.refreshAuthorizationStatus()
        }
    }
}

struct WatchPrivacyLocationSettingsSection: View {
    @EnvironmentObject private var gps: GPSManager
    @EnvironmentObject private var dive: DiveManager

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            settingsInfoRow(
                icon: "location.fill",
                iconColor: statusColor,
                title: String(localized: "watch.settings.location.title"),
                subtitle: statusText
            )

            if gps.locationPermissionState == .notDetermined {
                Button(String(localized: "watch.location.first_launch.allow")) {
                    gps.requestWhenInUseFromOnboarding()
                }
                .font(DiveUI.Typography.rowTitle)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 9)
            } else if gps.locationPermissionState.isDeniedOrRestricted {
                Text(String(localized: "watch.location.permission.denied.body"))
                    .font(DiveUI.Typography.hintCaption)
                    .foregroundStyle(DiveUI.secondaryText)
                    .padding(.horizontal, 4)
            }
        }
        .disabled(dive.isDiveActive)
        .onAppear {
            gps.refreshAuthorizationStatus()
        }
    }

    private var statusText: String {
        switch gps.locationPermissionState {
        case .authorized:
            return String(localized: "watch.settings.location.authorized")
        case .notDetermined:
            return String(localized: "watch.settings.location.not_determined")
        case .denied:
            return String(localized: "watch.settings.location.denied")
        case .restricted:
            return String(localized: "watch.settings.location.restricted")
        }
    }

    private var statusColor: Color {
        switch gps.locationPermissionState {
        case .authorized:
            return DiveUI.green
        case .notDetermined:
            return DiveUI.yellow
        case .denied, .restricted:
            return DiveUI.red
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
