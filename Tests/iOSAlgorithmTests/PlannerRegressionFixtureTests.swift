import XCTest

final class PlannerRegressionFixtureTests: XCTestCase {
    func testInvalidFixturesFailClosed() throws {
        let fixtures = try FixtureLoader.loadAll()
        let invalid = fixtures.filter { !$0.isValid }
        XCTAssertFalse(invalid.isEmpty)
        for fixture in invalid {
            let result = BuhlmannEngine.plan(fixture.makeRequest())
            XCTAssertTrue(result.hasBlockingIssues, "Fixture \(fixture.id) should fail closed")
            XCTAssertEqual(result.modelState, .invalidInput, "Fixture \(fixture.id) must return invalid input state")
        }
    }

    func testGF3070IsMoreConservativeThanGF5080() throws {
        let fixtures = try FixtureLoader.loadAll()
        guard let conservative = fixtures.first(where: { $0.id == "gf-30-70" }),
              let aggressive = fixtures.first(where: { $0.id == "gf-50-80" }) else {
            XCTFail("GF fixtures missing")
            return
        }
        let conservativePlan = BuhlmannEngine.plan(conservative.makeRequest())
        let aggressivePlan = BuhlmannEngine.plan(aggressive.makeRequest())
        XCTAssertGreaterThanOrEqual(conservativePlan.ttsMinutes, aggressivePlan.ttsMinutes)
    }
}
