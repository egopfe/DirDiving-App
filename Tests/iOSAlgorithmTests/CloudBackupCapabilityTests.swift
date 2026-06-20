import XCTest
@testable import DIRDivingiOSApp

final class CloudBackupCapabilityTests: XCTestCase {
    func testDivingMigrationFromLegacySharedKey() {
        let priorMigration = UserDefaults.standard.integer(forKey: CloudBackupCapability.migrationVersionKey)
        let priorDiving = UserDefaults.standard.object(forKey: CloudBackupCapability.divingEnabledKey)
        let priorLegacy = UserDefaults.standard.object(forKey: CloudBackupCapability.legacySharedEnabledKey)
        defer {
            UserDefaults.standard.set(priorMigration, forKey: CloudBackupCapability.migrationVersionKey)
            if let priorDiving { UserDefaults.standard.set(priorDiving, forKey: CloudBackupCapability.divingEnabledKey) }
            else { UserDefaults.standard.removeObject(forKey: CloudBackupCapability.divingEnabledKey) }
            if let priorLegacy { UserDefaults.standard.set(priorLegacy, forKey: CloudBackupCapability.legacySharedEnabledKey) }
            else { UserDefaults.standard.removeObject(forKey: CloudBackupCapability.legacySharedEnabledKey) }
        }
        UserDefaults.standard.set(true, forKey: CloudBackupCapability.legacySharedEnabledKey)
        UserDefaults.standard.removeObject(forKey: CloudBackupCapability.divingEnabledKey)
        UserDefaults.standard.removeObject(forKey: CloudBackupCapability.migrationVersionKey)
        CloudBackupCapability.migrateLegacySharedKeyIfNeeded()
        XCTAssertTrue(CloudBackupCapability.isDivingEnabled)
    }

    func testApneaSnorkelingExplicitlyUnavailable() {
        XCTAssertFalse(CloudBackupCapability.capability(for: .apnea).isUploadAvailable)
        XCTAssertFalse(CloudBackupCapability.capability(for: .snorkeling).isUploadAvailable)
    }

    func testSettingsRegistryScopesCloudBackupToDiving() {
        let descriptor = ActivitySettingsVisibility.registry.first { $0.key == CloudBackupCapability.divingEnabledKey }
        XCTAssertEqual(descriptor?.scope, .diving)
        XCTAssertTrue(descriptor?.visibleInDiving == true)
        XCTAssertFalse(descriptor?.visibleInApnea == true)
        XCTAssertFalse(descriptor?.visibleInSnorkeling == true)
    }
}
