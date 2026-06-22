import SwiftUI

/// Injects activity-scoped settings environment objects only for the selected mode.
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
        case .apnea:
            let settings = coordinator.ensureApneaSettingsStore()
            content()
                .environmentObject(settings)
        case .snorkeling:
            let settings = coordinator.ensureSnorkelingSettingsStore()
            content()
                .environmentObject(settings)
        }
    }
}
