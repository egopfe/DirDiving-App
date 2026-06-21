import Foundation
import CoreLocation

@MainActor
enum FullComputerEnvironmentSensorService {
    static func refreshProposal(into configuration: FullComputerPrediveConfigurationStore) {
        guard configuration.canEdit else { return }
        guard configuration.draftEnvironment == nil || configuration.pendingSensorProposal != nil else { return }
        guard CLLocationManager.locationServicesEnabled() else { return }
        let manager = CLLocationManager()
        guard let location = manager.location, location.verticalAccuracy >= 0 else { return }
        let altitude = location.altitude
        guard case .success(let record) = FullComputerEnvironmentRecord.make(
            altitudeMeters: altitude,
            salinity: configuration.draftEnvironment?.salinity ?? .salt,
            source: .watchSensorMeasuredProposal
        ) else { return }
        configuration.proposeSensorEnvironment(record)
    }
}
