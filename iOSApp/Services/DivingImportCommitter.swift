import Foundation

@MainActor
enum DivingImportCommitter {
    static func commit(
        selectedCandidates: [DivingImportCandidate],
        into logStore: DiveLogStore,
        duplicatePolicy: DivingImportDuplicatePolicy = .skipDuplicates
    ) -> DivingImportCommitReport {
        var importedCount = 0
        var skippedDuplicateCount = 0
        var failedCount = 0
        var warningsCount = 0
        var importedSessionIDs: [UUID] = []

        for candidate in selectedCandidates {
            guard candidate.isImportable else {
                failedCount += 1
                continue
            }
            warningsCount += candidate.warnings.count
            let status = DivingImportDeduplicator.classify(candidate: candidate, existingSessions: logStore.sessions)
            switch status {
            case .exactDuplicate, .likelyDuplicate:
                if duplicatePolicy == .skipDuplicates {
                    skippedDuplicateCount += 1
                    continue
                }
            case .new:
                break
            }

            let enriched = DivingImportNotesBuilder.appendImportMetadata(
                to: candidate.session,
                format: candidate.sourceFormat,
                fileName: candidate.sourceFileName,
                computerModel: candidate.sourceComputerModel,
                sourceDiveID: candidate.sourceDiveID,
                warnings: candidate.warnings
            )
            if logStore.add(enriched) {
                importedCount += 1
                importedSessionIDs.append(enriched.id)
            } else {
                failedCount += 1
            }
        }

        return DivingImportCommitReport(
            importedCount: importedCount,
            skippedDuplicateCount: skippedDuplicateCount,
            failedCount: failedCount,
            warningsCount: warningsCount,
            importedSessionIDs: importedSessionIDs
        )
    }
}

enum DivingImportCoordinator {
    @MainActor
    static func commit(
        rows: [DivingImportPreviewRow],
        into logStore: DiveLogStore,
        duplicatePolicy: DivingImportDuplicatePolicy = .skipDuplicates
    ) -> DivingImportCommitReport {
        let selected = rows.filter(\.isSelected).map(\.candidate)
        return DivingImportCommitter.commit(
            selectedCandidates: selected,
            into: logStore,
            duplicatePolicy: duplicatePolicy
        )
    }
}
