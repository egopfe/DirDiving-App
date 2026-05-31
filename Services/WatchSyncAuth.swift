import Foundation
import CryptoKit
import Security
import WatchConnectivity
import os

enum WatchSyncAuth {
    static let contextKey = "dirdiving_watch_sync_secret"
    private static let keychainService = "com.egopfe.dirdiving.watch-sync"
    private static let keychainAccount = "shared-secret"

    private static let logger = Logger(subsystem: "com.egopfe.dirdiving", category: "WatchSyncAuth")

    static func publishSharedSecretIfNeeded() {
        guard WCSession.isSupported(),
              WCSession.default.activationState == .activated else { return }
        guard let secret = loadOrCreateLocalSecret() else {
            logger.error("Local Watch sync secret unavailable: SecRandomCopyBytes failed; refusing to publish a deterministic fallback.")
            return
        }
        mergeApplicationContext([contextKey: secret.base64EncodedString()])
    }

    /// Merges keys into the current WC applicationContext without dropping peer secret or tombstones.
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

    static func hasPeerSecret() -> Bool {
        loadPeerSecret() != nil
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
    static func syncKey(peerBundleID _: String) -> SymmetricKey {
        guard let secret = loadPeerSecret() else {
            logger.error("syncKey requested without verified peer secret; returning zero key (callers must short-circuit via hasPeerSecret()).")
            return SymmetricKey(data: Data(repeating: 0, count: 32))
        }
        guard let localSecret = loadOrCreateLocalSecret() else {
            logger.error("syncKey requested but local secret unavailable; returning zero key.")
            return SymmetricKey(data: Data(repeating: 0, count: 32))
        }
        let orderedSecrets = [localSecret, secret].sorted { $0.lexicographicallyPrecedes($1) }
        var material = Data("dirdiving.watch.sync.v2|com.egopfe.dirdiving.ios.watch|com.egopfe.dirdiving.ios|".utf8)
        material.append(orderedSecrets[0])
        material.append(orderedSecrets[1])
        return SymmetricKey(data: SHA256.hash(data: material))
    }

    private static func loadOrCreateLocalSecret() -> Data? {
        if let existing = loadKeychain(account: keychainAccount) {
            return existing
        }
        guard let generated = try? randomKeyData(byteCount: 32) else {
            // F7: never fall back to a deterministic secret — fail loud instead.
            return nil
        }
        saveKeychain(generated, account: keychainAccount)
        return generated
    }

    private static func loadPeerSecret() -> Data? {
        loadKeychain(account: "\(keychainAccount)-peer")
    }

    private static func savePeerSecret(_ data: Data) {
        saveKeychain(data, account: "\(keychainAccount)-peer")
    }

    private static func randomKeyData(byteCount: Int) throws -> Data {
        var bytes = [UInt8](repeating: 0, count: byteCount)
        let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        guard status == errSecSuccess else { throw KeychainError.unhandledStatus(status) }
        return Data(bytes)
    }

    private static func loadKeychain(account: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess else { return nil }
        return result as? Data
    }

    private static func saveKeychain(_ data: Data, account: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
        var attributes = query
        attributes[kSecValueData as String] = data
        attributes[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        SecItemAdd(attributes as CFDictionary, nil)
    }

    private enum KeychainError: Error {
        case unhandledStatus(OSStatus)
    }
}
