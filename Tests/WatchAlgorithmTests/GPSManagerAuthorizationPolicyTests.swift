import XCTest

@MainActor
final class GPSManagerAuthorizationPolicyTests: XCTestCase {
    func testOnboardingPermissionRequestDoesNotStartContinuousUpdates() {
        let manager = GPSManager()
        XCTAssertFalse(manager.maintainsLocationUpdates)
        manager.requestWhenInUseFromOnboarding()
        XCTAssertFalse(manager.maintainsLocationUpdates)
        XCTAssertEqual(manager.locationPermissionState, .notDetermined)
    }

    func testRefreshAuthorizationStatusMapsPermissionState() {
        let manager = GPSManager()
        manager.refreshAuthorizationStatus()
        XCTAssertEqual(manager.locationPermissionState, WatchLocationPermissionState.map(manager.authorizationStatus))
    }

    func testNoFixCurrentBestPointRemainsUnavailableWithoutFakeGPS() {
        let manager = GPSManager()
        XCTAssertNil(manager.currentBestPoint())
        XCTAssertEqual(manager.fallbackQuality, .unavailable)
    }

    func testFirstLaunchPolicyNotRepeatedAfterMarkPresented() {
        let defaults = UserDefaults(suiteName: "GPSManagerAuthorizationPolicyTests")!
        defaults.removePersistentDomain(forName: "GPSManagerAuthorizationPolicyTests")
        defer { defaults.removePersistentDomain(forName: "GPSManagerAuthorizationPolicyTests") }

        WatchFirstLaunchLocationPermissionPolicy.markPresented(userDefaults: defaults)
        XCTAssertFalse(
            WatchFirstLaunchLocationPermissionPolicy.shouldPresentFirstLaunchPermissionFlow(
                authorizationStatus: .notDetermined,
                legalAccepted: true,
                userDefaults: defaults
            )
        )
    }

    func testWatchRootIntegratesFirstLaunchHost() throws {
        let contentView = try String(contentsOf: repositoryRoot().appendingPathComponent("Views/ContentView.swift"))
        let hostView = try String(contentsOf: repositoryRoot().appendingPathComponent("Views/WatchFirstLaunchLocationPermissionView.swift"))
        XCTAssertTrue(contentView.contains("WatchFirstLaunchLocationPermissionHost"))
        XCTAssertTrue(hostView.contains("WatchFirstLaunchLocationPermissionView"))
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
