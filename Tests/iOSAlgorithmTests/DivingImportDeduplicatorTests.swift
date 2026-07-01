import XCTest
@testable import DIRDivingiOSApp

final class DivingImportDeduplicatorTests: XCTestCase {
    func testSameSessionIDIsExactDuplicate() {
        let id = UUID()
        let session = makeSession(id: id)
        let candidate = makeCandidate(session: session)
        let status = DivingImportDeduplicator.classify(candidate: candidate, existingSessions: [session])
        if case .exactDuplicate(let existingID) = status {
            XCTAssertEqual(existingID, id)
        } else {
            XCTFail("Expected exact duplicate")
        }
    }

    func testDifferentSessionIsNew() {
        let existing = makeSession(id: UUID(), startOffset: 0)
        let candidate = makeCandidate(session: makeSession(id: UUID(), startOffset: 3_600))
        XCTAssertEqual(
            DivingImportDeduplicator.classify(candidate: candidate, existingSessions: [existing]),
            .new
        )
    }

    private func makeSession(id: UUID, startOffset: TimeInterval = 0) -> DiveSession {
        let start = Date(timeIntervalSince1970: 1_700_000_000 + startOffset)
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
