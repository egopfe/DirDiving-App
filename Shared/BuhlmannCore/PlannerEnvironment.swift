import Foundation

enum PlannerEnvironmentError: String, Error, Hashable {
    case invalidAltitude
    case invalidSalinity
}

enum WaterDensityModel {
    static let freshwaterDensityKgPerM3 = 997.0
    static let saltwaterDensityKgPerM3 = 1_025.0

    static func densityKgPerM3(for salinity: SalinityMode) -> Double {
        switch salinity {
        case .fresh:
            return freshwaterDensityKgPerM3
        case .salt:
            return saltwaterDensityKgPerM3
        }
    }

    static func validate(_ salinity: SalinityMode) -> PlannerEnvironmentError? {
        switch salinity {
        case .fresh, .salt:
            return nil
        }
    }
}

enum AmbientPressureModel {
    // Barometric formula approximation valid for recreational dive planning altitudes.
    static func surfacePressureBar(altitudeMeters: Double) -> Double? {
        guard altitudeMeters.isFinite, altitudeMeters >= -500, altitudeMeters <= 4_500 else {
            return nil
        }
        let pressure = 1.01325 * pow(1.0 - 2.25577e-5 * altitudeMeters, 5.25588)
        guard pressure.isFinite, pressure > 0 else { return nil }
        return pressure
    }

    static func ambientPressureBar(depthMeters: Double, environment: PlannerEnvironment) -> Double? {
        guard depthMeters.isFinite, depthMeters >= 0 else { return nil }
        let rho = environment.waterDensityKgPerM3
        let pressure = environment.surfacePressureBar + (rho * 9.80665 * depthMeters) / 100_000.0
        guard pressure.isFinite, pressure > 0 else { return nil }
        return pressure
    }

    static func depthMeters(ambientPressureBar: Double, environment: PlannerEnvironment) -> Double? {
        guard ambientPressureBar.isFinite, ambientPressureBar >= environment.surfacePressureBar else { return nil }
        let rho = environment.waterDensityKgPerM3
        let meters = (ambientPressureBar - environment.surfacePressureBar) * 100_000.0 / (rho * 9.80665)
        guard meters.isFinite, meters >= 0 else { return nil }
        return meters
    }
}

struct PlannerEnvironment: Hashable, Codable {
    let altitudeMeters: Double
    let salinity: SalinityMode
    let surfacePressureBar: Double
    let waterDensityKgPerM3: Double

    static let seaLevelSaltWater = PlannerEnvironment(
        altitudeMeters: 0,
        salinity: .salt,
        surfacePressureBar: 1.01325,
        waterDensityKgPerM3: WaterDensityModel.saltwaterDensityKgPerM3
    )

    static func make(altitudeMeters: Double, salinity: SalinityMode) -> Result<PlannerEnvironment, PlannerEnvironmentError> {
        if let salinityError = WaterDensityModel.validate(salinity) {
            return .failure(salinityError)
        }
        guard let surface = AmbientPressureModel.surfacePressureBar(altitudeMeters: altitudeMeters) else {
            return .failure(.invalidAltitude)
        }
        return .success(
            PlannerEnvironment(
                altitudeMeters: altitudeMeters,
                salinity: salinity,
                surfacePressureBar: surface,
                waterDensityKgPerM3: WaterDensityModel.densityKgPerM3(for: salinity)
            )
        )
    }
}
