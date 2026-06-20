import XCTest

final class ActivitySyncEnvelopeTests: XCTestCase {
    func testPayloadKeyMatchesEnvelopeActivity() throws {
        let body = Data("test".utf8)
        WatchSyncTestSupport.installDeterministicSecrets()
        defer { WatchSyncTestSupport.resetSecrets() }
        let key = try WatchSyncAuth.deriveSyncKey(peerBundleID: "com.egopfe.dirdiving.ios")
        let transport = ActivitySyncSignedTransport.makeSigned(
            body: body,
            bundleID: "com.egopfe.dirdiving.ios.watch",
            activity: .apnea,
            messageType: .sessionUpsert,
            revision: 1,
            syncKey: key
        )
        XCTAssertThrowsError(
            try ActivitySyncRoutingGuard.validate(
                payloadKey: "dirdiving_dive_session",
                transport: transport
            )
        )
    }

    func testV3RequiresEnvelopeFields() {
        let transport = ActivitySyncSignedTransport(
            version: 3,
            bundleID: "com.egopfe.dirdiving.ios.watch",
            issuedAt: Date(),
            nonce: UUID().uuidString,
            messageID: nil,
            activityType: nil,
            messageType: nil,
            payloadHash: nil,
            revision: nil,
            body: Data(),
            signature: ""
        )
        XCTAssertThrowsError(
            try ActivitySyncRoutingGuard.validate(
                payloadKey: "dirdiving_apnea_session",
                transport: transport
            )
        )
    }
}
