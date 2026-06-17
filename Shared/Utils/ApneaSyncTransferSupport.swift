import Foundation

enum ApneaSyncTransferSupport {
    static let transferTypeKey = "transferType"
    static let transferTypePackage = "apneaSyncPlanPackage"
    static let transferTypeAck = "apneaSyncPlanPackageAck"
    static let transferTypeSnapshot = "apneaSyncPlanPackageSnapshot"

    static let packageIDKey = "packageID"
    static let revisionKey = "revision"
    static let checksumKey = "checksum"
    static let payloadBase64Key = "payloadBase64"
    static let issuedAtKey = "issuedAt"
    static let ackSignatureKey = "ackSignature"
    static let ackStatusKey = "status"
    static let ackStatusImported = "imported"
    static let ackStatusRejected = "rejected"
    static let ackErrorCodeKey = "errorCode"
    static let capabilitySchemaKey = "apneaSyncCapabilitySchema"
    static let capabilityAlgorithmKey = "apneaSyncCapabilityAlgorithm"

    static let applicationContextSnapshotKey = "dirdiving_apnea_plan_snapshot"
    static let applicationContextPackageIDKey = "dirdiving_apnea_plan_id"
    static let applicationContextRevisionKey = "dirdiving_apnea_plan_revision"
    static let applicationContextChecksumKey = "dirdiving_apnea_plan_checksum"

    static func isPackageTransfer(_ payload: [String: Any]) -> Bool {
        payload[transferTypeKey] as? String == transferTypePackage
    }

    static func isPackageAck(_ payload: [String: Any]) -> Bool {
        payload[transferTypeKey] as? String == transferTypeAck
            || payload["type"] as? String == transferTypeAck
    }

    static func isSnapshotContext(_ context: [String: Any]) -> Bool {
        context[applicationContextSnapshotKey] != nil
    }

    static func makeTransferUserInfo(packageData: Data, package: ApneaSyncPackage) -> [String: Any] {
        [
            transferTypeKey: transferTypePackage,
            packageIDKey: package.body.packageID.uuidString,
            revisionKey: package.body.revision,
            checksumKey: package.payloadChecksumSHA256,
            payloadBase64Key: packageData.base64EncodedString(),
            capabilitySchemaKey: ApneaSyncCodec.currentSchemaVersion,
            capabilityAlgorithmKey: ApneaSyncCodec.algorithmVersion,
            issuedAtKey: Date().timeIntervalSince1970,
        ]
    }

    static func makeSnapshotContext(packageData: Data, package: ApneaSyncPackage) -> [String: Any] {
        [
            applicationContextSnapshotKey: packageData.base64EncodedString(),
            applicationContextPackageIDKey: package.body.packageID.uuidString,
            applicationContextRevisionKey: package.body.revision,
            applicationContextChecksumKey: package.payloadChecksumSHA256,
            capabilitySchemaKey: ApneaSyncCodec.currentSchemaVersion,
            capabilityAlgorithmKey: ApneaSyncCodec.algorithmVersion,
        ]
    }

    static func decodePackage(from payload: [String: Any]) throws -> ApneaSyncPackage {
        if let encoded = payload[payloadBase64Key] as? String,
           let data = Data(base64Encoded: encoded) {
            return try ApneaSyncCodec.decode(data)
        }
        throw ApneaSyncValidationError.decodeFailed
    }

    static func decodePackageFromSnapshot(_ context: [String: Any]) throws -> ApneaSyncPackage {
        guard let encoded = context[applicationContextSnapshotKey] as? String,
              let data = Data(base64Encoded: encoded) else {
            throw ApneaSyncValidationError.decodeFailed
        }
        return try ApneaSyncCodec.decode(data)
    }

    struct ParsedAck: Equatable {
        let packageID: UUID
        let revision: Int
        let checksum: String
        let status: String
        let issuedAt: Date
        let signature: String?
        let errorCode: String?
    }

    static func parseAck(_ payload: [String: Any]) -> ParsedAck? {
        guard isPackageAck(payload),
              let packageIDRaw = payload[packageIDKey] as? String,
              let packageID = UUID(uuidString: packageIDRaw),
              let revision = payload[revisionKey] as? Int,
              let checksum = payload[checksumKey] as? String,
              let status = payload[ackStatusKey] as? String,
              let issuedAtInterval = payload[issuedAtKey] as? TimeInterval else {
            return nil
        }
        let issuedAt = Date(timeIntervalSince1970: issuedAtInterval)
        guard abs(issuedAt.timeIntervalSinceNow) <= ApneaSyncCodec.maxIssuedAtSkew else { return nil }
        return ParsedAck(
            packageID: packageID,
            revision: revision,
            checksum: checksum,
            status: status,
            issuedAt: issuedAt,
            signature: payload[ackSignatureKey] as? String,
            errorCode: payload[ackErrorCodeKey] as? String
        )
    }

    static func makeAckPayload(
        packageID: UUID,
        revision: Int,
        checksum: String,
        status: String,
        issuedAt: Date,
        signature: String,
        errorCode: String? = nil
    ) -> [String: Any] {
        var payload: [String: Any] = [
            transferTypeKey: transferTypeAck,
            "type": transferTypeAck,
            packageIDKey: packageID.uuidString,
            revisionKey: revision,
            checksumKey: checksum,
            ackStatusKey: status,
            issuedAtKey: issuedAt.timeIntervalSince1970,
            ackSignatureKey: signature,
        ]
        if let errorCode {
            payload[ackErrorCodeKey] = errorCode
        }
        return payload
    }
}
