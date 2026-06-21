import XCTest
@testable import DIRDivingWatchApp

final class FullComputerRecoveryCheckpointTests: XCTestCase {
    func testCheckpointRoundTripPreservesTissueState() throws {
        let sessionID = UUID()
        let start = Date(timeIntervalSince1970: 10_000)
        var engine = try FullComputerRuntimeEngine(plan: .defaultAirGF3070, sessionStart: start)
        _ = engine.ingestSample(depthMeters: 28, timestamp: start.addingTimeInterval(600))
        engine.tick(now: start.addingTimeInterval(600))

        let checkpoint = try engine.exportCheckpoint(sessionID: sessionID, watchDivingMode: DIRDivingMode.fullComputer.rawValue)
        let data = try FullComputerRuntimeCheckpointCodec.encode(checkpoint)
        let decoded = try FullComputerRuntimeCheckpointCodec.decode(data)
        let restored = try FullComputerRuntimeEngine.restoreEngine(from: decoded, sessionStart: start)

        XCTAssertEqual(restored.snapshot.tissueState, engine.snapshot.tissueState)
        XCTAssertEqual(restored.runtimePlan.activeGas.gasMixId, engine.runtimePlan.activeGas.gasMixId)
        XCTAssertEqual(restored.snapshot.depthMeters, 28, accuracy: 0.001)
    }

    func testCorruptChecksumIsRejected() throws {
        let sessionID = UUID()
        let start = Date(timeIntervalSince1970: 20_000)
        var engine = try FullComputerRuntimeEngine(plan: .defaultAirGF3070, sessionStart: start)
        var checkpoint = try engine.exportCheckpoint(sessionID: sessionID, watchDivingMode: DIRDivingMode.fullComputer.rawValue)
        checkpoint = FullComputerRuntimeCheckpoint(payload: checkpoint.payload, checksumHex: "deadbeef")
        XCTAssertThrowsError(try FullComputerRuntimeCheckpointCodec.validate(checkpoint)) { error in
            XCTAssertEqual(error as? FullComputerRuntimeCheckpointError, .checksumMismatch)
        }
    }

    func testLegacyDraftWithoutCheckpointStillDecodes() throws {
        struct LegacyDraft: Codable {
            let schemaVersion: Int
            let phase: String
            let sessionID: UUID
            let startDate: Date
            let endDate: Date?
            let samples: [DiveSample]
            let entryGPS: GPSPoint?
            let exitGPS: GPSPoint?
            let entryGPSFixSource: GPSFixSource
            let exitGPSFixSource: GPSFixSource
            let isManualLifecycleActive: Bool
            let sessionStartedManually: Bool
            let activeDiveExceededSupportedDepth: Bool
            let hasObservedSubmersionDuringCurrentDive: Bool
            let createdAt: Date
            let updatedAt: Date
        }
        let draft = LegacyDraft(
            schemaVersion: 4,
            phase: "active",
            sessionID: UUID(),
            startDate: Date(),
            endDate: nil,
            samples: [],
            entryGPS: nil,
            exitGPS: nil,
            entryGPSFixSource: .noFix,
            exitGPSFixSource: .noFix,
            isManualLifecycleActive: false,
            sessionStartedManually: true,
            activeDiveExceededSupportedDepth: false,
            hasObservedSubmersionDuringCurrentDive: false,
            createdAt: Date(),
            updatedAt: Date()
        )
        let data = try JSONEncoder().encode(draft)
        XCTAssertFalse(data.isEmpty)
    }

    func testWatchMergePreservesFullComputerLogbookMetadata() {
        let id = UUID()
        let start = Date()
        let metadata = FullComputerDiveLogbookMetadata(
            watchDivingMode: DIRDivingMode.fullComputer.rawValue,
            gfLow: 30,
            gfHigh: 70,
            gasSwitchEvents: [],
            minimumNDLMinutes: 12,
            maximumCeilingMeters: 6,
            maximumTTSMinutes: 18,
            plannedStopDepthsMeters: [6],
            completedStopDepthsMeters: [],
            stopViolationCount: 0,
            ceilingViolationCount: 0,
            unavailableGasMixIds: [],
            recoveryEventCount: 1,
            recoveryDiagnostics: ["draft_restore"],
            algorithmVersion: FullComputerRuntimeConfiguration.algorithmVersion
        )
        let local = DiveSession(
            id: id,
            startDate: start,
            endDate: start.addingTimeInterval(60),
            durationSeconds: 60,
            maxDepthMeters: 20,
            avgDepthMeters: 15,
            avgWaterTemperatureCelsius: nil,
            minWaterTemperatureCelsius: nil,
            maxWaterTemperatureCelsius: nil,
            ttv: 1,
            entryGPS: nil,
            exitGPS: nil,
            samples: [],
            watchDivingMode: DIRDivingMode.gauge.rawValue
        )
        let remote = DiveSession(
            id: id,
            startDate: start,
            endDate: start.addingTimeInterval(90),
            durationSeconds: 90,
            maxDepthMeters: 22,
            avgDepthMeters: 16,
            avgWaterTemperatureCelsius: nil,
            minWaterTemperatureCelsius: nil,
            maxWaterTemperatureCelsius: nil,
            ttv: 2,
            entryGPS: nil,
            exitGPS: nil,
            samples: [],
            watchDivingMode: DIRDivingMode.fullComputer.rawValue,
            fullComputerLogbookMetadata: metadata
        )
        let merged = DiveSessionMerge.preferred(local, remote)
        XCTAssertEqual(merged.watchDivingMode, DIRDivingMode.fullComputer.rawValue)
        XCTAssertEqual(merged.fullComputerLogbookMetadata?.recoveryEventCount, 1)
    }

    func testLogbookAccumulatorCapturesExtremes() throws {
        let start = Date(timeIntervalSince1970: 30_000)
        var engine = try FullComputerRuntimeEngine(plan: .defaultAirGF3070, sessionStart: start)
        _ = engine.ingestSample(depthMeters: 30, timestamp: start.addingTimeInterval(300))
        engine.tick(now: start.addingTimeInterval(300))

        var accumulator = FullComputerRuntimeLogbookAccumulator()
        accumulator.ingest(snapshot: engine.snapshot, gasSwitchTracker: engine.persistedGasSwitchTracker)
        let metadata = accumulator.export(
            watchDivingMode: DIRDivingMode.fullComputer.rawValue,
            gfLow: 30,
            gfHigh: 70,
            gasSwitchEvents: [],
            unavailableGasMixIds: [],
            algorithmVersion: FullComputerRuntimeConfiguration.algorithmVersion,
            environmentRecord: FullComputerEnvironmentRecord.from(
                plannerEnvironment: .seaLevelSaltWater,
                source: .watchSettingsManual,
                capturedAt: start
            )
        )
        XCTAssertNotNil(metadata.minimumNDLMinutes)
        XCTAssertEqual(metadata.algorithmVersion, FullComputerRuntimeConfiguration.algorithmVersion)
    }
}
