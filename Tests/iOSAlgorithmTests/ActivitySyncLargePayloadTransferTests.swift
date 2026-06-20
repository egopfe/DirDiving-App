import XCTest
import CryptoKit

final class ActivitySyncLargePayloadTransferTests: XCTestCase {
    func testDirectLimitBoundary() {
        XCTAssertFalse(ActivitySyncLargePayloadTransfer.shouldUseFileTransfer(transportDataSize: 512_000))
        XCTAssertTrue(ActivitySyncLargePayloadTransfer.shouldUseFileTransfer(transportDataSize: 512_001))
    }

    func testPackageHashVerification() throws {
        WatchSyncTestSupport.installDeterministicSecrets()
        defer { WatchSyncTestSupport.resetSecrets() }
        let key = try WatchSyncAuth.deriveSyncKey(peerBundleID: "com.egopfe.dirdiving.ios")
        let body = Data(repeating: 1, count: 64)
        let transport = ActivitySyncSignedTransport.makeSigned(
            body: body,
            bundleID: "com.egopfe.dirdiving.ios.watch",
            activity: .diving,
            messageType: .sessionUpsert,
            revision: 1,
            syncKey: key
        )
        let package = try ActivitySyncLargePayloadTransfer.makePackage(
            transport: transport,
            activity: .diving,
            sessionID: UUID(),
            revision: 1
        )
        let data = try ActivitySyncLargePayloadTransfer.encodePackage(package)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("large-\(UUID().uuidString).json")
        try data.write(to: url)
        defer { try? FileManager.default.removeItem(at: url) }
        let decoded = try ActivitySyncLargePayloadTransfer.decodePackage(from: url)
        XCTAssertEqual(decoded.manifest.payloadHash, package.manifest.payloadHash)
    }
}
