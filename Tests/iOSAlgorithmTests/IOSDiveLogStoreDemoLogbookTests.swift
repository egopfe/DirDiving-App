import XCTest

@MainActor
final class IOSDiveLogStoreDemoLogbookTests: XCTestCase {
    private var tempDirectory: URL!
    private var defaults: UserDefaults!
    private var watchTransfers: [UUID]!

    override func setUp() {
        super.setUp()
        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("IOSDiveLogStoreDemoLogbookTests-\(UUID().uuidString)", isDirectory: true)
        try? FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        defaults = UserDefaults(suiteName: "IOSDiveLogStoreDemoLogbookTests")!
        defaults.removePersistentDomain(forName: "IOSDiveLogStoreDemoLogbookTests")
        watchTransfers = []
        DiveLogStore.testHook_storageDirectoryURL = tempDirectory
        DiveLogStore.testHook_userDefaults = defaults
        DiveLogStore.testHook_skipInitialLoad = true
        DiveLogStore.testHook_recordWatchTransfer = { [weak self] session in
            self?.watchTransfers.append(session.id)
        }
    }

    override func tearDown() {
        DiveLogStore.testHook_storageDirectoryURL = nil
        DiveLogStore.testHook_userDefaults = nil
        DiveLogStore.testHook_skipInitialLoad = false
        DiveLogStore.testHook_recordWatchTransfer = nil
        defaults.removePersistentDomain(forName: "IOSDiveLogStoreDemoLogbookTests")
        tempDirectory = nil
        defaults = nil
        watchTransfers = nil
        super.tearDown()
    }

    func testEnablingDemoLogbookInsertsWhenEmpty() {
        let store = makeStore(includeDemo: false)
        store.testing_finishInitialLoad(with: [])

        store.includeDemoLogbook = true

        XCTAssertEqual(demoSessions(in: store).count, DemoDiveCatalog.sessionIDs.count)
        XCTAssertTrue(demoSessions(in: store).allSatisfy(\.isDemoDive))
    }

    func testEnablingDemoLogbookInsertsWhenRealDivesExist() {
        let real = makeRealSession(id: UUID(uuidString: "A1111111-1111-4111-8111-111111111111")!)
        let store = makeStore(includeDemo: false)
        store.testing_finishInitialLoad(with: [real])

        store.includeDemoLogbook = true

        XCTAssertEqual(store.sessions.count, 1 + DemoDiveCatalog.sessionIDs.count)
        XCTAssertTrue(store.sessions.contains { $0.id == real.id })
        XCTAssertEqual(demoSessions(in: store).count, DemoDiveCatalog.sessionIDs.count)
    }

    func testEnablingDemoLogbookPreservesExistingRealDives() {
        let real = makeRealSession(id: UUID(uuidString: "B2222222-2222-4222-8222-222222222222")!)
        let store = makeStore(includeDemo: false)
        store.testing_finishInitialLoad(with: [real])
        let realBefore = store.session(id: real.id)

        store.includeDemoLogbook = true

        XCTAssertEqual(store.session(id: real.id), realBefore)
        XCTAssertFalse(store.sessions.contains { !$0.isDemoDive && $0.id != real.id })
    }

    func testEnablingDemoLogbookTwiceDoesNotDuplicateDemoDives() {
        let store = makeStore(includeDemo: false)
        store.testing_finishInitialLoad(with: [makeRealSession()])

        store.includeDemoLogbook = true
        let countAfterFirst = store.sessions.count
        store.includeDemoLogbook = true

        XCTAssertEqual(store.sessions.count, countAfterFirst)
        XCTAssertEqual(demoSessions(in: store).count, DemoDiveCatalog.sessionIDs.count)
    }

