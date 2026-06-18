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
    static let maxPayloadBytes = IOSAlgorithmConfiguration.maxSyncPayloadBytes
    static let maxIssuedAtSkew: TimeInterval = IOSAlgorithmConfiguration.syncIssuedAtSkewSeconds
    static let importedSessionIDsKey = "dirdiving_ios_imported_snorkeling_session_ids"
    static var replayCache = SyncNonceReplayCache()
    private static let replayCacheFileName = "dirdiving_ios_snorkeling_sync_replay_cache.json"

#if DEBUG
    static var testHook_bypassConnectivityChecks = false
    static var testHook_replayCacheFileURL: URL?

    static func resetTestHooks() {
        testHook_bypassConnectivityChecks = false
        testHook_replayCacheFileURL = nil
        replayCache.reset()
        UserDefaults.standard.removeObject(forKey: importedSessionIDsKey)
    }
#endif

    private static let expectedWatchBundleID = "com.egopfe.dirdiving.ios.watch"

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

    struct ParsedPayload {
        let session: SnorkelingSession
        let issuedAt: Date
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
        guard transport.bundleID == expectedWatchBundleID else {
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

#if DEBUG
    static func makeTestWatchTransport(
        session: SnorkelingSession,
        version: Int = schemaVersion,
        nonce: String = UUID().uuidString,
        issuedAt: Date = Date(),
        bundleID: String = "com.egopfe.dirdiving.ios.watch"
    ) throws -> [String: Any] {
        guard WatchSyncAuth.hasPeerSecret() else {
            throw SnorkelingSessionSyncError.missingPeerSecret
        }
        let normalized = SnorkelingLogbookPolicy.normalizedSession(session)
        try validate(normalized)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let body = try encoder.encode(normalized)
        guard body.count <= maxPayloadBytes else {
            throw SnorkelingSessionSyncError.payloadTooLarge
        }
        var transport = Transport(
            version: version,
            bundleID: bundleID,
            issuedAt: issuedAt,
            nonce: version >= schemaVersion ? nonce : nil,
            body: body,
            signature: ""
        )
        let nonceComponent = transport.version >= schemaVersion ? (transport.nonce ?? "") : ""
        let canonical = "\(transport.version)|\(transport.bundleID)|\(issuedAt.timeIntervalSince1970)|\(nonceComponent)|\(body.base64EncodedString())"
        let key = try syncKey()
        let code = HMAC<SHA256>.authenticationCode(for: Data(canonical.utf8), using: key)
        transport = Transport(
            version: version,
            bundleID: bundleID,
            issuedAt: issuedAt,
            nonce: transport.nonce,
            body: body,
            signature: Data(code).base64EncodedString()
        )
        let transportData = try JSONEncoder().encode(transport)
        return [payloadKey: transportData]
    }
#endif
}

private extension Data {
    func constantTimeEquals(_ other: Data) -> Bool {
        guard count == other.count else { return false }
        return zip(self, other).reduce(UInt8(0)) { $0 | ($1.0 ^ $1.1) } == 0
    }
}

enum SnorkelingSessionSyncImportResult: Equatable {
    case imported
    case merged
    case duplicateIgnored
    case failed(String)
}

enum SnorkelingSessionSyncImportPolicy {
    static func importSession(
        _ incoming: SnorkelingSession,
        existingSessions: [SnorkelingSession],
        importedIDs: Set<UUID>
    ) -> (result: SnorkelingSessionSyncImportResult, session: SnorkelingSession?, updatedImportedIDs: Set<UUID>) {
        let normalized = SnorkelingLogbookPolicy.normalizedSession(incoming)
        switch SnorkelingLogbookPolicy.classify(normalized) {
        case .invalid(let reason):
            return (.failed(reason), nil, importedIDs)
        case .exportable:
            break
        }

        var ids = importedIDs
        if let existing = existingSessions.first(where: { $0.id == normalized.id }) {
            let merged = SnorkelingSessionMerge.preferred(existing, normalized)
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
