import SwiftUI

@main
struct DIRDivingiOSApp: App {
    @StateObject private var stores = IOSCompanionStoreCoordinator()
    @StateObject private var locationPermissionService = IOSLocationPermissionService()

    init() {
        SensorSourceMode.applyReleaseSafeMigrationIfNeeded()
        IOSWindowChromeConfigurator.applyUIKitAppearance()
        ApneaCloudBackupPreference.reconcileWithCapability()
        SnorkelingCloudBackupPreference.reconcileWithCapability()
    }

    var body: some Scene {
        WindowGroup {
            stores.applyGlobalEnvironment(to:
                IOSRootShell {
                    IOSFirstLaunchLocationPermissionHost {
                        Group {
                            if stores.legalAcceptance.requiresAcceptance {
                                IOSLegalOnboardingView(
                                    languageCode: stores.sharedSettings.language.resolvedLanguageCode
                                )
                            } else if stores.companionActivity.shouldPresentSelectionScreen {
                                IOSCompanionActivitySelectionView()
                            } else if stores.companionActivity.selectedMode == .apnea {
                                stores.applyApneaEnvironment(to: IOSApneaRootView())
                            } else if stores.companionActivity.selectedMode == .snorkeling {
                                stores.applySnorkelingEnvironment(to: IOSSnorkelingRootView())
                            } else {
                                stores.applyDivingEnvironment(to: ContentView().id(stores.sharedSettings.language.rawValue))
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            )
            .environmentObject(locationPermissionService)
            .environment(\.locale, stores.sharedSettings.locale)
            .preferredColorScheme(.dark)
            .task {
                stores.activateWatchSyncIfNeeded()
            }
        }
    }
}
