import XCTest

final class IOSSnorkelingLogbookAnalyticsTests: XCTestCase {
    func testEligibilityExcludesSimulatedAndDegradedByDefault() {
        let simulated = makeSession(dipCount: 1, maxDepth: 8, startMode: .manual, includeSamples: false)
        var degraded = makeSession(dipCount: 1, maxDepth: 12)
        degraded.warnings = [.dataQualityDegraded]
        let valid = makeSession(dipCount: 2, maxDepth: 14.5)

        XCTAssertFalse(SnorkelingRecordEligibilityPolicy.isEligibleForRecords(simulated))
        XCTAssertFalse(SnorkelingRecordEligibilityPolicy.isEligibleForRecords(degraded))
        XCTAssertTrue(SnorkelingRecordEligibilityPolicy.isEligibleForRecords(valid))

        let summary = SnorkelingPersonalRecordsEngine.compute(from: [simulated, degraded, valid])
        XCTAssertEqual(summary.eligibleSessionCount, 1)
        XCTAssertEqual(summary.excludedSessionCount, 2)
    }

    func testEligibilityOverrideIncludesDegradedSessions() {
        var degraded = makeSession(dipCount: 1, maxDepth: 10)
        degraded.warnings = [.sparseTrack]
        let options = SnorkelingRecordEligibilityOptions(includeSimulatedSessions: false, includeDegradedData: true)
        XCTAssertTrue(SnorkelingRecordEligibilityPolicy.isEligibleForRecords(degraded, options: options))
    }

    func testPersonalRecordsPicksDeepestDipAndLongestSession() {
        let shallow = makeSession(dipCount: 1, maxDepth: 6, duration: 40)
        let deep = makeSession(dipCount: 2, maxDepth: 18.2, duration: 95)
        let summary = SnorkelingPersonalRecordsEngine.compute(from: [shallow, deep])
        let deepest = summary.records.first { $0.kind == .deepestDip }
        let longestSession = summary.records.first { $0.kind == .longestSessionDuration }
        XCTAssertEqual(deepest?.value ?? 0, 18.2, accuracy: 0.01)
        XCTAssertEqual(longestSession?.sessionID, deep.id)
    }

    func testPersonalRecordTiePreservesBestSession() {
        let first = makeSession(id: UUID(), dipCount: 1, maxDepth: 15, duration: 70, createdAt: Date(timeIntervalSince1970: 1_000))
        let second = makeSession(id: UUID(), dipCount: 1, maxDepth: 15, duration: 70, createdAt: Date(timeIntervalSince1970: 2_000))
        let summary = SnorkelingPersonalRecordsEngine.compute(from: [first, second])
        let deepest = summary.records.first { $0.kind == .deepestDip }
        XCTAssertEqual(deepest?.ties.count, 1)
    }

    func testDipAnalyticsAssociatesSurfacePosition() {
        let track = [
            surfaceTrackPoint(seconds: 0, lat: 44.10, lon: 8.90),
            surfaceTrackPoint(seconds: 30, lat: 44.11, lon: 8.91),
        ]
        var session = makeSession(dipCount: 1, maxDepth: 10, duration: 45)
        session.trackPoints = track
        let metrics = SnorkelingDipAnalytics.metricsForSession(session)
        XCTAssertEqual(metrics.count, 1)
        XCTAssertTrue(metrics[0].surfaceAssociation.hasCoordinate)
        XCTAssertNotEqual(metrics[0].surfaceAssociation.method, .unavailable)
    }

    func testSessionChartBuilderBuildsDepthDistanceAndSpeedSeries() {
        var session = makeSession(dipCount: 1, maxDepth: 12, duration: 60)
        session.trackPoints = [
            surfaceTrackPoint(seconds: 0, lat: 44.10, lon: 8.90, speed: 0.8),
            surfaceTrackPoint(seconds: 60, lat: 44.11, lon: 8.91, speed: 1.1),
        ]
        let charts = SnorkelingSessionChartBuilder.build(from: session)
        XCTAssertTrue(charts.hasDepthData)
        XCTAssertTrue(charts.hasDistanceData)
        XCTAssertTrue(charts.hasSpeedData)
        XCTAssertEqual(charts.dipBars.count, 1)
    }

    func testSessionChartBuilderHandlesEmptySession() {
        let session = SnorkelingSession(startMode: .watch, state: .completed, dips: [])
        XCTAssertEqual(SnorkelingSessionChartBuilder.build(from: session), .empty)
    }

    func testMapPresentationSplitsGapsIntoSegments() {
        var session = makeSession(dipCount: 1, maxDepth: 8)
        session.trackPoints = [
            surfaceTrackPoint(seconds: 0, lat: 44.10, lon: 8.90),
            surfaceTrackPoint(seconds: 10, lat: 44.101, lon: 8.901),
            surfaceTrackPoint(seconds: 80, lat: 44.12, lon: 8.92),
            surfaceTrackPoint(seconds: 90, lat: 44.121, lon: 8.921),
        ]
        let map = SnorkelingSessionMapPresentation.make(from: session)
        XCTAssertTrue(map.isAvailable)
        XCTAssertGreaterThanOrEqual(map.gapCount, 1)
        XCTAssertGreaterThan(map.segments.count, 1)
    }

