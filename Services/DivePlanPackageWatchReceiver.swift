import Foundation
import WatchConnectivity

enum DivePlanPackageWatchReceiver {
    @MainActor
    static func importPayload(
        _ payload: [String: Any],
        store: FullComputerImportedPlanStore
    ) -> [String: Any]? {
        guard DivePlanPackageTransferSupport.isPackageTransfer(payload) else { return nil }
        do {
            let package = try DivePlanPackageTransferSupport.decodePackage(from: payload)
            let imported = store.importPayload(package, source: "userInfo")
            return makeAck(for: package, imported: imported, errorCode: imported ? nil : errorCode(for: store.lastImportError))
        } catch {
            if let planIDRaw = payload[DivePlanPackageTransferSupport.planIDKey] as? String,
               let planID = UUID(uuidString: planIDRaw),
               let revision = payload[DivePlanPackageTransferSupport.revisionKey] as? Int,
               let checksum = payload[DivePlanPackageTransferSupport.checksumKey] as? String {
                return rejectedAck(planID: planID, revision: revision, checksum: checksum, errorCode: "decodeFailed")
            }
            return nil
        }
    }

    @MainActor
    static func importSnapshot(
        _ context: [String: Any],
        store: FullComputerImportedPlanStore
    ) {
        guard DivePlanPackageTransferSupport.isSnapshotContext(context) else { return }
        guard let package = try? DivePlanPackageTransferSupport.decodePackageFromSnapshot(context) else { return }
        _ = store.importPayload(package, source: "applicationContext")
    }

    private static func makeAck(for package: DivePlanPackage, imported: Bool, errorCode: String?) -> [String: Any] {
        let issuedAt = Date()
        let status = imported
            ? DivePlanPackageTransferSupport.ackStatusImported
            : DivePlanPackageTransferSupport.ackStatusRejected
        let signature = DivePlanPackageAckSigner.makeSignature(
            planID: package.body.planID,
            revision: package.body.revision,
            checksum: package.payloadChecksumSHA256,
            issuedAt: issuedAt
        )
        return DivePlanPackageTransferSupport.makeAckPayload(
            planID: package.body.planID,
            revision: package.body.revision,
            checksum: package.payloadChecksumSHA256,
            status: status,
            issuedAt: issuedAt,
            signature: signature,
            errorCode: errorCode
        )
    }

    private static func rejectedAck(planID: UUID, revision: Int, checksum: String, errorCode: String) -> [String: Any] {
        let issuedAt = Date()
        let signature = DivePlanPackageAckSigner.makeSignature(
            planID: planID,
            revision: revision,
            checksum: checksum,
            issuedAt: issuedAt
        )
        return DivePlanPackageTransferSupport.makeAckPayload(
            planID: planID,
            revision: revision,
            checksum: checksum,
            status: DivePlanPackageTransferSupport.ackStatusRejected,
            issuedAt: issuedAt,
            signature: signature,
            errorCode: errorCode
        )
    }

    private static func errorCode(for error: DivePlanPackageValidationError?) -> String {
        switch error {
        case .futureSchema: return "futureSchema"
        case .unsupportedSchema: return "unsupportedSchema"
        case .checksumMismatch: return "checksumMismatch"
        case .expired: return "expired"
        case .invalidGradientFactors: return "invalidGF"
        case .invalidGases: return "invalidGases"
        case .unsupportedCapabilities: return "unsupportedCapabilities"
        case .decodeFailed, .none: return "invalidPackage"
        }
    }

    static func deliverAck(_ payload: [String: Any]) {
        guard WCSession.isSupported(), WCSession.default.activationState == .activated else { return }
        _ = WCSession.default.transferUserInfo(payload)
    }
}
