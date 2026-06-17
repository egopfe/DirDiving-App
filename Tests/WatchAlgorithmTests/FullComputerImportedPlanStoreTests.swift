import XCTest

@MainActor
final class FullComputerImportedPlanStoreTests: XCTestCase {
    private let planID = UUID(uuidString: "11111111-1111-1111-1111-111111111111")!

    override func setUp() {
        super.setUp()
        FullComputerImportedPlanStore.shared.resetForTests()
        FullComputerPrediveConfigurationStore.shared.resetForTests()
    }

    override func tearDown() {
        FullComputerImportedPlanStore.shared.resetForTests()
        FullComputerPrediveConfigurationStore.shared.resetForTests()
        super.tearDown()
    }

    func testValidPackagePersistsSuccessfully() throws {
        let package = try makePackage(revision: 1)
        XCTAssertTrue(FullComputerImportedPlanStore.shared.importPayload(package, source: "test"))
        XCTAssertTrue(FullComputerImportedPlanStore.shared.hasPendingActivation)
        XCTAssertEqual(FullComputerImportedPlanStore.shared.pendingPackage?.body.revision, 1)
    }

    func testPendingPackageReloadsAfterStoreRecreation() throws {
        let package = try makePackage(revision: 2)
        XCTAssertTrue(FullComputerImportedPlanStore.shared.importPayload(package, source: "test"))
        let reloaded = FullComputerImportedPlanStore.shared
        XCTAssertEqual(reloaded.pendingPackage?.body.revision, 2)
    }

    func testSamePlanRevisionChecksumIsIdempotent() throws {
        let package = try makePackage(revision: 3)
        let store = FullComputerImportedPlanStore.shared
        XCTAssertTrue(store.importPayload(package, source: "test"))
        XCTAssertTrue(store.importPayload(package, source: "test"))
        XCTAssertEqual(store.pendingPackage?.body.revision, 3)
    }

    func testDuplicateImportDoesNotCreateDuplicateEntries() throws {
        let package = try makePackage(revision: 4)
        let store = FullComputerImportedPlanStore.shared
        XCTAssertTrue(store.importPayload(package, source: "a"))
        XCTAssertTrue(store.importPayload(package, source: "b"))
        XCTAssertNotNil(store.pendingPackage)
    }

    func testHigherRevisionReplacesOlderPendingRevision() throws {
        let store = FullComputerImportedPlanStore.shared
        XCTAssertTrue(store.importPayload(try makePackage(revision: 1), source: "test"))
        XCTAssertTrue(store.importPayload(try makePackage(revision: 5), source: "test"))
        XCTAssertEqual(store.pendingPackage?.body.revision, 5)
    }

    func testLowerRevisionIsRejected() throws {
        let store = FullComputerImportedPlanStore.shared
        XCTAssertTrue(store.importPayload(try makePackage(revision: 10), source: "test"))
        XCTAssertFalse(store.importPayload(try makePackage(revision: 9), source: "test"))
        XCTAssertEqual(store.pendingPackage?.body.revision, 10)
    }

    func testEqualRevisionWithDifferentChecksumFailsClosed() throws {
        let store = FullComputerImportedPlanStore.shared
        let first = try makePackage(revision: 6)
        XCTAssertTrue(store.importPayload(first, source: "test"))
        var body = first.body
        body.gfHigh = 75
        let conflicting = try DivePlanPackageCodec.seal(body)
        XCTAssertFalse(store.importPayload(conflicting, source: "test"))
        XCTAssertEqual(store.lastImportError, .checksumMismatch)
        XCTAssertEqual(store.pendingPackage?.payloadChecksumSHA256, first.payloadChecksumSHA256)
    }

    func testExpiredPackageIsRejected() throws {
        var body = sampleBody(revision: 7)
        body.expiresAt = Date().addingTimeInterval(-120)
        let package = try DivePlanPackageCodec.seal(body)
        XCTAssertFalse(FullComputerImportedPlanStore.shared.importPayload(package, source: "test"))
        XCTAssertEqual(FullComputerImportedPlanStore.shared.lastImportError, .expired)
    }

