import SwiftUI

/// Cold-launch and settings-driven startup flow (activity → diving mode → optional FC confirm).
struct StartupFlowView: View {
    @EnvironmentObject private var activitySelection: DIRActivitySelectionStore
    @EnvironmentObject private var navigation: AppNavigationStore

    var body: some View {
        ZStack {
            DiveScreenBackground()

            Group {
                switch activitySelection.startupStep {
                case .activitySelection:
                    ActivitySelectionView()
                case .divingModeSelection:
                    DivingModeSelectionView()
                case .fullComputerPrediveConfiguration:
                    if FullComputerImportedPlanStore.shared.hasPendingActivation {
                        FullComputerImportedPlanView()
                    } else {
                        FullComputerPrediveSettingsView()
                    }
                case .fullComputerConfirmation:
                    FullComputerPrediveConfirmationView()
                case .comingSoon(let activity):
                    ActivityComingSoonView(activity: activity)
                case .ready, .none:
                    EmptyView()
                }
            }
        }
        .onChange(of: activitySelection.sessionConfigured) { _, configured in
            if configured {
                navigation.selectedPage = .live
            }
        }
    }
}
