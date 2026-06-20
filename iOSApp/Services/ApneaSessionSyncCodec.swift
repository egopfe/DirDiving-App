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
    static let schemaVersion = ActivitySyncSignedTransport.envelopeSchemaVersion
    static let maxPayloadBytes = IOSAlgorithmConfiguration.maxSyncPayloadBytes
    static let maxIssuedAtSkew: TimeInterval = IOSAlgorithmConfiguration.syncIssuedAtSkewSeconds
    static let importedSessionIDsKey = "dirdiving_ios_imported_apnea_session_ids"
    static var replayCache = SyncNonceReplayCache()
    private static let replayCacheFileName = "dirdiving_ios_apnea_sync_replay_cache.json"

#if DEBUG
    /// Bypasses WatchConnectivity activation checks in unit tests.
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

    typealias Transport = ActivitySyncSignedTransport

    struct ParsedPayload {
        let session: ApneaSession
        let issuedAt: Date
    }

    static func parsePayload(from payload: [String: Any]) throws -> ParsedPayload {
#if DEBUG
        if !testHook_bypassConnectivityChecks {
            guard WCSession.default.activationState == .activated else {
                throw ApneaSessionSyncError.sessionInactive
            }
        }
#else
        guard WCSession.default.activationState == .activated else {
            throw ApneaSessionSyncError.sessionInactive
        }
#endif
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
        guard ActivitySyncCodecSupport.validateVersion(transport.version) else {
            throw ApneaSessionSyncError.unsupportedVersion
        }
        guard transport.bundleID == expectedWatchBundleID else {
            throw ApneaSessionSyncError.invalidSender
        }
        guard abs(transport.issuedAt.timeIntervalSinceNow) <= maxIssuedAtSkew else {
            throw ApneaSessionSyncError.stalePayload
        }
        do {
            try ActivitySyncCodecSupport.validateTransport(
                transport,
                payloadKey: payloadKey,
                expectedActivity: .apnea
            )
        } catch {
            throw ApneaSessionSyncError.invalidSignature
        }
        guard let key = try? syncKey(), transport.verify(with: key) else {
            throw ApneaSessionSyncError.invalidSignature
        }
        if transport.version >= ActivitySyncSignedTransport.nonceRequiredFromVersion {
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

#if DEBUG
    /// Builds a signed transport envelope as if sent from the Watch companion (unit tests only).
    static func makeTestWatchTransport(
        session: ApneaSession,
        version: Int = schemaVersion,
        nonce: String = UUID().uuidString,
        issuedAt: Date = Date(),
        bundleID: String = "com.egopfe.dirdiving.ios.watch"
    ) throws -> [String: Any] {
        guard WatchSyncAuth.hasPeerSecret() else {
            throw ApneaSessionSyncError.missingPeerSecret
        }
        let normalized = ApneaLogbookPolicy.normalizedSession(session)
        try validate(normalized)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let body = try encoder.encode(normalized)
        guard body.count <= maxPayloadBytes else {
            throw ApneaSessionSyncError.payloadTooLarge
        }
        let key = try syncKey()
        let signed: ActivitySyncSignedTransport
        if version == ActivitySyncSignedTransport.envelopeSchemaVersion {
            let revision = ActivitySyncCodecSupport.revision(for: normalized.createdAt)
            signed = ActivitySyncSignedTransport.makeSigned(
                body: body,
                bundleID: bundleID,
                activity: .apnea,
                messageType: .sessionUpsert,
                revision: revision,
                syncKey: key,
                issuedAt: issuedAt,
                nonce: nonce
            )
        } else {
            var unsigned = ActivitySyncSignedTransport(
                version: version,
                bundleID: bundleID,
                issuedAt: issuedAt,
                nonce: version >= ActivitySyncSignedTransport.nonceRequiredFromVersion ? nonce : nil,
                messageID: nil,
                activityType: nil,
                messageType: nil,
                payloadHash: nil,
                revision: nil,
                body: body,
                signature: ""
            )
            let signature = ActivitySyncHMAC.signCanonical(transport: unsigned, body: body, key: key)
            signed = ActivitySyncSignedTransport(
                version: unsigned.version,
                bundleID: unsigned.bundleID,
                issuedAt: unsigned.issuedAt,
                nonce: unsigned.nonce,
                messageID: nil,
                activityType: nil,
                messageType: nil,
                payloadHash: nil,
                revision: nil,
                body: body,
                signature: signature
            )
        }
        let transportData = try JSONEncoder().encode(signed)
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
