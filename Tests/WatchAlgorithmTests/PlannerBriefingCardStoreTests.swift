import XCTest

@MainActor
final class PlannerBriefingCardStoreTests: XCTestCase {
    private var store: PlannerBriefingCardStore!

    override func setUp() async throws {
        try await super.setUp()
        try? FileManager.default.removeItem(at: PlannerBriefingCardStore.storageDirectory())
        store = PlannerBriefingCardStore()
    }

    override func tearDown() async throws {
        try? FileManager.default.removeItem(at: PlannerBriefingCardStore.storageDirectory())
        store = nil
        try await super.tearDown()
    }

    func testWatchStoreKeepsLatestPackage() throws {
        let firstPackage = try makePackage(label: "First")
        try importPackage(firstPackage)
        XCTAssertEqual(store.manifest?.modeLabel, "First")

        let secondPackage = try makePackage(label: "Second")
        try importPackage(secondPackage)
        XCTAssertEqual(store.manifest?.modeLabel, "Second")
        XCTAssertEqual(store.sortedCards.count, 1)

        let directory = PlannerBriefingCardStore.storageDirectory()
        let remaining = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
        XCTAssertEqual(remaining.count, 2)
    }

    func testWatchRejectsOversizedCard() throws {
        let packageId = UUID()
        let oversizedURL = FileManager.default.temporaryDirectory.appendingPathComponent("oversized.png")
        let hugeData = Data(repeating: 0xFF, count: PlannerBriefingTransferSupport.maxImageBytes + 1)
        try hugeData.write(to: oversizedURL)
        XCTAssertThrowsError(
            try store.importStagedCard(
                packageId: packageId,
                cardId: UUID(),
                order: 1,
                expectedHash: PlannerBriefingTransferSupport.sha256Hex(data: hugeData),
                fileName: "oversized.png",
                sourceURL: oversizedURL
            )
        )
    }

    private func importPackage(_ package: (manifest: PlannerBriefingCardManifest, cardURL: URL, manifestURL: URL)) throws {
        try store.importStagedCard(
            packageId: package.manifest.id,
            cardId: package.manifest.cards[0].id,
            order: 1,
            expectedHash: package.manifest.cards[0].contentHashSHA256,
            fileName: package.manifest.cards[0].fileName,
            sourceURL: package.cardURL
        )
        try store.importManifest(package.manifest, from: package.manifestURL)
    }

    private func makePackage(label: String) throws -> (manifest: PlannerBriefingCardManifest, cardURL: URL, manifestURL: URL) {
        let packageId = UUID()
        let cardId = UUID()
        let cardURL = FileManager.default.temporaryDirectory.appendingPathComponent("card_\(packageId.uuidString).png")
        let png = makePNG()
        try png.write(to: cardURL)
        let hash = PlannerBriefingTransferSupport.sha256Hex(data: png)
        let card = PlannerBriefingCardMetadata(
            id: cardId,
            title: "Runtime",
            kind: .runtime,
            order: 1,
            fileName: cardURL.lastPathComponent,
            pixelWidth: PlannerBriefingTransferSupport.cardPixelWidth,
            pixelHeight: PlannerBriefingTransferSupport.cardPixelHeight,
            contentHashSHA256: hash
        )
        let manifest = PlannerBriefingCardManifest(
            id: packageId,
            plannerSessionId: nil,
            generatedAt: Date(),
            modeLabel: label,
            title: "Planner Briefing",
            subtitle: "REF ONLY",
            referenceOnly: true,
            cards: [card]
        )
        let manifestURL = FileManager.default.temporaryDirectory.appendingPathComponent("manifest_\(packageId.uuidString).json")
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        try encoder.encode(manifest).write(to: manifestURL)
        return (manifest, cardURL, manifestURL)
    }

    private func makePNG() -> Data {
        XCTestPNGFixtures.minimalPNG
    }
}

extension PlannerBriefingCardStore {
    var sortedCards: [PlannerBriefingCardMetadata] {
        (manifest?.cards ?? []).sorted { $0.order < $1.order }
    }
}
