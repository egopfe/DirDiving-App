import SwiftUI

@main
struct DIRDivingiOSApp: App {
    @StateObject private var cloudSync: CloudSyncStore
    @StateObject private var logStore: DiveLogStore
    @StateObject private var watchSync = WatchSyncService()
    @StateObject private var plannerStore: PlannerStore
    @StateObject private var equipmentStore: EquipmentStore

    init() {
        let cloudSync = CloudSyncStore()
        _cloudSync = StateObject(wrappedValue: cloudSync)
        _logStore = StateObject(wrappedValue: DiveLogStore(cloudSync: cloudSync))
        _plannerStore = StateObject(wrappedValue: PlannerStore(cloudSync: cloudSync))
        _equipmentStore = StateObject(wrappedValue: EquipmentStore(cloudSync: cloudSync))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(logStore)
                .environmentObject(watchSync)
                .environmentObject(plannerStore)
                .environmentObject(equipmentStore)
                .environmentObject(cloudSync)
                .preferredColorScheme(.dark)
                .onAppear { watchSync.activate(logStore: logStore) }
        }
    }
}
