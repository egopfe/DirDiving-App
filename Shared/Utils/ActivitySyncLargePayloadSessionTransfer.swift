import Foundation
import CryptoKit
import WatchConnectivity

enum ActivitySyncLargePayloadSessionTransfer {
    static func sendSessionPackage(
        transport: ActivitySyncSignedTransport,
        activity: ActivitySyncActivityType,
        sessionID: UUID,
        revision: Int,
        syncKey: SymmetricKey
    ) throws -> URL {
        let package = try ActivitySyncLargePayloadTransfer.makePackage(
            transport: transport,
            activity: activity,
            sessionID: sessionID,
            revision: revision
        )
        let data = try ActivitySyncLargePayloadTransfer.encodePackage(package)
        let fileName = "DIRDivingLargeSync_\(sessionID.uuidString).json"
        let url = try ActivitySyncLargePayloadTransfer.stageOutgoingPackage(data, fileName: fileName)
        let metadata = ActivitySyncLargePayloadTransfer.makeTransferMetadata(
            package: package,
            packageFileName: fileName,
            syncKey: syncKey
        )
        _ = WCSession.default.transferFile(url, metadata: metadata)
        return url
    }

    static func importSessionPackage(from url: URL, metadata: [String: Any], syncKey: SymmetricKey) throws -> ActivitySyncLargePayloadTransfer.Package {
        guard ActivitySyncLargePayloadTransfer.verifyTransferMetadata(metadata, syncKey: syncKey) else {
            throw ActivitySyncLargePayloadError.corruptHash
        }
        return try ActivitySyncLargePayloadTransfer.decodePackage(from: url)
    }
}
