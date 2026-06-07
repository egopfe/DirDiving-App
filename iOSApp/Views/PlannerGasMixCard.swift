import SwiftUI

/// Legacy alias retained only for unit-test and preview compilation targets.
/// Active planner UI uses `PlannerCylinderGasEditorView`; this view intentionally renders `EmptyView()`.
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
