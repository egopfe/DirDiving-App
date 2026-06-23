import SwiftUI

/// Injects activity-scoped settings and navigation destination stores only for the selected mode.
struct IOSCompanionSettingsEnvironmentHost<Content: View>: View {
    @EnvironmentObject private var companionSettingsScope: IOSCompanionSettingsScopeStore
    @EnvironmentObject private var coordinator: IOSCompanionStoreCoordinator
    @ViewBuilder private let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        switch companionSettingsScope.displayedMode {
        case .diving:
            content()
                .id(DIRActivityMode.diving)
        case .apnea:
            let bundle = coordinator.ensureApneaStores()
            content()
                .environmentObject(bundle.settingsStore)
                .environmentObject(bundle.equipmentStore)
                .environmentObject(bundle.buddySafetyStore)
                .id(DIRActivityMode.apnea)
        case .snorkeling:
            let bundle = coordinator.ensureSnorkelingStores()
            content()
                .environmentObject(bundle.settingsStore)
                .environmentObject(bundle.equipmentStore)
                .environmentObject(bundle.buddySafetyStore)
                .id(DIRActivityMode.snorkeling)
        }
    }
}