    func testMapPresentationRequiresAtLeastTwoMeasuredPoints() {
        var session = makeSession(dipCount: 1, maxDepth: 8)
        session.trackPoints = [surfaceTrackPoint(seconds: 0, lat: 44.10, lon: 8.90)]
        XCTAssertFalse(SnorkelingSessionMapPresentation.make(from: session).isAvailable)
    }

    func testStatisticsRangeFilterRespectsTimezoneDates() {
        let reference = Date(timeIntervalSince1970: 1_900_000_000)
        let old = makeSession(dipCount: 1, maxDepth: 8, createdAt: Calendar.current.date(byAdding: .day, value: -40, to: reference)!)
        let recent = makeSession(dipCount: 2, maxDepth: 14, createdAt: reference)
        let stats = SnorkelingLogbookAnalytics.aggregate(
            from: [old, recent],
            range: .last30Days,
            referenceDate: reference
        )
        XCTAssertEqual(stats.sessionCount, 1)
        XCTAssertEqual(stats.totalDipCount, 2)
    }

    func testPresentationUsesImperialUnits() {
        let session = makeSession(dipCount: 1, maxDepth: 10)
        let row = IOSSnorkelingLogbookPresentationMapper.sessionRow(session, units: .imperial)
        XCTAssertTrue(row.maxDepthText.contains("ft"))
    }

    func testLargeSessionChartBuildPerformance() {
        var dips: [SnorkelingDip] = []
        for index in 0..<30 {
            let samples = (0..<80).map { sampleIndex in
                SnorkelingDipSample(
                    monotonicRelativeTimestampSeconds: TimeInterval(sampleIndex),
                    depthMeters: Double(sampleIndex % 12),
                    temperatureCelsius: 23
                )
            }
            dips.append(
                SnorkelingDip(
                    startedAtMonotonicSeconds: TimeInterval(index * 200),
                    endedAtMonotonicSeconds: TimeInterval(index * 200 + 80),
                    durationSeconds: 80,
                    maxDepthMeters: 12,
                    averageDepthMeters: 6,
                    samples: samples,
                    events: []
                )
            )
        }
        var session = SnorkelingSession(startMode: .watch, state: .completed, dips: dips)
        session.statistics = session.refreshedStatistics()
        measure {
            _ = SnorkelingSessionChartBuilder.build(from: session)
        }
    }

    // MARK: - Helpers

    private func surfaceTrackPoint(
        seconds: TimeInterval,
        lat: Double,
        lon: Double,
        speed: Double? = nil
    ) -> SnorkelingTrackPoint {
        SnorkelingTrackPoint(
            monotonicRelativeTimestampSeconds: seconds,
            wallClockTimestamp: Date(timeIntervalSince1970: 1_700_000_000 + seconds),
            latitude: lat,
            longitude: lon,
            horizontalAccuracyMeters: 12,
            speedMetersPerSecond: speed,
            gpsQuality: .measured,
            isUnderwater: false
        )
    }

    private func makeSession(
        id: UUID = UUID(),
        dipCount: Int,
        maxDepth: Double,
        duration: TimeInterval = 45,
        startMode: SnorkelingSessionStartMode = .watch,
        includeSamples: Bool = true,
        createdAt: Date = Date()
    ) -> SnorkelingSession {
        var dips: [SnorkelingDip] = []
        for index in 0..<dipCount {
            let samples: [SnorkelingDipSample]
            if includeSamples {
                samples = [
                    SnorkelingDipSample(monotonicRelativeTimestampSeconds: 0, depthMeters: 0, temperatureCelsius: 22),
                    SnorkelingDipSample(monotonicRelativeTimestampSeconds: duration / 2, depthMeters: maxDepth, temperatureCelsius: 22),
                    SnorkelingDipSample(monotonicRelativeTimestampSeconds: duration, depthMeters: 0, temperatureCelsius: 22),
                ]
            } else {
                samples = []
            }
            dips.append(
                SnorkelingDip(
                    startedAtMonotonicSeconds: TimeInterval(index * 60),
                    endedAtMonotonicSeconds: TimeInterval(index * 60 + Int(duration)),
                    startedAtWallClock: createdAt,
                    endedAtWallClock: createdAt.addingTimeInterval(duration),
                    durationSeconds: duration,
                    maxDepthMeters: maxDepth,
                    averageDepthMeters: maxDepth * 0.7,
                    samples: samples,
                    events: []
                )
            )
        }
        var session = SnorkelingSession(
            id: id,
            startMode: startMode,
            state: .completed,
            createdAt: createdAt,
            dips: dips
        )
        session.statistics = session.refreshedStatistics()
        return session
    }
}
