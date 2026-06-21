import Foundation

enum FullComputerEnvironmentSource: String, Codable, Hashable {
    case iPhonePlanImported
    case watchSettingsManual
    case watchSensorMeasuredProposal
    case legacyUnknown

    var isLiveStartAuthorized: Bool {
        switch self {
        case .iPhonePlanImported, .watchSettingsManual, .watchSensorMeasuredProposal:
            return true
        case .legacyUnknown:
            return false
        }
    }
}

enum FullComputerEnvironmentValidationError: String, Error, Hashable, Equatable {
    case invalidAltitude
    case invalidSalinity
    case missingEnvironment
    case surfacePressureMismatch
    case unauthorizedSource
    case nonFiniteValue
}

/// Versioned frozen Full Computer dive environment with provenance.
struct FullComputerEnvironmentRecord: Codable, Hashable {
    static let currentSchemaVersion = 1
    private static let surfacePressureToleranceBar = 0.02

    var schemaVersion: Int
    var altitudeMeters: Double
    var surfacePressureBar: Double
    var salinityRaw: String
    var waterDensityKgPerM3: Double
    var source: FullComputerEnvironmentSource
    var capturedAt: Date

    var salinity: SalinityMode? {
        SalinityMode(rawValue: salinityRaw)
    }

    var plannerEnvironment: PlannerEnvironment? {
        guard let salinity else { return nil }
        return PlannerEnvironment(
            altitudeMeters: altitudeMeters,
            salinity: salinity,
            surfacePressureBar: surfacePressureBar,
            waterDensityKgPerM3: waterDensityKgPerM3
        )
    }

    static func make(
        altitudeMeters: Double,
        salinity: SalinityMode,
        source: FullComputerEnvironmentSource,
        capturedAt: Date = Date()
    ) -> Result<FullComputerEnvironmentRecord, FullComputerEnvironmentValidationError> {
        guard source.isLiveStartAuthorized else {
            return .failure(.unauthorizedSource)
        }
        guard altitudeMeters.isFinite else {
            return .failure(.nonFiniteValue)
        }
        switch PlannerEnvironment.make(altitudeMeters: altitudeMeters, salinity: salinity) {
        case .success(let environment):
            return .success(
                FullComputerEnvironmentRecord(
                    schemaVersion: currentSchemaVersion,
                    altitudeMeters: environment.altitudeMeters,
                    surfacePressureBar: environment.surfacePressureBar,
                    salinityRaw: salinity.rawValue,
                    waterDensityKgPerM3: environment.waterDensityKgPerM3,
                    source: source,
                    capturedAt: capturedAt
                )
            )
        case .failure(.invalidAltitude):
            return .failure(.invalidAltitude)
        case .failure(.invalidSalinity):
            return .failure(.invalidSalinity)
        }
    }

    func validateForLiveStart() -> FullComputerEnvironmentValidationError? {
        guard source.isLiveStartAuthorized else { return .unauthorizedSource }
        guard altitudeMeters.isFinite, surfacePressureBar.isFinite, waterDensityKgPerM3.isFinite else {
            return .nonFiniteValue
        }
        guard let salinity else { return .invalidSalinity }
        switch PlannerEnvironment.make(altitudeMeters: altitudeMeters, salinity: salinity) {
        case .failure(.invalidAltitude):
            return .invalidAltitude
        case .failure(.invalidSalinity):
            return .invalidSalinity
        case .success(let expected):
            if abs(expected.surfacePressureBar - surfacePressureBar) > Self.surfacePressureToleranceBar {
                return .surfacePressureMismatch
            }
            return nil
        }
    }
}

extension DivePlanEnvironmentPayload {
    func validatedRecord(
        source: FullComputerEnvironmentSource = .iPhonePlanImported,
        capturedAt: Date = Date()
    ) -> Result<FullComputerEnvironmentRecord, FullComputerEnvironmentValidationError> {
        guard let salinity = SalinityMode(rawValue: salinityRaw) else {
            return .failure(.invalidSalinity)
        }
        switch FullComputerEnvironmentRecord.make(
            altitudeMeters: altitudeMeters,
            salinity: salinity,
            source: source,
            capturedAt: capturedAt
        ) {
        case .failure(let error):
            return .failure(error)
        case .success(var record):
            if let declared = surfacePressureBar {
                guard declared.isFinite else { return .failure(.nonFiniteValue) }
                if abs(declared - record.surfacePressureBar) > 0.02 {
                    return .failure(.surfacePressureMismatch)
                }
                record.surfacePressureBar = declared
            }
            return .success(record)
        }
    }
}

extension FullComputerEnvironmentRecord {
    static func from(
        plannerEnvironment: PlannerEnvironment,
        source: FullComputerEnvironmentSource,
        capturedAt: Date
    ) -> FullComputerEnvironmentRecord {
        FullComputerEnvironmentRecord(
            schemaVersion: currentSchemaVersion,
            altitudeMeters: plannerEnvironment.altitudeMeters,
            surfacePressureBar: plannerEnvironment.surfacePressureBar,
            salinityRaw: plannerEnvironment.salinity.rawValue,
            waterDensityKgPerM3: plannerEnvironment.waterDensityKgPerM3,
            source: source,
            capturedAt: capturedAt
        )
    }

    func displaySummaryLocalizationKey(for source: FullComputerEnvironmentSource) -> String {
        switch source {
        case .iPhonePlanImported: return "fc.environment.source.iphone_plan"
        case .watchSettingsManual: return "fc.environment.source.watch_manual"
        case .watchSensorMeasuredProposal: return "fc.environment.source.watch_sensor"
        case .legacyUnknown: return "fc.environment.source.unknown"
        }
    }
}
