import SwiftUI

@main
struct DIRDivingApp: App {
    @StateObject private var logStore: DiveLogStore
    @StateObject private var gpsManager: GPSManager
    @StateObject private var compassManager: CompassManager
    @StateObject private var diveManager: DiveManager
    @StateObject private var imageStore: UserImageStore
    @StateObject private var ascentSettings: AscentRateSettingsStore
    @StateObject private var diveReminderSettings: DiveReminderSettingsStore
    @StateObject private var navigationStore: AppNavigationStore
    @StateObject private var watchSync: WatchSyncService
    @StateObject private var explorationStore: ExplorationStore
    @StateObject private var buddyAssist: BuddyAssistService
    @StateObject private var legalAcceptance = LegalAcceptanceStore()
    @AppStorage(DIRAppLanguage.storageKey) private var appLanguage = DIRAppLanguage.system.rawValue

    init() {
        let logStore = DiveLogStore()
        let gpsManager = GPSManager()
        let ascentSettings = AscentRateSettingsStore()
        let diveReminderSettings = DiveReminderSettingsStore()
        let navigationStore = AppNavigationStore()
        _logStore = StateObject(wrappedValue: logStore)
        _gpsManager = StateObject(wrappedValue: gpsManager)
        _compassManager = StateObject(wrappedValue: CompassManager())
        _diveManager = StateObject(wrappedValue: DiveManager(logStore: logStore, gpsManager: gpsManager, ascentSettings: ascentSettings))
        _imageStore = StateObject(wrappedValue: UserImageStore())
        _ascentSettings = StateObject(wrappedValue: ascentSettings)
        _diveReminderSettings = StateObject(wrappedValue: diveReminderSettings)
        _navigationStore = StateObject(wrappedValue: navigationStore)
        _watchSync = StateObject(wrappedValue: WatchSyncService.shared)
        _explorationStore = StateObject(wrappedValue: ExplorationStore())
        _buddyAssist = StateObject(wrappedValue: BuddyAssistService())
        WatchSyncService.shared.attachLogStore(logStore)
        SensorSourceMode.applyReleaseSafeMigrationIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                Group {
                    if legalAcceptance.requiresAcceptance {
                        WatchLegalOnboardingView(
                            languageCode: DIRAppLanguage.fromStorage(appLanguage).resolvedLanguageCode
                        )
                    } else {
                        ContentView()
                    }
                }
                .navigationDestination(isPresented: $navigationStore.exportCompletionPresented) {
                    ExportView(
                        fileName: navigationStore.exportCompletionFileName,
                        exportURL: navigationStore.exportCompletionURL
                    )
                }
            }
            .environmentObject(logStore)
            .environmentObject(gpsManager)
            .environmentObject(compassManager)
            .environmentObject(diveManager)
            .environmentObject(imageStore)
            .environmentObject(ascentSettings)
            .environmentObject(diveReminderSettings)
            .environmentObject(navigationStore)
            .environmentObject(watchSync)
            .environmentObject(explorationStore)
            .environmentObject(buddyAssist)
            .environmentObject(legalAcceptance)
            .environment(\.locale, DIRAppLanguage.fromStorage(appLanguage).locale)
        }
    }
}
