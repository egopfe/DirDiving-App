import Foundation

enum IOSLogbookEntryOrigin: String, Codable, Sendable {
    case real
    case demo
}

struct IOSApneaLogbookDisplayEntry: Identifiable, Equatable, Sendable {
    let id: String
    let origin: IOSLogbookEntryOrigin
    let session: ApneaSession

    var isDemo: Bool { origin == .demo }
}

struct IOSSnorkelingLogbookDisplayEntry: Identifiable, Equatable, Sendable {
    let id: String
    let origin: IOSLogbookEntryOrigin
    let session: SnorkelingSession

    var isDemo: Bool { origin == .demo }
}

enum IOSLogbookDisplayComposer {
    static func apneaEntries(
        realSessions: [ApneaSession],
        demoSessions: [ApneaSession]
    ) -> [IOSApneaLogbookDisplayEntry] {
        let real = realSessions.map {
            IOSApneaLogbookDisplayEntry(id: "real-\($0.id.uuidString)", origin: .real, session: $0)
        }
        let demo = demoSessions.map {
            IOSApneaLogbookDisplayEntry(id: "demo-\($0.id.uuidString)", origin: .demo, session: $0)
        }
        return real + demo
    }

    static func snorkelingEntries(
        realSessions: [SnorkelingSession],
        demoSessions: [SnorkelingSession]
    ) -> [IOSSnorkelingLogbookDisplayEntry] {
        let real = realSessions.map {
            IOSSnorkelingLogbookDisplayEntry(id: "real-\($0.id.uuidString)", origin: .real, session: $0)
        }
        let demo = demoSessions.map {
            IOSSnorkelingLogbookDisplayEntry(id: "demo-\($0.id.uuidString)", origin: .demo, session: $0)
        }
        return real + demo
    }

    static func realApneaSessions(from entries: [IOSApneaLogbookDisplayEntry]) -> [ApneaSession] {
        entries.filter { $0.origin == .real }.map(\.session)
    }

    static func realSnorkelingSessions(from entries: [IOSSnorkelingLogbookDisplayEntry]) -> [SnorkelingSession] {
        entries.filter { $0.origin == .real }.map(\.session)
    }
}
