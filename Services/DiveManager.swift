import Foundation
import Combine
import WatchKit

@MainActor
final class DiveManager: ObservableObject {
    static private(set) weak var shared: DiveManager?

    private enum ActiveDiveDraftPhase: String, Codable {
        case active
        case finalizing
    }

    private static let supportedDraftSchemaVersion = 5
    private static let minimumDraftSchemaVersion = 1
    private static let quarantineDirectoryName = "Diagnostics/Quarantine"

    private struct ActiveDiveDraft: Codable {
        let schemaVersion: Int
        let phase: ActiveDiveDraftPhase
        let sessionID: UUID
        let startDate: Date
        let endDate: Date?
        let samples: [DiveSample]
        let entryGPS: GPSPoint?
        let exitGPS: GPSPoint?
        let entryGPSFixSource: GPSFixSource
        let exitGPSFixSource: GPSFixSource
        let isManualLifecycleActive: Bool
        let sessionStartedManually: Bool
        let activeDiveExceededSupportedDepth: Bool
        let hasObservedSubmersionDuringCurrentDive: Bool
        let missionModeManualPendingForSession: Bool
        let watchActivityMode: String?
        let watchDivingMode: String?
        let fullComputerGasSwitchTracker: FullComputerGasSwitchTracker?
        let fullComputerCheckpoint: FullComputerRuntimeCheckpoint?
        let fullComputerLogbookMetadata: FullComputerDiveLogbookMetadata?
        let createdAt: Date
        let updatedAt: Date

        init(
            schemaVersion: Int = DiveManager.supportedDraftSchemaVersion,
            phase: ActiveDiveDraftPhase,
            sessionID: UUID,
            startDate: Date,
            endDate: Date? = nil,
            samples: [DiveSample],
            entryGPS: GPSPoint?,
            exitGPS: GPSPoint? = nil,
            entryGPSFixSource: GPSFixSource,
            exitGPSFixSource: GPSFixSource = .noFix,
            isManualLifecycleActive: Bool,
            sessionStartedManually: Bool,
            activeDiveExceededSupportedDepth: Bool,
            hasObservedSubmersionDuringCurrentDive: Bool,
            missionModeManualPendingForSession: Bool = false,
            watchActivityMode: String? = nil,
            watchDivingMode: String? = nil,
            fullComputerGasSwitchTracker: FullComputerGasSwitchTracker? = nil,
            fullComputerCheckpoint: FullComputerRuntimeCheckpoint? = nil,
            fullComputerLogbookMetadata: FullComputerDiveLogbookMetadata? = nil,
            createdAt: Date,
            updatedAt: Date
        ) {
            self.schemaVersion = schemaVersion
            self.phase = phase
            self.sessionID = sessionID
            self.startDate = startDate
            self.endDate = endDate
            self.samples = samples
            self.entryGPS = entryGPS
            self.exitGPS = exitGPS
            self.entryGPSFixSource = entryGPSFixSource
            self.exitGPSFixSource = exitGPSFixSource
            self.isManualLifecycleActive = isManualLifecycleActive
            self.sessionStartedManually = sessionStartedManually
            self.activeDiveExceededSupportedDepth = activeDiveExceededSupportedDepth
            self.hasObservedSubmersionDuringCurrentDive = hasObservedSubmersionDuringCurrentDive
            self.missionModeManualPendingForSession = missionModeManualPendingForSession
            self.watchActivityMode = watchActivityMode
            self.watchDivingMode = watchDivingMode
            self.fullComputerGasSwitchTracker = fullComputerGasSwitchTracker
            self.fullComputerCheckpoint = fullComputerCheckpoint
            self.fullComputerLogbookMetadata = fullComputerLogbookMetadata
            self.createdAt = createdAt
            self.updatedAt = updatedAt
        }

        private enum CodingKeys: String, CodingKey {
            case schemaVersion, phase, sessionID, startDate, endDate, samples
            case entryGPS, exitGPS, entryGPSFixSource, exitGPSFixSource
            case isManualLifecycleActive, sessionStartedManually
            case activeDiveExceededSupportedDepth, hasObservedSubmersionDuringCurrentDive
            case missionModeManualPendingForSession, watchActivityMode, watchDivingMode
            case fullComputerGasSwitchTracker, fullComputerCheckpoint, fullComputerLogbookMetadata
            case createdAt, updatedAt
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            guard let schemaVersion = try container.decodeIfPresent(Int.self, forKey: .schemaVersion),
                  schemaVersion >= DiveManager.minimumDraftSchemaVersion else {
                throw DecodingError.dataCorruptedError(
                    forKey: .schemaVersion,
                    in: container,
                    debugDescription: "Unsupported or legacy active dive draft schema"
                )
            }
            self.schemaVersion = schemaVersion
            phase = try container.decode(ActiveDiveDraftPhase.self, forKey: .phase)
            sessionID = try container.decode(UUID.self, forKey: .sessionID)
            startDate = try container.decode(Date.self, forKey: .startDate)
            endDate = try container.decodeIfPresent(Date.self, forKey: .endDate)
            samples = try container.decode([DiveSample].self, forKey: .samples)
            entryGPS = try container.decodeIfPresent(GPSPoint.self, forKey: .entryGPS)
            exitGPS = try container.decodeIfPresent(GPSPoint.self, forKey: .exitGPS)
            entryGPSFixSource = try container.decode(GPSFixSource.self, forKey: .entryGPSFixSource)
            exitGPSFixSource = try container.decodeIfPresent(GPSFixSource.self, forKey: .exitGPSFixSource) ?? .noFix
            isManualLifecycleActive = try container.decode(Bool.self, forKey: .isManualLifecycleActive)
            sessionStartedManually = try container.decodeIfPresent(Bool.self, forKey: .sessionStartedManually) ?? isManualLifecycleActive
            activeDiveExceededSupportedDepth = try container.decode(Bool.self, forKey: .activeDiveExceededSupportedDepth)
            hasObservedSubmersionDuringCurrentDive = try container.decode(Bool.self, forKey: .hasObservedSubmersionDuringCurrentDive)
            missionModeManualPendingForSession = try container.decodeIfPresent(Bool.self, forKey: .missionModeManualPendingForSession) ?? false
            watchActivityMode = try container.decodeIfPresent(String.self, forKey: .watchActivityMode)
            watchDivingMode = try container.decodeIfPresent(String.self, forKey: .watchDivingMode)
            fullComputerGasSwitchTracker = try container.decodeIfPresent(
                FullComputerGasSwitchTracker.self,
                forKey: .fullComputerGasSwitchTracker
            )
            fullComputerCheckpoint = try container.decodeIfPresent(
                FullComputerRuntimeCheckpoint.self,
                forKey: .fullComputerCheckpoint
            )
            fullComputerLogbookMetadata = try container.decodeIfPresent(
                FullComputerDiveLogbookMetadata.self,
                forKey: .fullComputerLogbookMetadata
            )
            createdAt = try container.decode(Date.self, forKey: .createdAt)
            updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        }
    }

    @Published var currentDepthMeters: Double = 0
    @Published var averageDepthMeters: Double = 0
    @Published var maxDepthMeters: Double = 0
    @Published var currentTemperatureCelsius: Double?
    @Published var runtime: TimeInterval = 0
    @Published var ttv: Double = 0
    @Published var stopwatchTime: TimeInterval = 0
    @Published var isStopwatchRunning = false
    @Published var isDiveActive = false
    @Published var ascentStatus = AscentStatus.make(rate: 0, depth: 0)
    @Published private(set) var alarmBlinkActive = false
    @Published var lastErrorMessage: String?
    @Published var alarmWarningMessage: String?
    @Published var gpsConfirmation: DiveGPSConfirmation?
    @Published var isDepthAutomationAvailable = false
    @Published var developerSensorSourceWarning: String?
    @Published var apneaOperationalOverlay: ApneaOperationalOverlay?
    @Published private(set) var isSimulationDepthActive = false
    /// Experimental Apnea/Snorkeling surfaces use this legacy name for sensor availability.
    var isDepthSensorAvailable: Bool { isDepthAutomationAvailable }
    @Published private(set) var isDepthAutomationMockFallbackActive = false
    @Published private(set) var depthSensorSourceResolution: DepthSensorSourceResolution = .unavailable
    @Published private(set) var draftRecoveryDiagnostic: String?
    @Published private(set) var lastDraftPersistenceError: String?
    @Published var isManualLifecycleActive = false
    @Published private(set) var manualStartHandedOffToAutomatic = false
    @Published private(set) var isMissionModeActive = false
    @Published private(set) var missionModeActivationSource: MissionModeActivationSource?
    @Published private(set) var missionModeManualPendingForSession = false
    @Published private(set) var depthSafetyState: DepthSafetyState = .normal
    @Published private(set) var exceededSupportedDepthRange = false
    @Published private(set) var isDepthDataStale = false
    @Published private(set) var depthDataUsesLastKnownReading = false
    @Published private(set) var diveReminderOverlay: DiveReminderOverlayContent?
    @Published private(set) var sessionActivityMode: DIRActivityMode = .diving
    @Published private(set) var sessionDivingMode: DIRDivingMode = .gauge
    @Published private(set) var fullComputerSnapshot: FullComputerRuntimeSnapshot?
    @Published private(set) var isFullComputerRecoveryActive = false

