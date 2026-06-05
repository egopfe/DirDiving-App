import SwiftUI

@main
struct DIRDivingiOSApp: App {
    @StateObject private var cloudSync: CloudSyncStore
    @StateObject private var logStore: DiveLogStore
    @StateObject private var watchSync = WatchSyncService()
    @StateObject private var plannerStore: PlannerStore
    @StateObject private var equipmentStore: EquipmentStore
    @StateObject private var explorationStore: ExplorationPlanningStore
    @StateObject private var buddyExperimentalStore: BuddyExperimentalStore
    @StateObject private var navigationStore = IOSNavigationStore()
    @StateObject private var legalAcceptance = LegalAcceptanceStore()
    @AppStorage(DIRIOSAppLanguage.storageKey) private var appLanguage = DIRIOSAppLanguage.system.rawValue

    init() {
        let cloudSync = CloudSyncStore()
        _cloudSync = StateObject(wrappedValue: cloudSync)
        _logStore = StateObject(wrappedValue: DiveLogStore(cloudSync: cloudSync))
        _plannerStore = StateObject(wrappedValue: PlannerStore(cloudSync: cloudSync))
        _equipmentStore = StateObject(wrappedValue: EquipmentStore(cloudSync: cloudSync))
        _explorationStore = StateObject(wrappedValue: ExplorationPlanningStore(cloudSync: cloudSync))
        _buddyExperimentalStore = StateObject(wrappedValue: BuddyExperimentalStore(cloudSync: cloudSync))
        SensorSourceMode.applyReleaseSafeMigrationIfNeeded()
        IOSWindowChromeConfigurator.applyUIKitAppearance()
    }

    var body: some Scene {
        WindowGroup {
            IOSRootShell {
                Group {
                    if legalAcceptance.requiresAcceptance {
                        IOSLegalOnboardingView(
                            languageCode: DIRIOSAppLanguage.fromStorage(appLanguage).resolvedLanguageCode
                        )
                    } else {
                        ContentView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .environmentObject(logStore)
            .environmentObject(watchSync)
            .environmentObject(plannerStore)
            .environmentObject(equipmentStore)
            .environmentObject(explorationStore)
            .environmentObject(buddyExperimentalStore)
            .environmentObject(cloudSync)
            .environmentObject(navigationStore)
            .environmentObject(legalAcceptance)
            .environment(\.locale, DIRIOSAppLanguage.fromStorage(appLanguage).locale)
            .preferredColorScheme(.dark)
            .task {
                logStore.attachWatchSync(watchSync)
                watchSync.activate(logStore: logStore)
            }
        }
    }
}
