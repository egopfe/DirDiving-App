# Watch Full Computer — Apnea Boundary Audit — CURRENT

**Baseline:** `main` @ `2c30412`  
**Audit date:** 2026-07-01  
**Context:** Apnea P1/P2/P3 @ `76f3703`

---

## Scope

Verify Apnea remains isolated from Full Computer Bühlmann/decompression runtime per V1.5 APNEA FIRST-CLASS SCOPE.

---

## Architecture Isolation — PASS

| Check | Result | Evidence |
|---|---|---|
| Apnea sources exclude FC/Bühlmann symbols | PASS | ApneaArchitectureIsolationTests @2c30412 |
| Apnea runtime does not write DiveLogStore | PASS | ApneaWatchRuntimeStore static review + test |
| Separate sync namespace keys | PASS | testSyncNamespaceKeysRemainIsolated |
| Apnea UI independent of DiveManager | PASS | testApneaProductionUIAndRuntimeDoNotReferenceDiveManager |
| No decompression wording in Apnea production | PASS | Static localization sweep (prior UI audit) |
| No GF/gas/MOD in Apnea settings | PASS | WatchActivitySettingsOwnershipTests |

---

## Apnea Truthfulness Checks

| Rule | Status |
|---|---|
| No medical guarantee for recovery | PASS — reference-only copy |
| No claim Apnea auto-detection physically validated | PASS — PENDING_PHYSICAL documented |
| No claim water auto-open starts Apnea session | PASS — conditional routing copy |
| No cross-activity logbook/settings leakage | PASS — separate stores |

---

## Water Auto-Open Boundary — PARTIAL

Apnea P1/P2/P3 changed startup routing behavior. **12 water-auto-open tests FAIL** @2c30412:

- Tests expect Apnea water auto-open → `.ready(activity: .apnea)`
- Production returns `.divingModeSelection` in test harness configuration

**Finding:** WFC-P2-005 (P2) — test/product alignment needed; **not** an FC tissue safety defect.

Detail matrix: `Docs/MASTER_WATCH_APNEA_WATER_AUTO_OPEN_BOUNDARY_MATRIX_CURRENT.csv`

---

## Full Computer Impact from Apnea Wave

- **FC math/runtime:** No changes to `FullComputerRuntimeEngine` or `BuhlmannCore` in Apnea commits.
- **FC tests:** All Audit-15 and FC-specific tests PASS.
- **Routing UX:** May require test fixture update for DepthCapabilityPolicy in water-auto-open tests.

---

## Verdict

**APNEA_FC_BOUNDARY:** **PASS** (architecture) / **PARTIAL** (water-auto-open test alignment)
