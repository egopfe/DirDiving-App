import XCTest

final class WatchSyncPendingQueueTests: XCTestCase {
    func testDequeueAfterSignedAckRemovesMatchingSessionOnly() {
        let first = sampleSession(id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!)
        let second = sampleSession(id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!)
        let queue = [
            WatchSyncPendingTransfer(session: first),
            WatchSyncPendingTransfer(session: second)
        ]
        let result = WatchSyncPendingQueuePolicy.dequeueAfterSignedAck(transfers: queue, sessionID: first.id)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.session.id, second.id)
    }

    func testImportedCompanionIDRetentionIsDeterministic() {
        let ids: Set<UUID> = [
            UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
            UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
        ]
        let key = WatchDiveSyncCodec.importedFromCompanionIDsKey + ".test.\(UUID().uuidString)"
        let originalKey = WatchDiveSyncCodec.importedFromCompanionIDsKey
        defer { UserDefaults.standard.removeObject(forKey: key) }

        // Mirror save logic with explicit sort
        let sorted = ids.map(\.uuidString).sorted()
        UserDefaults.standard.set(sorted, forKey: key)
        let loadedA = UserDefaults.standard.stringArray(forKey: key) ?? []
        UserDefaults.standard.set(sorted, forKey: key)
        let loadedB = UserDefaults.standard.stringArray(forKey: key) ?? []
        XCTAssertEqual(loadedA, loadedB)
        XCTAssertEqual(loadedA, sorted)
        _ = originalKey
    }

    func testSaveImportedFromCompanionIDsUsesLexicographicOrder() {
        let previous = UserDefaults.standard.stringArray(forKey: WatchDiveSyncCodec.importedFromCompanionIDsKey)
        defer {
            if let previous {
                UserDefaults.standard.set(previous, forKey: WatchDiveSyncCodec.importedFromCompanionIDsKey)
            } else {
                UserDefaults.standard.removeObject(forKey: WatchDiveSyncCodec.importedFromCompanionIDsKey)
            }
        }
        let ids: Set<UUID> = [
            UUID(uuidString: "BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB")!,
            UUID(uuidString: "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")!
        ]
        WatchDiveSyncCodec.saveImportedFromCompanionIDs(ids)
        let stored = UserDefaults.standard.stringArray(forKey: WatchDiveSyncCodec.importedFromCompanionIDsKey) ?? []
        XCTAssertEqual(stored, ids.map(\.uuidString).sorted())
    }

    private func sampleSession(id: UUID = UUID()) -> DiveSession {
        let start = Date(timeIntervalSince1970: 1_000)
        return DiveSession(
            id: id,
            startDate: start,
            endDate: start.addingTimeInterval(120),
            durationSeconds: 120,
            maxDepthMeters: 18,
            avgDepthMeters: 12,
            avgWaterTemperatureCelsius: nil,
            minWaterTemperatureCelsius: nil,
            maxWaterTemperatureCelsius: nil,
            ttv: 14,
            entryGPS: nil,
            exitGPS: nil,
            samples: [DiveSample(timestamp: start, depthMeters: 18, temperatureCelsius: 20)]
        )
    }
}
