import XCTest
@testable import DIRDivingWatchApp

final class GaugeOptionalTTVTests: XCTestCase {
    override func setUp() {
        super.setUp()
        #if DEBUG
        DIRStartupSelectionPolicy.resetForTests()
        #endif
    }

    func testGaugeTTVDefaultOff() {
        XCTAssertFalse(DIRStartupSelectionPolicy.gaugeShowsTTV)
    }

    func testGaugeTTVTogglePersists() {
        DIRStartupSelectionPolicy.gaugeShowsTTV = true
        XCTAssertTrue(DIRStartupSelectionPolicy.gaugeShowsTTV)
        DIRStartupSelectionPolicy.gaugeShowsTTV = false
        XCTAssertFalse(DIRStartupSelectionPolicy.gaugeShowsTTV)
    }

    func testPresentationPolicyHiddenForFullComputer() {
        let policy = GaugeLivePresentationPolicy.evaluate(isGaugeMode: false, showsTTV: true)
        XCTAssertEqual(policy.topPanel, .hidden)
    }

    func testPresentationPolicyTTVWhenEnabledInGauge() {
        let policy = GaugeLivePresentationPolicy.evaluate(isGaugeMode: true, showsTTV: true)
        XCTAssertEqual(policy.topPanel, .ttvAndRuntime)
    }

    func testPresentationPolicyRuntimeTemperatureWhenTTVOffInGauge() {
        let policy = GaugeLivePresentationPolicy.evaluate(isGaugeMode: true, showsTTV: false)
        XCTAssertEqual(policy.topPanel, .runtimeAndTemperature)
    }

    func testSyncedPreferenceAppliesWithoutMigrationSideEffects() {
        DIRStartupSelectionPolicy.applySyncedGaugeShowsTTV(true)
        XCTAssertTrue(DIRStartupSelectionPolicy.gaugeShowsTTV)
    }

    func testTTVIndexFormulaUnchanged() {
        XCTAssertEqual(DiveAlgorithm.ttvIndex(averageDepthMeters: 20, durationSeconds: 1_800), 50, accuracy: 0.001)
    }

    func testRepositoryStringsUseTTVLabelAndCommandFooter() throws {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let en = try String(contentsOf: root.appendingPathComponent("Resources/en.lproj/Localizable.strings"))
        let it = try String(contentsOf: root.appendingPathComponent("Resources/it.lproj/Localizable.strings"))
        XCTAssertTrue(en.contains("\"live.metric.ttv\" = \"TTV\""))
        XCTAssertFalse(en.contains("\"live.metric.ttv\" = \"TTS\""))
        XCTAssertTrue(en.contains("settings.gauge.show_ttv.footer"))
        XCTAssertTrue(it.contains("saturazione dei tessuti"))
    }
}
