import Combine
import SwiftUI

/// Activity-scoped store bundles — Apnea and Snorkeling are created on first use only.
@MainActor
final class IOSCompanionStoreCoordinator: ObservableObject {
    let cloudSync: CloudSyncStore
    let watchSync: WatchSyncService
    let sharedSettings: SharedIOSSettingsStore
    let legalAcceptance: LegalAcceptanceStore
    let companionActivity: CompanionActivityPreferenceStore
    let companionSettingsScope: IOSCompanionSettingsScopeStore

    // Diving stores — default Companion landing activity.
    let logStore: DiveLogStore
    let plannerStore: PlannerStore
    let equipmentStore: EquipmentStore
    let navigationStore: IOSNavigationStore
    let plannerAscentSpeedSettingsStore: PlannerAscentSpeedSettingsStore
    let divingSettingsStore: IOSDivingSettingsStore
    let plannerBriefingTransfer: PlannerBriefingWatchTransferService
    let divePlanPackageTransfer: DivePlanPackageWatchTransferService
    let demoLogbookSettings: IOSActivityDemoLogbookSettingsStore
    let logbookVisibilitySettings: IOSActivityLogbookVisibilitySettingsStore

    private var apneaBundle: IOSApneaStoreBundle?
    private var snorkelingBundle: IOSSnorkelingStoreBundle?
    private var syncApneaLogbook: IOSApneaLogbookStore?
    private var syncSnorkelingLogbook: IOSSnorkelingLogbookStore?
    private var lazyApneaSettingsStore: IOSApneaSettingsStore?
    private var lazySnorkelingSettingsStore: IOSSnorkelingSettingsStore?
    private var nestedStoreCancellables = Set<AnyCancellable>()

    var isApneaStoreActive: Bool { apneaBundle != nil }
    var isSnorkelingStoreActive: Bool { snorkelingBundle != nil }

    init() {
        let cloudSync = CloudSyncStore()
        self.cloudSync = cloudSync
        watchSync = WatchSyncService()
        sharedSettings = SharedIOSSettingsStore()
        legalAcceptance = LegalAcceptanceStore()
        companionActivity = CompanionActivityPreferenceStore()
        companionSettingsScope = IOSCompanionSettingsScopeStore()
        logStore = DiveLogStore(cloudSync: cloudSync)
        plannerStore = PlannerStore(cloudSync: cloudSync)
        equipmentStore = EquipmentStore(cloudSync: cloudSync)
        navigationStore = IOSNavigationStore()
        plannerAscentSpeedSettingsStore = PlannerAscentSpeedSettingsStore()
        divingSettingsStore = IOSDivingSettingsStore(
            sharedSettings: sharedSettings,
            plannerAscentSpeedSettings: plannerAscentSpeedSettingsStore
        )
        plannerBriefingTransfer = PlannerBriefingWatchTransferService()
        divePlanPackageTransfer = DivePlanPackageWatchTransferService()
        demoLogbookSettings = IOSActivityDemoLogbookSettingsStore()
        logbookVisibilitySettings = IOSActivityLogbookVisibilitySettingsStore()

        forwardNestedStoreChanges(from: legalAcceptance)
        forwardNestedStoreChanges(from: companionActivity)
        forwardNestedStoreChanges(from: sharedSettings)
        forwardNestedStoreChanges(from: demoLogbookSettings)
        forwardNestedStoreChanges(from: logbookVisibilitySettings)
    }

    /// Ensures logbook stores needed for read-only aggregated presentation are loaded.
    /// Does not change selected activity mode or activate Watch runtime beyond existing sync wiring.
    func ensureStoresForUnifiedLogbook() {
        _ = logStore
        _ = apneaLogbookStoreForPresentation()
        _ = snorkelingLogbookStoreForPresentation()
    }

    func apneaLogbookStoreForPresentation() -> IOSApneaLogbookStore {
        if let bundle = apneaBundle { return bundle.logbookStore }
        return lazyApneaLogbookForSync()
    }

    func snorkelingLogbookStoreForPresentation() -> IOSSnorkelingLogbookStore {
        if let bundle = snorkelingBundle { return bundle.logbookStore }
        return lazySnorkelingLogbookForSync()
    }

