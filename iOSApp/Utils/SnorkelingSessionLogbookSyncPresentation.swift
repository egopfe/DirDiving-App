import Foundation

enum SnorkelingSessionImportBadge: Equatable {
    case none
    case pending
    case failed(String)
    case synced
}

struct SnorkelingSessionLogbookSyncPresentation: Equatable {
    var sourceKey: String
    var badgeKey: String?
    var badgeIsWarning: Bool
    var guidanceKey: String?
}

enum SnorkelingSessionLogbookSyncPresentationPolicy {
    static func startModeKey(for startMode: SnorkelingSessionStartMode) -> String {
        switch startMode {
        case .watch: return "snorkeling.logbook.source.watch"
        case .manual: return "snorkeling.logbook.source.manual"
        case .imported: return "snorkeling.logbook.source.imported"
        }
    }

    static func make(
        session: SnorkelingSession,
        aggregateState: IOSSnorkelingSessionSyncService.PresentationState,
        sessionBadge: SnorkelingSessionImportBadge
    ) -> SnorkelingSessionLogbookSyncPresentation {
        let sourceKey = startModeKey(for: session.startMode)
        switch sessionBadge {
        case .failed(let reason):
            return SnorkelingSessionLogbookSyncPresentation(
                sourceKey: sourceKey,
                badgeKey: "snorkeling.logbook.sync.failed_row",
                badgeIsWarning: true,
                guidanceKey: "snorkeling.logbook.sync.retry_guidance"
            )
        case .pending:
            return SnorkelingSessionLogbookSyncPresentation(
                sourceKey: sourceKey,
                badgeKey: "snorkeling.logbook.sync.pending_row",
                badgeIsWarning: true,
                guidanceKey: "snorkeling.logbook.sync.pending_guidance"
            )
        case .synced, .none:
            if case .failed = aggregateState, session.startMode == .watch {
                return SnorkelingSessionLogbookSyncPresentation(
                    sourceKey: sourceKey,
                    badgeKey: "snorkeling.logbook.sync.failed_row",
                    badgeIsWarning: true,
                    guidanceKey: "snorkeling.logbook.sync.retry_guidance"
                )
            }
            return SnorkelingSessionLogbookSyncPresentation(
                sourceKey: sourceKey,
                badgeKey: nil,
                badgeIsWarning: false,
                guidanceKey: nil
            )
        }
    }
}
