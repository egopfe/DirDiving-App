import Foundation

enum ApneaSessionPlanKind: String, Codable, CaseIterable, Hashable, Sendable {
    case custom
    case pyramid
    case repeatedDepth
}

enum ApneaWatchPlanTransferState: String, Codable, CaseIterable, Hashable, Sendable {
    case draft
    case validated
    case sending
    case queued
    case awaitingAck
    case delivered
    case failed
}

struct ApneaPlannedDiveEntry: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var orderIndex: Int
    var targetDepthMeters: Double
    var targetDurationSeconds: TimeInterval
    var plannedRecoverySeconds: TimeInterval
    var note: String?

    init(
        id: UUID = UUID(),
        orderIndex: Int,
        targetDepthMeters: Double,
        targetDurationSeconds: TimeInterval,
        plannedRecoverySeconds: TimeInterval,
        note: String? = nil
    ) {
        self.id = id
        self.orderIndex = orderIndex
        self.targetDepthMeters = targetDepthMeters
        self.targetDurationSeconds = targetDurationSeconds
        self.plannedRecoverySeconds = plannedRecoverySeconds
        self.note = note
    }
}

struct ApneaSessionPlan: Identifiable, Codable, Hashable, Sendable {
    static let currentSchemaVersion = 1

    let id: UUID
    var schemaVersion: Int
    var profileID: UUID?
    var kind: ApneaSessionPlanKind
    var title: String
    var entries: [ApneaPlannedDiveEntry]
    var recoveryPolicy: ApneaRecoveryPolicy
    var alarms: [ApneaAlarm]
    var markers: [ApneaDepthMarker]
    var notes: String?
    var transferState: ApneaWatchPlanTransferState
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        schemaVersion: Int = ApneaSessionPlan.currentSchemaVersion,
        profileID: UUID? = nil,
        kind: ApneaSessionPlanKind = .custom,
        title: String = "",
        entries: [ApneaPlannedDiveEntry] = [],
        recoveryPolicy: ApneaRecoveryPolicy = .default,
        alarms: [ApneaAlarm] = [],
        markers: [ApneaDepthMarker] = [],
        notes: String? = nil,
        transferState: ApneaWatchPlanTransferState = .draft,
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.schemaVersion = schemaVersion
        self.profileID = profileID
        self.kind = kind
        self.title = title
        self.entries = entries
        self.recoveryPolicy = recoveryPolicy
        self.alarms = alarms
        self.markers = markers
        self.notes = notes
        self.transferState = transferState
        self.updatedAt = updatedAt
    }

    var estimatedUnderwaterSeconds: TimeInterval {
        entries.reduce(0) { $0 + max(0, $1.targetDurationSeconds) }
    }

    var estimatedRecoverySeconds: TimeInterval {
        entries.reduce(0) { $0 + max(0, $1.plannedRecoverySeconds) }
    }
}

struct ApneaSessionPlanTransferPayload: Codable, Hashable, Sendable {
    static let messageKey = "apnea_session_plan_v1"

    var plan: ApneaSessionPlan
    var profileID: UUID?
    var sentAt: Date
}
