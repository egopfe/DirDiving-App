import XCTest

@MainActor
final class SnorkelingWatchRuntimeStorePersistenceTests: XCTestCase {
    private let start = Date(timeIntervalSince1970: 1_700_000_000)

    override func setUp() {
        super.setUp()
        #if DEBUG
        SnorkelingWatchRuntimeStore.testHook_checkpointURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("snorkeling-runtime-checkpoint-\(UUID().uuidString).json")
        #endif
    }

    override func tearDown() {
        #if DEBUG
        if let url = SnorkelingWatchRuntimeStore.testHook_checkpointURL {
            try? FileManager.default.removeItem(at: url)
            try? FileManager.default.removeItem(at: url.appendingPathExtension("tmp"))
            let previous = url.deletingLastPathComponent()
                .appendingPathComponent(SnorkelingSessionCheckpointStore.previousCheckpointFileName)
            try? FileManager.default.removeItem(at: previous)
        }
        SnorkelingWatchRuntimeStore.testHook_checkpointURL = nil
        #endif
        super.tearDown()
    }

    func testRuntimeRestoresArmedSessionFromCheckpoint() {
        let first = SnorkelingWatchRuntimeStore()
        first.armSession(at: start)
        first.startSession(at: start)
        first.ingestDepthForTesting(depthMeters: 1.2, at: start.addingTimeInterval(2))
        first.persistCheckpointNowForTesting()

        let restored = SnorkelingWatchRuntimeStore()
        XCTAssertTrue(restored.isRecoveredSession)
        XCTAssertTrue(restored.isSessionActive)
        XCTAssertEqual(restored.presentationInput.dipCount, first.presentationInput.dipCount)
    }

    func testSaveCompletedSessionWritesLogbook() {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        SnorkelingLogbookStore.testHook_storageDirectoryURL = directory
        defer { SnorkelingLogbookStore.testHook_storageDirectoryURL = nil }

        let runtime = SnorkelingWatchRuntimeStore()
        let logbook = SnorkelingLogbookStore()
        runtime.armSession(at: start)
        runtime.startSession(at: start)
        runtime.ingestDepthForTesting(depthMeters: 0.8, at: start.addingTimeInterval(1))
        runtime.endSession(at: start.addingTimeInterval(10))
        XCTAssertTrue(runtime.saveCompletedSession(to: logbook))
        XCTAssertEqual(logbook.sessions.count, 1)
        runtime.resetAfterSave()
        XCTAssertFalse(runtime.isSessionActive)
    }
}
