import XCTest

final class FullComputerNamespaceIsolationTests: XCTestCase {
    override func setUp() {
        super.setUp()
        MainActor.assumeIsolated {
            FullComputerImportedPlanStore.shared.resetForTests()
            ApneaImportedPlanStore.shared.resetForTests()
        }
    }

    override func tearDown() {
        MainActor.assumeIsolated {
            FullComputerImportedPlanStore.shared.resetForTests()
            ApneaImportedPlanStore.shared.resetForTests()
        }
        super.tearDown()
    }

    func testApneaTransferTypeDoesNotRouteToFCReceiver() {
        XCTAssertFalse(DivePlanPackageTransferSupport.isPackageTransfer(["transferType": "apneaSyncPlanPackage"]))
    }

    func testFCTransferTypeRecognized() {
        XCTAssertTrue(DivePlanPackageTransferSupport.isPackageTransfer(["transferType": "fullComputerPlanPackage"]))
    }

    func testApneaACKDoesNotParseAsFCAck() {
        let payload: [String: Any] = [
            "transferType": "apneaSyncPlanPackageAck",
            DivePlanPackageTransferSupport.planIDKey: UUID().uuidString,
            DivePlanPackageTransferSupport.revisionKey: 1,
            DivePlanPackageTransferSupport.checksumKey: "abc",
            DivePlanPackageTransferSupport.ackStatusKey: "imported",
            DivePlanPackageTransferSupport.issuedAtKey: Date().timeIntervalSince1970,
        ]
        XCTAssertNil(DivePlanPackageTransferSupport.parseAck(payload))
    }

    func testFCACKParsesWithinSkew() throws {
        let planID = UUID()
        let issuedAt = Date()
        let signature = DivePlanPackageAckSigner.makeSignature(
            planID: planID,
            revision: 2,
            checksum: "checksum",
            issuedAt: issuedAt
        )
        let payload = DivePlanPackageTransferSupport.makeAckPayload(
            planID: planID,
            revision: 2,
            checksum: "checksum",
            status: DivePlanPackageTransferSupport.ackStatusImported,
            issuedAt: issuedAt,
            signature: signature
        )
        let parsed = DivePlanPackageTransferSupport.parseAck(payload)
        XCTAssertEqual(parsed?.planID, planID)
        XCTAssertEqual(parsed?.revision, 2)
    }

    func testACKOutsideClockSkewRejected() {
        let planID = UUID()
        let issuedAt = Date().addingTimeInterval(-600)
        let payload: [String: Any] = [
            DivePlanPackageTransferSupport.transferTypeKey: DivePlanPackageTransferSupport.transferTypeAck,
            DivePlanPackageTransferSupport.planIDKey: planID.uuidString,
            DivePlanPackageTransferSupport.revisionKey: 1,
            DivePlanPackageTransferSupport.checksumKey: "checksum",
            DivePlanPackageTransferSupport.ackStatusKey: DivePlanPackageTransferSupport.ackStatusImported,
            DivePlanPackageTransferSupport.issuedAtKey: issuedAt.timeIntervalSince1970,
        ]
        XCTAssertNil(DivePlanPackageTransferSupport.parseAck(payload))
    }

    func testApplicationContextKeysDoNotCollideWithApnea() {
        XCTAssertEqual(DivePlanPackageTransferSupport.applicationContextSnapshotKey, "dirdiving_fc_plan_snapshot")
        XCTAssertNotEqual(DivePlanPackageTransferSupport.applicationContextSnapshotKey, "dirdiving_apnea_session")
    }

    func testPendingStoreKeysAreSeparate() {
        XCTAssertNotEqual(FullComputerImportedPlanStore.pendingKey, ApneaImportedPlanStore.pendingKey)
        XCTAssertNotEqual(FullComputerImportedPlanStore.activatedKey, ApneaImportedPlanStore.activatedKey)
        XCTAssertNotEqual(FullComputerImportedPlanStore.importedChecksumsKey, ApneaImportedPlanStore.importedChecksumsKey)
    }

    @MainActor
    func testFCAndApneaStoresRemainIndependent() throws {
        FullComputerImportedPlanStore.shared.resetForTests()
        ApneaImportedPlanStore.shared.resetForTests()
        let fcPackage = try DivePlanPackageCodec.seal(
            DivePlanPackageBody(
                schemaVersion: 1,
                algorithmVersion: DivePlanPackageCodec.algorithmVersion,
                planID: UUID(),
                revision: 1,
                createdAt: Date(),
                expiresAt: Date().addingTimeInterval(3600),
                environment: DivePlanEnvironmentPayload(altitudeMeters: 0, salinityRaw: SalinityMode.salt.rawValue),
                gfLow: 30,
                gfHigh: 70,
                gases: [
                    DivePlanGasPayload(name: "Air", role: .bottom, oxygenFraction: 0.21, heliumFraction: 0, maxPPO2Bar: 1.4)
                ],
                bottomSegments: [DivePlanBottomSegmentPayload(depthMeters: 20, durationMinutes: 15, order: 0)],
                plannedSwitches: [],
                plannerSummary: DivePlanSummaryPayload(
                    modeLabel: "Deco",
                    planKind: "single",
                    maxDepthMeters: 20,
                    bottomMinutes: 15,
                    totalRuntimeMinutes: 25,
                    requiresDeco: false,
                    decoStopCount: 0
                ),
                capabilities: .current
            )
        )
        XCTAssertTrue(FullComputerImportedPlanStore.shared.importPayload(fcPackage, source: "test"))
        let apnea = try ApneaSyncPackageBuilder.build(
            plan: ApneaSessionPlan(
                kind: .custom,
                title: "A",
                entries: [
                    ApneaPlannedDiveEntry(orderIndex: 0, targetDepthMeters: 10, targetDurationSeconds: 60, plannedRecoverySeconds: 60)
                ]
            ),
            profile: ApneaCompanionProfile(displayName: "P", discipline: .custom),
            settings: .default,
            packageID: UUID(),
            revision: 1
        )
        XCTAssertTrue(ApneaImportedPlanStore.shared.importPayload(apnea, source: "test", sessionInProgress: true))
        XCTAssertTrue(FullComputerImportedPlanStore.shared.hasPendingActivation)
        XCTAssertTrue(ApneaImportedPlanStore.shared.hasPendingActivation)
    }
}
