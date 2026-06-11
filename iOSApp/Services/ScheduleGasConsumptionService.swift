import Foundation

enum GasUsageWarningState: Hashable {
    case reserveBreached(gas: String)
    case minimumGasBreached(gas: String)
    case lostGasContingencyFailed(gas: String)
    case invalidAllocation(gas: String)
}

struct GasCylinderAllocation: Hashable {
    let cylinderId: UUID
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
        let cylinderId: UUID
        let gasLabel: String
        let role: GasRole
        let consumedLiters: Double
        let remainingLiters: Double
        let remainingBar: Double
    }

    struct UnusedPlannedEntry: Hashable {
        let cylinderId: UUID
        let gasLabel: String
        let role: GasRole
        let availableLiters: Double
        let availableBar: Double
        let isStandbyOrBailout: Bool
    }

    let entries: [Entry]
    /// Planned cylinders not referenced by the generated Bühlmann schedule (includes bailout/standby).
    /// `totalConsumedLiters` counts schedule gases only; unused entries are informational.
    let unusedPlannedEntries: [UnusedPlannedEntry]
    let totalConsumedLiters: Double
    let totalRemainingLiters: Double
    let warnings: [GasUsageWarningState]

    func entry(for cylinderId: UUID) -> Entry? {
        entries.first { $0.cylinderId == cylinderId }
    }

    func bottomGasEntry(from input: GasPlanInput) -> Entry? {
        if let bottomId = input.plannerCylinders.first(where: { $0.role == .bottom })?.id,
           let entry = entry(for: bottomId) {
            return entry
        }
        return entries.first(where: { $0.role == .bottom }) ?? entries.first
    }
}

enum ScheduleGasConsumptionService {
    enum Error: Swift.Error, Hashable {
        case invalidSegment
        case missingCylinderAllocation(UUID)
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

        var consumedByCylinder: [UUID: Double] = [:]
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
            let key = segment.gas.allocationKey
            consumedByCylinder[key, default: 0] += consumed
        }

        var entries: [GasConsumptionLedger.Entry] = []
        var unusedPlannedEntries: [GasConsumptionLedger.UnusedPlannedEntry] = []
        var warnings: [GasUsageWarningState] = []
        var totalConsumed = 0.0
        var totalRemaining = 0.0
        let rockBottom = rockBottomLiters(input: input, environment: environment)

        for (cylinderId, consumed) in consumedByCylinder {
            guard let allocation = allocations[cylinderId] else {
                return .failure(.missingCylinderAllocation(cylinderId))
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
                warnings.append(.reserveBreached(gas: allocation.gasLabel))
            }
            if remainingLiters < rockBottom {
                warnings.append(.minimumGasBreached(gas: allocation.gasLabel))
            }
            if remainingLiters - (consumed * 0.3) < allocation.reserveLiters {
                warnings.append(.lostGasContingencyFailed(gas: allocation.gasLabel))
            }

            entries.append(
                .init(
                    cylinderId: cylinderId,
                    gasLabel: allocation.gasLabel,
                    role: allocation.role,
                    consumedLiters: consumed,
                    remainingLiters: remainingLiters,
                    remainingBar: remainingBar
                )
            )
            totalConsumed += consumed
            totalRemaining += remainingLiters
        }

        let consumedCylinderIDs = Set(consumedByCylinder.keys)
        for (cylinderId, allocation) in allocations where !consumedCylinderIDs.contains(cylinderId) {
            let availableLiters = allocation.startLiters
            let availableBar = allocation.cylinderVolumeLiters > 0 ? availableLiters / allocation.cylinderVolumeLiters : 0
            unusedPlannedEntries.append(
                .init(
                    cylinderId: cylinderId,
                    gasLabel: allocation.gasLabel,
                    role: allocation.role,
                    availableLiters: availableLiters,
                    availableBar: availableBar,
                    isStandbyOrBailout: allocation.role == .bailout || allocation.role == .travel
                )
            )
        }

        return .success(
            GasConsumptionLedger(
                entries: entries.sorted { lhs, rhs in
                    if lhs.role.sortOrder != rhs.role.sortOrder {
                        return lhs.role.sortOrder < rhs.role.sortOrder
                    }
                    return lhs.gasLabel < rhs.gasLabel
                },
                unusedPlannedEntries: unusedPlannedEntries.sorted { lhs, rhs in
                    if lhs.role.sortOrder != rhs.role.sortOrder {
                        return lhs.role.sortOrder < rhs.role.sortOrder
                    }
                    return lhs.gasLabel < rhs.gasLabel
                },
                totalConsumedLiters: totalConsumed,
                totalRemainingLiters: totalRemaining,
                warnings: warnings
            )
        )
    }

    private static func makeAllocations(input: GasPlanInput) -> [UUID: GasCylinderAllocation] {
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

        var result: [UUID: GasCylinderAllocation] = [:]
        for entry in cylinders {
            let cylinder = entry.cylinder
            result[entry.id] = GasCylinderAllocation(
                cylinderId: entry.id,
                gasLabel: entry.gas.label,
                role: entry.role,
                cylinderVolumeLiters: cylinder.volumeLiters,
                startPressureBar: cylinder.startPressureBar,
                reservePressureBar: cylinder.reservePressureBar
            )
        }
        return result
    }

    static func automaticAscentMinutes(plannedDepthMeters: Double) -> Double {
        guard plannedDepthMeters.isFinite else { return 3 }
        return max(3, plannedDepthMeters / 9.0)
    }

    static func normalizedEmergencyExtraMinutes(_ minutes: Double) -> Double {
        guard minutes.isFinite else { return IOSAlgorithmConfiguration.defaultEmergencyExtraMinutes }
        return min(
            IOSAlgorithmConfiguration.maxEmergencyExtraMinutes,
            max(0, minutes)
        )
    }

    static func normalizedTeamSize(_ teamSize: Double) -> Double {
        guard teamSize.isFinite else { return 2 }
        return min(
            IOSAlgorithmConfiguration.maxPlannerEmergencyTeamSize,
            max(1, teamSize.rounded())
        )
    }

    static func emergencyMinutesUsed(input: GasPlanInput) -> Double {
        automaticAscentMinutes(plannedDepthMeters: input.plannedDepthMeters)
            + normalizedEmergencyExtraMinutes(input.emergencyExtraMinutes)
    }

    static func rockBottomLiters(input: GasPlanInput, environment: PlannerEnvironment) -> Double {
        let averageAscentDepth = input.plannedDepthMeters / 2.0
        let averageAscentATA = AmbientPressureModel.ambientPressureBar(depthMeters: averageAscentDepth, environment: environment) ?? environment.surfacePressureBar
        let emergencyMinutes = emergencyMinutesUsed(input: input)
        let value = input.emergencySacLitersPerMinute
            * normalizedTeamSize(input.teamSize)
            * averageAscentATA
            * emergencyMinutes
        guard value.isFinite, value >= 0 else { return 0 }
        return value
    }
}

private extension GasRole {
    var sortOrder: Int {
        switch self {
        case .bottom: return 0
        case .travel: return 1
        case .deco: return 2
        case .bailout: return 3
        case .ccrDiluent: return 4
        case .ccrBailout: return 5
        }
    }
}
