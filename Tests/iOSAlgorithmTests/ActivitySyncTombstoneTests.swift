import XCTest
import CryptoKit

final class ActivitySyncTombstoneTests: XCTestCase {
    func testSignedTombstoneRoundTrip() throws {
        WatchSyncTestSupport.installDeterministicSecrets()
        defer { WatchSyncTestSupport.resetSecrets() }
        let key = try WatchSyncAuth.deriveSyncKey(peerBundleID: "com.egopfe.dirdiving.ios")
        let sessionID = UUID()
        let record = ActivitySyncTombstoneRecord(sessionID: sessionID, activity: .snorkeling, revision: 2)
        let signed = try ActivitySyncSignedTombstone.sign(
            record: record,
            syncKey: key,
            bundleID: "com.egopfe.dirdiving.ios.watch"
        )
        XCTAssertTrue(signed.verify(syncKey: key, expectedBundleID: "com.egopfe.dirdiving.ios.watch"))
        let payload = ActivitySyncTombstoneCodec.encodeBroadcastPayload(
            tombstones: [signed],
            broadcastKey: ActivitySyncTombstoneBroadcast.broadcastKey(for: .snorkeling)
        )
        let decoded = ActivitySyncTombstoneCodec.decodeBroadcastPayload(
            from: payload,
            broadcastKey: ActivitySyncTombstoneBroadcast.broadcastKey(for: .snorkeling)
        )
        XCTAssertEqual(decoded.first?.record.sessionID, sessionID)
    }

    func testTombstoneBeatsOlderUpsert() {
        let outcome = ActivitySyncTombstonePolicy.compareTombstone(existingRevision: 1, tombstoneRevision: 2)
        XCTAssertEqual(outcome, .acceptTombstone)
    }
}
