import Foundation
import Combine

@MainActor
final class CloudSyncStore: ObservableObject {
    @Published private(set) var lastSyncStatus = "iCloud non ancora sincronizzato"
    @Published private(set) var isICloudAvailable = FileManager.default.ubiquityIdentityToken != nil

    private let cloudStore = NSUbiquitousKeyValueStore.default
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        NotificationCenter.default.addObserver(
            forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: cloudStore,
            queue: .main
        ) { [weak self] notification in
            Task { @MainActor in
                self?.isICloudAvailable = FileManager.default.ubiquityIdentityToken != nil
                self?.lastSyncStatus = "Aggiornamento ricevuto da iCloud"
                NotificationCenter.default.post(
                    name: .cloudSyncDidChangeExternally,
                    object: self,
                    userInfo: notification.userInfo
                )
            }
        }
        synchronize()
    }

    func removeValue(forKey key: String) {
        defaults.removeObject(forKey: key)
        defaults.removeObject(forKey: modifiedAtKey(for: key))
        cloudStore.removeObject(forKey: key)
        cloudStore.removeObject(forKey: modifiedAtKey(for: key))
        synchronize()
        lastSyncStatus = "Dati sensibili rimossi da iCloud KVS"
    }

    func loadRawLocalData(forKey key: String) -> Data? {
        defaults.data(forKey: key)
    }

    func loadRawCloudData(forKey key: String) -> Data? {
        cloudStore.data(forKey: key)
    }

    func decodeLocal<T: Decodable>(_ type: T.Type, from data: Data) -> T? {
        decode(type, from: data)
    }

    func decodeCloud<T: Decodable>(_ type: T.Type, from data: Data) -> T? {
        decode(type, from: data)
    }

    func load<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        let cloudData = cloudStore.data(forKey: key)
        let localData = defaults.data(forKey: key)
        let cloudModifiedAt = cloudStore.double(forKey: modifiedAtKey(for: key))
        let localModifiedAt = defaults.double(forKey: modifiedAtKey(for: key))

        if let cloudData, let localData {
            if cloudModifiedAt > localModifiedAt,
               let decoded = decodeIfWithinPayloadCap(cloudData, type: type, key: key) {
                defaults.set(cloudData, forKey: key)
                defaults.set(cloudModifiedAt, forKey: modifiedAtKey(for: key))
                lastSyncStatus = "Dati caricati da iCloud"
                return decoded
            }

            if let decoded = decode(type, from: localData) {
                if localModifiedAt > cloudModifiedAt {
                    persistToCloudIfWithinCap(localData, key: key, modifiedAt: localModifiedAt)
                }
                return decoded
            }
        }

        if let cloudData,
           let decoded = decodeIfWithinPayloadCap(cloudData, type: type, key: key) {
            defaults.set(cloudData, forKey: key)
            defaults.set(cloudModifiedAt, forKey: modifiedAtKey(for: key))
            lastSyncStatus = "Dati caricati da iCloud"
            return decoded
        }

        if let cloudData,
           CloudSyncLegacyMigrationPolicy.incomingPayloadDecision(byteCount: cloudData.count) == .ignoreLegacyOversizedPerKey {
            CloudSyncMigrationTelemetry.recordLegacyOversizedIgnored(storageKey: key)
            lastSyncStatus = "Payload iCloud troppo grande ignorato"
        }

        if let localData,
           let decoded = decode(type, from: localData) {
            persistToCloudIfWithinCap(localData, key: key, modifiedAt: localModifiedAt)
            return decoded
        }

        return nil
    }

    func save<T: Encodable>(_ value: T, forKey key: String) {
        guard let data = encode(value) else {
            lastSyncStatus = "Errore codifica dati iCloud"
            return
        }

        let decision = CloudSyncLegacyMigrationPolicy.outgoingWriteDecision(
            key: key,
            newData: data,
            existingFootprints: CloudSyncBudgetPolicy.footprints(from: cloudStore)
        )
        let partial = CloudSyncLegacyMigrationPolicy.evaluatePartialMigration(
            hasLocalData: defaults.data(forKey: key) != nil,
            writeDecision: decision,
            alreadyCloudSynced: cloudStore.data(forKey: key) != nil
        )
        CloudSyncMigrationTelemetry.recordMigrationAttempt()
        switch decision {
        case .allowed:
            break
        case .blockedPerKey:
            if partial == .partialMigrationKeptLocal {
                CloudSyncMigrationTelemetry.recordPartialMigrationKeptLocal()
            }
            lastSyncStatus = "Payload troppo grande per iCloud KVS"
            return
        case .blockedAggregate:
            if partial == .partialMigrationKeptLocal {
                CloudSyncMigrationTelemetry.recordPartialMigrationKeptLocal()
            }
            lastSyncStatus = "Budget iCloud KVS aggregato superato"
            return
        }

        let modifiedAt = Date().timeIntervalSince1970
        defaults.set(data, forKey: key)
        defaults.set(modifiedAt, forKey: modifiedAtKey(for: key))
        persistToCloudIfWithinCap(data, key: key, modifiedAt: modifiedAt)
        lastSyncStatus = isICloudAvailable ? "Salvato localmente e su iCloud" : "Salvato localmente, iCloud non disponibile"
    }

    func synchronize() {
        cloudStore.synchronize()
        isICloudAvailable = FileManager.default.ubiquityIdentityToken != nil
    }

    private func encode<T: Encodable>(_ value: T) -> Data? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return try? encoder.encode(value)
    }

    private func decode<T: Decodable>(_ type: T.Type, from data: Data) -> T? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(type, from: data)
    }

    private func decodeIfWithinPayloadCap<T: Decodable>(_ data: Data, type: T.Type, key: String) -> T? {
        switch CloudSyncLegacyMigrationPolicy.incomingPayloadDecision(byteCount: data.count) {
        case .usePayload:
            return decode(type, from: data)
        case .ignoreLegacyOversizedPerKey:
            CloudSyncMigrationTelemetry.recordLegacyOversizedIgnored(storageKey: key)
            lastSyncStatus = "Payload iCloud troppo grande ignorato"
            return nil
        case .ignoreEmpty:
            return nil
        }
    }

    private func persistToCloudIfWithinCap(_ data: Data, key: String, modifiedAt: TimeInterval) {
        CloudSyncMigrationTelemetry.recordMigrationAttempt()
        let footprints = CloudSyncBudgetPolicy.footprints(from: cloudStore)
        let writeDecision = CloudSyncLegacyMigrationPolicy.outgoingWriteDecision(
            key: key,
            newData: data,
            existingFootprints: footprints,
            replacingKey: key
        )
        let partial = CloudSyncLegacyMigrationPolicy.evaluatePartialMigration(
            hasLocalData: defaults.data(forKey: key) != nil,
            writeDecision: writeDecision,
            alreadyCloudSynced: cloudStore.data(forKey: key) != nil
        )
        switch writeDecision {
        case .allowed:
            break
        case .blockedPerKey:
            if partial == .partialMigrationKeptLocal {
                CloudSyncMigrationTelemetry.recordPartialMigrationKeptLocal()
            }
            lastSyncStatus = "Payload troppo grande per iCloud KVS"
            return
        case .blockedAggregate:
            if partial == .partialMigrationKeptLocal {
                CloudSyncMigrationTelemetry.recordPartialMigrationKeptLocal()
            }
            lastSyncStatus = "Budget iCloud KVS aggregato superato"
            return
        }
        cloudStore.set(data, forKey: key)
        cloudStore.set(modifiedAt, forKey: modifiedAtKey(for: key))
        synchronize()
    }

    private func modifiedAtKey(for key: String) -> String {
        "\(key).__modifiedAt"
    }
}
