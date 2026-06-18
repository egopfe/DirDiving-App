import XCTest

final class SnorkelingReleaseHardValidationTests: XCTestCase {
    private let startDate = Date(timeIntervalSince1970: 1_700_000_000)

    func testReleaseSelfCheckPassesOnSnorkelingSources() throws {
        let root = repositoryRoot()
        let sources = try snorkelingSourceCorpus()
        let english = try loadWatchStrings(named: "en")
        let italian = try loadWatchStrings(named: "it")
        let issues = SnorkelingReleaseSelfCheck.runAll(
            snorkelingSourceText: sources,
            english: english,
            italian: italian,
            repositoryRoot: root
        )
        XCTAssertTrue(issues.isEmpty, "Self-check issues: \(issues)")
    }

    func testSnorkelingViewIncludedInWatchMainTarget() throws {
        let project = try String(contentsOf: repositoryRoot().appendingPathComponent("project.yml"), encoding: .utf8)
        XCTAssertFalse(project.contains("- SnorkelingView.swift"))
        XCTAssertTrue(project.contains("Services/SnorkelingWatchRuntimeStore.swift"))
    }

    func testCheckpointNamespaceIsUnique() {
        XCTAssertEqual(SnorkelingReleaseSelfCheck.checkpointNamespace, "dirdiving_snorkeling_session")
        XCTAssertNotEqual(
            SnorkelingReleaseSelfCheck.checkpointNamespace,
            SnorkelingReleaseSelfCheck.apneaSessionPayloadKey
        )
    }

    func testCheckpointRoundTripWithinBudget() throws {
        var engine = SnorkelingSessionEngine(configuration: .default, sessionStart: startDate)
        engine.armSession(at: startDate)
        engine.startSession(at: startDate)
        let start = CFAbsoluteTimeGetCurrent()
        var copy = engine
        let envelope = try copy.exportCheckpointEnvelope(
            runtime: SnorkelingCheckpointRuntimeState(sessionArmed: true, sessionStarted: true, missionModeEnabled: false, hapticsEnabled: true)
        )
        _ = try SnorkelingSessionEngine.restoreState(from: envelope)
        let elapsed = CFAbsoluteTimeGetCurrent() - start
        XCTAssertLessThanOrEqual(elapsed, SnorkelingReleaseHardTolerances.checkpointRoundTripBudgetSeconds)
    }

    func testRouteNormalizationIsNotRepeatedForUnchangedRoute() {
        let waypointA = SnorkelingWaypoint(name: "A", category: .reef, latitude: 44.4, longitude: 8.94, routeOrder: 0)
        let waypointB = SnorkelingWaypoint(name: "B", category: .reef, latitude: 44.41, longitude: 8.95, routeOrder: 1)
        let route = SnorkelingRoutePlan(name: "Test", waypoints: [waypointB, waypointA])
        var state = SnorkelingNavigationRuntimeState.initial
        let position = SnorkelingNavigationPositionInput(
            latitude: 44.4,
            longitude: 8.94,
            gpsQuality: .measured,
            gpsPresentationState: .tracking,
            isUnderwater: false,
            surfaceSpeedMetersPerSecond: 0.5,
            fixAgeSeconds: 1
        )
        let heading = SnorkelingNavigationHeadingInput(headingDegrees: 90, ageSeconds: 1)
        let first = SnorkelingNavigationEngine.evaluateWaypointNavigation(
            routePlan: route,
            state: state,
            position: position,
            heading: heading
        )
        let second = SnorkelingNavigationEngine.evaluateWaypointNavigation(
            routePlan: route,
            state: first.state,
            position: position,
            heading: heading
        )
        XCTAssertEqual(first.state.routePlanWaypointSignature, second.state.routePlanWaypointSignature)
        XCTAssertEqual(first.state.orderedWaypointIDs, second.state.orderedWaypointIDs)
    }

    func testQualityDegradationInvalidatesPreciseGuidance() {
        let valid = SnorkelingNavigationEngine.permitsPreciseTurnGuidance(
            position: .init(latitude: 44.4, longitude: 8.94, gpsQuality: .measured, gpsPresentationState: .tracking, isUnderwater: false, surfaceSpeedMetersPerSecond: 0.5, fixAgeSeconds: 1),
            headingQuality: .valid,
            configuration: .default
        )
        let stale = SnorkelingNavigationEngine.permitsPreciseTurnGuidance(
            position: .init(latitude: 44.4, longitude: 8.94, gpsQuality: .measured, gpsPresentationState: .tracking, isUnderwater: false, surfaceSpeedMetersPerSecond: 0.5, fixAgeSeconds: 1),
            headingQuality: .stale,
            configuration: .default
        )
        XCTAssertTrue(valid)
        XCTAssertFalse(stale)
    }

    func testDatelineBehaviorRemainsCorrectAfterOptimization() {
        let bearing = SnorkelingDomainSupport.bearingDegrees(
            from: (latitude: 10, longitude: 179.5),
            to: (latitude: 10, longitude: -179.5)
        )
        XCTAssertNotNil(bearing)
        XCTAssertGreaterThan(bearing ?? 0, 0)
        XCTAssertLessThan(bearing ?? 180, 180)
    }

    private func snorkelingSourceCorpus() throws -> String {
        let paths = [
            "Shared/Utils/SnorkelingNavigationEngine.swift",
            "Shared/Utils/SnorkelingReturnAdvisor.swift",
            "Shared/Utils/SnorkelingOperationalEventEngine.swift",
            "Utils/SnorkelingWatchPresentation.swift",
            "Views/SnorkelingView.swift",
            "Services/SnorkelingWatchRuntimeStore.swift",
        ]
        return try paths.map { try String(contentsOf: repositoryRoot().appendingPathComponent($0), encoding: .utf8) }.joined(separator: "\n")
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private func loadWatchStrings(named locale: String) throws -> [String: String] {
        let url = repositoryRoot().appendingPathComponent("Resources/\(locale).lproj/Localizable.strings")
        return parseStringsFile(try String(contentsOf: url, encoding: .utf8))
    }

    private func parseStringsFile(_ raw: String) -> [String: String] {
        var result: [String: String] = [:]
        let pattern = #"\"([^\"]+)\"\s*=\s*\"([^\"]*)\";"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return result }
        let range = NSRange(raw.startIndex..<raw.endIndex, in: raw)
        regex.enumerateMatches(in: raw, range: range) { match, _, _ in
            guard let match,
                  let keyRange = Range(match.range(at: 1), in: raw),
                  let valueRange = Range(match.range(at: 2), in: raw) else { return }
            result[String(raw[keyRange])] = String(raw[valueRange])
        }
        return result
    }
}
