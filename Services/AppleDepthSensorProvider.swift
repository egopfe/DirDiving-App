import CoreMotion
import Foundation

/// Lazy wrapper around `CMWaterSubmersionManager`. Never created at app launch.
@MainActor
final class AppleDepthSensorProvider: NSObject, DepthSensorProvider {
    enum OperatingMode: Equatable, Sendable {
        case shallow
        case full
    }

    let operatingMode: OperatingMode

    static var testHook_isAvailable: Bool?

    static var isAvailable: Bool {
        if let testHook_isAvailable { return testHook_isAvailable }
        return CMWaterSubmersionManager.waterSubmersionAvailable
    }

    var onDepthMeasurement: ((Double?, Date, Double?) -> Void)?
    var onSubmersionState: ((DepthSensorSubmersionState) -> Void)?
    var onTemperature: ((Double?, Date) -> Void)?
    var onError: ((String) -> Void)?

    private var manager: CMWaterSubmersionManager?
    private var lastTemperatureCelsius: Double?
    private(set) var isSensorDegraded = false

    init(operatingMode: OperatingMode) {
        self.operatingMode = operatingMode
        super.init()
    }

    var sampleSource: DepthSampleSource {
        switch operatingMode {
        case .shallow:
            return .appleShallow
        case .full:
            return .appleFull
        }
    }

    func start() {
        guard Self.isAvailable else {
            onError?(String(localized: "watch.depth_sensor.unavailable.apple_sensor"))
            return
        }
        let manager = CMWaterSubmersionManager()
        manager.delegate = self
        self.manager = manager
        isSensorDegraded = false
    }

    func stop() {
        manager?.delegate = nil
        manager = nil
        lastTemperatureCelsius = nil
        isSensorDegraded = false
    }

    private func sanitizedDepthMeters(_ depth: Double?) -> Double? {
        guard let depth, depth.isFinite, depth >= 0 else { return nil }
        if operatingMode == .shallow, depth > AppleDepthSensorProvider.shallowMaximumDepthMeters + 0.5 {
            isSensorDegraded = true
        }
        return depth
    }

    static let shallowMaximumDepthMeters = 6.0
}

extension AppleDepthSensorProvider: CMWaterSubmersionManagerDelegate {
    nonisolated func manager(_ manager: CMWaterSubmersionManager, didUpdate event: CMWaterSubmersionEvent) {
        Task { @MainActor in
            let state: DepthSensorSubmersionState
            switch event.state {
            case .submerged: state = .submerged
            case .notSubmerged: state = .notSubmerged
            case .unknown: state = .unknown
            @unknown default: state = .unknown
            }
            onSubmersionState?(state)
        }
    }

    nonisolated func manager(_ manager: CMWaterSubmersionManager, didUpdate measurement: CMWaterSubmersionMeasurement) {
        Task { @MainActor in
            let depth = sanitizedDepthMeters(measurement.depth?.converted(to: .meters).value)
            onDepthMeasurement?(
                depth,
                Date(),
                lastTemperatureCelsius
            )
        }
    }

    nonisolated func manager(_ manager: CMWaterSubmersionManager, didUpdate measurement: CMWaterTemperature) {
        Task { @MainActor in
            let receivedAt = Date()
            lastTemperatureCelsius = DiveAlgorithm.sanitizedTemperatureCelsius(
                measurement.temperature.converted(to: .celsius).value
            )
            onTemperature?(lastTemperatureCelsius, receivedAt)
        }
    }

    nonisolated func manager(_ manager: CMWaterSubmersionManager, errorOccurred error: Error) {
        Task { @MainActor in
            isSensorDegraded = true
            onError?(error.localizedDescription)
        }
    }
}
