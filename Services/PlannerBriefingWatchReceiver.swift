import Foundation

enum PlannerBriefingWatchReceiver {
    static func isPlannerBriefingTransfer(_ metadata: [String: Any]) -> Bool {
        let type = metadata[PlannerBriefingTransferSupport.transferTypeKey] as? String
        return type == PlannerBriefingTransferSupport.transferTypeCard
            || type == PlannerBriefingTransferSupport.transferTypeManifest
    }

    @MainActor
    static func importFile(
        from sourceURL: URL,
        metadata: [String: Any],
        store: PlannerBriefingCardStore
    ) -> [String: Any]? {
        if PlannerBriefingTransferSupport.isManifestTransfer(metadata) {
            guard let packageId = PlannerBriefingTransferSupport.packageId(from: metadata),
                  let data = try? Data(contentsOf: sourceURL),
                  let manifest = try? PlannerBriefingTransferSupport.decodeManifest(data),
                  manifest.id == packageId else {
                return ackPayload(packageId: PlannerBriefingTransferSupport.packageId(from: metadata), status: .rejected, errorCode: "invalidManifest")
            }
            do {
                try store.importManifest(manifest, from: sourceURL)
                return ackPayload(packageId: packageId, status: .imported, errorCode: nil)
            } catch {
                return ackPayload(packageId: packageId, status: .rejected, errorCode: "importFailed")
            }
        }

        guard let parsed = PlannerBriefingTransferSupport.parseCardMetadata(metadata) else {
            return nil
        }
        do {
            try store.importStagedCard(
                packageId: parsed.packageId,
                cardId: parsed.cardId,
                order: parsed.order,
                expectedHash: parsed.hash,
                fileName: parsed.fileName,
                sourceURL: sourceURL
            )
            return nil
        } catch {
            return ackPayload(packageId: parsed.packageId, status: .rejected, errorCode: "invalidCard")
        }
    }

    private enum AckStatus { case imported, rejected }

    private static func ackPayload(packageId: UUID?, status: AckStatus, errorCode: String?) -> [String: Any]? {
        guard let packageId else { return nil }
        var payload: [String: Any] = [
            "type": PlannerBriefingTransferSupport.ackType,
            PlannerBriefingTransferSupport.packageIdKey: packageId.uuidString,
            PlannerBriefingTransferSupport.ackStatusKey: status == .imported
                ? PlannerBriefingTransferSupport.ackStatusImported
                : PlannerBriefingTransferSupport.ackStatusRejected,
        ]
        if let errorCode {
            payload[PlannerBriefingTransferSupport.ackErrorCodeKey] = errorCode
        }
        return payload
    }
}
