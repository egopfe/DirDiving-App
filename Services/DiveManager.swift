import Foundation
import Combine
import CoreMotion
import WatchKit

enum DiveGPSConfirmation: Equatable {
    case start(point: GPSPoint?, fallback: Bool)
    case end(point: GPSPoint?, fallback: Bool)
}

@MainActor
final class DiveManager: NSObject, ObservableObject {
    static private(set) weak var shared: DiveManager?

    private struct ActiveDiveDraft: Codable {
        let startDate: Date
        let samples: [DiveSample]
        let entryGPS: GPSPoint?
        let entryGPSFixSource: GPSFixSource
        let isManualLifecycleActive: Bool
        let activeDiveExceededSupportedDepth: Bool
        let hasObservedSubmersionDuringCurrentDive: Bool
        let createdAt: Date
        let updatedAt: Date
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
    @Published var redWarningBlink = false
    @Published var lastErrorMessage: String?
    @Published var alarmWarningMessage: String?
    @Published var gpsConfirmation: DiveGPSConfirmation?
    @Published var isDepthAutomationAvailable = CMWaterSubmersionManager.waterSubmersionAvailable
    @Published var isManualLifecycleActive = false
    @Published private(set) var isMissionModeActive = false
    @Published private(set) var depthSafetyState: DepthSafetyState = .normal
    @Published private(set) var exceededSupportedDepthRange = false

    private let depthLimitHaptics = DepthLimitHapticCoordinator()

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
    private var submersionManager: CMWaterSubmersionManager?
    private var runtimeTimer: Timer?
    private var stopwatchTimer: Timer?
    private var blinkTimer: Timer?
    private var settingsCancellable: AnyCancellable?
    private var sessionStart: Date?
    private var samples: [DiveSample] = []
    private var entryGPS: GPSPoint?
    private var exitGPS: GPSPoint?
    private var entryGPSFixSource: GPSFixSource = .noFix
    private var exitGPSFixSource: GPSFixSource = .noFix
    private var previousDepthSample: DiveSample?
    private var isFinalizingDive = false
    private var lastDepthAlarmDate: Date?
    private var lastRuntimeAlarmDate: Date?
    private var lastBatteryAlarmDate: Date?
    private var lastAlarmDismissDate: Date?
    private var activeDiveExceededSupportedDepth = false
    private var hasObservedSubmersionDuringCurrentDive = false
    private var automaticStartCandidateCount = 0
    private var automaticStartCandidateDate: Date?
    private var automaticSurfaceCandidateDate: Date?
    private var automaticSurfaceEndTask: Task<Void, Never>?
    private var stopwatchAccumulatedTime: TimeInterval = 0
    private var stopwatchStartedAt: Date?

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

    init(logStore: DiveLogStore, gpsManager: GPSManager, ascentSettings: AscentRateSettingsStore) {
        self.logStore = logStore
        self.gpsManager = gpsManager
        self.ascentSettings = ascentSettings
        super.init()
        Self.shared = self
        settingsCancellable = ascentSettings.$limits.sink { [weak self] limits in
            Task { @MainActor in
                guard let self else { return }
                self.ascentStatus = AscentStatus.make(
                    rate: self.ascentStatus.currentRateMetersPerMinute,
                    depth: self.currentDepthMeters,
                    limits: limits
                )
            }
        }
        loadStopwatchState()
        configureSubmersion()
        restoreActiveDiveDraftIfAvailable()
    }

    private func configureSubmersion() {
        guard CMWaterSubmersionManager.waterSubmersionAvailable else {
            isDepthAutomationAvailable = false
            lastErrorMessage = String(localized: "Sensore immersione non disponibile su questo dispositivo o simulatore.")
            return
        }
        isDepthAutomationAvailable = true
        let manager = CMWaterSubmersionManager()
        manager.delegate = self
        submersionManager = manager
    }

    private func activeDiveDraftURL() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(activeDiveDraftFileName)
    }

    private func sanitizedSamples(_ source: [DiveSample]) -> [DiveSample] {
        DiveAlgorithm.sanitizedSamples(source)
    }

    private func persistActiveDiveDraft() {
        guard isDiveActive, let start = sessionStart else { return }
        let now = Date()
        let draft = ActiveDiveDraft(
            startDate: start,
            samples: sanitizedSamples(samples),
            entryGPS: entryGPS,
            entryGPSFixSource: entryGPSFixSource,
            isManualLifecycleActive: isManualLifecycleActive,
            activeDiveExceededSupportedDepth: activeDiveExceededSupportedDepth,
            hasObservedSubmersionDuringCurrentDive: hasObservedSubmersionDuringCurrentDive,
            createdAt: start,
            updatedAt: now
        )
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(draft) else { return }
        try? data.write(to: activeDiveDraftURL(), options: [.atomic, .completeFileProtection])
    }

