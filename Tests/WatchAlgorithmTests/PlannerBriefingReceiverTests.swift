import XCTest

@MainActor
final class PlannerBriefingReceiverTests: XCTestCase {
    func testWatchRejectsInvalidMetadata() async throws {
        let store = PlannerBriefingCardStore()
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("invalid.png")
        try makePNG().write(to: url)
        let ack = PlannerBriefingWatchReceiver.importFile(
            from: url,
            metadata: ["transferType": "plannerBriefingCard"],
            store: store
        )
        XCTAssertNil(ack)
    }

    func testManifestImportAckOnSuccess() async throws {
        try? FileManager.default.removeItem(at: PlannerBriefingCardStore.storageDirectory())
        let store = PlannerBriefingCardStore()
        let packageId = UUID()
        let cardId = UUID()
        let fileName = "runtime.png"
        let png = makePNG()
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
            plannerSessionId: nil,
            generatedAt: Date(),
            modeLabel: "Deco",
            title: "Planner Briefing",
            subtitle: "REF ONLY",
            referenceOnly: true,
            cards: [
                PlannerBriefingCardMetadata(
                    id: cardId,
                    title: "Runtime",
                    kind: .runtime,
                    order: 1,
                    fileName: fileName,
                    pixelWidth: PlannerBriefingTransferSupport.cardPixelWidth,
                    pixelHeight: PlannerBriefingTransferSupport.cardPixelHeight,
                    contentHashSHA256: hash
                ),
            ]
        )
        let manifestURL = FileManager.default.temporaryDirectory.appendingPathComponent("manifest.json")
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        try encoder.encode(manifest).write(to: manifestURL)

        let ack = PlannerBriefingWatchReceiver.importFile(
            from: manifestURL,
            metadata: PlannerBriefingTransferSupport.makeManifestTransferMetadata(packageId: packageId),
            store: store
        )
        XCTAssertEqual(ack?["type"] as? String, PlannerBriefingTransferSupport.ackType)
        XCTAssertEqual(ack?[PlannerBriefingTransferSupport.ackStatusKey] as? String, PlannerBriefingTransferSupport.ackStatusImported)
        XCTAssertEqual(store.manifest?.modeLabel, "Deco")
        try? FileManager.default.removeItem(at: PlannerBriefingCardStore.storageDirectory())
    }

    private func makePNG() -> Data {
        XCTestPNGFixtures.minimalPNG
    }
}

enum XCTestPNGFixtures {
    static let minimalPNG = Data(base64Encoded: "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==")!
}
