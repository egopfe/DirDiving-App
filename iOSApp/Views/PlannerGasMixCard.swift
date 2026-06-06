import SwiftUI

/// Legacy alias retained for tests; planner uses `PlannerCylinderGasEditorView`.
struct GasMixCard: View {
    @Binding var mix: GasMix
    let accent: Color
    var unitPreference: IOSUnitPreference = .metric
    var plannerEnvironment: PlannerEnvironment = .seaLevelSaltWater
    var allowedMixKinds: [GasMixKind] = GasMixKind.allCases
    var onMixChanged: (() -> Void)? = nil

    var body: some View {
        EmptyView()
    }
}
