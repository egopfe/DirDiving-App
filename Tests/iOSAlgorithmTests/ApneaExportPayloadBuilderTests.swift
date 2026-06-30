import XCTest

final class ApneaExportPayloadBuilderTests: XCTestCase {
    func testDemoBadgeInExport() {
        let dive = ApneaDive(startedAtMonotonicSeconds: 0, durationSeconds: 90, maxDepthMeters: 0, averageDepthMeters: 0)
        let session = ApneaSession(id: DemoApneaSessionCatalog.sessionIDs[0], startMode: .manual, state: .completed, dives: [dive])
        let text = ApneaExportPayloadBuilder.buildText(
            .init(session: session, profileKind: .staticApnea, qualityReport: .init(overall: .good, sensors: .unavailable, sessionCompleteness: .good, validHoldCount: 1, recoveryTrackingComplete: true, depthAvailable: false, heartRateAvailable: false, sensorGapCount: 0), notes: nil, isDemo: true),
            profileLabel: "Static",
            qualityLabel: "Good"
        )
        XCTAssertTrue(text.contains("DEMO"))
    }
}
