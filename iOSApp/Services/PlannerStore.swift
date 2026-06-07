import Foundation
import Combine

@MainActor
final class PlannerStore: ObservableObject {
    @Published var mode: PlannerMode = .base {
        didSet {
            guard isReady else { return }
            isApplyingInputSideEffects = true
            PlannerModeLimits.enforceInputLimits(&input, mode: mode)
            isApplyingInputSideEffects = false
            invalidateAnalysisCache()
            scheduleSave()
            schedulePlanningUpdate()
        }
    }
    @Published var input = GasPlanInput() {
        didSet {
            guard !isApplyingInputSideEffects else { return }
            isApplyingInputSideEffects = true
            PlannerModeLimits.enforceInputLimits(&input, mode: mode)
            isApplyingInputSideEffects = false
            invalidateAnalysisCache()
            scheduleSave()
            schedulePlanningUpdate()
        }
    }
    @Published var plan = PlannerService.makePlan(input: GasPlanInput(), mode: .base)
    @Published var buhlmann = BuhlmannPlanner.plan(
        depthMeters: 40,
        bottomGas: GasMix(name: "Gas di Fondo", oxygen: 0.18, helium: 0.45, maxPPO2: 1.40)
    )
    @Published private(set) var analysis: TechnicalGasAnalysis = GasPlanningService.analyze(input: GasPlanInput(), mode: .base)
    var briefingText: String { plan.briefingLines.joined(separator: "\n") }
    @Published var repetitivePlanningEnabled: Bool = false {
        didSet { scheduleSave() }
    }
    @Published var surfaceIntervalMinutes: Double = 60 {
        didSet { scheduleSave() }
    }
    @Published private(set) var isCalculating = false
    @Published private(set) var lastTissueSnapshot: TissueSnapshot?
    @Published var scrollToCNSThresholdSettings = false
    @Published var decompressionMethod: PlannerDecompressionMethod = .buhlmann {
        didSet {
            guard isReady else { return }
            scheduleSave()
            schedulePlanningUpdate()
        }
    }
    @Published var ratioDecoPreset: RatioDecoPreset = .preset1to1 {
        didSet {
            guard isReady else { return }
            scheduleSave()
            schedulePlanningUpdate()
        }
    }
    @Published var savedRatioDecoPresets: [RatioDecoPreset] = [] {
        didSet {
            guard isReady else { return }
            scheduleSave()
        }
    }

    private let cloudSync: CloudSyncStore?
    private let key = "dirdiving_ios_experimental_planner_state"
    private var isReady = false
    private var isApplyingInputSideEffects = false
    private var planningUpdateTask: Task<Void, Never>?
    private var saveTask: Task<Void, Never>?
    private var planningGeneration: UInt = 0
    private var cachedAnalysis: TechnicalGasAnalysis?
    private var analysisCacheKey: AnalysisCacheKey?

    init(cloudSync: CloudSyncStore? = nil) {
        self.cloudSync = cloudSync
        if let saved = cloudSync?.load(PlannerState.self, forKey: key) {
            mode = saved.mode
            input = saved.input
            repetitivePlanningEnabled = saved.repetitivePlanningEnabled
            surfaceIntervalMinutes = saved.surfaceIntervalMinutes
            lastTissueSnapshot = saved.lastTissueSnapshot
            decompressionMethod = saved.decompressionMethod
            ratioDecoPreset = saved.ratioDecoPreset
            savedRatioDecoPresets = saved.savedRatioDecoPresets
        }
        input.ensurePlannerCylindersFromLegacy()
        calculate()
        isReady = true
        saveIfReady()
    }

    func refreshDerivedPlanningPreview() {
        schedulePlanningUpdate()
    }

    func requestCNSThresholdSettingsFocus() {
        scrollToCNSThresholdSettings = true
    }

    func acknowledgeCNSThresholdSettingsFocus() {
        scrollToCNSThresholdSettings = false
    }

    func normalizeSwitchDepthAfterGasOrPPO2Change(cylinderID: UUID) {
        guard isReady else { return }
        isApplyingInputSideEffects = true
        input.normalizeSwitchDepthsToMOD(changedCylinderID: cylinderID, updateChangedGasToMOD: true)
        isApplyingInputSideEffects = false
        invalidateAnalysisCache()
        schedulePlanningUpdate()
        scheduleSave()
    }

