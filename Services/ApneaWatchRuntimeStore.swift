import Foundation
import Combine

@MainActor
final class ApneaWatchRuntimeStore: ObservableObject, ApneaWatchRuntimeProviding {
    static private(set) weak var shared: ApneaWatchRuntimeStore?

    @Published private(set) var presentationInput: ApneaWatchPresentationInput = .idle
    @Published private(set) var lifecyclePhase: ApneaLifecyclePhase = .idle
    @Published private(set) var operationalOverlay: ApneaOperationalOverlay?
    @Published var showSessionSummary = false

    private var engine = ApneaSessionEngine()
    private var operationalState = ApneaOperationalEventState.initial
    private var previousAcceptedDepthMeters: Double?
    private var dismissedOverlayEventIDs: Set<UUID> = []
    private var temperatureCelsius: Double?
    private var depthProvider: DepthSensorProvider?
    private var activeDepthSensorMetadata = DepthSensorSessionMetadata()
    private var tickTask: Task<Void, Never>?
    private var checkpointTask: Task<Void, Never>?
    private var firedHapticEventIDs: Set<UUID> = []
    private var missionModeEnabled = false
    private var hapticsEnabled = true

    private let importedPlan: ApneaImportedPlanStore
    private let checkpointFileName = "apnea_watch_session_checkpoint.json"
    #if DEBUG
    static var testHook_checkpointURL: URL?
    static var testLifecycleConfiguration: ApneaLifecycleConfiguration?
    #endif

    init(importedPlan: ApneaImportedPlanStore = .shared) {
        self.importedPlan = importedPlan
        Self.shared = self
        restoreCheckpointIfPresent()
        refreshPresentation()
    }

    var currentDepthMeters: Double? { engine.snapshot.currentDepthMeters }

    var isSensorDegraded: Bool {
        engine.snapshot.sensorHealth != .available
    }

    var isSessionActive: Bool {
        lifecyclePhase != .idle && lifecyclePhase != .ended
    }

    func configureRuntimePreferences(hapticsEnabled: Bool, missionModeEnabled: Bool) {
        self.hapticsEnabled = hapticsEnabled
        self.missionModeEnabled = missionModeEnabled
        refreshPresentation()
    }

    func armSession(at wallClock: Date = Date()) {
        applyImportedPlanConfiguration()
        engine.armSession(at: wallClock)
        operationalState = .initial
        previousAcceptedDepthMeters = nil
        dismissedOverlayEventIDs.removeAll()
        firedHapticEventIDs.removeAll()
        operationalOverlay = nil
        showSessionSummary = false
        startDepthSensor()
        startBackgroundLoops()
        refreshPresentation()
        persistCheckpointSoon()
    }

    func startManualFallback() {
        engine.enableManualFallback()
        refreshPresentation()
        persistCheckpointSoon()
    }

    func triggerManualDescent() {
        engine.triggerManualDescent()
        processOperationalEvents(accepted: true)
        refreshPresentation()
        persistCheckpointSoon()
    }

    func triggerManualSurface() {
        engine.triggerManualSurface()
        processOperationalEvents(accepted: true)
        refreshPresentation()
        persistCheckpointSoon()
    }

    func requestSessionSummary() {
        showSessionSummary = true
        refreshPresentation()
    }

    func endSession() {
        engine.endSession()
        stopDepthSensor()
        stopBackgroundLoops()
        clearCheckpoint()
        refreshPresentation()
    }

    func dismissOperationalOverlay(eventID: UUID) {
        dismissedOverlayEventIDs.insert(eventID)
        if operationalOverlay?.eventID == eventID {
            operationalOverlay = nil
        }
        refreshPresentation()
    }

    func saveCompletedSession(to logbook: ApneaLogbookStore) {
        var session = engine.snapshot.session
        if session.state != .completed {
            session.state = .completed
        }
        session.statistics = session.refreshedStatistics()
        if isSensorDegraded, !session.warnings.contains(.dataQualityDegraded) {
            session.warnings.append(.dataQualityDegraded)
        }
        session.depthSampleSource = activeDepthSensorMetadata.depthSampleSource
        session.depthCapabilityMode = activeDepthSensorMetadata.depthCapabilityMode
        logbook.add(session)
    }

    func resetAfterSave() {
        engine = ApneaSessionEngine(recoveryPolicy: currentRecoveryPolicy())
        operationalState = .initial
        previousAcceptedDepthMeters = nil
        dismissedOverlayEventIDs.removeAll()
        firedHapticEventIDs.removeAll()
        operationalOverlay = nil
        showSessionSummary = false
        stopDepthSensor()
        stopBackgroundLoops()
        clearCheckpoint()
        importedPlan.activatePendingIfNeeded(sessionInProgress: false)
        refreshPresentation()
    }