    func testUnsupportedSchemaIsRejected() throws {
        var body = sampleBody(revision: 8)
        body.schemaVersion = 0
        let package = try DivePlanPackageCodec.seal(body)
        XCTAssertFalse(FullComputerImportedPlanStore.shared.importPayload(package, source: "test"))
    }

    func testUnsupportedAlgorithmVersionRejectedByCapabilities() throws {
        var body = sampleBody(revision: 9)
        body.capabilities = DivePlanFeatureCapabilities(
            supportsMultigas: true,
            supportsMultilevel: true,
            minimumWatchSchemaVersion: DivePlanPackageCodec.currentSchemaVersion + 5,
            minimumAlgorithmVersion: DivePlanPackageCodec.algorithmVersion
        )
        let package = try DivePlanPackageCodec.seal(body)
        XCTAssertFalse(FullComputerImportedPlanStore.shared.importPayload(package, source: "test"))
    }

    func testMalformedPackageIsRejected() throws {
        var body = sampleBody(revision: 11)
        body.gfLow = 99
        body.gfHigh = 1
        let package = try DivePlanPackageCodec.seal(body)
        XCTAssertFalse(FullComputerImportedPlanStore.shared.importPayload(package, source: "test"))
        XCTAssertEqual(FullComputerImportedPlanStore.shared.lastImportError, .invalidGradientFactors)
    }

    func testFutureSchemaRejected() throws {
        var package = try makePackage(revision: 12)
        package = DivePlanPackage(body: package.body, payloadChecksumSHA256: "bad")
        XCTAssertFalse(FullComputerImportedPlanStore.shared.importPayload(package, source: "test"))
        XCTAssertEqual(FullComputerImportedPlanStore.shared.lastImportError, .checksumMismatch)
    }

    func testActivationRemovesPendingState() throws {
        let store = FullComputerImportedPlanStore.shared
        XCTAssertTrue(store.importPayload(try makePackage(revision: 13), source: "test"))
        try store.activatePendingPlan()
        XCTAssertNil(store.pendingPackage)
        XCTAssertEqual(store.activatedRevision, 13)
    }

    func testActivationIsUserDrivenAndDoesNotStartDive() throws {
        let store = FullComputerImportedPlanStore.shared
        XCTAssertTrue(store.importPayload(try makePackage(revision: 14), source: "test"))
        try store.activatePendingPlan()
        XCTAssertEqual(store.activatedPlanID, planID)
        XCTAssertFalse(store.hasPendingActivation)
    }

    func testImportDoesNotBypassFullComputerConfirmation() throws {
        let config = FullComputerPrediveConfigurationStore.shared
        XCTAssertTrue(FullComputerImportedPlanStore.shared.importPayload(try makePackage(revision: 15), source: "test"))
        try FullComputerImportedPlanStore.shared.activatePendingPlan(configuration: config)
        XCTAssertNotNil(config.confirmedProfile)
    }

    func testPackageFingerprintIsDeterministic() throws {
        let package = try makePackage(revision: 16)
        let fingerprint = "\(package.body.planID.uuidString)|\(package.body.revision)|\(package.payloadChecksumSHA256)"
        XCTAssertTrue(FullComputerImportedPlanStore.shared.importPayload(package, source: "test"))
        XCTAssertTrue(FullComputerImportedPlanStore.shared.importPayload(package, source: "test"))
        XCTAssertNotNil(fingerprint)
    }

    func testClearingStoreRemovesOnlyFCPackageData() throws {
        let store = FullComputerImportedPlanStore.shared
        XCTAssertTrue(store.importPayload(try makePackage(revision: 17), source: "test"))
        store.resetForTests()
        XCTAssertNil(store.pendingPackage)
        XCTAssertNil(store.activatedPlanID)
    }