    func clampAllSwitchDepthsToMOD() {
        guard isReady else { return }
        isApplyingInputSideEffects = true
        input.normalizeSwitchDepthsToMOD()
        isApplyingInputSideEffects = false
        invalidateAnalysisCache()
        schedulePlanningUpdate()
        scheduleSave()
    }

    func clampSwitchDepth(forCylinderAt index: Int, proposedMeters: Double) {
        guard isReady, input.plannerCylinders.indices.contains(index) else { return }
        let environment = input.plannerEnvironment
        let maxAllowed = input.plannerCylinders[index].usableSwitchDepthMeters(environment: environment)
        let clamped = min(max(0, proposedMeters), maxAllowed)
        guard abs(input.plannerCylinders[index].switchDepthMeters - clamped) > 0.001 else { return }
        isApplyingInputSideEffects = true
        input.plannerCylinders[index].switchDepthMeters = clamped
        isApplyingInputSideEffects = false
        invalidateAnalysisCache()
        schedulePlanningUpdate()
        scheduleSave()
    }

    func normalizeNewCylinderSwitchDepth(cylinderID: UUID) {
        normalizeSwitchDepthAfterGasOrPPO2Change(cylinderID: cylinderID)
    }

    func saveRatioDecoPreset(_ preset: RatioDecoPreset) {
        guard isReady, !preset.isBuiltIn else { return }
        if let index = savedRatioDecoPresets.firstIndex(where: { $0.id == preset.id }) {
            savedRatioDecoPresets[index] = preset
        } else {
            savedRatioDecoPresets.append(preset)
        }
        ratioDecoPreset = preset
    }

    func deleteRatioDecoPreset(id: UUID) {
        guard isReady else { return }
        savedRatioDecoPresets.removeAll { $0.id == id && !$0.isBuiltIn }
        if ratioDecoPreset.id == id {
            ratioDecoPreset = .customDefault
        }
    }

    func calculate() {
        guard isReady else { return }
        planningUpdateTask?.cancel()
        saveTask?.cancel()
        isCalculating = true
        defer { isCalculating = false }
        refreshAnalysis(force: true)
        applyInputToPlanningOutputs(persistSnapshot: true)
        saveIfReady()
    }

