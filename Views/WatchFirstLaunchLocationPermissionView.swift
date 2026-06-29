import SwiftUI

struct WatchFirstLaunchLocationPermissionView: View {
    @EnvironmentObject private var gps: GPSManager
    let onComplete: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Image(systemName: iconName)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(iconColor)

                Text(String(localized: "watch.location.first_launch.title"))
                    .font(.headline)
                    .multilineTextAlignment(.center)

                Text(bodyText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                if gps.locationPermissionState == .notDetermined {
                    Button(String(localized: "watch.location.first_launch.allow")) {
                        gps.requestWhenInUseFromOnboarding()
                        WatchFirstLaunchLocationPermissionPolicy.markPresented()
                        onComplete()
                    }

                    Button(String(localized: "watch.location.first_launch.not_now")) {
                        WatchFirstLaunchLocationPermissionPolicy.markPresented()
                        onComplete()
                    }
                    .buttonStyle(.borderless)
                } else {
                    Button(String(localized: "common.continue")) {
                        WatchFirstLaunchLocationPermissionPolicy.markPresented()
                        onComplete()
                    }
                }
            }
            .padding()
        }
        .accessibilityIdentifier("watch.location.first_launch")
        .onAppear {
            gps.refreshAuthorizationStatus()
        }
    }

    private var bodyText: String {
        if gps.locationPermissionState.isDeniedOrRestricted {
            return String(localized: "watch.location.permission.denied.body")
        }
        return String(localized: "watch.location.first_launch.body")
    }

    private var iconName: String {
        gps.locationPermissionState.isDeniedOrRestricted ? "location.slash.fill" : "location.fill"
    }

    private var iconColor: Color {
        gps.locationPermissionState.isDeniedOrRestricted ? DiveUI.orange : DiveUI.cyan
    }
}

struct WatchFirstLaunchLocationPermissionHost<Content: View>: View {
    @EnvironmentObject private var legalAcceptance: LegalAcceptanceStore
    @EnvironmentObject private var gps: GPSManager
    @State private var showFirstLaunchLocationPermission = false
    @Binding private var launchDisclaimerPresented: Bool
    @ViewBuilder private var content: () -> Content

    init(
        launchDisclaimerPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        _launchDisclaimerPresented = launchDisclaimerPresented
        self.content = content
    }

    var body: some View {
        content()
            .onAppear {
                evaluateFirstLaunchLocationPermission()
            }
            .onChange(of: launchDisclaimerPresented) { _, isPresented in
                guard !isPresented else { return }
                evaluateFirstLaunchLocationPermission()
            }
            .onChange(of: legalAcceptance.requiresAcceptance) { _, requiresAcceptance in
                guard !requiresAcceptance else { return }
                evaluateFirstLaunchLocationPermission()
            }
            .fullScreenCover(isPresented: $showFirstLaunchLocationPermission) {
                WatchFirstLaunchLocationPermissionView {
                    showFirstLaunchLocationPermission = false
                }
                .environmentObject(gps)
            }
    }

    private func evaluateFirstLaunchLocationPermission() {
        guard !launchDisclaimerPresented else { return }
        guard !legalAcceptance.requiresAcceptance else { return }
        gps.refreshAuthorizationStatus()
        showFirstLaunchLocationPermission = WatchFirstLaunchLocationPermissionPolicy.shouldPresentFirstLaunchPermissionFlow(
            authorizationStatus: gps.authorizationStatus,
            legalAccepted: legalAcceptance.hasAccepted
        )
    }
}
