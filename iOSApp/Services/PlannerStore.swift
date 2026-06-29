import Foundation
import Combine

@MainActor
final class PlannerStore: ObservableObject {
    @Published var mode: PlannerMode = .base {
        didSet {
            guard isReady else { return }
            deferModeMutationSideEffects()
        }
    }
    @Published var input = GasPlanInput() {
        didSet {
            guard !isApplyingInputSideEffects else { return }
            deferInputMutationSideEffects()
        }
    }
    @Published var plan = DivePlanResult.empty
    @Published var buhlmann = BuhlmannPlanResult.emptyReference
    @Published private(set) var analysis: TechnicalGasAnalysis = GasPlanningService.analyze(input: GasPlanInput(), mode: .base)
    var briefingText: String { plan.briefingLines.joined(separator: "\n") }
    @Published var repetitivePlanningEnabled: Bool = false {
        didSet { scheduleSave() }
    }
    @Published var surfaceIntervalMinutes: Double = 60 {
        didSet { scheduleSave() }
    }
    @Published private(set) var chartSnapshots = PlannerChartSnapshots.empty
    @Published private(set) var tissueAnalyticsPresentation: TissueAnalyticsPresentation?
    @Published private(set) var isCalculating = false
    @Published private(set) var plannerBriefingSessionId = UUID()
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
    @Published var ccrInput = CCRPlanInput.default {
        didSet {
            guard !isApplyingInputSideEffects, isReady else { return }
            deferCCRInputMutationSideEffects()
        }
    }
    @Published private(set) var ccrPlan = CCRPlanResult.empty
    @Published var plannerShowsModeSelection = false

