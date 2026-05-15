import Foundation

enum DemoDiveCatalog {
    static let sessionIDs: [UUID] = [
        UUID(uuidString: "D1000001-0001-4001-8001-000000000001")!,
        UUID(uuidString: "D1000002-0002-4002-8002-000000000002")!,
        UUID(uuidString: "D1000003-0003-4003-8003-000000000003")!,
        UUID(uuidString: "D1000004-0004-4004-8004-000000000004")!,
        UUID(uuidString: "D1000005-0005-4005-8005-000000000005")!
    ]

    static let idSet = Set(sessionIDs)

    static func isDemoSession(id: UUID) -> Bool {
        idSet.contains(id)
    }
}
