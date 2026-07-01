# Master UI/UX Apnea Full Deep Audit — CURRENT

**Command:** 03 V1.5 Apnea first-class scope  
**Date:** 2026-07-01  
**Commit:** `2c30412`  
**Apnea wave:** P1/P2/P3 @ `76f3703`

---

## Executive Summary

Apnea is a **first-class product area** on iOS Companion and Apple Watch with isolated Settings, Logbook, sync schema, and runtime. **No decompression wording, GF, gas, MOD, or PPO2** in Apnea production UI paths. **No cross-activity logbook or settings leakage** confirmed by automated isolation tests.

**Verdict:** **PARTIAL** — software-complete for P1/P2/P3 runtime; **P2 gaps** in alarms/markers editor UI and Watch title localization; **physical wet QA pending**.

| Severity | Count |
|----------|------:|
| P0 | 0 |
| P1 | 1 (physical QA) |
| P2 | 3 |
| P3 | 2 |

---

## Scope Verified

| Area | iOS | Watch | Status |
|------|-----|-------|--------|
| Root/dashboard | IOSApneaRootView | ApneaView | PASS |
| Live session | IOSApneaSessionCheckView | ApneaWatchRuntimeStore | PASS |
| Automatic detection | IOSApneaSettingsStore | ApneaWatchRuntimeStore | PASS |
| Recovery countdown | Settings + live | ApneaView overlays | PASS |
| Targets/training P1/P2/P3 | IOSApneaSessionPlannerView | Training compound steps | PASS |
| Alarms/markers | Model + presets | Runtime | **P2** — editor UI missing |
| Statistics/records | IOSApneaStatisticsView | N/A browse | PASS |
| Logbook | IOSApneaLogbookStore | ApneaLogbookStore (no Watch browse) | PASS |
| Settings | IOSApneaSettingsContent | Watch read-only section | PASS |
| In-mode Settings gear | Sheet initialMode | WatchInModeSettingsAccessButton | PASS |
| Water auto-open Apnea route | Policy | Last/preferred Apnea ready | PASS software |
| Digital Crown underwater | Live only | WatchUnderwaterPagePolicy | PASS |
| Action Button | Unavailable on Apnea live | Router | PASS |

---

## Mandatory Negative Checks

| Check | Result |
|-------|--------|
| No decompression wording in Apnea | PASS |
| No GF/gas/MOD/PPO2/deco settings | PASS |
| No medical guarantee for recovery | PASS |
| No claim Apnea auto-detection physically validated | PASS (pending labeled) |
| No claim WAO starts Apnea session | PASS |
| No cross-activity logbook/settings leakage | PASS |

---

## Open Findings

| ID | Sev | Finding |
|----|-----|---------|
| MUIUX-P1-001 | P1 | Apnea WAO wet routing physical QA (shared with global WAO) |
| MUIUX-P2-006 | P2 | `ApneaView` hardcoded `"Apnea"` title — not localized |
| MUIUX-P2-007 | P2 | `IOSApneaProfileEditorView` lacks alarms/markers editor despite model |
| MUIUX-P3-005 | P3 | iCloud Apnea backup stub — honest disclosure only |

---

## Matrices

- `MASTER_UI_UX_APNEA_FEATURE_IMPLEMENTATION_MATRIX_CURRENT.csv`
- `MASTER_UI_UX_APNEA_NAVIGATION_REACHABILITY_MATRIX_CURRENT.csv`
- `MASTER_UI_UX_APNEA_STATE_COMPLETENESS_MATRIX_CURRENT.csv`
- `MASTER_UI_UX_APNEA_ACCESSIBILITY_LOCALIZATION_MATRIX_CURRENT.csv`

---

## Verdict

```text
APNEA_UI_UX_DEEP_AUDIT: PARTIAL
APNEA_FIRST_CLASS: PASS
APNEA_SETTINGS_OWNERSHIP: PASS
APNEA_LOGBOOK_OWNERSHIP: PASS
APNEA_NO_DECO_LEAKAGE: PASS
APNEA_PHYSICAL_QA: PENDING_PHYSICAL
```
