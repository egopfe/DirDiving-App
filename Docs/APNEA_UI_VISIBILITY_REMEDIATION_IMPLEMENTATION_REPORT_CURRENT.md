# Apnea UI Visibility Remediation — Implementation Report (Current)

**Branch:** `main` (uncommitted work)  
**Baseline commit:** `305308186832497944d6c1cedde3ae1310288673`  
**Date:** 2026-07-01  

## Files inspected (pre-change)

All paths listed in remediation spec §2 were reviewed: shared models/evaluators, iOS stores/views, Watch runtime/presentation, localization bundles, tests, `project.yml`.

## Files changed (summary)

### Shared
- `Shared/Models/ApneaCompanionSettings.swift` — `preApneaChecklist`, schema v2 migration
- `Shared/Models/ApneaCompanionProfile.swift` — optional `maxRepetitions`
- `Shared/Models/ApneaSessionProfile.swift` — bridge passes max repetitions
- `Shared/Utils/ApneaReadinessPresentation.swift` — planner session check + send gate helpers

### iOS
- `iOSApp/Services/IOSApneaSettingsStore.swift` — checklist persist/reset API
- `iOSApp/Views/Apnea/IOSApneaChecklistView.swift` — store-backed checklist + reset
- `iOSApp/Views/Apnea/IOSApneaSessionPlannerView.swift` — checklist + session check sections
- `iOSApp/Views/Apnea/IOSApneaDashboardView.swift` — Apnea Readiness card + sheets
- `iOSApp/Views/Apnea/IOSApneaProfilesView.swift` — kind/recovery/max reps editor
- `iOSApp/Views/Apnea/IOSApneaSessionCheckView.swift` — buddy from checklist store
- `iOSApp/Utils/IOSApneaDashboardPresentation.swift` — profile subtitle enrichment

### Watch
- `Utils/ApneaWatchPresentation.swift` — pre-check label from checklist counts
- `Services/ApneaWatchRuntimeStore.swift` — checklist counts in presentation input
- `Views/ApneaView.swift` — ready panel pre-check row

### Localization
- `iOSApp/Resources/en.lproj/Localizable.strings`
- `iOSApp/Resources/it.lproj/Localizable.strings`
- `Resources/en.lproj/Localizable.strings` (Watch pre-check keys)
- `Resources/it.lproj/Localizable.strings`

### Tests
- `Tests/iOSAlgorithmTests/ApneaChecklistPersistenceTests.swift` (new)
- `Tests/iOSAlgorithmTests/ApneaSessionCheckPlannerIntegrationTests.swift` (new)
- `Tests/iOSAlgorithmTests/ApneaReadinessPresentationTests.swift` (new)
- `Tests/iOSAlgorithmTests/ApneaProfileKindEditorTests.swift` (new)
- `Tests/iOSAlgorithmTests/ApneaSessionPlannerSectionOrderTests.swift` (updated)
- `Tests/WatchAlgorithmTests/ApneaWatchPrecheckPresentationTests.swift` (new)
- `Tests/WatchAlgorithmTests/ApneaWatchPresentationTests.swift` (+ related input fixes)

### Docs / QA
- `Docs/APNEA_UI_VISIBILITY_REMEDIATION.md`
- `Docs/APNEA_CHECKLIST_PERSISTENCE.md`
- `Docs/APNEA_PLANNER_SESSION_CHECK_INTEGRATION.md`
- `Docs/APNEA_READINESS_DASHBOARD.md`
- `Docs/APNEA_PROFILE_UI_STRUCTURED_KIND.md`
- `Docs/QA_EVIDENCE/APNEA_*` (8 templates, default **PENDING**)

## Implementation details

### Checklist persistence
- `ApneaCompanionSettings.preApneaChecklist` with backward-compatible decode
- `IOSApneaSettingsStore.setChecklistItem`, `resetChecklist`, completion/buddy helpers
- No checklist data written to logbook as certification

### Planner session check
- Section order: recovery → checklist → session check → notes → watch transfer
- `ApneaSessionCheckEvaluator` via `ApneaReadinessPresentation.plannerSessionCheck`
- Send to Watch disabled on invalid plan or `.incomplete`/`.blocked`; `.warning` allowed with visible badge

### Dashboard readiness card
- Always visible; profile, checklist count, recovery alerts, session check status
- Sheets for full checklist and session check

### Profile UI structured kind
- Editor: profile type, recovery rule, max repetitions
- List subtitle shows kind, targets, recovery, reps

### Watch pre-check reminder
- Synthetic label: `Pre-check: X/Y` or buddy/recovery reminder
- Does not block session start; no safety-critical wording

## Localization keys added

`apnea.readiness.*`, `apnea.checklist.completed_format`, `apnea.checklist.reset*`, `apnea.checklist.operational_reminder`, `apnea.profile.kind`, `apnea.profile.recovery_rule`, `apnea.profile.max_repetitions`, `apnea.watch.precheck*`, updated session-check issue strings (EN/IT).

## Tests

| Suite | Result |
|-------|--------|
| DIRDiving iOS Algorithm Tests | **1678 passed**, 0 failed |
| DIRDiving Watch Algorithm Tests | **1156 passed**, 0 failed |

New/updated Apnea remediation tests cover checklist persistence, planner session check gating, readiness presentation, profile kind editor, planner section order, Watch pre-check presentation.

## Build

| Target | Result |
|--------|--------|
| DIRDiving iOS | **BUILD SUCCEEDED** |
| DIRDiving Watch App | **BUILD SUCCEEDED** |

## Scripts

- `./Scripts/check_secrets.sh` — PASS
- `./Scripts/audit_localization.sh` — PASS
- `./Scripts/check_main_target_isolation.sh` — PASS

## Known limitations

- Checklist item-level sync to Watch plan payload is not fully wired; Watch uses counts from imported package settings when available
- Session check does not evaluate live Watch battery/sensor availability from device (nil inputs)
- Full checklist on Watch intentionally omitted (synthetic pre-check only)
- Physical device QA not executed

## Physical QA status

**PENDING** — all `Docs/QA_EVIDENCE/APNEA_*` templates default to PENDING.

## Final verdict

| Tag | Status |
|-----|--------|
| INTERNAL_READY | YES |
| PHYSICAL_QA_PENDING | YES |
| APNEA_UI_VISIBILITY_REMEDIATION_READY | YES |
| APNEA_CHECKLIST_PERSISTENCE_READY | YES |
| APNEA_PLANNER_SESSION_CHECK_READY | YES |
| APNEA_DASHBOARD_READINESS_READY | YES |
| APNEA_PROFILE_KIND_UI_READY | YES |
| APNEA_WATCH_PRECHECK_READY | YES |
| NO_CROSS_ACTIVITY_REGRESSION | YES (automated suites green; no non-Apnea code paths modified) |
| NO_SAFETY_CRITICAL_CLAIMS | YES |
| NO_MEDICAL_DEVICE_CLAIMS | YES |
