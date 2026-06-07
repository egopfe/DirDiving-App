import Foundation

enum PlannerResultState: String, Codable, Hashable, CaseIterable {
    case validReference
    case invalidInput
    case unsupportedDepth
    case unsupportedGas
    case unsupportedTrimix
    case basicNoDecoLimitExceeded
    case decoDepthLimitExceeded
    case unsupportedProfile
    case modelIncomplete
    case simplifiedReferenceOnly
    case nonCertifiedReference
    case unavailable
    case insufficientGas
    case belowReserve
    case MODExceeded
    case PPO2Exceeded
    case gasDensityWarning
    case gasDensityDanger
    case invalidEnvironment
    case gasAllocationIncomplete
    case oxygenExposureElevated
    case noValidDecompressionSolution
    case calculationIncomplete
    case repetitivePlanningActive
    case snapshotMissing
    case snapshotStale
    case snapshotCorrupt
    case snapshotSchemaMismatch
    case snapshotEnvironmentMismatch
    case missingCylinder
    case surfaceIntervalRejected

    var warningText: String? {
        userFacingMessage.message
    }

    var userFacingMessage: PlannerUserFacingMessage {
        PlannerUserFacingCopy.message(for: self)
    }
}

enum PlannerWarningSeverity: String, Codable, Hashable {
    case info
    case warning
    case blocking
}

struct PlannerUserFacingMessage: Hashable, Identifiable {
    let id: String
    let title: String
    let message: String
    let correctiveHint: String?
    let severity: PlannerWarningSeverity

    var accessibilityLabel: String {
        [title, message, correctiveHint].compactMap { $0 }.joined(separator: ". ")
    }
}

enum PlannerResultHeaderKind: String, Codable, Hashable, CaseIterable {
    case noDecoReference
    case decoRequiredReference
    case invalidInput
    case unsupportedProfile
    case noValidDecompressionSolution
    case calculationIncomplete
    case repetitiveReferencePlan
    case environmentAdjustedReferencePlan

    var presentation: PlannerUserFacingMessage {
        PlannerUserFacingCopy.header(for: self)
    }
}

struct PlannerResultHeader: Hashable {
    let kind: PlannerResultHeaderKind
    let title: String
    let subtitle: String
    let severity: PlannerWarningSeverity
}

struct RepetitivePlanningContext: Hashable {
    let enabled: Bool
    let surfaceIntervalMinutes: Double
    let snapshotAvailable: Bool
    let snapshotCreatedAt: Date?
    let snapshotSource: String?
    let tissueStateApplied: Bool
    let snapshotIssue: PlannerResultState?
}

struct PlannerEnvironmentSummary: Hashable {
    let isActive: Bool
    let altitudeMeters: Double
    let salinity: SalinityMode
    let surfacePressureBar: Double
    let waterDensityKgPerM3: Double
    let statusMessage: String
    let correctiveHint: String?
}

enum GasLedgerFailureReason: Hashable {
    case invalidSegment
    case missingCylinder(UUID)
    case invalidCylinder

    var userFacingMessage: PlannerUserFacingMessage {
        switch self {
        case .invalidSegment:
            return PlannerUserFacingCopy.localized(
                id: "gasLedger.invalidSegment",
                titleKey: "planner.gas_ledger.failure.segment.title",
                messageKey: "planner.gas_ledger.failure.segment.message",
                hintKey: "planner.gas_ledger.failure.segment.hint",
                severity: .blocking
            )
        case .missingCylinder(let id):
            return PlannerUserFacingCopy.localized(
                id: "gasLedger.missingCylinder.\(id.uuidString)",
                titleKey: "planner.gas_ledger.failure.missing_cylinder.title",
                messageKey: "planner.gas_ledger.failure.missing_cylinder.message",
                hintKey: "planner.gas_ledger.failure.missing_cylinder.hint",
                severity: .blocking
            )
        case .invalidCylinder:
            return PlannerUserFacingCopy.localized(
                id: "gasLedger.invalidCylinder",
                titleKey: "planner.gas_ledger.failure.cylinder.title",
                messageKey: "planner.gas_ledger.failure.cylinder.message",
                hintKey: "planner.gas_ledger.failure.cylinder.hint",
                severity: .blocking
            )
        }
    }
}

enum BuhlmannModelState: String, Codable, Hashable {
    case validReference
    case simplifiedReferenceOnly
    case unsupportedTrimix
    case modelIncomplete
    case unavailable
    case invalidInput
}

struct PlannerValidationResult: Hashable {
    var states: [PlannerResultState] = []
    var messages: [String] = []

