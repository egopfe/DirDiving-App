import SwiftUI

/// Unified iOS Companion Settings root with activity-scoped mode switcher.
struct IOSCompanionSettingsRootView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var companionSettingsScope: IOSCompanionSettingsScopeStore
    @EnvironmentObject private var coordinator: IOSCompanionStoreCoordinator

    let initialMode: DIRActivityMode

    var body: some View {
        DIRScreenContainer {
            VStack(spacing: 0) {
                IOSCompanionSettingsModeSwitcher(
                    selection: Binding(
                        get: { companionSettingsScope.displayedMode },
                        set: { companionSettingsScope.setDisplayedMode($0) }
                    )
                )
                .padding(.horizontal, 16)
                .padding(.top, 8)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        settingsContent
                        IOSCompanionSharedCompanionSections()
                    }
                    .padding(16)
                }
                .dirCompanionScrollSurface()
            }
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(DIRIOSLocalizer.string("common.close")) {
                    dismiss()
                }
            }
        }
        .onAppear {
            companionSettingsScope.applyInitialScope(initialMode)
            ensureStoresForDisplayedMode()
        }
        .onChange(of: companionSettingsScope.displayedMode) { _, _ in
            ensureStoresForDisplayedMode()
        }
    }

    private var navigationTitle: String {
        switch companionSettingsScope.displayedMode {
        case .diving:
            return DIRIOSLocalizer.string("settings.title")
        case .apnea:
            return DIRIOSLocalizer.string("apnea.settings.title")
        case .snorkeling:
            return DIRIOSLocalizer.string("snorkeling.settings.title")
        }
    }

    @ViewBuilder
    private var settingsContent: some View {
        switch companionSettingsScope.displayedMode {
        case .diving:
            IOSDivingSettingsEmbeddedContent()
        case .apnea:
            IOSApneaSettingsContent()
        case .snorkeling:
            IOSSnorkelingSettingsContent()
        }
    }

    private func ensureStoresForDisplayedMode() {
        switch companionSettingsScope.displayedMode {
        case .diving:
            break
        case .apnea:
            _ = coordinator.ensureApneaStores()
        case .snorkeling:
            _ = coordinator.ensureSnorkelingStores()
        }
    }
}
