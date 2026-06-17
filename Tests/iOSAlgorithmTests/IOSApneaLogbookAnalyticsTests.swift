import XCTest

final class IOSApneaLogbookAnalyticsTests: XCTestCase {
    func testEligibilityExcludesSimulatedAndDegradedByDefault() {
        let simulated = makeSession(diveCount: 1, maxDepth: 12, startMode: .manual, includeSamples: false)
        var degraded = makeSession(diveCount: 1, maxDepth: 18)
        degraded.warnings = [.dataQualityDegraded]
        let valid = makeSession(diveCount: 2, maxDepth: 24.7)

        XCTAssertFalse(ApneaRecordEligibilityPolicy.isEligibleForRecords(simulated))
        XCTAssertFalse(ApneaRecordEligibilityPolicy.isEligibleForRecords(degraded))
        XCTAssertTrue(ApneaRecordEligibilityPolicy.isEligibleForRecords(valid))

        let summary = ApneaPersonalRecordsEngine.compute(from: [simulated, degraded, valid])
        XCTAssertEqual(summary.eligibleSessionCount, 1)
        XCTAssertEqual(summary.excludedSessionCount, 2)
    }

    func testEligibilityOverrideIncludesDegradedSessions() {
        var degraded = makeSession(diveCount: 1, maxDepth: 18)
        degraded.warnings = [.sparseSamples]
        let options = ApneaRecordEligibilityOptions(includeSimulatedSessions: false, includeDegradedData: true)
        XCTAssertTrue(ApneaRecordEligibilityPolicy.isEligibleForRecords(degraded, options: options))
    }

    func testPersonalRecordsPicksDeepestAndLongest() {
        let shallow = makeSession(diveCount: 1, maxDepth: 12, duration: 50)
        let deep = makeSession(diveCount: 1, maxDepth: 28.5, duration: 106)
        let summary = ApneaPersonalRecordsEngine.compute(from: [shallow, deep])
        let deepest = summary.records.first { $0.kind == .deepestDive }
        let longest = summary.records.first { $0.kind == .longestApnea }
        XCTAssertEqual(deepest?.value ?? 0, 28.5, accuracy: 0.01)
        XCTAssertEqual(longest?.value ?? 0, 106, accuracy: 0.01)
        XCTAssertEqual(deepest?.sessionID, deep.id)
    }

    func testPersonalRecordTiePreservesBestSession() {
        let first = makeSession(id: UUID(), diveCount: 1, maxDepth: 20, duration: 80, createdAt: Date(timeIntervalSince1970: 1_000))
        let second = makeSession(id: UUID(), diveCount: 1, maxDepth: 20, duration: 80, createdAt: Date(timeIntervalSince1970: 2_000))
        let summary = ApneaPersonalRecordsEngine.compute(from: [first, second])
        let deepest = summary.records.first { $0.kind == .deepestDive }
        XCTAssertEqual(deepest?.ties.count, 1)
    }

    func testDiveAnalyticsComputesSpeedsAndMarkers() {
        let markerID = UUID()
        let dive = ApneaDive(
            startedAtMonotonicSeconds: 0,
            durationSeconds: 84,
            maxDepthMeters: 24.4,
            averageDepthMeters: 14,
            samples: [
                ApneaSample(monotonicRelativeTimestampSeconds: 0, depthMeters: 0, verticalSpeedMetersPerSecond: -1.1),
                ApneaSample(monotonicRelativeTimestampSeconds: 20, depthMeters: 22, temperatureCelsius: 24, verticalSpeedMetersPerSecond: 0),
                ApneaSample(monotonicRelativeTimestampSeconds: 60, depthMeters: 24.4, temperatureCelsius: 24, verticalSpeedMetersPerSecond: 0),
                ApneaSample(monotonicRelativeTimestampSeconds: 84, depthMeters: 0, verticalSpeedMetersPerSecond: 1.2),
            ],
            events: [ApneaEvent(kind: .alarmTriggered, monotonicRelativeTimestampSeconds: 60, note: "Depth 20 m")],
            markers: [ApneaDepthMarker(id: markerID, label: "20 m", depthMeters: 20)],
            reachedMarkerIDs: [markerID],
            recoveryAfter: ApneaRecoveryInterval(plannedSeconds: 84, completedSeconds: 84)
        )
        let metrics = ApneaDiveAnalytics.metrics(for: dive, diveIndex: 0, sessionOffsetSeconds: 0)
        XCTAssertEqual(metrics.descentSpeedMetersPerSecond, 1.1, accuracy: 0.01)
        XCTAssertEqual(metrics.ascentSpeedMetersPerSecond, 1.2, accuracy: 0.01)
        XCTAssertEqual(metrics.averageTemperatureCelsius ?? 0, 24, accuracy: 0.01)
        XCTAssertEqual(metrics.markersReached, ["20 m"])
        XCTAssertEqual(metrics.alarmsTriggered, ["Depth 20 m"])
        XCTAssertEqual(metrics.recoveryAfterSeconds, 84, accuracy: 0.01)
        XCTAssertTrue(metrics.hasDepthProfile)
    }

