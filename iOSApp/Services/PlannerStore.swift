import Foundation
import Combine

@MainActor
final class PlannerStore: ObservableObject {
    @Published var mode: PlannerMode = .advanced {
        didSet { saveIfReady() }
    }
    @Published var input = GasPlanInput() {
        didSet { saveIfReady() }
    }
    @Published var plan = PlannerService.makePlan(input: GasPlanInput())
    @Published var buhlmann = BuhlmannPlanner.plan(depthMeters: 40, gas: GasPlanInput().bottomGas)
    @Published var safetyAcknowledged = false

    private let cloudSync: CloudSyncStore?
    private let key = "dirdiving_ios_planner_state"
    private var isReady = false

    init(cloudSync: CloudSyncStore? = nil) {
        self.cloudSync = cloudSync
        if let saved = cloudSync?.load(PlannerState.self, forKey: key) {
            mode = saved.mode
            input = saved.input
        }
        calculate()
        isReady = true
        saveIfReady()
    }

    func calculate() {
        plan = PlannerService.makePlan(input: input)
        buhlmann = BuhlmannPlanner.plan(depthMeters: input.plannedDepthMeters, gas: input.bottomGas)
        saveIfReady()
    }

    private func saveIfReady() {
        guard isReady else { return }
        cloudSync?.save(PlannerState(mode: mode, input: input), forKey: key)
    }
}

private struct PlannerState: Codable {
    var mode: PlannerMode
    var input: GasPlanInput
}
