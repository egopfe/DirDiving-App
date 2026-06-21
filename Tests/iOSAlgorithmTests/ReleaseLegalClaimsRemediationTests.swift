import XCTest

final class ReleaseLegalClaimsRemediationTests: XCTestCase {
    func testGovernanceDocumentsExist() {
        let root = repositoryRoot()
        for path in ReleaseLegalClaimsPolicy.requiredGovernanceDocuments {
            XCTAssertTrue(
                ReleaseLegalClaimsPolicy.documentExists(relativePath: path, repositoryRoot: root),
                "Missing governance document: \(path)"
            )
        }
    }

    func testClaimsRegistryCoversMinimumClaimIDs() {
        XCTAssertTrue(ReleaseLegalClaimsPolicy.registryCoversMinimumClaimIDs(in: repositoryRoot()))
    }

    func testEvidencePackagesContainRequiredFiles() {
        let root = repositoryRoot()
        for package in ReleaseLegalClaimsPolicy.requiredEvidencePackages {
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: root.appendingPathComponent("\(package.folder)/README.md").path),
                package.folder
            )
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: root.appendingPathComponent("\(package.folder)/\(package.statusFile)").path),
                package.folder
            )
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: root.appendingPathComponent("\(package.folder)/\(package.templateFile)").path),
                package.folder
            )
            let status = try? String(
                contentsOf: root.appendingPathComponent("\(package.folder)/\(package.statusFile)"),
                encoding: .utf8
            )
            XCTAssertTrue(status?.localizedCaseInsensitiveContains("PENDING") == true, package.folder)
        }
    }

    func testLegalRevisionMatchesAcrossPlatforms() throws {
        let watch = try String(
            contentsOf: rootFile("App/LegalAcceptanceStore.swift"),
            encoding: .utf8
        )
        let ios = try String(
            contentsOf: rootFile("iOSApp/App/LegalAcceptanceStore.swift"),
            encoding: .utf8
        )
        XCTAssertTrue(watch.contains("static let legalRevision = \"2026-05-23\""))
        XCTAssertTrue(ios.contains("static let legalRevision = \"2026-05-23\""))
    }

    func testIOSLegalAcceptanceStoreRequiresAcceptanceWhenEmpty() throws {
        let source = try String(
            contentsOf: rootFile("iOSApp/App/LegalAcceptanceStore.swift"),
            encoding: .utf8
        )
        XCTAssertTrue(source.contains("var requiresAcceptance: Bool"))
        XCTAssertTrue(source.contains("guard acknowledgedDepthOperatingLimits else { return }"))
        XCTAssertTrue(source.contains("record.legalRevision != Self.legalRevision"))
    }

    func testExportDisclaimerKeysExist() throws {
        let en = try loadIOSStrings(named: "en")
        let required = [
            "planner.reference_only.warning",
            "ccr.safety.disclaimer",
            "pdf.export.ratio_deco.disclaimer",
            "planner.buhlmann.reference_disclaimer",
            "detail.ttv.note",
        ]
        for key in required {
            XCTAssertFalse(en[key, default: ""].isEmpty, key)
        }
    }

    func testSyncAndCloudLimitationCopyExists() throws {
        let en = try loadIOSStrings(named: "en")
        XCTAssertFalse(en["more.safety.footer", default: ""].isEmpty)
        let cloudCapability = try String(contentsOf: rootFile("Tests/iOSAlgorithmTests/CloudBackupCapabilityTests.swift"), encoding: .utf8)
        XCTAssertTrue(cloudCapability.contains("ApneaSnorkelingExplicitlyUnavailable"))
    }

    func testEquipmentChecklistDoesNotClaimLifeSupportVerification() throws {
        let generator = try String(
            contentsOf: rootFile("iOSApp/Utils/EquipmentChecklistGenerator.swift"),
            encoding: .utf8
        )
        XCTAssertFalse(generator.localizedCaseInsensitiveContains("life-support verification"))
    }

    func testProhibitedClaimsScannerScriptExists() {
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: repositoryRoot()
                    .appendingPathComponent(ReleaseLegalClaimsPolicy.prohibitedClaimsScannerPath)
                    .path
            )
        )
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private func rootFile(_ relative: String) -> URL {
        repositoryRoot().appendingPathComponent(relative)
    }

    private func loadIOSStrings(named locale: String) throws -> [String: String] {
        let raw = try String(
            contentsOf: rootFile("iOSApp/Resources/\(locale).lproj/Localizable.strings"),
            encoding: .utf8
        )
        var result: [String: String] = [:]
        let pattern = #"\"([^\"]+)\"\s*=\s*\"([^\"]*)\";"#
        let regex = try NSRegularExpression(pattern: pattern)
        let range = NSRange(raw.startIndex..<raw.endIndex, in: raw)
        regex.enumerateMatches(in: raw, range: range) { match, _, _ in
            guard let match,
                  let keyRange = Range(match.range(at: 1), in: raw),
                  let valueRange = Range(match.range(at: 2), in: raw) else { return }
            result[String(raw[keyRange])] = String(raw[valueRange])
        }
        return result
    }
}
