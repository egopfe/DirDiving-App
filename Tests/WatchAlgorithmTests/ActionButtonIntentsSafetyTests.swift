import XCTest

final class ActionButtonIntentsSafetyTests: XCTestCase {
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        let suite = "ActionButtonSafety-\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
    }

    func testSafetyGateFailsClosedWhenLegalNotAccepted() {
        XCTAssertTrue(LegalAcceptanceGate.requiresAcceptance(defaults: defaults))
        XCTAssertThrowsError(try ActionButtonSafetyGate.requireLegalAcceptance(defaults: defaults)) { error in
            XCTAssertEqual(error as? LegalAcceptanceGateError, .notAccepted)
        }
    }

    func testSafetyGateAllowsWhenLegalAccepted() {
        defaults.set(Date(), forKey: "dirdiving_legal_acceptance_timestamp")
        let major = (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1")
            .split(separator: ".")
            .first
            .map(String.init) ?? "1"
        defaults.set(major, forKey: "dirdiving_legal_acceptance_major_version")
        defaults.set(LegalAcceptanceStore.legalRevision, forKey: "dirdiving_legal_acceptance_revision")
        defaults.set(true, forKey: "dirdiving_legal_depth_limits_acknowledged")
        XCTAssertFalse(LegalAcceptanceGate.requiresAcceptance(defaults: defaults))
        XCTAssertNoThrow(try ActionButtonSafetyGate.requireLegalAcceptance(defaults: defaults))
    }

    func testVersionBumpRequiresReAcceptance() {
        defaults.set(Date(), forKey: "dirdiving_legal_acceptance_timestamp")
        defaults.set("0", forKey: "dirdiving_legal_acceptance_major_version")
        defaults.set(LegalAcceptanceStore.legalRevision, forKey: "dirdiving_legal_acceptance_revision")
        defaults.set(true, forKey: "dirdiving_legal_depth_limits_acknowledged")
        XCTAssertTrue(LegalAcceptanceGate.requiresAcceptance(defaults: defaults))
    }
}