    private let cloudSync: CloudSyncStore?
    private let key = "dirdiving_ios_experimental_planner_state"
    private var isReady = false
    private var isApplyingInputSideEffects = false
    private var planningUpdateTask: Task<Void, Never>?
    private var saveTask: Task<Void, Never>?
    private var planningGeneration: UInt = 0
    private var activeCalculationGeneration: UInt?
    private var cachedAnalysis: TechnicalGasAnalysis?
    private var analysisCacheKey: AnalysisCacheKey?
    private var ascentSpeedObserver: NSObjectProtocol?

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
            ccrInput = saved.ccrInput ?? .default
            plannerShowsModeSelection = saved.plannerShowsModeSelection ?? false
        } else {
            plannerShowsModeSelection = true
        }
        input.ensurePlannerCylindersFromLegacy()
        isReady = true
        ascentSpeedObserver = NotificationCenter.default.addObserver(
            forName: .plannerAscentSpeedSettingsDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.invalidateAnalysisCache()
                self?.refreshDerivedPlanningPreview()
            }
        }
        deferPublishedMutation { [self] in
            schedulePlanningUpdate(persistSnapshot: false)
            if mode.isCCR {
                scheduleCCRPlanningUpdate(immediate: true)
            }
            saveIfReady()
        }
    }

    deinit {
        planningUpdateTask?.cancel()
        saveTask?.cancel()
        if let ascentSpeedObserver {
            NotificationCenter.default.removeObserver(ascentSpeedObserver)
        }
    }

    func selectPlannerMode(_ selected: PlannerMode) {
        mode = selected
        plannerShowsModeSelection = false
        if selected.isCCR {
            scheduleCCRPlanningUpdate(immediate: true)
        } else {
            schedulePlanningUpdate()
        }
    }

    func returnToPlannerModeSelection() {
        plannerShowsModeSelection = true
    }

    func preparePostLegalOnboardingEntry() {
        guard isReady else { return }
        plannerShowsModeSelection = true
        saveIfReady()
    }

    func refreshDerivedPlanningPreview() {
        schedulePlanningUpdate()
    }

    func requestCNSThresholdSettingsFocus() {
        scrollToCNSThresholdSettings = true
    }

    func acknowledgeCNSThresholdSettingsFocus() {
        deferPublishedMutation { [self] in
            scrollToCNSThresholdSettings = false
        }
    }

    func bootstrapPlannerIfNeeded() {
        deferPublishedMutation { [self] in
            guard isReady else { return }
            isApplyingInputSideEffects = true
            input.ensurePlannerCylindersFromLegacy()
            isApplyingInputSideEffects = false
            refreshDerivedPlanningPreview()
        }
    }

    func normalizeSwitchDepthAfterGasOrPPO2Change(cylinderID: UUID) {
        guard isReady else { return }
        deferPublishedMutation { [self] in
            guard isReady else { return }
            isApplyingInputSideEffects = true
            input.normalizeSwitchDepthsToMOD(changedCylinderID: cylinderID, updateChangedGasToMOD: true)
            isApplyingInputSideEffects = false
            invalidateAnalysisCache()
            schedulePlanningUpdate()
            scheduleSave()
        }
    }

    func clampAllSwitchDepthsToMOD() {
        guard isReady else { return }
        deferPublishedMutation { [self] in
            guard isReady else { return }
            isApplyingInputSideEffects = true
            input.normalizeSwitchDepthsToMOD()
            isApplyingInputSideEffects = false
            invalidateAnalysisCache()
            schedulePlanningUpdate()
            scheduleSave()
        }
    }

    func clampSwitchDepth(forCylinderAt index: Int, proposedMeters: Double) {
        guard isReady, input.plannerCylinders.indices.contains(index) else { return }
        deferPublishedMutation { [self] in
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
        saveTask?.cancel()
        if mode.isCCR {
            scheduleCCRPlanningUpdate(immediate: true)
        } else {
            schedulePlanningUpdate(persistSnapshot: true, immediate: true)
        }
        saveIfReady()
    }

    private func schedulePlanningUpdate(persistSnapshot: Bool = false, immediate: Bool = false) {
        guard isReady, mode.isOpenCircuit else { return }
        planningUpdateTask?.cancel()
        planningGeneration &+= 1
        let generation = planningGeneration
        planningUpdateTask = Task { @MainActor in
            if !immediate {
                await Task.yield()
                try? await Task.sleep(nanoseconds: 200_000_000)
            }
            guard !Task.isCancelled, generation == planningGeneration else { return }
            await runBackgroundOCCalculation(generation: generation, persistSnapshot: persistSnapshot)
        }
    }

    private func runBackgroundOCCalculation(generation: UInt, persistSnapshot: Bool) async {
        guard generation == planningGeneration else { return }
        if activeCalculationGeneration == generation { return }
        activeCalculationGeneration = generation
        isCalculating = true

        refreshAnalysis(force: false)
        let snapshot = PlannerOCCalculationInput(
            mode: mode,
            input: input,
            repetitivePlanningEnabled: repetitivePlanningEnabled,
            lastTissueSnapshot: lastTissueSnapshot,
            surfaceIntervalMinutes: surfaceIntervalMinutes,
            decompressionMethod: decompressionMethod,
            ratioDecoPreset: ratioDecoPreset,
            ascentSpeedSettings: PlannerAscentSpeedSettings.load(),
            precomputedAnalysis: analysis
        )

        let result = await Task.detached(priority: .userInitiated) {
            PlannerBackgroundCalculation.compute(
                snapshot: snapshot,
                generation: generation,
                persistSnapshot: persistSnapshot
            )
        }.value

        guard !Task.isCancelled, generation == planningGeneration else {
            isCalculating = false
            activeCalculationGeneration = nil
            return
        }

        applyCalculationResult(result, generation: generation)
        isCalculating = false
        activeCalculationGeneration = nil
    }

    private func applyCalculationResult(_ result: PlannerOCCalculationResult, generation: UInt) {
        guard generation == planningGeneration else { return }
        isApplyingInputSideEffects = true
        plan = result.plan
        buhlmann = result.buhlmann
        analysis = result.analysis
        cachedAnalysis = result.analysis
        analysisCacheKey = AnalysisCacheKey(input: input, mode: mode)
        if let snapshot = result.lastTissueSnapshot {
            lastTissueSnapshot = snapshot
        }
        isApplyingInputSideEffects = false
        plannerBriefingSessionId = UUID()
        if chartSnapshots != result.chartSnapshots {
#if DEBUG
            PlannerChartSnapshots.testHook_invalidationCount += 1
#endif
            chartSnapshots = result.chartSnapshots
        }
        tissueAnalyticsPresentation = result.tissueAnalytics
    }

    private func refreshCCRChartSnapshots() {
        let next = PlannerChartSnapshots.make(fromCCR: ccrPlan, generation: planningGeneration)
        guard next != chartSnapshots else { return }
#if DEBUG
        PlannerChartSnapshots.testHook_invalidationCount += 1
#endif
        chartSnapshots = next
        tissueAnalyticsPresentation = TissueAnalyticsService.presentationForCCRPlan(plan: ccrPlan, input: ccrInput)
    }

    func updateTeamMember(_ member: TeamMember) {
        guard let index = input.teamMembers.firstIndex(where: { $0.id == member.id }) else { return }
        input.teamMembers[index] = member
    }

    private func scheduleCCRPlanningUpdate(immediate: Bool = false) {
        guard isReady, mode.isCCR else { return }
        planningUpdateTask?.cancel()
        planningGeneration &+= 1
        let generation = planningGeneration
        planningUpdateTask = Task { @MainActor in
            if !immediate {
                await Task.yield()
                try? await Task.sleep(nanoseconds: 200_000_000)
            }
            guard !Task.isCancelled, generation == planningGeneration else { return }
            await runBackgroundCCRCalculation(generation: generation)
        }
    }

    private func runBackgroundCCRCalculation(generation: UInt) async {
        guard generation == planningGeneration else { return }
        isCalculating = true
        let capturedInput = ccrInput
        let result = await Task.detached(priority: .userInitiated) {
            let signpost = DIRPerformanceSignpost.begin(.iosCCRPlannerCalculation)
            defer { signpost.end() }
            return CCRPlannerService.makePlan(input: capturedInput)
        }.value
        guard !Task.isCancelled, generation == planningGeneration else {
            isCalculating = false
            return
        }
        ccrPlan = result
        plannerBriefingSessionId = UUID()
        refreshCCRChartSnapshots()
        isCalculating = false
    }

    private func deferPublishedMutation(_ operation: @MainActor @escaping () -> Void) {
        Task { @MainActor in
            await Task.yield()
            operation()
        }
    }

    private func deferModeMutationSideEffects() {
        deferPublishedMutation { [self] in
            guard isReady else { return }
            isApplyingInputSideEffects = true
            PlannerModeLimits.enforceInputLimits(&input, mode: mode)
            input.normalizeSwitchDepthsToMOD()
            isApplyingInputSideEffects = false
            invalidateAnalysisCache()
            scheduleSave()
            schedulePlanningUpdate()
        }
    }

    private func deferInputMutationSideEffects() {
        deferPublishedMutation { [self] in
            guard !isApplyingInputSideEffects else { return }
            isApplyingInputSideEffects = true
            PlannerModeLimits.enforceInputLimits(&input, mode: mode)
            isApplyingInputSideEffects = false
            invalidateAnalysisCache()
            scheduleSave()
            schedulePlanningUpdate()
        }
    }

    private func deferCCRInputMutationSideEffects() {
        deferPublishedMutation { [self] in
            guard isReady else { return }
            scheduleSave()
            scheduleCCRPlanningUpdate()
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
                savedRatioDecoPresets: savedRatioDecoPresets,
                ccrInput: ccrInput,
                plannerShowsModeSelection: plannerShowsModeSelection
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
        let computed = GasPlanningService.analyze(
            input: input,
            mode: mode,
            ascentSpeedSettings: PlannerAscentSpeedSettings.load()
        )
        cachedAnalysis = computed
        analysisCacheKey = key
        analysis = computed
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
    var ccrInput: CCRPlanInput?
    var plannerShowsModeSelection: Bool?

    init(
        mode: PlannerMode,
        input: GasPlanInput,
        repetitivePlanningEnabled: Bool = false,
        surfaceIntervalMinutes: Double = 60,
        lastTissueSnapshot: TissueSnapshot? = nil,
        decompressionMethod: PlannerDecompressionMethod = .buhlmann,
        ratioDecoPreset: RatioDecoPreset = .preset1to1,
        savedRatioDecoPresets: [RatioDecoPreset] = [],
        ccrInput: CCRPlanInput? = nil,
        plannerShowsModeSelection: Bool? = nil
    ) {
        self.mode = mode
        self.input = input
        self.repetitivePlanningEnabled = repetitivePlanningEnabled
        self.surfaceIntervalMinutes = surfaceIntervalMinutes
        self.lastTissueSnapshot = lastTissueSnapshot
        self.decompressionMethod = decompressionMethod
        self.ratioDecoPreset = ratioDecoPreset
        self.savedRatioDecoPresets = savedRatioDecoPresets
        self.ccrInput = ccrInput
        self.plannerShowsModeSelection = plannerShowsModeSelection
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
        ccrInput = try container.decodeIfPresent(CCRPlanInput.self, forKey: .ccrInput)
        plannerShowsModeSelection = try container.decodeIfPresent(Bool.self, forKey: .plannerShowsModeSelection)
    }
}

private struct AnalysisCacheKey: Equatable {
    let mode: PlannerMode
    let plannedDepthMeters: Double
    let plannedAverageDepthMeters: Double
    let planningDepthReference: PlanningDepthReference
    let averageDepthGasConsumptionEnabled: Bool
    let bottomTimeMinutes: Double
    let sacLitersPerMinute: Double
    let emergencySacLitersPerMinute: Double
    let teamSize: Double
    let emergencyExtraMinutes: Double
    let altitudeMeters: Double
    let salinity: SalinityMode
    let bottomGasSignature: String
    let cylinderSignature: String
    let environmentSignature: String
    let projectedCylinderSignature: String
    let ascentSpeedSignature: String

    init(input: GasPlanInput, mode: PlannerMode) {
        self.mode = mode
        plannedDepthMeters = input.plannedDepthMeters
        plannedAverageDepthMeters = input.plannedAverageDepthMeters
        planningDepthReference = input.planningDepthReference
        averageDepthGasConsumptionEnabled = input.averageDepthGasConsumptionEnabled
        bottomTimeMinutes = input.plannedBottomMinutes
        sacLitersPerMinute = input.sacLitersPerMinute
        emergencySacLitersPerMinute = input.emergencySacLitersPerMinute
        teamSize = input.teamSize
        emergencyExtraMinutes = input.emergencyExtraMinutes
        altitudeMeters = input.altitudeMeters
        salinity = input.salinity
        bottomGasSignature = "\(input.bottomGas.oxygen)-\(input.bottomGas.helium)-\(input.bottomGas.maxPPO2)"
        cylinderSignature = input.plannerCylinders.map {
            "\($0.id.uuidString)|\($0.role.rawValue)|\($0.gas.oxygen)|\($0.gas.helium)|\($0.gas.maxPPO2)|\($0.switchDepthMeters)|\($0.startPressure)|\($0.pressureUnit.rawValue)"
        }.joined(separator: ";")
        environmentSignature = "\(input.altitudeMeters)-\(input.salinity.rawValue)-\(input.gfLow)-\(input.gfHigh)"
        let projected = PlannerModePolicy.activePlanInput(from: input, mode: mode)
        projectedCylinderSignature = projected.plannerCylinders.map {
            "\($0.id.uuidString)|\($0.role.rawValue)|\($0.gas.oxygen)|\($0.gas.helium)|\($0.gas.maxPPO2)|\($0.switchDepthMeters)"
        }.joined(separator: ";")
        ascentSpeedSignature = PlannerAscentSpeedSettings.load().signature
    }
}

#if DEBUG
extension PlannerStore {
    var testHook_planningGeneration: UInt { planningGeneration }

    func testHook_flushDebouncedWork() async {
        for _ in 0..<5 {
            await Task.yield()
        }
        try? await Task.sleep(nanoseconds: 250_000_000)
        planningUpdateTask?.cancel()
        saveTask?.cancel()
        isCalculating = false
        activeCalculationGeneration = nil
        await runBackgroundOCCalculation(generation: planningGeneration, persistSnapshot: false)
        saveIfReady()
    }
}
#endif
