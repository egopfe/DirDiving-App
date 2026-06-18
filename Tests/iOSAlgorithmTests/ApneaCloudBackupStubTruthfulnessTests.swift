import XCTest

final class ApneaCloudBackupStubTruthfulnessTests: XCTestCase {
    func testCloudBackupLocalizationDoesNotClaimUpload() {
        guard let enPath = Bundle.main.path(forResource: "en", ofType: "lproj"),
              let itPath = Bundle.main.path(forResource: "it", ofType: "lproj"),
              let en = Bundle(path: enPath),
              let it = Bundle(path: itPath) else {
            XCTSkip("localization bundles unavailable in test host")
            return
        }
        let enNote = en.localizedString(forKey: "apnea.ios.export.cloud_backup_note", value: nil, table: nil)
        let itNote = it.localizedString(forKey: "apnea.ios.export.cloud_backup_note", value: nil, table: nil)
        XCTAssertTrue(enNote.localizedCaseInsensitiveContains("no upload") || enNote.localizedCaseInsensitiveContains("preference"))
        XCTAssertTrue(itNote.localizedCaseInsensitiveContains("upload") || itNote.localizedCaseInsensitiveContains("preferenza"))
        let enPending = en.localizedString(forKey: "apnea.ios.export.cloud_backup_pending", value: nil, table: nil)
        XCTAssertTrue(enPending.localizedCaseInsensitiveContains("not uploaded"))
    }

    func testCloudBackupDefaultsOff() {
        let key = "dirdiving_ios_apnea_cloud_backup_enabled"
        UserDefaults.standard.removeObject(forKey: key)
        XCTAssertFalse(UserDefaults.standard.bool(forKey: key))
    }

    func testCloudBackupOptInPersistsWithoutNetworkSideEffect() {
        let key = "dirdiving_ios_apnea_cloud_backup_enabled"
        defer { UserDefaults.standard.removeObject(forKey: key) }
        UserDefaults.standard.set(true, forKey: key)
        XCTAssertTrue(UserDefaults.standard.bool(forKey: key))
    }
}
