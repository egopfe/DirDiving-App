import XCTest

final class BuhlmannGoldenFixtureTests: XCTestCase {
    func testAllGoldenFixturesParseAndRunDeterministically() throws {
        let fixtures = try FixtureLoader.loadAll()
        XCTAssertFalse(fixtures.isEmpty)
        for fixture in fixtures where fixture.isValid {
            let result = BuhlmannEngine.plan(try fixture.makeRequest())
            XCTAssertFalse(result.hasBlockingIssues, "Fixture \(fixture.id) should be valid")
            XCTAssertEqual(result.modelState, .validReference, "Fixture \(fixture.id) expected valid reference")
            XCTAssertFalse(result.ttsMinutes < 0)
            XCTAssertFalse(result.ttsMinutes == 999, "Fixture \(fixture.id) returned fake NDL/TTS value")
            XCTAssertFalse(result.stops.contains { !$0.depthMeters.isFinite || !$0.ppO2.isFinite })
            if let ndl = result.ndlMinutes {
                XCTAssertFalse(ndl.isNaN)
                XCTAssertFalse(ndl.isInfinite)
                XCTAssertLessThan(ndl, 999)
            }
            if let range = fixture.expectedTTSRangeMinutes {
                XCTAssertGreaterThanOrEqual(Double(result.ttsMinutes), range.min - fixture.toleranceMinutes)
                XCTAssertLessThanOrEqual(Double(result.ttsMinutes), range.max + fixture.toleranceMinutes)
            }
            if let firstStop = fixture.expectedFirstStopDepthMeters {
                XCTAssertEqual(result.stops.first?.depthMeters ?? 0, firstStop, accuracy: fixture.toleranceMinutes)
            }
            if let ndlRange = fixture.expectedNDLRangeMinutes, let ndl = result.ndlMinutes {
                XCTAssertGreaterThanOrEqual(ndl, ndlRange.min - 1)
                XCTAssertLessThanOrEqual(ndl, ndlRange.max + 1)
            }
        }
    }

    func testMalformedFixtureSchemaIsRejected() throws {
        let malformed = """
        {"id":"broken","isValid":true,"depthMeters":30}
        """.data(using: .utf8)!
        XCTAssertThrowsError(try JSONDecoder().decode(PlannerFixture.self, from: malformed))
    }
}

struct FixtureTTSRange: Codable {
    let min: Double
    let max: Double
}

struct FixtureEnvironment: Codable {
    let altitudeMeters: Double
    let salinity: String

    func makeEnvironment() throws -> PlannerEnvironment {
        let mode: SalinityMode = salinity.lowercased() == "fresh" ? .fresh : .salt
        switch PlannerEnvironment.make(altitudeMeters: altitudeMeters, salinity: mode) {
        case .success(let environment):
            return environment
        case .failure(let error):
            throw error
        }
    }
}

struct FixturePriorDive: Codable {
    let depthMeters: Double
    let bottomMinutes: Double
    let surfaceIntervalMinutes: Double
}

struct PlannerFixture: Codable {
    let id: String
    let isValid: Bool
    let depthMeters: Double
    let bottomMinutes: Double
    let gfLow: Double
    let gfHigh: Double
    let gases: [FixtureGas]
    let environment: FixtureEnvironment?
    let priorDive: FixturePriorDive?
    let expectedTTSRangeMinutes: FixtureTTSRange?
    let expectedNDLRangeMinutes: FixtureTTSRange?
    let expectedFirstStopDepthMeters: Double?
    let toleranceMinutes: Double

    func makeRequest() throws -> BuhlmannPlanRequest {
        guard !gases.isEmpty else {
            throw FixtureLoader.Error.malformed(id)
        }
        let environment = try (environment?.makeEnvironment()) ?? .seaLevelSaltWater
        let bottom = gases.first(where: { $0.role == "bottom" }) ?? gases[0]
        let deco = gases.filter { $0.role == "deco" }.map { $0.toBuhlmannGas() }
        var request = BuhlmannPlanRequest(
            maxDepthMeters: depthMeters,
            bottomMinutes: bottomMinutes,
            bottomGas: bottom.toBuhlmannGas(),
            travelGases: [],
            decoGases: deco,
            gfLow: gfLow,
            gfHigh: gfHigh,
            initialTissueState: BuhlmannTissueState.airSaturated(surfacePressureBar: environment.surfacePressureBar),
            plannerEnvironment: environment
        )
        if let prior = priorDive {
            let priorGas = bottom.toBuhlmannGas()
            var priorRequest = request
            priorRequest.maxDepthMeters = prior.depthMeters
            priorRequest.bottomMinutes = prior.bottomMinutes
            priorRequest.bottomGas = priorGas
            let priorResult = BuhlmannEngine.plan(priorRequest)
            guard let snapshot = RepetitiveDivePlannerService.makeSnapshot(from: priorResult, environment: environment) else {
                throw FixtureLoader.Error.malformed(id)
            }
            switch RepetitiveDivePlannerService.seedRequest(
                request,
                snapshot: snapshot,
                surfaceIntervalMinutes: prior.surfaceIntervalMinutes,
                environment: environment
            ) {
            case .success(let seeded):
                request = seeded
            case .failure:
                throw FixtureLoader.Error.malformed(id)
            }
        }
        return request
    }
}

struct FixtureGas: Codable {
    let name: String
    let role: String
    let oxygen: Double
    let helium: Double
    let maxPPO2: Double
    let switchDepthMeters: Double
    let gasMixId: String?
    let cylinderId: String?

    func toBuhlmannGas() -> BuhlmannGas {
        BuhlmannGas(
            name: name,
            role: role == "deco" ? .deco : .bottom,
            oxygenFraction: oxygen,
            heliumFraction: helium,
            maxPPO2Bar: maxPPO2,
            switchDepthMeters: switchDepthMeters,
            gasMixId: gasMixId.flatMap(UUID.init(uuidString:)) ?? UUID(),
            cylinderId: cylinderId.flatMap(UUID.init(uuidString:))
        )
    }
}

enum FixtureLoader {
    enum Error: Swift.Error {
        case malformed(String)
    }

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
        "duplicate-gas-labels.json",
        "oxygen-exposure-deco.json",
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
        let baseName = name.replacingOccurrences(of: ".json", with: "")
        let url = bundle.url(forResource: baseName, withExtension: "json", subdirectory: "Fixtures")
            ?? bundle.url(forResource: baseName, withExtension: "json")
        guard let url else {
            throw NSError(domain: "Fixture", code: 404, userInfo: [NSLocalizedDescriptionKey: "Fixture missing: \(name)"])
        }
        let data = try Data(contentsOf: url)
        let fixture = try JSONDecoder().decode(PlannerFixture.self, from: data)
        guard fixture.toleranceMinutes.isFinite, fixture.toleranceMinutes >= 0 else {
            throw Error.malformed(fixture.id)
        }
        return fixture
    }
}
