import XCTest
@testable import DIRDivingWatchApp

@MainActor
final class DeveloperSensorSourceTests: XCTestCase {
    func testDefaultSensorSourceIsSimulation() {
        let defaults = UserDefaults(suiteName: "DeveloperSensorSourceTests")!
        defaults.removeObject(forKey: SensorSourceMode.storageKey)
        XCTAssertEqual(
            SensorSourceMode(rawValue: defaults.string(forKey: SensorSourceMode.storageKey) ?? SensorSourceMode.simulation.rawValue),
            .simulation
        )
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
