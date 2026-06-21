import Foundation
import CoreMotion
import Combine

struct FullComputerAbsoluteAltitudeSample: Equatable, Sendable {
    let altitudeMeters: Double
    let accuracyMeters: Double
    let precisionMeters: Double
    /// Core Motion sensor measurement time (`CMAbsoluteAltitudeData.timestamp`).
    let sensorMeasuredAt: Date
    /// Callback delivery time for diagnostics only.
    let receivedAt: Date

    /// Maps Core Motion log timestamp to a stable `Date` for freshness validation.
    static func canonicalSensorTimestamp(from data: CMAbsoluteAltitudeData, receivedAt: Date) -> Date {
        let secondsSinceReference = (data as CMLogItem).timestamp
        let sensorDate = Date(timeIntervalSinceReferenceDate: secondsSinceReference)
        let age = receivedAt.timeIntervalSince(sensorDate)
        if age >= -FullComputerAltitudeSamplingPolicy.maximumFutureSensorTimestampSkewSeconds,
           age <= FullComputerEnvironmentRecord.maximumSensorAgeSeconds {
            return sensorDate
        }
        return receivedAt
    }
}

enum FullComputerEnvironmentSensorError: String, Error, Equatable, Sendable {
    case unavailable
    case sensorFailure
    case timedOut
    case nilDataStream
}

enum FullComputerEnvironmentSensorState: Equatable {
    case idle
    case sampling
    case proposalReady
    case unavailable
    case timedOut
    case failed
    case cancelled

    var isTerminal: Bool {
        switch self {
        case .idle, .sampling:
            return false
        case .proposalReady, .unavailable, .timedOut, .failed, .cancelled:
            return true
        }
    }
}

enum FullComputerAltitudeSamplingPolicy {
    static let requiredSampleCount = 5
    static let maximumAccuracyMeters = FullComputerEnvironmentRecord.maximumSensorAccuracyMeters
    static let maximumStableSpreadMeters = 12.0
    static let timeoutSeconds: TimeInterval = 8
    static let maximumConsecutiveNilDataCallbacks = 3
    static let maximumFutureSensorTimestampSkewSeconds: TimeInterval = 5

#if DEBUG
    static var testHook_timeoutSeconds: TimeInterval?
    static var effectiveTimeoutSeconds: TimeInterval { testHook_timeoutSeconds ?? timeoutSeconds }
#else
    static var effectiveTimeoutSeconds: TimeInterval { timeoutSeconds }
#endif

    static func isUsable(_ sample: FullComputerAbsoluteAltitudeSample, referenceNow: Date = Date()) -> Bool {
        sample.altitudeMeters.isFinite
            && sample.accuracyMeters.isFinite
            && sample.accuracyMeters >= 0
            && sample.accuracyMeters <= maximumAccuracyMeters
            && sample.precisionMeters.isFinite
            && sample.precisionMeters >= 0
            && isSensorTimestampAcceptable(sample.sensorMeasuredAt, referenceNow: referenceNow)
    }

    static func isSensorTimestampAcceptable(_ sensorMeasuredAt: Date, referenceNow: Date) -> Bool {
        let age = referenceNow.timeIntervalSince(sensorMeasuredAt)
        return age >= -maximumFutureSensorTimestampSkewSeconds
            && age <= FullComputerEnvironmentRecord.maximumSensorAgeSeconds
    }

    static func stableProposal(
        from samples: [FullComputerAbsoluteAltitudeSample]
    ) -> FullComputerAbsoluteAltitudeSample? {
        let referenceNow = samples.map(\.receivedAt).max() ?? Date()
        let usable = samples.filter { isUsable($0, referenceNow: referenceNow) }
        guard usable.count >= requiredSampleCount else { return nil }
        let window = Array(usable.suffix(requiredSampleCount))
        let altitudes = window.map(\.altitudeMeters).sorted()
        guard let minimum = altitudes.first,
              let maximum = altitudes.last,
              maximum - minimum <= maximumStableSpreadMeters else {
            return nil
        }
        let medianIndex = altitudes.count / 2
        let medianAltitude = altitudes[medianIndex]
        let representative = window.min {
            abs($0.altitudeMeters - medianAltitude) < abs($1.altitudeMeters - medianAltitude)
        } ?? window[window.count / 2]
        return FullComputerAbsoluteAltitudeSample(
            altitudeMeters: medianAltitude,
            accuracyMeters: window.map(\.accuracyMeters).max() ?? maximumAccuracyMeters,
            precisionMeters: window.map(\.precisionMeters).max() ?? 0,
            sensorMeasuredAt: representative.sensorMeasuredAt,
            receivedAt: window.map(\.receivedAt).max() ?? representative.receivedAt
        )
    }
}

