import Foundation
import CryptoKit
import WatchConnectivity

enum WatchDiveSyncCodec {
    static let payloadKey = "dirdiving_dive_session"
    static let schemaVersion = 1
    static let maxPayloadBytes = IOSAlgorithmConfiguration.maxSyncPayloadBytes
    static let maxSamples = IOSAlgorithmConfiguration.maxProfileSampleCount
    static let maxDepthMeters = IOSAlgorithmConfiguration.maxSyncDepthMeters
    // F6: tightened from 86_400 (24 h) to 3_600 (1 h) to shrink the replay window.
    // WatchConnectivity is pairing-locked at the OS level, but a 1 h skew is more than
    // enough for the usual Watch/iPhone clock drift while removing the day-long replay
    // surface that the legacy value implied.
    static let maxIssuedAtSkew: TimeInterval = IOSAlgorithmConfiguration.syncIssuedAtSkewSeconds
    static let importedSessionIDsKey = "dirdiving_ios_imported_session_ids"

    private static let expectedWatchBundleID = "com.egopfe.dirdiving.ios.watch"

    struct Transport: Codable {
        let version: Int
        let bundleID: String
        let issuedAt: Date
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
        let transport = Transport(
            version: schemaVersion,
            bundleID: bundleID,
            issuedAt: issuedAt,
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
        guard transport.version == schemaVersion else {
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

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let session = try decoder.decode(DiveSession.self, from: transport.body)
        let validatedSession = try validateForSync(session)
        return ParsedPayload(session: validatedSession, issuedAt: transport.issuedAt)
    }

    // F11: ack signature recomputed and returned by iOS in response to a signed
    // Watch payload. The Watch side validates this in constant time before
    // declaring the dive acknowledged. The legacy `acknowledged` string path is
    // kept on the Watch side for backward compatibility with older iOS builds.
    // TODO(F11-followup): once the floor build is bumped, make the signed ack
    // mandatory on both ends and remove the legacy string fallback.
    static func ackSignature(sessionID: UUID, issuedAt: Date) -> String {
        let canonical = "ack|\(sessionID.uuidString)|\(issuedAt.timeIntervalSince1970)"
        let code = HMAC<SHA256>.authenticationCode(for: Data(canonical.utf8), using: syncKey())
        return Data(code).base64EncodedString()
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

    private static func syncKey() -> SymmetricKey {
        WatchSyncAuth.syncKey(peerBundleID: expectedWatchBundleID)
    }

    private static func sign(_ transport: Transport, issuedAt: Date, body: Data) -> Transport {
        let mac = hmac(version: transport.version, bundleID: transport.bundleID, issuedAt: issuedAt, body: body)
        return Transport(
            version: transport.version,
            bundleID: transport.bundleID,
            issuedAt: issuedAt,
            body: body,
            signature: mac
        )
    }

    private static func hmac(version: Int, bundleID: String, issuedAt: Date, body: Data) -> String {
        let canonical = "\(version)|\(bundleID)|\(issuedAt.timeIntervalSince1970)|\(body.base64EncodedString())"
        let code = HMAC<SHA256>.authenticationCode(for: Data(canonical.utf8), using: syncKey())
        return Data(code).base64EncodedString()
    }

    private static func verify(_ transport: Transport) -> Bool {
        let canonical = "\(transport.version)|\(transport.bundleID)|\(transport.issuedAt.timeIntervalSince1970)|\(transport.body.base64EncodedString())"
        let code = HMAC<SHA256>.authenticationCode(for: Data(canonical.utf8), using: syncKey())
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

    var errorDescription: String? {
        switch self {
        case .missingPayload: return "Payload sync mancante."
        case .payloadTooLarge: return "Payload sync troppo grande."
        case .unsupportedVersion: return "Versione sync non supportata."
        case .invalidSender: return "Mittente sync non valido."
        case .stalePayload: return "Payload sync scaduto."
        case .invalidSignature: return "Firma sync non valida."
        case .invalidSession: return "Sessione immersione non valida."
        case .sessionInactive: return "WatchConnectivity non attivo."
        case .missingPeerSecret: return "Chiave sync Watch non ancora disponibile."
        }
    }
}

private extension Data {
    func constantTimeEquals(_ other: Data) -> Bool {
        guard count == other.count else { return false }
        return zip(self, other).reduce(UInt8(0)) { $0 | ($1.0 ^ $1.1) } == 0
    }
}