    var isValid: Bool {
        !states.contains(.invalidInput)
            && !states.contains(.unsupportedDepth)
            && !states.contains(.unsupportedGas)
            && !states.contains(.unsupportedTrimix)
            && !states.contains(.basicNoDecoLimitExceeded)
            && !states.contains(.decoDepthLimitExceeded)
            && !states.contains(.unavailable)
            && !states.contains(.invalidEnvironment)
    }

    mutating func add(_ state: PlannerResultState, message: String? = nil) {
        if !states.contains(state) {
            states.append(state)
        }
        if let message, !messages.contains(message) {
            messages.append(message)
        } else if let warning = state.warningText, !messages.contains(warning) {
            messages.append(warning)
        }
    }

    mutating func merge(_ other: PlannerValidationResult) {
        other.states.forEach { add($0) }
        other.messages.forEach { message in
            if !messages.contains(message) {
                messages.append(message)
            }
        }
    }
}

enum PlannerUserFacingCopy {
    static func message(for state: PlannerResultState) -> PlannerUserFacingMessage {
        switch state {
        case .validReference:
            return localized(
                id: state.rawValue,
                titleKey: "planner.state.valid_reference.title",
                messageKey: "planner.state.valid_reference.message",
                hintKey: nil,
                severity: .info
            )
        case .invalidInput:
            return localized(
                id: state.rawValue,
                titleKey: "planner.state.invalid_input.title",
                messageKey: "planner.state.invalid_input.message",
                hintKey: "planner.state.invalid_input.hint",
                severity: .blocking
            )
        case .unsupportedDepth:
            return localized(
                id: state.rawValue,
                titleKey: "planner.state.unsupported_depth.title",
                messageKey: "planner.state.unsupported_depth.message",
                hintKey: "planner.state.unsupported_depth.hint",
                severity: .blocking
            )
        case .unsupportedGas:
            return localized(
                id: state.rawValue,
                titleKey: "planner.state.unsupported_gas.title",
                messageKey: "planner.state.unsupported_gas.message",
                hintKey: "planner.state.unsupported_gas.hint",
                severity: .blocking
            )
        case .unsupportedTrimix:
            return localized(
                id: state.rawValue,
                titleKey: "planner.state.unsupported_trimix.title",
                messageKey: "planner.state.unsupported_trimix.message",
                hintKey: "planner.state.unsupported_trimix.hint",
                severity: .warning
            )
        case .basicNoDecoLimitExceeded:
            return localized(
                id: state.rawValue,
                titleKey: "planner.mode.basic.no_deco.title",
                messageKey: "planner.mode.basic.no_deco.message",
                hintKey: "planner.mode.basic.no_deco.hint",
                severity: .blocking
            )
        case .decoDepthLimitExceeded:
            return localized(
                id: state.rawValue,
                titleKey: "planner.mode.deco.depth_limit.title",
                messageKey: "planner.mode.deco.depth_limit.message",
                hintKey: "planner.mode.deco.depth_limit.hint",
                severity: .blocking
            )
        case .unsupportedProfile:
            return localized(
                id: state.rawValue,
                titleKey: "planner.state.unsupported_profile.title",
                messageKey: "planner.state.unsupported_profile.message",
                hintKey: "planner.state.unsupported_profile.hint",
                severity: .blocking
            )
        case .modelIncomplete:
            return localized(
                id: state.rawValue,
                titleKey: "planner.state.model_incomplete.title",
                messageKey: "planner.state.model_incomplete.message",
                hintKey: "planner.state.model_incomplete.hint",
                severity: .warning
            )
        case .simplifiedReferenceOnly:
            return localized(
                id: state.rawValue,
                titleKey: "planner.state.simplified_reference.title",
                messageKey: "planner.state.simplified_reference.message",
                hintKey: "planner.state.simplified_reference.hint",
                severity: .info
            )
        case .nonCertifiedReference:
            return localized(
                id: state.rawValue,
                titleKey: "planner.state.non_certified.title",
                messageKey: "planner.state.non_certified.message",
                hintKey: "planner.state.non_certified.hint",
                severity: .info
            )
        case .unavailable:
            return localized(
                id: state.rawValue,
                titleKey: "planner.state.unavailable.title",
                messageKey: "planner.state.unavailable.message",
                hintKey: "planner.state.unavailable.hint",
                severity: .blocking
            )
        case .insufficientGas:
            return localized(
                id: state.rawValue,
                titleKey: "planner.state.insufficient_gas.title",
                messageKey: "planner.state.insufficient_gas.message",
                hintKey: "planner.state.insufficient_gas.hint",
                severity: .blocking
            )
        case .belowReserve:
            return localized(
                id: state.rawValue,
                titleKey: "planner.state.below_reserve.title",
                messageKey: "planner.state.below_reserve.message",
                hintKey: "planner.state.below_reserve.hint",
                severity: .blocking
            )
        case .MODExceeded:
            return localized(
                id: state.rawValue,
                titleKey: "planner.state.mod_exceeded.title",
                messageKey: "planner.state.mod_exceeded.message",
                hintKey: "planner.state.mod_exceeded.hint",
                severity: .blocking
            )
        case .PPO2Exceeded:
            return localized(
                id: state.rawValue,
                titleKey: "planner.state.ppo2_exceeded.title",
                messageKey: "planner.state.ppo2_exceeded.message",
                hintKey: "planner.state.ppo2_exceeded.hint",
                severity: .blocking
            )
        case .gasDensityWarning:
            return localized(
                id: state.rawValue,
                titleKey: "planner.state.gas_density_warning.title",
                messageKey: "planner.state.gas_density_warning.message",
                hintKey: "planner.state.gas_density_warning.hint",
                severity: .warning
            )
        case .gasDensityDanger:
            return localized(
                id: state.rawValue,
                titleKey: "planner.state.gas_density_danger.title",
                messageKey: "planner.state.gas_density_danger.message",
                hintKey: "planner.state.gas_density_danger.hint",
                severity: .blocking
            )
        case .invalidEnvironment:
            return localized(
                id: state.rawValue,
                titleKey: "planner.state.invalid_environment.title",
                messageKey: "planner.state.invalid_environment.message",
                hintKey: "planner.state.invalid_environment.hint",
                severity: .blocking
            )
        case .gasAllocationIncomplete:
            return localized(
                id: state.rawValue,
                titleKey: "planner.state.gas_allocation_incomplete.title",
                messageKey: "planner.state.gas_allocation_incomplete.message",
                hintKey: "planner.state.gas_allocation_incomplete.hint",
                severity: .blocking
            )
        case .oxygenExposureElevated:
            return localized(
                id: state.rawValue,
                titleKey: "planner.state.oxygen_exposure.title",
                messageKey: "planner.state.oxygen_exposure.message",
                hintKey: "planner.state.oxygen_exposure.hint",
                severity: .warning
            )
        case .noValidDecompressionSolution:
            return localized(
                id: state.rawValue,
                titleKey: "planner.state.no_deco_solution.title",
                messageKey: "planner.state.no_deco_solution.message",
                hintKey: "planner.state.no_deco_solution.hint",
                severity: .blocking
            )
        case .calculationIncomplete:
            return localized(
                id: state.rawValue,
                titleKey: "planner.state.calculation_incomplete.title",
                messageKey: "planner.state.calculation_incomplete.message",
                hintKey: "planner.state.calculation_incomplete.hint",
                severity: .blocking
            )
        case .repetitivePlanningActive:
            return localized(
                id: state.rawValue,
                titleKey: "planner.state.repetitive_active.title",
                messageKey: "planner.state.repetitive_active.message",
                hintKey: "planner.state.repetitive_active.hint",
                severity: .info
            )
        case .snapshotMissing:
            return localized(
                id: state.rawValue,
                titleKey: "planner.state.snapshot_missing.title",
                messageKey: "planner.state.snapshot_missing.message",
                hintKey: "planner.state.snapshot_missing.hint",
                severity: .blocking
            )
        case .snapshotStale:
            return localized(
                id: state.rawValue,
                titleKey: "planner.state.snapshot_stale.title",
                messageKey: "planner.state.snapshot_stale.message",
                hintKey: "planner.state.snapshot_stale.hint",
                severity: .blocking
            )
        case .snapshotCorrupt:
            return localized(
                id: state.rawValue,
                titleKey: "planner.state.snapshot_corrupt.title",
                messageKey: "planner.state.snapshot_corrupt.message",
                hintKey: "planner.state.snapshot_corrupt.hint",
                severity: .blocking
            )
        case .snapshotSchemaMismatch:
            return localized(
                id: state.rawValue,
                titleKey: "planner.state.snapshot_schema.title",
                messageKey: "planner.state.snapshot_schema.message",
                hintKey: "planner.state.snapshot_schema.hint",
                severity: .blocking
            )
        case .snapshotEnvironmentMismatch:
            return localized(
                id: state.rawValue,
                titleKey: "planner.state.snapshot_environment.title",
                messageKey: "planner.state.snapshot_environment.message",
                hintKey: "planner.state.snapshot_environment.hint",
                severity: .blocking
            )
        case .missingCylinder:
            return localized(
                id: state.rawValue,
                titleKey: "planner.state.missing_cylinder.title",
                messageKey: "planner.state.missing_cylinder.message",
                hintKey: "planner.state.missing_cylinder.hint",
                severity: .blocking
            )
        case .surfaceIntervalRejected:
            return localized(
                id: state.rawValue,
                titleKey: "planner.state.surface_interval.title",
                messageKey: "planner.state.surface_interval.message",
                hintKey: "planner.state.surface_interval.hint",
                severity: .blocking
            )
        }
    }

