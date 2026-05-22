import SwiftUI

@main
struct DIRDivingiOSApp: App {
    @StateObject private var cloudSync: CloudSyncStore
    @StateObject private var logStore: DiveLogStore
    @StateObject private var watchSync = WatchSyncService()
    @StateObject private var plannerStore: PlannerStore
    @StateObject private var buddyExperimentalStore: BuddyExperimentalStore
    @StateObject private var explorationPlanningStore: ExplorationPlanningStore
    @StateObject private var legalAcceptance = LegalAcceptanceStore()
    @AppStorage(DIRIOSAppLanguage.storageKey) private var appLanguage = DIRIOSAppLanguage.system.rawValue

    init() {
        let cloudSync = CloudSyncStore()
        _cloudSync = StateObject(wrappedValue: cloudSync)
        _logStore = StateObject(wrappedValue: DiveLogStore(cloudSync: cloudSync))
        _plannerStore = StateObject(wrappedValue: PlannerStore(cloudSync: cloudSync))
        _buddyExperimentalStore = StateObject(wrappedValue: BuddyExperimentalStore(cloudSync: cloudSync))
        _explorationPlanningStore = StateObject(wrappedValue: ExplorationPlanningStore(cloudSync: cloudSync))
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if legalAcceptance.requiresAcceptance {
                    IOSLegalOnboardingView(
                        languageCode: DIRIOSAppLanguage.fromStorage(appLanguage).resolvedLanguageCode
                    )
                } else {
                    ContentView()
                }
            }
                .environmentObject(logStore)
                .environmentObject(watchSync)
                .environmentObject(plannerStore)
                .environmentObject(buddyExperimentalStore)
                .environmentObject(explorationPlanningStore)
                .environmentObject(cloudSync)
                .environmentObject(legalAcceptance)
                .environment(\.locale, DIRIOSAppLanguage.fromStorage(appLanguage).locale)
                .preferredColorScheme(.dark)
                .onAppear { watchSync.activate(logStore: logStore) }
        }
    }
}
