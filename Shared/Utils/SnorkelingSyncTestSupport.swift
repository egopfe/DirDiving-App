import Foundation

/// Deterministic WatchConnectivity crypto fixtures for Snorkeling session/route sync unit tests.
/// Production code continues to use Keychain-backed secrets; tests must not XCTSkip on peer availability.
enum SnorkelingSyncTestSupport {
    static let deterministicLocalSecret = Data(repeating: 1, count: 32)
    static let deterministicPeerSecret = Data(repeating: 13, count: 32)

    static func installDeterministicSecrets() {
        WatchSyncAuth.resetPeerTrust()
#if DEBUG
        WatchSyncAuth.installTestSecrets(local: deterministicLocalSecret, peer: deterministicPeerSecret)
#else
        _ = WatchSyncAuth.ingestSharedSecretFromContext([
            WatchSyncAuth.contextKey: deterministicPeerSecret.base64EncodedString()
        ])
#endif
    }

    static func resetSecrets() {
        WatchSyncAuth.resetPeerTrust()
#if DEBUG
        WatchSyncAuth.resetTestSecrets()
#endif
    }

    static func requirePeerSecret(file: StaticString = #filePath, line: UInt = #line) {
        guard WatchSyncAuth.hasPeerSecret() else {
            fatalError("Snorkeling sync test peer secret unavailable after installDeterministicSecrets()", file: file, line: line)
        }
    }
}
