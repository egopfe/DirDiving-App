import XCTest

final class MockupVisualRegressionRemediationTests: XCTestCase {
    func testRegistryAccountsForAllFiftyNineCanonicalMockups() {
        XCTAssertEqual(MockupVisualRegressionRegistry.count, 59)
        XCTAssertEqual(MockupVisualRegressionRegistry.iosRasterEntries.count, 20)
    }

    func testAllMockupsHaveExecutableFixtures() {
        for entry in MockupVisualRegressionRegistry.all {
            XCTAssertTrue(entry.hasExecutableFixture, entry.mockupID)
            XCTAssertNotNil(entry.fixtureKey, entry.mockupID)
            XCTAssertTrue(MockupVisualRegressionRegistry.resolveFixtureKey(entry.fixtureKey!), entry.mockupID)
        }
    }

    func testCommand14DocumentsExist() {
        let root = repositoryRoot()
        for path in MockupVisualRegressionSoftwareGatePolicy.command14AuditDocuments {
            XCTAssertTrue(
                MockupVisualRegressionSoftwareGatePolicy.documentExists(relativePath: path, repositoryRoot: root),
                "Missing \(path)"
            )
        }
    }

    func testQaEvidenceScaffoldingExistsAndRemainsPending() throws {
        let root = repositoryRoot()
        for folder in MockupVisualRegressionSoftwareGatePolicy.qaEvidenceScaffoldingFolders {
            XCTAssertTrue(
                MockupVisualRegressionSoftwareGatePolicy.folderHasScaffolding(relativePath: folder, repositoryRoot: root),
                "Missing scaffolding in \(folder)"
            )
            let status = try String(
                contentsOf: root.appendingPathComponent("\(folder)/STATUS.md"),
                encoding: .utf8
            )
            XCTAssertTrue(status.contains("PENDING"), "\(folder) must remain PENDING")
        }
    }

    func testFullComputerMatrixFixturesIncludeFC0407() {
        let fc04 = FullComputerMockupReferenceMatrix.all.first { $0.id == "FC_UI_04" }
        let fc07 = FullComputerMockupReferenceMatrix.all.first { $0.id == "FC_UI_07" }
        XCTAssertEqual(fc04?.fixtureKey, WatchSettingsMockupFixtures.fixtureKey)
        XCTAssertEqual(fc07?.fixtureKey, IOSDivePlanTransferMockupFixtures.fixtureKey)
        XCTAssertTrue(fc04?.hasExecutableFixture == true)
        XCTAssertTrue(fc07?.hasExecutableFixture == true)
    }

    func testWatchSettingsFixtureIsDeterministic() {
        let first = WatchSettingsMockupFixtures.settingsActivityDefault()
        let second = WatchSettingsMockupFixtures.settingsActivityDefault()
        XCTAssertEqual(first, second)
        XCTAssertEqual(first.defaultActivityMode, .diving)
        XCTAssertTrue(first.showActivitySelectionAtLaunch)
    }

    func testIOSDecoPlanTransferFixtureValidates() throws {
        let package = try IOSDivePlanTransferMockupFixtures.validDecoPlanPackage()
        XCTAssertNoThrow(try DivePlanPackageCodec.validate(package))
        let labels = IOSDivePlanTransferMockupFixtures.presentationLabels(for: package)
        XCTAssertEqual(labels.bottomGas, "Trimix 18/45")
        XCTAssertEqual(labels.decoGases, "EAN50")
        XCTAssertEqual(labels.gf, "30/70")
    }

    func testCanonicalMockupPathsExistOnDisk() {
        let root = repositoryRoot()
        for entry in MockupVisualRegressionRegistry.all {
            XCTAssertTrue(
                MockupCanonicalPaths.fileExists(at: root, relativePath: entry.path),
                "Missing \(entry.path)"
            )
        }
    }

    func testLegacyReferenceUIAssetsRegistered() throws {
        let csv = try String(
            contentsOf: repositoryRoot().appendingPathComponent("Docs/REFERENCE_UI_LEGACY_ASSET_REGISTER_CURRENT.csv"),
            encoding: .utf8
        )
        XCTAssertTrue(csv.contains("Docs/ReferenceUI/Watch_LIVE_reference.png"))
        XCTAssertTrue(csv.contains("historical_reference"))
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
