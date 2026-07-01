import XCTest
@testable import DIRDivingiOSApp

final class DivingImportCommitterTests: XCTestCase {
    func testBuildPreviewRowsSkipsDuplicateSelectionByDefault() {
        let id = UUID()
        let session = makeSession(id: id)
        let candidate = makeCandidate(session: session)
        let preview = DivingImportPreviewResult(
            source: DivingImportSource(url: URL(fileURLWithPath: "/tmp/test.csv"), fileName: "test.csv", format: .subsurfaceCSV, fileSizeBytes: 100),
            candidates: [candidate],
            parseWarnings: [],
            skippedCount: 0
        )
        let rows = DivingImportDeduplicator.buildPreviewRows(from: preview, existingSessions: [session])
        XCTAssertEqual(rows.count, 1)
        XCTAssertFalse(rows[0].isSelected)
        if case .exactDuplicate = rows[0].duplicateStatus {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected duplicate status")
        }
    }

    func testCommitReportCountsFailedNonImportableCandidates() {
        let report = DivingImportCommitReport(
            importedCount: 0,
            skippedDuplicateCount: 1,
            failedCount: 2,
            warningsCount: 3,
            importedSessionIDs: []
        )
        XCTAssertEqual(report.failedCount, 2)
        XCTAssertEqual(report.skippedDuplicateCount, 1)
    }

    private func makeSession(id: UUID) -> DiveSession {
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        return DiveSession(
            id: id,
            startDate: start,
            endDate: start.addingTimeInterval(600),
            durationSeconds: 600,
            maxDepthMeters: 20,
            avgDepthMeters: 10,
            avgWaterTemperatureCelsius: 22,
            ttv: 8,
            entryGPS: nil,
            exitGPS: nil,
            samples: [
                DiveSample(timestamp: start, depthMeters: 0, temperatureCelsius: 22),
                DiveSample(timestamp: start.addingTimeInterval(600), depthMeters: 20, temperatureCelsius: 21)
            ]
        )
    }

    private func makeCandidate(session: DiveSession) -> DivingImportCandidate {
        DivingImportCandidate(
            id: UUID(),
            sourceFormat: .subsurfaceCSV,
            sourceFileName: "test.csv",
            sourceDiveID: nil,
            sourceComputerModel: nil,
            originalDiveNumber: nil,
            session: session,
            warnings: [],
            fingerprint: DivingImportFingerprint.make(from: session, sourceDiveID: nil, sourceComputerModel: nil),
            isImportable: true
        )
    }
}
