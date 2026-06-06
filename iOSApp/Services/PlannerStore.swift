import Foundation
import Combine

@MainActor
final class PlannerStore: ObservableObject {
    @Published var mode: PlannerMode = .base {
        didSet {
            guard isReady else { return }
            saveIfReady()
            applyInputToPlanningOutputs()
        }
    }
    @Published var input = GasPlanInput() {
        didSet {
            guard !isApplyingInputSideEffects else { return }
            saveIfReady()
            applyInputToPlanningOutputs()
        }
    }
    @Published var plan = PlannerService.makePlan(input: GasPlanInput(), mode: .base)
    @Published var buhlmann = BuhlmannPlanner.plan(
        depthMeters: 40,
        bottomGas: GasMix(name: "Gas di Fondo", oxygen: 0.18, helium: 0.45, maxPPO2: 1.40)
    )
    var analysis: TechnicalGasAnalysis { GasPlanningService.analyze(input: input, mode: mode) }
    var briefingText: String { plan.briefingLines.joined(separator: "\n") }
    @Published var repetitivePlanningEnabled: Bool = false {
        didSet { saveIfReady() }
    }
    @Published var surfaceIntervalMinutes: Double = 60 {
        didSet { saveIfReady() }
    }
    @Published private(set) var isCalculating = false
    @Published private(set) var lastTissueSnapshot: TissueSnapshot?

    private let cloudSync: CloudSyncStore?
    private let key = "dirdiving_ios_experimental_planner_state"
    private var isReady = false
    private var isApplyingInputSideEffects = false

    init(cloudSync: CloudSyncStore? = nil) {
        self.cloudSync = cloudSync
        if let saved = cloudSync?.load(PlannerState.self, forKey: key) {
            mode = saved.mode
            input = saved.input
            repetitivePlanningEnabled = saved.repetitivePlanningEnabled
            surfaceIntervalMinutes = saved.surfaceIntervalMinutes
            lastTissueSnapshot = saved.lastTissueSnapshot
        }
        input.ensurePlannerCylindersFromLegacy()
        calculate()
        isReady = true
        saveIfReady()
    }

    func refreshDerivedPlanningPreview() {
        applyInputToPlanningOutputs()
    }

    func calculate() {
        guard isReady else { return }
        isCalculating = true
        defer { isCalculating = false }
        applyInputToPlanningOutputs(persistSnapshot: true)
        saveIfReady()
    }

    /// Keeps plan, Bühlmann NDL, and analysis in sync with mode-projected planner input.
    private func applyInputToPlanningOutputs(persistSnapshot: Bool = false) {
        guard isReady else { return }
        isApplyingInputSideEffects = true
        input.syncLegacyGasesFromPlannerCylinders()
        let active = PlannerModePolicy.activePlanInput(from: input, mode: mode)
        if case .success(let environment) = PlannerEnvironment.make(altitudeMeters: active.altitudeMeters, salinity: active.salinity) {
            buhlmann = BuhlmannPlanner.plan(
                depthMeters: active.buhlmannPlanningDepthMeters,
                bottomGas: active.buhlmannBackGas,
                environment: environment,
                gfHigh: active.gfHigh
            )
        }
        plan = PlannerService.makePlan(
            input: input,
            mode: mode,
            repetitivePlanningEnabled: repetitivePlanningEnabled,
            repetitiveSnapshot: repetitivePlanningEnabled ? lastTissueSnapshot : nil,
            surfaceIntervalMinutes: surfaceIntervalMinutes
        )
        if persistSnapshot,
           let environment = try? makeEnvironment(from: active),
           let snapshot = RepetitiveDivePlannerService.makeSnapshot(from: BuhlmannPlanner.enginePlan(input: active), environment: environment) {
            lastTissueSnapshot = snapshot
        }
        isApplyingInputSideEffects = false
    }

    func updateTeamMember(_ member: TeamMember) {
        guard let index = input.teamMembers.firstIndex(where: { $0.id == member.id }) else { return }
        input.teamMembers[index] = member
    }

    private func saveIfReady() {
        guard isReady else { return }
        cloudSync?.save(
            PlannerState(
                mode: mode,
                input: input,
                repetitivePlanningEnabled: repetitivePlanningEnabled,
                surfaceIntervalMinutes: surfaceIntervalMinutes,
                lastTissueSnapshot: lastTissueSnapshot
            ),
            forKey: key
        )
    }

    private func makeEnvironment(from input: GasPlanInput) throws -> PlannerEnvironment {
        switch PlannerEnvironment.make(altitudeMeters: input.altitudeMeters, salinity: input.salinity) {
        case .success(let environment):
            return environment
        case .failure:
            throw NSError(domain: "PlannerEnvironment", code: 2)
        }
    }
}

private struct PlannerState: Codable {
    var mode: PlannerMode
    var input: GasPlanInput
    var repetitivePlanningEnabled: Bool = false
    var surfaceIntervalMinutes: Double = 60
    var lastTissueSnapshot: TissueSnapshot?
}
