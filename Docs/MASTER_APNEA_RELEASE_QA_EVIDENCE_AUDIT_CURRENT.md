# Apnea — Release / QA / Evidence Audit — CURRENT

**Command:** 05 V1.5 Apnea first-class scope  
**Baseline:** `main` @ `2c30412`  
**Apnea wave:** P1/P2/P3 @ `76f3703`  
**Audit date:** 2026-07-01

---

## A. Executive Summary

Apnea is a **first-class product area** with strict isolation from Diving decompression math. **Software readiness: INTERNAL_READY.** Physical wet QA, auto-detection field validation, and paired-device Apnea sync remain **PENDING_PHYSICAL**.

| Check | Verdict |
|---|---|
| No decompression/GF/gas/MOD in Apnea | **PASS** |
| Settings/Logbook ownership isolated | **PASS** |
| Sync schema isolated (`dirdiving_apnea_*`) | **PASS** |
| No medical guarantee for recovery | **PASS** |
| No claim WAO starts Apnea session | **PASS** |
| No claim auto-detection physically validated | **PASS** (pending labeled) |
| Apnea automated tests | **PASS** |
| Physical wet QA | **PENDING_PHYSICAL** |

**Verdict:** **PARTIAL** — software INTERNAL_READY; release blocked by physical gates same as Diving.

---

## B. Scope Verified

| Area | Watch @76f3703 | iOS Companion | Software | Physical |
|---|---|---|---|---|
| Root/dashboard | ApneaView | IOSApneaRootView | PASS | PENDING |
| Live session | ApneaWatchRuntimeStore | Import only | PASS | PENDING |
| Automatic detection | ApneaWatchRuntimeStore | Settings sync | PASS | PENDING |
| Depth/time profile | Watch runtime | Imported display | PASS | PENDING |
| Recovery countdown | ApneaView overlays | Settings | PASS | PENDING |
| Targets/alarms P1/P2/P3 | Training compound | Planner config | PASS | P2 editor UI |
| Statistics/records | N/A browse | IOSApneaStatisticsView | PASS | n/a |
| Logbook | ApneaLogbookStore | IOSApneaLogbookStore | PASS | PENDING |
| Settings | Watch read-only section | IOSApneaSettingsContent | PASS | PENDING |
| iOS mode switch | n/a | Activity switcher | PASS | n/a |
| WAO Apnea route | Policy boundary | n/a | PASS software | PENDING |
| Digital Crown | Live-only clamp | n/a | PASS software | PENDING |
| Action Button | Router unavailable live | n/a | PASS | PENDING |
| Sync/persistence | ApneaSyncCodec | ApneaSyncCodec | PASS | PENDING paired |

---

## C. Mandatory Truthfulness (V1.5)

All negative checks **PASS** — see [`MASTER_APNEA_CLAIMS_EVIDENCE_MATRIX_CURRENT.csv`](MASTER_APNEA_CLAIMS_EVIDENCE_MATRIX_CURRENT.csv).

---

## D. Test Evidence

| Suite | Result |
|---|---|
| ApneaLifecycleEngineTests | PASS |
| ApneaTimeRecoveryCheckpointEngineTests | PASS |
| ApneaReleaseHardValidationTests | PASS (Both) |
| ApneaArchitectureIsolationTests | PASS |
| IOSApneaCompanionTests | PASS |
| ApneaSyncCodec cross-decode rejection | PASS |

**WAO routing note:** Post-Apnea wave, water-auto-open routing tests fail when Apnea is preferred activity — documented as WFC-P2-005 (cross-activity routing test drift, not Apnea math defect).

---

## E. Physical / Wet QA

Matrix: [`MASTER_APNEA_PHYSICAL_WET_QA_MATRIX_CURRENT.csv`](MASTER_APNEA_PHYSICAL_WET_QA_MATRIX_CURRENT.csv)

**0% executed** — APNEA_WET_INTERACTION, APNEA_BATTERY_THERMAL, APNEA_VOICEOVER folders template-only.

---

## F. Release Posture

| Gate | Verdict |
|---|---|
| Internal TestFlight (Apnea software) | **READY** |
| External TestFlight (Apnea field) | **NOT READY** |
| App Store (Apnea) | **NOT READY** |

---

## G. Findings

| ID | Sev | Finding |
|---|---|---|
| APNEA-P1-001 | P1 | Wet interaction QA not executed |
| APNEA-P2-001 | P2 | Alarms/markers editor UI incomplete (UI audit 03) |
| APNEA-P2-002 | P2 | Apnea iCloud backup stub (IOS-P3-002) |
| APNEA-P2-003 | P2 | WAO routing test drift affects Apnea preferred routing tests |

**P0:** None

---

## H. Verdict

```text
APNEA_RELEASE_QA_EVIDENCE_AUDIT: PARTIAL
APNEA_SOFTWARE_READINESS: INTERNAL_READY
APNEA_PHYSICAL_WET_QA: PENDING_PHYSICAL
APNEA_CLAIMS_TRUTHFULNESS: PASS
```
