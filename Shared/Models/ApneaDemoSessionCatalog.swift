import Foundation

/// Stable demo session IDs (prefix A100…); excluded from real statistics and personal bests.
enum DemoApneaSessionCatalog {
    private static let rawSessionIDStrings = [
        "A1000001-0001-4001-8001-000000000001",
        "A1000002-0002-4002-8002-000000000002",
        "A1000003-0003-4003-8003-000000000003",
        "A1000004-0004-4004-8004-000000000004",
        "A1000005-0005-4005-8005-000000000005",
        "A1000006-0006-4006-8006-000000000006",
        "A1000007-0007-4007-8007-000000000007"
    ]

    static let sessionIDs: [UUID] = rawSessionIDStrings.enumerated().map { index, rawValue in
        UUID(uuidString: rawValue) ?? fallbackSessionID(index: index)
    }

    static let idSet = Set(sessionIDs)

    static func isDemoSession(id: UUID) -> Bool {
        idSet.contains(id)
    }

    private static func fallbackSessionID(index: Int) -> UUID {
        let suffix = UInt8(max(0, min(index + 1, 255)))
        return UUID(uuid: (0xA1, 0, 0, suffix, 0, suffix, 0x40, suffix, 0x80, suffix, 0, 0, 0, 0, 0, suffix))
    }
}
