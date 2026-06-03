import Foundation
import CryptoKit
import Security
import WatchConnectivity
import os

enum WatchSyncAuthError: Error, Equatable {
    case missingPeerSecret
    case missingLocalSecret
}

enum WatchSyncAuth {
    static let contextKey = "dirdiving_watch_sync_secret"

    // F8: primary keychainService uses the canonical product prefix `dirdiving`.
    // The legacy `dirmotion` service is read as a one-shot migration source only.
    private static let keychainService = "com.egopfe.dirdiving.watch-sync"
    private static let legacyKeychainService = "com.egopfe.dirmotion.watch-sync"
    private static let keychainAccount = "shared-secret"

    private static let logger = Logger(subsystem: "com.egopfe.dirdiving.ios", category: "WatchSyncAuth")

    static func hasPeerSecret() -> Bool {
        loadPeerSecret() != nil
    }

    static func publishSharedSecretIfNeeded() {
        guard WCSession.isSupported(),
              WCSession.default.activationState == .activated else { return }
        guard let secret = loadOrCreateLocalSecret() else {
            logger.error("Local Watch sync secret unavailable: SecRandomCopyBytes failed; refusing to publish a deterministic fallback.")
            return
        }
        mergeApplicationContext([contextKey: secret.base64EncodedString()])
    }

    static func mergeApplicationContext(_ updates: [String: Any]) {
        guard WCSession.isSupported(),
              WCSession.default.activationState == .activated else { return }
        var context = WCSession.default.applicationContext
        for (key, value) in updates {
            context[key] = value
        }
        if context[contextKey] == nil, let secret = loadOrCreateLocalSecret() {
            context[contextKey] = secret.base64EncodedString()
        }
        try? WCSession.default.updateApplicationContext(context)
    }

    static func ingestSharedSecretFromContext(_ context: [String: Any]) {
        guard let encoded = context[contextKey] as? String,
              let secret = Data(base64Encoded: encoded),
              secret.count >= 32 else { return }
        savePeerSecret(secret)
        NotificationCenter.default.post(name: .watchSyncPeerSecretDidUpdate, object: nil)
    }

    // MARK: - Sync key derivation
    //
    // Authoritative algorithm = `v2 ordered-secrets` (see Docs/SECURITY_AUDIT_MAIN_AND_MAIN_IOS_20260519.md F2).
    // BOTH sides (Watch + iOS) on `main` MUST keep this implementation byte-identical.
    // Any change to the canonical string or the ordering rule REQUIRES a bump of
    // `WatchDiveSyncCodec.schemaVersion` and a coordinated Watch/iOS release.
    static func deriveSyncKey(peerBundleID _: String) throws -> SymmetricKey {
        guard let secret = loadPeerSecret() else {
            logger.error("deriveSyncKey requested without verified peer secret.")
            throw WatchSyncAuthError.missingPeerSecret
        }
        guard let localSecret = loadOrCreateLocalSecret() else {
            logger.error("deriveSyncKey requested but local secret unavailable.")
            throw WatchSyncAuthError.missingLocalSecret
        }
        let orderedSecrets = [localSecret, secret].sorted { $0.lexicographicallyPrecedes($1) }
        var material = Data("dirdiving.watch.sync.v2|com.egopfe.dirdiving.ios.watch|com.egopfe.dirdiving.ios|".utf8)
        material.append(orderedSecrets[0])
        material.append(orderedSecrets[1])
        return SymmetricKey(data: SHA256.hash(data: material))
    }

    static func cachedApplicationContext() -> [String: Any] {
        guard WCSession.isSupported() else { return [:] }
        return WCSession.default.receivedApplicationContext
    }

    // F1: explicit peer-trust reset used by the iOS UI to force a fresh pairing handshake.
    static func resetPeerTrust() {
        deleteKeychain(account: "\(keychainAccount)-peer", service: keychainService)
        deleteKeychain(account: "\(keychainAccount)-peer", service: legacyKeychainService)
        NotificationCenter.default.post(name: .watchSyncPeerSecretDidUpdate, object: nil)
    }

    private static func loadOrCreateLocalSecret() -> Data? {
        if let existing = loadKeychain(account: keychainAccount, service: keychainService) {
            return existing
        }
        // F8 migration: adopt the legacy `dirmotion` secret only once, then re-save under the canonical service.
        // Watch-side builds always used the canonical `dirdiving` service label; migration is iOS-only by design.
        if let legacy = loadKeychain(account: keychainAccount, service: legacyKeychainService) {
            saveKeychain(legacy, account: keychainAccount, service: keychainService)
            return legacy
        }
        guard let generated = try? randomKeyData(byteCount: 32) else {
            // F7: never fall back to a deterministic secret — fail loud instead.
            return nil
        }
        saveKeychain(generated, account: keychainAccount, service: keychainService)
        return generated
    }

    private static func loadPeerSecret() -> Data? {
        if let secret = loadKeychain(account: "\(keychainAccount)-peer", service: keychainService) {
            return secret
        }
        return loadKeychain(account: "\(keychainAccount)-peer", service: legacyKeychainService)
    }

    private static func savePeerSecret(_ data: Data) {
        saveKeychain(data, account: "\(keychainAccount)-peer", service: keychainService)
    }

    private static func randomKeyData(byteCount: Int) throws -> Data {
        var bytes = [UInt8](repeating: 0, count: byteCount)
        let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        guard status == errSecSuccess else { throw KeychainError.unhandledStatus(status) }
        return Data(bytes)
    }

    private static func loadKeychain(account: String, service: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess else { return nil }
        return result as? Data
    }

    private static func saveKeychain(_ data: Data, account: String, service: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
        var attributes = query
        attributes[kSecValueData as String] = data
        attributes[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        SecItemAdd(attributes as CFDictionary, nil)
    }

    private static func deleteKeychain(account: String, service: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
    }

    private enum KeychainError: Error {
        case unhandledStatus(OSStatus)
    }
}
