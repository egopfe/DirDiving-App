import XCTest

final class BuhlmannGoldenFixtureTests: XCTestCase {
    func testAllGoldenFixturesParseAndRunDeterministically() throws {
        let fixtures = try FixtureLoader.loadAll()
        XCTAssertFalse(fixtures.isEmpty)
        for fixture in fixtures where fixture.isValid {
            let result = BuhlmannEngine.plan(fixture.makeRequest())
            XCTAssertFalse(result.hasBlockingIssues, "Fixture \(fixture.id) should be valid")
            XCTAssertEqual(result.modelState, .validReference, "Fixture \(fixture.id) expected valid reference")
            XCTAssertFalse(result.ttsMinutes < 0)
            XCTAssertFalse(result.ttsMinutes == 999, "Fixture \(fixture.id) returned fake NDL/TTS value")
            XCTAssertFalse(result.stops.contains { !$0.depthMeters.isFinite || !$0.ppO2.isFinite })
            if let range = fixture.expectedTTSRangeMinutes {
                XCTAssertGreaterThanOrEqual(Double(result.ttsMinutes), range.min - fixture.toleranceMinutes)
                XCTAssertLessThanOrEqual(Double(result.ttsMinutes), range.max + fixture.toleranceMinutes)
            }
        }
    }
}

struct FixtureTTSRange: Codable {
    let min: Double
    let max: Double
}

struct PlannerFixture: Codable {
    let id: String
    let isValid: Bool
    let depthMeters: Double
    let bottomMinutes: Double
    let gfLow: Double
    let gfHigh: Double
    let gases: [FixtureGas]
    let expectedTTSRangeMinutes: FixtureTTSRange?
    let toleranceMinutes: Double

    func makeRequest() -> BuhlmannPlanRequest {
        let bottom = gases.first(where: { $0.role == "bottom" }) ?? gases[0]
        let deco = gases.filter { $0.role == "deco" }.map { $0.toBuhlmannGas() }
        return BuhlmannPlanRequest(
            maxDepthMeters: depthMeters,
            bottomMinutes: bottomMinutes,
            bottomGas: bottom.toBuhlmannGas(),
            travelGases: [],
            decoGases: deco,
            gfLow: gfLow,
            gfHigh: gfHigh
        )
    }
}

struct FixtureGas: Codable {
    let name: String
    let role: String
    let oxygen: Double
    let helium: Double
    let maxPPO2: Double
    let switchDepthMeters: Double

    func toBuhlmannGas() -> BuhlmannGas {
        BuhlmannGas(
            name: name,
            role: role == "deco" ? .deco : .bottom,
            oxygenFraction: oxygen,
            heliumFraction: helium,
            maxPPO2Bar: maxPPO2,
            switchDepthMeters: switchDepthMeters
        )
    }
}

enum FixtureLoader {
    static let fixtureFiles = [
        "air-18m.json",
        "air-30m.json",
        "air-40m.json",
        "nitrox32-30m.json",
        "trimix-bottom.json",
        "trimix-ean50.json",
        "trimix-ean50-o2.json",
        "gf-30-70.json",
        "gf-50-80.json",
        "altitude-profile.json",
        "fresh-vs-salt-profile.json",
        "repetitive-surface-interval.json",
        "lost-deco-gas.json",
        "invalid-gas-composition.json",
        "mod-violation.json",
        "hypoxic-too-shallow.json",
        "gas-switch-too-deep.json"
    ]

    static func loadAll() throws -> [PlannerFixture] {
        try fixtureFiles.map(load)
    }

    static func load(_ name: String) throws -> PlannerFixture {
        let bundle = Bundle(for: BuhlmannGoldenFixtureTests.self)
        guard let url = bundle.url(forResource: name.replacingOccurrences(of: ".json", with: ""), withExtension: "json", subdirectory: "Fixtures") else {
            throw NSError(domain: "Fixture", code: 404, userInfo: [NSLocalizedDescriptionKey: "Fixture missing: \(name)"])
        }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(PlannerFixture.self, from: data)
    }
}
