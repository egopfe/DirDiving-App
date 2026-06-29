import XCTest

final class IOSSnorkelingLocationPermissionTests: XCTestCase {
    func testSnorkelingPermissionDelegatesToCentralMapping() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Utils/IOSSnorkelingLocationPermission.swift"))
        XCTAssertTrue(source.contains("IOSLocationPermissionService.map"))
    }

    func testRoutePlannerUsesCentralLocationPermissionService() throws {
        let planner = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/Snorkeling/IOSSnorkelingRoutePlannerView.swift"))
        XCTAssertTrue(planner.contains("@EnvironmentObject private var locationPermission: IOSLocationPermissionService"))
        XCTAssertTrue(planner.contains("requestWhenInUseFromUserAction()"))
        XCTAssertTrue(planner.contains("IOSLocationSettingsOpener.openAppSettings()"))
        XCTAssertFalse(planner.contains("@State private var mapPermission"))
    }

    func testFirstLaunchFlowIsModeIndependent() throws {
        let app = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/App/DIRDivingiOSApp.swift"))
        let host = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/IOSFirstLaunchLocationPermissionView.swift"))
        XCTAssertTrue(app.contains("IOSFirstLaunchLocationPermissionHost"))
        XCTAssertTrue(app.contains("IOSLocationPermissionService()"))
        XCTAssertTrue(host.contains("IOSFirstLaunchLocationPermissionPolicy.markPresented()"))
        XCTAssertTrue(host.contains("legalAcceptance.requiresAcceptance"))
    }

    func testLocationSettingsOpenerIsIOSOnly() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Utils/IOSLocationSettingsOpener.swift"))
        XCTAssertTrue(source.contains("UIApplication.openSettingsURLString"))
        let appDirectory = repositoryRoot().appendingPathComponent("App")
        let watchSources = try FileManager.default.subpathsOfDirectory(atPath: appDirectory.path)
        for path in watchSources where path.hasSuffix(".swift") {
            let body = try String(contentsOf: appDirectory.appendingPathComponent(path))
            XCTAssertFalse(body.contains("IOSLocationSettingsOpener"))
        }
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
