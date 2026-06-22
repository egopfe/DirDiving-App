import SwiftUI

struct MoreView: View {
    @EnvironmentObject private var companionSettingsScope: IOSCompanionSettingsScopeStore
    @EnvironmentObject private var coordinator: IOSCompanionStoreCoordinator

    var body: some View {
        NavigationStack {
            DIRScreenContainer {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 7) {
                            Text(DIRIOSLocalizer.string("settings.title"))
                                .dirScreenTitleStyle()
                            Text(DIRIOSLocalizer.string("more.header.subtitle"))
                                .font(.callout)
                                .foregroundStyle(DIRTheme.muted)
                        }

                        IOSCompanionSettingsModeSwitcher(
                            selection: Binding(
                                get: { companionSettingsScope.displayedMode },
                                set: { companionSettingsScope.setDisplayedMode($0) }
                            )
                        )

                        settingsBody

                        IOSCompanionSharedCompanionSections()

                        if companionSettingsScope.displayedMode == .diving {
                            DIRWarningBox(text: DIRIOSLocalizer.string("more.safety.footer"))
                        }
                    }
                    .padding(16)
                }
                .dirCompanionScrollSurface()
            }
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                companionSettingsScope.applyInitialScope(.diving)
            }
            .onChange(of: companionSettingsScope.displayedMode) { _, mode in
                ensureStores(for: mode)
            }
        }
        .dirCompanionTabRoot()
    }

    @ViewBuilder
    private var settingsBody: some View {
        switch companionSettingsScope.displayedMode {
        case .diving:
            IOSDivingSettingsEmbeddedContent()
        case .apnea:
            IOSApneaSettingsForm()
        case .snorkeling:
            IOSSnorkelingSettingsForm()
        }
    }

    private func ensureStores(for mode: DIRActivityMode) {
        switch mode {
        case .diving:
            break
        case .apnea:
            _ = coordinator.ensureApneaStores()
        case .snorkeling:
            _ = coordinator.ensureSnorkelingStores()
        }
    }
}