    func ingestDepthForTesting(depthMeters: Double, temperatureCelsius: Double? = nil, at wallClock: Date = Date()) {
        self.temperatureCelsius = temperatureCelsius
        let result = engine.ingest(
            raw: DepthMeasurementRaw(
                depthMeters: depthMeters,
                sensorTimestamp: wallClock,
                receivedAt: wallClock,
                temperatureCelsius: temperatureCelsius
            ),
            wallClock: wallClock
        )
        if result.accepted != nil {
            processOperationalEvents(accepted: true)
        }
        refreshPresentation()
    }

    func tickForTesting(at wallClock: Date = Date()) {
        engine.tick(now: wallClock)
        refreshPresentation()
    }

    #if DEBUG
    func persistCheckpointNowForTesting() {
        persistCheckpoint()
    }

    func runEngineReplayForTesting(
        depths: [Double],
        intervalSeconds: TimeInterval,
        startDate: Date
    ) {
        engine.replayProfile(depths: depths, intervalSeconds: intervalSeconds, startDate: startDate)
        previousAcceptedDepthMeters = engine.snapshot.currentDepthMeters
        processOperationalEvents(accepted: true)
        refreshPresentation()
    }

    func replaceEngineForTesting(_ engine: ApneaSessionEngine) {
        self.engine = engine
        refreshPresentation()
    }
    #endif

    // MARK: - Private

    private func applyImportedPlanConfiguration() {
        let package = importedPlan.activatedPackage ?? importedPlan.pendingPackage
        let plan = package?.body.plan
        let profile = package?.body.profile
        let recoveryPolicy = plan?.recoveryPolicy ?? profile?.recoveryPolicy ?? .default
        engine = ApneaSessionEngine(
            configuration: Self.testLifecycleConfiguration ?? .default,
            recoveryPolicy: recoveryPolicy
        )
        missionModeEnabled = package?.body.settings.missionModeEnabled ?? false
    }

    private func currentRecoveryPolicy() -> ApneaRecoveryPolicy {
        let package = importedPlan.activatedPackage ?? importedPlan.pendingPackage
        return package?.body.plan.recoveryPolicy
            ?? package?.body.profile?.recoveryPolicy
            ?? .default
    }

    private func operationalConfiguration() -> (alarms: [ApneaAlarm], targets: [ApneaTarget], markers: [ApneaDepthMarker]) {
        let package = importedPlan.activatedPackage ?? importedPlan.pendingPackage
        let plan = package?.body.plan
        let profile = package?.body.profile
        let alarms = plan?.alarms.isEmpty == false ? (plan?.alarms ?? []) : (profile?.alarms ?? [])
        let markers = plan?.markers.isEmpty == false ? (plan?.markers ?? []) : (profile?.markers ?? [])
        var targets: [ApneaTarget] = []
        if let depth = plan?.entries.sorted(by: { $0.orderIndex < $1.orderIndex }).first?.targetDepthMeters
            ?? profile?.targetDepthMeters {
            targets = [
                ApneaTarget(
                    kind: .depth,
                    label: String(localized: "apnea.ready.target"),
                    targetDepthMeters: depth,
                    direction: .descending
                )
            ]
        }
        return (alarms, targets, markers)
    }

    private func startDepthSensor() {
        stopDepthSensor()
        let mode = SensorSourceMode.runtimeMode
        let selection = SensorProviderFactory.makeSelection(mode: mode)
        activeDepthSensorMetadata = DepthSensorSessionMetadata.capture(from: selection)
        let provider = selection.provider
        provider.onDepthMeasurement = { [weak self] depth, timestamp, temperature in
            Task { @MainActor in
                self?.handleDepthMeasurement(depth: depth, temperature: temperature, timestamp: timestamp)
            }
        }
        provider.onTemperature = { [weak self] temperature, _ in
            Task { @MainActor in
                self?.temperatureCelsius = temperature
                self?.refreshPresentation()
            }
        }
        provider.start()
        depthProvider = provider
    }

    private func stopDepthSensor() {
        depthProvider?.stop()
        depthProvider = nil
    }

    private func handleDepthMeasurement(depth: Double?, temperature: Double?, timestamp: Date) {
        temperatureCelsius = temperature
        let depthValue = depth ?? 0
        let result = engine.ingest(
            raw: DepthMeasurementRaw(
                depthMeters: depthValue,
                sensorTimestamp: timestamp,
                receivedAt: Date(),
                temperatureCelsius: temperature
            ),
            wallClock: Date()
        )
        if result.accepted != nil {
            processOperationalEvents(accepted: true)
        }
        refreshPresentation()
        persistCheckpointSoon()
    }

