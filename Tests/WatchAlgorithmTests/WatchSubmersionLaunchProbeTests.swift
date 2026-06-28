import XCTest
@testable import DIRDivingWatchApp

@MainActor
final class WatchSubmersionLaunchProbeTests: XCTestCase {
    override func setUp() {
        super.setUp()
        #if DEBUG
        WatchSubmersionLaunchProbe.testHook_submergedAtLaunch = nil
        WatchSubmersionLaunchProbe.testHook_skipHardwareProbe = false
        #endif
    }

    func testResolveColdLaunchEntryPointUsesSystemPathWhenSubmerged() {
        WatchWaterAutoOpenPolicy.mode = .preferredMode
        let entry = WatchLaunchRoutingPolicy.resolveColdLaunchEntryPoint(isSubmergedAtLaunch: true)
        XCTAssertEqual(entry, .systemWaterAutoLaunch)
    }

    func testResolveColdLaunchEntryPointStaysColdWhenNotSubmerged() {
        WatchWaterAutoOpenPolicy.mode = .preferredMode
        let entry = WatchLaunchRoutingPolicy.resolveColdLaunchEntryPoint(isSubmergedAtLaunch: false)
        XCTAssertEqual(entry, .userColdLaunch)
    }

    func testProbeTestHookReturnsConfiguredSubmersionState() async {
        #if DEBUG
        WatchSubmersionLaunchProbe.testHook_submergedAtLaunch = true
        let submerged = await WatchSubmersionLaunchProbe.isSubmergedAtLaunch()
        XCTAssertTrue(submerged)
        #endif
    }

    func testAutomaticDepthLaunchConfigurationReadsInfoPlistKeys() throws {
        let source = try String(
            contentsOf: repositoryRoot().appendingPathComponent("App/Info.plist"),
            encoding: .utf8
        )
        XCTAssertTrue(source.contains("WKSupportsAutomaticDepthLaunch"))
        XCTAssertTrue(source.contains("underwater-depth"))
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