    private enum AlarmBlinkSource: Hashable {
        case ascent
        case depth
        case runtime
        case battery
    }

    private let depthLimitHaptics = DepthLimitHapticCoordinator()
    private let ascentHaptics = AscentSafetyHapticCoordinator()

    private var ascentAlarmEnabled: Bool {
        UserDefaults.standard.object(forKey: "dirdiving_watch_alarm_ascent_enabled") == nil
            ? true
            : UserDefaults.standard.bool(forKey: "dirdiving_watch_alarm_ascent_enabled")
    }
    private var depthAlarmEnabled: Bool { UserDefaults.standard.bool(forKey: "dirdiving_watch_alarm_depth_enabled") }
    private var runtimeAlarmEnabled: Bool { UserDefaults.standard.bool(forKey: "dirdiving_watch_alarm_runtime_enabled") }
    private var depthAlarmThresholdMeters: Double {
        let stored = UserDefaults.standard.double(forKey: "dirdiving_watch_alarm_depth_threshold_m")
        return stored > 0 ? stored : 40
    }
    private var runtimeAlarmThresholdMinutes: Int {
        let stored = UserDefaults.standard.integer(forKey: "dirdiving_watch_alarm_runtime_threshold_min")
        return stored > 0 ? stored : WatchAlarmDefaults.runtimeThresholdMinutes
    }
    private var batteryAlarmThresholdPercent: Int {
        let stored = UserDefaults.standard.integer(forKey: "dirdiving_watch_alarm_battery_threshold_pct")
        return stored > 0 ? stored : 20
    }
    private var batteryAlarmEnabled: Bool {
        UserDefaults.standard.object(forKey: "dirdiving_watch_alarm_battery_enabled") == nil
            ? true
            : UserDefaults.standard.bool(forKey: "dirdiving_watch_alarm_battery_enabled")
    }

    private let logStore: DiveLogStore
    private let gpsManager: GPSManager
    private let ascentSettings: AscentRateSettingsStore
    private var depthSensorProvider: DepthSensorProvider?
    private var runtimeTimer: Timer?
    private var stopwatchTimer: Timer?
    private var settingsCancellable: AnyCancellable?
    private var sessionStart: Date?
    private var samples: [DiveSample] = []
    private var entryGPS: GPSPoint?
    private var exitGPS: GPSPoint?
    private var entryGPSFixSource: GPSFixSource = .noFix
    private var exitGPSFixSource: GPSFixSource = .noFix
    private var previousDepthSample: DiveSample?
    private var activeDiveSessionID: UUID?
    private var isFinalizingDive = false
    private var lastDepthAlarmDate: Date?
    private var lastRuntimeAlarmDate: Date?
    private var diveReminderRuntimeState = DiveReminderRuntimeState()
    private var diveReminderDismissTask: Task<Void, Never>?
    private var lastBatteryAlarmDate: Date?
    private var lastAlarmDismissDate: Date?
    private var activeDiveExceededSupportedDepth = false
    private var hasObservedSubmersionDuringCurrentDive = false
    private var depthValidationState = DepthSampleValidationState()
    private var lifecycleAlgorithm = DiveLifecycleAlgorithm()
    private var automaticSurfaceEndTask: Task<Void, Never>?
    private var stopwatchAccumulatedTime: TimeInterval = 0
    private var stopwatchStartedAt: Date?
    private var runtimeClock = MonotonicElapsedClock()
    private var stopwatchClock = MonotonicElapsedClock()
    private var lastAcceptedDepthSampleAt: Date?
    private var lastTemperatureSampleAt: Date?
    private var sessionStartedManually = false
    private var activeBlinkSources: Set<AlarmBlinkSource> = []
    private var lastReportedRuntime: TimeInterval = 0
    private var fullComputerEngine: FullComputerRuntimeEngine?
    private var fullComputerLogbookAccumulator: FullComputerRuntimeLogbookAccumulator?

    private let activeDiveDraftFileName = "dirdiving_active_dive_draft.json"
    private let stopwatchAccumulatedKey = "dirdiving_watch_stopwatch_accumulated"
    private let stopwatchStartedAtKey = "dirdiving_watch_stopwatch_started_at"
    private let stopwatchRunningKey = "dirdiving_watch_stopwatch_running"

    private var missionModeAutoEnableOnDiveStart: Bool {
        UserDefaults.standard.bool(forKey: MissionModeSettings.autoEnableOnDiveStartKey)
    }

    var missionModeRuntimeProfile: MissionModeRuntimeProfile {
        isMissionModeActive ? .mission : .standard
    }

    var missionModeWillActivateOnNextDive: Bool {
        missionModeAutoEnableOnDiveStart || missionModeManualPendingForSession
    }

    func recordSessionModeSelection(activity: DIRActivityMode, divingMode: DIRDivingMode) {
        sessionActivityMode = activity
        sessionDivingMode = divingMode
    }

    init(logStore: DiveLogStore, gpsManager: GPSManager, ascentSettings: AscentRateSettingsStore) {
        self.logStore = logStore
        self.gpsManager = gpsManager
        self.ascentSettings = ascentSettings
        Self.shared = self
        settingsCancellable = ascentSettings.$limits.sink { [weak self] limits in
            Task { @MainActor in
                guard let self else { return }
                self.ascentStatus = AscentStatus.make(
                    rate: self.ascentStatus.currentRateMetersPerMinute,
                    depth: self.currentDepthMeters,
                    limits: limits
                )
                self.ascentHaptics.update(isOverLimit: self.isDiveActive && self.ascentStatus.isOverLimit && self.ascentAlarmEnabled)
            }
        }
        loadStopwatchState()
        configureDepthSensorProvider()
        restoreActiveDiveDraftIfAvailable()
    }

    func reloadDepthSensorConfiguration() {
        configureDepthSensorProvider()
    }

    private func configureDepthSensorProvider() {
        depthSensorProvider?.stop()
        depthSensorProvider = nil
        developerSensorSourceWarning = nil
        isSimulationDepthActive = false
        isDepthAutomationMockFallbackActive = false
        depthSensorSourceResolution = .unavailable

        if Self.testHook_suppressDepthSensorProvider {
            isDepthAutomationAvailable = true
            depthSensorSourceResolution = .unavailable
            return
        }

        var mode = DeveloperSettings.sensorSourceMode
        if mode == .appleSensor, !AppleDepthSensorProvider.isAvailable {
            let fallback: SensorSourceMode = DeveloperSettings.allowsSimulationSensorSelection ? .simulation : .automatic
            DeveloperSettings.persistSensorSource(fallback)
            mode = fallback
            developerSensorSourceWarning = String(localized: "developer.sensor_source.apple_fallback")
        }

        let provider = SensorProviderFactory.makeProvider(mode: mode)
        let usesMockProvider = provider is MockDepthSensorProvider
        isSimulationDepthActive = usesMockProvider
        switch mode {
        case .simulation:
            depthSensorSourceResolution = .simulation
            isDepthAutomationMockFallbackActive = false
        case .automatic, .appleSensor:
            if usesMockProvider {
                depthSensorSourceResolution = .mockFallback
                isDepthAutomationMockFallbackActive = true
            } else {
                depthSensorSourceResolution = .appleSensor
                isDepthAutomationMockFallbackActive = false
            }
        }
        provider.onDepthMeasurement = { [weak self] depth, timestamp, temperature in
            self?.processDepthMeasurement(
                rawDepthMeters: depth,
                timestamp: timestamp,
                receivedAt: timestamp,
                temperatureCelsius: temperature
            )
        }
        provider.onSubmersionState = { [weak self] state in
            self?.handleSubmersionState(state)
        }
        provider.onTemperature = { [weak self] celsius, receivedAt in
            self?.currentTemperatureCelsius = DiveAlgorithm.sanitizedTemperatureCelsius(celsius)
            self?.lastTemperatureSampleAt = celsius == nil ? nil : receivedAt
        }
        provider.onError = { [weak self] message in
            self?.lastErrorMessage = message
        }
        provider.start()
        depthSensorProvider = provider

        switch mode {
        case .simulation, .automatic:
            isDepthAutomationAvailable = true
        case .appleSensor:
            isDepthAutomationAvailable = AppleDepthSensorProvider.isAvailable
        }
    }

    private func handleSubmersionState(_ state: DepthSensorSubmersionState) {
        switch state {
        case .submerged:
            if isDiveActive {
                hasObservedSubmersionDuringCurrentDive = true
                if isManualLifecycleActive {
                    manualStartHandedOffToAutomatic = true
                    isManualLifecycleActive = false
                }
                cancelAutomaticSurfaceEnd()
            }
        case .notSubmerged:
            guard !isManualLifecycleActive || hasObservedSubmersionDuringCurrentDive else { return }
            guard let previousDepthSample,
                  previousDepthSample.depthMeters <= DiveAlgorithmConfiguration.automaticStopDepthMeters else { return }
            evaluateAutomaticSurfaceCandidate(
                validatedSample: ValidatedDepthSample(
                    validity: .valid,
                    rawDepthMeters: previousDepthSample.depthMeters,
                    sample: previousDepthSample
                )
            )
        case .unknown:
            break
        }
    }

    private func activeDiveDraftURL() -> URL {
        let base = Self.testHook_draftDirectoryURL
            ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return base.appendingPathComponent(activeDiveDraftFileName)
    }