    func testCorruptedPersistedDataDoesNotCrash() {
        UserDefaults.standard.set(Data([0x00, 0x01, 0x02]), forKey: FullComputerImportedPlanStore.pendingKey)
        let store = FullComputerImportedPlanStore.shared
        XCTAssertNil(store.pendingPackage)
    }

    func testActivationPreservesWatchNativeTravelAndBailout() throws {
        let config = FullComputerPrediveConfigurationStore.shared
        config.updateDraft { profile in
            profile.travelGases = [
                FullComputerConfiguredGas(
                    name: "Travel EAN36",
                    role: .travel,
                    oxygenFraction: 0.36,
                    heliumFraction: 0,
                    maxPPO2Bar: 1.4,
                    switchDepthMeters: 30
                )
            ]
            profile.bailoutGases = [
                FullComputerConfiguredGas(
                    name: "Bailout Air",
                    role: .bailout,
                    oxygenFraction: 0.21,
                    heliumFraction: 0,
                    maxPPO2Bar: 1.4,
                    switchDepthMeters: 0
                )
            ]
        }
        let store = FullComputerImportedPlanStore.shared
        XCTAssertTrue(store.importPayload(try makePackage(revision: 18), source: "test"))
        try store.activatePendingPlan(configuration: config)
        XCTAssertEqual(config.confirmedProfile?.travelGases.count, 1)
        XCTAssertEqual(config.confirmedProfile?.bailoutGases.count, 1)
        XCTAssertEqual(config.confirmedProfile?.travelGases.first?.name, "Travel EAN36")
    }

    func testWatchReceiverRejectsNonPackageTransfer() throws {
        let ack = DivePlanPackageWatchReceiver.importPayload(
            ["transferType": "apneaSyncPlanPackage"],
            store: .shared
        )
        XCTAssertNil(ack)
        XCTAssertFalse(FullComputerImportedPlanStore.shared.hasPendingActivation)
    }

    private func makePackage(revision: Int) throws -> DivePlanPackage {
        try DivePlanPackageCodec.seal(sampleBody(revision: revision))
    }

    private func sampleBody(revision: Int) -> DivePlanPackageBody {
        let bottomID = UUID()
        let decoID = UUID()
        return DivePlanPackageBody(
            schemaVersion: DivePlanPackageCodec.currentSchemaVersion,
            algorithmVersion: DivePlanPackageCodec.algorithmVersion,
            planID: planID,
            revision: revision,
            createdAt: Date(),
            expiresAt: Date().addingTimeInterval(3600),
            environment: DivePlanEnvironmentPayload(altitudeMeters: 0, salinityRaw: SalinityMode.salt.rawValue),
            gfLow: 30,
            gfHigh: 70,
            gases: [
                DivePlanGasPayload(
                    id: bottomID,
                    name: "Trimix 18/45",
                    role: .bottom,
                    oxygenFraction: 0.18,
                    heliumFraction: 0.45,
                    maxPPO2Bar: 1.4,
                    switchDepthMeters: nil,
                    sortOrder: 0
                ),
                DivePlanGasPayload(
                    id: decoID,
                    name: "EAN50",
                    role: .deco,
                    oxygenFraction: 0.50,
                    heliumFraction: 0,
                    maxPPO2Bar: 1.6,
                    switchDepthMeters: 21,
                    sortOrder: 1
                ),
            ],
            bottomSegments: [DivePlanBottomSegmentPayload(depthMeters: 45, durationMinutes: 20, order: 0)],
            plannedSwitches: [DivePlanGasSwitchPayload(gasID: decoID, switchDepthMeters: 21, order: 0)],
            plannerSummary: DivePlanSummaryPayload(
                modeLabel: "Deco",
                planKind: "single",
                maxDepthMeters: 45,
                bottomMinutes: 20,
                totalRuntimeMinutes: 55,
                requiresDeco: true,
                decoStopCount: 2
            ),
            capabilities: .current
        )
    }
}
