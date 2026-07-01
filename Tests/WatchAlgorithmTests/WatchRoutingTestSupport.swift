import XCTest
@testable import DIRDivingWatchApp

/// Shared depth-capability + developer-toggle setup for Watch water-auto-open routing tests.
enum WatchRoutingTestSupport {
    #if DEBUG
    static func configureShallowEntitlementRoutingForTests() {
        DepthCapabilityEntitlementProbe.testHook_hasShallowEntitlement = true
        DepthCapabilityEntitlementProbe.testHook_hasFullEntitlement = false
        DeveloperSettings.setShallowGaugeTestingEnabled(true)
        DeveloperSettings.setShallowDepthDivingTestingEnabled(true)
    }

    static func resetRoutingTestEnvironment() {
        DepthCapabilityEntitlementProbe.testHook_hasShallowEntitlement = nil
        DepthCapabilityEntitlementProbe.testHook_hasFullEntitlement = nil
        DeveloperSettings.resetShallowDepthDivingTestingForTests()
        DIRStartupSelectionPolicy.resetForTests()
        WatchWaterAutoOpenPolicy.resetForTests()
    }
    #endif
}
