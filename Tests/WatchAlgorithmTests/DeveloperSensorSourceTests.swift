import XCTest
@testable import DIRDivingWatchApp

@MainActor
final class DeveloperSensorSourceTests: XCTestCase {
    func testDefaultSensorSourceIsAutomatic() {
        let defaults = UserDefaults(suiteName: "DeveloperSensorSourceTests")!
        defaults.removePersistentDomain(forName: "DeveloperSensorSourceTests")
        UserDefaults.standard.removeObject(forKey: SensorSourceMode.storageKey)
        XCTAssertEqual(SensorSourceMode.persisted, .automatic)
    }

    func testStoredSimulationResolvesToAutomaticInReleasePolicy() {
        SensorSourceMode.persist(.simulation)
        #if DEBUG
        XCTAssertEqual(SensorSourceMode.runtimeMode, .simulation)
        #else
        if DeveloperSettings.allowsSimulationSensorSelection {
            XCTAssertEqual(SensorSourceMode.runtimeMode, .simulation)
        } else {
            XCTAssertEqual(SensorSourceMode.runtimeMode, .automatic)
        }
        #endif
    }

    func testFactorySimulationNeverUsesAppleTypeName() {
        let provider = SensorProviderFactory.makeProvider(mode: .simulation)
        XCTAssertTrue(provider is MockDepthSensorProvider)
    }

    func testFactoryAutomaticFallsBackToMockWhenAppleUnavailable() {
        guard !AppleDepthSensorProvider.isAvailable else {
            let provider = SensorProviderFactory.makeProvider(mode: .automatic)
            XCTAssertTrue(provider is AppleDepthSensorProvider)
            return
        }
        let provider = SensorProviderFactory.makeProvider(mode: .automatic)
        XCTAssertTrue(provider is MockDepthSensorProvider)
    }

    func testPersistRoundTrip() {
        SensorSourceMode.persist(.appleSensor)
        XCTAssertEqual(SensorSourceMode.persisted, .appleSensor)
        SensorSourceMode.persist(.simulation)
        XCTAssertEqual(SensorSourceMode.persisted, .simulation)
    }
}
