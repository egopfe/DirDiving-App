import XCTest

final class SnorkelingSessionSyncCodecTests: XCTestCase {
    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: SnorkelingSessionSyncCodec.importedSessionIDsKey)
    }

    func testSessionImportPolicyMergesByCompleteness() {
        let id = UUID()
        let local = SnorkelingSession(
            id: id,
            startMode: .watch,
            state: .completed,
            dips: [
                SnorkelingDip(
                    startedAtMonotonicSeconds: 0,
                    durationSeconds: 60,
                    maxDepthMeters: 4,
                    averageDepthMeters: 3
                )
            ]
        )
        var remote = local
        remote.dips = local.dips + [
            SnorkelingDip(
                startedAtMonotonicSeconds: 90,
                durationSeconds: 45,
                maxDepthMeters: 6,
                averageDepthMeters: 5
            )
        ]
        let outcome = SnorkelingSessionSyncImportPolicy.importSession(remote, existingSessions: [local], importedIDs: [])
        guard case .merged = outcome.result, let merged = outcome.session else {
            return XCTFail("Expected merged session")
        }
        XCTAssertEqual(merged.dips.count, 2)
    }

    @MainActor
    func testIOSLogbookAtomicImport() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        IOSSnorkelingLogbookStore.testHook_storageDirectoryURL = directory
        defer {
            IOSSnorkelingLogbookStore.testHook_storageDirectoryURL = nil
            try? FileManager.default.removeItem(at: directory)
        }

        let store = IOSSnorkelingLogbookStore()
        store.resetImportedIDsForTesting()
        let session = makeCompletedSession()
        let result = store.mergeImportedSession(session)
        XCTAssertEqual(result, .imported)
        XCTAssertEqual(store.sessions.count, 1)
        XCTAssertEqual(store.mergeImportedSession(session), .merged)
    }

    private func makeCompletedSession() -> SnorkelingSession {
        var session = SnorkelingSession(
            startMode: .watch,
            state: .completed,
            dips: [
                SnorkelingDip(
                    startedAtMonotonicSeconds: 0,
                    durationSeconds: 75,
                    maxDepthMeters: 5,
                    averageDepthMeters: 4
                )
            ]
        )
        session.statistics = session.refreshedStatistics()
        return session
    }
}
