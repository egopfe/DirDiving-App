import Foundation
import CryptoKit

enum PlannerBriefingCardKind: String, Codable, Hashable {
    case decoStops
    case runtime
    case gasEmergency
}

struct PlannerBriefingCardMetadata: Codable, Hashable, Identifiable {
    let id: UUID
    let title: String
    let kind: PlannerBriefingCardKind
    let order: Int
    let fileName: String
    let pixelWidth: Int
    let pixelHeight: Int
    let contentHashSHA256: String
}

struct PlannerBriefingCardManifest: Codable, Hashable, Identifiable {
    let id: UUID
    let plannerSessionId: UUID?
    let generatedAt: Date
    let modeLabel: String
    let title: String
    let subtitle: String?
    let referenceOnly: Bool
    let cards: [PlannerBriefingCardMetadata]
}

struct PlannerBriefingExportPackage: Hashable {
    let manifest: PlannerBriefingCardManifest
    let imageFiles: [URL]
}

enum PlannerBriefingTransferSupport {
    static let transferTypeKey = "transferType"
    static let transferTypeManifest = "plannerBriefingManifest"
    static let transferTypeCard = "plannerBriefingCard"
    static let packageIdKey = "packageId"
    static let cardIdKey = "cardId"
    static let cardKindKey = "kind"
    static let cardOrderKey = "order"
    static let fileNameKey = "fileName"
    static let contentHashKey = "contentHashSHA256"
    static let referenceOnlyKey = "referenceOnly"
    static let generatedAtKey = "generatedAt"
    static let ackType = "plannerBriefingAck"
    static let ackStatusKey = "status"
    static let ackStatusImported = "imported"
    static let ackStatusRejected = "rejected"
    static let ackErrorCodeKey = "errorCode"

    static let cardPixelWidth = 410
    static let cardPixelHeight = 502
    static let maxRowsPerCard = 8
    static let maxImageBytes = 1_024 * 1_024
    static let maxPackageBytes = 5 * 1_024 * 1_024
    static let manifestFileName = "planner_briefing_manifest.json"

    static let referenceOnlyFooter = "DIR DIVING — REF ONLY"
    static let notCertifiedFooter = "NOT A CERTIFIED DECO COMPUTER"

    static func sha256Hex(data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }

    static func makeCardMetadata(
        fileURL: URL,
        title: String,
        kind: PlannerBriefingCardKind,
        order: Int
    ) throws -> PlannerBriefingCardMetadata {
        let data = try Data(contentsOf: fileURL)
        guard data.count <= maxImageBytes else {
            throw PlannerBriefingValidationError.oversizedCard
        }
        return PlannerBriefingCardMetadata(
            id: UUID(),
            title: title,
            kind: kind,
            order: order,
            fileName: fileURL.lastPathComponent,
            pixelWidth: cardPixelWidth,
            pixelHeight: cardPixelHeight,
            contentHashSHA256: sha256Hex(data: data)
        )
    }

    static func makeCardTransferMetadata(
        packageId: UUID,
        card: PlannerBriefingCardMetadata
    ) -> [String: Any] {
        [
            transferTypeKey: transferTypeCard,
            packageIdKey: packageId.uuidString,
            cardIdKey: card.id.uuidString,
            cardKindKey: card.kind.rawValue,
            cardOrderKey: card.order,
            fileNameKey: card.fileName,
            contentHashKey: card.contentHashSHA256,
            referenceOnlyKey: true,
        ]
    }

    static func makeManifestTransferMetadata(packageId: UUID) -> [String: Any] {
        [
            transferTypeKey: transferTypeManifest,
            packageIdKey: packageId.uuidString,
            fileNameKey: manifestFileName,
            referenceOnlyKey: true,
        ]
    }

    static func parseCardMetadata(_ metadata: [String: Any]) -> (packageId: UUID, cardId: UUID, order: Int, hash: String, fileName: String)? {
        guard metadata[transferTypeKey] as? String == transferTypeCard,
              let packageRaw = metadata[packageIdKey] as? String,
              let packageId = UUID(uuidString: packageRaw),
              let cardRaw = metadata[cardIdKey] as? String,
              let cardId = UUID(uuidString: cardRaw),
              let order = metadata[cardOrderKey] as? Int,
              let hash = metadata[contentHashKey] as? String,
              let fileName = metadata[fileNameKey] as? String,
              !hash.isEmpty,
              !fileName.isEmpty else {
            return nil
        }
        return (packageId, cardId, order, hash, fileName)
    }

    static func isManifestTransfer(_ metadata: [String: Any]) -> Bool {
        metadata[transferTypeKey] as? String == transferTypeManifest
    }

    static func packageId(from metadata: [String: Any]) -> UUID? {
        guard let raw = metadata[packageIdKey] as? String else { return nil }
        return UUID(uuidString: raw)
    }

    static func decodeManifest(_ data: Data) throws -> PlannerBriefingCardManifest {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(PlannerBriefingCardManifest.self, from: data)
    }

    static func encodeManifest(_ manifest: PlannerBriefingCardManifest) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(manifest)
    }
}

enum PlannerBriefingValidationError: Error, Equatable {
    case invalidMetadata
    case invalidFileType
    case oversizedCard
    case oversizedPackage
    case hashMismatch
    case manifestCardMismatch
}
