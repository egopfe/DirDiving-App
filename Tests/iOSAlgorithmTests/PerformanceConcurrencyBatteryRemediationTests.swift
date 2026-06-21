import XCTest

@MainActor
final class PerformanceConcurrencyBatteryRemediationTests: XCTestCase {
    func testSignpostCatalogCoversRequiredCategories() {
        XCTAssertEqual(DIRPerformanceSignpost.catalogCategoryCount, 24)
        XCTAssertEqual(DIRPerformanceSignpostCategory.allCases.count, 24)
        for category in DIRPerformanceSignpostCategory.allCases {
            let interval = DIRPerformanceSignpost.begin(category)
            interval.end()
        }
    }

    func testPerformanceBudgetRegistryCoversAllOperations() {
        XCTAssertTrue(DIRPerformanceBudgets.registryCoversAllOperations)
        XCTAssertNotNil(DIRPerformanceBudgets.entry(for: .watchFullComputerCompleteSolver))
        XCTAssertNotNil(DIRPerformanceBudgets.entry(for: .iosPlannerOCCalculation))
        XCTAssertNotNil(DIRPerformanceBudgets.entry(for: .logbookLoad))
    }

    func testStopwatchPersistencePolicyAcceptsBoundedPayload() {
        StopwatchPersistencePolicy.resetTestHook()
        XCTAssertTrue(StopwatchPersistencePolicy.isAcceptedPayload(accumulatedTime: 120, isRunning: true, startedAt: Date()))
        StopwatchPersistencePolicy.recordPersist()
        XCTAssertEqual(StopwatchPersistencePolicy.testHook_writeCount, 1)
    }

    func testPresentationDownsamplerPreservesEndpoints() {
        let values = Array(0..<10_000)
        let downsampled = PresentationSeriesDownsampler.downsampleUniform(values, maxPoints: 128)
        XCTAssertEqual(downsampled.first, 0)
        XCTAssertEqual(downsampled.last, 9_999)
        XCTAssertLessThanOrEqual(downsampled.count, 128)
    }

    func testLogbookScalabilitySyntheticDatasets() throws {
        for count in [100, 500, 1_000, 5_000] {
            let dive = IOSDiveLogbookScalabilitySupport.makeSyntheticSessions(count: count)
            let diveData = try IOSDiveLogbookScalabilitySupport.encodeSessions(dive)
            let decodedDive = try IOSDiveLogbookScalabilitySupport.decodeSessions(from: diveData)
            XCTAssertEqual(decodedDive.count, count)

            let apnea = LogbookScalabilitySupport.makeSyntheticApneaSessions(count: count)
            let apneaData = try LogbookScalabilitySupport.encodeApneaSessions(apnea)
            let decodedApnea = try LogbookScalabilitySupport.decodeApneaSessions(from: apneaData)
            XCTAssertEqual(decodedApnea.count, count)

            let snorkeling = LogbookScalabilitySupport.makeSyntheticSnorkelingSessions(count: count)
            let snorkelingData = try LogbookScalabilitySupport.encodeSnorkelingSessions(snorkeling)
            let decodedSnorkeling = try LogbookScalabilitySupport.decodeSnorkelingSessions(from: snorkelingData)
            XCTAssertEqual(decodedSnorkeling.count, count)
        }
    }

    func testLogbookLoadBudgetSynthetic5000() throws {
        let sessions = IOSDiveLogbookScalabilitySupport.makeSyntheticSessions(count: 5_000)
        let data = try IOSDiveLogbookScalabilitySupport.encodeSessions(sessions)
        let budget = DIRPerformanceBudgets.entry(for: .logbookLoad)!
        let start = CFAbsoluteTimeGetCurrent()
        _ = try IOSDiveLogbookScalabilitySupport.decodeSessions(from: data)
        let elapsedMs = (CFAbsoluteTimeGetCurrent() - start) * 1_000
        XCTAssertLessThan(elapsedMs, budget.hardTestLimit)
    }

