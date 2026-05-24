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
        configureSubmersion()
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

    func startStopwatch() {
        guard !isStopwatchRunning else { return }
        isStopwatchRunning = true
        HapticService.shared.confirm()
        stopwatchTimer?.invalidate()
        stopwatchTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.stopwatchTime += 1 }
        }
    }

    func stopStopwatch() { stopStopwatch(playHaptic: true) }
    func resetStopwatch() {
        stopStopwatch(playHaptic: false)
        stopwatchTime = 0
        HapticService.shared.confirm()
    }
    func toggleStopwatch() { isStopwatchRunning ? stopStopwatch() : startStopwatch() }

    func startManualDive() {
        guard !isDepthAutomationAvailable else { return }
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
        gpsManager.start()
        isDiveActive = true
        isManualLifecycleActive = isManual
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
        runtimeTimer?.invalidate()
        runtimeTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                self.runtime += 1
                self.ttv = self.averageDepthMeters + (self.runtime / 60.0)
                self.evaluateRuntimeAlarms()
            }
        }
    }

    private func endDiveIfNeeded(isManual: Bool = false) {
        guard isDiveActive, let start = sessionStart, !isFinalizingDive else { return }
        let capturedEntryGPS = entryGPS
        let capturedEntryGPSFixSource = entryGPSFixSource
        exitGPS = gpsManager.currentBestPoint()
        let capturedExitGPS = exitGPS
        exitGPSFixSource = capturedExitGPS == nil ? .noFix : .fallback
        isDiveActive = false
        isFinalizingDive = true
        isManualLifecycleActive = false
        HapticService.shared.criticalConfirm()
        runtimeTimer?.invalidate()
        runtimeTimer = nil
        stopBlinking()
        let end = Date()
        let finishedSamples = samples
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
        let depths = samples.map(\.depthMeters)
        let temps = samples.compactMap(\.temperatureCelsius)
        let avgDepth = depths.isEmpty ? 0 : depths.reduce(0, +) / Double(depths.count)
        let maxDepth = depths.max() ?? 0
        let avgTemp = temps.isEmpty ? nil : temps.reduce(0, +) / Double(temps.count)
        let duration = end.timeIntervalSince(start)
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
            ttv: avgDepth + (duration / 60.0),
            entryGPS: entryGPS,
            exitGPS: exitGPS,
            entryGPSFixSource: entryGPSFixSource,
            exitGPSFixSource: exitGPSFixSource,
            samples: samples,
            exceededSupportedDepthRange: exceeded
        )
        activeDiveExceededSupportedDepth = false
        logStore.add(session)
    }

    private func addSample(depthMeters: Double, temperatureCelsius: Double?) {
        guard isDiveActive else { return }
        let sample = DiveSample(depthMeters: max(0, depthMeters), temperatureCelsius: temperatureCelsius)
        currentDepthMeters = sample.depthMeters
        currentTemperatureCelsius = temperatureCelsius
        samples.append(sample)
        let depths = samples.map(\.depthMeters)
        averageDepthMeters = depths.reduce(0, +) / Double(max(depths.count, 1))
        maxDepthMeters = max(maxDepthMeters, sample.depthMeters)
        ttv = averageDepthMeters + (runtime / 60.0)
        updateDepthSafety(for: sample.depthMeters)
        if depthSafetyState != .exceeded {
            evaluateDepthAlarm()
        }
        updateAscentRate(with: sample)
        previousDepthSample = sample
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
        isStopwatchRunning = false
        stopwatchTimer?.invalidate()
        stopwatchTimer = nil
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
        guard let previous = previousDepthSample else {
            ascentStatus = AscentStatus.make(rate: 0, depth: sample.depthMeters, limits: ascentSettings.limits)
            return
        }
        let deltaTime = max(sample.timestamp.timeIntervalSince(previous.timestamp), 0.001)
        let deltaDepth = previous.depthMeters - sample.depthMeters
        let rate = max(0, (deltaDepth / deltaTime) * 60.0)
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
}

extension DiveManager: CMWaterSubmersionManagerDelegate {
    nonisolated func manager(_ manager: CMWaterSubmersionManager, didUpdate event: CMWaterSubmersionEvent) {
        Task { @MainActor in
            switch event.state {
            case .submerged: beginDiveIfNeeded()
            case .notSubmerged: endDiveIfNeeded()
            case .unknown: break
            @unknown default: break
            }
        }
    }

    nonisolated func manager(_ manager: CMWaterSubmersionManager, didUpdate measurement: CMWaterSubmersionMeasurement) {
        Task { @MainActor in
            let depth = measurement.depth?.converted(to: .meters).value ?? currentDepthMeters
            addSample(depthMeters: depth, temperatureCelsius: currentTemperatureCelsius)
        }
    }

    nonisolated func manager(_ manager: CMWaterSubmersionManager, didUpdate measurement: CMWaterTemperature) {
        Task { @MainActor in currentTemperatureCelsius = measurement.temperature.converted(to: .celsius).value }
    }

    nonisolated func manager(_ manager: CMWaterSubmersionManager, errorOccurred error: Error) {
        Task { @MainActor in lastErrorMessage = error.localizedDescription }
    }
}
