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

    func testCSVRowLimitEnforcedDuringParse() {
        var rows = ["date,time,depth\n"]
        for index in 0..<(DiveCSVImportBounds.maxRows + 5) {
            rows.append("2024-01-01,12:00,\(index)\n")
        }
        let contents = rows.joined()
        XCTAssertNil(DiveImportService.testHook_parseCSV(contents))
    }

    func testTissueAnalyticsCacheBounded() {
        TissueAnalyticsService.invalidateCache()
        for index in 0..<36 {
            var input = GasPlanInput()
            input.plannedDepthMeters = 18 + Double(index % 6)
            input.plannedBottomMinutes = 25
            let plan = PlannerService.makePlan(input: input, mode: .base)
            _ = TissueAnalyticsService.presentationForPlanner(plan: plan, input: input, mode: .base)
        }
        XCTAssertLessThanOrEqual(TissueAnalyticsService.testHook_cacheEntryCount(), 32)
        TissueAnalyticsService.invalidateCache()
    }

    func testPlannerBackgroundFlushWithinBudget() async {
        let store = PlannerStore()
        let budget = DIRPerformanceBudgets.entry(for: .iosPlannerOCCalculation)!
        let start = CFAbsoluteTimeGetCurrent()
        await store.testHook_flushDebouncedWork()
        let elapsedMs = (CFAbsoluteTimeGetCurrent() - start) * 1_000
        XCTAssertLessThan(elapsedMs, budget.hardTestLimit)
        XCTAssertGreaterThan(store.chartSnapshots.planningGeneration, 0)
    }

    func testManualCalculateUsesBackgroundPipeline() async {
        let store = PlannerStore()
        await store.testHook_flushDebouncedWork()
        store.calculate()
        for _ in 0..<20 { await Task.yield() }
        try? await Task.sleep(nanoseconds: 800_000_000)
        XCTAssertFalse(store.isCalculating)
    }

    private func repositorySource(relativePath: String) throws -> String {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        return try String(contentsOf: root.appendingPathComponent(relativePath), encoding: .utf8)
    }

    func testLogbookViewUsesLazyRenderingStructure() throws {
        let source = try repositorySource(relativePath: "iOSApp/Views/LogbookView.swift")
        XCTAssertTrue(source.contains("LazyVStack"))
    }

    func testApneaRowPresentationUsesCachedStatistics() throws {
        let source = try repositorySource(relativePath: "iOSApp/Utils/IOSApneaLogbookPresentation.swift")
        XCTAssertTrue(source.contains("session.statistics"))
    }

    func testSnorkelingMapPresentationDownsamplesInBuilder() throws {
        let source = try repositorySource(relativePath: "Shared/Utils/SnorkelingSessionMapPresentation.swift")
        XCTAssertTrue(source.contains("downsampledMeasuredPoints"))
        XCTAssertTrue(source.contains("SnorkelingRoutePresentationSampling"))
    }

    func testSettingsLazyEnvironmentHostExists() throws {
        let source = try repositorySource(relativePath: "iOSApp/Views/Components/IOSCompanionSettingsEnvironmentHost.swift")
        XCTAssertTrue(source.contains("ensureApneaSettingsStore"))
        XCTAssertTrue(source.contains("ensureSnorkelingSettingsStore"))
    }

    func testWatchSyncFlushPolicyBoundsBatch() {
        struct Transfer {
            let id: UUID
            let lastAttemptAt: Date?
        }
        let transfers: [Transfer] = (0..<1_000).map { _ in Transfer(id: UUID(), lastAttemptAt: nil) }
        let eligible = WatchSyncPendingFlushPolicy.sessionsEligibleForSend(
            transfers: transfers,
            sessionID: { (transfer: Transfer) in transfer.id },
            lastAttemptAt: { (transfer: Transfer) in transfer.lastAttemptAt },
            inFlightSessionIDs: []
        )
        XCTAssertEqual(eligible.count, 1_000)
        let inFlight: Set<UUID> = [transfers[0].id]
        let throttled = WatchSyncPendingFlushPolicy.sessionsEligibleForSend(
            transfers: transfers,
            sessionID: { (transfer: Transfer) in transfer.id },
            lastAttemptAt: { (transfer: Transfer) in transfer.lastAttemptAt },
            inFlightSessionIDs: inFlight
        )
        XCTAssertEqual(throttled.count, 999)
    }
}
