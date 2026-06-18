import XCTest

@MainActor
final class ApneaPlanRevisionIdempotencyTests: XCTestCase {
    override func setUp() {
        super.setUp()
        ApneaImportedPlanStore.shared.resetForTests()
    }

    override func tearDown() {
        ApneaImportedPlanStore.shared.resetForTests()
        super.tearDown()
    }

    func testSameRevisionSameChecksumIsIdempotent() throws {
        let package = try makePackage(revision: 3)
        importPlan(package, sessionInProgress: false)
        importPlan(package, sessionInProgress: false)
        XCTAssertEqual(ApneaImportedPlanStore.shared.activatedRevision, 3)
    }

    func testHigherRevisionReplacesLower() throws {
        let id = UUID()
        importPlan(try makePackage(revision: 2, packageID: id), sessionInProgress: false)
        importPlan(try makePackage(revision: 4, packageID: id), sessionInProgress: false)
        XCTAssertEqual(ApneaImportedPlanStore.shared.activatedRevision, 4)
    }

    func testLowerRevisionRejectedWhileActive() throws {
        let id = UUID()
        importPlan(try makePackage(revision: 5, packageID: id), sessionInProgress: false)
        importPlan(try makePackage(revision: 3, packageID: id), sessionInProgress: false)
        XCTAssertTrue(ApneaImportedPlanStore.shared.staleRevisionRejected)
        XCTAssertEqual(ApneaImportedPlanStore.shared.activatedRevision, 5)
    }

    func testPendingPlanNotActivatedMidSession() throws {
        importPlan(try makePackage(revision: 1), sessionInProgress: false)
        importPlan(try makePackage(revision: 2), sessionInProgress: true)
        XCTAssertEqual(ApneaImportedPlanStore.shared.activatedRevision, 1)
        XCTAssertTrue(ApneaImportedPlanStore.shared.hasPendingActivation)
    }

    private func makePackage(revision: Int, packageID: UUID = UUID()) throws -> ApneaSyncPackage {
        try ApneaSyncPackageBuilder.build(
            plan: ApneaSessionPlan(kind: .custom, title: "Rev", entries: [
                ApneaPlannedDiveEntry(orderIndex: 0, targetDepthMeters: 12, targetDurationSeconds: 45, plannedRecoverySeconds: 45)
            ]),
            profile: nil,
            settings: .default,
            packageID: packageID,
            revision: revision
        )
    }

    private func importPlan(_ package: ApneaSyncPackage, sessionInProgress: Bool) {
        guard let data = try? ApneaSyncCodec.encode(package) else { return XCTFail("encode") }
        let payload = ApneaSyncTransferSupport.makeTransferUserInfo(packageData: data, package: package)
        _ = ApneaSyncWatchReceiver.importPayload(payload, store: .shared, sessionInProgress: sessionInProgress)
    }
}
