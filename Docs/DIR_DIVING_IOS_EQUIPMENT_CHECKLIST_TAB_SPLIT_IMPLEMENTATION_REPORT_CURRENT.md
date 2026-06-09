# DIR DIVING iOS — Equipment / Checklist Tab Split Implementation Report

**Date:** 2026-06-09  
**Branch:** `main`  
**Scope:** UI/navigation/information-architecture only.

---

## 1. Executive summary

Split the combined Attrezzatura + Checklist experience into two main tabs while preserving all equipment, checklist, and image-management features. Settings is now an explicit sixth tab.

## 2. Goal implemented

- **Attrezzatura** — inventory, saved setups, equipment images / Watch photo transfer.
- **Checklist** — operational pre-dive checklist with setup selection from saved templates.

## 3. Final tab structure

| Tab | Root view |
|-----|-----------|
| Planner | `PlannerRootView` |
| Logbook | `LogbookView` |
| Analisi | `AnalysisView` |
| Attrezzatura | `EquipmentView` |
| Checklist | `ChecklistView` |
| Settings | `MoreView` |

Default selected tab remains **Planner**.

## 4. Files modified

| File | Change |
|------|--------|
| `iOSApp/Views/ContentView.swift` | Six-tab `IOSTab` model |
| `iOSApp/Views/EquipmentView.swift` | Inventory + setups + images only |
| `iOSApp/Views/ChecklistView.swift` | **New** — checklist + setup picker |
| `iOSApp/Services/EquipmentStore.swift` | `selectedChecklistTemplateID` + setup helpers |
| `iOSApp/Views/MoreView.swift` | Removed `WatchPhotoTransferPanel` |
| `iOSApp/Resources/en.lproj/Localizable.strings` | Tab + checklist + image keys |
| `iOSApp/Resources/it.lproj/Localizable.strings` | Tab + checklist + image keys |
| `Tests/iOSAlgorithmTests/IOSEquipmentChecklistTabSplitTests.swift` | **New** |
| `Tests/iOSAlgorithmTests/UIUXRemediationV3AccessibilityTests.swift` | Checklist + Settings tab badge assertions |
| `project.yml` | `EquipmentStore.swift` in iOS Algorithm Tests sources |
| `Docs/DIR_DIVING_IOS_EQUIPMENT_CHECKLIST_TAB_SPLIT_IMPLEMENTATION_REPORT_CURRENT.md` | This report |

## 5. Existing combined functionality discovered

- Single `EquipmentView` contained planning card + checklist card + templates sheet.
- `EquipmentStore` holds one `EquipmentProfile` + named `EquipmentTemplate` setups.
- `WatchPhotoTransferPanel` lived under Settings sync card in `MoreView`.
- Checklist gas BAR/PSI logic in `EquipmentChecklistGasSection` unchanged.

## 6–8. Features preserved / setup reference

- All checklist toggles, GAS flag, gas sections, add/remove items, PDF export → **Checklist** tab.
- Planning fields, templates, reset → **Attrezzatura** tab.
- Checklist references setup via `selectedChecklistTemplateID` (persisted KVS key `dirdiving_ios_equipment_checklist_selection`). Selecting a template calls existing `applyTemplate`. Fallback display: **Profilo corrente / Current profile**.

## 9. Image management relocation

`WatchPhotoTransferPanel` moved to Attrezzatura card **Immagini attrezzatura / Equipment images**.

## 10. Settings cleanup

Settings (`MoreView`) retains preferences, sync, legal, developer, cloud backup, CSV import — no photo transfer UI.

## 11–12. Localization & accessibility

- New `tab.checklist`, `tab.settings`, checklist setup/empty-state keys (EN/IT).
- Checklist progress, setup change, and image panel accessibility preserved/extended.

## 13. Fullscreen / adaptive layout

Uses existing `DIRScreenContainer`, `dirCompanionTabRoot`, `dirCompanionScrollSurface` — no layout hacks.

## 14. Validation

| Command | Result |
|---------|--------|
| `xcodebuild -list` | Schemes: DIRDiving iOS, DIRDiving iOS Algorithm Tests, … |
| `xcodebuild -scheme "DIRDiving iOS" -destination 'platform=iOS Simulator,name=iPhone 15 Pro' build` | **BUILD SUCCEEDED** |
| `xcodebuild -scheme "DIRDiving iOS" -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build` | **BUILD SUCCEEDED** |
| `xcodebuild -scheme "DIRDiving iOS Algorithm Tests" … test -only-testing:IOSEquipmentChecklistTabSplitTests` | **TEST SUCCEEDED** (2 tests) |
| Full iOS Algorithm Tests suite | **TEST SUCCEEDED** — 580 tests, 13 skipped, 0 failures |

**Simulators validated:** iPhone 15 Pro, iPhone 17 Pro. iPhone 14 Pro / 15 Pro Max runtimes not installed on this machine.

## 15. Manual QA checklist

- [ ] Six tabs visible
- [ ] Attrezzatura: planning + setups + images
- [ ] Checklist: setup card + items + GAS/BAR/PSI
- [ ] Settings: no checklist execution / no photo panel
- [ ] Planner unchanged
- [ ] No GPS POI added

## 16. Follow-up

- Multi-profile equipment inventory (beyond single `EquipmentProfile`) not in scope.
- Checklist could bind read-only to template without applying to profile — deferred; current behavior applies template to profile (existing semantics).

## 17. Confirmations

- Apple Watch files: **not changed**
- Algorithms / Bühlmann / gas / CNS/OTU / planner math: **not changed**
- WatchConnectivity / sync codecs: **not changed**
- Equipment, checklist, image features: **preserved**
- GPS POI: **not introduced**
