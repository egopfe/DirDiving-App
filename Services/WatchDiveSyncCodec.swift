import Foundation
import CryptoKit
import WatchConnectivity

enum WatchDiveSyncCodec {
    static let payloadKey = "dirdiving_dive_session"
    static let legacySchemaVersion = 1
    static let schemaVersion = 2
    static let maxPayloadBytes = 512_000
    static let maxSamples = 20_000
    static let maxDepthMeters = 350.0
    /// Retains the most recent companion-import session IDs to suppress re-transfer echo.
    static let importedCompanionIDRetentionLimit = 512
    static let maxIssuedAtSkew: TimeInterval = 3_600
    static let importedFromCompanionIDsKey = "dirdiving_watch_imported_from_companion_ids"
    static var replayCache = SyncNonceReplayCache()
    private static let replayCacheFileName = "dirdiving_watch_sync_replay_cache.json"

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
        let session: DiveSession
        let issuedAt: Date
    }

    static func makePayload(session: DiveSession) throws -> PayloadEnvelope {
        guard WatchSyncAuth.hasPeerSecret() else {
            throw WatchDiveSyncError.missingPeerSecret
        }
        let transportSession = DiveSessionMerge.preferred(session, session)
        try validate(transportSession)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let body = try encoder.encode(transportSession)
        guard body.count <= maxPayloadBytes else {
            throw WatchDiveSyncError.payloadTooLarge
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
            throw WatchDiveSyncError.payloadTooLarge
        }
        return PayloadEnvelope(
            message: [payloadKey: transportData],
            sessionID: transportSession.id,
            issuedAt: issuedAt
        )
    }

    static func parseSession(from payload: [String: Any]) throws -> DiveSession {
        try parsePayload(from: payload).session
    }

    static func parsePayload(from payload: [String: Any]) throws -> ParsedPayload {
        guard WCSession.default.activationState == .activated else {
            throw WatchDiveSyncError.sessionInactive
        }
        guard WatchSyncAuth.hasPeerSecret() else {
            throw WatchDiveSyncError.missingPeerSecret
        }
        guard let data = payload[payloadKey] as? Data else {
            throw WatchDiveSyncError.missingPayload
        }
        guard data.count <= maxPayloadBytes else {
            throw WatchDiveSyncError.payloadTooLarge
        }

        let transport = try JSONDecoder().decode(Transport.self, from: data)
        guard transport.version == legacySchemaVersion || transport.version == schemaVersion else {
            throw WatchDiveSyncError.unsupportedVersion
        }
        guard transport.bundleID == expectedCompanionBundleID else {
            throw WatchDiveSyncError.invalidSender
        }
        guard abs(transport.issuedAt.timeIntervalSinceNow) <= maxIssuedAtSkew else {
            throw WatchDiveSyncError.stalePayload
        }
        guard transport.body.count <= maxPayloadBytes else {
            throw WatchDiveSyncError.payloadTooLarge
        }
        guard verify(transport) else {
            throw WatchDiveSyncError.invalidSignature
        }
        if transport.version == schemaVersion {
            guard let nonce = transport.nonce, !nonce.isEmpty else {
                throw WatchDiveSyncError.invalidSignature
            }
            if replayCache.isReplay(nonce) {
                throw WatchDiveSyncError.replayedPayload
            }
            guard replayCache.register(nonce) else {
                throw WatchDiveSyncError.replayedPayload
            }
            persistReplayCache()
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let session = try decoder.decode(DiveSession.self, from: transport.body)
        try validate(session)
        return ParsedPayload(session: session, issuedAt: transport.issuedAt)
    }

    static func ackSignature(sessionID: UUID, issuedAt: Date) -> String {
        guard WatchSyncAuth.hasPeerSecret(),
              let key = try? syncKey() else { return "" }
        let canonical = "ack|\(sessionID.uuidString)|\(issuedAt.timeIntervalSince1970)"
        let code = HMAC<SHA256>.authenticationCode(for: Data(canonical.utf8), using: key)
        return Data(code).base64EncodedString()
    }

    static func verifyAckSignature(_ signature: String?, sessionID: UUID, issuedAt: Date) -> Bool {
        guard let signature,
              !signature.isEmpty,
              signature != "acknowledged",
              let providedData = Data(base64Encoded: signature) else { return false }
        let expected = ackSignature(sessionID: sessionID, issuedAt: issuedAt)
        guard !expected.isEmpty, let expectedData = Data(base64Encoded: expected) else { return false }
        return providedData.constantTimeEquals(expectedData)
    }

    static func isImportAck(_ payload: [String: Any]) -> Bool {
        payload["type"] as? String == WatchSyncKeys.diveImportAckType
    }

    static func parseImportAck(from payload: [String: Any]) -> (sessionID: UUID, issuedAt: Date, signature: String)? {
        guard isImportAck(payload),
              let sessionIDString = payload[WatchSyncKeys.diveImportAckSessionIDKey] as? String,
              let sessionID = UUID(uuidString: sessionIDString),
              let issuedAtInterval = payload[WatchSyncKeys.diveImportAckIssuedAtKey] as? TimeInterval,
              let signature = payload[WatchSyncKeys.diveImportAckSignatureKey] as? String else {
            return nil
        }
        let issuedAt = Date(timeIntervalSince1970: issuedAtInterval)
        guard abs(issuedAt.timeIntervalSinceNow) <= maxIssuedAtSkew else { return nil }
        return (sessionID, issuedAt, signature)
    }

    static func makeImportAckPayload(sessionID: UUID, issuedAt: Date) -> [String: Any] {
        [
            "type": WatchSyncKeys.diveImportAckType,
            WatchSyncKeys.diveImportAckSessionIDKey: sessionID.uuidString,
            WatchSyncKeys.diveImportAckIssuedAtKey: issuedAt.timeIntervalSince1970,
            WatchSyncKeys.diveImportAckSignatureKey: ackSignature(sessionID: sessionID, issuedAt: issuedAt),
        ]
    }

    static func loadImportedFromCompanionIDs() -> Set<UUID> {
        guard let strings = UserDefaults.standard.stringArray(forKey: importedFromCompanionIDsKey) else {
            return []
        }
        return Set(strings.compactMap(UUID.init(uuidString:)))
    }

    static func saveImportedFromCompanionIDs(_ ids: Set<UUID>) {
        let sorted = ids.map(\.uuidString).sorted()
        let trimmed = Array(sorted.suffix(importedCompanionIDRetentionLimit))
        UserDefaults.standard.set(trimmed, forKey: importedFromCompanionIDsKey)
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

    private static func validate(_ session: DiveSession) throws {
        do {
            try DiveSessionAlgorithmValidator.validate(session)
        } catch {
            throw WatchDiveSyncError.invalidSession
        }
    }
}

private extension Data {
    func constantTimeEquals(_ other: Data) -> Bool {
        guard count == other.count else { return false }
        return zip(self, other).reduce(UInt8(0)) { $0 | ($1.0 ^ $1.1) } == 0
    }
}

enum WatchDiveSyncError: LocalizedError {
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
        case .payloadTooLarge: return "Payload sync troppo grande."
        case .missingPeerSecret: return "Chiave sync companion non ancora disponibile."
        case .missingPayload: return "Payload sync mancante."
        case .unsupportedVersion: return "Versione sync non supportata."
        case .invalidSender: return "Mittente sync non valido."
        case .stalePayload: return "Payload sync scaduto."
        case .invalidSignature: return "Firma sync non valida."
        case .invalidSession: return "Sessione immersione non valida."
        case .sessionInactive: return "WatchConnectivity non attivo."
        case .replayedPayload: return "Payload sync già processato."
        }
    }
}
