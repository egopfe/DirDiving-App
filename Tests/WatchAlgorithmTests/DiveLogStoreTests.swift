import XCTest

@MainActor
final class DiveLogStoreTests: XCTestCase {
    private var tempDirectory: URL!

    override func setUp() async throws {
        try await super.setUp()
        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("DiveLogStoreTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        DiveLogStore.testHook_storageDirectoryURL = tempDirectory
    }

    override func tearDown() async throws {
        DiveLogStore.testHook_storageDirectoryURL = nil
        try? FileManager.default.removeItem(at: tempDirectory)
        try await super.tearDown()
    }

    func testInvalidSessionIsRejectedAndNotPersisted() {
        let store = DiveLogStore()
        let start = Date()
        let invalid = DiveSession(
            startDate: start,
            endDate: start.addingTimeInterval(60),
            durationSeconds: 60,
            maxDepthMeters: 400,
            avgDepthMeters: 10,
            avgWaterTemperatureCelsius: nil,
            minWaterTemperatureCelsius: nil,
            maxWaterTemperatureCelsius: nil,
            ttv: 11,
            entryGPS: nil,
            exitGPS: nil,
            samples: [DiveSample(timestamp: start, depthMeters: 400, temperatureCelsius: nil)]
        )
        store.add(invalid)
        XCTAssertTrue(store.sessions.isEmpty)
        XCTAssertNotNil(store.loadErrorMessage)
    }

    func testValidSessionPersists() {
        let store = DiveLogStore()
        let start = Date()
        let valid = DiveSession(
            startDate: start,
            endDate: start.addingTimeInterval(60),
            durationSeconds: 60,
            maxDepthMeters: 12,
            avgDepthMeters: 10,
            avgWaterTemperatureCelsius: nil,
            minWaterTemperatureCelsius: nil,
            maxWaterTemperatureCelsius: nil,
            ttv: 11,
            entryGPS: nil,
            exitGPS: nil,
            samples: [DiveSample(timestamp: start, depthMeters: 12, temperatureCelsius: nil)],
            isManual: true,
            hasDepthProfile: false
        )
        store.add(valid)
        XCTAssertEqual(store.sessions.count, 1)
        XCTAssertNil(store.lastPersistenceError)
    }

    func testDeleteRemovesSessionAndRecordsTombstone() {
        let store = DiveLogStore()
        let start = Date()
        let valid = DiveSession(
            startDate: start,
            endDate: start.addingTimeInterval(60),
            durationSeconds: 60,
            maxDepthMeters: 12,
            avgDepthMeters: 10,
            avgWaterTemperatureCelsius: nil,
            minWaterTemperatureCelsius: nil,
            maxWaterTemperatureCelsius: nil,
            ttv: 11,
            entryGPS: nil,
            exitGPS: nil,
            samples: [DiveSample(timestamp: start, depthMeters: 12, temperatureCelsius: nil)],
            isManual: true,
            hasDepthProfile: false
        )
        store.add(valid)
        store.delete(id: valid.id)
        XCTAssertTrue(store.sessions.isEmpty)
        XCTAssertTrue(store.isDeleted(id: valid.id))
    }
}
