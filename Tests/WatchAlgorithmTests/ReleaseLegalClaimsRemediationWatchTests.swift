import XCTest

final class ReleaseLegalClaimsRemediationWatchTests: XCTestCase {
    func testWatchLegalRevisionMatchesIOS() throws {
        let watch = try String(
            contentsOf: repositoryRoot().appendingPathComponent("App/LegalAcceptanceStore.swift"),
            encoding: .utf8
        )
        let ios = try String(
            contentsOf: repositoryRoot().appendingPathComponent("iOSApp/App/LegalAcceptanceStore.swift"),
            encoding: .utf8
        )
        XCTAssertEqual(
            watch.contains("static let legalRevision = \"2026-05-23\""),
            ios.contains("static let legalRevision = \"2026-05-23\"")
        )
    }

    func testSnorkelingForbiddenSafetyClaimSelfCheckIncludesGuaranteedReturn() throws {
        let source = try String(
            contentsOf: repositoryRoot().appendingPathComponent("Utils/SnorkelingReleaseSelfCheck.swift"),
            encoding: .utf8
        )
        XCTAssertTrue(source.contains("verifyNoForbiddenSafetyClaims"))
        XCTAssertTrue(source.contains("guaranteed return"))
    }

    func testEntitlementDisclosureDocumentationExists() {
        let root = repositoryRoot()
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: root.appendingPathComponent("Docs/WATCH_ULTRA_ENTITLEMENT_RELEASE_GATE_CURRENT.md").path
            )
        )
    }

    func testBriefingReferenceOnlyFooterKeyExists() throws {
        let en = try String(
            contentsOf: repositoryRoot().appendingPathComponent("Resources/en.lproj/Localizable.strings"),
            encoding: .utf8
        )
        XCTAssertTrue(en.contains("briefing.reference_only.footer"))
    }

    func testHardwareEntitlementEvidenceFolderPending() throws {
        let status = try String(
            contentsOf: repositoryRoot().appendingPathComponent("Docs/QA_EVIDENCE/HARDWARE_ENTITLEMENT/STATUS.md"),
            encoding: .utf8
        )
        XCTAssertTrue(status.localizedCaseInsensitiveContains("PENDING"))
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