    private func sanitizedSamples(_ source: [DiveSample]) -> [DiveSample] {
        DiveAlgorithm.sanitizedSamples(source)
    }

    private var lastActiveDraftPersistedAt: Date?
    private var activeDraftPersistDeferred = false

    private func persistActiveDiveDraft(immediate: Bool = false) {
        guard isDiveActive, let start = sessionStart else { return }
        let now = Date()
        if !immediate,
           let lastActiveDraftPersistedAt,
           now.timeIntervalSince(lastActiveDraftPersistedAt) < DiveAlgorithmConfiguration.activeDiveDraftPersistenceIntervalSeconds {
            activeDraftPersistDeferred = true
            return
        }
        let sessionID = activeDiveSessionID ?? UUID()
        activeDiveSessionID = sessionID
        var checkpoint: FullComputerRuntimeCheckpoint?
        if sessionDivingMode == .fullComputer, var engine = fullComputerEngine {
            checkpoint = try? engine.exportCheckpoint(
                sessionID: sessionID,
                watchDivingMode: sessionDivingMode.rawValue
            )
            fullComputerEngine = engine
        }
        let draft = ActiveDiveDraft(
            phase: .active,
            sessionID: sessionID,
            startDate: start,
            samples: sanitizedSamples(samples),
            entryGPS: entryGPS,
            entryGPSFixSource: entryGPSFixSource,
            isManualLifecycleActive: isManualLifecycleActive,
            sessionStartedManually: sessionStartedManually,
            activeDiveExceededSupportedDepth: activeDiveExceededSupportedDepth,
            hasObservedSubmersionDuringCurrentDive: hasObservedSubmersionDuringCurrentDive,
            missionModeManualPendingForSession: missionModeManualPendingForSession,
            watchActivityMode: sessionActivityMode.rawValue,
            watchDivingMode: sessionDivingMode.rawValue,
            fullComputerGasSwitchTracker: sessionDivingMode == .fullComputer
                ? fullComputerEngine?.persistedGasSwitchTracker
                : nil,
            fullComputerCheckpoint: checkpoint,
            fullComputerLogbookMetadata: currentFullComputerLogbookMetadata(),
            createdAt: start,
            updatedAt: now
        )
        writeActiveDiveDraft(draft)
        lastActiveDraftPersistedAt = now
        activeDraftPersistDeferred = false
        #if DEBUG
        Self.testHook_activeDraftWriteCount += 1
        #endif
    }

    private func flushDeferredActiveDiveDraftIfNeeded() {
        guard activeDraftPersistDeferred, isDiveActive else { return }
        persistActiveDiveDraft(immediate: true)
    }

    private func persistPendingFinalizationDraft(
        sessionID: UUID,
        start: Date,
        end: Date,
        samples: [DiveSample],
        entryGPS: GPSPoint?,
        exitGPS: GPSPoint?,
        entryGPSFixSource: GPSFixSource,
        exitGPSFixSource: GPSFixSource,
        sessionStartedManually: Bool,
        activeDiveExceededSupportedDepth: Bool,
        fullComputerLogbookMetadata: FullComputerDiveLogbookMetadata?
    ) {
        let now = Date()
        let draft = ActiveDiveDraft(
            phase: .finalizing,
            sessionID: sessionID,
            startDate: start,
            endDate: end,
            samples: sanitizedSamples(samples),
            entryGPS: entryGPS,
            exitGPS: exitGPS,
            entryGPSFixSource: entryGPSFixSource,
            exitGPSFixSource: exitGPSFixSource,
            isManualLifecycleActive: false,
            sessionStartedManually: sessionStartedManually,
            activeDiveExceededSupportedDepth: activeDiveExceededSupportedDepth,
            hasObservedSubmersionDuringCurrentDive: false,
            missionModeManualPendingForSession: missionModeManualPendingForSession,
            watchActivityMode: sessionActivityMode.rawValue,
            watchDivingMode: sessionDivingMode.rawValue,
            fullComputerLogbookMetadata: fullComputerLogbookMetadata,
            createdAt: start,
            updatedAt: now
        )
        writeActiveDiveDraft(draft)
        lastActiveDraftPersistedAt = now
        activeDraftPersistDeferred = false
    }

