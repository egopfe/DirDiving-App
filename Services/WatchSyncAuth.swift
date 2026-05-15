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

    static func ingestSharedSecretFromContext(_ context: [String: Any]) {
        guard let encoded = context[contextKey] as? String,
              let secret = Data(base64Encoded: encoded),
              secret.count >= 32 else { return }
        savePeerSecret(secret)
    }

    static func syncKey(peerBundleID: String) -> SymmetricKey {
        let secret = loadPeerSecret() ?? loadOrCreateLocalSecret()
        var material = secret
        material.append(Data(peerBundleID.utf8))
        return SymmetricKey(data: SHA256.hash(data: material))
    }

    private static func loadOrCreateLocalSecret() -> Data {
        if let existing = loadKeychain(account: keychainAccount) {
            return existing
        }
        let generated = (try? SecureBuddyStore.randomKeyData(byteCount: 32)) ?? Data(UUID().uuidString.utf8)
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
