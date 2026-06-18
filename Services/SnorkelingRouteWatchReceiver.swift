import Foundation
import WatchConnectivity

enum SnorkelingRouteWatchReceiver {
    @MainActor
    static func importPayload(
        _ payload: [String: Any],
        store: SnorkelingImportedRouteStore,
        sessionInProgress: Bool
    ) -> [String: Any]? {
        guard SnorkelingRouteSyncTransferSupport.isPackageTransfer(payload) else { return nil }
        do {
            let package = try SnorkelingRouteSyncTransferSupport.decodePackage(from: payload)
            let imported = store.importPayload(package, source: "userInfo", sessionInProgress: sessionInProgress)
            return makeAck(for: package, imported: imported, errorCode: imported ? nil : errorCode(for: store))
        } catch {
            if let packageIDRaw = payload[SnorkelingRouteSyncTransferSupport.packageIDKey] as? String,
               let packageID = UUID(uuidString: packageIDRaw),
               let revision = payload[SnorkelingRouteSyncTransferSupport.revisionKey] as? Int,
               let checksum = payload[SnorkelingRouteSyncTransferSupport.checksumKey] as? String {
                return rejectedAck(packageID: packageID, revision: revision, checksum: checksum, errorCode: "decodeFailed")
            }
            return nil
        }
    }

    @MainActor
    static func importSnapshot(
        _ context: [String: Any],
        store: SnorkelingImportedRouteStore,
        sessionInProgress: Bool
    ) {
        guard SnorkelingRouteSyncTransferSupport.isSnapshotContext(context) else { return }
        guard let package = try? SnorkelingRouteSyncTransferSupport.decodePackageFromSnapshot(context) else { return }
        _ = store.importPayload(package, source: "applicationContext", sessionInProgress: sessionInProgress)
    }

    private static func makeAck(for package: SnorkelingRouteSyncPackage, imported: Bool, errorCode: String?) -> [String: Any] {
        let issuedAt = Date()
        let status = imported
            ? SnorkelingRouteSyncTransferSupport.ackStatusImported
            : SnorkelingRouteSyncTransferSupport.ackStatusRejected
        let signature = SnorkelingRouteSyncAckSigner.makeSignature(
            packageID: package.body.packageID,
            revision: package.body.revision,
            checksum: package.payloadChecksumSHA256,
            issuedAt: issuedAt
        )
        return SnorkelingRouteSyncTransferSupport.makeAckPayload(
            packageID: package.body.packageID,
            revision: package.body.revision,
            checksum: package.payloadChecksumSHA256,
            status: status,
            issuedAt: issuedAt,
            signature: signature,
            errorCode: errorCode
        )
    }

    private static func rejectedAck(packageID: UUID, revision: Int, checksum: String, errorCode: String) -> [String: Any] {
        let issuedAt = Date()
        let signature = SnorkelingRouteSyncAckSigner.makeSignature(
            packageID: packageID,
            revision: revision,
            checksum: checksum,
            issuedAt: issuedAt
        )
        return SnorkelingRouteSyncTransferSupport.makeAckPayload(
            packageID: packageID,
            revision: revision,
            checksum: checksum,
            status: SnorkelingRouteSyncTransferSupport.ackStatusRejected,
            issuedAt: issuedAt,
            signature: signature,
            errorCode: errorCode
        )
    }

    @MainActor
    private static func errorCode(for store: SnorkelingImportedRouteStore) -> String {
        if store.staleRevisionRejected { return "staleRevision" }
        switch store.lastImportError {
        case .futureSchema: return "futureSchema"
        case .unsupportedSchema: return "unsupportedSchema"
        case .checksumMismatch: return "checksumMismatch"
        case .expired: return "expired"
        case .invalidRoute: return "invalidRoute"
        case .unsupportedCapabilities: return "unsupportedCapabilities"
        case .decodeFailed, .none: return "invalidPackage"
        }
    }

    static func deliverAck(_ payload: [String: Any]) {
        guard WCSession.isSupported(), WCSession.default.activationState == .activated else { return }
        _ = WCSession.default.transferUserInfo(payload)
    }
}