    private func writeActiveDiveDraft(_ draft: ActiveDiveDraft) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(draft) else {
            lastDraftPersistenceError = String(localized: "watch.draft.encode_failed")
            return
        }
        do {
            try data.write(to: activeDiveDraftURL(), options: [.atomic, .completeFileProtection])
            lastDraftPersistenceError = nil
        } catch {
            lastDraftPersistenceError = error.localizedDescription
        }
    }

    private func quarantineActiveDraftPayload(_ data: Data, reason: String) {
        let base = Self.testHook_draftDirectoryURL
            ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directory = base.appendingPathComponent(Self.quarantineDirectoryName, isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let stamp = Int(Date().timeIntervalSince1970)
        let payloadURL = directory.appendingPathComponent("active_dive_draft_\(stamp).json")
        let metaURL = directory.appendingPathComponent("active_dive_draft_\(stamp).meta.json")
        try? data.write(to: payloadURL, options: [.atomic, .completeFileProtection])
        let meta: [String: String] = [
            "reason": reason,
            "quarantinedAt": ISO8601DateFormatter().string(from: Date())
        ]
        if let metaData = try? JSONSerialization.data(withJSONObject: meta, options: [.sortedKeys]) {
            try? metaData.write(to: metaURL, options: [.atomic, .completeFileProtection])
        }
    }

    private func clearActiveDiveDraft() {
        try? FileManager.default.removeItem(at: activeDiveDraftURL())
    }

    /// Restores `.active` drafts or completes `.finalizing` drafts. Corrupt/legacy payloads are quarantined — never crashes launch.
    private func restoreActiveDiveDraftIfAvailable() {
        let url = activeDiveDraftURL()
        guard let data = try? Data(contentsOf: url) else { return }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let draft = try? decoder.decode(ActiveDiveDraft.self, from: data) else {
            quarantineActiveDraftPayload(data, reason: "unsupported_or_corrupt_schema")
            clearActiveDiveDraft()
            return
        }
        guard Date().timeIntervalSince(draft.updatedAt) <= DiveAlgorithmConfiguration.activeDiveDraftExpirationSeconds else {
            quarantineActiveDraftPayload(data, reason: "expired_ttl")
            draftRecoveryDiagnostic = String(localized: "watch.draft.expired_discarded")
            clearActiveDiveDraft()
            return
        }

        if draft.phase == .finalizing {
            completePendingFinalization(from: draft)
            return
        }

        activeDiveSessionID = draft.sessionID
        let restoredSamples = sanitizedSamples(draft.samples)
        sessionStart = draft.startDate
        samples = restoredSamples
        previousDepthSample = restoredSamples.last
        depthValidationState.restore(lastValidSample: restoredSamples.last)
        entryGPS = draft.entryGPS
        entryGPSFixSource = draft.entryGPSFixSource
        isDiveActive = true
        isManualLifecycleActive = draft.isManualLifecycleActive
        sessionStartedManually = draft.sessionStartedManually
        activeDiveExceededSupportedDepth = draft.activeDiveExceededSupportedDepth
        exceededSupportedDepthRange = draft.activeDiveExceededSupportedDepth
        hasObservedSubmersionDuringCurrentDive = draft.hasObservedSubmersionDuringCurrentDive
        missionModeManualPendingForSession = draft.missionModeManualPendingForSession
        if let rawActivity = draft.watchActivityMode, let activity = DIRActivityMode(rawValue: rawActivity) {
            sessionActivityMode = activity
        }
        if let rawDiving = draft.watchDivingMode, let divingMode = DIRDivingMode(rawValue: rawDiving) {
            sessionDivingMode = divingMode
        }

        if let lastSample = restoredSamples.last {
            currentDepthMeters = lastSample.depthMeters
            currentTemperatureCelsius = lastSample.temperatureCelsius
            maxDepthMeters = restoredSamples.map(\.depthMeters).max() ?? 0
            let restoreTailEnd = min(
                Date(),
                lastSample.timestamp.addingTimeInterval(DiveAlgorithmConfiguration.draftRestoreAverageDepthMaxTailSeconds)
            )
            averageDepthMeters = DiveAlgorithm.timeWeightedAverageDepth(
                samples: restoredSamples,
                endDate: restoreTailEnd
            )
            depthSafetyState = DepthSafetyState.from(depthMeters: lastSample.depthMeters)
            if depthSafetyState == .exceeded {
                activeDiveExceededSupportedDepth = true
                exceededSupportedDepthRange = true
            }
            ascentStatus = AscentStatus.make(
                rate: DiveAlgorithm.ascentRateMetersPerMinute(samples: restoredSamples, current: lastSample),
                depth: lastSample.depthMeters,
                limits: ascentSettings.limits
            )
        }
        runtimeClock.reset(anchorDate: draft.startDate)
        lastReportedRuntime = max(0, Date().timeIntervalSince(draft.startDate))
        runtime = lastReportedRuntime
        lastAcceptedDepthSampleAt = restoredSamples.last?.timestamp
        updateRuntimeFromClock(evaluateAlarms: false)
        gpsManager.start()
        startRuntimeTimer()
        restoreFullComputerRuntimeIfNeeded(
            samples: restoredSamples,
            sessionStart: draft.startDate,
            sessionID: draft.sessionID,
            gasSwitchTracker: draft.fullComputerGasSwitchTracker,
            checkpoint: draft.fullComputerCheckpoint
        )
        if sessionDivingMode == .fullComputer {
            isFullComputerRecoveryActive = true
            fullComputerLogbookAccumulator = FullComputerRuntimeLogbookAccumulator()
            if var accumulator = fullComputerLogbookAccumulator {
                if let metadata = draft.fullComputerLogbookMetadata {
                    for diagnostic in metadata.recoveryDiagnostics {
                        accumulator.recordRecovery(diagnostic: diagnostic)
                    }
                }
                accumulator.recordRecovery(diagnostic: "draft_restore")
                fullComputerLogbookAccumulator = accumulator
            }
        }
        applyMissionModeIfNeededOnDiveStart(restored: true)
    }

    private func completePendingFinalization(from draft: ActiveDiveDraft) {
        guard let endDate = draft.endDate else {
            if let data = try? Data(contentsOf: activeDiveDraftURL()) {
                quarantineActiveDraftPayload(data, reason: "finalizing_missing_end_date")
            }
            draftRecoveryDiagnostic = String(localized: "watch.draft.finalizing_missing_enddate")
            clearActiveDiveDraft()
            return
        }
        if logStore.sessions.contains(where: { $0.id == draft.sessionID }) {
            clearActiveDiveDraft()
            return
        }
        finalizeDive(
            sessionID: draft.sessionID,
            start: draft.startDate,
            end: endDate,
            entryGPS: draft.entryGPS,
            exitGPS: draft.exitGPS,
            entryGPSFixSource: draft.entryGPSFixSource,
            exitGPSFixSource: draft.exitGPSFixSource,
            samples: draft.samples,
            activeDiveExceededSupportedDepth: draft.activeDiveExceededSupportedDepth,
            sessionStartedManually: draft.sessionStartedManually,
            watchActivityMode: draft.watchActivityMode,
            watchDivingMode: draft.watchDivingMode,
            fullComputerLogbookMetadata: draft.fullComputerLogbookMetadata
        )
    }

    private func resetAutomaticLifecycleCandidates() {
        lifecycleAlgorithm.reset()
        automaticSurfaceEndTask?.cancel()
        automaticSurfaceEndTask = nil
    }

    private func evaluateLifecycle(with validatedSample: ValidatedDepthSample) -> DiveLifecycleAction {
        lifecycleAlgorithm.evaluate(
            validatedSample: validatedSample,
            isDiveActive: isDiveActive,
            isManualLifecycleActive: isManualLifecycleActive,
            hasObservedSubmersion: hasObservedSubmersionDuringCurrentDive
        )
    }

    private func evaluateAutomaticSurfaceCandidate(validatedSample: ValidatedDepthSample) {
        guard isDiveActive, !isFinalizingDive else { return }

        let action = evaluateLifecycle(with: validatedSample)
        if action == .endDive {
            endDiveIfNeeded()
        } else if lifecycleAlgorithm.surfaceCandidateDate != nil {
            scheduleAutomaticSurfaceEnd()
        } else {
            cancelAutomaticSurfaceEnd()
        }
    }

    private func scheduleAutomaticSurfaceEnd() {
        guard automaticSurfaceEndTask == nil else { return }
        automaticSurfaceEndTask = Task { [weak self] in
            let dwellSeconds = Self.testHook_automaticStopDwellSeconds
                ?? DiveAlgorithmConfiguration.automaticStopDwellSeconds
            let nanoseconds = UInt64(dwellSeconds * 1_000_000_000)
            try? await Task.sleep(nanoseconds: nanoseconds)
            guard !Task.isCancelled else { return }
            await MainActor.run {
                guard let self else { return }
                self.automaticSurfaceEndTask = nil
                guard self.isDiveActive, !self.isFinalizingDive else { return }
                let dwellSeconds = Self.testHook_automaticStopDwellSeconds
                    ?? DiveAlgorithmConfiguration.automaticStopDwellSeconds
                if self.lifecycleAlgorithm.shouldEndAtSurface(
                    currentDepthMeters: self.currentDepthMeters,
                    timestamp: Date(),
                    dwellSeconds: dwellSeconds
                ) {
                    self.endDiveIfNeeded()
                }
            }
        }
    }

    private func cancelAutomaticSurfaceEnd() {
        lifecycleAlgorithm.clearSurfaceCandidate()
        automaticSurfaceEndTask?.cancel()
        automaticSurfaceEndTask = nil
    }

    private func startRuntimeTimer() {
        runtimeTimer?.invalidate()
        updateRuntimeFromClock(evaluateAlarms: false)
        runtimeTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateRuntimeFromClock(evaluateAlarms: true)
            }
        }
    }

    private func updateRuntimeFromClock(evaluateAlarms: Bool = true) {
        guard sessionStart != nil else { return }
        runtime = runtimeClock.elapsed()
        lastReportedRuntime = runtime
        evaluateDepthCallbackFreshness()
        ttv = DiveAlgorithm.ttvIndex(averageDepthMeters: averageDepthMeters, durationSeconds: runtime)
        tickFullComputerRuntimeIfNeeded()
        if evaluateAlarms {
            evaluateRuntimeAlarms()
            evaluateDiveReminders()
        }
    }

    private func evaluateDepthCallbackFreshness(now: Date = Date()) {
        guard isDiveActive else {
            isDepthDataStale = false
            depthDataUsesLastKnownReading = false
            return
        }
        if isManualNoDepthSession {
            isDepthDataStale = false
            depthDataUsesLastKnownReading = false
            return
        }
        guard isDepthAutomationAvailable else {
            isDepthDataStale = false
            depthDataUsesLastKnownReading = false
            return
        }

        let threshold = DiveAlgorithmConfiguration.activeDepthCallbackSilenceSeconds
        if let lastAcceptedDepthSampleAt {
            let age = now.timeIntervalSince(lastAcceptedDepthSampleAt)
            if age > threshold {
                isDepthDataStale = true
                depthDataUsesLastKnownReading = true
            } else {
                isDepthDataStale = false
                depthDataUsesLastKnownReading = false
            }
            return
        }

        if let sessionStart, now.timeIntervalSince(sessionStart) > threshold {
            isDepthDataStale = true
            depthDataUsesLastKnownReading = false
        } else {
            isDepthDataStale = false
            depthDataUsesLastKnownReading = false
        }
    }

    var isManualNoDepthSession: Bool {
        isDiveActive && !isDepthAutomationAvailable && isManualLifecycleActive
    }

    private func loadStopwatchState() {
        stopwatchAccumulatedTime = max(0, UserDefaults.standard.double(forKey: stopwatchAccumulatedKey))
        if UserDefaults.standard.bool(forKey: stopwatchRunningKey) {
            stopwatchStartedAt = UserDefaults.standard.object(forKey: stopwatchStartedAtKey) as? Date ?? Date()
            if let stopwatchStartedAt {
                stopwatchClock.reset(anchorDate: stopwatchStartedAt)
            }
            isStopwatchRunning = true
            updateStopwatchFromClock()
            startStopwatchTimer()
        } else {
            isStopwatchRunning = false
            stopwatchStartedAt = nil
            stopwatchTime = stopwatchAccumulatedTime
        }
    }

    private func persistStopwatchState() {
        UserDefaults.standard.set(stopwatchAccumulatedTime, forKey: stopwatchAccumulatedKey)
        UserDefaults.standard.set(isStopwatchRunning, forKey: stopwatchRunningKey)
        if let stopwatchStartedAt {
            UserDefaults.standard.set(stopwatchStartedAt, forKey: stopwatchStartedAtKey)
        } else {
            UserDefaults.standard.removeObject(forKey: stopwatchStartedAtKey)
        }
    }

    private func startStopwatchTimer() {
        stopwatchTimer?.invalidate()
        guard isStopwatchRunning else { return }
        stopwatchTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateStopwatchFromClock()
            }
        }
    }

    private func updateStopwatchFromClock() {
        guard isStopwatchRunning, stopwatchStartedAt != nil else {
            stopwatchTime = stopwatchAccumulatedTime
            return
        }
        stopwatchTime = stopwatchAccumulatedTime + stopwatchClock.elapsed()
    }

    func startStopwatch() {
        guard !isStopwatchRunning else { return }
        let now = Date()
        stopwatchStartedAt = now
        stopwatchClock.reset(anchorDate: now)
        isStopwatchRunning = true
        updateStopwatchFromClock()
        startStopwatchTimer()
        persistStopwatchState()
        HapticService.shared.confirm()
    }

    func stopStopwatch() { stopStopwatch(playHaptic: true) }
    func resetStopwatch() {
        stopStopwatch(playHaptic: false)
        stopwatchAccumulatedTime = 0
        stopwatchStartedAt = nil
        stopwatchTime = 0
        persistStopwatchState()
        HapticService.shared.confirm()
    }
    func toggleStopwatch() { isStopwatchRunning ? stopStopwatch() : startStopwatch() }

    func startManualDive() {
        beginDiveIfNeeded(isManual: true)
    }

    func endManualDive() {
        guard isDiveActive else { return }
        guard isManualLifecycleActive || sessionStartedManually else { return }
        endDiveIfNeeded(isManual: true)
    }

    func dismissAlarmWarning() {
        guard alarmWarningMessage != nil else { return }
        alarmWarningMessage = nil
        lastAlarmDismissDate = Date()
        stopBlinking(source: .depth)
        stopBlinking(source: .runtime)
        stopBlinking(source: .battery)
        HapticService.shared.notify()
    }

    func resyncHapticsAfterPreferenceChange() {
        ascentHaptics.refreshHapticsAfterPreferenceChange()
        depthLimitHaptics.refreshAfterPreferenceChange(currentDepthMeters: currentDepthMeters)
    }

    private func beginDiveIfNeeded(isManual: Bool = false, sessionStart: Date? = nil) {
        guard !isDiveActive, !isFinalizingDive else { return }
        resetAutomaticLifecycleCandidates()
        if isManual {
            depthValidationState.reset()
        }
        gpsManager.start()
        isDiveActive = true
        isManualLifecycleActive = isManual
        sessionStartedManually = isManual
        manualStartHandedOffToAutomatic = false
        hasObservedSubmersionDuringCurrentDive = !isManual
        applyMissionModeIfNeededOnDiveStart()
        HapticService.shared.criticalConfirm()
        alarmWarningMessage = nil
        resetDiveReminderRuntime()
        let start = sessionStart ?? Date()
        activeDiveSessionID = UUID()
        self.sessionStart = start
        runtimeClock.reset(anchorDate: start)
        lastAcceptedDepthSampleAt = nil
        isDepthDataStale = false
        depthDataUsesLastKnownReading = false
        entryGPS = gpsManager.currentBestPoint()
        let capturedAtStart = entryGPS
        entryGPSFixSource = capturedAtStart == nil ? .noFix : .fallback
        gpsManager.captureBestEffortPoint(for: 6) { [weak self] point in
            guard let self, self.isDiveActive, !self.isFinalizingDive else { return }
            self.entryGPS = point ?? capturedAtStart
            self.entryGPSFixSource = point != nil ? .fix : (capturedAtStart == nil ? .noFix : .fallback)
            self.showGPSConfirmation(.start(point: self.entryGPS, fallback: point == nil && capturedAtStart != nil))
            self.persistActiveDiveDraft(immediate: true)
        }
        samples = []
        previousDepthSample = nil
        currentDepthMeters = 0
        averageDepthMeters = 0
        maxDepthMeters = 0
        depthSafetyState = .normal
        exceededSupportedDepthRange = false
        depthLimitHaptics.reset()
        runtime = 0
        ttv = 0
        lastReportedRuntime = 0
        startFullComputerRuntimeIfNeeded(sessionStart: start)
        persistActiveDiveDraft(immediate: true)
        startRuntimeTimer()
    }

    private func endDiveIfNeeded(isManual: Bool = false) {
        guard isDiveActive, let start = sessionStart, !isFinalizingDive else { return }
        flushDeferredActiveDiveDraftIfNeeded()
        cancelAutomaticSurfaceEnd()
        updateRuntimeFromClock(evaluateAlarms: false)
        let sessionID = activeDiveSessionID ?? UUID()
        let capturedEntryGPS = entryGPS
        let capturedEntryGPSFixSource = entryGPSFixSource
        let capturedSessionStartedManually = sessionStartedManually
        let capturedExceededSupportedDepth = activeDiveExceededSupportedDepth
        exitGPS = gpsManager.currentBestPoint()
        let capturedExitGPS = exitGPS
        let capturedExitGPSFixSource: GPSFixSource = capturedExitGPS == nil ? .noFix : .fallback
        isDiveActive = false
        isFinalizingDive = true
        isManualLifecycleActive = false
        hasObservedSubmersionDuringCurrentDive = false
        deactivateMissionModeOnDiveEnd()
        HapticService.shared.criticalConfirm()
        runtimeTimer?.invalidate()
        runtimeTimer = nil
        resetDiveReminderRuntime()
        stopAllBlinking()
        ascentHaptics.clear()
        runtimeClock.clear()
        let capturedFullComputerLogbook = captureFullComputerLogbookMetadata()
        stopFullComputerRuntime()
        isDepthDataStale = false
        depthDataUsesLastKnownReading = false
        let end = Date()
        let finishedSamples = sanitizedSamples(samples)
        persistPendingFinalizationDraft(
            sessionID: sessionID,
            start: start,
            end: end,
            samples: finishedSamples,
            entryGPS: capturedEntryGPS,
            exitGPS: capturedExitGPS,
            entryGPSFixSource: capturedEntryGPSFixSource,
            exitGPSFixSource: capturedExitGPSFixSource,
            sessionStartedManually: capturedSessionStartedManually,
            activeDiveExceededSupportedDepth: capturedExceededSupportedDepth,
            fullComputerLogbookMetadata: capturedFullComputerLogbook
        )
        sessionStart = nil
        activeDiveSessionID = nil
        samples = []
        previousDepthSample = nil
        entryGPS = nil
        depthValidationState.reset()
        gpsManager.captureBestEffortPoint(for: 6) { [weak self] point in
            guard let self else { return }
            self.isFinalizingDive = false
            let finalExitGPS = point ?? capturedExitGPS
            self.exitGPS = finalExitGPS
            self.exitGPSFixSource = point != nil ? .fix : (capturedExitGPS == nil ? .noFix : .fallback)
            self.showGPSConfirmation(.end(point: finalExitGPS, fallback: point == nil && capturedExitGPS != nil))
            self.finalizeDive(
                sessionID: sessionID,
                start: start,
                end: end,
                entryGPS: capturedEntryGPS,
                exitGPS: finalExitGPS,
                entryGPSFixSource: capturedEntryGPSFixSource,
                exitGPSFixSource: self.exitGPSFixSource,
                samples: finishedSamples,
                activeDiveExceededSupportedDepth: capturedExceededSupportedDepth,
                sessionStartedManually: capturedSessionStartedManually,
                watchActivityMode: self.sessionActivityMode.rawValue,
                watchDivingMode: self.sessionDivingMode.rawValue,
                fullComputerLogbookMetadata: capturedFullComputerLogbook
            )
            self.gpsManager.stop()
        }
    }

    private func finalizeDive(
        sessionID: UUID,
        start: Date,
        end: Date,
        entryGPS: GPSPoint?,
        exitGPS: GPSPoint?,
        entryGPSFixSource: GPSFixSource,
        exitGPSFixSource: GPSFixSource,
        samples: [DiveSample],
        activeDiveExceededSupportedDepth: Bool,
        sessionStartedManually: Bool,
        watchActivityMode: String? = nil,
        watchDivingMode: String? = nil,
        fullComputerLogbookMetadata: FullComputerDiveLogbookMetadata? = nil
    ) {
        if logStore.sessions.contains(where: { $0.id == sessionID }) {
            clearActiveDiveDraft()
            self.activeDiveExceededSupportedDepth = false
            self.sessionStartedManually = false
            return
        }
        let validSamples = sanitizedSamples(samples)
        let depths = validSamples.map(\.depthMeters)
        let temps = validSamples.compactMap { DiveAlgorithm.sanitizedTemperatureCelsius($0.temperatureCelsius) }
        let avgDepth = DiveAlgorithm.timeWeightedAverageDepth(samples: validSamples, endDate: end)
        let maxDepth = depths.max() ?? 0
        let avgTemp = temps.isEmpty ? nil : temps.reduce(0, +) / Double(temps.count)
        let duration = max(0, end.timeIntervalSince(start))
        let exceeded = activeDiveExceededSupportedDepth || maxDepth >= DepthSafetyConfiguration.maximumSupportedDepthMeters
        let hasDepthProfile = !validSamples.isEmpty
        let session = DiveSession(
            id: sessionID,
            startDate: start,
            endDate: end,
            durationSeconds: duration,
            maxDepthMeters: maxDepth,
            avgDepthMeters: avgDepth,
            avgWaterTemperatureCelsius: avgTemp,
            minWaterTemperatureCelsius: temps.min(),
            maxWaterTemperatureCelsius: temps.max(),
            ttv: DiveAlgorithm.ttvIndex(averageDepthMeters: avgDepth, durationSeconds: duration),
            entryGPS: entryGPS,
            exitGPS: exitGPS,
            entryGPSFixSource: entryGPSFixSource,
            exitGPSFixSource: exitGPSFixSource,
            samples: validSamples,
            exceededSupportedDepthRange: exceeded,
            isManual: sessionStartedManually,
            hasDepthProfile: hasDepthProfile,
            watchActivityMode: watchActivityMode ?? sessionActivityMode.rawValue,
            watchDivingMode: watchDivingMode ?? sessionDivingMode.rawValue,
            fullComputerLogbookMetadata: fullComputerLogbookMetadata
        )
        self.activeDiveExceededSupportedDepth = false
        self.sessionStartedManually = false
        isFullComputerRecoveryActive = false
        fullComputerLogbookAccumulator = nil
        logStore.add(session)
        clearActiveDiveDraft()
    }

    private func processDepthMeasurement(
        rawDepthMeters: Double?,
        timestamp: Date = Date(),
        receivedAt: Date? = nil,
        temperatureCelsius: Double?
    ) {
        let validated = depthValidationState.validate(
            rawDepthMeters: rawDepthMeters,
            timestamp: timestamp,
            receivedAt: receivedAt ?? Date(),
            temperatureCelsius: temperatureCelsius,
            isDiveActive: isDiveActive,
            exemptMockSurfaceFrozenSamples: isSimulationDepthActive
        )
        guard let sample = validated.sample else {
            lastErrorMessage = depthValidationMessage(validated.validity)
            return
        }

        var sampleAddedInPreDiveBranch = false
        if !isDiveActive {
            currentDepthMeters = sample.depthMeters
            currentTemperatureCelsius = resolvedTemperatureForDepthSample(sample.temperatureCelsius, at: sample.timestamp)
            if evaluateLifecycle(with: validated) == .startDive {
                beginDiveIfNeeded(isManual: false, sessionStart: sample.timestamp)
                addSample(
                    depthMeters: sample.depthMeters,
                    timestamp: sample.timestamp,
                    temperatureCelsius: resolvedTemperatureForDepthSample(sample.temperatureCelsius, at: sample.timestamp)
                )
                sampleAddedInPreDiveBranch = true
            }
        } else if isManualLifecycleActive,
                  sample.depthMeters > DiveAlgorithmConfiguration.automaticStartDepthMeters {
            hasObservedSubmersionDuringCurrentDive = true
            manualStartHandedOffToAutomatic = true
            isManualLifecycleActive = false
        }

        guard DiveDepthMeasurementIngestion.shouldInvokeAddSampleAfterPreDiveBranch(
            sampleAddedInPreDiveBranch: sampleAddedInPreDiveBranch
        ) else { return }

        addSample(
            depthMeters: sample.depthMeters,
            timestamp: sample.timestamp,
            temperatureCelsius: resolvedTemperatureForDepthSample(temperatureCelsius, at: sample.timestamp)
        )
    }

    private func depthValidationMessage(_ validity: DepthSampleValidity) -> String {
        switch validity {
        case .valid:
            return ""
        case .missing:
            return String(localized: "watch.depth_validation.missing_sample")
        case .stale:
            return String(localized: "watch.depth_validation.stale_sample")
        case .frozen:
            return String(localized: "watch.depth_validation.stuck_sensor")
        case .spikeRejected:
            return String(localized: "watch.depth_validation.implausible_change")
        case .nonFinite:
            return String(localized: "watch.depth_validation.non_finite")
        case .outOfRange:
            return String(localized: "watch.depth_validation.out_of_range")
        }
    }

    private func addSample(depthMeters: Double, timestamp: Date = Date(), temperatureCelsius: Double?) {
        guard isDiveActive else { return }
        let sample = DiveSample(timestamp: timestamp, depthMeters: depthMeters, temperatureCelsius: temperatureCelsius)
        guard DiveAlgorithm.isPlausibleDepthTransition(from: previousDepthSample, to: sample) else {
            lastErrorMessage = String(localized: "watch.depth_validation.implausible_change")
            return
        }

        let resolvedTemperature = resolvedTemperatureForDepthSample(temperatureCelsius, at: timestamp)
        let storedSample = DiveSample(
            timestamp: timestamp,
            depthMeters: depthMeters,
            temperatureCelsius: resolvedTemperature
        )
        currentDepthMeters = storedSample.depthMeters
        currentTemperatureCelsius = resolvedTemperature
        lastErrorMessage = nil
        lastAcceptedDepthSampleAt = timestamp
        isDepthDataStale = false
        depthDataUsesLastKnownReading = false
        samples.append(storedSample)
        averageDepthMeters = DiveAlgorithm.timeWeightedAverageDepth(samples: samples, endDate: sample.timestamp)
        maxDepthMeters = max(maxDepthMeters, sample.depthMeters)
        updateRuntimeFromClock(evaluateAlarms: false)
        updateDepthSafety(for: sample.depthMeters)
        if depthSafetyState != .exceeded {
            evaluateDepthAlarm()
        }
        updateAscentRate(with: storedSample)
        ingestFullComputerSample(storedSample)
        previousDepthSample = storedSample
        persistActiveDiveDraft(immediate: samples.count <= 1)
        evaluateAutomaticSurfaceCandidate(
            validatedSample: ValidatedDepthSample(validity: .valid, rawDepthMeters: depthMeters, sample: sample)
        )
    }

    private func updateDepthSafety(for depthMeters: Double) {
        let state = DepthSafetyState.from(depthMeters: depthMeters)
        depthSafetyState = state
        if state == .exceeded {
            activeDiveExceededSupportedDepth = true
            exceededSupportedDepthRange = true
        }
        let hapticsEnabled = UserDefaults.standard.object(forKey: HapticService.hapticsEnabledKey) == nil
            ? true
            : UserDefaults.standard.bool(forKey: HapticService.hapticsEnabledKey)
        depthLimitHaptics.handle(depthMeters: depthMeters, hapticsEnabled: hapticsEnabled)
    }

    private func resolvedTemperatureForDepthSample(_ temperatureCelsius: Double?, at timestamp: Date) -> Double? {
        if let lastTemperatureSampleAt {
            guard timestamp.timeIntervalSince(lastTemperatureSampleAt) <= DiveAlgorithmConfiguration.staleTemperatureSeconds else {
                return nil
            }
        }
        return DiveAlgorithm.sanitizedTemperatureCelsius(temperatureCelsius ?? currentTemperatureCelsius)
    }

    private func evaluateDepthAlarm() {
        guard !isDepthDataStale else { return }
        let threshold = depthAlarmThresholdMeters
        guard depthAlarmEnabled, maxDepthMeters > threshold, depthSafetyState != .exceeded else { return }
        let units = DIRUnitPreference.fromStorage(UserDefaults.standard.string(forKey: DIRUnitPreference.storageKey) ?? DIRUnitPreference.metric.rawValue)
        let display = WatchDepthFormatting.display(meters: threshold, units: units)
        triggerAlarm(
            String(format: String(localized: "watch.alarm.depth_exceeded_format"), "\(display.valueText) \(display.unitLabel)"),
            lastDate: &lastDepthAlarmDate,
            blinkSource: .depth
        )
    }

    private func evaluateRuntimeAlarms() {
        let runtimeThreshold = runtimeAlarmThresholdMinutes
        if runtimeAlarmEnabled, runtime > TimeInterval(runtimeThreshold * 60) {
            triggerAlarm(
                String(format: String(localized: "watch.alarm.runtime_exceeded_format"), runtimeThreshold),
                lastDate: &lastRuntimeAlarmDate,
                blinkSource: .runtime
            )
        }
        if batteryAlarmEnabled {
            let device = WKInterfaceDevice.current()
            device.isBatteryMonitoringEnabled = true
            let batteryThreshold = Float(batteryAlarmThresholdPercent) / 100
            if device.batteryLevel >= 0, device.batteryLevel < batteryThreshold {
                triggerAlarm(
                    String(format: String(localized: "watch.alarm.battery_low_format"), batteryAlarmThresholdPercent),
                    lastDate: &lastBatteryAlarmDate,
                    blinkSource: .battery
                )
            }
        }
    }

    private var shouldSuppressDiveReminders: Bool {
        LiveDiveReminderSuppressionPolicy.shouldSuppressReminders(
            bannerInput: LiveDiveBannerPresentationPolicy.Input(
                showAscentAlarmBanner: ascentAlarmEnabled && ascentStatus.isOverLimit,
                depthSafetyState: depthSafetyState,
                exceededSupportedDepthRange: exceededSupportedDepthRange,
                isDepthDataStale: isDepthDataStale,
                isManualNoDepthSession: isManualNoDepthSession,
                hapticsEnabled: UserDefaults.standard.object(forKey: HapticService.hapticsEnabledKey) == nil
                    || UserDefaults.standard.bool(forKey: HapticService.hapticsEnabledKey),
                isDepthAutomationMockFallbackActive: isDepthAutomationMockFallbackActive,
                isSimulationDepthActive: isSimulationDepthActive,
                showsAutoDiveHint: false,
                showsManualHandoffNote: false
            ),
            alarmWarningMessage: alarmWarningMessage,
            ascentAlarmEnabled: ascentAlarmEnabled,
            ascentIsOverLimit: ascentStatus.isOverLimit
        )
    }

    private func evaluateDiveReminders() {
        guard isDiveActive, diveReminderOverlay == nil else { return }
        let settings = DiveReminderSettingsStore.load()
        let runtimeMinute = Int(runtime / 60)
        let triggered = DiveReminderEngine.evaluate(
            runtimeSeconds: runtime,
            runtimeMinute: runtimeMinute,
            settings: settings,
            state: &diveReminderRuntimeState
        )
        guard !triggered.isEmpty else { return }
        guard !shouldSuppressDiveReminders else { return }
        presentDiveReminderOverlay(
            DiveReminderEngine.makeOverlay(for: triggered, runtimeMinute: runtimeMinute)
        )
    }

    func dismissDiveReminderOverlay() {
        diveReminderDismissTask?.cancel()
        diveReminderDismissTask = nil
        diveReminderOverlay = nil
    }

    private func presentDiveReminderOverlay(_ content: DiveReminderOverlayContent) {
        diveReminderDismissTask?.cancel()
        diveReminderOverlay = content
        if content.shouldHaptic {
            HapticService.shared.reminderPulseIfNeeded()
        }
        diveReminderDismissTask = Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            guard !Task.isCancelled else { return }
            self?.diveReminderOverlay = nil
        }
    }

    private func resetDiveReminderRuntime() {
        diveReminderDismissTask?.cancel()
        diveReminderDismissTask = nil
        diveReminderOverlay = nil
        diveReminderRuntimeState.reset()
    }

    private func stopStopwatch(playHaptic: Bool) {
        guard isStopwatchRunning || stopwatchTimer != nil else { return }
        updateStopwatchFromClock()
        stopwatchAccumulatedTime = stopwatchTime
        stopwatchStartedAt = nil
        stopwatchClock.clear()
        isStopwatchRunning = false
        stopwatchTimer?.invalidate()
        stopwatchTimer = nil
        persistStopwatchState()
        if playHaptic {
            HapticService.shared.confirm()
        }
    }

    private func triggerAlarm(_ message: String, lastDate: inout Date?, blinkSource: AlarmBlinkSource) {
        let now = Date()
        if let lastAlarmDismissDate, now.timeIntervalSince(lastAlarmDismissDate) < 15 { return }
        if let lastDate, now.timeIntervalSince(lastDate) < 30 { return }
        lastDate = now
        alarmWarningMessage = message
        HapticService.shared.warnIfNeeded()
        startBlinking(source: blinkSource)
    }

    private func updateAscentRate(with sample: DiveSample) {
        guard previousDepthSample != nil else {
            ascentStatus = AscentStatus.make(rate: 0, depth: sample.depthMeters, limits: ascentSettings.limits)
            return
        }
        let rate = DiveAlgorithm.ascentRateMetersPerMinute(samples: samples, current: sample)
        ascentStatus = AscentStatus.make(rate: rate, depth: sample.depthMeters, limits: ascentSettings.limits)
        if ascentStatus.isOverLimit, ascentAlarmEnabled {
            startBlinking(source: .ascent)
            ascentHaptics.update(isOverLimit: isDiveActive)
        } else {
            stopBlinking(source: .ascent)
            ascentHaptics.clear()
        }
    }

    private func startBlinking(source: AlarmBlinkSource) {
        activeBlinkSources.insert(source)
        if !alarmBlinkActive {
            alarmBlinkActive = true
        }
    }

    private func stopBlinking(source: AlarmBlinkSource) {
        activeBlinkSources.remove(source)
        reconcileBlinkTimer()
    }

    private func stopAllBlinking() {
        activeBlinkSources.removeAll()
        reconcileBlinkTimer()
    }

    private func reconcileBlinkTimer() {
        guard activeBlinkSources.isEmpty else { return }
        alarmBlinkActive = false
    }

    private func showGPSConfirmation(_ confirmation: DiveGPSConfirmation) {
        gpsConfirmation = confirmation
        HapticService.shared.confirm()
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_400_000_000)
            if self.gpsConfirmation == confirmation {
                self.gpsConfirmation = nil
            }
        }
    }

    func applyMissionModeIfNeededOnDiveStart(restored: Bool = false) {
        let shouldActivate = MissionModeLifecycle.shouldActivateRuntime(
            autoEnablePreference: missionModeAutoEnableOnDiveStart,
            manualPendingForSession: missionModeManualPendingForSession
        )
        isMissionModeActive = shouldActivate
        missionModeActivationSource = MissionModeLifecycle.activationSource(
            autoEnablePreference: missionModeAutoEnableOnDiveStart,
            manualPendingForSession: missionModeManualPendingForSession,
            restored: restored
        )
    }

    func setMissionModeActive(_ active: Bool, source: MissionModeActivationSource) {
        if active {
            if isDiveActive {
                isMissionModeActive = true
                missionModeActivationSource = source
            } else {
                missionModeManualPendingForSession = true
                isMissionModeActive = false
                missionModeActivationSource = nil
            }
        } else {
            missionModeManualPendingForSession = false
            isMissionModeActive = false
            missionModeActivationSource = nil
        }
    }

    func enableMissionModeManually() {
        setMissionModeActive(true, source: .manual)
    }

    func disableMissionModeManually() {
        setMissionModeActive(false, source: .manual)
    }

    func deactivateMissionModeOnDiveEnd() {
        isMissionModeActive = false
        missionModeManualPendingForSession = false
        missionModeActivationSource = nil
    }

    // MARK: - Full Computer runtime

    private var isFullComputerDiveActive: Bool {
        isDiveActive && sessionDivingMode == .fullComputer
    }

    private func startFullComputerRuntimeIfNeeded(sessionStart: Date) {
        guard sessionDivingMode == .fullComputer else {
            stopFullComputerRuntime()
            return
        }
        let readiness = FullComputerRuntimeEngine.canStart(plan: FullComputerPrediveConfigurationStore.shared.runtimePlan())
        guard readiness.ready else {
            fullComputerEngine = nil
            fullComputerSnapshot = unavailableFullComputerSnapshot(diagnostics: readiness.diagnostics)
            return
        }
        do {
            let plan = FullComputerPrediveConfigurationStore.shared.runtimePlan()
            var engine = try FullComputerRuntimeEngine(plan: plan, sessionStart: sessionStart)
            engine.tick(now: sessionStart)
            fullComputerEngine = engine
            fullComputerSnapshot = engine.snapshot
            fullComputerLogbookAccumulator = FullComputerRuntimeLogbookAccumulator()
            isFullComputerRecoveryActive = false
            updateFullComputerLogbookAccumulator(from: engine)
        } catch FullComputerRuntimeStartupFailure.invalidPlan(let diagnostics) {
            fullComputerEngine = nil
            fullComputerSnapshot = unavailableFullComputerSnapshot(diagnostics: diagnostics)
        } catch {
            fullComputerEngine = nil
            fullComputerSnapshot = unavailableFullComputerSnapshot(diagnostics: ["startup_failed"])
        }
    }

    private func restoreFullComputerRuntimeIfNeeded(
        samples: [DiveSample],
        sessionStart: Date,
        sessionID: UUID,
        gasSwitchTracker: FullComputerGasSwitchTracker? = nil,
        checkpoint: FullComputerRuntimeCheckpoint? = nil
    ) {
        guard sessionDivingMode == .fullComputer else {
            stopFullComputerRuntime()
            return
        }

        let lastDepth = samples.last?.depthMeters ?? 0
        if let checkpoint {
            do {
                try FullComputerRuntimeCheckpointCodec.validate(checkpoint)
                guard checkpoint.payload.sessionID == sessionID else {
                    throw FullComputerRuntimeCheckpointError.sessionMismatch
                }
                var engine = try FullComputerRuntimeEngine.restoreEngine(from: checkpoint, sessionStart: sessionStart)
                let diagnostics = engine.recoverySelfCheckDiagnostics(lastKnownDepthMeters: lastDepth)
                if diagnostics.isEmpty {
                    engine.applyConservativeCatchUp(now: Date())
                    engine.replaySamplesAfterCheckpoint(
                        samples,
                        checkpointTimestamp: checkpoint.payload.lastSampleTimestamp
                    )
                    engine.tick(now: Date())
                    fullComputerEngine = engine
                    fullComputerSnapshot = engine.snapshot
                    updateFullComputerLogbookAccumulator(from: engine)
                    return
                }
                quarantineCorruptCheckpoint(checkpoint, reason: "self_check_failed:\(diagnostics.joined(separator: ","))")
            } catch {
                quarantineCorruptCheckpoint(checkpoint, reason: "checkpoint_restore_failed:\(error)")
            }
        }

        startFullComputerRuntimeIfNeeded(sessionStart: sessionStart)
        guard var engine = fullComputerEngine else { return }
        engine.replaySamples(samples)
        if let gasSwitchTracker {
            engine.restoreGasSwitchTracker(gasSwitchTracker)
        }
        engine.applyConservativeCatchUp(now: Date())
        engine.tick(now: Date())
        fullComputerEngine = engine
        fullComputerSnapshot = engine.snapshot
        updateFullComputerLogbookAccumulator(from: engine)
    }

    private func quarantineCorruptCheckpoint(_ checkpoint: FullComputerRuntimeCheckpoint, reason: String) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(checkpoint) else { return }
        quarantineActiveDraftPayload(data, reason: reason)
        draftRecoveryDiagnostic = String(localized: "watch.full_computer.recovery_checkpoint_quarantined")
    }

    private func captureFullComputerLogbookMetadata() -> FullComputerDiveLogbookMetadata? {
        guard sessionDivingMode == .fullComputer, let engine = fullComputerEngine else { return nil }
        return currentFullComputerLogbookMetadata(engine: engine)
    }

    private func currentFullComputerLogbookMetadata(engine: FullComputerRuntimeEngine? = nil) -> FullComputerDiveLogbookMetadata? {
        guard sessionDivingMode == .fullComputer else { return nil }
        let resolvedEngine = engine ?? fullComputerEngine
        guard let resolvedEngine else { return nil }
        updateFullComputerLogbookAccumulator(from: resolvedEngine)
        let accumulator = fullComputerLogbookAccumulator ?? FullComputerRuntimeLogbookAccumulator()
        return accumulator.export(
            watchDivingMode: sessionDivingMode.rawValue,
            gfLow: resolvedEngine.runtimePlan.gfLow,
            gfHigh: resolvedEngine.runtimePlan.gfHigh,
            gasSwitchEvents: resolvedEngine.gasSwitchAuditTrail.map(Self.logbookGasSwitchEvent(from:)),
            unavailableGasMixIds: Array(resolvedEngine.persistedGasSwitchTracker.unavailableGasMixIds),
            algorithmVersion: FullComputerRuntimeConfiguration.algorithmVersion
        )
    }

    private static func logbookGasSwitchEvent(from event: FullComputerGasSwitchAuditEvent) -> FullComputerLogbookGasSwitchEvent {
        FullComputerLogbookGasSwitchEvent(
            id: event.id,
            timestamp: event.timestamp,
            kind: FullComputerLogbookGasSwitchKind(rawValue: event.kind.rawValue) ?? .offPlan,
            depthMeters: event.depthMeters,
            fromGasMixId: event.fromGasMixId,
            toGasMixId: event.toGasMixId,
            note: event.note
        )
    }

    private func updateFullComputerLogbookAccumulator(from engine: FullComputerRuntimeEngine) {
        var working = fullComputerLogbookAccumulator ?? FullComputerRuntimeLogbookAccumulator()
        working.ingest(snapshot: engine.snapshot, gasSwitchTracker: engine.persistedGasSwitchTracker)
        fullComputerLogbookAccumulator = working
    }

    func confirmFullComputerGasSwitch(gasMixId: UUID) {
        guard var engine = fullComputerEngine else { return }
        guard engine.confirmGasSwitch(to: gasMixId, at: Date()) else { return }
        HapticService.shared.confirm()
        fullComputerEngine = engine
        fullComputerSnapshot = engine.snapshot
        persistActiveDiveDraft()
    }

    func ignoreFullComputerGasSwitch(gasMixId: UUID) {
        guard var engine = fullComputerEngine else { return }
        engine.ignoreSuggestedGasSwitch(gasMixId: gasMixId, at: Date())
        HapticService.shared.notify()
        fullComputerEngine = engine
        fullComputerSnapshot = engine.snapshot
        persistActiveDiveDraft()
    }

    func dismissFullComputerMissedGasSwitch() {
        guard var engine = fullComputerEngine else { return }
        engine.dismissMissedGasSwitchPrompt()
        fullComputerEngine = engine
        fullComputerSnapshot = engine.snapshot
    }

    func markFullComputerGasUnavailable(gasMixId: UUID) {
        guard var engine = fullComputerEngine else { return }
        engine.markGasUnavailable(gasMixId: gasMixId, at: Date())
        HapticService.shared.warnIfNeeded()
        fullComputerEngine = engine
        fullComputerSnapshot = engine.snapshot
        persistActiveDiveDraft()
    }

    private func stopFullComputerRuntime() {
        fullComputerEngine = nil
        fullComputerSnapshot = nil
    }

    private func ingestFullComputerSample(_ sample: DiveSample) {
        guard isFullComputerDiveActive else { return }
        guard var engine = fullComputerEngine else { return }
        if !engine.ingestSample(depthMeters: sample.depthMeters, timestamp: sample.timestamp) {
            engine.tick(now: sample.timestamp)
        }
        fullComputerEngine = engine
        fullComputerSnapshot = engine.snapshot
        updateFullComputerLogbookAccumulator(from: engine)
    }

    private func tickFullComputerRuntimeIfNeeded(now: Date = Date()) {
        guard isFullComputerDiveActive, var engine = fullComputerEngine else { return }
        engine.tick(now: now)
        fullComputerEngine = engine
        fullComputerSnapshot = engine.snapshot
        updateFullComputerLogbookAccumulator(from: engine)
    }

    private func unavailableFullComputerSnapshot(diagnostics: [String]) -> FullComputerRuntimeSnapshot {
        let plan = FullComputerRuntimePlan.defaultAirGF3070
        let tissue = BuhlmannTissueState.airSaturated(surfacePressureBar: plan.plannerEnvironment.surfacePressureBar)
        return FullComputerRuntimeSnapshot(
            engineState: .unavailable,
            tissueState: tissue,
            activeGas: plan.activeGas,
            gfLow: plan.gfLow,
            gfHigh: plan.gfHigh,
            monotonicElapsedSeconds: 0,
            lastSampleTimestamp: nil,
            depthMeters: 0,
            ambientPressureBar: plan.plannerEnvironment.surfacePressureBar,
            ndlMinutes: nil,
            rawCeilingMeters: 0,
            operationalCeilingMeters: 0,
            controllingCompartmentRaw: 0,
            controllingCompartmentOperational: 0,
            ttsMinutes: 0,
            stops: [],
            modelState: .unavailable,
            diagnostics: diagnostics,
            decoPresentation: FullComputerDecoPresentation(
                mode: .noDecompression,
                immersionAccent: .diving,
                immersionStatusKey: "live.status.in_dive",
                ndlDisplayMinutes: nil,
                ndlAccent: nil,
                ttsMinutes: 0,
                runtimeMinutes: 0,
                ceilingMetersExact: 0,
                ceilingMetersRounded: 0,
                nextStopDepthMeters: nil,
                nextStopMinutes: nil,
                remainingStopCount: 0,
                ceilingViolation: false,
                ascentAllowedBetweenStops: false,
                showDecoStopPanel: false,
                showCeilingViolationBanner: false,
                usedConservativeFallback: true,
                diagnostics: diagnostics,
                stopState: nil,
                stopDirection: .none,
                stopPanelAccent: .green,
                stopPanelTitleKey: "",
                stopInstructionKey: nil,
                stopRemainingSeconds: nil,
                activeGasLabel: plan.activeGas.name,
                showDecoProgressPanel: false,
                hideManualStopwatch: false,
                timerAccruing: false
            ),
            gasSwitchSurface: .none,
            runtimeGasRows: [],
            gasSwitchAuditEvents: []
        )
    }
}