    func ensureApneaSettingsStore() -> IOSApneaSettingsStore {
        if let bundle = apneaBundle { return bundle.settingsStore }
        if lazyApneaSettingsStore == nil { lazyApneaSettingsStore = IOSApneaSettingsStore() }
        return lazyApneaSettingsStore!
    }

    func ensureSnorkelingSettingsStore() -> IOSSnorkelingSettingsStore {
        if let bundle = snorkelingBundle { return bundle.settingsStore }
        if lazySnorkelingSettingsStore == nil { lazySnorkelingSettingsStore = IOSSnorkelingSettingsStore() }
        return lazySnorkelingSettingsStore!
    }

    private func forwardNestedStoreChanges(from store: some ObservableObject) {
        store.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &nestedStoreCancellables)
    }

    func ensureApneaStores() -> IOSApneaStoreBundle {
        if let apneaBundle { return apneaBundle }
        let bundle = IOSApneaStoreBundle(
            logbookStore: syncApneaLogbook,
            settingsStore: lazyApneaSettingsStore
        )
        apneaBundle = bundle
        syncApneaLogbook = nil
        lazyApneaSettingsStore = nil
        watchSync.attachApneaLogbookStore(bundle.logbookStore)
        watchSync.apneaWatchTransferService = bundle.watchTransfer
        return bundle
    }

    func ensureSnorkelingStores() -> IOSSnorkelingStoreBundle {
        if let snorkelingBundle { return snorkelingBundle }
        let bundle = IOSSnorkelingStoreBundle(
            logbookStore: syncSnorkelingLogbook,
            settingsStore: lazySnorkelingSettingsStore
        )
        snorkelingBundle = bundle
        syncSnorkelingLogbook = nil
        lazySnorkelingSettingsStore = nil
        watchSync.attachSnorkelingLogbookStore(bundle.logbookStore)
        bundle.logbookStore.attachWatchSync(watchSync)
        watchSync.snorkelingWatchTransferService = bundle.watchTransfer
        watchSync.snorkelingSessionSyncService = bundle.sessionSync
        return bundle
    }

    func activateWatchSyncIfNeeded() {
        logStore.attachWatchSync(watchSync)
        watchSync.apneaLogbookProvider = { [weak self] in self?.lazyApneaLogbookForSync() }
        watchSync.snorkelingLogbookProvider = { [weak self] in self?.lazySnorkelingLogbookForSync() }
        watchSync.activate(logStore: logStore)
        watchSync.plannerBriefingTransferService = plannerBriefingTransfer
        watchSync.divePlanPackageTransferService = divePlanPackageTransfer
    }

    func attachActivityLogbookForSyncIfNeeded(activity: DIRActivityMode) {
        switch activity {
        case .diving:
            break
        case .apnea:
            _ = lazyApneaLogbookForSync()
        case .snorkeling:
            _ = lazySnorkelingLogbookForSync()
        }
    }

    private func lazyApneaLogbookForSync() -> IOSApneaLogbookStore {
        if let bundle = apneaBundle { return bundle.logbookStore }
        if syncApneaLogbook == nil { syncApneaLogbook = IOSApneaLogbookStore() }
        return syncApneaLogbook!
    }

    private func lazySnorkelingLogbookForSync() -> IOSSnorkelingLogbookStore {
        if let bundle = snorkelingBundle { return bundle.logbookStore }
        if syncSnorkelingLogbook == nil { syncSnorkelingLogbook = IOSSnorkelingLogbookStore() }
        return syncSnorkelingLogbook!
    }

    @ViewBuilder
    func applyGlobalEnvironment<Content: View>(to content: Content) -> some View {
        content
            .environmentObject(self)
            .environmentObject(watchSync)
            .environmentObject(cloudSync)
            .environmentObject(legalAcceptance)
            .environmentObject(companionActivity)
            .environmentObject(companionSettingsScope)
            .environmentObject(sharedSettings)
            .environmentObject(demoLogbookSettings)
            .environmentObject(logbookVisibilitySettings)
    }

    @ViewBuilder
    func applyCompanionSettingsSheetEnvironment<Content: View>(to content: Content) -> some View {
        applyDivingEnvironment(to:
            IOSCompanionSettingsEnvironmentHost {
                content
            }
        )
    }

    @ViewBuilder
    func applyDivingEnvironment<Content: View>(to content: Content) -> some View {
        applyGlobalEnvironment(to: content)
            .environmentObject(logStore)
            .environmentObject(plannerStore)
            .environmentObject(equipmentStore)
            .environmentObject(navigationStore)
            .environmentObject(plannerAscentSpeedSettingsStore)
            .environmentObject(divingSettingsStore)
            .environmentObject(plannerBriefingTransfer)
            .environmentObject(divePlanPackageTransfer)
    }

    /// Backward-compatible alias for Diving root wiring.
    @ViewBuilder
    func applySharedEnvironment<Content: View>(to content: Content) -> some View {
        applyDivingEnvironment(to: content)
    }

    @ViewBuilder
    func applyApneaEnvironment<Content: View>(to content: Content) -> some View {
        let bundle = ensureApneaStores()
        applyGlobalEnvironment(to: content)
            .environmentObject(bundle.navigation)
            .environmentObject(bundle.profileStore)
            .environmentObject(bundle.plannerStore)
            .environmentObject(bundle.logbookStore)
            .environmentObject(bundle.settingsStore)
            .environmentObject(bundle.watchTransfer)
            .environmentObject(bundle.equipmentStore)
            .environmentObject(bundle.buddySafetyStore)
    }

    @ViewBuilder
    func applySnorkelingEnvironment<Content: View>(to content: Content) -> some View {
        let bundle = ensureSnorkelingStores()
        applyGlobalEnvironment(to: content)
            .environmentObject(bundle.navigation)
            .environmentObject(bundle.profileStore)
            .environmentObject(bundle.routePlannerStore)
            .environmentObject(bundle.logbookStore)
            .environmentObject(bundle.watchTransfer)
            .environmentObject(bundle.sessionSync)
            .environmentObject(bundle.equipmentStore)
            .environmentObject(bundle.buddySafetyStore)
            .environmentObject(bundle.sessionPhotoStore)
            .environmentObject(bundle.settingsStore)
    }
}