enum FullComputerAltitudeProviderEvent: Equatable {
    case sample(FullComputerAbsoluteAltitudeSample)
    case failure(FullComputerEnvironmentSensorError)
    case nilDataNilError
}

@MainActor
protocol FullComputerAbsoluteAltitudeProviding: AnyObject {
    var isAvailable: Bool { get }
    func start(
        handler: @escaping (FullComputerAltitudeProviderEvent) -> Void
    )
    func stop()
}

@MainActor
final class AppleWatchAbsoluteAltitudeProvider: FullComputerAbsoluteAltitudeProviding {
    private let altimeter = CMAltimeter()

    var isAvailable: Bool {
        CMAltimeter.isAbsoluteAltitudeAvailable()
    }

    func start(
        handler: @escaping (FullComputerAltitudeProviderEvent) -> Void
    ) {
        guard isAvailable else {
            handler(.failure(.unavailable))
            return
        }
        altimeter.stopAbsoluteAltitudeUpdates()
        altimeter.startAbsoluteAltitudeUpdates(to: .main) { data, error in
            Task { @MainActor in
                if let error {
                    _ = error
                    handler(.failure(.sensorFailure))
                    return
                }
                guard let data else {
                    handler(.nilDataNilError)
                    return
                }
                let receivedAt = Date()
                let sensorMeasuredAt = FullComputerAbsoluteAltitudeSample.canonicalSensorTimestamp(
                    from: data,
                    receivedAt: receivedAt
                )
                handler(
                    .sample(
                        FullComputerAbsoluteAltitudeSample(
                            altitudeMeters: data.altitude,
                            accuracyMeters: data.accuracy,
                            precisionMeters: data.precision,
                            sensorMeasuredAt: sensorMeasuredAt,
                            receivedAt: receivedAt
                        )
                    )
                )
            }
        }
    }

    func stop() {
        altimeter.stopAbsoluteAltitudeUpdates()
    }
}

/// Captures a fresh absolute-altitude sample immediately before Full Computer start.
/// Sensor data is always a proposal; it never mutates the active draft until accepted.
@MainActor
final class FullComputerEnvironmentSensorService: ObservableObject {
    static let shared = FullComputerEnvironmentSensorService()

    @Published private(set) var state: FullComputerEnvironmentSensorState = .idle
    @Published private(set) var lastDiagnostic: String?

    private let provider: FullComputerAbsoluteAltitudeProviding
    private var samples: [FullComputerAbsoluteAltitudeSample] = []
    private var timeoutTask: Task<Void, Never>?
    private weak var configuration: FullComputerPrediveConfigurationStore?
    private var requestGeneration: UInt64 = 0
    private var activeRequestGeneration: UInt64 = 0
    private var consecutiveNilDataCount = 0
    private var providerStoppedForRequest = false

    init(provider: FullComputerAbsoluteAltitudeProviding? = nil) {
        self.provider = provider ?? AppleWatchAbsoluteAltitudeProvider()
    }

    /// Non-destructive entry: respects Watch policy and avoids duplicate subscriptions.
    func requestProposalIfNeeded(into configuration: FullComputerPrediveConfigurationStore) {
        guard shouldAllowAutomaticSampling else { return }
        guard configuration.canEdit else { return }
        if state == .sampling || state == .proposalReady || configuration.pendingSensorProposal != nil {
            return
        }
        requestProposal(into: configuration)
    }

    /// Explicit refresh (Settings button) — still requires acceptance and respects manual-only policy.
    func refreshProposal(into configuration: FullComputerPrediveConfigurationStore) {
        guard configuration.canEdit else { return }
        guard WatchFullComputerAltitudeSensorProposalSettingsStore.shared.mode != .manualOnly else { return }
        requestProposal(into: configuration)
    }

    func requestProposal(into configuration: FullComputerPrediveConfigurationStore) {
        cancelInternal(clearPendingProposal: true)
        guard configuration.canEdit else { return }
        guard shouldAllowAutomaticSampling else {
            state = .idle
            lastDiagnostic = "manual_only"
            return
        }
        configuration.dismissPendingSensorProposal()
        guard provider.isAvailable else {
            state = .unavailable
            lastDiagnostic = "unavailable"
            return
        }

        requestGeneration &+= 1
        let generation = requestGeneration
        activeRequestGeneration = generation
        self.configuration = configuration
        samples = []
        consecutiveNilDataCount = 0
        providerStoppedForRequest = false
        state = .sampling
        lastDiagnostic = nil

        provider.start { [weak self] event in
            guard let self else { return }
            self.handleProviderEvent(event, generation: generation)
        }

        guard state == .sampling, generation == activeRequestGeneration else { return }
        timeoutTask = Task { @MainActor [weak self] in
            try? await Task.sleep(
                nanoseconds: UInt64(FullComputerAltitudeSamplingPolicy.effectiveTimeoutSeconds * 1_000_000_000)
            )
            guard !Task.isCancelled else { return }
            self?.finishTimeout(for: generation)
        }
    }

