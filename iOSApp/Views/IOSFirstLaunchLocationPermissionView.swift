import SwiftUI

struct IOSFirstLaunchLocationPermissionView: View {
    @EnvironmentObject private var locationPermission: IOSLocationPermissionService
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        DIRDisclaimerScreen(verticalLayout: .center) {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 10) {
                        Image(systemName: "location.fill")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(DIRTheme.cyan)
                        Text(DIRIOSLocalizer.string("ios.location.permission.first_launch.title"))
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    Text(DIRIOSLocalizer.string("ios.location.permission.first_launch.body"))
                        .font(.body)
                        .foregroundStyle(DIRTheme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }

                VStack(spacing: 12) {
                    Button(action: allowLocation) {
                        Text(DIRIOSLocalizer.string("ios.location.permission.allow"))
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(RoundedRectangle(cornerRadius: DIRTheme.cardRadius).fill(DIRTheme.cyan))
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("ios.location.permission.allow")

                    Button(action: deferLocation) {
                        Text(DIRIOSLocalizer.string("ios.location.permission.not_now"))
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(DIRTheme.cyan)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(RoundedRectangle(cornerRadius: DIRTheme.cardRadius).stroke(DIRTheme.cyan, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("ios.location.permission.not_now")
                }
            }
        }
        .accessibilityIdentifier("ios.location.permission.first_launch")
    }

    private func allowLocation() {
        locationPermission.requestWhenInUseFromUserAction()
        IOSFirstLaunchLocationPermissionPolicy.markPresented()
        dismiss()
    }

    private func deferLocation() {
        IOSFirstLaunchLocationPermissionPolicy.markPresented()
        dismiss()
    }
}

struct IOSFirstLaunchLocationPermissionHost<Content: View>: View {
    @EnvironmentObject private var legalAcceptance: LegalAcceptanceStore
    @EnvironmentObject private var locationPermission: IOSLocationPermissionService
    @State private var showFirstLaunchLocationPermission = false
    @ViewBuilder private var content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        content()
            .onAppear {
                evaluateFirstLaunchLocationPermission()
            }
            .onChange(of: legalAcceptance.requiresAcceptance) { _, requiresAcceptance in
                guard !requiresAcceptance else { return }
                evaluateFirstLaunchLocationPermission()
            }
            .onChange(of: locationPermission.authorizationStatus) { _, status in
                guard status != .notDetermined, showFirstLaunchLocationPermission else { return }
                IOSFirstLaunchLocationPermissionPolicy.markPresented()
                showFirstLaunchLocationPermission = false
            }
            .fullScreenCover(isPresented: $showFirstLaunchLocationPermission) {
                IOSFirstLaunchLocationPermissionView()
                    .environmentObject(locationPermission)
            }
    }

    private func evaluateFirstLaunchLocationPermission() {
        guard !legalAcceptance.requiresAcceptance else { return }
        locationPermission.refresh()
        showFirstLaunchLocationPermission = IOSFirstLaunchLocationPermissionPolicy.shouldPresentFirstLaunchPermissionFlow(
            authorizationStatus: locationPermission.authorizationStatus
        )
    }
}