    static func header(for kind: PlannerResultHeaderKind) -> PlannerUserFacingMessage {
        switch kind {
        case .noDecoReference:
            return localized(
                id: kind.rawValue,
                titleKey: "planner.header.no_deco.title",
                messageKey: "planner.header.no_deco.message",
                hintKey: "planner.header.reference_only.hint",
                severity: .info
            )
        case .decoRequiredReference:
            return localized(
                id: kind.rawValue,
                titleKey: "planner.header.deco_required.title",
                messageKey: "planner.header.deco_required.message",
                hintKey: "planner.header.reference_only.hint",
                severity: .warning
            )
        case .invalidInput:
            return localized(
                id: kind.rawValue,
                titleKey: "planner.header.invalid_input.title",
                messageKey: "planner.header.invalid_input.message",
                hintKey: "planner.header.invalid_input.hint",
                severity: .blocking
            )
        case .unsupportedProfile:
            return localized(
                id: kind.rawValue,
                titleKey: "planner.header.unsupported_profile.title",
                messageKey: "planner.header.unsupported_profile.message",
                hintKey: "planner.header.unsupported_profile.hint",
                severity: .blocking
            )
        case .noValidDecompressionSolution:
            return localized(
                id: kind.rawValue,
                titleKey: "planner.header.no_deco_solution.title",
                messageKey: "planner.header.no_deco_solution.message",
                hintKey: "planner.header.no_deco_solution.hint",
                severity: .blocking
            )
        case .calculationIncomplete:
            return localized(
                id: kind.rawValue,
                titleKey: "planner.header.calculation_incomplete.title",
                messageKey: "planner.header.calculation_incomplete.message",
                hintKey: "planner.header.calculation_incomplete.hint",
                severity: .blocking
            )
        case .repetitiveReferencePlan:
            return localized(
                id: kind.rawValue,
                titleKey: "planner.header.repetitive.title",
                messageKey: "planner.header.repetitive.message",
                hintKey: "planner.header.reference_only.hint",
                severity: .info
            )
        case .environmentAdjustedReferencePlan:
            return localized(
                id: kind.rawValue,
                titleKey: "planner.header.environment.title",
                messageKey: "planner.header.environment.message",
                hintKey: "planner.header.reference_only.hint",
                severity: .info
            )
        }
    }

