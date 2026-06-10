import XCTest

final class ChecklistPlannerSyncMapperTests: XCTestCase {
    func testExportLineIncludesSwitchDepthForDecoGas() {
        let item = EquipmentChecklistItem(
            title: "Deco stage",
            usesGas: true,
            gasMixKind: .ean,
            gasText: "EAN50",
            switchDepthMeters: 21,
            gasRole: .deco
        )
        XCTAssertEqual(item.switchDepthMeters ?? 0, 21, accuracy: 0.01)
        let line = ChecklistPDFBuilder.exportLine(for: item, unitPreference: .metric)
        XCTAssertTrue(line.contains("switch @"), "line was: \(line)")
        XCTAssertTrue(line.contains("21"), "line was: \(line)")
    }

    func testChecklistToPlannerMapsTankPressureAndMix() {
        let item = EquipmentChecklistItem(
            title: "Deco stage",
            usesGas: true,
            gasMixKind: .ean,
            gasText: "EAN50",
            pressureText: "190",
            pressureUnit: .bar,
            tankSize: .liters12,
            gasRole: .deco
        )
        let entry = ChecklistPlannerSyncMapper.plannerCylinder(
            from: item,
            role: .deco,
            environment: .seaLevelSaltWater
        )
        XCTAssertEqual(entry.tankSize, .liters12)
        XCTAssertEqual(entry.startPressure, 190, accuracy: 0.01)
        XCTAssertEqual(entry.gas.oxygen, 0.50, accuracy: 0.01)
        XCTAssertEqual(entry.role, .deco)
    }

    func testInferRoleFromChecklistTitle() {
        let item = EquipmentChecklistItem(title: "Back gas", usesGas: true)
        XCTAssertEqual(ChecklistPlannerSyncMapper.resolvedRole(for: item), .bottom)
    }

    func testDuplicateDetectionMatchesTankMixAndRole() {
        let item = EquipmentChecklistItem(
            title: "Deco",
            usesGas: true,
            gasMixKind: .ean,
            gasText: "O2",
            pressureText: "180",
            pressureUnit: .bar,
            tankSize: .liters12,
            gasRole: .deco
        )
        var cylinders = [
            ChecklistPlannerSyncMapper.plannerCylinder(from: item, role: .deco, environment: .seaLevelSaltWater)
        ]
        let duplicateIndex = ChecklistPlannerSyncMapper.findMatchingPlannerIndex(for: item, role: .deco, in: cylinders)
        XCTAssertEqual(duplicateIndex, 0)

        ChecklistPlannerSyncMapper.applyImport(
            candidates: [
                ChecklistPlannerImportCandidate(
                    id: item.id,
                    checklistItem: item,
                    assignedRole: .deco,
                    isSelected: true,
                    duplicatePlannerIndex: duplicateIndex,
                    duplicateAction: .skip
                )
            ],
            to: &cylinders,
            environment: .seaLevelSaltWater
        )
        XCTAssertEqual(cylinders.count, 1)
    }

    func testImportDoesNotDuplicateWhenSkipSelected() {
        let item = EquipmentChecklistItem(
            title: "Deco",
            usesGas: true,
            gasMixKind: .air,
            gasText: "",
            pressureText: "200",
            pressureUnit: .bar,
            tankSize: .liters12,
            gasRole: .deco
        )
        var cylinders: [PlannerCylinderEntry] = []
        let candidates = ChecklistPlannerSyncMapper.importCandidates(checklist: [item], plannerCylinders: cylinders)
        ChecklistPlannerSyncMapper.applyImport(
            candidates: candidates,
            to: &cylinders,
            environment: .seaLevelSaltWater
        )
        XCTAssertEqual(cylinders.count, 1)

        ChecklistPlannerSyncMapper.applyImport(
            candidates: ChecklistPlannerSyncMapper.importCandidates(checklist: [item], plannerCylinders: cylinders),
            to: &cylinders,
            environment: .seaLevelSaltWater
        )
        XCTAssertEqual(cylinders.count, 1)
    }

