import XCTest

final class IOSDashboardMockupFidelityTests: XCTestCase {
    private let fixedDate = IOSMockupPreviewFixtures.fixedDate
    private let fixedLocaleEN = IOSMockupPreviewFixtures.fixedLocaleEN
    private let fixedLocaleIT = IOSMockupPreviewFixtures.fixedLocaleIT

    func testApneaDashboardLastSessionPresentationIncludesInlineMetrics() {
        let session = sampleApneaSession()
        let presentation = IOSApneaDashboardPresentationMapper.make(
            lastSession: session,
            aggregate: .empty,
            watchConnectivityText: "Connected",
            watchConnectivityIsPositive: true,
            locale: fixedLocaleEN
        )
        XCTAssertTrue(presentation.hasLastSession)
        XCTAssertFalse(presentation.lastSessionDurationText.isEmpty)
        XCTAssertFalse(presentation.lastSessionMaxDepthText.isEmpty)
        XCTAssertEqual(presentation.lastSessionDiveCountText, "2")
    }

    func testApneaDashboardEmptyStateUsesLocalizedKey() {
        let presentation = IOSApneaDashboardPresentationMapper.make(
            lastSession: nil,
            aggregate: .empty,
            watchConnectivityText: "—",
            watchConnectivityIsPositive: false,
            locale: fixedLocaleEN
        )
        XCTAssertFalse(presentation.hasLastSession)
        XCTAssertEqual(presentation.emptyStateText, "apnea.ios.dashboard.empty")
    }

    func testSnorkelingDashboardLastSessionPresentationIncludesInlineMetrics() {
        let session = sampleSnorkelingSession()
        let presentation = IOSSnorkelingDashboardPresentationMapper.make(
            lastSession: session,
            sessions: [session],
            statistics: SnorkelingLogbookStatistics.aggregate(from: [session]),
            watchConnectivityText: "Connected",
            watchConnectivityIsPositive: true,
            syncStatusText: "Synced",
            syncStatusIsPositive: true,
            locale: fixedLocaleEN
        )
        XCTAssertTrue(presentation.hasLastSession)
        XCTAssertFalse(presentation.lastSessionDurationText.isEmpty)
        XCTAssertFalse(presentation.lastSessionMaxDepthText.isEmpty)
        XCTAssertFalse(presentation.lastSessionDistanceText.isEmpty)
    }

    func testApneaDashboardViewContractMatchesMockupAPNEA_IOS_01() throws {
        let source = try String(
            contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/Apnea/IOSApneaDashboardView.swift"),
            encoding: .utf8
        )
        XCTAssertTrue(source.contains("NavigationLink"))
        XCTAssertTrue(source.contains("metricInline"))
        XCTAssertTrue(source.contains("apnea.ios.dashboard.duration"))
        XCTAssertTrue(source.contains("accessibilityIdentifier(\"apnea.ios.dashboard\")"))
    }

    func testSnorkelingDashboardViewContractMatchesMockupSNORKELING_IOS_01() throws {
        let source = try String(
            contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/Snorkeling/IOSSnorkelingDashboardView.swift"),
            encoding: .utf8
        )
        XCTAssertTrue(source.contains("metricInline"))
        XCTAssertTrue(source.contains("accessibilityIdentifier(\"snorkeling.ios.dashboard\")"))
    }

    func testDashboardLocalizationENIT() throws {
        let en = try loadIOSStrings("en")
        let it = try loadIOSStrings("it")
        for key in [
            "apnea.ios.dashboard.duration",
            "apnea.ios.dashboard.last_session.a11y",
            "snorkeling.ios.dashboard.duration",
            "snorkeling.ios.dashboard.last_session.a11y",
        ] {
            XCTAssertFalse(en[key, default: ""].isEmpty, "Missing EN \(key)")
            XCTAssertFalse(it[key, default: ""].isEmpty, "Missing IT \(key)")
        }
    }

    func testApneaDashboardLongTextDoesNotEmptyFields() {
        let session = sampleApneaSession()
        let presentation = IOSApneaDashboardPresentationMapper.make(
            lastSession: session,
            aggregate: .empty,
            watchConnectivityText: String(repeating: "Connected ", count: 20),
            watchConnectivityIsPositive: true,
            locale: fixedLocaleIT
        )
        XCTAssertFalse(presentation.watchConnectivityText.isEmpty)
        XCTAssertFalse(presentation.lastSessionDateText.isEmpty)
    }

    private func sampleApneaSession() -> ApneaSession {
        ApneaSession(
            id: IOSMockupPreviewFixtures.fixedSessionID,
            startMode: .manual,
            state: .completed,
            createdAt: fixedDate,
            dives: [
                ApneaDive(startedAtMonotonicSeconds: 0, durationSeconds: 90, maxDepthMeters: 12, averageDepthMeters: 10),
                ApneaDive(startedAtMonotonicSeconds: 100, durationSeconds: 75, maxDepthMeters: 10, averageDepthMeters: 8),
            ]
        )
    }

    private func sampleSnorkelingSession() -> SnorkelingSession {
        SnorkelingSession(
            id: IOSMockupPreviewFixtures.fixedSessionID,
            startMode: .watch,
            state: .completed,
            createdAt: fixedDate,
            statistics: SnorkelingSessionStatistics(
                dipCount: 2,
                totalDipSeconds: 600,
                sessionMaxDepthMeters: 4.2,
                totalDistanceMeters: 420,
                averageSpeedMetersPerSecond: 0.47,
                markerCount: 0,
                eventCount: 0,
                sessionDurationSeconds: 900
            )
        )
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private func loadIOSStrings(_ locale: String) throws -> [String: String] {
        let url = repositoryRoot().appendingPathComponent("iOSApp/Resources/\(locale).lproj/Localizable.strings")
        return parseStrings(try String(contentsOf: url))
    }

    private func parseStrings(_ raw: String) -> [String: String] {
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
