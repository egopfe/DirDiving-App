import XCTest
@testable import DIRDivingWatchApp

@MainActor
final class DepthCapabilityTests: XCTestCase {
    override func setUp() {
        #if DEBUG
        DeveloperSettings.resetShallowDepthDivingTestingForTests()
        #endif
        super.setUp()
    }

    override func tearDown() {
        DepthCapabilityEntitlementProbe.testHook_hasShallowEntitlement = nil
        DepthCapabilityEntitlementProbe.testHook_hasFullEntitlement = nil
        AppleDepthSensorProvider.testHook_isAvailable = nil
        #if DEBUG
        DeveloperSettings.resetShallowDepthDivingTestingForTests()
        #endif
        super.tearDown()
    }

    func testShallowDoesNotImplyFullCapabilityWhenTestingDisabled() {
        DeveloperSettings.setShallowGaugeTestingEnabled(false)
        DeveloperSettings.setShallowDepthDivingTestingEnabled(false)
        DepthCapabilityEntitlementProbe.testHook_hasShallowEntitlement = true
        DepthCapabilityEntitlementProbe.testHook_hasFullEntitlement = false
        let resolver = DepthCapabilityResolver()
        XCTAssertEqual(resolver.resolveHardwareCapability(), .appleShallow)
        let policy = DepthCapabilityPolicy(capability: .appleShallow)
        XCTAssertTrue(policy.supportsSnorkelingRuntime)
        XCTAssertTrue(policy.supportsApneaRuntime)
        XCTAssertFalse(policy.supportsFullComputerRuntime)
        XCTAssertFalse(policy.supportsDivingGaugeRuntime)
    }

    func testShallowAllowsGaugeWhenGaugeTestingEnabled() {
        DeveloperSettings.setShallowGaugeTestingEnabled(true)
        DeveloperSettings.setShallowDepthDivingTestingEnabled(false)
        let policy = DepthCapabilityPolicy(capability: .appleShallow)
        XCTAssertTrue(policy.supportsDivingGaugeRuntime)
        XCTAssertFalse(policy.supportsFullComputerRuntime)
    }

    func testShallowAllowsGaugeAndFullComputerWhenTestingEnabled() {
        DeveloperSettings.setShallowGaugeTestingEnabled(true)
        DeveloperSettings.setShallowDepthDivingTestingEnabled(true)
        let policy = DepthCapabilityPolicy(capability: .appleShallow)
        XCTAssertTrue(policy.supportsDivingGaugeRuntime)
        XCTAssertTrue(policy.supportsFullComputerRuntime)
    }

    func testFullCapabilityUnlocksFullComputerPolicy() {
        let policy = DepthCapabilityPolicy(capability: .appleFull)
        XCTAssertTrue(policy.supportsFullComputerRuntime)
        XCTAssertTrue(policy.supportsDivingGaugeRuntime)
    }

    func testAutomaticSelectsShallowWhenFullAbsent() {
        DepthCapabilityEntitlementProbe.testHook_hasShallowEntitlement = true
        DepthCapabilityEntitlementProbe.testHook_hasFullEntitlement = false
        AppleDepthSensorProvider.testHook_isAvailable = true
        let resolver = DepthCapabilityResolver(testHook_capability: .appleShallow)
        let selection = SensorProviderFactory.makeSelection(mode: .automatic, resolver: resolver)
        XCTAssertTrue(selection.provider is AppleDepthSensorProvider)
        XCTAssertEqual(selection.resolution, .appleShallow)
        XCTAssertEqual(selection.sampleSource, .appleShallow)
    }

    func testExplicitFullFailsWhenOnlyShallowExists() {
        let resolver = DepthCapabilityResolver(testHook_capability: .appleShallow)
        let selection = SensorProviderFactory.makeSelection(mode: .appleFull, resolver: resolver)
        XCTAssertTrue(selection.provider is UnavailableDepthSensorProvider)
        XCTAssertEqual(selection.unavailableReason, DepthSensorUnavailableReason.fullEntitlementMissing)
    }

    func testSimulationDisabledInReleasePolicyPath() {
        let resolver = DepthCapabilityResolver(testHook_capability: .none)
        let selection = SensorProviderFactory.makeSelection(mode: .simulation, resolver: resolver)
        #if DEBUG
        if DeveloperSettings.allowsSimulationSensorSelection {
            XCTAssertTrue(selection.provider is MockDepthSensorProvider)
            return
        }
        #endif
        if DeveloperSettings.allowsSimulationSensorSelection {
            XCTAssertTrue(selection.provider is MockDepthSensorProvider)
        } else {
            XCTAssertTrue(selection.provider is UnavailableDepthSensorProvider)
            XCTAssertEqual(selection.unavailableReason, DepthSensorUnavailableReason.simulationDisabledInRelease)
        }
    }

    func testAutomaticDoesNotSilentlyUseMockInReleasePolicy() {
        let resolver = DepthCapabilityResolver(testHook_capability: .none)
        let selection = SensorProviderFactory.makeSelection(mode: .automatic, resolver: resolver)
        if DeveloperSettings.allowsSimulationSensorSelection {
            XCTAssertTrue(selection.provider is MockDepthSensorProvider || selection.provider is UnavailableDepthSensorProvider)
        } else {
            XCTAssertTrue(selection.provider is UnavailableDepthSensorProvider)
            XCTAssertNotEqual(selection.sampleSource, .simulation)
        }
    }

    func testDepthSampleSourceRoundTripTag() {
        let metadata = DepthSensorSessionMetadata(
            depthSampleSource: DepthSampleSource.appleShallow.rawValue,
            depthCapabilityMode: DepthCapabilityMode.appleShallow.rawValue
        )
        XCTAssertEqual(DepthSampleSource(persistedTag: metadata.depthSampleSource), .appleShallow)
    }
}
