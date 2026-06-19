import XCTest

final class SnorkelingDuplicateIgnoredImportTests: XCTestCase {
    func testDuplicateIgnoredWhenAlreadyImported() {
        let id = UUID()
        let session = SnorkelingSession(id: id, startMode: .watch, state: .completed)
        var importedIDs: Set<UUID> = [id]
        let outcome = SnorkelingSessionSyncImportPolicy.importSession(session, existingSessions: [], importedIDs: importedIDs)
        guard case .duplicateIgnored = outcome.result else {
            return XCTFail("expected duplicateIgnored")
        }
        XCTAssertNil(outcome.session)
    }

    func testRicherIncomingSessionMerges() {
        let id = UUID()
        let local = SnorkelingSession(
            id: id,
            startMode: .watch,
            state: .completed,
            dips: [SnorkelingDip(startedAtMonotonicSeconds: 0, durationSeconds: 30, maxDepthMeters: 3, averageDepthMeters: 2)]
        )
        var remote = local
        remote.dips.append(SnorkelingDip(startedAtMonotonicSeconds: 60, durationSeconds: 40, maxDepthMeters: 5, averageDepthMeters: 4))
        let outcome = SnorkelingSessionSyncImportPolicy.importSession(remote, existingSessions: [local], importedIDs: [])
        guard case .merged = outcome.result, let merged = outcome.session else {
            return XCTFail("expected merged")
        }
        XCTAssertEqual(merged.dips.count, 2)
    }

    @MainActor
    func testLogbookDuplicateIgnoredAfterPriorImport() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        IOSSnorkelingLogbookStore.testHook_storageDirectoryURL = directory
        defer {
            IOSSnorkelingLogbookStore.testHook_storageDirectoryURL = nil
            try? FileManager.default.removeItem(at: directory)
        }

        let store = IOSSnorkelingLogbookStore()
        store.resetImportedIDsForTesting()
        let session = SnorkelingSession(startMode: .watch, state: .completed)
        XCTAssertEqual(store.mergeImportedSession(session), .imported)
        store.delete(id: session.id)
        XCTAssertEqual(store.mergeImportedSession(session), .duplicateIgnored)
        XCTAssertTrue(store.sessions.isEmpty)
    }
}