    func testLogbookSortAndFilterBounded() {
        let sessions = IOSDiveLogbookScalabilitySupport.makeSyntheticSessions(count: 1_000)
        let sorted = LogbookScalabilitySupport.sortedByDate(sessions) { $0.startDate }
        XCTAssertEqual(sorted.count, 1_000)
        let filtered = IOSDiveLogbookScalabilitySupport.filteredSessions(sessions, minimumDepth: 20)
        XCTAssertFalse(filtered.isEmpty)
        let rows = IOSDiveLogbookScalabilitySupport.lightweightRows(from: sessions)
        XCTAssertEqual(rows.count, 1_000)
    }

    func testSnorkelingRoutePresentationSamplingBounded() {
        var points: [SnorkelingTrackPoint] = []
        for index in 0..<50_000 {
            points.append(
                SnorkelingTrackPoint(
                    id: UUID(),
                    monotonicRelativeTimestampSeconds: Double(index),
                    wallClockTimestamp: Date(timeIntervalSince1970: Double(index)),
                    latitude: 44.0 + Double(index) * 0.00001,
                    longitude: 8.0 + Double(index) * 0.00001,
                    horizontalAccuracyMeters: 5,
                    gpsQuality: .measured,
                    depthMeters: 0,
                    isUnderwater: false
                )
            )
        }
        let downsampled = SnorkelingRoutePresentationSampling.downsampleTrackPointsForPresentation(points)
        XCTAssertLessThanOrEqual(downsampled.count, SnorkelingRoutePresentationSampling.maxMapPresentationCoordinates)
        XCTAssertEqual(downsampled.first?.latitude, points.first?.latitude)
        XCTAssertEqual(downsampled.last?.latitude, points.last?.latitude)
    }

    func testPlannerChartSnapshotsIgnoreUnrelatedUIState() async {
        PlannerChartSnapshots.resetTestHook()
        let store = PlannerStore()
        await store.testHook_flushDebouncedWork()
        let before = store.chartSnapshots
        let invalidationsBefore = PlannerChartSnapshots.testHook_invalidationCount
        store.scrollToCNSThresholdSettings = true
        store.acknowledgeCNSThresholdSettingsFocus()
        await Task.yield()
        XCTAssertEqual(store.chartSnapshots, before)
        XCTAssertEqual(PlannerChartSnapshots.testHook_invalidationCount, invalidationsBefore)
    }

    func testPlannerChartSnapshotsRebuildOnPlanRevision() async {
        PlannerChartSnapshots.resetTestHook()
        let store = PlannerStore()
        await store.testHook_flushDebouncedWork()
        let beforeGeneration = store.chartSnapshots.planningGeneration
        store.input.plannedDepthMeters = store.input.plannedDepthMeters + 1
        await store.testHook_flushDebouncedWork()
        XCTAssertGreaterThanOrEqual(store.chartSnapshots.planningGeneration, beforeGeneration)
    }

    func testPlannerRapidEditStressBounded() async {
        let store = PlannerStore()
        await store.testHook_flushDebouncedWork()
        var maxGeneration = store.testHook_planningGeneration
        for offset in 0..<100 {
            store.input.plannedDepthMeters = 30 + Double(offset % 5)
            await Task.yield()
            await Task.yield()
            maxGeneration = max(maxGeneration, store.testHook_planningGeneration)
        }
        await store.testHook_flushDebouncedWork()
        XCTAssertGreaterThan(maxGeneration, 0)
        XCTAssertFalse(store.isCalculating)
        XCTAssertFalse(store.chartSnapshots.ndlCurve.isEmpty)
    }

    func testGPSLifecyclePolicyInactiveAuthorizationDoesNotRestart() {
        GPSLifecyclePolicy.resetTestHook()
        XCTAssertFalse(
            GPSLifecyclePolicy.shouldRestartUpdatesAfterAuthorization(
                maintainsLocationUpdates: false,
                hasActiveBestEffortCapture: false
            )
        )
        XCTAssertTrue(
            GPSLifecyclePolicy.shouldRestartUpdatesAfterAuthorization(
                maintainsLocationUpdates: true,
                hasActiveBestEffortCapture: false
            )
        )
    }

    func testCSVImportBoundsEnforced() {
        XCTAssertEqual(DiveCSVImportBounds.maxBytes, 10 * 1_024 * 1_024)
        XCTAssertGreaterThan(DiveCSVImportBounds.maxRows, 0)
    }
}
