import XCTest

final class SnorkelingQAEvidenceCatalogTests: XCTestCase {
    func testCatalogDefinesTwentyOneFolders() {
        XCTAssertEqual(SnorkelingQAEvidenceCatalog.entries.count, 21)
        XCTAssertEqual(SnorkelingQAEvidenceCatalog.folderCount, 21)
    }

    func testCatalogQAIDsAreUnique() {
        let ids = SnorkelingQAEvidenceCatalog.entries.map(\.qaID)
        XCTAssertEqual(Set(ids).count, ids.count)
    }

    func testCatalogFolderNamesAreUnique() {
        let folders = SnorkelingQAEvidenceCatalog.entries.map(\.folderName)
        XCTAssertEqual(Set(folders).count, folders.count)
    }

    func testEveryEvidenceFolderHasExecutableREADME() throws {
        let root = repositoryRoot()
        for entry in SnorkelingQAEvidenceCatalog.entries {
            let readme = SnorkelingQAEvidenceCatalog.readmePath(for: entry, repositoryRoot: root)
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: readme.path),
                "Missing README for \(entry.folderName)"
            )
            let text = try String(contentsOf: readme, encoding: .utf8)
            XCTAssertTrue(text.contains(entry.qaID), "\(entry.folderName) README must include QA ID")
            XCTAssertTrue(text.contains("**PENDING**"), "\(entry.folderName) must remain PENDING until physical execution")
            for field in SnorkelingQAEvidenceCatalog.requiredMetadataFields {
                XCTAssertTrue(
                    text.localizedCaseInsensitiveContains(field),
                    "\(entry.folderName) missing metadata field \(field)"
                )
            }
        }
    }

    func testInternalEvidenceGatePassesWithPendingTemplates() throws {
        let issues = try validateEvidence(mode: .internalPendingAllowed)
        XCTAssertTrue(issues.isEmpty, "Internal gate issues: \(issues)")
    }

    func testReleaseEvidenceGateFailsWhilePending() throws {
        let issues = try validateEvidence(mode: .releaseRequiresPass)
        XCTAssertFalse(issues.isEmpty, "Release mode must fail while evidence is PENDING")
        XCTAssertEqual(issues.count, SnorkelingQAEvidenceCatalog.entries.count)
    }

    private enum ValidationMode {
        case internalPendingAllowed
        case releaseRequiresPass
    }

    private func validateEvidence(mode: ValidationMode) throws -> [String] {
        let root = repositoryRoot()
        var issues: [String] = []
        for entry in SnorkelingQAEvidenceCatalog.entries {
            let text = try String(
                contentsOf: SnorkelingQAEvidenceCatalog.readmePath(for: entry, repositoryRoot: root),
                encoding: .utf8
            )
            let status = parseStatus(from: text)
            switch mode {
            case .internalPendingAllowed:
                if status != "PENDING" {
                    issues.append("\(entry.qaID): internal mode expects PENDING, got \(status ?? "nil")")
                }
            case .releaseRequiresPass:
                if status != "PASS" {
                    issues.append("\(entry.qaID): release blocked — status \(status ?? "nil")")
                }
            }
        }
        return issues
    }

    private func parseStatus(from text: String) -> String? {
        let patterns = [
            #"\|\s*\*\*Status\*\*\s*\|\s*\*\*(PENDING|PASS|FAIL)\*\*"#,
            #"status:\s*(PENDING|PASS|FAIL)"#,
        ]
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]),
               let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
               let range = Range(match.range(at: 1), in: text) {
                return String(text[range]).uppercased()
            }
        }
        return nil
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
