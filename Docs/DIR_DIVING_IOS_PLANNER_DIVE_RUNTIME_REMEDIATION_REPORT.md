# DIR Diving iOS — Planner Dive Runtime Remediation Report

**Date:** 2026-06-11  
**Branch:** `main`  
**Status:** Implemented

## Files modified

- `iOSApp/Services/PlannerAscentTableBuilder.swift`
- `iOSApp/Models/DivePlan.swift`
- `iOSApp/Views/PlannerView.swift`
- `iOSApp/Views/CCR/CCRPlanResultView.swift`
- `iOSApp/Services/PDF/BriefingPDFBuilder.swift`
- `iOSApp/Services/PDF/PlannerPDFBuilder.swift`
- `iOSApp/Services/PDF/CCRPlannerPDFBuilder.swift`
- `iOSApp/Resources/en.lproj/Localizable.strings`
- `iOSApp/Resources/it.lproj/Localizable.strings`
- `Tests/iOSAlgorithmTests/PlannerAscentTableTests.swift`
- `Tests/iOSAlgorithmTests/PlannerPresentationTests.swift` *(new)*
- `Tests/iOSAlgorithmTests/PlannerLocalizationTests.swift`
- `Tests/iOSAlgorithmTests/BriefingPDFBuilderTests.swift`
- `Tests/iOSAlgorithmTests/CCRPlannerTests.swift`
- `Docs/DIR_DIVING_IOS_PLANNER_DIVE_RUNTIME_PRESENTATION.md` *(new)*

## Localization keys added/updated

**Added:**
- `planner.runtime.title`, `planner.runtime.subtitle`
- `planner.runtime.row.descent`, `.bottom`, `.travel`, `.ascent`, `.deco_stop`, `.surface`
- `planner.runtime.table.a11y`
- `planner.table.phase`

**Updated values:**
- `planner.result.ascent_plan`, `planner.result.ascent_plan.subtitle`
- `planner.result.ascent_table.a11y`
- `planner.table.briefing_order.footnote`
- `pdf.export.briefing.ascent`

## Affected modes

| Mode | Runtime table | Descent row | Deco Stop label |
|------|---------------|-------------|-----------------|
| Base | Not shown by policy | N/A | Only if real deco exists |
| Deco | Simplified runtime table | Yes | Sosta Deco / Deco Stop |
| Technical | Full runtime table | Yes | Sosta Deco / Deco Stop |
| CCR | Schedule card + PDF | Yes (engine phase) | Sosta Deco for `.stop` phase |

## Confirmations

- Bühlmann math unchanged
- CCR math unchanged
- Ratio Deco calculation unchanged
- Stop depths unchanged (builder reads engine stops)
- Stop times unchanged
- Raw `decoStop` enum name not user-visible
- “Runtime immersione” / “Dive Runtime” shown in planner, PDF, briefing
- “Sosta Deco” / “Deco Stop” shown for decompression rows

## Tests added/updated

- `PlannerAscentTableTests`: descent order, deco stop kinds, deco unchanged, technical travel, base isolation, labels, title localization
- `PlannerPresentationTests`: PlannerView keys, briefing PDF runtime + deco label
- `PlannerLocalizationTests`, `BriefingPDFBuilderTests`, `CCRPlannerTests`

## Build / test results

| Command | Result |
|---------|--------|
| `xcodegen generate` | OK |
| `xcodebuild -scheme "DIRDiving iOS" -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build` | **BUILD SUCCEEDED** |
| `PlannerAscentTableTests` | **Passed** (15 tests) |
| `PlannerPresentationTests` | **Passed** (2 tests) |
| `BriefingPDFBuilderTests` | **Passed** (3 tests) |
| `CCRPlannerTests` | **Passed** (12 tests) |
| `PlannerLocalizationTests` | **Passed** |

Simulator: `Iphone 15 Pro` (iPhone 17 Pro destination also used for initial run).

## Remaining limitations

- Ratio Deco ascent rows do not add a separate descent row (heuristic bundle unchanged).
- CCR schedule remains engine-phase driven; no fabricated rows beyond `CCRScheduleRow` output.
