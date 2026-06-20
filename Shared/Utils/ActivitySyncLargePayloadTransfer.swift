import Foundation
import CryptoKit

/// File-transfer fallback for session payloads exceeding direct WC `userInfo` limits (SYNC-P2-002).
enum ActivitySyncLargePayloadTransfer {
    static let transferTypeKey = "activitySyncLargePayload"
    static let activityTypeKey = "activityType"
    static let messageTypeKey = "messageType"
    static let messageIDKey = "messageID"
    static let sessionIDKey = "sessionID"
    static let revisionKey = "revision"
    static let schemaVersionKey = "schemaVersion"
    static let payloadSizeKey = "payloadSize"
    static let payloadHashKey = "payloadHash"
    static let createdAtKey = "createdAt"
    static let signatureKey = "signature"
    static let packageFileNameKey = "packageFileName"

    static let maxDirectPayloadBytes = 512_000
    static let maxPackageBytes = 5 * 1_024 * 1_024

    struct Manifest: Codable, Equatable {
        let activityType: String
        let messageType: String
        let schemaVersion: Int
        let messageID: UUID
        let sessionID: UUID
        let revision: Int
        let payloadSize: Int
        let payloadHash: String
        let createdAt: Date
    }

    struct Package: Codable, Equatable {
        let manifest: Manifest
        let transport: ActivitySyncSignedTransport
    }

    static func isLargePayloadTransfer(_ metadata: [String: Any]) -> Bool {
        metadata[transferTypeKey] as? String == transferTypeKey
    }

    static func shouldUseFileTransfer(transportDataSize: Int) -> Bool {
        transportDataSize > maxDirectPayloadBytes
    }

    static func makePackage(
        transport: ActivitySyncSignedTransport,
        activity: ActivitySyncActivityType,
        sessionID: UUID,
        revision: Int,
        messageID: UUID = UUID()
    ) throws -> Package {
        let transportData = try transportEncoder().encode(transport)
        guard transportData.count <= maxPackageBytes else {
            throw ActivitySyncLargePayloadError.packageTooLarge
        }
        let manifest = Manifest(
            activityType: activity.rawValue,
            messageType: ActivitySyncMessageType.sessionUpsert.rawValue,
            schemaVersion: transport.version,
            messageID: messageID,
            sessionID: sessionID,
            revision: revision,
            payloadSize: transportData.count,
            payloadHash: ActivitySyncSignedTransport.payloadHash(for: transportData),
            createdAt: Date()
        )
        return Package(manifest: manifest, transport: transport)
    }

    private static func transportEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }

    private static func transportDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    static func encodePackage(_ package: Package) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(package)
        guard data.count <= maxPackageBytes else {
            throw ActivitySyncLargePayloadError.packageTooLarge
        }
        return data
    }

    static func decodePackage(from url: URL) throws -> Package {
        let data = try Data(contentsOf: url)
        guard data.count <= maxPackageBytes else {
            throw ActivitySyncLargePayloadError.packageTooLarge
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let package = try decoder.decode(Package.self, from: data)
        let transportData = try transportEncoder().encode(package.transport)
        guard transportData.count == package.manifest.payloadSize else {
            throw ActivitySyncLargePayloadError.partialTransfer
        }
        let hash = ActivitySyncSignedTransport.payloadHash(for: transportData)
        guard hash == package.manifest.payloadHash else {
            throw ActivitySyncLargePayloadError.corruptHash
        }
        return package
    }

    static func makeTransferMetadata(
        package: Package,
        packageFileName: String,
        syncKey: SymmetricKey
    ) -> [String: Any] {
        let manifest = package.manifest
        let canonical = [
            transferTypeKey,
            manifest.activityType,
            manifest.messageType,
            manifest.messageID.uuidString,
            manifest.sessionID.uuidString,
            "\(manifest.revision)",
            "\(manifest.schemaVersion)",
            "\(manifest.payloadSize)",
            manifest.payloadHash,
            "\(manifest.createdAt.timeIntervalSince1970)",
        ].joined(separator: "|")
        let code = HMAC<SHA256>.authenticationCode(for: Data(canonical.utf8), using: syncKey)
        return [
            transferTypeKey: transferTypeKey,
            activityTypeKey: manifest.activityType,
            messageTypeKey: manifest.messageType,
            messageIDKey: manifest.messageID.uuidString,
            sessionIDKey: manifest.sessionID.uuidString,
            revisionKey: manifest.revision,
            schemaVersionKey: manifest.schemaVersion,
            payloadSizeKey: manifest.payloadSize,
            payloadHashKey: manifest.payloadHash,
            createdAtKey: manifest.createdAt.timeIntervalSince1970,
            packageFileNameKey: packageFileName,
            signatureKey: Data(code).base64EncodedString(),
        ]
    }

    static func verifyTransferMetadata(_ metadata: [String: Any], syncKey: SymmetricKey) -> Bool {
        guard isLargePayloadTransfer(metadata),
              let activityType = metadata[activityTypeKey] as? String,
              let messageType = metadata[messageTypeKey] as? String,
              let messageID = metadata[messageIDKey] as? String,
              let sessionID = metadata[sessionIDKey] as? String,
              let revision = metadata[revisionKey] as? Int,
              let schemaVersion = metadata[schemaVersionKey] as? Int,
              let payloadSize = metadata[payloadSizeKey] as? Int,
              let payloadHash = metadata[payloadHashKey] as? String,
              let createdAt = metadata[createdAtKey] as? TimeInterval,
              let signature = metadata[signatureKey] as? String else {
            return false
        }
        let canonical = [
            transferTypeKey,
            activityType,
            messageType,
            messageID,
            sessionID,
            "\(revision)",
            "\(schemaVersion)",
            "\(payloadSize)",
            payloadHash,
            "\(createdAt)",
        ].joined(separator: "|")
        let code = HMAC<SHA256>.authenticationCode(for: Data(canonical.utf8), using: syncKey)
        let expected = Data(code).base64EncodedString()
        guard let received = Data(base64Encoded: signature),
              let expectedData = Data(base64Encoded: expected) else {
            return false
        }
        return received.constantTimeEquals(expectedData)
    }

    static func stageOutgoingPackage(_ data: Data, fileName: String) throws -> URL {
        guard data.count <= maxPackageBytes else {
            throw ActivitySyncLargePayloadError.packageTooLarge
        }
        let sanitized = (fileName as NSString).lastPathComponent
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("DIRDivingLargeSync_\(UUID().uuidString)_\(sanitized)")
        try data.write(to: url, options: [.atomic, .completeFileProtection])
        return url
    }
}

enum ActivitySyncLargePayloadError: Error, Equatable {
    case packageTooLarge
    case partialTransfer
    case corruptHash
    case invalidActivity
    case unsupportedSchema
}

private extension Data {
    func constantTimeEquals(_ other: Data) -> Bool {
        guard count == other.count else { return false }
        return zip(self, other).reduce(UInt8(0)) { $0 | ($1.0 ^ $1.1) } == 0
    }
}