    func testDisablingDemoLogbookRemovesOnlyDemoDives() {
        let real = makeRealSession()
        let store = makeStore(includeDemo: true)
        store.testing_finishInitialLoad(with: [real])
        store.includeDemoLogbook = true
        XCTAssertGreaterThan(demoSessions(in: store).count, 0)

        store.includeDemoLogbook = false

        XCTAssertTrue(demoSessions(in: store).isEmpty)
        XCTAssertEqual(store.sessions.map(\.id), [real.id])
    }

    func testDemoInsertionDoesNotPushToWatch() {
        let store = makeStore(includeDemo: false)
        store.testing_finishInitialLoad(with: [makeRealSession()])

        store.includeDemoLogbook = true

        XCTAssertTrue(watchTransfers.isEmpty)
    }

    func testInitialLoadWithDemoEnabledAndRealSessionsAddsMissingDemos() async {
        defaults.set(true, forKey: DiveLogStore.includeDemoLogbookKey)
        DiveLogStore.testHook_skipInitialLoad = false
        let real = makeRealSession()
        persistProtectedSessions([real])

        let store = DiveLogStore()
        await store.loadIfNeeded()

        XCTAssertTrue(store.sessions.contains { $0.id == real.id })
        XCTAssertEqual(demoSessions(in: store).count, DemoDiveCatalog.sessionIDs.count)
    }

    func testReloadFromCloudReappliesDemoPreferenceIdempotently() {
        defaults.set(true, forKey: DiveLogStore.includeDemoLogbookKey)
        let real = makeRealSession()
        let store = makeStore(includeDemo: true)
        store.testing_finishInitialLoad(with: [real])
        store.includeDemoLogbook = true
        persistProtectedSessions(store.sessions.filter { !$0.isDemoDive })

        store.testing_reloadFromCloud()

        XCTAssertTrue(store.sessions.contains { $0.id == real.id })
        XCTAssertEqual(demoSessions(in: store).count, DemoDiveCatalog.sessionIDs.count)
        XCTAssertEqual(Set(demoSessions(in: store).map(\.id)), DemoDiveCatalog.idSet)
    }

    func testDemoSessionsUseCatalogIDsAndDemoFlag() {
        let store = makeStore(includeDemo: false)
        store.testing_finishInitialLoad(with: [])
        store.includeDemoLogbook = true

        XCTAssertEqual(Set(demoSessions(in: store).map(\.id)), DemoDiveCatalog.idSet)
        XCTAssertTrue(demoSessions(in: store).allSatisfy(\.isDemo))
    }

    private func makeStore(includeDemo: Bool) -> DiveLogStore {
        defaults.set(includeDemo, forKey: DiveLogStore.includeDemoLogbookKey)
        return DiveLogStore()
    }

    private func demoSessions(in store: DiveLogStore) -> [DiveSession] {
        store.sessions.filter(\.isDemoDive)
    }

    private func persistProtectedSessions(_ sessions: [DiveSession]) {
        let url = tempDirectory.appendingPathComponent("dirdiving_ios_dive_sessions.json")
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys]
        let data = try! encoder.encode(sessions)
        try! data.write(to: url, options: .atomic)
    }

    private func makeRealSession(id: UUID = UUID()) -> DiveSession {
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        let end = start.addingTimeInterval(2_400)
        let samples = [
            DiveSample(timestamp: start, depthMeters: 0, temperatureCelsius: 20),
            DiveSample(timestamp: end, depthMeters: 24, temperatureCelsius: 19),
        ]
        let summary = DiveProfileMath.summary(samples: samples, startDate: start, endDate: end)
        return DiveSession(
            id: id,
            startDate: start,
            endDate: end,
            durationSeconds: summary.durationSeconds,
            maxDepthMeters: summary.maxDepthMeters,
            avgDepthMeters: summary.averageDepthMeters,
            avgWaterTemperatureCelsius: summary.averageTemperatureCelsius,
            ttv: summary.ttv,
            entryGPS: nil,
            exitGPS: nil,
            samples: samples,
            siteName: "Real imported dive",
            isDemo: false
        )
    }
}
