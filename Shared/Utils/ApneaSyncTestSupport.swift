import Foundation

/// Deterministic Apnea sync crypto fixtures — mirrors Snorkeling/Watch test support.
enum ApneaSyncTestSupport {
    static let deterministicLocalSecret = WatchSyncTestSupport.deterministicLocalSecret
    static let deterministicPeerSecret = WatchSyncTestSupport.deterministicPeerSecret

    static func installDeterministicSecrets(
        local: Data = deterministicLocalSecret,
        peer: Data = deterministicPeerSecret
    ) {
        WatchSyncTestSupport.installDeterministicSecrets(local: local, peer: peer)
    }

    static func resetSecrets() {
        WatchSyncTestSupport.resetSecrets()
    }

    static func requirePeerSecret(file: StaticString = #filePath, line: UInt = #line) {
        WatchSyncTestSupport.requirePeerSecret(file: file, line: line)
    }
}