    /// Keeps plan, Bühlmann NDL, and analysis in sync with mode-projected planner input.
    private func applyInputToPlanningOutputs(persistSnapshot: Bool = false) {
        guard isReady else { return }
        isApplyingInputSideEffects = true
        input.syncLegacyGasesFromPlannerCylinders()
        refreshAnalysis(force: false)
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
            surfaceIntervalMinutes: surfaceIntervalMinutes,
            decompressionMethod: decompressionMethod,
            ratioDecoPreset: ratioDecoPreset,
            unitPreference: .metric
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

    private func schedulePlanningUpdate(persistSnapshot: Bool = false) {
        guard isReady else { return }
        planningUpdateTask?.cancel()
        planningGeneration &+= 1
        let generation = planningGeneration
        isCalculating = true
        planningUpdateTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 200_000_000)
            guard !Task.isCancelled, generation == planningGeneration else { return }
            applyInputToPlanningOutputs(persistSnapshot: persistSnapshot)
            isCalculating = false
        }
    }

    private func scheduleSave() {
        guard isReady else { return }
        saveTask?.cancel()
        saveTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 350_000_000)
            guard !Task.isCancelled else { return }
            saveIfReady()
        }
    }

    private func saveIfReady() {
        guard isReady else { return }
        cloudSync?.save(
            PlannerState(
                mode: mode,
                input: input,
                repetitivePlanningEnabled: repetitivePlanningEnabled,
                surfaceIntervalMinutes: surfaceIntervalMinutes,
                lastTissueSnapshot: lastTissueSnapshot,
                decompressionMethod: decompressionMethod,
                ratioDecoPreset: ratioDecoPreset,
                savedRatioDecoPresets: savedRatioDecoPresets
            ),
            forKey: key
        )
    }

    private func invalidateAnalysisCache() {
        cachedAnalysis = nil
        analysisCacheKey = nil
    }

    private func refreshAnalysis(force: Bool) {
        let key = AnalysisCacheKey(input: input, mode: mode)
        if !force, key == analysisCacheKey, let cachedAnalysis {
            analysis = cachedAnalysis
            return
        }
        let computed = GasPlanningService.analyze(input: input, mode: mode)
        cachedAnalysis = computed
        analysisCacheKey = key
        analysis = computed
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
    var decompressionMethod: PlannerDecompressionMethod = .buhlmann
    var ratioDecoPreset: RatioDecoPreset = .preset1to1
    var savedRatioDecoPresets: [RatioDecoPreset] = []

    init(
        mode: PlannerMode,
        input: GasPlanInput,
        repetitivePlanningEnabled: Bool = false,
        surfaceIntervalMinutes: Double = 60,
        lastTissueSnapshot: TissueSnapshot? = nil,
        decompressionMethod: PlannerDecompressionMethod = .buhlmann,
        ratioDecoPreset: RatioDecoPreset = .preset1to1,
        savedRatioDecoPresets: [RatioDecoPreset] = []
    ) {
        self.mode = mode
        self.input = input
        self.repetitivePlanningEnabled = repetitivePlanningEnabled
        self.surfaceIntervalMinutes = surfaceIntervalMinutes
        self.lastTissueSnapshot = lastTissueSnapshot
        self.decompressionMethod = decompressionMethod
        self.ratioDecoPreset = ratioDecoPreset
        self.savedRatioDecoPresets = savedRatioDecoPresets
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        mode = try container.decode(PlannerMode.self, forKey: .mode)
        input = try container.decode(GasPlanInput.self, forKey: .input)
        repetitivePlanningEnabled = try container.decodeIfPresent(Bool.self, forKey: .repetitivePlanningEnabled) ?? false
        surfaceIntervalMinutes = try container.decodeIfPresent(Double.self, forKey: .surfaceIntervalMinutes) ?? 60
        lastTissueSnapshot = try container.decodeIfPresent(TissueSnapshot.self, forKey: .lastTissueSnapshot)
        decompressionMethod = try container.decodeIfPresent(PlannerDecompressionMethod.self, forKey: .decompressionMethod) ?? .buhlmann
        ratioDecoPreset = try container.decodeIfPresent(RatioDecoPreset.self, forKey: .ratioDecoPreset) ?? .preset1to1
        savedRatioDecoPresets = try container.decodeIfPresent([RatioDecoPreset].self, forKey: .savedRatioDecoPresets) ?? []
    }
}

private struct AnalysisCacheKey: Equatable {
    let mode: PlannerMode
    let plannedDepthMeters: Double
    let bottomTimeMinutes: Double
    let altitudeMeters: Double
    let salinity: SalinityMode
    let bottomGasSignature: String
    let cylinderSignature: String
    let environmentSignature: String

    init(input: GasPlanInput, mode: PlannerMode) {
        self.mode = mode
        plannedDepthMeters = input.plannedDepthMeters
        bottomTimeMinutes = input.plannedBottomMinutes
        altitudeMeters = input.altitudeMeters
        salinity = input.salinity
        bottomGasSignature = "\(input.bottomGas.oxygen)-\(input.bottomGas.helium)-\(input.bottomGas.maxPPO2)"
        cylinderSignature = input.plannerCylinders.map {
            "\($0.id.uuidString)|\($0.role.rawValue)|\($0.gas.oxygen)|\($0.gas.helium)|\($0.gas.maxPPO2)|\($0.switchDepthMeters)|\($0.startPressure)|\($0.pressureUnit.rawValue)"
        }.joined(separator: ";")
        environmentSignature = "\(input.altitudeMeters)-\(input.salinity.rawValue)-\(input.gfLow)-\(input.gfHigh)"
    }
}

#if DEBUG
extension PlannerStore {
    var testHook_planningGeneration: UInt { planningGeneration }

    func testHook_flushDebouncedWork() async {
        planningUpdateTask?.cancel()
        saveTask?.cancel()
        isCalculating = false
        applyInputToPlanningOutputs()
        saveIfReady()
    }
}
#endif
