import Foundation

struct SnorkelingRoutePlan: Identifiable, Codable, Hashable, Sendable {
    static let currentSchemaVersion = 1

    let id: UUID
    var schemaVersion: Int
    var name: String
    var waypoints: [SnorkelingWaypoint]
    var offlineCacheReady: Bool
    var syncReady: Bool

    init(
        id: UUID = UUID(),
        schemaVersion: Int = SnorkelingRoutePlan.currentSchemaVersion,
        name: String,
        waypoints: [SnorkelingWaypoint] = [],
        offlineCacheReady: Bool = false,
        syncReady: Bool = false
    ) {
        self.id = id
        self.schemaVersion = schemaVersion
        self.name = name
        self.waypoints = waypoints
        self.offlineCacheReady = offlineCacheReady
        self.syncReady = syncReady
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let decodedVersion = try container.decodeIfPresent(Int.self, forKey: .schemaVersion) ?? 0
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        waypoints = try container.decodeIfPresent([SnorkelingWaypoint].self, forKey: .waypoints) ?? []
        offlineCacheReady = try container.decodeIfPresent(Bool.self, forKey: .offlineCacheReady) ?? false
        syncReady = try container.decodeIfPresent(Bool.self, forKey: .syncReady) ?? false
        schemaVersion = decodedVersion <= 0 ? SnorkelingRoutePlan.currentSchemaVersion : min(decodedVersion, SnorkelingRoutePlan.currentSchemaVersion)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(SnorkelingRoutePlan.currentSchemaVersion, forKey: .schemaVersion)
        try container.encode(name, forKey: .name)
        try container.encode(waypoints, forKey: .waypoints)
        try container.encode(offlineCacheReady, forKey: .offlineCacheReady)
        try container.encode(syncReady, forKey: .syncReady)
    }

    private enum CodingKeys: String, CodingKey {
        case id, schemaVersion, name, waypoints, offlineCacheReady, syncReady
    }
}
