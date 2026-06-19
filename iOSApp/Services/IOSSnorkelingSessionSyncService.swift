import Combine
import Foundation

@MainActor
final class IOSSnorkelingSessionSyncService: ObservableObject {
    enum PresentationState: Equatable {
        case localOnly
        case imported
        case merged
        case duplicateIgnored
        case failed(String)
    }

    @Published private(set) var state: PresentationState = .localOnly
    @Published private(set) var lastEventAt: Date?

    func recordImport(_ result: SnorkelingSessionSyncImportResult) {
        switch result {
        case .imported:
            state = .imported
            lastEventAt = Date()
        case .merged:
            state = .merged
            lastEventAt = Date()
        case .duplicateIgnored:
            state = .duplicateIgnored
            lastEventAt = Date()
        case .failed(let reason):
            state = .failed(reason)
            lastEventAt = Date()
        }
    }

    func statusText(dateFormatter: DateFormatter) -> String {
        switch state {
        case .localOnly:
            return DIRIOSLocalizer.string("snorkeling.ios.sync.session.none")
        case .imported:
            guard let lastEventAt else { return DIRIOSLocalizer.string("snorkeling.ios.sync.session.none") }
            return String(
                format: DIRIOSLocalizer.string("snorkeling.ios.sync.session.imported_format"),
                dateFormatter.string(from: lastEventAt)
            )
        case .merged:
            guard let lastEventAt else { return DIRIOSLocalizer.string("snorkeling.ios.sync.session.none") }
            return String(
                format: DIRIOSLocalizer.string("snorkeling.ios.sync.session.merged_format"),
                dateFormatter.string(from: lastEventAt)
            )
        case .duplicateIgnored:
            return DIRIOSLocalizer.string("snorkeling.ios.sync.session.duplicate")
        case .failed(let reason):
            return String(format: DIRIOSLocalizer.string("snorkeling.ios.sync.session.failed_format"), reason)
        }
    }

    var isPositive: Bool {
        switch state {
        case .imported, .merged, .localOnly, .duplicateIgnored:
            return true
        case .failed:
            return false
        }
    }
}