    private func clearActiveDiveDraft() {
        try? FileManager.default.removeItem(at: activeDiveDraftURL())
    }

    private func restoreActiveDiveDraftIfAvailable() {
        let url = activeDiveDraftURL()
        guard let data = try? Data(contentsOf: url) else { return }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let draft = try? decoder.decode(ActiveDiveDraft.self, from: data) else {
            clearActiveDiveDraft()
            return
        }
        guard Date().timeIntervalSince(draft.updatedAt) <= DiveAlgorithmConfiguration.activeDiveDraftExpirationSeconds else {
            clearActiveDiveDraft()
            return
        }

        let restoredSamples = sanitizedSamples(draft.samples)
        sessionStart = draft.startDate
        samples = restoredSamples
        previousDepthSample = restoredSamples.last
        entryGPS = draft.entryGPS
        entryGPSFixSource = draft.entryGPSFixSource
        isDiveActive = true
        isManualLifecycleActive = draft.isManualLifecycleActive
        activeDiveExceededSupportedDepth = draft.activeDiveExceededSupportedDepth
        exceededSupportedDepthRange = draft.activeDiveExceededSupportedDepth
        hasObservedSubmersionDuringCurrentDive = draft.hasObservedSubmersionDuringCurrentDive

        if let lastSample = restoredSamples.last {
            currentDepthMeters = lastSample.depthMeters
            currentTemperatureCelsius = lastSample.temperatureCelsius
            maxDepthMeters = restoredSamples.map(\.depthMeters).max() ?? 0
            averageDepthMeters = DiveAlgorithm.timeWeightedAverageDepth(samples: restoredSamples, endDate: Date())
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
        updateRuntimeFromClock(evaluateAlarms: false)
        gpsManager.start()
        startRuntimeTimer()
    }

    private func resetAutomaticLifecycleCandidates() {
        automaticStartCandidateCount = 0
        automaticStartCandidateDate = nil
        automaticSurfaceCandidateDate = nil
        automaticSurfaceEndTask?.cancel()
        automaticSurfaceEndTask = nil
    }

    private func evaluateAutomaticStartCandidate(depthMeters: Double, timestamp: Date) -> Bool {
        guard depthMeters > DiveAlgorithmConfiguration.automaticStartDepthMeters else {
            automaticStartCandidateCount = 0
            automaticStartCandidateDate = nil
            return false
        }

        if let candidateDate = automaticStartCandidateDate,
           timestamp.timeIntervalSince(candidateDate) > DiveAlgorithmConfiguration.staleDepthSampleSeconds {
            automaticStartCandidateCount = 0
            automaticStartCandidateDate = nil
        }

        if automaticStartCandidateDate == nil {
            automaticStartCandidateDate = timestamp
        }
        automaticStartCandidateCount += 1
        return automaticStartCandidateCount >= DiveAlgorithmConfiguration.automaticStartRequiredSamples
    }

    private func evaluateAutomaticSurfaceCandidate(depthMeters: Double, timestamp: Date) {
        guard isDiveActive, !isFinalizingDive else { return }
        guard !isManualLifecycleActive || hasObservedSubmersionDuringCurrentDive else { return }

        if depthMeters <= DiveAlgorithmConfiguration.automaticStopDepthMeters {
            if automaticSurfaceCandidateDate == nil {
                automaticSurfaceCandidateDate = timestamp
            }
            scheduleAutomaticSurfaceEnd()
        } else {
            cancelAutomaticSurfaceEnd()
        }
    }

    private func scheduleAutomaticSurfaceEnd() {
        guard automaticSurfaceEndTask == nil else { return }
        automaticSurfaceEndTask = Task { [weak self] in
            let nanoseconds = UInt64(DiveAlgorithmConfiguration.automaticStopDwellSeconds * 1_000_000_000)
            try? await Task.sleep(nanoseconds: nanoseconds)
            guard !Task.isCancelled else { return }
            await MainActor.run {
                guard let self else { return }
                self.automaticSurfaceEndTask = nil
                guard let candidateDate = self.automaticSurfaceCandidateDate else { return }
                guard self.isDiveActive, !self.isFinalizingDive else { return }
                let dwell = Date().timeIntervalSince(candidateDate)
                guard dwell >= DiveAlgorithmConfiguration.automaticStopDwellSeconds else { return }
                let lastDepthTimestamp = self.previousDepthSample?.timestamp ?? .distantPast
                let noDepthSampleAfterSurfaceEvent = lastDepthTimestamp <= candidateDate
                guard self.currentDepthMeters <= DiveAlgorithmConfiguration.automaticStopDepthMeters
                    || noDepthSampleAfterSurfaceEvent else { return }
                self.endDiveIfNeeded()
            }
        }
    }

    private func cancelAutomaticSurfaceEnd() {
        automaticSurfaceCandidateDate = nil
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
        guard let start = sessionStart else { return }
        runtime = max(0, Date().timeIntervalSince(start))
        ttv = DiveAlgorithm.ttvIndex(averageDepthMeters: averageDepthMeters, durationSeconds: runtime)
        if evaluateAlarms {
            evaluateRuntimeAlarms()
        }
    }

    private func loadStopwatchState() {
        stopwatchAccumulatedTime = max(0, UserDefaults.standard.double(forKey: stopwatchAccumulatedKey))
        if UserDefaults.standard.bool(forKey: stopwatchRunningKey) {
            stopwatchStartedAt = UserDefaults.standard.object(forKey: stopwatchStartedAtKey) as? Date ?? Date()
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
        guard isStopwatchRunning, let startedAt = stopwatchStartedAt else {
            stopwatchTime = stopwatchAccumulatedTime
            return
        }
        stopwatchTime = max(0, stopwatchAccumulatedTime + Date().timeIntervalSince(startedAt))
    }

    func startStopwatch() {
        guard !isStopwatchRunning else { return }
        stopwatchStartedAt = Date()
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
        guard isManualLifecycleActive else { return }
        endDiveIfNeeded(isManual: true)
    }

    func dismissAlarmWarning() {
        guard alarmWarningMessage != nil else { return }
        alarmWarningMessage = nil
        lastAlarmDismissDate = Date()
        stopBlinking()
        HapticService.shared.notify()
    }

    private func beginDiveIfNeeded(isManual: Bool = false) {
        guard !isDiveActive, !isFinalizingDive else { return }
        resetAutomaticLifecycleCandidates()
        gpsManager.start()
        isDiveActive = true
        isManualLifecycleActive = isManual
        hasObservedSubmersionDuringCurrentDive = !isManual
        applyMissionModeIfNeededOnDiveStart()
        HapticService.shared.criticalConfirm()
        alarmWarningMessage = nil
        sessionStart = Date()
        entryGPS = gpsManager.currentBestPoint()
        let capturedAtStart = entryGPS
        entryGPSFixSource = capturedAtStart == nil ? .noFix : .fallback
        gpsManager.captureBestEffortPoint(for: 6) { [weak self] point in
            guard let self, self.isDiveActive, !self.isFinalizingDive else { return }
            self.entryGPS = point ?? capturedAtStart
            self.entryGPSFixSource = point != nil ? .fix : (capturedAtStart == nil ? .noFix : .fallback)
            self.showGPSConfirmation(.start(point: self.entryGPS, fallback: point == nil && capturedAtStart != nil))
            self.persistActiveDiveDraft()
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
        persistActiveDiveDraft()
        startRuntimeTimer()
    }

    private func endDiveIfNeeded(isManual: Bool = false) {
        guard isDiveActive, let start = sessionStart, !isFinalizingDive else { return }
        cancelAutomaticSurfaceEnd()
        updateRuntimeFromClock(evaluateAlarms: false)
        let capturedEntryGPS = entryGPS
        let capturedEntryGPSFixSource = entryGPSFixSource
        exitGPS = gpsManager.currentBestPoint()
        let capturedExitGPS = exitGPS
        exitGPSFixSource = capturedExitGPS == nil ? .noFix : .fallback
        isDiveActive = false
        isFinalizingDive = true
        isManualLifecycleActive = false
        hasObservedSubmersionDuringCurrentDive = false
        deactivateMissionModeOnDiveEnd()
        HapticService.shared.criticalConfirm()
        runtimeTimer?.invalidate()
        runtimeTimer = nil
        stopBlinking()
        let end = Date()
        let finishedSamples = sanitizedSamples(samples)
        sessionStart = nil
        samples = []
        previousDepthSample = nil
        entryGPS = nil
        gpsManager.captureBestEffortPoint(for: 6) { [weak self] point in
            guard let self else { return }
            self.isFinalizingDive = false
            let finalExitGPS = point ?? capturedExitGPS
            self.exitGPS = finalExitGPS
            self.exitGPSFixSource = point != nil ? .fix : (capturedExitGPS == nil ? .noFix : .fallback)
            self.showGPSConfirmation(.end(point: finalExitGPS, fallback: point == nil && capturedExitGPS != nil))
            self.finalizeDive(start: start, end: end, entryGPS: capturedEntryGPS, exitGPS: finalExitGPS, entryGPSFixSource: capturedEntryGPSFixSource, exitGPSFixSource: self.exitGPSFixSource, samples: finishedSamples)
            self.gpsManager.stop()
        }
    }

    private func finalizeDive(start: Date, end: Date, entryGPS: GPSPoint?, exitGPS: GPSPoint?, entryGPSFixSource: GPSFixSource, exitGPSFixSource: GPSFixSource, samples: [DiveSample]) {
        let validSamples = sanitizedSamples(samples)
        let depths = validSamples.map(\.depthMeters)
        let temps = validSamples.compactMap { DiveAlgorithm.sanitizedTemperatureCelsius($0.temperatureCelsius) }
        let avgDepth = DiveAlgorithm.timeWeightedAverageDepth(samples: validSamples, endDate: end)
        let maxDepth = depths.max() ?? 0
        let avgTemp = temps.isEmpty ? nil : temps.reduce(0, +) / Double(temps.count)
        let duration = max(0, end.timeIntervalSince(start))
        let exceeded = activeDiveExceededSupportedDepth || maxDepth >= DepthSafetyConfiguration.maximumSupportedDepthMeters
        let session = DiveSession(
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
            exceededSupportedDepthRange: exceeded
        )
        activeDiveExceededSupportedDepth = false
        logStore.add(session)
        clearActiveDiveDraft()
    }

    private func processDepthMeasurement(rawDepthMeters: Double?, timestamp: Date = Date(), temperatureCelsius: Double?) {
        guard let depthMeters = DiveAlgorithm.sanitizedDepthMeters(rawDepthMeters) else {
            lastErrorMessage = String(localized: "Campione profondita non valido ignorato.")
            return
        }

        let safeTemperature = DiveAlgorithm.sanitizedTemperatureCelsius(temperatureCelsius)
        if !isDiveActive {
            currentDepthMeters = depthMeters
            currentTemperatureCelsius = safeTemperature
            guard evaluateAutomaticStartCandidate(depthMeters: depthMeters, timestamp: timestamp) else { return }
            beginDiveIfNeeded()
        }

        addSample(depthMeters: depthMeters, timestamp: timestamp, temperatureCelsius: safeTemperature)
    }

    private func addSample(depthMeters: Double, timestamp: Date = Date(), temperatureCelsius: Double?) {
        guard isDiveActive else { return }
        let sample = DiveSample(timestamp: timestamp, depthMeters: depthMeters, temperatureCelsius: temperatureCelsius)
        guard DiveAlgorithm.isPlausibleDepthTransition(from: previousDepthSample, to: sample) else {
            lastErrorMessage = String(localized: "Variazione profondita non plausibile: campione ignorato.")
            return
        }

        currentDepthMeters = sample.depthMeters
        currentTemperatureCelsius = temperatureCelsius
        lastErrorMessage = nil
        samples.append(sample)
        averageDepthMeters = DiveAlgorithm.timeWeightedAverageDepth(samples: samples, endDate: sample.timestamp)
        maxDepthMeters = max(maxDepthMeters, sample.depthMeters)
        updateRuntimeFromClock(evaluateAlarms: false)
        updateDepthSafety(for: sample.depthMeters)
        if depthSafetyState != .exceeded {
            evaluateDepthAlarm()
        }
        updateAscentRate(with: sample)
        previousDepthSample = sample
        persistActiveDiveDraft()
        evaluateAutomaticSurfaceCandidate(depthMeters: sample.depthMeters, timestamp: sample.timestamp)
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

    private func evaluateDepthAlarm() {
        let threshold = depthAlarmThresholdMeters
        guard depthAlarmEnabled, maxDepthMeters > threshold, depthSafetyState != .exceeded else { return }
        let units = DIRUnitPreference.fromStorage(UserDefaults.standard.string(forKey: DIRUnitPreference.storageKey) ?? DIRUnitPreference.metric.rawValue)
        let display = WatchDepthFormatting.display(meters: threshold, units: units)
        triggerAlarm(String(format: String(localized: "ALLARME PROFONDITÀ > %@"), "\(display.valueText) \(display.unitLabel)"), lastDate: &lastDepthAlarmDate)
    }

    private func evaluateRuntimeAlarms() {
        let runtimeThreshold = runtimeAlarmThresholdMinutes
        if runtimeAlarmEnabled, runtime > TimeInterval(runtimeThreshold * 60) {
            triggerAlarm(String(format: String(localized: "ALLARME TEMPO > %lld min"), runtimeThreshold), lastDate: &lastRuntimeAlarmDate)
        }
        if batteryAlarmEnabled {
            let device = WKInterfaceDevice.current()
            device.isBatteryMonitoringEnabled = true
            let batteryThreshold = Float(batteryAlarmThresholdPercent) / 100
            if device.batteryLevel >= 0, device.batteryLevel < batteryThreshold {
                triggerAlarm(String(format: String(localized: "ALLARME BATTERIA < %lld%%"), batteryAlarmThresholdPercent), lastDate: &lastBatteryAlarmDate)
            }
        }
    }

    private func stopStopwatch(playHaptic: Bool) {
        guard isStopwatchRunning || stopwatchTimer != nil else { return }
        updateStopwatchFromClock()
        stopwatchAccumulatedTime = stopwatchTime
        stopwatchStartedAt = nil
        isStopwatchRunning = false
        stopwatchTimer?.invalidate()
        stopwatchTimer = nil
        persistStopwatchState()
        if playHaptic {
            HapticService.shared.confirm()
        }
    }

    private func triggerAlarm(_ message: String, lastDate: inout Date?) {
        let now = Date()
        if let lastAlarmDismissDate, now.timeIntervalSince(lastAlarmDismissDate) < 15 { return }
        if let lastDate, now.timeIntervalSince(lastDate) < 30 { return }
        lastDate = now
        alarmWarningMessage = message
        HapticService.shared.warnIfNeeded()
        startBlinking()
    }

    private func updateAscentRate(with sample: DiveSample) {
        guard previousDepthSample != nil else {
            ascentStatus = AscentStatus.make(rate: 0, depth: sample.depthMeters, limits: ascentSettings.limits)
            return
        }
        let rate = DiveAlgorithm.ascentRateMetersPerMinute(samples: samples, current: sample)
        ascentStatus = AscentStatus.make(rate: rate, depth: sample.depthMeters, limits: ascentSettings.limits)
        if ascentStatus.isOverLimit, ascentAlarmEnabled {
            startBlinking()
        } else {
            stopBlinking()
        }
    }

    private func startBlinking() {
        guard blinkTimer == nil else { return }
        blinkTimer = Timer.scheduledTimer(withTimeInterval: 0.45, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.redWarningBlink.toggle() }
        }
    }

    private func stopBlinking() { blinkTimer?.invalidate(); blinkTimer = nil; redWarningBlink = false }

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

    func applyMissionModeIfNeededOnDiveStart() {
        isMissionModeActive = missionModeAutoEnableOnDiveStart
    }

    func deactivateMissionModeOnDiveEnd() {
        isMissionModeActive = false
    }
}

extension DiveManager: CMWaterSubmersionManagerDelegate {
    nonisolated func manager(_ manager: CMWaterSubmersionManager, didUpdate event: CMWaterSubmersionEvent) {
        Task { @MainActor in
            switch event.state {
            case .submerged:
                if isDiveActive {
                    hasObservedSubmersionDuringCurrentDive = true
                    if isManualLifecycleActive {
                        isManualLifecycleActive = false
                    }
                    cancelAutomaticSurfaceEnd()
                } else {
                    automaticStartCandidateCount = max(
                        automaticStartCandidateCount,
                        DiveAlgorithmConfiguration.automaticStartRequiredSamples - 1
                    )
                    automaticStartCandidateDate = Date()
                }
            case .notSubmerged:
                guard !isManualLifecycleActive || hasObservedSubmersionDuringCurrentDive else { return }
                evaluateAutomaticSurfaceCandidate(depthMeters: 0, timestamp: Date())
            case .unknown: break
            @unknown default: break
            }
        }
    }

    nonisolated func manager(_ manager: CMWaterSubmersionManager, didUpdate measurement: CMWaterSubmersionMeasurement) {
        Task { @MainActor in
            processDepthMeasurement(
                rawDepthMeters: measurement.depth?.converted(to: .meters).value,
                temperatureCelsius: currentTemperatureCelsius
            )
        }
    }

    nonisolated func manager(_ manager: CMWaterSubmersionManager, didUpdate measurement: CMWaterTemperature) {
        Task { @MainActor in
            currentTemperatureCelsius = DiveAlgorithm.sanitizedTemperatureCelsius(
                measurement.temperature.converted(to: .celsius).value
            )
        }
    }

    nonisolated func manager(_ manager: CMWaterSubmersionManager, errorOccurred error: Error) {
        Task { @MainActor in lastErrorMessage = error.localizedDescription }
    }
}
