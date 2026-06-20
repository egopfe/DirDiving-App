import XCTest

@MainActor
final class IOSActivityLogbookDataIsolationTests: XCTestCase {
    private var apneaDirectory: URL!
    private var snorkelingDirectory: URL!

    override func setUp() async throws {
        try await super.setUp()
        apneaDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("IOSLogbookApnea-\(UUID().uuidString)", isDirectory: true)
        snorkelingDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("IOSLogbookSnorkel-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: apneaDirectory, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: snorkelingDirectory, withIntermediateDirectories: true)
        IOSApneaLogbookStore.testHook_storageDirectoryURL = apneaDirectory
        IOSSnorkelingLogbookStore.testHook_storageDirectoryURL = snorkelingDirectory
    }

    override func tearDown() async throws {
        IOSApneaLogbookStore.testHook_storageDirectoryURL = nil
        IOSSnorkelingLogbookStore.testHook_storageDirectoryURL = nil
        try? FileManager.default.removeItem(at: apneaDirectory)
        try? FileManager.default.removeItem(at: snorkelingDirectory)
        try await super.tearDown()
    }

    func testDeletingApneaEntryDoesNotAffectSnorkeling() throws {
        let sharedID = UUID()
        let apneaStore = IOSApneaLogbookStore()
        let snorkelingStore = IOSSnorkelingLogbookStore()

        try apneaStore.replaceSessionsForTesting([makeApneaSession(id: sharedID)])
        try snorkelingStore.replaceSessionsForTesting([makeSnorkelingSession(id: sharedID)])

        try apneaStore.replaceSessionsForTesting([])

        XCTAssertNil(apneaStore.session(id: sharedID))
        XCTAssertNotNil(snorkelingStore.session(id: sharedID))
    }

    func testDeletingSnorkelingEntryDoesNotAffectApnea() throws {
        let sharedID = UUID()
        let apneaStore = IOSApneaLogbookStore()
        let snorkelingStore = IOSSnorkelingLogbookStore()

        try apneaStore.replaceSessionsForTesting([makeApneaSession(id: sharedID)])
        try snorkelingStore.replaceSessionsForTesting([makeSnorkelingSession(id: sharedID)])

        snorkelingStore.delete(id: sharedID)

        XCTAssertNotNil(apneaStore.session(id: sharedID))
        XCTAssertNil(snorkelingStore.session(id: sharedID))
    }

    func testDuplicateIDsAcrossApneaAndSnorkelingDoNotCollide() throws {
        let sharedID = UUID()
        let apneaStore = IOSApneaLogbookStore()
        let snorkelingStore = IOSSnorkelingLogbookStore()

        try apneaStore.replaceSessionsForTesting([makeApneaSession(id: sharedID)])
        try snorkelingStore.replaceSessionsForTesting([makeSnorkelingSession(id: sharedID)])

        snorkelingStore.delete(id: sharedID)

        XCTAssertNotNil(apneaStore.session(id: sharedID))
        XCTAssertNil(snorkelingStore.session(id: sharedID))
    }

    func testLogbookStoresUseSeparateStorageFiles() throws {
        let apneaPath = apneaDirectory.appendingPathComponent("dirdiving_ios_apnea_sessions.json").path
        let snorkelingPath = snorkelingDirectory.appendingPathComponent("dirdiving_ios_snorkeling_sessions.json").path
        let sharedID = UUID()
        try IOSApneaLogbookStore().replaceSessionsForTesting([makeApneaSession(id: sharedID)])
        try IOSSnorkelingLogbookStore().replaceSessionsForTesting([makeSnorkelingSession(id: sharedID)])
        XCTAssertTrue(FileManager.default.fileExists(atPath: apneaPath))
        XCTAssertTrue(FileManager.default.fileExists(atPath: snorkelingPath))
        XCTAssertNotEqual(apneaPath, snorkelingPath)
    }

    func testDivingLogbookUsesSeparateStorageKeyFromApneaAndSnorkeling() throws {
        let divingSource = try readSource("iOSApp/Services/DiveLogStore.swift")
        XCTAssertTrue(divingSource.contains("dirdiving_ios_dive_sessions"))
        XCTAssertFalse(divingSource.contains("dirdiving_ios_apnea_sessions.json"))
        XCTAssertFalse(divingSource.contains("dirdiving_ios_snorkeling_sessions.json"))
    }

    private func makeApneaSession(id: UUID) -> ApneaSession {
        ApneaSession(
            id: id,
            startMode: .watch,
            state: .completed,
            dives: [
                ApneaDive(startedAtMonotonicSeconds: 0, durationSeconds: 88, maxDepthMeters: 12, averageDepthMeters: 8)
            ]
        )
    }

    private func makeSnorkelingSession(id: UUID) -> SnorkelingSession {
        SnorkelingSession(
            id: id,
            startMode: .watch,
            state: .completed,
            trackPoints: [],
            dips: []
        )
    }

    private func readSource(_ relativePath: String) throws -> String {
        let url = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent(relativePath)
        return try String(contentsOf: url, encoding: .utf8)
    }
}
