import XCTest

final class SnorkelingCrossDomainIsolationTests: XCTestCase {
    private let snorkelingRuntimePaths = SnorkelingArchitectureIsolation.productionSourcePaths

    func testSnorkelingRuntimeDoesNotReferenceDiveManager() throws {
        try assertNoSymbol("DiveManager")
    }

    func testSnorkelingRuntimeDoesNotReferenceApneaSessionEngine() throws {
        try assertNoSymbol("ApneaSessionEngine")
    }

    func testSnorkelingRuntimeDoesNotReferenceFullComputerRuntime() throws {
        try assertNoSymbol("FullComputerRuntimeEngine")
    }

    func testSnorkelingRuntimeDoesNotReferenceExplorationStore() throws {
        try assertNoSymbol("ExplorationStore")
    }

    func testSnorkelingNamespacesDoNotCollideWithExistingDomains() {
        let checkpointKey = "dirdiving_snorkeling_session"
        let sessionSyncKey = SnorkelingSessionSyncCodec.payloadKey
        XCTAssertNotEqual(checkpointKey, ApneaReleaseSelfCheck.apneaSessionPayloadKey)
        XCTAssertNotEqual(checkpointKey, ApneaReleaseSelfCheck.diveSessionPayloadKey)
        XCTAssertNotEqual(sessionSyncKey, ApneaReleaseSelfCheck.apneaSessionPayloadKey)
        XCTAssertNotEqual(sessionSyncKey, ApneaReleaseSelfCheck.diveSessionPayloadKey)
        XCTAssertNotEqual(sessionSyncKey, checkpointKey)
        XCTAssertNotEqual(sessionSyncKey, ApneaReleaseSelfCheck.apneaPlanTransferType)
        XCTAssertNotEqual(sessionSyncKey, ApneaReleaseSelfCheck.fullComputerPlanTransferType)
    }

    func testSharedDepthFeedUsesNamespacedConfiguration() {
        XCTAssertNotEqual(
            DepthMeasurementFeedConfiguration.snorkelingDefault.maximumPlausibleDepthMeters,
            DepthMeasurementFeedConfiguration.apneaDefault.maximumPlausibleDepthMeters
        )
        XCTAssertEqual(DepthMeasurementFeedConfiguration.snorkelingDefault.maximumPlausibleDepthMeters, 25)
    }

    private func assertNoSymbol(_ symbol: String) throws {
        let violations = try SnorkelingArchitectureIsolation.violations(inRepositoryRoot: repositoryRoot())
        XCTAssertFalse(violations.contains(where: { $0.symbol == symbol }), violations.description)
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}

private extension Array where Element == SnorkelingArchitectureIsolation.Violation {
    var description: String {
        map { "\($0.file): \($0.symbol)" }.joined(separator: ", ")
    }
}
