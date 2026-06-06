import Foundation
import Combine
import os

@MainActor
final class CloudSyncStore: ObservableObject {
    @Published private(set) var lastSyncStatus = String(localized: "cloud.status.not_yet_synced")
    @Published private(set) var isICloudAvailable = FileManager.default.ubiquityIdentityToken != nil
    @Published private(set) var lastDecodeError: String?
    @Published private(set) var isSynchronizing = false
    @Published private(set) var lastSuccessfulSyncDate: Date?

    private let cloudStore = NSUbiquitousKeyValueStore.default
    private let defaults: UserDefaults
    private static let logger = Logger(subsystem: "com.egopfe.dirdiving.ios", category: "CloudSyncStore")

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        NotificationCenter.default.addObserver(
            forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: cloudStore,
            queue: .main
        ) { [weak self] notification in
            Task { @MainActor in
                guard let self else { return }
                self.publishDeferred { [self] in
                    self.isICloudAvailable = FileManager.default.ubiquityIdentityToken != nil
                    self.lastSyncStatus = String(localized: "cloud.status.external_update")
                }
                NotificationCenter.default.post(
                    name: .cloudSyncDidChangeExternally,
                    object: self,
                    userInfo: notification.userInfo
                )
            }
        }
        synchronize()
    }

    func clearDecodeError() {
        publishDeferred { [self] in lastDecodeError = nil }
    }

    func loadRawLocalData(forKey key: String) -> Data? {
        defaults.data(forKey: key)
    }

    func loadRawCloudData(forKey key: String) -> Data? {
        cloudStore.data(forKey: key)
    }

    func removeValue(forKey key: String) {
        defaults.removeObject(forKey: key)
        defaults.removeObject(forKey: modifiedAtKey(for: key))
        cloudStore.removeObject(forKey: key)
        cloudStore.removeObject(forKey: modifiedAtKey(for: key))
        synchronize()
    }

    func decodeLocal<T: Decodable>(_ type: T.Type, from data: Data) -> T? {
        decode(type, from: data, key: "local", source: String(localized: "cloud.source.local"))
    }

    func decodeCloud<T: Decodable>(_ type: T.Type, from data: Data) -> T? {
        decode(type, from: data, key: "cloud", source: String(localized: "cloud.source.icloud"))
    }

    func load<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        let cloudData = cloudStore.data(forKey: key)
        let localData = defaults.data(forKey: key)
        let cloudModifiedAt = cloudStore.double(forKey: modifiedAtKey(for: key))
        let localModifiedAt = defaults.double(forKey: modifiedAtKey(for: key))

        if let cloudData, let localData {
            if cloudModifiedAt > localModifiedAt {
                if let decoded = decode(type, from: cloudData, key: key, source: String(localized: "cloud.source.icloud")) {
                    defaults.set(cloudData, forKey: key)
                    defaults.set(cloudModifiedAt, forKey: modifiedAtKey(for: key))
                    publishDeferred { [self] in
                        lastSyncStatus = String(localized: "cloud.status.loaded_from_icloud")
                    }
                    return decoded
                }
                recordDecodeFailure(key: key, source: String(localized: "cloud.source.icloud"))
            }

            if let decoded = decode(type, from: localData, key: key, source: String(localized: "cloud.source.local")) {
                if localModifiedAt > cloudModifiedAt {
                    cloudStore.set(localData, forKey: key)
                    cloudStore.set(localModifiedAt, forKey: modifiedAtKey(for: key))
                    synchronize()
                    publishDeferred { [self] in
                        lastSyncStatus = String(localized: "cloud.status.local_newer_pending_icloud")
                    }
                } else if lastDecodeError != nil {
                    publishDeferred { [self] in
                        lastSyncStatus = String(localized: "cloud.status.using_local_after_icloud_error")
                    }
                }
                return decoded
            }
            recordDecodeFailure(key: key, source: String(localized: "cloud.source.local"))
        }

        if let cloudData {
            if let decoded = decode(type, from: cloudData, key: key, source: String(localized: "cloud.source.icloud")) {
                defaults.set(cloudData, forKey: key)
                defaults.set(cloudModifiedAt, forKey: modifiedAtKey(for: key))
                publishDeferred { [self] in
                    lastSyncStatus = String(localized: "cloud.status.loaded_from_icloud")
                }
                return decoded
            }
            recordDecodeFailure(key: key, source: String(localized: "cloud.source.icloud"))
        }

        if let localData {
            if let decoded = decode(type, from: localData, key: key, source: String(localized: "cloud.source.local")) {
                cloudStore.set(localData, forKey: key)
                cloudStore.set(localModifiedAt, forKey: modifiedAtKey(for: key))
                synchronize()
                publishDeferred { [self] in
                    lastSyncStatus = String(localized: "cloud.status.local_pending_icloud")
                }
                return decoded
            }
            recordDecodeFailure(key: key, source: String(localized: "cloud.source.local"))
        }

        return nil
    }

    func save<T: Encodable>(_ value: T, forKey key: String) {
        guard let data = encode(value) else {
            publishDeferred { [self] in
                lastSyncStatus = String(localized: "cloud.status.encode_failed")
            }
            return
        }

        let modifiedAt = Date().timeIntervalSince1970
        defaults.set(data, forKey: key)
        defaults.set(modifiedAt, forKey: modifiedAtKey(for: key))

        if data.count > IOSAlgorithmConfiguration.maxSyncPayloadBytes {
            publishDeferred { [self] in
                lastSyncStatus = String(localized: "cloud.status.payload_too_large")
            }
            return
        }

        cloudStore.set(data, forKey: key)
        cloudStore.set(modifiedAt, forKey: modifiedAtKey(for: key))
        synchronize()
        let available = FileManager.default.ubiquityIdentityToken != nil
        publishDeferred { [self] in
            lastDecodeError = nil
            lastSyncStatus = available
                ? String(localized: "cloud.status.saved_local_and_icloud")
                : String(localized: "cloud.status.saved_local_only")
            if available {
                lastSuccessfulSyncDate = Date()
            }
        }
    }

    func synchronize() {
        cloudStore.synchronize()
        let available = FileManager.default.ubiquityIdentityToken != nil
        publishDeferred { [self] in
            isSynchronizing = true
            isICloudAvailable = available
            if available {
                lastSyncStatus = String(localized: "cloud.status.sync_requested")
                lastSuccessfulSyncDate = Date()
            } else {
                lastSyncStatus = String(localized: "cloud.status.icloud_unavailable")
            }
        }
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 900_000_000)
            isSynchronizing = false
        }
    }

    private func encode<T: Encodable>(_ value: T) -> Data? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        do {
            return try encoder.encode(value)
        } catch {
            publishDeferred { [self] in
                lastSyncStatus = String(localized: "cloud.status.encode_failed")
            }
            Self.logger.error("iCloud encode failed: \(error.localizedDescription, privacy: .private)")
            return nil
        }
    }

    private func decode<T: Decodable>(_ type: T.Type, from data: Data, key: String, source: String) -> T? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            return try decoder.decode(type, from: data)
        } catch {
            recordDecodeFailure(key: key, source: source, underlying: error)
            return nil
        }
    }

    private func recordDecodeFailure(key: String, source: String, underlying: Error? = nil) {
        let name = Self.friendlyKeyName(key)
        let detail: String
        if let underlying {
            detail = String(
                format: String(localized: "cloud.decode.error_with_reason"),
                name,
                source,
                underlying.localizedDescription
            )
        } else {
            detail = String(format: String(localized: "cloud.decode.error_format"), name, source)
        }
        if let existing = lastDecodeError, existing != detail {
            publishDeferred { [self] in
                lastDecodeError = "\(existing)\n\(detail)"
                lastSyncStatus = String(localized: "cloud.status.decode_failed")
            }
        } else {
            publishDeferred { [self] in
                lastDecodeError = detail
                lastSyncStatus = String(localized: "cloud.status.decode_failed")
            }
        }
        Self.logger.error("iCloud decode failed key=\(key, privacy: .public) source=\(source, privacy: .public)")
    }

    private static func friendlyKeyName(_ key: String) -> String {
        switch key {
        case "dirdiving_ios_dive_sessions":
            return String(localized: "cloud.key.dive_sessions")
        case WatchSyncKeys.deletedSessionIDsKey:
            return String(localized: "cloud.key.deleted_sessions")
        default:
            return key
        }
    }

    private func modifiedAtKey(for key: String) -> String {
        "\(key).__modifiedAt"
    }

    /// Avoid SwiftUI runtime fault: "Publishing changes from within view updates".
    private func publishDeferred(_ update: @escaping () -> Void) {
        Task { @MainActor in
            update()
        }
    }
}
