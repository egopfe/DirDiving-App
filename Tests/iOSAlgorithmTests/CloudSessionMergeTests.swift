import XCTest

@MainActor
final class CloudSessionMergeTests: XCTestCase {
    private var defaults: UserDefaults!
    private var suiteName: String!

    override func setUp() {
        super.setUp()
        suiteName = "CloudSessionMergeTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        suiteName = nil
        super.tearDown()
    }

    func testRawLocalLoadDoesNotUseMergedCloudPayload() throws {
        let key = "dirdiving_ios_dive_sessions"
        let local = makeSession(siteName: "Local Site")
        let cloud = makeSession(id: local.id, siteName: "Cloud Site")
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        defaults.set(try encoder.encode([local]), forKey: key)
        let cloudSync = CloudSyncStore(defaults: defaults)
        let localSessions = decodeLocalSessions(from: cloudSync.loadRawLocalData(forKey: key), cloudSync: cloudSync)
        let cloudSessions = decodeCloudSessions(from: try encoder.encode([cloud]), cloudSync: cloudSync)

        XCTAssertEqual(localSessions.first?.siteName, "Local Site")
        XCTAssertEqual(cloudSessions.first?.siteName, "Cloud Site")
        XCTAssertNotEqual(localSessions.first?.siteName, cloudSessions.first?.siteName)
    }

    func testMergedSessionsUsesPreferredPolicy() {
        let id = UUID()
        let start = Date(timeIntervalSince1970: 1_000)
        let local = makeSession(id: id, start: start, siteName: "Local", endOffset: 120)
        let cloud = makeSession(id: id, start: start, siteName: "Cloud", endOffset: 180)
        let merged = mergedSessions(local: [local], cloud: [cloud])
        XCTAssertEqual(merged.first?.siteName, "Cloud")
    }

    func testMergeConflictDetectedForDivergentMetadata() {
        let id = UUID()
        let start = Date(timeIntervalSince1970: 1_000)
        let local = makeSession(id: id, start: start, siteName: "Local Reef", endOffset: 120)
        let cloud = makeSession(id: id, start: start, siteName: "Cloud Reef", endOffset: 120)
        let conflicts = DiveSessionMergeConflictDetector.detect(local: [local], cloud: [cloud])
        XCTAssertTrue(conflicts.contains { $0.fieldName == "siteName" })
    }

    func testTombstonesWinDuringSessionFilter() throws {
        let deletedID = UUID()
        let kept = makeSession(siteName: "Kept")
        let deleted = makeSession(id: deletedID, siteName: "Deleted")
        let merged = mergedSessions(local: [kept, deleted], cloud: nil)
            .filter { ![deletedID].contains($0.id) }
        XCTAssertEqual(merged.count, 1)
        XCTAssertEqual(merged.first?.siteName, "Kept")
    }

    func testRawCloudDecodeIsSeparateFromLocal() throws {
        let local = makeSession(siteName: "Local Only")
        let cloud = makeSession(siteName: "Cloud Only")
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let localData = try encoder.encode([local])
        let cloudData = try encoder.encode([cloud])

        let cloudSync = CloudSyncStore(defaults: defaults)
        let decodedLocal = try XCTUnwrap(cloudSync.decodeLocal([DiveSession].self, from: localData))
        let decodedCloud = try XCTUnwrap(cloudSync.decodeCloud([DiveSession].self, from: cloudData))
        XCTAssertEqual(decodedLocal.first?.siteName, "Local Only")
        XCTAssertEqual(decodedCloud.first?.siteName, "Cloud Only")
    }

    func testCloudSyncStoreCanRemoveLegacyFullSessionPayload() throws {
        let key = "dirdiving_ios_dive_sessions"
        let session = makeSession(siteName: "Legacy Defaults")
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        defaults.set(try encoder.encode([session]), forKey: key)

        let cloudSync = CloudSyncStore(defaults: defaults)
        XCTAssertNotNil(cloudSync.loadRawLocalData(forKey: key))

        cloudSync.removeValue(forKey: key)

        XCTAssertNil(cloudSync.loadRawLocalData(forKey: key))
    }

    private func decodeLocalSessions(from data: Data?, cloudSync: CloudSyncStore) -> [DiveSession] {
        guard let data else { return [] }
        return cloudSync.decodeLocal([DiveSession].self, from: data) ?? []
    }

    private func decodeCloudSessions(from data: Data?, cloudSync: CloudSyncStore) -> [DiveSession] {
        guard let data else { return [] }
        return cloudSync.decodeCloud([DiveSession].self, from: data) ?? []
    }

    private func mergedSessions(local: [DiveSession], cloud: [DiveSession]?) -> [DiveSession] {
        var byID: [UUID: DiveSession] = [:]
        for session in local {
            byID[session.id] = session
        }
        if let cloud {
            for session in cloud {
                if let existing = byID[session.id] {
                    byID[session.id] = DiveSessionMerge.preferred(existing, session)
                } else {
                    byID[session.id] = session
                }
            }
        }
        return IOSDiveLogbookPolicy.normalizeAndCap(Array(byID.values))
    }

    private func makeSession(
        id: UUID = UUID(),
        start: Date = Date(timeIntervalSince1970: 1_000),
        siteName: String? = nil,
        endOffset: TimeInterval = 120
    ) -> DiveSession {
        let end = start.addingTimeInterval(endOffset)
        let samples = [
            DiveSample(timestamp: start, depthMeters: 0, temperatureCelsius: 20),
            DiveSample(timestamp: end, depthMeters: 18, temperatureCelsius: 20)
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
            siteName: siteName
        )
    }
}
