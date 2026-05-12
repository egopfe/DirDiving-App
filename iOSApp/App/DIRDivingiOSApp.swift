import SwiftUI

@main
struct DIRDivingiOSApp: App {
    @StateObject private var cloudSync: CloudSyncStore
    @StateObject private var logStore: DiveLogStore
    @StateObject private var watchSync = WatchSyncService()
    @StateObject private var plannerStore: PlannerStore
    @StateObject private var buddyExperimentalStore: BuddyExperimentalStore
    @StateObject private var explorationPlanningStore: ExplorationPlanningStore

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
            ContentView()
                .environmentObject(logStore)
                .environmentObject(watchSync)
                .environmentObject(plannerStore)
                .environmentObject(buddyExperimentalStore)
                .environmentObject(explorationPlanningStore)
                .environmentObject(cloudSync)
                .preferredColorScheme(.dark)
                .onAppear { watchSync.activate(logStore: logStore) }
        }
    }
}
