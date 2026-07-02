import Foundation

struct SnorkelingRoutePendingSendEntry: Codable, Equatable {
    var packageID: UUID
    var revision: Int
    var checksum: String
    var packageData: Data
    var enqueuedAt: Date
}

enum SnorkelingRoutePendingSendQueuePersistence {
    static let userDefaultsKey = "dirdiving_snorkeling_route_pending_send_queue_v1"

    static func load(from defaults: UserDefaults = .standard) -> [SnorkelingRoutePendingSendEntry] {
        guard let data = defaults.data(forKey: userDefaultsKey) else { return [] }
        guard let decoded = try? JSONDecoder().decode([SnorkelingRoutePendingSendEntry].self, from: data) else {
            return []
        }
        return decoded
    }

    static func save(_ entries: [SnorkelingRoutePendingSendEntry], to defaults: UserDefaults = .standard) {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        defaults.set(data, forKey: userDefaultsKey)
    }

    static func clear(from defaults: UserDefaults = .standard) {
        defaults.removeObject(forKey: userDefaultsKey)
    }
}