// MARK: - Algorithm test hooks (Watch algorithm test target, @testable)

extension DiveManager {
    static var testHook_draftDirectoryURL: URL?
    static var testHook_suppressDepthSensorProvider = false
    static var testHook_automaticStopDwellSeconds: TimeInterval?
    static var testHook_activeDraftWriteCount = 0

    var testHook_sampleCount: Int { samples.count }

    var testHook_sessions: [DiveSession] { logStore.sessions }

    var testHook_isFinalizingDive: Bool { isFinalizingDive }

    var testHook_hasActiveDiveDraftOnDisk: Bool {
        FileManager.default.fileExists(atPath: activeDiveDraftURL().path)
    }

    func testHook_clearActiveDiveDraft() {
        clearActiveDiveDraft()
    }

    func testHook_restoreActiveDiveDraftIfAvailable() {
        restoreActiveDiveDraftIfAvailable()
    }

    func testHook_completePendingFinalizationIfNeeded() {
        restoreActiveDiveDraftIfAvailable()
    }

    var testHook_samples: [DiveSample] { samples }

    var testHook_lastErrorMessage: String? { lastErrorMessage }

    var testHook_isDepthDataStale: Bool { isDepthDataStale }

    func testHook_endDiveForTests() {
        endDiveIfNeeded()
    }

