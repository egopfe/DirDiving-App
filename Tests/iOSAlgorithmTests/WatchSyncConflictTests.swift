import XCTest

final class WatchSyncConflictTests: XCTestCase {
    private func session(id: UUID = UUID(), maxDepth: Double = 30, notes: String? = nil) -> DiveSession {
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        return DiveSession(
            id: id,
            startDate: start,
            endDate: start.addingTimeInterval(3600),
            durationSeconds: 3600,
            maxDepthMeters: maxDepth,
            avgDepthMeters: 18,
            avgWaterTemperatureCelsius: nil,
            ttv: 78,
            entryGPS: nil,
            exitGPS: nil,
            samples: [],
            notes: notes
        )
    }

    func testMetadataOnlyDifferenceIsNotSignificant() {
        let local = session(notes: "Local notes")
        var incoming = local
        incoming.notes = "Watch notes"
        XCTAssertFalse(WatchSyncSessionDiff.hasSignificantDifference(local: local, incoming: incoming))
    }

    func testDepthDifferenceIsSignificant() {
        let local = session()
        let incoming = session(id: local.id, maxDepth: 36)
        let differences = WatchSyncSessionDiff.significantDifferences(local: local, incoming: incoming)
        XCTAssertTrue(differences.contains(where: { $0.field == "maxDepthMeters" }))
    }

    func testBoundedIDStorePreservesRecentEntries() {
        var ids = Set<UUID>()
        for _ in 0..<600 {
            ids = WatchSyncBoundedIDStore.merge(UUID(), into: ids, maxCount: 512)
        }
        XCTAssertEqual(ids.count, 512)
    }

    func testImportedSessionIDOrderIsBounded() {
        let ids = Set((0..<600).map { _ in UUID() })
        WatchDiveSyncCodec.saveImportedSessionIDs(ids)
        let stored = WatchDiveSyncCodec.loadImportedSessionIDs()
        XCTAssertLessThanOrEqual(stored.count, WatchSyncBoundedIDStore.maxImportedSessionIDs)
    }

    func testSignedAckVerificationRejectsUnsignedOrWrongContextReplies() throws {
        WatchSyncTestSupport.installDeterministicSecrets()
        defer { WatchSyncTestSupport.resetSecrets() }
        WatchSyncTestSupport.requirePeerSecret()

        let sessionID = UUID()
        let issuedAt = Date(timeIntervalSince1970: 1_700_000_000)
        let signature = WatchDiveSyncCodec.ackSignature(sessionID: sessionID, issuedAt: issuedAt)

        XCTAssertFalse(signature.isEmpty)
        let wrongSessionID = UUID()
        XCTAssertTrue(WatchDiveSyncCodec.verifyAckSignature(signature, sessionID: sessionID, issuedAt: issuedAt))
        XCTAssertFalse(WatchDiveSyncCodec.verifyAckSignature("acknowledged", sessionID: sessionID, issuedAt: issuedAt))
        XCTAssertFalse(WatchDiveSyncCodec.verifyAckSignature(signature, sessionID: wrongSessionID, issuedAt: issuedAt))
        XCTAssertFalse(WatchDiveSyncCodec.verifyAckSignature(signature, sessionID: sessionID, issuedAt: issuedAt.addingTimeInterval(1)))
    }
}
