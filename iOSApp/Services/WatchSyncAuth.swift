import Foundation
import CryptoKit
import Security
import WatchConnectivity

enum WatchSyncAuth {
    static let contextKey = "dirdiving_watch_sync_secret"
    private static let keychainService = "com.egopfe.dirmotion.watch-sync"
    private static let keychainAccount = "shared-secret"

    static func hasPeerSecret() -> Bool {
        loadPeerSecret() != nil
    }

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
        NotificationCenter.default.post(name: .watchSyncPeerSecretDidUpdate, object: nil)
    }

    static func syncKey(peerBundleID: String) -> SymmetricKey {
        guard let secret = loadPeerSecret() else {
            assertionFailure("Watch sync key requested before peer secret verification.")
            return SymmetricKey(data: Data(repeating: 0, count: 32))
        }
        var material = secret
        material.append(Data(peerBundleID.utf8))
        return SymmetricKey(data: SHA256.hash(data: material))
    }

    static func cachedApplicationContext() -> [String: Any] {
        guard WCSession.isSupported() else { return [:] }
        return WCSession.default.receivedApplicationContext
    }

    private static func loadOrCreateLocalSecret() -> Data {
        if let existing = loadKeychain(account: keychainAccount) {
            return existing
        }
        guard let generated = try? randomKeyData(byteCount: 32) else {
            return Data(SHA256.hash(data: Data("dirmotion.ios.sync.local".utf8)))
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

    private enum KeychainError: Error {
        case unhandledStatus(OSStatus)
    }
}