    static func snapshotIssue(for error: RepetitiveDivePlannerService.SnapshotError) -> PlannerResultState {
        switch error {
        case .missing: return .snapshotMissing
        case .corrupted: return .snapshotCorrupt
        case .stale: return .snapshotStale
        case .schemaMismatch: return .snapshotSchemaMismatch
        case .invalidEnvironment: return .snapshotEnvironmentMismatch
        case .invalidSurfaceInterval: return .surfaceIntervalRejected
        }
    }

    static func gasUsageWarning(for warning: GasUsageWarningState) -> PlannerUserFacingMessage {
        switch warning {
        case .reserveBreached(let gas):
            return localized(
                id: "reserve.\(gas)",
                titleKey: "planner.gas_ledger.warning.reserve.title",
                messageKey: "planner.gas_ledger.warning.reserve.message",
                hintKey: "planner.gas_ledger.warning.reserve.hint",
                severity: .blocking,
                arguments: [gas]
            )
        case .minimumGasBreached(let gas):
            return localized(
                id: "minimum.\(gas)",
                titleKey: "planner.gas_ledger.warning.minimum.title",
                messageKey: "planner.gas_ledger.warning.minimum.message",
                hintKey: "planner.gas_ledger.warning.minimum.hint",
                severity: .blocking,
                arguments: [gas]
            )
        case .lostGasContingencyFailed(let gas):
            return localized(
                id: "lost.\(gas)",
                titleKey: "planner.gas_ledger.warning.lost_gas.title",
                messageKey: "planner.gas_ledger.warning.lost_gas.message",
                hintKey: "planner.gas_ledger.warning.lost_gas.hint",
                severity: .warning,
                arguments: [gas]
            )
        case .invalidAllocation(let gas):
            return localized(
                id: "allocation.\(gas)",
                titleKey: "planner.gas_ledger.warning.allocation.title",
                messageKey: "planner.gas_ledger.warning.allocation.message",
                hintKey: "planner.gas_ledger.warning.allocation.hint",
                severity: .blocking,
                arguments: [gas]
            )
        }
    }

