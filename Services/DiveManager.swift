import Foundation
import CoreMotion

@MainActor
final class DiveManager: NSObject, ObservableObject {
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
    private var submersionManager: CMWaterSubmersionManager?
    private var runtimeTimer: Timer?
    private var stopwatchTimer: Timer?
    private var blinkTimer: Timer?
    private var sessionStart: Date?
    private var samples: [DiveSample] = []
    private var entryGPS: GPSPoint?
    private var exitGPS: GPSPoint?
    private var previousDepthSample: DiveSample?

    init(logStore: DiveLogStore, gpsManager: GPSManager) {
        self.logStore = logStore
        self.gpsManager = gpsManager
        super.init()
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
        guard isDiveActive, let start = sessionStart else { return }
        exitGPS = gpsManager.currentBestPoint()
        isDiveActive = false
        runtimeTimer?.invalidate()
        runtimeTimer = nil
        stopBlinking()
        let end = Date()
        let depths = samples.map(\.depthMeters)
        let temps = samples.compactMap(\.temperatureCelsius)
        let avgDepth = depths.isEmpty ? 0 : depths.reduce(0, +) / Double(depths.count)
        let maxDepth = depths.max() ?? 0
        let avgTemp = temps.isEmpty ? nil : temps.reduce(0, +) / Double(temps.count)
        let duration = end.timeIntervalSince(start)
        let session = DiveSession(startDate: start, endDate: end, durationSeconds: duration, maxDepthMeters: maxDepth, avgDepthMeters: avgDepth, avgWaterTemperatureCelsius: avgTemp, minWaterTemperatureCelsius: temps.min(), maxWaterTemperatureCelsius: temps.max(), ttv: avgDepth + (duration / 60.0), entryGPS: entryGPS, exitGPS: exitGPS, samples: samples)
        logStore.add(session)
        sessionStart = nil
        samples = []
        previousDepthSample = nil
    }

    private func addSample(depthMeters: Double, temperatureCelsius: Double?) {
        beginDiveIfNeeded()
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
            ascentStatus = AscentStatus.make(rate: 0, depth: sample.depthMeters)
            return
        }
        let deltaTime = sample.timestamp.timeIntervalSince(previous.timestamp)
        guard deltaTime > 0 else { return }
        let deltaDepth = previous.depthMeters - sample.depthMeters
        let rate = max(0, (deltaDepth / deltaTime) * 60.0)
        ascentStatus = AscentStatus.make(rate: rate, depth: sample.depthMeters)
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
