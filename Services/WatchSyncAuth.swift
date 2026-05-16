import Foundation
import CryptoKit
import Security
import WatchConnectivity

enum WatchSyncAuth {
    static let contextKey = "dirdiving_watch_sync_secret"
    private static let keychainService = "com.egopfe.dirdiving.watch-sync"
    private static let keychainAccount = "shared-secret"

    static func publishSharedSecretIfNeeded() {
        guard WCSession.isSupported(),
              WCSession.default.activationState == .activated else { return }
        let secret = loadOrCreateLocalSecret()
        try? WCSession.default.updateApplicationContext([contextKey: secret.base64EncodedString()])
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

    static func syncKey(peerBundleID _: String) -> SymmetricKey {
        guard let secret = loadPeerSecret() else {
            return SymmetricKey(data: SHA256.hash(data: Data()))
        }
        let localSecret = loadOrCreateLocalSecret()
        let orderedSecrets = [localSecret, secret].sorted { $0.lexicographicallyPrecedes($1) }
        var material = Data("dirdiving.watch.sync.v2|com.egopfe.dirdiving|com.egopfe.dirdiving.ios|".utf8)
        material.append(orderedSecrets[0])
        material.append(orderedSecrets[1])
        return SymmetricKey(data: SHA256.hash(data: material))
    }

    private static func loadOrCreateLocalSecret() -> Data {
        if let existing = loadKeychain(account: keychainAccount) {
            return existing
        }
        guard let generated = try? SecureBuddyStore.randomKeyData(byteCount: 32) else {
            return Data(SHA256.hash(data: Data("dirmotion.watch.sync.local".utf8)))
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

    private static func loadKeychain(account: String) -> Data? {
        var query: [String: Any] = [
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
}