    func testPlannerToChecklistCreatesGasItemWithRole() {
        let entry = PlannerCylinderEntry(
            role: .bailout,
            tankSize: .s80,
            gas: GasMix(name: "Air", role: .bailout, mixKind: .air, oxygen: 0.21, helium: 0, maxPPO2: 1.4),
            startPressure: 210,
            pressureUnit: .psi
        )
        let checklistItem = ChecklistPlannerSyncMapper.checklistItem(from: entry)
        XCTAssertTrue(checklistItem.usesGas)
        XCTAssertEqual(checklistItem.gasRole, .bailout)
        XCTAssertEqual(checklistItem.tankSize, .s80)
        XCTAssertEqual(checklistItem.pressureUnit, .psi)
    }

    func testMissingPlannerCylindersDetectedForExport() {
        let entry = PlannerCylinderEntry(
            role: .deco,
            gas: GasMix(name: "O2", role: .deco, mixKind: .ean, oxygen: 1.0, helium: 0, maxPPO2: 1.6)
        )
        let missing = ChecklistPlannerSyncMapper.cylindersMissingFromChecklist(
            plannerCylinders: [entry],
            checklist: []
        )
        XCTAssertEqual(missing.count, 1)
    }

    func testExportAddsOnlySelectedMissingItems() {
        let entry = PlannerCylinderEntry(
            role: .deco,
            tankSize: .liters12,
            gas: GasMix(name: "EAN50", role: .deco, mixKind: .ean, oxygen: 0.5, helium: 0, maxPPO2: 1.6),
            startPressure: 190,
            pressureUnit: .bar
        )
        var checklist: [EquipmentChecklistItem] = []
        let candidates = ChecklistPlannerSyncMapper.exportCandidates(
            plannerCylinders: [entry],
            checklist: checklist
        )
        ChecklistPlannerSyncMapper.applyExport(candidates: candidates, to: &checklist)
        XCTAssertEqual(checklist.count, 1)
        XCTAssertTrue(checklist[0].usesGas)
        XCTAssertEqual(checklist[0].gasRole, .deco)
    }

    func testCCRMultipleBailoutExportPreservesRowOrder() {
        var input = CCRPlanInput.default
        input.bailoutGases = [
            CCRBailoutGas(mixKind: .ean, oxygenPercent: 32, switchDepthMeters: 0),
            CCRBailoutGas(mixKind: .oxygen, switchDepthMeters: 6)
        ]
        var checklist: [EquipmentChecklistItem] = [
            EquipmentChecklistItem(title: "D", isReady: true, usesGas: true, gasText: "X", gasRole: .ccrDiluent),
            EquipmentChecklistItem(title: "B1", isReady: false, usesGas: true, gasText: "OLD1", gasRole: .ccrBailout),
            EquipmentChecklistItem(title: "B2", isReady: true, usesGas: true, gasText: "OLD2", gasRole: .ccrBailout)
        ]
        ChecklistPlannerSyncMapper.applyCCRExport(input: input, to: &checklist)
        let bailouts = checklist.filter { $0.gasRole == .ccrBailout }
        XCTAssertEqual(bailouts.count, 2)
        XCTAssertFalse(bailouts[0].isReady)
        XCTAssertTrue(bailouts[1].isReady)
        XCTAssertFalse(bailouts.contains { $0.gasText == "OLD1" || $0.gasText == "OLD2" })
    }

    func testInferRoleItalianDiluentTitle() {
        let item = EquipmentChecklistItem(title: "Bombola diluente CCR", usesGas: true)
        XCTAssertEqual(ChecklistPlannerSyncMapper.resolvedRole(for: item), .ccrDiluent)
    }

    func testHasCCRChecklistItemsMissingDetectsAbsentDiluentAndBailout() {
        var input = CCRPlanInput.default
        input.bailoutGases = [CCRBailoutGas(mixKind: .oxygen, switchDepthMeters: 6)]
        XCTAssertTrue(
            ChecklistPlannerSyncMapper.hasCCRChecklistItemsMissing(input: input, checklist: [])
        )
        var checklist = ChecklistPlannerSyncMapper.ccrChecklistItems(from: input)
        checklist[0].gasText = input.diluent.label
        XCTAssertFalse(
            ChecklistPlannerSyncMapper.hasCCRChecklistItemsMissing(input: input, checklist: checklist)
        )
    }
}
