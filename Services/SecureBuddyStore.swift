import Foundation
import Security

final class SecureBuddyStore {
    private let service = "com.egopfe.dirdiving.secure-buddy"

    func saveBuddyKey(_ keyData: Data, for buddyIdentifier: String) throws {
        let query = baseQuery(for: buddyIdentifier)
        SecItemDelete(query as CFDictionary)

        var attributes = query
        attributes[kSecValueData as String] = keyData
        attributes[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly

        let status = SecItemAdd(attributes as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.unhandledStatus(status)
        }
    }

    func loadBuddyKey(for buddyIdentifier: String) -> Data? {
        var query = baseQuery(for: buddyIdentifier)
        query[kSecReturnData as String] = kCFBooleanTrue
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess else { return nil }
        return result as? Data
    }

    func deleteBuddyKey(for buddyIdentifier: String) {
        SecItemDelete(baseQuery(for: buddyIdentifier) as CFDictionary)
    }

    static func randomKeyData(byteCount: Int) throws -> Data {
        var bytes = [UInt8](repeating: 0, count: byteCount)
        let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        guard status == errSecSuccess else {
            throw KeychainError.unhandledStatus(status)
        }
        return Data(bytes)
    }

    private func baseQuery(for buddyIdentifier: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: buddyIdentifier
        ]
    }

    private enum KeychainError: Error {
        case unhandledStatus(OSStatus)
    }
}
