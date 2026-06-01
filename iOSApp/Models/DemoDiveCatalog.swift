import Foundation

enum DemoDiveCatalog {
    private static let rawSessionIDStrings = [
        "D1000001-0001-4001-8001-000000000001",
        "D1000002-0002-4002-8002-000000000002",
        "D1000003-0003-4003-8003-000000000003",
        "D1000004-0004-4004-8004-000000000004",
        "D1000005-0005-4005-8005-000000000005"
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
        return UUID(uuid: (0xD1, 0, 0, suffix, 0, suffix, 0x40, suffix, 0x80, suffix, 0, 0, 0, 0, 0, suffix))
    }
}
