import XCTest

/// End-to-end software matrix for supported Planner briefing card kinds on Watch.
@MainActor
final class PlannerBriefingCardKindMatrixTests: XCTestCase {
    func testSupportedCardKindMatrix() async throws {
        let kinds: [PlannerBriefingCardKind] = [.decoStops, .runtime, .ccrSummary]
        for kind in kinds {
            try await exerciseCardKind(kind)
        }
    }

    private func exerciseCardKind(_ kind: PlannerBriefingCardKind) async throws {
        try? FileManager.default.removeItem(at: PlannerBriefingCardStore.storageDirectory())
        defer { try? FileManager.default.removeItem(at: PlannerBriefingCardStore.storageDirectory()) }

        let store = PlannerBriefingCardStore()
        let packageId = UUID()
        let cardId = UUID()
        let fileName = "\(kind.rawValue).png"
        let png = XCTestPNGFixtures.minimalPNG
        let hash = PlannerBriefingTransferSupport.sha256Hex(data: png)
        let cardURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        try png.write(to: cardURL)

        try store.importStagedCard(
            packageId: packageId,
            cardId: cardId,
            order: 1,
            expectedHash: hash,
            fileName: fileName,
            sourceURL: cardURL
        )

        let manifest = PlannerBriefingCardManifest(
            id: packageId,
            plannerSessionId: UUID(),
            generatedAt: Date(),
            modeLabel: kind == .ccrSummary ? "CCR" : "Deco",
            title: "Planner Briefing",
            subtitle: PlannerBriefingTransferSupport.referenceOnlyFooter,
            referenceOnly: true,
            cards: [
                PlannerBriefingCardMetadata(
                    id: cardId,
                    title: kind.rawValue,
                    kind: kind,
                    order: 1,
                    fileName: fileName,
                    pixelWidth: PlannerBriefingTransferSupport.cardPixelWidth,
                    pixelHeight: PlannerBriefingTransferSupport.cardPixelHeight,
                    contentHashSHA256: hash
                ),
            ]
        )
        let manifestURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(kind.rawValue)-manifest.json")
        try PlannerBriefingTransferSupport.encodeManifest(manifest).write(to: manifestURL)

        let transferMetadata = PlannerBriefingTransferSupport.makeManifestTransferMetadata(packageId: packageId)
        XCTAssertEqual(transferMetadata[PlannerBriefingTransferSupport.transferTypeKey] as? String, PlannerBriefingTransferSupport.transferTypeManifest)

        let ack = PlannerBriefingWatchReceiver.importFile(
            from: manifestURL,
            metadata: transferMetadata,
            store: store
        )
        XCTAssertEqual(ack?[PlannerBriefingTransferSupport.ackStatusKey] as? String, PlannerBriefingTransferSupport.ackStatusImported)
        XCTAssertEqual(store.manifest?.cards.first?.kind, kind)
        XCTAssertTrue(store.manifest?.referenceOnly == true)
        XCTAssertFalse(store.isPackageIncomplete)

        try store.deleteBriefing()
        XCTAssertNil(store.manifest)
    }
}
