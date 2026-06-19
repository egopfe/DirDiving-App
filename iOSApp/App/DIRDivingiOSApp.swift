import SwiftUI

@main
struct DIRDivingiOSApp: App {
    @StateObject private var cloudSync: CloudSyncStore
    @StateObject private var logStore: DiveLogStore
    @StateObject private var watchSync = WatchSyncService()
    @StateObject private var plannerStore: PlannerStore
    @StateObject private var equipmentStore: EquipmentStore
    @StateObject private var navigationStore = IOSNavigationStore()
    @StateObject private var legalAcceptance = LegalAcceptanceStore()
    @StateObject private var plannerAscentSpeedSettingsStore = PlannerAscentSpeedSettingsStore()
    @StateObject private var plannerBriefingTransfer = PlannerBriefingWatchTransferService()
    @StateObject private var divePlanPackageTransfer = DivePlanPackageWatchTransferService()
    @StateObject private var companionActivity = CompanionActivityPreferenceStore()
    @StateObject private var apneaNavigation = IOSApneaNavigationStore()
    @StateObject private var apneaProfileStore = IOSApneaProfileStore()
    @StateObject private var apneaPlannerStore = IOSApneaPlannerStore()
    @StateObject private var apneaLogbookStore = IOSApneaLogbookStore()
    @StateObject private var apneaSettingsStore = IOSApneaSettingsStore()
    @StateObject private var apneaWatchTransfer = IOSApneaWatchTransferService()
    @StateObject private var apneaEquipmentStore = IOSApneaEquipmentStore()
    @StateObject private var apneaBuddySafetyStore = IOSApneaBuddySafetyStore()
    @StateObject private var snorkelingNavigation = IOSSnorkelingNavigationStore()
    @StateObject private var snorkelingProfileStore = IOSSnorkelingProfileStore()
    @StateObject private var snorkelingRoutePlannerStore = IOSSnorkelingRoutePlannerStore()
    @StateObject private var snorkelingLogbookStore = IOSSnorkelingLogbookStore()
    @StateObject private var snorkelingWatchTransfer = IOSSnorkelingWatchTransferService()
    @StateObject private var snorkelingSessionSync = IOSSnorkelingSessionSyncService()
    @StateObject private var snorkelingEquipmentStore = IOSSnorkelingEquipmentStore()
    @StateObject private var snorkelingBuddySafetyStore = IOSSnorkelingBuddySafetyStore()
    @StateObject private var snorkelingSessionPhotoStore = IOSSnorkelingSessionPhotoStore()
    @AppStorage(DIRIOSAppLanguage.storageKey) private var appLanguage = DIRIOSAppLanguage.system.rawValue

    init() {
        let cloudSync = CloudSyncStore()
        _cloudSync = StateObject(wrappedValue: cloudSync)
        _logStore = StateObject(wrappedValue: DiveLogStore(cloudSync: cloudSync))
        _plannerStore = StateObject(wrappedValue: PlannerStore(cloudSync: cloudSync))
        _equipmentStore = StateObject(wrappedValue: EquipmentStore(cloudSync: cloudSync))
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
                    } else if companionActivity.shouldPresentSelectionScreen {
                        IOSCompanionActivitySelectionView()
                    } else if companionActivity.selectedMode == .apnea {
                        IOSApneaRootView()
                    } else if companionActivity.selectedMode == .snorkeling {
                        IOSSnorkelingRootView()
                    } else {
                        ContentView()
                            .id(appLanguage)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .environmentObject(logStore)
            .environmentObject(watchSync)
            .environmentObject(plannerStore)
            .environmentObject(equipmentStore)
            .environmentObject(cloudSync)
            .environmentObject(navigationStore)
            .environmentObject(legalAcceptance)
            .environmentObject(plannerAscentSpeedSettingsStore)
            .environmentObject(plannerBriefingTransfer)
            .environmentObject(divePlanPackageTransfer)
            .environmentObject(companionActivity)
            .environmentObject(apneaNavigation)
            .environmentObject(apneaProfileStore)
            .environmentObject(apneaPlannerStore)
            .environmentObject(apneaLogbookStore)
            .environmentObject(apneaSettingsStore)
            .environmentObject(apneaWatchTransfer)
            .environmentObject(apneaEquipmentStore)
            .environmentObject(apneaBuddySafetyStore)
            .environmentObject(snorkelingNavigation)
            .environmentObject(snorkelingProfileStore)
            .environmentObject(snorkelingRoutePlannerStore)
            .environmentObject(snorkelingLogbookStore)
            .environmentObject(snorkelingWatchTransfer)
            .environmentObject(snorkelingSessionSync)
            .environmentObject(snorkelingEquipmentStore)
            .environmentObject(snorkelingBuddySafetyStore)
            .environmentObject(snorkelingSessionPhotoStore)
            .environment(\.locale, DIRIOSAppLanguage.fromStorage(appLanguage).locale)
            .preferredColorScheme(.dark)
            .task {
                logStore.attachWatchSync(watchSync)
                watchSync.activate(
                    logStore: logStore,
                    apneaLogbookStore: apneaLogbookStore,
                    snorkelingLogbookStore: snorkelingLogbookStore
                )
                watchSync.plannerBriefingTransferService = plannerBriefingTransfer
                watchSync.divePlanPackageTransferService = divePlanPackageTransfer
                watchSync.apneaWatchTransferService = apneaWatchTransfer
                watchSync.snorkelingWatchTransferService = snorkelingWatchTransfer
                watchSync.snorkelingSessionSyncService = snorkelingSessionSync
            }
        }
    }
}
