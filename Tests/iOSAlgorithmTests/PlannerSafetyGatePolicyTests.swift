import XCTest
@testable import DIRDivingiOSApp

final class PlannerSafetyGatePolicyTests: XCTestCase {
    func testGenericAndCCRUseDifferentStorageKeys() {
        XCTAssertNotEqual(
            PlannerSafetyAcknowledgment.storageKey,
            CCRPlannerSafetyAcknowledgment.storageKey
        )
        XCTAssertNotEqual(
            PlannerSafetyAcknowledgment.currentRevision,
            CCRPlannerSafetyAcknowledgment.currentRevision
        )
    }

    func testGenericAcknowledgementDoesNotUnlockCCR() {
        XCTAssertFalse(
            PlannerSafetyGatePolicy.isAcknowledged(
                mode: .ccr,
                genericAcknowledged: true,
                ccrAcknowledged: false
            )
        )
    }

    func testCCRAcknowledgementDoesNotUnlockTechnical() {
        XCTAssertFalse(
            PlannerSafetyGatePolicy.isAcknowledged(
                mode: .technical,
                genericAcknowledged: false,
                ccrAcknowledged: true
            )
        )
    }

    func testCCRModeRequiresCCRAcknowledgementOnly() {
        XCTAssertTrue(
            PlannerSafetyGatePolicy.isAcknowledged(
                mode: .ccr,
                genericAcknowledged: false,
                ccrAcknowledged: true
            )
        )
    }

    func testTechnicalModeRequiresGenericAcknowledgementOnly() {
        XCTAssertTrue(
            PlannerSafetyGatePolicy.isAcknowledged(
                mode: .technical,
                genericAcknowledged: true,
                ccrAcknowledged: false
            )
        )
    }

    func testItalianGenericAcknowledgementUsesAccentedVerb() throws {
        let it = try loadStrings(named: "it")
        let label = try XCTUnwrap(it["planner.safety_ack.label"])
        XCTAssertTrue(label.contains("è solo indicativo"))
        XCTAssertFalse(label.contains(" e solo indicativo"))
    }

    func testItalianCCRAcknowledgementUsesAccentedVerb() throws {
        let it = try loadStrings(named: "it")
        let label = try XCTUnwrap(it["planner.ccr.safety_ack.label"])
        XCTAssertTrue(label.contains("è solo indicativo"))
        XCTAssertFalse(label.contains(" e solo indicativo"))
    }

    func testCCRPlannerViewUsesIndependentStorageKey() throws {
        let source = try String(
            contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/CCR/CCRPlannerView.swift"),
            encoding: .utf8
        )
        XCTAssertTrue(source.contains("CCRPlannerSafetyAcknowledgment.storageKey"))
        XCTAssertFalse(source.contains("@AppStorage(PlannerSafetyAcknowledgment"))
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private func loadStrings(named name: String) throws -> [String: String] {
        let path = repositoryRoot()
            .appendingPathComponent("iOSApp/Resources/\(name).lproj/Localizable.strings")
        let contents = try String(contentsOf: path, encoding: .utf8)
        var result: [String: String] = [:]
        for line in contents.split(separator: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard trimmed.hasPrefix("\""), let eq = trimmed.firstIndex(of: "=") else { continue }
            let key = String(trimmed[trimmed.index(after: trimmed.startIndex)..<eq])
                .trimmingCharacters(in: .whitespaces)
                .trimmingCharacters(in: CharacterSet(charactersIn: "\""))
            var value = String(trimmed[trimmed.index(after: eq)...])
                .trimmingCharacters(in: .whitespaces)
            if value.hasSuffix(";") { value.removeLast() }
            value = value.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
            result[key] = value
        }
        return result
    }
}
