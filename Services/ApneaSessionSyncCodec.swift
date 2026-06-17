import Foundation
import CryptoKit
import WatchConnectivity

enum ApneaSessionSyncCodec {
    static let payloadKey = "dirdiving_apnea_session"
    static let importAckType = "dirdiving_apnea_session_import_ack"
    static let importAckSessionIDKey = "apneaSessionID"
    static let importAckIssuedAtKey = "apneaIssuedAt"
    static let importAckSignatureKey = "apneaAckSignature"

    static let legacySchemaVersion = 1
    static let schemaVersion = 2
    static let maxPayloadBytes = 512_000
    static let maxIssuedAtSkew: TimeInterval = 3_600
    static let importedToCompanionIDsKey = "dirdiving_watch_apnea_imported_to_companion_ids"
    static let importedToCompanionIDRetentionLimit = 512
    static var replayCache = SyncNonceReplayCache()
    private static let replayCacheFileName = "dirdiving_watch_apnea_sync_replay_cache.json"

    private static let expectedCompanionBundleID = "com.egopfe.dirdiving.ios"

    static func bootstrapReplayCacheIfNeeded() {
        replayCache.loadProtected(from: replayCacheFileURL())
    }

    private static func replayCacheFileURL() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(replayCacheFileName)
    }

    private static func persistReplayCache() {
        replayCache.persistProtected(to: replayCacheFileURL())
    }

    struct Transport: Codable {
        let version: Int
        let bundleID: String
        let issuedAt: Date
        let nonce: String?
        let body: Data
        let signature: String
    }

    struct PayloadEnvelope {
        let message: [String: Any]
        let sessionID: UUID
        let issuedAt: Date
    }

    struct ParsedPayload {
        let session: ApneaSession
        let issuedAt: Date
    }

    static func makePayload(session: ApneaSession) throws -> PayloadEnvelope {
        guard WatchSyncAuth.hasPeerSecret() else {
            throw ApneaSessionSyncError.missingPeerSecret
        }
        let transportSession = ApneaSessionMerge.preferred(session, session)
        try validate(transportSession)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let body = try encoder.encode(transportSession)
        guard body.count <= maxPayloadBytes else {
            throw ApneaSessionSyncError.payloadTooLarge
        }

        let issuedAt = Date()
        let nonce = UUID().uuidString
        let transport = Transport(
            version: schemaVersion,
            bundleID: Bundle.main.bundleIdentifier ?? "com.egopfe.dirdiving.ios.watch",
            issuedAt: issuedAt,
            nonce: nonce,
            body: body,
            signature: ""
        )
        let signed = sign(transport, issuedAt: issuedAt, body: body)
        let transportData = try JSONEncoder().encode(signed)
        guard transportData.count <= maxPayloadBytes else {
            throw ApneaSessionSyncError.payloadTooLarge
        }
        return PayloadEnvelope(
            message: [payloadKey: transportData],
            sessionID: transportSession.id,
            issuedAt: issuedAt
        )
    }

    static func parsePayload(from payload: [String: Any]) throws -> ParsedPayload {
        guard WCSession.default.activationState == .activated else {
            throw ApneaSessionSyncError.sessionInactive
        }
        guard WatchSyncAuth.hasPeerSecret() else {
            throw ApneaSessionSyncError.missingPeerSecret
        }
        guard let data = payload[payloadKey] as? Data else {
            throw ApneaSessionSyncError.missingPayload
        }
        guard data.count <= maxPayloadBytes else {
            throw ApneaSessionSyncError.payloadTooLarge
        }

        let transport = try JSONDecoder().decode(Transport.self, from: data)
        guard transport.version == legacySchemaVersion || transport.version == schemaVersion else {
            throw ApneaSessionSyncError.unsupportedVersion
        }
        guard transport.bundleID == expectedCompanionBundleID else {
            throw ApneaSessionSyncError.invalidSender
        }
        guard abs(transport.issuedAt.timeIntervalSinceNow) <= maxIssuedAtSkew else {
            throw ApneaSessionSyncError.stalePayload
        }
        guard verify(transport) else {
            throw ApneaSessionSyncError.invalidSignature
        }
        if transport.version == schemaVersion {
            guard let nonce = transport.nonce, !nonce.isEmpty else {
                throw ApneaSessionSyncError.invalidSignature
            }
            if replayCache.isReplay(nonce) {
                throw ApneaSessionSyncError.replayedPayload
            }
            guard replayCache.register(nonce) else {
                throw ApneaSessionSyncError.replayedPayload
            }
            persistReplayCache()
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let session = try decoder.decode(ApneaSession.self, from: transport.body)
        try validate(session)
        return ParsedPayload(session: session, issuedAt: transport.issuedAt)
    }

    static func ackSignature(sessionID: UUID, issuedAt: Date) -> String {
        guard WatchSyncAuth.hasPeerSecret(),
              let key = try? syncKey() else { return "" }
        let canonical = "apneaAck|\(sessionID.uuidString)|\(issuedAt.timeIntervalSince1970)"
        let code = HMAC<SHA256>.authenticationCode(for: Data(canonical.utf8), using: key)
        return Data(code).base64EncodedString()
    }

    static func verifyAckSignature(_ signature: String?, sessionID: UUID, issuedAt: Date) -> Bool {
        guard let signature,
              !signature.isEmpty,
              let providedData = Data(base64Encoded: signature) else { return false }
        let expected = ackSignature(sessionID: sessionID, issuedAt: issuedAt)
        guard !expected.isEmpty, let expectedData = Data(base64Encoded: expected) else { return false }
        return providedData.constantTimeEquals(expectedData)
    }

    static func isImportAck(_ payload: [String: Any]) -> Bool {
        payload["type"] as? String == importAckType
    }

    static func parseImportAck(from payload: [String: Any]) -> (sessionID: UUID, issuedAt: Date, signature: String)? {
        guard isImportAck(payload),
              let sessionIDString = payload[importAckSessionIDKey] as? String,
              let sessionID = UUID(uuidString: sessionIDString),
              let issuedAtInterval = payload[importAckIssuedAtKey] as? TimeInterval,
              let signature = payload[importAckSignatureKey] as? String else {
            return nil
        }
        let issuedAt = Date(timeIntervalSince1970: issuedAtInterval)
        guard abs(issuedAt.timeIntervalSinceNow) <= maxIssuedAtSkew else { return nil }
        return (sessionID, issuedAt, signature)
    }

    static func makeImportAckPayload(sessionID: UUID, issuedAt: Date) -> [String: Any] {
        [
            "type": importAckType,
            importAckSessionIDKey: sessionID.uuidString,
            importAckIssuedAtKey: issuedAt.timeIntervalSince1970,
            importAckSignatureKey: ackSignature(sessionID: sessionID, issuedAt: issuedAt),
        ]
    }

    static func loadImportedToCompanionIDs() -> Set<UUID> {
        guard let strings = UserDefaults.standard.stringArray(forKey: importedToCompanionIDsKey) else {
            return []
        }
        return Set(strings.compactMap(UUID.init(uuidString:)))
    }

    static func saveImportedToCompanionIDs(_ ids: Set<UUID>) {
        let sorted = ids.map(\.uuidString).sorted()
        let trimmed = Array(sorted.suffix(importedToCompanionIDRetentionLimit))
        UserDefaults.standard.set(trimmed, forKey: importedToCompanionIDsKey)
    }

    private static func syncKey() throws -> SymmetricKey {
        try WatchSyncAuth.deriveSyncKey(peerBundleID: expectedCompanionBundleID)
    }

    private static func sign(_ transport: Transport, issuedAt: Date, body: Data) -> Transport {
        let mac = hmac(transport: transport, issuedAt: issuedAt, body: body)
        return Transport(
            version: transport.version,
            bundleID: transport.bundleID,
            issuedAt: issuedAt,
            nonce: transport.nonce,
            body: body,
            signature: mac
        )
    }

    private static func hmac(transport: Transport, issuedAt: Date, body: Data) -> String {
        guard let key = try? syncKey() else { return "" }
        let nonceComponent = transport.version >= schemaVersion ? (transport.nonce ?? "") : ""
        let canonical = "\(transport.version)|\(transport.bundleID)|\(issuedAt.timeIntervalSince1970)|\(nonceComponent)|\(body.base64EncodedString())"
        let code = HMAC<SHA256>.authenticationCode(for: Data(canonical.utf8), using: key)
        return Data(code).base64EncodedString()
    }

    private static func verify(_ transport: Transport) -> Bool {
        guard let key = try? syncKey() else { return false }
        let nonceComponent = transport.version >= schemaVersion ? (transport.nonce ?? "") : ""
        let canonical = "\(transport.version)|\(transport.bundleID)|\(transport.issuedAt.timeIntervalSince1970)|\(nonceComponent)|\(transport.body.base64EncodedString())"
        let code = HMAC<SHA256>.authenticationCode(for: Data(canonical.utf8), using: key)
        let expected = Data(code).base64EncodedString()
        guard let received = Data(base64Encoded: transport.signature) else { return false }
        guard let expectedData = Data(base64Encoded: expected) else { return false }
        return received.constantTimeEquals(expectedData)
    }

    private static func validate(_ session: ApneaSession) throws {
        guard ApneaDomainValidator.isValid(session: session) else {
            throw ApneaSessionSyncError.invalidSession
        }
        switch ApneaLogbookPolicy.classify(session) {
        case .exportable:
            return
        case .invalid:
            throw ApneaSessionSyncError.invalidSession
        }
    }
}

private extension Data {
    func constantTimeEquals(_ other: Data) -> Bool {
        guard count == other.count else { return false }
        return zip(self, other).reduce(UInt8(0)) { $0 | ($1.0 ^ $1.1) } == 0
    }
}

enum ApneaSessionSyncError: LocalizedError, Equatable {
    case payloadTooLarge
    case missingPeerSecret
    case missingPayload
    case unsupportedVersion
    case invalidSender
    case stalePayload
    case invalidSignature
    case invalidSession
    case sessionInactive
    case replayedPayload

    var errorDescription: String? {
        switch self {
        case .payloadTooLarge: return "Apnea payload too large."
        case .missingPeerSecret: return "Companion sync key unavailable."
        case .missingPayload: return "Missing Apnea payload."
        case .unsupportedVersion: return "Unsupported Apnea sync version."
        case .invalidSender: return "Invalid Apnea sync sender."
        case .stalePayload: return "Stale Apnea payload."
        case .invalidSignature: return "Invalid Apnea signature."
        case .invalidSession: return "Invalid Apnea session."
        case .sessionInactive: return "WatchConnectivity inactive."
        case .replayedPayload: return "Replayed Apnea payload."
        }
    }
}
