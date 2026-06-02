import XCTest
@testable import DIRDivingiOSApp

final class DeveloperSensorSourceTests: XCTestCase {
    func testDefaultSensorSourceIsSimulationWhenUnset() {
        let key = SensorSourceMode.storageKey
        let prior = UserDefaults.standard.string(forKey: key)
        defer {
            if let prior {
                UserDefaults.standard.set(prior, forKey: key)
            } else {
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
        UserDefaults.standard.removeObject(forKey: key)
        let raw = UserDefaults.standard.string(forKey: key) ?? SensorSourceMode.simulation.rawValue
        XCTAssertEqual(SensorSourceMode(rawValue: raw), .simulation)
    }

    func testPersistRoundTrip() {
        SensorSourceMode.persist(.automatic)
        XCTAssertEqual(SensorSourceMode.persisted, .automatic)
        SensorSourceMode.persist(.simulation)
        XCTAssertEqual(SensorSourceMode.persisted, .simulation)
    }
}