    func cancel() {
        cancelInternal(clearPendingProposal: false)
    }

    private var shouldAllowAutomaticSampling: Bool {
        WatchFullComputerAltitudeSensorProposalSettingsStore.shared.mode != .manualOnly
    }

    private func handleProviderEvent(_ event: FullComputerAltitudeProviderEvent, generation: UInt64) {
        guard generation == activeRequestGeneration else { return }
        guard state == .sampling else { return }

        switch event {
        case .sample(let sample):
            consecutiveNilDataCount = 0
            consume(sample, generation: generation)
        case .failure(let error):
            finish(with: error == .unavailable ? .unavailable : .failed, generation: generation, diagnostic: error.rawValue)
        case .nilDataNilError:
            consecutiveNilDataCount += 1
            lastDiagnostic = "nil_data_nil_error"
            if consecutiveNilDataCount >= FullComputerAltitudeSamplingPolicy.maximumConsecutiveNilDataCallbacks {
                finish(with: .failed, generation: generation, diagnostic: FullComputerEnvironmentSensorError.nilDataStream.rawValue)
            }
        }
    }

    private func consume(_ sample: FullComputerAbsoluteAltitudeSample, generation: UInt64) {
        guard generation == activeRequestGeneration, state == .sampling else { return }
        guard FullComputerAltitudeSamplingPolicy.isUsable(sample, referenceNow: sample.receivedAt) else { return }
        samples.append(sample)
        guard let stable = FullComputerAltitudeSamplingPolicy.stableProposal(from: samples),
              let configuration else {
            return
        }

        let salinity = configuration.draftEnvironment?.salinity ?? .salt
        guard case .success(var record) = FullComputerEnvironmentRecord.make(
            altitudeMeters: stable.altitudeMeters,
            salinity: salinity,
            source: .watchSensorMeasuredProposal,
            capturedAt: stable.sensorMeasuredAt,
            sensorReceivedAt: stable.receivedAt
        ) else {
            finish(with: .failed, generation: generation, diagnostic: "invalid_record")
            return
        }
        record.sensorAccuracyMeters = stable.accuracyMeters
        record.sensorPrecisionMeters = stable.precisionMeters
        guard record.validateForLiveStart(now: stable.receivedAt) == nil else {
            finish(with: .failed, generation: generation, diagnostic: "validation_failed")
            return
        }
        configuration.proposeSensorEnvironment(record)
        finish(with: .proposalReady, generation: generation, diagnostic: nil)
    }

    private func finishTimeout(for generation: UInt64) {
        guard generation == activeRequestGeneration, state == .sampling else { return }
        finish(with: .timedOut, generation: generation, diagnostic: "timed_out")
    }

    private func finish(
        with finalState: FullComputerEnvironmentSensorState,
        generation: UInt64,
        diagnostic: String?
    ) {
        guard generation == activeRequestGeneration else { return }
        guard state == .sampling else { return }
        stopProviderIfNeeded()
        timeoutTask?.cancel()
        timeoutTask = nil
        samples = []
        configuration = nil
        consecutiveNilDataCount = 0
        lastDiagnostic = diagnostic
        state = finalState
    }

    private func cancelInternal(clearPendingProposal: Bool) {
        if state == .sampling {
            activeRequestGeneration &+= 1
            stopProviderIfNeeded()
            timeoutTask?.cancel()
            timeoutTask = nil
            samples = []
            configuration = nil
            consecutiveNilDataCount = 0
            state = .cancelled
            lastDiagnostic = "cancelled"
        }
        if clearPendingProposal {
            configuration?.dismissPendingSensorProposal()
        }
        configuration = nil
    }

    private func stopProviderIfNeeded() {
        guard !providerStoppedForRequest else { return }
        provider.stop()
        providerStoppedForRequest = true
    }

    #if DEBUG
    func resetForTests() {
        cancel()
        state = .idle
        lastDiagnostic = nil
        requestGeneration = 0
        activeRequestGeneration = 0
        providerStoppedForRequest = false
    }
    #endif
}