    private func processOperationalEvents(accepted: Bool) {
        guard accepted else { return }
        let snapshot = engine.snapshot
        guard let currentDepth = snapshot.currentDepthMeters else { return }
        let config = operationalConfiguration()
        let context = ApneaOperationalEventContext(
            monotonicNow: snapshot.sessionElapsedSeconds,
            wallClockNow: Date(),
            diveElapsedSeconds: snapshot.diveElapsedSeconds,
            sessionElapsedSeconds: snapshot.sessionElapsedSeconds,
            recoveryCompleted: snapshot.isRecoveryComplete,
            batteryPercent: nil,
            sensorDegraded: isSensorDegraded,
            missionModeEnabled: missionModeEnabled,
            hapticsEnabled: hapticsEnabled
        )
        let output = ApneaOperationalEventEngine.evaluate(
            previousDepthMeters: previousAcceptedDepthMeters,
            currentDepthMeters: currentDepth,
            verticalSpeedMetersPerSecond: snapshot.verticalSpeedMetersPerSecond,
            alarms: config.alarms,
            targets: config.targets,
            markers: config.markers,
            state: &operationalState,
            context: context
        )
        previousAcceptedDepthMeters = currentDepth

        if let overlay = output.overlays.last,
           !dismissedOverlayEventIDs.contains(overlay.eventID) {
            operationalOverlay = overlay
        }

        for cue in output.hapticCues where hapticsEnabled {
            let key = cue.sourceID ?? UUID()
            guard !firedHapticEventIDs.contains(key) else { continue }
            firedHapticEventIDs.insert(key)
            playHaptic(cue.pattern)
        }
    }

    private func playHaptic(_ pattern: ApneaHapticPattern) {
        switch pattern {
        case .markerReached, .targetReached:
            HapticService.shared.confirm()
        case .alarmInfo, .alarmWarning:
            HapticService.shared.notify()
        case .alarmCritical:
            HapticService.shared.criticalConfirm()
        }
    }

