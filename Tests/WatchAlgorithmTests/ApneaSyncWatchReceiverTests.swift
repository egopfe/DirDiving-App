import XCTest

@MainActor
final class ApneaSyncWatchReceiverTests: XCTestCase {
    override func setUp() {
        super.setUp()
        ApneaImportedPlanStore.shared.resetForTests()
    }

    override func tearDown() {
        ApneaImportedPlanStore.shared.resetForTests()
        super.tearDown()
    }

    func testImportActivatesPlanWhenIdle() throws {
        let package = try makePackage(revision: 1)
        let data = try ApneaSyncCodec.encode(package)
        let payload = ApneaSyncTransferSupport.makeTransferUserInfo(packageData: data, package: package)
        let ack = ApneaSyncWatchReceiver.importPayload(payload, store: .shared, sessionInProgress: false)
        XCTAssertNotNil(ack)
        XCTAssertEqual(ApneaImportedPlanStore.shared.activatedRevision, 1)
        XCTAssertEqual(ApneaImportedPlanStore.shared.readyPresentation.targetDepthMeters, 20)
    }

    func testStaleRevisionRejectedWithoutReplacingActivePlan() throws {
        let first = try makePackage(revision: 2)
        let firstData = try ApneaSyncCodec.encode(first)
        _ = ApneaSyncWatchReceiver.importPayload(
            ApneaSyncTransferSupport.makeTransferUserInfo(packageData: firstData, package: first),
            store: .shared,
            sessionInProgress: false
        )

        let stale = try makePackage(revision: 1, packageID: first.body.packageID)
        let staleData = try ApneaSyncCodec.encode(stale)
        let ack = ApneaSyncWatchReceiver.importPayload(
            ApneaSyncTransferSupport.makeTransferUserInfo(packageData: staleData, package: stale),
            store: .shared,
            sessionInProgress: false
        )
        XCTAssertNotNil(ack)
        XCTAssertTrue(ApneaImportedPlanStore.shared.staleRevisionRejected)
        XCTAssertEqual(ApneaImportedPlanStore.shared.activatedRevision, 2)
    }

    func testDuplicateChecksumIsIdempotent() throws {
        let package = try makePackage(revision: 4)
        let data = try ApneaSyncCodec.encode(package)
        let payload = ApneaSyncTransferSupport.makeTransferUserInfo(packageData: data, package: package)
        XCTAssertNotNil(ApneaSyncWatchReceiver.importPayload(payload, store: .shared, sessionInProgress: false))
        XCTAssertNotNil(ApneaSyncWatchReceiver.importPayload(payload, store: .shared, sessionInProgress: false))
        XCTAssertEqual(ApneaImportedPlanStore.shared.activatedRevision, 4)
    }

    func testSessionInProgressStoresPendingPlan() throws {
        let package = try makePackage(revision: 5)
        let data = try ApneaSyncCodec.encode(package)
        let payload = ApneaSyncTransferSupport.makeTransferUserInfo(packageData: data, package: package)
        XCTAssertNotNil(ApneaSyncWatchReceiver.importPayload(payload, store: .shared, sessionInProgress: true))
        XCTAssertNil(ApneaImportedPlanStore.shared.activatedRevision)
        XCTAssertTrue(ApneaImportedPlanStore.shared.hasPendingActivation)
        ApneaImportedPlanStore.shared.activatePendingIfNeeded(sessionInProgress: false)
        XCTAssertEqual(ApneaImportedPlanStore.shared.activatedRevision, 5)
    }

    private func makePackage(revision: Int, packageID: UUID = UUID()) throws -> ApneaSyncPackage {
        try ApneaSyncPackageBuilder.build(
            plan: ApneaSessionPlan(
                kind: .custom,
                title: "Watch plan",
                entries: [
                    ApneaPlannedDiveEntry(orderIndex: 0, targetDepthMeters: 20, targetDurationSeconds: 60, plannedRecoverySeconds: 60)
                ]
            ),
            profile: ApneaCompanionProfile(displayName: "Imported", discipline: .custom),
            settings: .default,
            packageID: packageID,
            revision: revision
        )
    }
}
