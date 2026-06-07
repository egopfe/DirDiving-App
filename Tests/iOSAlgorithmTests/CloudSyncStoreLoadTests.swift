import XCTest

@MainActor
final class CloudSyncStoreLoadTests: XCTestCase {
    private var defaults: UserDefaults!
    private var suiteName: String!

    override func setUp() {
        super.setUp()
        suiteName = "CloudSyncStoreLoadTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        suiteName = nil
        super.tearDown()
    }

    func testPrefersCloudPayloadWhenCloudModifiedAtIsNewer() {
        XCTAssertTrue(CloudSyncStore.prefersCloudPayload(localModifiedAt: 100, cloudModifiedAt: 200))
        XCTAssertFalse(CloudSyncStore.prefersCloudPayload(localModifiedAt: 200, cloudModifiedAt: 100))
        XCTAssertFalse(CloudSyncStore.prefersCloudPayload(localModifiedAt: 100, cloudModifiedAt: 100))
    }

    func testLoadLocalOnlyRoundTrip() throws {
        let key = "dirdiving_ios_dive_sessions"
        let session = makeSession(siteName: "Local Round Trip")
        let store = CloudSyncStore(defaults: defaults)
        store.save([session], forKey: key)

        let loaded = store.load([DiveSession].self, forKey: key)
        XCTAssertEqual(loaded?.first?.siteName, "Local Round Trip")
        XCTAssertNil(store.lastDecodeError)
    }

    func testMalformedLocalPayloadRecordsDecodeError() async {
        let key = "dirdiving_ios_dive_sessions"
        defaults.set(Data([0x00, 0x01, 0x02]), forKey: key)
        defaults.set(Date().timeIntervalSince1970, forKey: "\(key).__modifiedAt")

        let store = CloudSyncStore(defaults: defaults)
        let loaded = store.load([DiveSession].self, forKey: key)
        XCTAssertNil(loaded)
        try? await Task.sleep(nanoseconds: 50_000_000)
        XCTAssertNotNil(store.lastDecodeError)
    }

    func testRemoveValueClearsLocalPayload() throws {
        let key = "cloud.test.remove"
        struct Payload: Codable { let value: String }
        let store = CloudSyncStore(defaults: defaults)
        store.save(Payload(value: "x"), forKey: key)
        XCTAssertNotNil(defaults.data(forKey: key))

        store.removeValue(forKey: key)
        XCTAssertNil(defaults.data(forKey: key))
        XCTAssertNil(defaults.object(forKey: "\(key).__modifiedAt"))
    }

    func testLocalNewerModifiedAtIsNotPreferredOverCloudByPolicy() {
        XCTAssertFalse(CloudSyncStore.prefersCloudPayload(localModifiedAt: 500, cloudModifiedAt: 400))
    }

    private func makeSession(siteName: String? = nil) -> DiveSession {
        let start = Date(timeIntervalSince1970: 1_000)
        let end = start.addingTimeInterval(120)
        let samples = [
            DiveSample(timestamp: start, depthMeters: 0, temperatureCelsius: 20),
            DiveSample(timestamp: end, depthMeters: 18, temperatureCelsius: 20)
        ]
        let summary = DiveProfileMath.summary(samples: samples, startDate: start, endDate: end)
        return DiveSession(
            id: UUID(),
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
