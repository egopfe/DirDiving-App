import Foundation
import CryptoKit
import WatchConnectivity

enum WatchDiveSyncCodec {
    static let payloadKey = "dirdiving_dive_session"
    static let legacySchemaVersion = 1
    static let schemaVersion = 2
    static let maxPayloadBytes = IOSAlgorithmConfiguration.maxSyncPayloadBytes
    static let maxSamples = IOSAlgorithmConfiguration.maxProfileSampleCount
    static let maxDepthMeters = IOSAlgorithmConfiguration.maxSyncDepthMeters
    // F6: tightened from 86_400 (24 h) to 3_600 (1 h) to shrink the replay window.
    static let maxIssuedAtSkew: TimeInterval = IOSAlgorithmConfiguration.syncIssuedAtSkewSeconds
    static let importedSessionIDsKey = "dirdiving_ios_imported_session_ids"
    static var replayCache = SyncNonceReplayCache()
    private static let replayCacheFileName = "dirdiving_ios_sync_replay_cache.json"

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
        let validatedSession = try validateForSync(session)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let body = try encoder.encode(validatedSession)
        guard body.count <= maxPayloadBytes else {
            throw WatchDiveSyncError.payloadTooLarge
        }

        let issuedAt = Date()
        let bundleID = Bundle.main.bundleIdentifier ?? "com.egopfe.dirdiving.ios"
        let nonce = UUID().uuidString
        let transport = Transport(
            version: schemaVersion,
            bundleID: bundleID,
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
            sessionID: validatedSession.id,
            issuedAt: issuedAt
        )
    }

    static func parseSession(from payload: [String: Any]) throws -> DiveSession {
        try parsePayload(from: payload).session
    }

    // F11: full parse exposed so the receiver can sign the ack with the same
    // (sessionID, issuedAt) that the sender used to derive its expected MAC.
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
        guard transport.bundleID == expectedWatchBundleID else {
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
        let validatedSession = try validateForSync(session)
        return ParsedPayload(session: validatedSession, issuedAt: transport.issuedAt)
    }

    // SYNC-001/SYNC-003: ack signature recomputed from the signed payload
    // context. Senders validate this in constant time before declaring the dive
    // acknowledged; unsigned `acknowledged` strings are not accepted.
    static func ackSignature(sessionID: UUID, issuedAt: Date) -> String {
        guard WatchSyncAuth.hasPeerSecret(),
              let key = try? WatchSyncAuth.deriveSyncKey(peerBundleID: expectedWatchBundleID) else { return "" }
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

    static func sessionID(fromOutboundPayload payload: [String: Any]) -> UUID? {
        guard let data = payload[payloadKey] as? Data,
              data.count <= maxPayloadBytes,
              let transport = try? JSONDecoder().decode(Transport.self, from: data),
              transport.version == legacySchemaVersion || transport.version == schemaVersion,
              transport.body.count <= maxPayloadBytes else {
            return nil
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode(DiveSession.self, from: transport.body))?.id
    }

    static func loadImportedSessionIDs() -> Set<UUID> {
        guard let strings = UserDefaults.standard.stringArray(forKey: importedSessionIDsKey) else {
            return []
        }
        return Set(strings.compactMap(UUID.init(uuidString:)))
    }

    static func saveImportedSessionIDs(_ ids: Set<UUID>) {
        var order = loadImportedSessionIDOrder().filter { ids.contains($0) }
        for id in ids where !order.contains(id) {
            order.append(id)
        }
        if order.count > WatchSyncBoundedIDStore.maxImportedSessionIDs {
            order.removeFirst(order.count - WatchSyncBoundedIDStore.maxImportedSessionIDs)
        }
        UserDefaults.standard.set(order.map(\.uuidString), forKey: importedSessionIDsKey)
    }

    private static func loadImportedSessionIDOrder() -> [UUID] {
        guard let strings = UserDefaults.standard.stringArray(forKey: importedSessionIDsKey) else {
            return []
        }
        return strings.compactMap(UUID.init(uuidString:))
    }

    private static func syncKey() throws -> SymmetricKey {
        try WatchSyncAuth.deriveSyncKey(peerBundleID: expectedWatchBundleID)
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

    static func validateForSync(_ session: DiveSession) throws -> DiveSession {
        guard session.samples.count <= maxSamples else { throw WatchDiveSyncError.invalidSession }
        do {
            return try DiveSessionAlgorithmValidator.normalizedForStorage(
                session,
                allowEmptySamples: session.isManual && !session.hasDepthProfile,
                maxDepthMeters: maxDepthMeters
            )
        } catch {
            throw WatchDiveSyncError.invalidSession
        }
    }
}

enum WatchDiveSyncError: LocalizedError {
    case missingPayload
    case payloadTooLarge
    case unsupportedVersion
    case invalidSender
    case stalePayload
    case invalidSignature
    case invalidSession
    case sessionInactive
    case missingPeerSecret
    case replayedPayload

    var errorDescription: String? {
        switch self {
        case .missingPayload:
            return DIRIOSLocalizer.string("sync.codec.error.missing_payload")
        case .payloadTooLarge:
            return DIRIOSLocalizer.string("sync.codec.error.payload_too_large")
        case .unsupportedVersion:
            return DIRIOSLocalizer.string("sync.codec.error.unsupported_version")
        case .invalidSender:
            return DIRIOSLocalizer.string("sync.codec.error.invalid_sender")
        case .stalePayload:
            return DIRIOSLocalizer.string("sync.codec.error.stale_payload")
        case .invalidSignature:
            return DIRIOSLocalizer.string("sync.codec.error.invalid_signature")
        case .invalidSession:
            return DIRIOSLocalizer.string("sync.codec.error.invalid_session")
        case .sessionInactive:
            return DIRIOSLocalizer.string("sync.codec.error.session_inactive")
        case .missingPeerSecret:
            return DIRIOSLocalizer.string("sync.codec.error.missing_peer_secret")
        case .replayedPayload:
            return DIRIOSLocalizer.string("sync.codec.error.replayed_payload")
        }
    }
}

private extension Data {
    func constantTimeEquals(_ other: Data) -> Bool {
        guard count == other.count else { return false }
        return zip(self, other).reduce(UInt8(0)) { $0 | ($1.0 ^ $1.1) } == 0
    }
}
