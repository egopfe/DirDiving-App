import XCTest

/// Verifies supported Planner briefing card kinds and legacy kind filtering.
final class PlannerBriefingLegacyKindDecodeTests: XCTestCase {
    func testLegacyGasEmergencyKindFilteredFromManifest() throws {
        let packageId = UUID()
        let supportedId = UUID()
        let json = """
        {
          "id": "\(packageId.uuidString)",
          "plannerSessionId": null,
          "generatedAt": "2026-06-17T12:00:00Z",
          "modeLabel": "Deco",
          "title": "Planner Briefing",
          "subtitle": "REF ONLY",
          "referenceOnly": true,
          "cards": [
            {
              "id": "\(supportedId.uuidString)",
              "title": "Runtime",
              "kind": "runtime",
              "order": 1,
              "fileName": "runtime.png",
              "pixelWidth": \(PlannerBriefingTransferSupport.cardPixelWidth),
              "pixelHeight": \(PlannerBriefingTransferSupport.cardPixelHeight),
              "contentHashSHA256": "abc123"
            },
            {
              "id": "\(UUID().uuidString)",
              "title": "Emergency",
              "kind": "gasEmergency",
              "order": 2,
              "fileName": "emergency.png",
              "pixelWidth": \(PlannerBriefingTransferSupport.cardPixelWidth),
              "pixelHeight": \(PlannerBriefingTransferSupport.cardPixelHeight),
              "contentHashSHA256": "def456"
            }
          ]
        }
        """
        let manifest = try PlannerBriefingTransferSupport.decodeManifest(Data(json.utf8))
        XCTAssertEqual(manifest.id, packageId)
        XCTAssertEqual(manifest.cards.count, 1)
        XCTAssertEqual(manifest.cards.first?.id, supportedId)
        XCTAssertEqual(manifest.cards.first?.kind, .runtime)
    }

    func testUnknownFutureKindFilteredWithoutCrash() throws {
        let packageId = UUID()
        let json = """
        {
          "id": "\(packageId.uuidString)",
          "plannerSessionId": null,
          "generatedAt": "2026-06-17T12:00:00Z",
          "modeLabel": "CCR",
          "title": "Planner Briefing",
          "subtitle": null,
          "referenceOnly": true,
          "cards": [
            {
              "id": "\(UUID().uuidString)",
              "title": "Future",
              "kind": "futureExperimentalCard",
              "order": 1,
              "fileName": "future.png",
              "pixelWidth": 410,
              "pixelHeight": 502,
              "contentHashSHA256": "000"
            }
          ]
        }
        """
        let manifest = try PlannerBriefingTransferSupport.decodeManifest(Data(json.utf8))
        XCTAssertTrue(manifest.cards.isEmpty)
        XCTAssertTrue(manifest.referenceOnly)
    }

    func testSupportedKindsRemainStable() {
        XCTAssertEqual(PlannerBriefingCardKind.decoStops.rawValue, "decoStops")
        XCTAssertEqual(PlannerBriefingCardKind.runtime.rawValue, "runtime")
        XCTAssertEqual(PlannerBriefingCardKind.ccrSummary.rawValue, "ccrSummary")
        XCTAssertNil(PlannerBriefingCardKind(rawValue: "gasEmergency"))
    }
}
