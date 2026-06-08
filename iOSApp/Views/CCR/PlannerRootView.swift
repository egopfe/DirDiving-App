import SwiftUI

struct PlannerRootView: View {
    @EnvironmentObject private var store: PlannerStore

    var body: some View {
        Group {
            if store.plannerShowsModeSelection {
                PlannerModeSelectionView()
            } else if store.mode.isCCR {
                CCRPlannerView()
            } else {
                PlannerView()
            }
        }
    }
}
