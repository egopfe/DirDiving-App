import SwiftUI

@main
struct DIRDivingApp: App {
    @StateObject private var logStore: DiveLogStore
    @StateObject private var apneaLogbookStore: ApneaLogbookStore
    @StateObject private var gpsManager: GPSManager
    @StateObject private var compassManager: CompassManager
    @StateObject private var diveManager: DiveManager
    @StateObject private var imageStore: UserImageStore
    @StateObject private var ascentSettings: AscentRateSettingsStore
    @StateObject private var diveReminderSettings: DiveReminderSettingsStore
    @StateObject private var navigationStore: AppNavigationStore
    @StateObject private var activitySelectionStore: DIRActivitySelectionStore
    @StateObject private var apneaRuntimeStore: ApneaWatchRuntimeStore
    @StateObject private var snorkelingRuntimeStore: SnorkelingWatchRuntimeStore
    @StateObject private var snorkelingLogbookStore: SnorkelingLogbookStore
    @StateObject private var watchSync: WatchSyncService
    @StateObject private var plannerBriefingStore: PlannerBriefingCardStore
    @StateObject private var underwaterActionRouter: WatchUnderwaterActionRouter
    @StateObject private var legalAcceptance = LegalAcceptanceStore()
    @AppStorage(DIRAppLanguage.storageKey) private var appLanguage = DIRAppLanguage.system.rawValue

    init() {
        let logStore = DiveLogStore()
        let apneaLogbookStore = ApneaLogbookStore()
        let gpsManager = GPSManager()
        let ascentSettings = AscentRateSettingsStore()
        let diveReminderSettings = DiveReminderSettingsStore()
        let navigationStore = AppNavigationStore()
        let activitySelectionStore = DIRActivitySelectionStore()
        let apneaRuntimeStore = ApneaWatchRuntimeStore()
        let snorkelingRuntimeStore = SnorkelingWatchRuntimeStore()
        let snorkelingLogbookStore = SnorkelingLogbookStore()
        let plannerBriefingStore = PlannerBriefingCardStore()
        let compassManager = CompassManager()
        let imageStore = UserImageStore()
        let diveManager = DiveManager(logStore: logStore, gpsManager: gpsManager, ascentSettings: ascentSettings)
        _logStore = StateObject(wrappedValue: logStore)
        _apneaLogbookStore = StateObject(wrappedValue: apneaLogbookStore)
        _gpsManager = StateObject(wrappedValue: gpsManager)
        _compassManager = StateObject(wrappedValue: compassManager)
        _diveManager = StateObject(wrappedValue: diveManager)
        _imageStore = StateObject(wrappedValue: imageStore)
        _ascentSettings = StateObject(wrappedValue: ascentSettings)
        _diveReminderSettings = StateObject(wrappedValue: diveReminderSettings)
        _navigationStore = StateObject(wrappedValue: navigationStore)
        _activitySelectionStore = StateObject(wrappedValue: activitySelectionStore)
        _apneaRuntimeStore = StateObject(wrappedValue: apneaRuntimeStore)
        _snorkelingRuntimeStore = StateObject(wrappedValue: snorkelingRuntimeStore)
        _snorkelingLogbookStore = StateObject(wrappedValue: snorkelingLogbookStore)
        _watchSync = StateObject(wrappedValue: WatchSyncService.shared)
        _plannerBriefingStore = StateObject(wrappedValue: plannerBriefingStore)
        _underwaterActionRouter = StateObject(
            wrappedValue: WatchUnderwaterActionRouter(
                navigation: navigationStore,
                dive: diveManager,
                compass: compassManager,
                activitySelection: activitySelectionStore,
                apneaRuntime: apneaRuntimeStore,
                imageStore: imageStore
            )
        )
        WatchSyncService.shared.attachLogStore(logStore)
        WatchSyncService.shared.attachPlannerBriefingStore(plannerBriefingStore)
        WatchSyncService.shared.attachApneaLogbookStore(apneaLogbookStore)
        SensorSourceMode.applyReleaseSafeMigrationIfNeeded()
        FullComputerPrediveConfigurationStore.migrateIfNeeded()
        WatchWaterAutoOpenPolicy.migrateIfNeeded()
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
            .environmentObject(apneaLogbookStore)
            .environmentObject(gpsManager)
            .environmentObject(compassManager)
            .environmentObject(diveManager)
            .environmentObject(imageStore)
            .environmentObject(ascentSettings)
            .environmentObject(diveReminderSettings)
            .environmentObject(navigationStore)
            .environmentObject(activitySelectionStore)
            .environmentObject(apneaRuntimeStore)
            .environmentObject(snorkelingRuntimeStore)
            .environmentObject(snorkelingLogbookStore)
            .environmentObject(watchSync)
            .environmentObject(plannerBriefingStore)
            .environmentObject(underwaterActionRouter)
            .environmentObject(legalAcceptance)
            .environment(\.locale, DIRAppLanguage.fromStorage(appLanguage).locale)
        }
    }
}
