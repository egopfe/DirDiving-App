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
    @Published var buhlmann = BuhlmannPlanner.plan(depthMeters: 40, o2Fraction: 0.18)
    var analysis: TechnicalGasAnalysis { GasPlanningService.analyze(input: input) }
    var briefingText: String { plan.briefingLines.joined(separator: "\n") }

    private let cloudSync: CloudSyncStore?
    private let key = "dirdiving_ios_experimental_planner_state"
    private var isReady = false

    init(cloudSync: CloudSyncStore? = nil) {
        self.cloudSync = cloudSync
        if let saved = cloudSync?.load(PlannerState.self, forKey: key) {
            mode = saved.mode
            input = saved.input
        }
        input.ensurePlannerCylindersFromLegacy()
        calculate()
        isReady = true
        saveIfReady()
    }

    func calculate() {
        input.syncLegacyGasesFromPlannerCylinders()
        plan = PlannerService.makePlan(input: input)
        buhlmann = BuhlmannPlanner.plan(depthMeters: input.plannedDepthMeters, o2Fraction: input.bottomGas.oxygen)
        saveIfReady()
    }

    func updateTeamMember(_ member: TeamMember) {
        guard let index = input.teamMembers.firstIndex(where: { $0.id == member.id }) else { return }
        input.teamMembers[index] = member
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
