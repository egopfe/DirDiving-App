import CoreMotion
import Foundation

/// Lazy wrapper around `CMWaterSubmersionManager`. Never created at app launch.
@MainActor
final class AppleDepthSensorProvider: NSObject, DepthSensorProvider {
    static var isAvailable: Bool {
        CMWaterSubmersionManager.waterSubmersionAvailable
    }

    var onDepthMeasurement: ((Double?, Date, Double?) -> Void)?
    var onSubmersionState: ((DepthSensorSubmersionState) -> Void)?
    var onTemperature: ((Double?, Date) -> Void)?
    var onError: ((String) -> Void)?

    private var manager: CMWaterSubmersionManager?
    private var lastTemperatureCelsius: Double?

    func start() {
        guard Self.isAvailable else { return }
        let manager = CMWaterSubmersionManager()
        manager.delegate = self
        self.manager = manager
    }

    func stop() {
        manager?.delegate = nil
        manager = nil
        lastTemperatureCelsius = nil
    }
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
            onDepthMeasurement?(
                measurement.depth?.converted(to: .meters).value,
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
            onError?(error.localizedDescription)
        }
    }
}
