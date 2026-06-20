import XCTest

final class ApneaCloudBackupStubTruthfulnessTests: XCTestCase {
    func testCloudCapabilityIsExplicitlyUnavailable() {
        XCTAssertFalse(ApneaCloudCapability.current.isUploadAvailable)
        if case .notAvailable(let reason) = ApneaCloudCapability.current {
            XCTAssertEqual(reason, .localOnlyPolicy)
        } else {
            XCTFail("Expected notAvailable capability")
        }
    }

    func testCloudBackupReconcileClearsStaleOptIn() {
        let key = ApneaCloudBackupPreference.enabledKey
        defer { UserDefaults.standard.removeObject(forKey: key) }
        UserDefaults.standard.set(true, forKey: key)
        ApneaCloudBackupPreference.reconcileWithCapability()
        XCTAssertFalse(ApneaCloudBackupPreference.isEnabled)
    }

    func testCloudBackupLocalizationDoesNotClaimUpload() throws {
        let en = try loadStrings(named: "en")
        let it = try loadStrings(named: "it")
        let enNote = en["apnea.ios.export.cloud_backup_unavailable"] ?? ""
        let itNote = it["apnea.ios.export.cloud_backup_unavailable"] ?? ""
        XCTAssertTrue(enNote.localizedCaseInsensitiveContains("not available") || enNote.localizedCaseInsensitiveContains("locally"))
        XCTAssertTrue(itNote.localizedCaseInsensitiveContains("non") || itNote.localizedCaseInsensitiveContains("local"))
    }

    func testNoApneaCloudUploadPathInLogbookStore() {
        let source = String(data: try! Data(contentsOf: URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("iOSApp/Services/IOSApneaLogbookStore.swift")), encoding: .utf8)!
        XCTAssertFalse(source.contains("CloudSyncStore"))
        XCTAssertFalse(source.contains("syncCloud"))
    }

    private func loadStrings(named language: String) throws -> [String: String] {
        let url = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("iOSApp/Resources/\(language).lproj/Localizable.strings")
        let raw = try String(contentsOf: url, encoding: .utf8)
        var result: [String: String] = [:]
        for line in raw.split(separator: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard trimmed.hasPrefix("\""), let eq = trimmed.firstIndex(of: "=") else { continue }
            let key = String(trimmed[trimmed.index(after: trimmed.startIndex)..<eq]).trimmingCharacters(in: .whitespaces).trimmingCharacters(in: CharacterSet(charactersIn: "\""))
            let valuePart = trimmed[trimmed.index(after: eq)...].trimmingCharacters(in: .whitespaces)
            guard valuePart.hasPrefix("\""), valuePart.hasSuffix("\";") || valuePart.hasSuffix("\"") else { continue }
            var value = String(valuePart.dropFirst().dropLast(valuePart.hasSuffix("\";") ? 2 : 1))
            result[key] = value
        }
        return result
    }
}
