import Foundation
import Combine
import os

@MainActor
final class CloudSyncStore: ObservableObject {
    @Published private(set) var lastSyncStatus = DIRIOSLocalizer.string("cloud.status.not_yet_synced")
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
                    let available = Self.currentICloudAvailability()
                    self.isICloudAvailable = available
                    self.lastSyncStatus = DIRIOSLocalizer.string("cloud.status.external_update")
                }
                NotificationCenter.default.post(
                    name: .cloudSyncDidChangeExternally,
                    object: self,
                    userInfo: notification.userInfo
                )
            }
        }
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name.NSUbiquityIdentityDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                let wasAvailable = self.isICloudAvailable
                let nowAvailable = Self.currentICloudAvailability()
                self.publishICloudAvailability(nowAvailable, postStatus: true)
                if !wasAvailable, nowAvailable {
                    self.synchronize()
                }
            }
        }
        if isICloudAvailable {
            synchronize()
        } else {
            publishDeferred { [self] in
                lastSyncStatus = DIRIOSLocalizer.string("cloud.status.icloud_unavailable")
            }
        }
    }

    func clearDecodeError() {
        publishDeferred { [self] in lastDecodeError = nil }
    }

    func loadRawLocalData(forKey key: String) -> Data? {
        defaults.data(forKey: key)
    }

    func loadRawCloudData(forKey key: String) -> Data? {
        guard isICloudAvailable else { return nil }
        return cloudStore.data(forKey: key)
    }

    func removeValue(forKey key: String) {
        defaults.removeObject(forKey: key)
        defaults.removeObject(forKey: modifiedAtKey(for: key))
        guard isICloudAvailable else {
            publishDeferred { [self] in
                lastSyncStatus = DIRIOSLocalizer.string("cloud.status.icloud_unavailable")
            }
            return
        }
        cloudStore.removeObject(forKey: key)
        cloudStore.removeObject(forKey: modifiedAtKey(for: key))
        synchronize()
    }

    func decodeLocal<T: Decodable>(_ type: T.Type, from data: Data) -> T? {
        decode(type, from: data, key: "local", source: DIRIOSLocalizer.string("cloud.source.local"))
    }

    func decodeCloud<T: Decodable>(_ type: T.Type, from data: Data) -> T? {
        decode(type, from: data, key: "cloud", source: DIRIOSLocalizer.string("cloud.source.icloud"))
    }

    func load<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        let cloudData = isICloudAvailable ? cloudStore.data(forKey: key) : nil
        let localData = defaults.data(forKey: key)
        let cloudModifiedAt = isICloudAvailable ? cloudStore.double(forKey: modifiedAtKey(for: key)) : 0
        let localModifiedAt = defaults.double(forKey: modifiedAtKey(for: key))

        if let cloudData, let localData {
            if Self.prefersCloudPayload(localModifiedAt: localModifiedAt, cloudModifiedAt: cloudModifiedAt) {
                if let decoded = decodeCloudIfAllowed(type, cloudData: cloudData, key: key) {
                    defaults.set(cloudData, forKey: key)
                    defaults.set(cloudModifiedAt, forKey: modifiedAtKey(for: key))
                    publishDeferred { [self] in
                        lastSyncStatus = DIRIOSLocalizer.string("cloud.status.loaded_from_icloud")
                    }
                    return decoded
                }
                recordDecodeFailure(key: key, source: DIRIOSLocalizer.string("cloud.source.icloud"))
            }

            if let decoded = decode(type, from: localData, key: key, source: DIRIOSLocalizer.string("cloud.source.local")) {
                if isICloudAvailable, localModifiedAt > cloudModifiedAt {
                    cloudStore.set(localData, forKey: key)
                    cloudStore.set(localModifiedAt, forKey: modifiedAtKey(for: key))
                    synchronize()
                    publishDeferred { [self] in
                        lastSyncStatus = DIRIOSLocalizer.string("cloud.status.local_newer_pending_icloud")
                    }
                } else if lastDecodeError != nil {
                    publishDeferred { [self] in
                        lastSyncStatus = DIRIOSLocalizer.string("cloud.status.using_local_after_icloud_error")
                    }
                }
                return decoded
            }
            recordDecodeFailure(key: key, source: DIRIOSLocalizer.string("cloud.source.local"))
        }

        if let cloudData {
            if let decoded = decodeCloudIfAllowed(type, cloudData: cloudData, key: key) {
                defaults.set(cloudData, forKey: key)
                defaults.set(cloudModifiedAt, forKey: modifiedAtKey(for: key))
                publishDeferred { [self] in
                    lastSyncStatus = DIRIOSLocalizer.string("cloud.status.loaded_from_icloud")
                }
                return decoded
            }
            recordDecodeFailure(key: key, source: DIRIOSLocalizer.string("cloud.source.icloud"))
        }

        if let localData {
            if let decoded = decode(type, from: localData, key: key, source: DIRIOSLocalizer.string("cloud.source.local")) {
                if isICloudAvailable {
                    cloudStore.set(localData, forKey: key)
                    cloudStore.set(localModifiedAt, forKey: modifiedAtKey(for: key))
                    synchronize()
                    publishDeferred { [self] in
                        lastSyncStatus = DIRIOSLocalizer.string("cloud.status.local_pending_icloud")
                    }
                } else {
                    publishDeferred { [self] in
                        lastSyncStatus = DIRIOSLocalizer.string("cloud.status.saved_local_only")
                    }
                }
                return decoded
            }
            recordDecodeFailure(key: key, source: DIRIOSLocalizer.string("cloud.source.local"))
        }

        return nil
    }

    func loadLocal<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let localData = defaults.data(forKey: key) else { return nil }
        return decode(type, from: localData, key: key, source: String(localized: "cloud.source.local"))
    }

    func loadCloud<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let cloudData = cloudStore.data(forKey: key) else { return nil }
        return decode(type, from: cloudData, key: key, source: String(localized: "cloud.source.icloud"))
    }

    func save<T: Encodable>(_ value: T, forKey key: String) {
        guard let data = encode(value) else {
            publishDeferred { [self] in
                lastSyncStatus = DIRIOSLocalizer.string("cloud.status.encode_failed")
            }
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
            publishDeferred { [self] in
                lastSyncStatus = DIRIOSLocalizer.string("cloud.status.payload_too_large")
            }
            return
        case .blockedAggregate:
            if partial == .partialMigrationKeptLocal {
                CloudSyncMigrationTelemetry.recordPartialMigrationKeptLocal()
            }
            publishDeferred { [self] in
                lastSyncStatus = DIRIOSLocalizer.string("cloud.status.aggregate_budget_exceeded")
            }
            return
        }

        let modifiedAt = Date().timeIntervalSince1970
        defaults.set(data, forKey: key)
        defaults.set(modifiedAt, forKey: modifiedAtKey(for: key))

        if isICloudAvailable {
            cloudStore.set(data, forKey: key)
            cloudStore.set(modifiedAt, forKey: modifiedAtKey(for: key))
            synchronize(requestedAt: Date())
        }
        publishDeferred { [self] in
            lastDecodeError = nil
            lastSyncStatus = isICloudAvailable
                ? DIRIOSLocalizer.string("cloud.status.saved_local_and_icloud")
                : DIRIOSLocalizer.string("cloud.status.saved_local_only")
        }
    }

    private var syncGeneration: UInt = 0
    private var lastSyncRequestedDate: Date?

    func synchronize(requestedAt: Date = Date()) {
        let available = Self.currentICloudAvailability()
        publishICloudAvailability(available, postStatus: false)
        syncGeneration &+= 1
        let generation = syncGeneration
        lastSyncRequestedDate = requestedAt
        guard available else {
            publishDeferred { [self] in
                isSynchronizing = false
                lastSyncStatus = DIRIOSLocalizer.string("cloud.status.icloud_unavailable")
            }
            return
        }
        cloudStore.synchronize()
        publishDeferred { [self] in
            isSynchronizing = true
            lastSyncStatus = DIRIOSLocalizer.string("cloud.status.sync_requested")
        }
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 900_000_000)
            guard generation == syncGeneration else { return }
            publishDeferred { [self] in
                isSynchronizing = false
                lastSuccessfulSyncDate = Date()
                lastSyncStatus = DIRIOSLocalizer.string("cloud.status.sync_completed")
            }
        }
    }

    private static func currentICloudAvailability() -> Bool {
        FileManager.default.ubiquityIdentityToken != nil
    }

    private func publishICloudAvailability(_ available: Bool, postStatus: Bool) {
        publishDeferred { [self] in
            isICloudAvailable = available
            if postStatus, !available {
                lastSyncStatus = DIRIOSLocalizer.string("cloud.status.icloud_unavailable")
            }
        }
    }

    private func refreshICloudAvailability(postStatus: Bool) {
        publishICloudAvailability(Self.currentICloudAvailability(), postStatus: postStatus)
    }

    private func encode<T: Encodable>(_ value: T) -> Data? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        do {
            return try encoder.encode(value)
        } catch {
            publishDeferred { [self] in
                lastSyncStatus = DIRIOSLocalizer.string("cloud.status.encode_failed")
            }
            Self.logger.error("iCloud encode failed: \(error.localizedDescription, privacy: .private)")
            return nil
        }
    }

    private func decodeCloudIfAllowed<T: Decodable>(_ type: T.Type, cloudData: Data, key: String) -> T? {
        switch CloudSyncLegacyMigrationPolicy.incomingPayloadDecision(byteCount: cloudData.count) {
        case .usePayload:
            return decode(type, from: cloudData, key: key, source: DIRIOSLocalizer.string("cloud.source.icloud"))
        case .ignoreLegacyOversizedPerKey:
            CloudSyncMigrationTelemetry.recordLegacyOversizedIgnored(storageKey: key)
            publishDeferred { [self] in
                lastSyncStatus = DIRIOSLocalizer.string("cloud.status.payload_too_large")
            }
            return nil
        case .ignoreEmpty:
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
                format: DIRIOSLocalizer.string("cloud.decode.error_with_reason"),
                name,
                source,
                underlying.localizedDescription
            )
        } else {
            detail = DIRIOSLocalizer.formatted("cloud.decode.error_format", name, source)
        }
        if let existing = lastDecodeError, existing != detail {
            publishDeferred { [self] in
                lastDecodeError = "\(existing)\n\(detail)"
                lastSyncStatus = DIRIOSLocalizer.string("cloud.status.decode_failed")
            }
        } else {
            publishDeferred { [self] in
                lastDecodeError = detail
                lastSyncStatus = DIRIOSLocalizer.string("cloud.status.decode_failed")
            }
        }
        Self.logger.error("iCloud decode failed key=\(key, privacy: .public) source=\(source, privacy: .public)")
    }

    private static func friendlyKeyName(_ key: String) -> String {
        switch key {
        case "dirdiving_ios_dive_sessions":
            return DIRIOSLocalizer.string("cloud.key.dive_sessions")
        case WatchSyncKeys.deletedSessionIDsKey:
            return DIRIOSLocalizer.string("cloud.key.deleted_sessions")
        default:
            return key
        }
    }

    private func modifiedAtKey(for key: String) -> String {
        "\(key).__modifiedAt"
    }

    /// Testable LWW decision used by `load(_:forKey:)`.
    static func prefersCloudPayload(localModifiedAt: Double, cloudModifiedAt: Double) -> Bool {
        cloudModifiedAt > localModifiedAt
    }

    /// Avoid SwiftUI runtime fault: "Publishing changes from within view updates".
    private func publishDeferred(_ update: @escaping () -> Void) {
        Task { @MainActor in
            await Task.yield()
            update()
        }
    }
}
