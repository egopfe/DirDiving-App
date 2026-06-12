import XCTest

final class EquipmentChecklistGeneratorTests: XCTestCase {
    func testGenerateChecklistFromTechnicalSetupAddsGasAndSafetyTasks() {
        var profile = EquipmentProfile()
        profile.setupMode = .technicalOC
        profile.structuredCylinders = [
            EquipmentGasCylinder(
                name: "Back",
                role: .bottom,
                tankSize: .liters12,
                gas: EquipmentStructuredSupport.defaultBottomGas(named: "TRIMIX 18/45")
            ),
            EquipmentGasCylinder(
                name: "Deco50",
                role: .deco,
                tankSize: .liters12,
                gas: EquipmentStructuredSupport.defaultDecoGas(named: "EAN50", oxygen: 0.5)
            )
        ]
        let generated = EquipmentChecklistGenerator.generate(from: profile)
        XCTAssertTrue(generated.contains(where: { $0.kind == .gas }))
        XCTAssertTrue(generated.contains(where: { $0.kind == .safety || $0.kind == .task }))
        XCTAssertTrue(generated.contains(where: {
            $0.title.contains(DIRIOSLocalizer.string("checklist.quick.valve_drill"))
        }))
    }

    func testGenerateChecklistAvoidsDuplicates() {
        let profile = EquipmentProfile()
        let generated = EquipmentChecklistGenerator.generate(from: profile)
        let existing = [
            EquipmentChecklistItem(
                title: DIRIOSLocalizer.string("checklist.quick.confirm_rock_bottom"),
                kind: .task
            )
        ]
        let merged = EquipmentChecklistGenerator.merge(
            generated: generated,
            into: existing,
            strategy: .appendMissing
        )
        let rockBottomCount = merged.filter {
            EquipmentStructuredSupport.normalizedChecklistKey(
                title: $0.title,
                kind: $0.kind
            ) == EquipmentStructuredSupport.normalizedChecklistKey(
                title: DIRIOSLocalizer.string("checklist.quick.confirm_rock_bottom"),
                kind: .task
            )
        }.count
        XCTAssertEqual(rockBottomCount, 1)
    }

    func testGenerateChecklistDoesNotDeleteUserItems() {
        let existing = [
            EquipmentChecklistItem(title: "Keep me", kind: .custom)
        ]
        let generated = EquipmentChecklistGenerator.generate(from: EquipmentProfile())
        let merged = EquipmentChecklistGenerator.merge(
            generated: generated,
            into: existing,
            strategy: .appendMissing
        )
        XCTAssertTrue(merged.contains(where: { $0.title == "Keep me" }))
        XCTAssertGreaterThan(merged.count, existing.count)
    }
}
