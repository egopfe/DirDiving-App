import Foundation
import Combine
import CoreMotion

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
    private var previousDepthSample: DiveSample?
    private var isFinalizingDive = false

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
            lastErrorMessage = "Sensore immersione non disponibile su questo dispositivo o simulatore."
            return
        }
        let manager = CMWaterSubmersionManager()
        manager.delegate = self
        submersionManager = manager
    }

    func startStopwatch() {
        guard !isStopwatchRunning else { return }
        isStopwatchRunning = true
        stopwatchTimer?.invalidate()
        stopwatchTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.stopwatchTime += 1 }
        }
    }

    func stopStopwatch() { isStopwatchRunning = false; stopwatchTimer?.invalidate(); stopwatchTimer = nil }
    func resetStopwatch() { stopStopwatch(); stopwatchTime = 0 }
    func toggleStopwatch() { isStopwatchRunning ? stopStopwatch() : startStopwatch() }

    private func beginDiveIfNeeded() {
        guard !isDiveActive else { return }
        gpsManager.start()
        isDiveActive = true
        sessionStart = Date()
        entryGPS = gpsManager.currentBestPoint()
        gpsManager.captureBestEffortPoint(for: 6) { [weak self] point in
            self?.entryGPS = point
        }
        samples = []
        previousDepthSample = nil
        currentDepthMeters = 0
        averageDepthMeters = 0
        maxDepthMeters = 0
        runtime = 0
        ttv = 0
        runtimeTimer?.invalidate()
        runtimeTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                self.runtime += 1
                self.ttv = self.averageDepthMeters + (self.runtime / 60.0)
            }
        }
    }

    private func endDiveIfNeeded() {
        guard isDiveActive, let start = sessionStart, !isFinalizingDive else { return }
        let capturedEntryGPS = entryGPS
        exitGPS = gpsManager.currentBestPoint()
        isDiveActive = false
        isFinalizingDive = true
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
            self.exitGPS = point
            self.finalizeDive(start: start, end: end, entryGPS: capturedEntryGPS, exitGPS: point, samples: finishedSamples)
        }
    }

    private func finalizeDive(start: Date, end: Date, entryGPS: GPSPoint?, exitGPS: GPSPoint?, samples: [DiveSample]) {
        let depths = samples.map(\.depthMeters)
        let temps = samples.compactMap(\.temperatureCelsius)
        let avgDepth = depths.isEmpty ? 0 : depths.reduce(0, +) / Double(depths.count)
        let maxDepth = depths.max() ?? 0
        let avgTemp = temps.isEmpty ? nil : temps.reduce(0, +) / Double(temps.count)
        let duration = end.timeIntervalSince(start)
        let session = DiveSession(startDate: start, endDate: end, durationSeconds: duration, maxDepthMeters: maxDepth, avgDepthMeters: avgDepth, avgWaterTemperatureCelsius: avgTemp, minWaterTemperatureCelsius: temps.min(), maxWaterTemperatureCelsius: temps.max(), ttv: avgDepth + (duration / 60.0), entryGPS: entryGPS, exitGPS: exitGPS, samples: samples)
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
        updateAscentRate(with: sample)
        previousDepthSample = sample
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
        if ascentStatus.isOverLimit {
            HapticService.shared.warnIfNeeded()
            startBlinking()
        } else { stopBlinking() }
    }

    private func startBlinking() {
        guard blinkTimer == nil else { return }
        blinkTimer = Timer.scheduledTimer(withTimeInterval: 0.45, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.redWarningBlink.toggle() }
        }
    }

    private func stopBlinking() { blinkTimer?.invalidate(); blinkTimer = nil; redWarningBlink = false }
}

extension DiveManager: CMWaterSubmersionManagerDelegate {
    nonisolated func manager(_ manager: CMWaterSubmersionManager, didUpdate event: CMWaterSubmersionEvent) {
        Task { @MainActor in
            switch event.state {
            case .submerged: beginDiveIfNeeded()
            case .notSubmerged: endDiveIfNeeded()
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