@MainActor
final class IOSApneaStoreBundle {
    let navigation = IOSApneaNavigationStore()
    let profileStore = IOSApneaProfileStore()
    let plannerStore = IOSApneaPlannerStore()
    let logbookStore: IOSApneaLogbookStore
    let settingsStore: IOSApneaSettingsStore
    let watchTransfer = IOSApneaWatchTransferService()
    let equipmentStore = IOSApneaEquipmentStore()
    let buddySafetyStore = IOSApneaBuddySafetyStore()

    init(logbookStore existing: IOSApneaLogbookStore? = nil, settingsStore existingSettings: IOSApneaSettingsStore? = nil) {
        logbookStore = existing ?? IOSApneaLogbookStore()
        settingsStore = existingSettings ?? IOSApneaSettingsStore()
    }
}

@MainActor
final class IOSSnorkelingStoreBundle {
    let navigation = IOSSnorkelingNavigationStore()
    let profileStore = IOSSnorkelingProfileStore()
    let routePlannerStore = IOSSnorkelingRoutePlannerStore()
    let logbookStore: IOSSnorkelingLogbookStore
    let watchTransfer = IOSSnorkelingWatchTransferService()
    let sessionSync = IOSSnorkelingSessionSyncService()
    let equipmentStore = IOSSnorkelingEquipmentStore()
    let buddySafetyStore = IOSSnorkelingBuddySafetyStore()
    let sessionPhotoStore = IOSSnorkelingSessionPhotoStore()
    let settingsStore: IOSSnorkelingSettingsStore

    init(logbookStore existing: IOSSnorkelingLogbookStore? = nil, settingsStore existingSettings: IOSSnorkelingSettingsStore? = nil) {
        logbookStore = existing ?? IOSSnorkelingLogbookStore()
        settingsStore = existingSettings ?? IOSSnorkelingSettingsStore()
    }
}
