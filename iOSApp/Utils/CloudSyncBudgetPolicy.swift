import Foundation

/// Centralized iCloud KVS byte budget for per-key and aggregate limits.
enum CloudSyncBudgetPolicy {
    static let maxPerKeyBytes = 512 * 1024
    static let maxAggregateBytes = 900 * 1024
    static let reservedBytesForSystemMetadata = 64 * 1024

    enum BudgetDecision: Equatable {
        case allowed
        case perKeyExceeded(actual: Int)
        case aggregateExceeded(projectedTotal: Int, limit: Int)
    }

    struct KeyFootprint: Equatable {
        let key: String
        let dataBytes: Int
        let modifiedAtBytes: Int

        var totalBytes: Int { dataBytes + modifiedAtBytes }
    }

    static func modifiedAtKey(for key: String) -> String {
        "\(key).__modifiedAt"
    }

    static func evaluateWrite(
        key: String,
        newData: Data,
        existingFootprints: [KeyFootprint],
        replacingKey: String? = nil
    ) -> BudgetDecision {
        guard newData.count <= maxPerKeyBytes else {
            return .perKeyExceeded(actual: newData.count)
        }
        let modifiedAtBytes = MemoryLayout<TimeInterval>.size
        let newFootprint = KeyFootprint(key: key, dataBytes: newData.count, modifiedAtBytes: modifiedAtBytes)
        var projected = existingFootprints.filter { $0.key != replacingKey && $0.key != key }
        projected.append(newFootprint)
        let total = projected.reduce(0) { $0 + $1.totalBytes }
        let limit = maxAggregateBytes - reservedBytesForSystemMetadata
        guard total <= limit else {
            return .aggregateExceeded(projectedTotal: total, limit: limit)
        }
        return .allowed
    }

    static func footprints(from store: NSUbiquitousKeyValueStore) -> [KeyFootprint] {
        let keys = store.dictionaryRepresentation.keys
        let dataKeys = Set(keys.filter { !$0.hasSuffix(".__modifiedAt") })
        var footprints: [KeyFootprint] = []
        for key in dataKeys.sorted() {
            let dataBytes: Int
            if let data = store.data(forKey: key) {
                dataBytes = data.count
            } else if store.object(forKey: key) is String {
                dataBytes = (store.string(forKey: key) as NSString?)?.lengthOfBytes(using: String.Encoding.utf8.rawValue) ?? 0
            } else if store.object(forKey: key) is NSNumber {
                dataBytes = MemoryLayout<Int64>.size
            } else if store.object(forKey: key) is [Any] {
                dataBytes = (try? JSONSerialization.data(withJSONObject: store.object(forKey: key) as Any)).map(\.count) ?? 0
            } else {
                dataBytes = 0
            }
            let modifiedAtKey = modifiedAtKey(for: key)
            let modifiedAtBytes = store.object(forKey: modifiedAtKey) != nil ? MemoryLayout<TimeInterval>.size : 0
            footprints.append(KeyFootprint(key: key, dataBytes: dataBytes, modifiedAtBytes: modifiedAtBytes))
        }
        return footprints
    }

    static func aggregateByteTotal(_ footprints: [KeyFootprint]) -> Int {
        footprints.reduce(0) { $0 + $1.totalBytes }
    }
}
