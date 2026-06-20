import SwiftUI

/// Activity-scoped store bundles — Apnea and Snorkeling are created on first use only.
@MainActor
final class IOSCompanionStoreCoordinator: ObservableObject {
    let cloudSync: CloudSyncStore
    let watchSync: WatchSyncService
    let sharedSettings: SharedIOSSettingsStore
    let legalAcceptance: LegalAcceptanceStore
    let companionActivity: CompanionActivityPreferenceStore

    // Diving stores — default Companion landing activity.
    let logStore: DiveLogStore
    let plannerStore: PlannerStore
    let equipmentStore: EquipmentStore
    let navigationStore: IOSNavigationStore
    let plannerAscentSpeedSettingsStore: PlannerAscentSpeedSettingsStore
    let plannerBriefingTransfer: PlannerBriefingWatchTransferService
    let divePlanPackageTransfer: DivePlanPackageWatchTransferService

    private var apneaBundle: IOSApneaStoreBundle?
    private var snorkelingBundle: IOSSnorkelingStoreBundle?
    private var syncApneaLogbook: IOSApneaLogbookStore?
    private var syncSnorkelingLogbook: IOSSnorkelingLogbookStore?

    var isApneaStoreActive: Bool { apneaBundle != nil }
    var isSnorkelingStoreActive: Bool { snorkelingBundle != nil }

    init() {
        let cloudSync = CloudSyncStore()
        self.cloudSync = cloudSync
        watchSync = WatchSyncService()
        sharedSettings = SharedIOSSettingsStore()
        legalAcceptance = LegalAcceptanceStore()
        companionActivity = CompanionActivityPreferenceStore()
        logStore = DiveLogStore(cloudSync: cloudSync)
        plannerStore = PlannerStore(cloudSync: cloudSync)
        equipmentStore = EquipmentStore(cloudSync: cloudSync)
        navigationStore = IOSNavigationStore()
        plannerAscentSpeedSettingsStore = PlannerAscentSpeedSettingsStore()
        plannerBriefingTransfer = PlannerBriefingWatchTransferService()
        divePlanPackageTransfer = DivePlanPackageWatchTransferService()
    }

    func ensureApneaStores() -> IOSApneaStoreBundle {
        if let apneaBundle { return apneaBundle }
        let bundle = IOSApneaStoreBundle(logbookStore: syncApneaLogbook)
        apneaBundle = bundle
        syncApneaLogbook = nil
        watchSync.attachApneaLogbookStore(bundle.logbookStore)
        watchSync.apneaWatchTransferService = bundle.watchTransfer
        return bundle
    }

    func ensureSnorkelingStores() -> IOSSnorkelingStoreBundle {
        if let snorkelingBundle { return snorkelingBundle }
        let bundle = IOSSnorkelingStoreBundle(logbookStore: syncSnorkelingLogbook)
        snorkelingBundle = bundle
        syncSnorkelingLogbook = nil
        watchSync.attachSnorkelingLogbookStore(bundle.logbookStore)
        watchSync.snorkelingWatchTransferService = bundle.watchTransfer
        watchSync.snorkelingSessionSyncService = bundle.sessionSync
        return bundle
    }

    func activateWatchSyncIfNeeded() {
        logStore.attachWatchSync(watchSync)
        watchSync.activate(
            logStore: logStore,
            apneaLogbookStore: lazyApneaLogbookForSync(),
            snorkelingLogbookStore: lazySnorkelingLogbookForSync()
        )
        watchSync.plannerBriefingTransferService = plannerBriefingTransfer
        watchSync.divePlanPackageTransferService = divePlanPackageTransfer
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
    func applySharedEnvironment<Content: View>(to content: Content) -> some View {
        content
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
            .environmentObject(sharedSettings)
    }

    @ViewBuilder
    func applyApneaEnvironment<Content: View>(to content: Content) -> some View {
        let bundle = ensureApneaStores()
        applySharedEnvironment(to: content)
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
        applySharedEnvironment(to: content)
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
    let settingsStore = IOSApneaSettingsStore()
    let watchTransfer = IOSApneaWatchTransferService()
    let equipmentStore = IOSApneaEquipmentStore()
    let buddySafetyStore = IOSApneaBuddySafetyStore()

    init(logbookStore existing: IOSApneaLogbookStore? = nil) {
        logbookStore = existing ?? IOSApneaLogbookStore()
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
    let settingsStore = IOSSnorkelingSettingsStore()

    init(logbookStore existing: IOSSnorkelingLogbookStore? = nil) {
        logbookStore = existing ?? IOSSnorkelingLogbookStore()
    }
}
