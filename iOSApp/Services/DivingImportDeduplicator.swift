import Foundation

enum DivingImportDeduplicator {
    static func classify(
        candidate: DivingImportCandidate,
        existingSessions: [DiveSession]
    ) -> DivingImportDuplicateStatus {
        if let exact = existingSessions.first(where: { $0.id == candidate.session.id }) {
            return .exactDuplicate(existingID: exact.id)
        }
        if let sourceID = candidate.sourceDiveID,
           let match = existingSessions.first(where: { sessionNotesContainSourceID($0.notes, sourceID: sourceID) }) {
            return .exactDuplicate(existingID: match.id)
        }
        for existing in existingSessions {
            if isLikelyDuplicate(candidate: candidate, existing: existing) {
                return .likelyDuplicate(
                    existingID: existing.id,
                    reason: DIRIOSLocalizer.string("diving.import.status.likely_duplicate")
                )
            }
        }
        return .new
    }

    private static func isLikelyDuplicate(candidate: DivingImportCandidate, existing: DiveSession) -> Bool {
        let fp = candidate.fingerprint
        let existingFP = DivingImportFingerprint.make(from: existing, sourceDiveID: nil, sourceComputerModel: nil)
        guard abs(existing.startDate.timeIntervalSince(candidate.session.startDate)) <= DivingImportLimits.startDateToleranceSeconds else {
            return false
        }
        guard abs(existing.durationSeconds - candidate.session.durationSeconds) <= DivingImportLimits.durationToleranceSeconds else {
            return false
        }
        guard abs(existing.maxDepthMeters - candidate.session.maxDepthMeters) <= DivingImportLimits.maxDepthToleranceMeters else {
            return false
        }
        return fp.sampleCount == existingFP.sampleCount
            && fp.startDateBucket == existingFP.startDateBucket
    }

    private static func sessionNotesContainSourceID(_ notes: String?, sourceID: String) -> Bool {
        guard let notes else { return false }
        return notes.contains("Original dive ID: \(sourceID)")
    }
}

struct DivingImportPreviewRow: Identifiable, Hashable {
    let id: UUID
    let candidate: DivingImportCandidate
    let duplicateStatus: DivingImportDuplicateStatus
    var isSelected: Bool
}

extension DivingImportDeduplicator {
    static func buildPreviewRows(
        from preview: DivingImportPreviewResult,
        existingSessions: [DiveSession]
    ) -> [DivingImportPreviewRow] {
        preview.candidates.map { candidate in
            let status = classify(candidate: candidate, existingSessions: existingSessions)
            let selected: Bool = {
                guard candidate.isImportable else { return false }
                switch status {
                case .new: return true
                case .exactDuplicate, .likelyDuplicate: return false
                }
            }()
            return DivingImportPreviewRow(
                id: candidate.id,
                candidate: candidate,
                duplicateStatus: status,
                isSelected: selected
            )
        }
    }
}
