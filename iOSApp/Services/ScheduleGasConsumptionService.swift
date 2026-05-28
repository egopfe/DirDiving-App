import Foundation

enum GasUsageWarningState: Hashable {
    case reserveBreached(gas: String)
    case minimumGasBreached(gas: String)
    case lostGasContingencyFailed(gas: String)
    case invalidAllocation(gas: String)
}

struct GasCylinderAllocation: Hashable {
    let gasLabel: String
    let role: GasRole
    let cylinderVolumeLiters: Double
    let startPressureBar: Double
    let reservePressureBar: Double

    var startLiters: Double { cylinderVolumeLiters * startPressureBar }
    var reserveLiters: Double { cylinderVolumeLiters * reservePressureBar }
}

struct GasConsumptionLedger: Hashable {
    struct Entry: Hashable {
        let gasLabel: String
        let consumedLiters: Double
        let remainingLiters: Double
        let remainingBar: Double
    }

    let entries: [Entry]
    let totalConsumedLiters: Double
    let totalRemainingLiters: Double
    let warnings: [GasUsageWarningState]
}

enum ScheduleGasConsumptionService {
    enum Error: Swift.Error, Hashable {
        case invalidSegment
        case missingCylinderAllocation(String)
        case invalidCylinder
    }

    static func analyze(
        input: GasPlanInput,
        enginePlan: BuhlmannEngineResult,
        environment: PlannerEnvironment
    ) -> Result<GasConsumptionLedger, Error> {
        guard !enginePlan.segments.isEmpty else {
            return .failure(.invalidSegment)
        }

        let allocations = makeAllocations(input: input)
        guard !allocations.isEmpty else { return .failure(.invalidCylinder) }

        var consumedByGas: [String: Double] = [:]
        for segment in enginePlan.segments {
            guard segment.minutes.isFinite, segment.minutes >= 0, segment.depthMeters.isFinite else {
                return .failure(.invalidSegment)
            }
            guard let ambient = AmbientPressureModel.ambientPressureBar(depthMeters: segment.depthMeters, environment: environment),
                  ambient.isFinite, ambient > 0 else {
                return .failure(.invalidSegment)
            }
            let consumed = input.sacLitersPerMinute * ambient * segment.minutes
            guard consumed.isFinite, consumed >= 0 else {
                return .failure(.invalidSegment)
            }
            consumedByGas[segment.gas.label, default: 0] += consumed
        }

        var entries: [GasConsumptionLedger.Entry] = []
        var warnings: [GasUsageWarningState] = []
        var totalConsumed = 0.0
        var totalRemaining = 0.0

        for (gas, consumed) in consumedByGas {
            guard let allocation = allocations[gas] else {
                return .failure(.missingCylinderAllocation(gas))
            }
            guard allocation.cylinderVolumeLiters.isFinite, allocation.cylinderVolumeLiters > 0 else {
                return .failure(.invalidCylinder)
            }

            let remainingLiters = allocation.startLiters - consumed
            let remainingBar = remainingLiters / allocation.cylinderVolumeLiters
            if !remainingLiters.isFinite || !remainingBar.isFinite {
                return .failure(.invalidCylinder)
            }

            if remainingLiters < allocation.reserveLiters {
                warnings.append(.reserveBreached(gas: gas))
            }
            if remainingLiters < rockBottomLiters(input: input) {
                warnings.append(.minimumGasBreached(gas: gas))
            }
            if remainingLiters - (consumed * 0.3) < allocation.reserveLiters {
                warnings.append(.lostGasContingencyFailed(gas: gas))
            }

            entries.append(
                .init(
                    gasLabel: gas,
                    consumedLiters: consumed,
                    remainingLiters: remainingLiters,
                    remainingBar: remainingBar
                )
            )
            totalConsumed += consumed
            totalRemaining += remainingLiters
        }

        return .success(
            GasConsumptionLedger(
                entries: entries.sorted { $0.gasLabel < $1.gasLabel },
                totalConsumedLiters: totalConsumed,
                totalRemainingLiters: totalRemaining,
                warnings: warnings
            )
        )
    }

    private static func makeAllocations(input: GasPlanInput) -> [String: GasCylinderAllocation] {
        let cylinders = input.plannerCylinders.isEmpty ? [
            PlannerCylinderEntry(
                role: .bottom,
                tankSize: TankSize.nearest(toVolumeLiters: input.primaryCylinder.volumeLiters),
                gas: input.bottomGas,
                startPressure: input.primaryCylinder.startPressure,
                reservePressure: input.primaryCylinder.reservePressure,
                pressureUnit: input.primaryCylinder.pressureUnit
            )
        ] : input.plannerCylinders

        return Dictionary(uniqueKeysWithValues: cylinders.map { entry in
            let cylinder = entry.cylinder
            return (
                entry.gas.label,
                GasCylinderAllocation(
                    gasLabel: entry.gas.label,
                    role: entry.role,
                    cylinderVolumeLiters: cylinder.volumeLiters,
                    startPressureBar: cylinder.startPressureBar,
                    reservePressureBar: cylinder.reservePressureBar
                )
            )
        })
    }

    private static func rockBottomLiters(input: GasPlanInput) -> Double {
        let averageAscentATA = IOSUnitConversions.ambientPressureBar(depthMeters: input.plannedDepthMeters / 2.0)
        let ascentMinutes = max(3, input.plannedDepthMeters / 9.0)
        let emergencyMinutes = 1.0 + ascentMinutes + (input.plannedDepthMeters > 10 ? 3.0 : 0.0)
        return input.emergencySacLitersPerMinute * max(1, input.teamSize) * averageAscentATA * emergencyMinutes
    }
}
