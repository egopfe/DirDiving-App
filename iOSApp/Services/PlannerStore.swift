import Foundation
import Combine

@MainActor
final class PlannerStore: ObservableObject {
    @Published var mode: PlannerMode = .advanced {
        didSet { saveIfReady() }
    }
    @Published var input = GasPlanInput() {
        didSet {
            guard !isApplyingInputSideEffects else { return }
            saveIfReady()
            applyInputToPlanningOutputs()
        }
    }
    @Published var plan = PlannerService.makePlan(input: GasPlanInput())
    @Published var buhlmann = BuhlmannPlanner.plan(
        depthMeters: 40,
        bottomGas: GasMix(name: "Gas di Fondo", oxygen: 0.18, helium: 0.45, maxPPO2: 1.40)
    )
    var analysis: TechnicalGasAnalysis { GasPlanningService.analyze(input: input) }
    var briefingText: String { plan.briefingLines.joined(separator: "\n") }

    private let cloudSync: CloudSyncStore?
    private let key = "dirdiving_ios_experimental_planner_state"
    private var isReady = false
    private var isApplyingInputSideEffects = false

    init(cloudSync: CloudSyncStore? = nil) {
        self.cloudSync = cloudSync
        if let saved = cloudSync?.load(PlannerState.self, forKey: key) {
            mode = saved.mode
            input = saved.input
        }
        input.ensurePlannerCylindersFromLegacy()
        input.normalizeAllPlannerGases()
        calculate()
        isReady = true
        saveIfReady()
    }

    func refreshDerivedPlanningPreview() {
        applyInputToPlanningOutputs()
    }

    func calculate() {
        applyInputToPlanningOutputs()
        saveIfReady()
    }

    /// Keeps plan, Bühlmann NDL, and analysis in sync with current gas UI (algorithm unchanged; inputs only).
    private func applyInputToPlanningOutputs() {
        guard isReady else { return }
        isApplyingInputSideEffects = true
        input.normalizeAllPlannerGases()
        input.syncLegacyGasesFromPlannerCylinders()
        buhlmann = BuhlmannPlanner.plan(
            depthMeters: input.buhlmannPlanningDepthMeters,
            bottomGas: input.buhlmannBackGas
        )
        plan = PlannerService.makePlan(input: input)
        isApplyingInputSideEffects = false
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
