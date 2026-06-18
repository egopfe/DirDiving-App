import XCTest

final class SnorkelingRouteSyncCodecTests: XCTestCase {
    func testSealValidateAndChecksumRoundTrip() throws {
        var draft = SnorkelingRoutePlannerDraft(name: "Morning reef")
        draft.entryPoint = SnorkelingRoutePlannerPoint(name: "Entry", role: .entry, latitude: 44.10, longitude: 9.82)
        draft.exitPoint = SnorkelingRoutePlannerPoint(name: "Exit", role: .exit, latitude: 44.11, longitude: 9.83)
        let profile = SnorkelingCompanionProfilePresets.reef()
        let package = try SnorkelingRoutePackageBuilder.build(
            draft: draft,
            profile: profile,
            packageID: UUID(),
            revision: 1
        )
        XCTAssertNoThrow(try SnorkelingRouteSyncCodec.validate(package))
        let data = try SnorkelingRouteSyncCodec.encode(package)
        let decoded = try SnorkelingRouteSyncCodec.decode(data)
        XCTAssertEqual(decoded.payloadChecksumSHA256, package.payloadChecksumSHA256)
    }

    func testChecksumMismatchRejected() throws {
        var draft = SnorkelingRoutePlannerDraft(name: "Route")
        draft.entryPoint = SnorkelingRoutePlannerPoint(name: "A", role: .entry, latitude: 1, longitude: 1)
        draft.exitPoint = SnorkelingRoutePlannerPoint(name: "B", role: .exit, latitude: 1.01, longitude: 1.01)
        var package = try SnorkelingRoutePackageBuilder.build(
            draft: draft,
            profile: nil,
            packageID: UUID(),
            revision: 2
        )
        package.payloadChecksumSHA256 = "deadbeef"
        XCTAssertThrowsError(try SnorkelingRouteSyncCodec.validate(package)) { error in
            XCTAssertEqual(error as? SnorkelingRouteSyncValidationError, .checksumMismatch)
        }
    }

    func testTransferSupportRoundTrip() throws {
        var draft = SnorkelingRoutePlannerDraft(name: "Sync")
        draft.entryPoint = SnorkelingRoutePlannerPoint(name: "A", role: .entry, latitude: 10, longitude: 10)
        draft.exitPoint = SnorkelingRoutePlannerPoint(name: "B", role: .exit, latitude: 10.01, longitude: 10.01)
        let package = try SnorkelingRoutePackageBuilder.build(
            draft: draft,
            profile: nil,
            packageID: UUID(),
            revision: 3
        )
        let data = try SnorkelingRouteSyncCodec.encode(package)
        let userInfo = SnorkelingRouteSyncTransferSupport.makeTransferUserInfo(packageData: data, package: package)
        XCTAssertTrue(SnorkelingRouteSyncTransferSupport.isPackageTransfer(userInfo))
        let decoded = try SnorkelingRouteSyncTransferSupport.decodePackage(from: userInfo)
        XCTAssertEqual(decoded.body.revision, 3)
    }

    @MainActor
    func testImportedRouteStoreAcceptsValidPackage() throws {
        SnorkelingImportedRouteStore.shared.resetForTesting()
        defer { SnorkelingImportedRouteStore.shared.resetForTesting() }

        var draft = SnorkelingRoutePlannerDraft(name: "Import")
        draft.entryPoint = SnorkelingRoutePlannerPoint(name: "A", role: .entry, latitude: 5, longitude: 5)
        draft.exitPoint = SnorkelingRoutePlannerPoint(name: "B", role: .exit, latitude: 5.01, longitude: 5.01)
        let package = try SnorkelingRoutePackageBuilder.build(
            draft: draft,
            profile: nil,
            packageID: UUID(),
            revision: 1
        )
        XCTAssertTrue(SnorkelingImportedRouteStore.shared.importPayload(package, source: "test", sessionInProgress: false))
        XCTAssertNotNil(SnorkelingImportedRouteStore.shared.activeRoutePlan)
    }
}
