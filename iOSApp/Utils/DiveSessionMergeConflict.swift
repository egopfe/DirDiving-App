import Foundation

struct DiveSessionMergeConflict: Identifiable, Hashable {
    let sessionID: UUID
    let fieldName: String
    let localValue: String
    let cloudValue: String

    var id: String { "\(sessionID.uuidString)-\(fieldName)" }

    var userMessage: String {
        String(
            format: String(localized: "cloud.merge.conflict.format"),
            fieldName,
            localValue,
            cloudValue
        )
    }
}

enum DiveSessionMergeConflictDetector {
    static func detect(local: [DiveSession], cloud: [DiveSession]) -> [DiveSessionMergeConflict] {
        let dedupedLocal = DiveSessionCollectionIntegrity.deduplicated(local)
        let dedupedCloud = DiveSessionCollectionIntegrity.deduplicated(cloud)
        var conflicts = duplicateSessionIDConflicts(
            localDuplicates: dedupedLocal.duplicateSessionIDs,
            cloudDuplicates: dedupedCloud.duplicateSessionIDs
        )
        let cloudByID = Dictionary(uniqueKeysWithValues: dedupedCloud.sessions.map { ($0.id, $0) })
        for localSession in dedupedLocal.sessions {
            guard let cloudSession = cloudByID[localSession.id] else { continue }
            conflicts.append(contentsOf: detect(local: localSession, cloud: cloudSession))
        }
        return conflicts
    }

    private static func duplicateSessionIDConflicts(
        localDuplicates: [UUID],
        cloudDuplicates: [UUID]
    ) -> [DiveSessionMergeConflict] {
        var conflicts: [DiveSessionMergeConflict] = []
        for sessionID in localDuplicates {
            conflicts.append(
                DiveSessionMergeConflict(
                    sessionID: sessionID,
                    fieldName: "duplicateSessionID",
                    localValue: String(localized: "cloud.merge.duplicate_session.local"),
                    cloudValue: "—"
                )
            )
        }
        for sessionID in cloudDuplicates where !localDuplicates.contains(sessionID) {
            conflicts.append(
                DiveSessionMergeConflict(
                    sessionID: sessionID,
                    fieldName: "duplicateSessionID",
                    localValue: "—",
                    cloudValue: String(localized: "cloud.merge.duplicate_session.cloud")
                )
            )
        }
        return conflicts
    }

    static func detect(local: DiveSession, cloud: DiveSession) -> [DiveSessionMergeConflict] {
        var conflicts: [DiveSessionMergeConflict] = []
        appendConflict(
            &conflicts,
            sessionID: local.id,
            fieldName: "siteName",
            local: local.siteName,
            cloud: cloud.siteName
        )
        appendConflict(
            &conflicts,
            sessionID: local.id,
            fieldName: "buddy",
            local: local.buddy,
            cloud: cloud.buddy
        )
        appendConflict(
            &conflicts,
            sessionID: local.id,
            fieldName: "notes",
            local: local.notes,
            cloud: cloud.notes
        )
        appendConflict(
            &conflicts,
            sessionID: local.id,
            fieldName: "equipmentUsed",
            local: local.equipmentUsed,
            cloud: cloud.equipmentUsed
        )
        appendConflict(
            &conflicts,
            sessionID: local.id,
            fieldName: "entryPressureText",
            local: local.entryPressureText,
            cloud: cloud.entryPressureText
        )
        appendConflict(
            &conflicts,
            sessionID: local.id,
            fieldName: "exitPressureText",
            local: local.exitPressureText,
            cloud: cloud.exitPressureText
        )
        appendConflict(
            &conflicts,
            sessionID: local.id,
            fieldName: "decompressionNotes",
            local: local.decompressionNotes,
            cloud: cloud.decompressionNotes
        )
        if local.gasLabel != cloud.gasLabel {
            conflicts.append(
                DiveSessionMergeConflict(
                    sessionID: local.id,
                    fieldName: "gasLabel",
                    localValue: local.gasLabel.rawValue,
                    cloudValue: cloud.gasLabel.rawValue
                )
            )
        }
        if local.isManual != cloud.isManual {
            conflicts.append(
                DiveSessionMergeConflict(
                    sessionID: local.id,
                    fieldName: "isManual",
                    localValue: local.isManual ? "1" : "0",
                    cloudValue: cloud.isManual ? "1" : "0"
                )
            )
        }
        if let localSAC = local.sacLitersMinute, let cloudSAC = cloud.sacLitersMinute, abs(localSAC - cloudSAC) > 0.01 {
            conflicts.append(
                DiveSessionMergeConflict(
                    sessionID: local.id,
                    fieldName: "sacLitersMinute",
                    localValue: String(format: "%.2f", localSAC),
                    cloudValue: String(format: "%.2f", cloudSAC)
                )
            )
        } else if (local.sacLitersMinute == nil) != (cloud.sacLitersMinute == nil) {
            conflicts.append(
                DiveSessionMergeConflict(
                    sessionID: local.id,
                    fieldName: "sacLitersMinute",
                    localValue: local.sacLitersMinute.map { String(format: "%.2f", $0) } ?? "—",
                    cloudValue: cloud.sacLitersMinute.map { String(format: "%.2f", $0) } ?? "—"
                )
            )
        }
        if abs(local.endDate.timeIntervalSince1970 - cloud.endDate.timeIntervalSince1970) > 1 {
            let formatter = ISO8601DateFormatter()
            conflicts.append(
                DiveSessionMergeConflict(
                    sessionID: local.id,
                    fieldName: "endDate",
                    localValue: formatter.string(from: local.endDate),
                    cloudValue: formatter.string(from: cloud.endDate)
                )
            )
        }
        if DiveSessionProfileDivergence.profilesDiverge(local, cloud) {
            conflicts.append(
                DiveSessionMergeConflict(
                    sessionID: local.id,
                    fieldName: String(localized: "cloud.merge.field.depth_profile"),
                    localValue: DiveSessionProfileDivergence.profileSummary(local),
                    cloudValue: DiveSessionProfileDivergence.profileSummary(cloud)
                )
            )
        }
        return conflicts
    }

    private static func appendConflict(
        _ conflicts: inout [DiveSessionMergeConflict],
        sessionID: UUID,
        fieldName: String,
        local: String?,
        cloud: String?
    ) {
        let normalizedLocal = normalized(local)
        let normalizedCloud = normalized(cloud)
        guard normalizedLocal != normalizedCloud else { return }
        conflicts.append(
            DiveSessionMergeConflict(
                sessionID: sessionID,
                fieldName: fieldName,
                localValue: normalizedLocal ?? "—",
                cloudValue: normalizedCloud ?? "—"
            )
        )
    }

    private static func normalized(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
