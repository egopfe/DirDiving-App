import Foundation

/// Deterministic WatchConnectivity crypto fixtures for Snorkeling session/route sync unit tests.
/// Production code continues to use Keychain-backed secrets; tests must not XCTSkip on peer availability.
enum SnorkelingSyncTestSupport {
    static let deterministicLocalSecret = WatchSyncTestSupport.deterministicLocalSecret
    static let deterministicPeerSecret = Data(repeating: 13, count: 32)

    static func installDeterministicSecrets() {
        WatchSyncTestSupport.installDeterministicSecrets(
            local: deterministicLocalSecret,
            peer: deterministicPeerSecret
        )
    }

    static func resetSecrets() {
        WatchSyncTestSupport.resetSecrets()
    }

    static func requirePeerSecret(file: StaticString = #filePath, line: UInt = #line) {
        WatchSyncTestSupport.requirePeerSecret(file: file, line: line)
    }
}
