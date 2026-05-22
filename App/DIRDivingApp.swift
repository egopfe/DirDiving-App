import SwiftUI

@main
struct DIRDivingApp: App {
    @StateObject private var logStore: DiveLogStore
    @StateObject private var gpsManager: GPSManager
    @StateObject private var compassManager: CompassManager
    @StateObject private var diveManager: DiveManager
    @StateObject private var imageStore: UserImageStore
    @StateObject private var ascentSettings: AscentRateSettingsStore
    @StateObject private var navigationStore: AppNavigationStore
    @StateObject private var watchSync: WatchSyncService
    @AppStorage(DIRAppLanguage.storageKey) private var appLanguage = DIRAppLanguage.system.rawValue

    init() {
        let logStore = DiveLogStore()
        let gpsManager = GPSManager()
        let ascentSettings = AscentRateSettingsStore()
        let navigationStore = AppNavigationStore()
        _logStore = StateObject(wrappedValue: logStore)
        _gpsManager = StateObject(wrappedValue: gpsManager)
        _compassManager = StateObject(wrappedValue: CompassManager())
        _diveManager = StateObject(wrappedValue: DiveManager(logStore: logStore, gpsManager: gpsManager, ascentSettings: ascentSettings))
        _imageStore = StateObject(wrappedValue: UserImageStore())
        _ascentSettings = StateObject(wrappedValue: ascentSettings)
        _navigationStore = StateObject(wrappedValue: navigationStore)
        _watchSync = StateObject(wrappedValue: WatchSyncService.shared)
        WatchSyncService.shared.attachLogStore(logStore)
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack { ContentView() }
                .environmentObject(logStore)
                .environmentObject(gpsManager)
                .environmentObject(compassManager)
                .environmentObject(diveManager)
                .environmentObject(imageStore)
                .environmentObject(ascentSettings)
                .environmentObject(navigationStore)
                .environmentObject(watchSync)
                .environment(\.locale, DIRAppLanguage.fromStorage(appLanguage).locale)
        }
    }
}
