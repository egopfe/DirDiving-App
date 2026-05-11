import Foundation
import Combine

@MainActor
final class PlannerStore: ObservableObject {
    @Published var mode: PlannerMode = .advanced
    @Published var input = GasPlanInput()
    @Published var plan = PlannerService.makePlan(input: GasPlanInput())
    @Published var buhlmann = BuhlmannPlanner.plan(depthMeters: 40, o2Fraction: 0.18)
    func calculate() {
        plan = PlannerService.makePlan(input: input)
        buhlmann = BuhlmannPlanner.plan(depthMeters: input.plannedDepthMeters, o2Fraction: input.bottomGas.oxygen)
    }
}
