import XCTest

@MainActor
final class ApneaPlanPackageWatchNegativeTests: XCTestCase {
    override func setUp() {
        super.setUp()
        ApneaImportedPlanStore.shared.resetForTests()
    }

    override func tearDown() {
        ApneaImportedPlanStore.shared.resetForTests()
        super.tearDown()
    }

    func testFuturePlanSchemaRejectedWithoutPersistence() throws {
        var package = try makeValidPackage(revision: 1)
        package.body.schemaVersion = ApneaSyncCodec.currentSchemaVersion + 1
        package.payloadChecksumSHA256 = try ApneaSyncCodec.checksum(for: package.body)
        importRejected(package)
        XCTAssertNil(ApneaImportedPlanStore.shared.activatedRevision)
    }

    func testTruncatedPlanPackageIsRejectedWithoutReplacingPendingOrActivePlan() throws {
        let active = try makeValidPackage(revision: 10)
        importPlan(active, sessionInProgress: false)
        XCTAssertEqual(ApneaImportedPlanStore.shared.activatedRevision, 10)

        let truncatedPayload: [String: Any] = [
            ApneaSyncTransferSupport.transferTypeKey: ApneaSyncTransferSupport.transferTypePackage,
            ApneaSyncTransferSupport.packageIDKey: active.body.packageID.uuidString,
            ApneaSyncTransferSupport.revisionKey: active.body.revision,
            ApneaSyncTransferSupport.checksumKey: active.payloadChecksumSHA256,
            ApneaSyncTransferSupport.payloadBase64Key: Data("{".utf8).base64EncodedString(),
        ]
        _ = ApneaSyncWatchReceiver.importPayload(truncatedPayload, store: .shared, sessionInProgress: false)
        XCTAssertEqual(ApneaImportedPlanStore.shared.activatedRevision, 10)
    }

    func testCorruptPlanDoesNotReplaceActivePlan() throws {
        let active = try makeValidPackage(revision: 5)
        importPlan(active, sessionInProgress: false)

        var corrupt = try makeValidPackage(revision: 6, packageID: active.body.packageID)
        corrupt.payloadChecksumSHA256 = "deadbeef"
        importRejected(corrupt)
        XCTAssertEqual(ApneaImportedPlanStore.shared.activatedRevision, 5)
    }

    private func makeValidPackage(revision: Int, packageID: UUID = UUID()) throws -> ApneaSyncPackage {
        try ApneaSyncPackageBuilder.build(
            plan: ApneaSessionPlan(
                kind: .custom,
                title: "Watch plan",
                entries: [
                    ApneaPlannedDiveEntry(orderIndex: 0, targetDepthMeters: 20, targetDurationSeconds: 60, plannedRecoverySeconds: 60)
                ]
            ),
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

    private func importRejected(_ package: ApneaSyncPackage) {
        importPlan(package, sessionInProgress: false)
    }
}
