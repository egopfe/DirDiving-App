import XCTest

final class SnorkelingImportedRouteCompatibilityTests: XCTestCase {
    func testPackageWithoutPlanningMetadataDecodesAndValidates() throws {
        let routePlan = SnorkelingRoutePlan(
            name: "Legacy",
            waypoints: [
                SnorkelingWaypoint(name: "A", category: .buoy, latitude: 44.40, longitude: 8.94, routeOrder: 0),
                SnorkelingWaypoint(name: "B", category: .buoy, latitude: 44.41, longitude: 8.95, routeOrder: 1),
            ]
        )
        let body = SnorkelingRouteSyncPackageBody(
            schemaVersion: 1,
            packageID: UUID(),
            revision: 1,
            createdAt: Date(),
            expiresAt: Date().addingTimeInterval(3_600),
            routePlan: routePlan,
            profile: nil,
            maxDistanceLimitMeters: nil,
            planningMetadata: nil,
            capabilities: .current
        )
        let package = try SnorkelingRouteSyncCodec.seal(body)
        XCTAssertNoThrow(try SnorkelingRouteSyncCodec.validate(package))
        let data = try SnorkelingRouteSyncCodec.encode(package)
        let decoded = try SnorkelingRouteSyncCodec.decode(data)
        XCTAssertNil(decoded.body.planningMetadata)
    }

    func testFullPackageWithPlanningMetadataRoundTrips() throws {
        var draft = SnorkelingRoutePlannerDraft(name: "Modern", routeType: .roundTrip, returnAlertPolicy: .halfPlannedDistance)
        draft.entryPoint = SnorkelingRoutePlannerPoint(name: "Entry", role: .entry, latitude: 44.40, longitude: 8.94)
        draft.waypoints = [
            SnorkelingRoutePlannerPoint(name: "WP", role: .waypoint, latitude: 44.401, longitude: 8.941, routeOrder: 0),
        ]
        let package = try SnorkelingRoutePackageBuilder.build(
            draft: draft,
            profile: SnorkelingCompanionProfilePresets.reef(),
            packageID: UUID(),
            revision: 1
        )
        let data = try SnorkelingRouteSyncCodec.encode(package)
        let decoded = try SnorkelingRouteSyncCodec.decode(data)
        XCTAssertNotNil(decoded.body.planningMetadata)
        XCTAssertEqual(decoded.body.planningMetadata?.returnAlertPolicy, .halfPlannedDistance)
    }

    @MainActor
    func testImportedRouteStoreAcceptsLegacyCompatiblePackage() throws {
        SnorkelingImportedRouteStore.shared.resetForTesting()
        defer { SnorkelingImportedRouteStore.shared.resetForTesting() }

        var draft = SnorkelingRoutePlannerDraft(name: "Compat")
        draft.entryPoint = SnorkelingRoutePlannerPoint(name: "A", role: .entry, latitude: 5, longitude: 5)
        draft.exitPoint = SnorkelingRoutePlannerPoint(name: "B", role: .exit, latitude: 5.01, longitude: 5.01)
        let package = try SnorkelingRoutePackageBuilder.build(
            draft: draft,
            profile: nil,
            packageID: UUID(),
            revision: 1
        )
        XCTAssertTrue(SnorkelingImportedRouteStore.shared.importPayload(package, source: "test", sessionInProgress: false))
        XCTAssertNotNil(SnorkelingImportedRouteStore.shared.activePlanningMetadata)
    }

    func testRouteSyncNamespaceDoesNotCollideWithOtherActivities() {
        let routeKey = SnorkelingRouteSyncTransferSupport.transferTypePackage
        XCTAssertNotEqual(routeKey, ApneaReleaseSelfCheck.apneaSessionPayloadKey)
        XCTAssertNotEqual(routeKey, ApneaReleaseSelfCheck.diveSessionPayloadKey)
        XCTAssertNotEqual(routeKey, SnorkelingSessionSyncCodec.payloadKey)
    }

    @MainActor
    func testStaleRevisionRejectedWithoutMutatingActivatedPackage() throws {
        SnorkelingImportedRouteStore.shared.resetForTesting()
        defer { SnorkelingImportedRouteStore.shared.resetForTesting() }

        let packageID = UUID()
        var draft = SnorkelingRoutePlannerDraft(name: "Rev")
        draft.entryPoint = SnorkelingRoutePlannerPoint(name: "A", role: .entry, latitude: 1, longitude: 1)
        draft.exitPoint = SnorkelingRoutePlannerPoint(name: "B", role: .exit, latitude: 1.01, longitude: 1.01)
        let newer = try SnorkelingRoutePackageBuilder.build(
            draft: draft,
            profile: nil,
            packageID: packageID,
            revision: 2
        )
        let older = try SnorkelingRoutePackageBuilder.build(
            draft: draft,
            profile: nil,
            packageID: packageID,
            revision: 1
        )
        XCTAssertTrue(SnorkelingImportedRouteStore.shared.importPayload(newer, source: "test", sessionInProgress: false))
        XCTAssertFalse(SnorkelingImportedRouteStore.shared.importPayload(older, source: "test", sessionInProgress: false))
        XCTAssertTrue(SnorkelingImportedRouteStore.shared.staleRevisionRejected)
        XCTAssertEqual(SnorkelingImportedRouteStore.shared.activatedRevision, 2)
    }
}
