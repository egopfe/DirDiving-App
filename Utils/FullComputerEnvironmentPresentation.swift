import Foundation

enum FullComputerEnvironmentPresentation {
    static func altitudeLabel(meters: Double) -> String {
        String(format: String(localized: "fc.environment.altitude_format"), Int(meters.rounded()))
    }

    static func salinityLabel(salinity: SalinityMode) -> String {
        switch salinity {
        case .fresh: return String(localized: "fc.environment.salinity.fresh")
        case .salt: return String(localized: "fc.environment.salinity.salt")
        }
    }

    static func sourceLabel(source: FullComputerEnvironmentSource) -> String {
        switch source {
        case .iPhonePlanImported: return String(localized: "fc.environment.source.iphone_plan")
        case .watchSettingsManual: return String(localized: "fc.environment.source.watch_manual")
        case .watchSensorMeasuredProposal: return String(localized: "fc.environment.source.watch_sensor")
        case .legacyUnknown: return String(localized: "fc.environment.source.unknown")
        }
    }

    static func summary(for record: FullComputerEnvironmentRecord) -> String {
        guard let salinity = record.salinity else {
            return String(localized: "fc.environment.summary.invalid")
        }
        let base = String(
            format: String(localized: "fc.environment.summary_format"),
            Int(record.altitudeMeters.rounded()),
            salinityLabel(salinity: salinity),
            sourceLabel(source: record.source)
        )
        guard record.source == .watchSensorMeasuredProposal,
              let accuracy = record.sensorAccuracyMeters else {
            return base
        }
        return base + " · " + String(
            format: String(localized: "fc.environment.sensor.accuracy_format"),
            Int(accuracy.rounded())
        )
    }
}
