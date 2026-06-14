import XCTest

@MainActor
final class WatchBriefingCardRemediationTests: XCTestCase {
    func testIncompletePackageDetectedWhenPNGMissing() throws {
        let directory = PlannerBriefingCardStore.storageDirectory()
        try? FileManager.default.removeItem(at: directory)
        defer { try? FileManager.default.removeItem(at: directory) }

        let cardId = UUID()
        let packageId = UUID()
        let card = PlannerBriefingCardMetadata(
            id: cardId,
            title: "Runtime",
            kind: .runtime,
            order: 1,
            fileName: "missing.png",
            pixelWidth: PlannerBriefingTransferSupport.cardPixelWidth,
            pixelHeight: PlannerBriefingTransferSupport.cardPixelHeight,
            contentHashSHA256: "abc"
        )
        let manifest = PlannerBriefingCardManifest(
            id: packageId,
            plannerSessionId: UUID(),
            generatedAt: Date(),
            modeLabel: "CCR",
            title: "Planner Briefing",
            subtitle: "REF ONLY",
            referenceOnly: true,
            cards: [card]
        )
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let data = try PlannerBriefingTransferSupport.encodeManifest(manifest)
        try data.write(to: directory.appendingPathComponent(PlannerBriefingTransferSupport.manifestFileName))

        let store = PlannerBriefingCardStore()
        XCTAssertTrue(store.isPackageIncomplete)
        XCTAssertEqual(store.missingCardCount, 1)
    }

    func testCleanupRemovesOldStagingDirectories() throws {
        let packageId = UUID()
        let staging = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(PlannerBriefingCardStore.stagingDirectoryPrefix)\(packageId.uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: staging, withIntermediateDirectories: true)
        let marker = staging.appendingPathComponent("marker.txt")
        try Data("x".utf8).write(to: marker)
        let oldDate = Date(timeIntervalSinceNow: -100_000)
        try FileManager.default.setAttributes([.modificationDate: oldDate], ofItemAtPath: staging.path)

        PlannerBriefingCardStore.cleanupOrphanStagingDirectories(now: Date())

        XCTAssertFalse(FileManager.default.fileExists(atPath: staging.path))
    }
}
