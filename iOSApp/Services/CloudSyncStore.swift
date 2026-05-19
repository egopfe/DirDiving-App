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

    func load<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        let cloudData = cloudStore.data(forKey: key)
        let localData = defaults.data(forKey: key)
        let cloudModifiedAt = cloudStore.double(forKey: modifiedAtKey(for: key))
        let localModifiedAt = defaults.double(forKey: modifiedAtKey(for: key))

        if let cloudData, let localData {
            if cloudModifiedAt > localModifiedAt,
               let decoded = decode(type, from: cloudData) {
                defaults.set(cloudData, forKey: key)
                defaults.set(cloudModifiedAt, forKey: modifiedAtKey(for: key))
                lastSyncStatus = "Dati caricati da iCloud"
                return decoded
            }

            if let decoded = decode(type, from: localData) {
                if localModifiedAt > cloudModifiedAt {
                    cloudStore.set(localData, forKey: key)
                    cloudStore.set(localModifiedAt, forKey: modifiedAtKey(for: key))
                    synchronize()
                    lastSyncStatus = "Dati locali piu recenti pronti per iCloud"
                }
                return decoded
            }
        }

        if let cloudData,
           let decoded = decode(type, from: cloudData) {
            defaults.set(cloudData, forKey: key)
            defaults.set(cloudModifiedAt, forKey: modifiedAtKey(for: key))
            lastSyncStatus = "Dati caricati da iCloud"
            return decoded
        }

        if let localData,
           let decoded = decode(type, from: localData) {
            cloudStore.set(localData, forKey: key)
            cloudStore.set(localModifiedAt, forKey: modifiedAtKey(for: key))
            synchronize()
            lastSyncStatus = "Dati locali pronti per iCloud"
            return decoded
        }

        return nil
    }

    func loadLocal<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let localData = defaults.data(forKey: key) else { return nil }
        return decode(type, from: localData)
    }

    func loadCloud<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let cloudData = cloudStore.data(forKey: key) else { return nil }
        return decode(type, from: cloudData)
    }

    func save<T: Encodable>(_ value: T, forKey key: String) {
        guard let data = encode(value) else {
            lastSyncStatus = "Errore codifica dati iCloud"
            return
        }

        let modifiedAt = Date().timeIntervalSince1970
        defaults.set(data, forKey: key)
        defaults.set(modifiedAt, forKey: modifiedAtKey(for: key))
        cloudStore.set(data, forKey: key)
        cloudStore.set(modifiedAt, forKey: modifiedAtKey(for: key))
        synchronize()
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

    private func modifiedAtKey(for key: String) -> String {
        "\(key).__modifiedAt"
    }
}
