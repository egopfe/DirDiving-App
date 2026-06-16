import Foundation

enum DivePlanPackageTransferSupport {
    static let transferTypeKey = "transferType"
    static let transferTypePackage = "fullComputerPlanPackage"
    static let transferTypeAck = "fullComputerPlanPackageAck"
    static let transferTypeSnapshot = "fullComputerPlanPackageSnapshot"

    static let planIDKey = "planID"
    static let revisionKey = "revision"
    static let checksumKey = "checksum"
    static let payloadBase64Key = "payloadBase64"
    static let issuedAtKey = "issuedAt"
    static let ackSignatureKey = "ackSignature"
    static let ackStatusKey = "status"
    static let ackStatusImported = "imported"
    static let ackStatusRejected = "rejected"
    static let ackErrorCodeKey = "errorCode"
    static let capabilitySchemaKey = "fcPlanCapabilitySchema"
    static let capabilityAlgorithmKey = "fcPlanCapabilityAlgorithm"

    static let applicationContextSnapshotKey = "dirdiving_fc_plan_snapshot"
    static let applicationContextPlanIDKey = "dirdiving_fc_plan_id"
    static let applicationContextRevisionKey = "dirdiving_fc_plan_revision"
    static let applicationContextChecksumKey = "dirdiving_fc_plan_checksum"

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

    static func makeTransferUserInfo(packageData: Data, package: DivePlanPackage) -> [String: Any] {
        [
            transferTypeKey: transferTypePackage,
            planIDKey: package.body.planID.uuidString,
            revisionKey: package.body.revision,
            checksumKey: package.payloadChecksumSHA256,
            payloadBase64Key: packageData.base64EncodedString(),
            capabilitySchemaKey: DivePlanPackageCodec.currentSchemaVersion,
            capabilityAlgorithmKey: DivePlanPackageCodec.algorithmVersion,
            issuedAtKey: Date().timeIntervalSince1970,
        ]
    }

    static func makeSnapshotContext(packageData: Data, package: DivePlanPackage) -> [String: Any] {
        [
            applicationContextSnapshotKey: packageData.base64EncodedString(),
            applicationContextPlanIDKey: package.body.planID.uuidString,
            applicationContextRevisionKey: package.body.revision,
            applicationContextChecksumKey: package.payloadChecksumSHA256,
            capabilitySchemaKey: DivePlanPackageCodec.currentSchemaVersion,
            capabilityAlgorithmKey: DivePlanPackageCodec.algorithmVersion,
        ]
    }

    static func decodePackage(from payload: [String: Any]) throws -> DivePlanPackage {
        if let encoded = payload[payloadBase64Key] as? String,
           let data = Data(base64Encoded: encoded) {
            return try DivePlanPackageCodec.decode(data)
        }
        throw DivePlanPackageValidationError.decodeFailed
    }

    static func decodePackageFromSnapshot(_ context: [String: Any]) throws -> DivePlanPackage {
        guard let encoded = context[applicationContextSnapshotKey] as? String,
              let data = Data(base64Encoded: encoded) else {
            throw DivePlanPackageValidationError.decodeFailed
        }
        return try DivePlanPackageCodec.decode(data)
    }

    struct ParsedAck: Equatable {
        let planID: UUID
        let revision: Int
        let checksum: String
        let status: String
        let issuedAt: Date
        let signature: String?
        let errorCode: String?
    }

    static func parseAck(_ payload: [String: Any]) -> ParsedAck? {
        guard isPackageAck(payload),
              let planIDRaw = payload[planIDKey] as? String,
              let planID = UUID(uuidString: planIDRaw),
              let revision = payload[revisionKey] as? Int,
              let checksum = payload[checksumKey] as? String,
              let status = payload[ackStatusKey] as? String,
              let issuedAtInterval = payload[issuedAtKey] as? TimeInterval else {
            return nil
        }
        let issuedAt = Date(timeIntervalSince1970: issuedAtInterval)
        guard abs(issuedAt.timeIntervalSinceNow) <= DivePlanPackageCodec.maxIssuedAtSkew else { return nil }
        return ParsedAck(
            planID: planID,
            revision: revision,
            checksum: checksum,
            status: status,
            issuedAt: issuedAt,
            signature: payload[ackSignatureKey] as? String,
            errorCode: payload[ackErrorCodeKey] as? String
        )
    }

    static func makeAckPayload(
        planID: UUID,
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
            planIDKey: planID.uuidString,
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
