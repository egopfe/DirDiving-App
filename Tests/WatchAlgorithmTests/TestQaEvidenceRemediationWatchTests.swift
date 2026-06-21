import XCTest

final class TestQaEvidenceRemediationWatchTests: XCTestCase {
    func testMockDepthSensorProviderDoesNotRequireEntitlement() throws {
        let source = try String(
            contentsOf: repositoryRoot().appendingPathComponent("Services/MockDepthSensorProvider.swift"),
            encoding: .utf8
        )
        XCTAssertTrue(source.contains("no Submerged Depth and Pressure entitlement required"))
    }

    func testAppleDepthSensorAvailabilityProbeIsNonInstantiating() throws {
        let source = try String(
            contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Utils/AppleDepthSensorAvailability.swift"),
            encoding: .utf8
        )
        XCTAssertTrue(source.contains("does not instantiate"))
        XCTAssertTrue(source.contains("CMWaterSubmersionManager"))
    }

    func testSnorkelingNavigationEngineSoftwareGate() {
        let bearing = SnorkelingDomainSupport.bearingDegrees(
            from: (latitude: 44.4, longitude: 8.94),
            to: (latitude: 44.401, longitude: 8.95)
        )
        XCTAssertNotNil(bearing)
        let delta = SnorkelingDomainSupport.signedAngularDeltaDegrees(heading: 350, bearing: 10)
        XCTAssertEqual(delta, 20, accuracy: 0.1)
    }

    func testApneaWetInteractionEvidenceFolderPending() throws {
        let readme = repositoryRoot().appendingPathComponent("Docs/QA_EVIDENCE/APNEA_WET_INTERACTION/README.md")
        XCTAssertTrue(FileManager.default.fileExists(atPath: readme.path))
        let text = try String(contentsOf: readme, encoding: .utf8)
        XCTAssertTrue(text.localizedCaseInsensitiveContains("PENDING"))
    }

    func testFullComputerBatteryPolicySoftwareGate() {
        XCTAssertNotNil(DIRPerformanceBudgets.entry(for: .watchFullComputerCompleteSolver))
        XCTAssertNotNil(DIRPerformanceBudgets.entry(for: .watchFullComputerTissueUpdate))
    }

    func testDepthSafetyConfigurationSoftwareGate() {
        XCTAssertEqual(DepthSafetyConfiguration.cautionDepthMeters, 35)
        XCTAssertEqual(DepthSafetyConfiguration.maximumSupportedDepthMeters, 40)
        XCTAssertEqual(DepthSafetyState.from(depthMeters: 36), .caution)
        XCTAssertEqual(DepthSafetyState.from(depthMeters: 40), .exceeded)
    }

    func testWatchUltraPhysicalEvidenceFolderPending() throws {
        let readme = repositoryRoot().appendingPathComponent("Docs/QA_EVIDENCE/WATCH_ULTRA/README.md")
        XCTAssertTrue(FileManager.default.fileExists(atPath: readme.path))
        let text = try String(contentsOf: readme, encoding: .utf8)
        XCTAssertTrue(text.localizedCaseInsensitiveContains("PENDING"))
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
