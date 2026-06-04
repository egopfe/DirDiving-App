import Foundation
import CryptoKit
import Security
import WatchConnectivity
import os

enum WatchSyncAuthError: Error, Equatable {
    case missingPeerSecret
    case missingLocalSecret
}

enum WatchSyncPeerSecretIngestResult: Equatable {
    case acceptedFirstTrust
    case unchanged
    case rejectedMismatch
}

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

    private static let peerSecretMismatchKey = "dirdiving_watch_sync_peer_secret_mismatch"

    static var peerSecretMismatchDetected: Bool {
        UserDefaults.standard.bool(forKey: peerSecretMismatchKey)
    }

    @discardableResult
    static func ingestSharedSecretFromContext(_ context: [String: Any]) -> WatchSyncPeerSecretIngestResult {
        guard let encoded = context[contextKey] as? String,
              let secret = Data(base64Encoded: encoded),
              secret.count >= 32 else { return .unchanged }
        if let existing = loadPeerSecret() {
            if existing.constantTimeEquals(secret) {
                clearPeerSecretMismatch()
                return .unchanged
            }
            logger.warning("Rejected Watch sync peer secret replacement (TOFU pinning).")
            setPeerSecretMismatch(true)
            NotificationCenter.default.post(name: .watchSyncPeerSecretMismatch, object: nil)
            return .rejectedMismatch
        }
        savePeerSecret(secret)
        clearPeerSecretMismatch()
        NotificationCenter.default.post(name: .watchSyncPeerSecretDidUpdate, object: nil)
        return .acceptedFirstTrust
    }

    static func resetPeerTrust() {
        deleteKeychain(account: "\(keychainAccount)-peer")
        clearPeerSecretMismatch()
        NotificationCenter.default.post(name: .watchSyncPeerSecretDidUpdate, object: nil)
    }

    private static func setPeerSecretMismatch(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: peerSecretMismatchKey)
    }

    private static func clearPeerSecretMismatch() {
        UserDefaults.standard.set(false, forKey: peerSecretMismatchKey)
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

    private static func loadOrCreateLocalSecret() -> Data? {
        if let existing = loadKeychain(account: keychainAccount) {
            return existing
        }
        // Watch builds always used the canonical `dirdiving` keychain service; legacy `dirmotion`
        // migration is implemented on iOS only (see iOSApp/Services/WatchSyncAuth.swift).
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

    private static func deleteKeychain(account: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
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

private extension Data {
    func constantTimeEquals(_ other: Data) -> Bool {
        guard count == other.count else { return false }
        return zip(self, other).reduce(UInt8(0)) { $0 | ($1.0 ^ $1.1) } == 0
    }
}