    static func environmentSummary(for environment: PlannerEnvironment) -> PlannerEnvironmentSummary {
        let isDefault = abs(environment.altitudeMeters) < 0.01 && environment.salinity == .salt
        return PlannerEnvironmentSummary(
            isActive: !isDefault,
            altitudeMeters: environment.altitudeMeters,
            salinity: environment.salinity,
            surfacePressureBar: environment.surfacePressureBar,
            waterDensityKgPerM3: environment.waterDensityKgPerM3,
            statusMessage: isDefault
                ? String(localized: "planner.environment.default.message")
                : String(localized: "planner.environment.active.message"),
            correctiveHint: nil
        )
    }

    static func invalidEnvironmentSummary(for input: GasPlanInput, error: PlannerEnvironmentError) -> PlannerEnvironmentSummary {
        let message: String
        let hint: String
        switch error {
        case .invalidAltitude:
            message = String(localized: "planner.environment.invalid_altitude.message")
            hint = String(localized: "planner.environment.invalid_altitude.hint")
        case .invalidSalinity:
            message = String(localized: "planner.environment.invalid_salinity.message")
            hint = String(localized: "planner.environment.invalid_salinity.hint")
        }
        return PlannerEnvironmentSummary(
            isActive: false,
            altitudeMeters: input.altitudeMeters,
            salinity: input.salinity,
            surfacePressureBar: 0,
            waterDensityKgPerM3: 0,
            statusMessage: message,
            correctiveHint: hint
        )
    }

    static func userFacingWarnings(from states: [PlannerResultState]) -> [PlannerUserFacingMessage] {
        states
            .filter { $0 != .validReference }
            .map(\.userFacingMessage)
    }

    static func localized(
        id: String,
        titleKey: String,
        messageKey: String,
        hintKey: String?,
        severity: PlannerWarningSeverity,
        arguments: [CVarArg] = []
    ) -> PlannerUserFacingMessage {
        let title = String(localized: String.LocalizationValue(titleKey))
        let message = arguments.isEmpty
            ? String(localized: String.LocalizationValue(messageKey))
            : String(format: String(localized: String.LocalizationValue(messageKey)), arguments: arguments)
        let hint = hintKey.map { String(localized: String.LocalizationValue($0)) }
        return PlannerUserFacingMessage(id: id, title: title, message: message, correctiveHint: hint, severity: severity)
    }
}

enum PlannerPresentationSupport {
    static func resultHeader(
        stops: [DecoStop],
        states: [PlannerResultState],
        repetitiveContext: RepetitivePlanningContext?,
        environment: PlannerEnvironment
    ) -> PlannerResultHeader {
        let presentation: PlannerUserFacingMessage
        let kind: PlannerResultHeaderKind

        if states.contains(where: { [.invalidInput, .unavailable].contains($0) }) {
            kind = .invalidInput
        } else if states.contains(.unsupportedProfile) {
            kind = .unsupportedProfile
        } else if states.contains(.calculationIncomplete) {
            kind = .calculationIncomplete
        } else if states.contains(.noValidDecompressionSolution) || states.contains(.modelIncomplete) && !stops.isEmpty {
            kind = .noValidDecompressionSolution
        } else if repetitiveContext?.tissueStateApplied == true {
            kind = .repetitiveReferencePlan
        } else if environment.altitudeMeters > 0.01 || environment.salinity == .fresh {
            kind = environmentAdjustedReferencePlanKind(stops: stops)
        } else if stops.isEmpty {
            kind = .noDecoReference
        } else {
            kind = .decoRequiredReference
        }

        presentation = PlannerUserFacingCopy.header(for: kind)
        var subtitle = presentation.message
        if kind == .repetitiveReferencePlan, !stops.isEmpty {
            subtitle = String(localized: "planner.header.repetitive.deco_subtitle")
        } else if kind == .environmentAdjustedReferencePlan, !stops.isEmpty {
            subtitle = String(localized: "planner.header.environment.deco_subtitle")
        } else if kind == .noDecoReference || kind == .decoRequiredReference {
            subtitle = presentation.message
        }

        return PlannerResultHeader(kind: kind, title: presentation.title, subtitle: subtitle, severity: presentation.severity)
    }

    private static func environmentAdjustedReferencePlanKind(stops: [DecoStop]) -> PlannerResultHeaderKind {
        stops.isEmpty ? .environmentAdjustedReferencePlan : .decoRequiredReference
    }
}