    func testSessionChartBuilderSeparatesDivesAndRecovery() {
        var dive = ApneaDive(
            startedAtMonotonicSeconds: 0,
            durationSeconds: 60,
            maxDepthMeters: 20,
            averageDepthMeters: 12,
            samples: [
                ApneaSample(monotonicRelativeTimestampSeconds: 0, depthMeters: 0),
                ApneaSample(monotonicRelativeTimestampSeconds: 30, depthMeters: 20),
                ApneaSample(monotonicRelativeTimestampSeconds: 60, depthMeters: 0),
            ],
            recoveryAfter: ApneaRecoveryInterval(plannedSeconds: 60, completedSeconds: 60)
        )
        let session = ApneaSession(startMode: .watch, state: .completed, dives: [dive])
        let charts = ApneaSessionChartBuilder.build(from: session)
        XCTAssertTrue(charts.hasDepthData)
        XCTAssertTrue(charts.hasRecoveryData)
        XCTAssertEqual(charts.diveBars.count, 1)
        XCTAssertEqual(charts.recoveryBars.count, 1)
        XCTAssertGreaterThan(charts.depthPoints.count, 2)
    }

    func testSessionChartBuilderHandlesEmptySession() {
        let session = ApneaSession(startMode: .watch, state: .completed, dives: [])
        XCTAssertEqual(ApneaSessionChartBuilder.build(from: session), .empty)
    }

    func testMapPresentationRequiresAtLeastTwoGPSPoints() {
        var session = makeSession(diveCount: 1, maxDepth: 10)
        session.surfaceGPSPoints = [
            ApneaSurfaceGPSPoint(latitude: 44.1, longitude: 8.9, horizontalAccuracyMeters: 12)
        ]
        XCTAssertFalse(ApneaSessionMapPresentation.make(from: session).isAvailable)

        session.surfaceGPSPoints.append(
            ApneaSurfaceGPSPoint(latitude: 44.11, longitude: 8.91, horizontalAccuracyMeters: 15, capturedAt: Date().addingTimeInterval(3600))
        )
        let map = ApneaSessionMapPresentation.make(from: session)
        XCTAssertTrue(map.isAvailable)
        XCTAssertEqual(map.coordinates.count, 2)
        XCTAssertEqual(map.accuracyMeters ?? 0, 15, accuracy: 0.01)
    }

    func testStatisticsRangeFilterRespectsTimezoneDates() {
        let reference = Date(timeIntervalSince1970: 1_900_000_000)
        let old = makeSession(diveCount: 1, maxDepth: 10, createdAt: Calendar.current.date(byAdding: .day, value: -40, to: reference)!)
        let recent = makeSession(diveCount: 2, maxDepth: 22, createdAt: reference)
        let stats = ApneaLogbookStatistics.aggregate(
            from: [old, recent],
            range: .last30Days,
            referenceDate: reference
        )
        XCTAssertEqual(stats.sessionCount, 1)
        XCTAssertEqual(stats.totalDiveCount, 2)
    }

    func testPresentationUsesImperialUnits() {
        let session = makeSession(diveCount: 1, maxDepth: 30)
        let row = IOSApneaLogbookPresentationMapper.sessionRow(session, units: .imperial)
        XCTAssertTrue(row.maxDepthText.contains("ft"))
    }

    func testLargeSessionChartBuildPerformance() {
        var dives: [ApneaDive] = []
        for index in 0..<40 {
            let samples = (0..<120).map { sampleIndex in
                ApneaSample(
                    monotonicRelativeTimestampSeconds: TimeInterval(sampleIndex),
                    depthMeters: Double(sampleIndex % 20),
                    temperatureCelsius: 24
                )
            }
            dives.append(
                ApneaDive(
                    startedAtMonotonicSeconds: TimeInterval(index * 500),
                    durationSeconds: 120,
                    maxDepthMeters: 20,
                    averageDepthMeters: 10,
                    samples: samples,
                    recoveryAfter: ApneaRecoveryInterval(plannedSeconds: 90, completedSeconds: 90)
                )
            )
        }
        let session = ApneaSession(startMode: .watch, state: .completed, dives: dives)
        measure {
            _ = ApneaSessionChartBuilder.build(from: session)
        }
    }

    private func makeSession(
        id: UUID = UUID(),
        diveCount: Int,
        maxDepth: Double,
        duration: TimeInterval = 60,
        startMode: ApneaSessionStartMode = .watch,
        includeSamples: Bool = true,
        createdAt: Date = Date()
    ) -> ApneaSession {
        let dives = (0..<diveCount).map { index in
            let samples: [ApneaSample]
            if includeSamples {
                samples = [
                    ApneaSample(monotonicRelativeTimestampSeconds: 0, depthMeters: 0),
                    ApneaSample(monotonicRelativeTimestampSeconds: duration / 2, depthMeters: maxDepth, temperatureCelsius: 24),
                    ApneaSample(monotonicRelativeTimestampSeconds: duration, depthMeters: 0),
                ]
            } else {
                samples = []
            }
            return ApneaDive(
                startedAtMonotonicSeconds: TimeInterval(index * 200),
                durationSeconds: duration,
                maxDepthMeters: maxDepth,
                averageDepthMeters: maxDepth * 0.6,
                samples: samples
            )
        }
        var session = ApneaSession(
            id: id,
            startMode: startMode,
            state: .completed,
            createdAt: createdAt,
            dives: dives
        )
        session.statistics = session.refreshedStatistics()
        return session
    }
}
