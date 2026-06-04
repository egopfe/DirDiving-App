import XCTest
@testable import DIRDivingiOSApp

final class CloudBackupPolicyTests: XCTestCase {
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: "CloudBackupPolicyTests")!
        defaults.removePersistentDomain(forName: "CloudBackupPolicyTests")
        defaults.set(false, forKey: CloudBackupSettings.enabledKey)
    }

    func testCloudBackupDisabledByDefault() {
        XCTAssertFalse(CloudBackupSettings.isEnabled)
    }

    func testCloudBackupTogglePersists() {
        CloudBackupSettings.setEnabled(true)
        XCTAssertTrue(CloudBackupSettings.isEnabled)
        CloudBackupSettings.setEnabled(false)
        XCTAssertFalse(CloudBackupSettings.isEnabled)
    }
}
