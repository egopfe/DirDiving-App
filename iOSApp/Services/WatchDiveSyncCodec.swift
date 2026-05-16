import Foundation
import CryptoKit
import WatchConnectivity

enum WatchDiveSyncCodec {
    static let payloadKey = "dirdiving_dive_session"
    static let schemaVersion = 1
    static let maxPayloadBytes = 512_000
    static let maxSamples = 20_000
    static let maxDepthMeters = 350.0
    static let maxIssuedAtSkew: TimeInterval = 86_400
    static let importedSessionIDsKey = "dirdiving_ios_imported_session_ids"

    private static let expectedWatchBundleID = "com.egopfe.dirdiving"

    struct Transport: Codable {
        let version: Int
        let bundleID: String
        let issuedAt: Date
        let body: Data
        let signature: String
    }

    static func parseSession(from payload: [String: Any]) throws -> DiveSession {
        guard WCSession.default.activationState == .activated else {
            throw WatchDiveSyncError.sessionInactive
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
        try validate(session)
        return session
    }

    static func loadImportedSessionIDs() -> Set<UUID> {
        guard let strings = UserDefaults.standard.stringArray(forKey: importedSessionIDsKey) else {
            return []
        }
        return Set(strings.compactMap(UUID.init(uuidString:)))
    }

    static func saveImportedSessionIDs(_ ids: Set<UUID>) {
        let trimmed = Array(ids.suffix(128))
        UserDefaults.standard.set(trimmed.map(\.uuidString), forKey: importedSessionIDsKey)
    }

    private static func syncKey() -> SymmetricKey {
        let peer = expectedWatchBundleID
        return WatchSyncAuth.syncKey(peerBundleID: peer)
    }

    private static func verify(_ transport: Transport) -> Bool {
        let canonical = "\(transport.version)|\(transport.bundleID)|\(transport.issuedAt.timeIntervalSince1970)|\(transport.body.base64EncodedString())"
        let code = HMAC<SHA256>.authenticationCode(for: Data(canonical.utf8), using: syncKey())
        let expected = Data(code).base64EncodedString()
        guard let received = Data(base64Encoded: transport.signature) else { return false }
        guard let expectedData = Data(base64Encoded: expected) else { return false }
        return received.constantTimeEquals(expectedData)
    }

    private static func validate(_ session: DiveSession) throws {
        guard session.durationSeconds >= 0, session.durationSeconds <= 86_400 else {
            throw WatchDiveSyncError.invalidSession
        }
        guard session.maxDepthMeters >= 0, session.maxDepthMeters <= maxDepthMeters else {
            throw WatchDiveSyncError.invalidSession
        }
        guard session.samples.count <= maxSamples else {
            throw WatchDiveSyncError.invalidSession
        }
        guard session.endDate >= session.startDate else {
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
        }
    }
}

private extension Data {
    func constantTimeEquals(_ other: Data) -> Bool {
        guard count == other.count else { return false }
        return zip(self, other).reduce(UInt8(0)) { $0 | ($1.0 ^ $1.1) } == 0
    }
}
