import Foundation
import CryptoKit
import WatchConnectivity

enum SnorkelingSessionSyncCodec {
    static let payloadKey = "dirdiving_snorkeling_session_sync"
    static let importAckType = "dirdiving_snorkeling_session_import_ack"
    static let importAckSessionIDKey = "snorkelingSessionID"
    static let importAckIssuedAtKey = "snorkelingIssuedAt"
    static let importAckSignatureKey = "snorkelingAckSignature"

    static let legacySchemaVersion = 1
    static let schemaVersion = 2
    static let maxPayloadBytes = 512_000
    static let maxIssuedAtSkew: TimeInterval = 3_600
    static let importedToCompanionIDsKey = "dirdiving_watch_snorkeling_imported_to_companion_ids"
    static let importedToCompanionIDRetentionLimit = 512
    static var replayCache = SyncNonceReplayCache()
    private static let replayCacheFileName = "dirdiving_watch_snorkeling_sync_replay_cache.json"

#if DEBUG
    static var testHook_bypassConnectivityChecks = false
    static var testHook_replayCacheFileURL: URL?

    static func resetTestHooks() {
        testHook_bypassConnectivityChecks = false
        testHook_replayCacheFileURL = nil
        replayCache.reset()
        UserDefaults.standard.removeObject(forKey: importedToCompanionIDsKey)
    }
#endif

    private static let expectedCompanionBundleID = "com.egopfe.dirdiving.ios"

    static func bootstrapReplayCacheIfNeeded() {
        replayCache.loadProtected(from: replayCacheFileURL())
    }

    private static func replayCacheFileURL() -> URL {
#if DEBUG
        if let override = testHook_replayCacheFileURL { return override }
#endif
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
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
        let session: SnorkelingSession
        let issuedAt: Date
    }

    static func makePayload(session: SnorkelingSession) throws -> PayloadEnvelope {
        guard WatchSyncAuth.hasPeerSecret() else {
            throw SnorkelingSessionSyncError.missingPeerSecret
        }
        let transportSession = SnorkelingSessionMerge.preferred(session, session)
        try validate(transportSession)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let body = try encoder.encode(transportSession)
        guard body.count <= maxPayloadBytes else {
            throw SnorkelingSessionSyncError.payloadTooLarge
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
            throw SnorkelingSessionSyncError.payloadTooLarge
        }
        return PayloadEnvelope(
            message: [payloadKey: transportData],
            sessionID: transportSession.id,
            issuedAt: issuedAt
        )
    }

    static func parsePayload(from payload: [String: Any]) throws -> ParsedPayload {
#if DEBUG
        if !testHook_bypassConnectivityChecks {
            guard WCSession.default.activationState == .activated else {
                throw SnorkelingSessionSyncError.sessionInactive
            }
        }
#else
        guard WCSession.default.activationState == .activated else {
            throw SnorkelingSessionSyncError.sessionInactive
        }
#endif
        guard WatchSyncAuth.hasPeerSecret() else {
            throw SnorkelingSessionSyncError.missingPeerSecret
        }
        guard let data = payload[payloadKey] as? Data else {
            throw SnorkelingSessionSyncError.missingPayload
        }
        guard data.count <= maxPayloadBytes else {
            throw SnorkelingSessionSyncError.payloadTooLarge
        }

        let transport = try JSONDecoder().decode(Transport.self, from: data)
        guard transport.version == legacySchemaVersion || transport.version == schemaVersion else {
            throw SnorkelingSessionSyncError.unsupportedVersion
        }
        guard transport.bundleID == expectedCompanionBundleID else {
            throw SnorkelingSessionSyncError.invalidSender
        }
        guard abs(transport.issuedAt.timeIntervalSinceNow) <= maxIssuedAtSkew else {
            throw SnorkelingSessionSyncError.stalePayload
        }
        guard verify(transport) else {
            throw SnorkelingSessionSyncError.invalidSignature
        }
        if transport.version == schemaVersion {
            guard let nonce = transport.nonce, !nonce.isEmpty else {
                throw SnorkelingSessionSyncError.invalidSignature
            }
            if replayCache.isReplay(nonce) {
                throw SnorkelingSessionSyncError.replayedPayload
            }
            guard replayCache.register(nonce) else {
                throw SnorkelingSessionSyncError.replayedPayload
            }
            persistReplayCache()
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let session = try decoder.decode(SnorkelingSession.self, from: transport.body)
        try validate(session)
        return ParsedPayload(session: session, issuedAt: transport.issuedAt)
    }

    static func ackSignature(sessionID: UUID, issuedAt: Date) -> String {
        guard WatchSyncAuth.hasPeerSecret(),
              let key = try? syncKey() else { return "" }
        let canonical = "snorkelingAck|\(sessionID.uuidString)|\(issuedAt.timeIntervalSince1970)"
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

    private static func validate(_ session: SnorkelingSession) throws {
        guard SnorkelingDomainValidator.validate(session: session).isEmpty else {
            throw SnorkelingSessionSyncError.invalidSession
        }
        switch SnorkelingLogbookPolicy.classify(session) {
        case .exportable:
            return
        case .invalid:
            throw SnorkelingSessionSyncError.invalidSession
        }
    }
}

private extension Data {
    func constantTimeEquals(_ other: Data) -> Bool {
        guard count == other.count else { return false }
        return zip(self, other).reduce(UInt8(0)) { $0 | ($1.0 ^ $1.1) } == 0
    }
}

enum SnorkelingSessionSyncError: LocalizedError, Equatable {
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
        case .payloadTooLarge: return "Snorkeling payload too large."
        case .missingPeerSecret: return "Companion sync key unavailable."
        case .missingPayload: return "Missing Snorkeling payload."
        case .unsupportedVersion: return "Unsupported Snorkeling sync version."
        case .invalidSender: return "Invalid Snorkeling sync sender."
        case .stalePayload: return "Stale Snorkeling payload."
        case .invalidSignature: return "Invalid Snorkeling signature."
        case .invalidSession: return "Invalid Snorkeling session."
        case .sessionInactive: return "WatchConnectivity inactive."
        case .replayedPayload: return "Replayed Snorkeling payload."
        }
    }
}
