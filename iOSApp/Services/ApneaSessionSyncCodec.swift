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
    static let maxPayloadBytes = IOSAlgorithmConfiguration.maxSyncPayloadBytes
    static let maxIssuedAtSkew: TimeInterval = IOSAlgorithmConfiguration.syncIssuedAtSkewSeconds
    static let importedSessionIDsKey = "dirdiving_ios_imported_apnea_session_ids"
    static var replayCache = SyncNonceReplayCache()
    private static let replayCacheFileName = "dirdiving_ios_apnea_sync_replay_cache.json"

    private static let expectedWatchBundleID = "com.egopfe.dirdiving.ios.watch"

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

    struct ParsedPayload {
        let session: ApneaSession
        let issuedAt: Date
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
        guard transport.bundleID == expectedWatchBundleID else {
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

    static func loadImportedSessionIDs() -> Set<UUID> {
        guard let strings = UserDefaults.standard.stringArray(forKey: importedSessionIDsKey) else {
            return []
        }
        return Set(strings.compactMap(UUID.init(uuidString:)))
    }

    static func saveImportedSessionIDs(_ ids: Set<UUID>) {
        let sorted = ids.map(\.uuidString).sorted()
        let trimmed = Array(sorted.suffix(512))
        UserDefaults.standard.set(trimmed, forKey: importedSessionIDsKey)
    }

    private static func syncKey() throws -> SymmetricKey {
        try WatchSyncAuth.deriveSyncKey(peerBundleID: expectedWatchBundleID)
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

enum ApneaSessionSyncImportResult: Equatable {
    case imported
    case merged
    case duplicateIgnored
    case failed(String)
}

enum ApneaSessionSyncImportPolicy {
    static func importSession(
        _ incoming: ApneaSession,
        existingSessions: [ApneaSession],
        importedIDs: Set<UUID>
    ) -> (result: ApneaSessionSyncImportResult, session: ApneaSession?, updatedImportedIDs: Set<UUID>) {
        let normalized = ApneaLogbookPolicy.normalizedSession(incoming)
        switch ApneaLogbookPolicy.classify(normalized) {
        case .invalid(let reason):
            return (.failed(reason), nil, importedIDs)
        case .exportable:
            break
        }

        var ids = importedIDs
        if let existing = existingSessions.first(where: { $0.id == normalized.id }) {
            let merged = ApneaSessionMerge.preferred(existing, normalized)
            ids = WatchSyncBoundedIDStore.merge(normalized.id, into: ids, maxCount: 512)
            return (.merged, merged, ids)
        }
        if ids.contains(normalized.id) {
            return (.duplicateIgnored, nil, ids)
        }
        ids = WatchSyncBoundedIDStore.merge(normalized.id, into: ids, maxCount: 512)
        return (.imported, normalized, ids)
    }
}
