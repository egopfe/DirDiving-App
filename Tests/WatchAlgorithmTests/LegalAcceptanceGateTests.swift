import XCTest
@testable import DIRDivingWatchApp

final class LegalAcceptanceGateTests: XCTestCase {
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: "LegalAcceptanceGateTests")!
        defaults.removePersistentDomain(forName: "LegalAcceptanceGateTests")
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: "LegalAcceptanceGateTests")
        super.tearDown()
    }

    func testRequiresAcceptanceWhenNeverAccepted() {
        XCTAssertTrue(LegalAcceptanceGate.requiresAcceptance(defaults: defaults))
        XCTAssertThrowsError(try LegalAcceptanceGate.requireAccepted(defaults: defaults)) { error in
            XCTAssertEqual(error as? LegalAcceptanceGateError, .notAccepted)
        }
    }

    func testRequiresAcceptanceAfterLegalRevisionBump() {
        defaults.set(Date().timeIntervalSince1970, forKey: "dirdiving_legal_acceptance_timestamp")
        defaults.set("1", forKey: "dirdiving_legal_acceptance_major_version")
        defaults.set("old-revision", forKey: "dirdiving_legal_acceptance_revision")
        defaults.set(true, forKey: "dirdiving_legal_depth_limits_acknowledged")
        XCTAssertTrue(LegalAcceptanceGate.requiresAcceptance(defaults: defaults))
    }

    func testAllowsExecutionWhenFullyAccepted() {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let major = version.split(separator: ".").first.map(String.init) ?? version
        defaults.set(Date().timeIntervalSince1970, forKey: "dirdiving_legal_acceptance_timestamp")
        defaults.set(version, forKey: "dirdiving_legal_acceptance_app_version")
        defaults.set(major, forKey: "dirdiving_legal_acceptance_major_version")
        defaults.set(LegalAcceptanceStore.legalRevision, forKey: "dirdiving_legal_acceptance_revision")
        defaults.set(true, forKey: "dirdiving_legal_depth_limits_acknowledged")
        XCTAssertFalse(LegalAcceptanceGate.requiresAcceptance(defaults: defaults))
        XCTAssertNoThrow(try LegalAcceptanceGate.requireAccepted(defaults: defaults))
    }
}