    private func startBackgroundLoops() {
        stopBackgroundLoops()
        tickTask = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard let self, self.isSessionActive else { continue }
                self.engine.tick()
                self.refreshPresentation()
            }
        }
    }

    private func stopBackgroundLoops() {
        tickTask?.cancel()
        tickTask = nil
        checkpointTask?.cancel()
        checkpointTask = nil
    }

    private func persistCheckpointSoon() {
        checkpointTask?.cancel()
        checkpointTask = Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 250_000_000)
            self?.persistCheckpoint()
        }
    }

    private func persistCheckpoint() {
        guard isSessionActive else { return }
        do {
            let envelope = try engine.exportCheckpoint()
            try ApneaSessionCheckpointStore.write(envelope, to: checkpointURL())
        } catch {
            // Checkpoint failures must not interrupt an active session.
        }
    }

    private func restoreCheckpointIfPresent() {
        guard FileManager.default.fileExists(atPath: checkpointURL().path) else { return }
        do {
            let envelope = try ApneaSessionCheckpointStore.read(from: checkpointURL())
            engine = try ApneaSessionEngine(checkpoint: envelope)
            lifecyclePhase = engine.snapshot.phase
            showSessionSummary = false
            startBackgroundLoops()
        } catch {
            clearCheckpoint()
        }
    }

    private func clearCheckpoint() {
        try? FileManager.default.removeItem(at: checkpointURL())
    }

    private func checkpointURL() -> URL {
        #if DEBUG
        if let hook = Self.testHook_checkpointURL {
            return hook
        }
        #endif
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        return base.appendingPathComponent(checkpointFileName)
    }

    private func refreshPresentation() {
        lifecyclePhase = engine.snapshot.phase
        presentationInput = buildPresentationInput()
    }

    private func buildPresentationInput() -> ApneaWatchPresentationInput {
        let snapshot = engine.snapshot
        let planPresentation = importedPlan.readyPresentation
        let dives = snapshot.session.dives
        let lastDive = dives.last
        let currentDepth = snapshot.currentDepthMeters ?? 0
        let sessionMax = max(dives.map(\.maxDepthMeters).max() ?? 0, currentDepth)
        let activeMax = max(lastDive?.maxDepthMeters ?? 0, currentDepth)
        let diveCount = dives.count
        let totalUnderwater = snapshot.totalUnderwaterSeconds
        let bestTime = dives.map(\.durationSeconds).max() ?? 0
        let average = diveCount > 0 ? totalUnderwater / Double(diveCount) : 0
        let sessionTotal = snapshot.sessionElapsedSeconds

        let overlay: ApneaWatchOverlayPresentation? = {
            guard let operational = operationalOverlay,
                  !dismissedOverlayEventIDs.contains(operational.eventID) else { return nil }
            let dismissSafe = operational.kind != .alarm
                && (snapshot.recoveryRemainingSeconds ?? 0) <= 0
                && currentDepth < 0.5
            return ApneaWatchOverlayPresentation(
                kind: operational.kind,
                title: operational.title,
                subtitle: operational.subtitle,
                depthMeters: operational.depthMeters,
                dismissSafe: dismissSafe
            )
        }()

        let recoveryRemaining = snapshot.recoveryRemainingSeconds ?? 0
        let recoveryInsufficient = snapshot.session.warnings.contains(.incompleteRecovery)
            && recoveryRemaining > 0

        var sessionWarnings: [String] = []
        if recoveryInsufficient {
            sessionWarnings.append(String(localized: "apnea.recovery.state.insufficient"))
        }

        return ApneaWatchPresentationInput(
            isSessionStarted: lifecyclePhase != .idle,
            showSessionSummary: showSessionSummary,
            currentDepthMeters: currentDepth,
            maxDepthMeters: lifecyclePhase == .submerged || lifecyclePhase == .descending || lifecyclePhase == .ascending
                ? activeMax
                : sessionMax,
            temperatureCelsius: temperatureCelsius,
            diveElapsedSeconds: snapshot.diveElapsedSeconds,
            diveCount: diveCount,
            verticalSpeedMetersPerSecond: snapshot.verticalSpeedMetersPerSecond,
            targetDepthMeters: planPresentation.targetDepthMeters,
            recoveryPolicyLabel: planPresentation.recoveryPolicyLabel,
            activeAlarmCount: planPresentation.enabledAlarmLabels.count,
            configuredAlarmLabels: planPresentation.enabledAlarmLabels,
            buddyReminderEnabled: true,
            sensorDegraded: isSensorDegraded,
            hapticsEnabled: hapticsEnabled,
            missionModeEnabled: planPresentation.missionModeEnabled || missionModeEnabled,
            surfaceElapsedSeconds: snapshot.surfaceElapsedSeconds,
            lastDiveDurationSeconds: lastDive?.durationSeconds ?? 0,
            lastDiveMaxDepthMeters: lastDive?.maxDepthMeters ?? 0,
            requiredRecoverySeconds: snapshot.requiredRecoverySeconds,
            recoveryElapsedSeconds: snapshot.recoveryElapsedSeconds,
            recoveryRemainingSeconds: recoveryRemaining,
            recoveryInsufficient: recoveryInsufficient,
            recoveryInProgress: snapshot.phase == .recovery,
            allowEarlyDiveWhenIncomplete: engine.recoveryPolicy.allowEarlyDiveWhenIncomplete,
            sessionTotalSeconds: sessionTotal,
            totalUnderwaterSeconds: totalUnderwater,
            sessionMaxDepthMeters: sessionMax,
            bestDiveDurationSeconds: bestTime,
            averageDiveDurationSeconds: average,
            sessionWarnings: sessionWarnings,
            dataQualityDegraded: isSensorDegraded,
            activeOverlay: overlay
        )
    }
}

private extension ApneaWatchPresentationInput {
    static let idle = ApneaWatchPresentationInput(
        isSessionStarted: false,
        showSessionSummary: false,
        currentDepthMeters: 0,
        maxDepthMeters: 0,
        temperatureCelsius: nil,
        diveElapsedSeconds: 0,
        diveCount: 0,
        verticalSpeedMetersPerSecond: 0,
        targetDepthMeters: 0,
        recoveryPolicyLabel: "",
        activeAlarmCount: 0,
        configuredAlarmLabels: [],
        buddyReminderEnabled: true,
        sensorDegraded: false,
        hapticsEnabled: true,
        missionModeEnabled: false,
        surfaceElapsedSeconds: 0,
        lastDiveDurationSeconds: 0,
        lastDiveMaxDepthMeters: 0,
        requiredRecoverySeconds: 0,
        recoveryElapsedSeconds: 0,
        recoveryRemainingSeconds: 0,
        recoveryInsufficient: false,
        recoveryInProgress: false,
        allowEarlyDiveWhenIncomplete: false,
        sessionTotalSeconds: 0,
        totalUnderwaterSeconds: 0,
        sessionMaxDepthMeters: 0,
        bestDiveDurationSeconds: 0,
        averageDiveDurationSeconds: 0,
        sessionWarnings: [],
        dataQualityDegraded: false,
        activeOverlay: nil
    )
}
