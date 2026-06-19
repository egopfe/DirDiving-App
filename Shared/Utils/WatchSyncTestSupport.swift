import Foundation

/// Deterministic WatchConnectivity crypto fixtures for unit/integration tests.
/// Production code continues to use Keychain-backed secrets; tests must not XCTSkip on peer availability.
enum WatchSyncTestSupport {
    static let deterministicLocalSecret = Data(repeating: 1, count: 32)
    static let deterministicPeerSecret = Data(repeating: 7, count: 32)

    static func installDeterministicSecrets(
        local: Data = deterministicLocalSecret,
        peer: Data = deterministicPeerSecret
    ) {
        WatchSyncAuth.resetPeerTrust()
#if DEBUG
        WatchSyncAuth.installTestSecrets(local: local, peer: peer)
#else
        _ = WatchSyncAuth.ingestSharedSecretFromContext([
            WatchSyncAuth.contextKey: peer.base64EncodedString()
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
            fatalError("Watch sync test peer secret unavailable after installDeterministicSecrets()", file: file, line: line)
        }
    }
}