    func testHook_simulateManualToAutomaticHandoffForTests() {
        guard isDiveActive else { return }
        hasObservedSubmersionDuringCurrentDive = true
        if isManualLifecycleActive {
            manualStartHandedOffToAutomatic = true
            isManualLifecycleActive = false
        }
    }

    func testHook_processDepthMeasurement(
        rawDepthMeters: Double?,
        timestamp: Date = Date(),
        temperatureCelsius: Double? = nil
    ) {
        processDepthMeasurement(
            rawDepthMeters: rawDepthMeters,
            timestamp: timestamp,
            receivedAt: timestamp,
            temperatureCelsius: temperatureCelsius
        )
    }

    func testHook_setDepthAutomationAvailableForTests(_ available: Bool) {
        isDepthAutomationAvailable = available
    }

    func testHook_setCurrentTemperatureForTests(_ celsius: Double?, receivedAt: Date = Date()) {
        currentTemperatureCelsius = DiveAlgorithm.sanitizedTemperatureCelsius(celsius)
        lastTemperatureSampleAt = celsius == nil ? nil : receivedAt
    }

    func testHook_evaluateDepthCallbackFreshness(at date: Date) {
        evaluateDepthCallbackFreshness(now: date)
    }

    func testHook_stopDepthSensorForTests() {
        depthSensorProvider?.stop()
        depthSensorProvider = nil
    }

    func testHook_shutdownTimersForTests() {
        runtimeTimer?.invalidate()
        runtimeTimer = nil
        stopwatchTimer?.invalidate()
        stopwatchTimer = nil
        alarmBlinkActive = false
        automaticSurfaceEndTask?.cancel()
        automaticSurfaceEndTask = nil
        diveReminderDismissTask?.cancel()
        diveReminderDismissTask = nil
    }

    func testHook_setRuntimeForTests(_ seconds: TimeInterval) {
        runtime = seconds
        lastReportedRuntime = seconds
    }

    func testHook_evaluateDiveRemindersForTests() {
        evaluateDiveReminders()
    }

    func testHook_evaluateDepthAlarmForTests() {
        evaluateDepthAlarm()
    }

    var testHook_alarmWarningMessage: String? { alarmWarningMessage }

    var testHook_diveReminderRuntimeState: DiveReminderRuntimeState {
        diveReminderRuntimeState
    }
}
