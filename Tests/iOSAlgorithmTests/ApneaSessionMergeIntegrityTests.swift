import XCTest

final class ApneaSessionMergeIntegrityTests: XCTestCase {
    func testIncomingRicherSessionWins() {
        let id = UUID()
        let local = ApneaSession(
            id: id,
            startMode: .watch,
            state: .completed,
            dives: [ApneaDive(startedAtMonotonicSeconds: 0, durationSeconds: 60, maxDepthMeters: 10, averageDepthMeters: 8)]
        )
        var remote = local
        remote.dives.append(ApneaDive(startedAtMonotonicSeconds: 120, durationSeconds: 75, maxDepthMeters: 15, averageDepthMeters: 12))
        let merged = ApneaSessionMerge.preferred(local, remote)
        XCTAssertEqual(merged.dives.count, 2)
    }

    func testExistingRicherSessionPreserved() {
        let id = UUID()
        var local = ApneaSession(
            id: id,
            startMode: .watch,
            state: .completed,
            dives: [
                ApneaDive(startedAtMonotonicSeconds: 0, durationSeconds: 60, maxDepthMeters: 10, averageDepthMeters: 8),
                ApneaDive(startedAtMonotonicSeconds: 120, durationSeconds: 75, maxDepthMeters: 15, averageDepthMeters: 12),
            ]
        )
        let remote = ApneaSession(
            id: id,
            startMode: .watch,
            state: .completed,
            dives: [ApneaDive(startedAtMonotonicSeconds: 0, durationSeconds: 60, maxDepthMeters: 10, averageDepthMeters: 8)]
        )
        let merged = ApneaSessionMerge.preferred(local, remote)
        XCTAssertEqual(merged.dives.count, 2)
    }

    func testWarningsPreservedAcrossMerge() {
        let id = UUID()
        var local = ApneaSession(id: id, startMode: .watch, state: .completed, dives: [])
        local.warnings = [.dataQualityDegraded]
        var remote = local
        remote.warnings = [.sparseSamples]
        let merged = ApneaSessionMerge.preferred(local, remote)
        XCTAssertTrue(merged.warnings.contains(.dataQualityDegraded))
        XCTAssertTrue(merged.warnings.contains(.sparseSamples))
    }

    @MainActor
    func testAtomicImportDuplicateSuppressed() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        IOSApneaLogbookStore.testHook_storageDirectoryURL = directory
        defer {
            IOSApneaLogbookStore.testHook_storageDirectoryURL = nil
            try? FileManager.default.removeItem(at: directory)
        }
        let store = IOSApneaLogbookStore()
        store.resetImportedIDsForTesting()
        var session = ApneaSession(
            startMode: .watch,
            state: .completed,
            dives: [ApneaDive(startedAtMonotonicSeconds: 0, durationSeconds: 90, maxDepthMeters: 18, averageDepthMeters: 12)]
        )
        session.statistics = session.refreshedStatistics()
        XCTAssertEqual(store.mergeImportedSession(session), .imported)
        XCTAssertEqual(store.mergeImportedSession(session), .merged)
        XCTAssertEqual(store.sessions.count, 1)
    }
}
