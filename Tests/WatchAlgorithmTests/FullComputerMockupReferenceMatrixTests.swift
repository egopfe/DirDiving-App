import XCTest

final class FullComputerMockupReferenceMatrixTests: XCTestCase {
    func testMatrixAccountsForAllTwentyFiveMockupFiles() {
        XCTAssertEqual(FullComputerMockupReferenceMatrix.count, 25)
        let fileNames = FullComputerMockupReferenceMatrix.all.map(\.fileName)
        XCTAssertEqual(Set(fileNames).count, 25, "Duplicate mockup file names in matrix")
        for index in 1...25 {
            let id = String(format: "FC_UI_%02d", index)
            XCTAssertTrue(
                FullComputerMockupReferenceMatrix.all.contains(where: { $0.id == id }),
                "Missing matrix entry for \(id)"
            )
        }
    }

    func testFixtureKeysMapToVisualRegressionStates() {
        let regression = Set(FullComputerLivePanelFixtures.visualRegressionStateNames)
        let referenced = FullComputerMockupReferenceMatrix.fixtureKeysReferencedByMockups()
        XCTAssertTrue(referenced.isSubset(of: regression), "Unknown fixture keys: \(referenced.subtracting(regression))")
    }

    func testExecutableFixturesResolveForLivePresentationStates() {
        let fixtures = FullComputerLivePanelFixtures.localizedPresentationFixtures.map(\.0)
        for reference in FullComputerMockupReferenceMatrix.all where reference.hasExecutableFixture {
            guard let key = reference.fixtureKey else { continue }
            if fixtures.contains(key) {
                continue
            }
            XCTAssertTrue(
                FullComputerLivePanelFixtures.visualRegressionStateNames.contains(key),
                "Fixture key \(key) for \(reference.id) is not in visual regression list"
            )
        }
    }
}
