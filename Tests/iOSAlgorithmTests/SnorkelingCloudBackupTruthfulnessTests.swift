import XCTest

@MainActor
final class SnorkelingCloudBackupTruthfulnessTests: XCTestCase {
    func testCloudCapabilityIsExplicitlyUnavailable() {
        let capability = SnorkelingCloudCapability.current
        XCTAssertFalse(capability.isUploadAvailable)
        if case .notAvailable(.localOnlyPolicy) = capability {
            // expected
        } else {
            XCTFail("Expected localOnlyPolicy")
        }
    }

    func testExportViewDoesNotExposeCloudToggle() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/Snorkeling/IOSSnorkelingSessionExportView.swift"))
        XCTAssertTrue(source.contains("SnorkelingCloudCapability.current"))
        XCTAssertFalse(source.contains("@AppStorage(\"dirdiving_ios_snorkeling_cloud_backup_enabled\")"))
        XCTAssertFalse(source.contains("Toggle(DIRIOSLocalizer.string(\"snorkeling.ios.export.cloud_backup\"), isOn:"))
        XCTAssertTrue(source.contains("localizationStatusKey"))
    }

    func testReconcileClearsStaleOptIn() {
        SnorkelingCloudBackupPreference.setEnabled(true)
        SnorkelingCloudBackupPreference.reconcileWithCapability()
        XCTAssertFalse(SnorkelingCloudBackupPreference.isEnabled)
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
