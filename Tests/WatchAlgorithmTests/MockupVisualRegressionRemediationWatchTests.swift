import XCTest

final class MockupVisualRegressionRemediationWatchTests: XCTestCase {
    func testAllFullComputerMockupsHaveExecutableFixtures() {
        for reference in FullComputerMockupReferenceMatrix.all {
            XCTAssertTrue(reference.hasExecutableFixture, reference.id)
            XCTAssertNotNil(reference.fixtureKey, reference.id)
        }
    }

    func testFixtureKeysResolveInRegistry() {
        let referenced = FullComputerMockupReferenceMatrix.fixtureKeysReferencedByMockups()
        for key in referenced {
            XCTAssertTrue(MockupVisualRegressionRegistry.resolveFixtureKey(key), key)
        }
    }

    func testApneaAndSnorkelingMockupPNGExistence() {
        let root = repositoryRoot()
        XCTAssertTrue(ApneaMockupReferenceMatrix.referencePNGExists(at: root).isEmpty)
        XCTAssertTrue(SnorkelingMockupReferenceMatrix.referencePNGExists(at: root).isEmpty)
    }

    func testWatchSettingsFixtureKeyRegistered() {
        XCTAssertTrue(
            MockupVisualRegressionRegistry.resolveFixtureKey(WatchSettingsMockupFixtures.fixtureKey)
        )
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
