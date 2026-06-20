import Foundation

/// Deterministic policy for legacy oversized iCloud KVS snapshots (MAIN-DCA-003).
enum CloudSyncLegacyMigrationPolicy {
    enum IncomingPayloadDecision: Equatable {
        case usePayload
        case ignoreLegacyOversizedPerKey
        case ignoreEmpty
    }

    enum OutgoingWriteDecision: Equatable {
        case allowed
        case blockedPerKey(actual: Int)
        case blockedAggregate(projected: Int, limit: Int)
    }

    enum PartialMigrationOutcome: Equatable {
        case fullyMigrated
        case partialMigrationKeptLocal
        case nothingToMigrate
        case idempotentNoOp
    }

    static func incomingPayloadDecision(byteCount: Int, perKeyLimit: Int = CloudSyncBudgetPolicy.maxPerKeyBytes) -> IncomingPayloadDecision {
        guard byteCount > 0 else { return .ignoreEmpty }
        guard byteCount <= perKeyLimit else { return .ignoreLegacyOversizedPerKey }
        return .usePayload
    }

    static func outgoingWriteDecision(
        key: String,
        newData: Data,
        existingFootprints: [CloudSyncBudgetPolicy.KeyFootprint],
        replacingKey: String? = nil
    ) -> OutgoingWriteDecision {
        switch CloudSyncBudgetPolicy.evaluateWrite(
            key: key,
            newData: newData,
            existingFootprints: existingFootprints,
            replacingKey: replacingKey
        ) {
        case .allowed:
            return .allowed
        case .perKeyExceeded(let actual):
            return .blockedPerKey(actual: actual)
        case .aggregateExceeded(let projectedTotal, let limit):
            return .blockedAggregate(projected: projectedTotal, limit: limit)
        }
    }

    static func evaluatePartialMigration(
        hasLocalData: Bool,
        writeDecision: OutgoingWriteDecision,
        alreadyCloudSynced: Bool
    ) -> PartialMigrationOutcome {
        guard hasLocalData else { return .nothingToMigrate }
        switch writeDecision {
        case .allowed:
            return alreadyCloudSynced ? .idempotentNoOp : .fullyMigrated
        case .blockedPerKey, .blockedAggregate:
            return .partialMigrationKeptLocal
        }
    }

    static func isExactPerKeyBoundary(byteCount: Int, perKeyLimit: Int = CloudSyncBudgetPolicy.maxPerKeyBytes) -> Bool {
        byteCount == perKeyLimit
    }

    static func isOneByteOverPerKey(byteCount: Int, perKeyLimit: Int = CloudSyncBudgetPolicy.maxPerKeyBytes) -> Bool {
        byteCount == perKeyLimit + 1
    }
}
