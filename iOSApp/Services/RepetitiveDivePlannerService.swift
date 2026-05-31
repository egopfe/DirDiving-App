import Foundation

struct TissueSnapshot: Codable, Hashable {
    let createdAt: Date
    let plannerEnvironment: PlannerEnvironment
    let tissueState: BuhlmannTissueState
    let schemaVersion: Int
    let oxygenCarryover: OxygenExposureCarryover?

    static let currentSchemaVersion = 2
    static let maxAge: TimeInterval = 60 * 60 * 24 * 14

    init(
        createdAt: Date,
        plannerEnvironment: PlannerEnvironment,
        tissueState: BuhlmannTissueState,
        schemaVersion: Int = TissueSnapshot.currentSchemaVersion,
        oxygenCarryover: OxygenExposureCarryover? = nil
    ) {
        self.createdAt = createdAt
        self.plannerEnvironment = plannerEnvironment
        self.tissueState = tissueState
        self.schemaVersion = schemaVersion
        self.oxygenCarryover = oxygenCarryover
    }
}

struct SurfaceIntervalModel: Hashable {
    let minutes: Double

    func offGas(_ state: BuhlmannTissueState, environment: PlannerEnvironment) -> BuhlmannTissueState? {
        guard minutes.isFinite, minutes >= 0 else { return nil }
        guard let air = BuhlmannGas.makeAir(environment: environment) else { return nil }
        return state.loadedConstantDepth(depthMeters: 0, minutes: minutes, gas: air, environment: environment)
    }
}

enum RepetitiveDivePlannerService {
    enum SnapshotError: Error, Hashable {
        case missing
        case corrupted
        case stale
        case schemaMismatch
        case invalidEnvironment
        case invalidSurfaceInterval
    }

    static func makeSnapshot(from result: BuhlmannEngineResult, environment: PlannerEnvironment) -> TissueSnapshot? {
        guard let tissue = result.finalTissueState else { return nil }
        let oxygenCarryover: OxygenExposureCarryover?
        switch OxygenExposureModel.from(segments: result.segments, environment: environment, carryover: .zero) {
        case .success(let exposure):
            oxygenCarryover = exposure.carryoverEnd
        case .failure:
            oxygenCarryover = nil
        }
        return TissueSnapshot(
            createdAt: Date(),
            plannerEnvironment: environment,
            tissueState: tissue,
            schemaVersion: TissueSnapshot.currentSchemaVersion,
            oxygenCarryover: oxygenCarryover
        )
    }

    static func validateSnapshot(_ snapshot: TissueSnapshot?) -> Result<TissueSnapshot, SnapshotError> {
        guard let snapshot else { return .failure(.missing) }
        guard snapshot.schemaVersion == 1 || snapshot.schemaVersion == TissueSnapshot.currentSchemaVersion else {
            return .failure(.schemaMismatch)
        }
        if Date().timeIntervalSince(snapshot.createdAt) > TissueSnapshot.maxAge {
            return .failure(.stale)
        }
        return .success(snapshot)
    }

    static func seedRequest(
        _ request: BuhlmannPlanRequest,
        snapshot: TissueSnapshot?,
        surfaceIntervalMinutes: Double,
        environment: PlannerEnvironment
    ) -> Result<BuhlmannPlanRequest, SnapshotError> {
        switch validateSnapshot(snapshot) {
        case .failure(let error):
            return .failure(error)
        case .success(let valid):
            guard valid.plannerEnvironment == environment else {
                return .failure(.invalidEnvironment)
            }
            guard surfaceIntervalMinutes.isFinite, surfaceIntervalMinutes >= 0 else {
                return .failure(.invalidSurfaceInterval)
            }
            let interval = SurfaceIntervalModel(minutes: surfaceIntervalMinutes)
            guard let offGassed = interval.offGas(valid.tissueState, environment: environment) else {
                return .failure(.corrupted)
            }
            var seeded = request
            seeded.initialTissueState = offGassed
            return .success(seeded)
        }
    }
}

private extension BuhlmannGas {
    static func makeAir(environment: PlannerEnvironment) -> BuhlmannGas? {
        guard environment.surfacePressureBar.isFinite, environment.surfacePressureBar > 0 else { return nil }
        return BuhlmannGas(
            name: "Air",
            role: .bottom,
            oxygenFraction: BuhlmannConstants.oxygenFractionAir,
            heliumFraction: 0,
            maxPPO2Bar: 1.4,
            switchDepthMeters: 0
        )
    }
}
