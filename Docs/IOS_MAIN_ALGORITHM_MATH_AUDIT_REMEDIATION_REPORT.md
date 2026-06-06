# iOS MAIN Algorithm Math Audit — Remediation Report

**Remediation date:** 2026-06-06  
**Repository:** DIR DIVING (`DirDiving-App`)  
**Branch:** `main`  
**Audit baseline:** [`IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md) @ `ecad0d9`  
**Remediation applied:** working tree on `main` (post-`e8f837a`, uncommitted at report time)  
**Target:** `DIRDiving iOS` only  
**Scope:** Code, tests, and static documentation — **excluding physical/external QA**

---

## A. Branch confirmed

`main`

## B. Commit confirmed

- Audit read baseline: `ecad0d9`
- Prior doc index commit: `e8f837a`
- Remediation edits: working tree (uncommitted)

## C. Target confirmed

**DIRDiving iOS** (iOS Companion MAIN). Shared sync message localized on iOS only; **no Watch runtime algorithm changes**.

## D. Experimental exclusions confirmed

No edits to Exploration Lab, Buddy experimental, Apnea, Snorkeling, or files excluded from `project.yml` iOS target.

## E. Files modified

| Area | Files |
|---|---|
| HIGH-002 | `iOSApp/Services/PlannerStore.swift`, `iOSApp/Services/PlannerService.swift` |
| HIGH-001 | `iOSApp/Utils/DiveSessionMerge.swift`, `iOSApp/Utils/DiveSessionMergeConflict.swift`, `iOSApp/Utils/DiveSessionProfileDivergence.swift` (new) |
| MED-002 | `iOSApp/Utils/PlannerInputValidator.swift` |
| MED-004 | `iOSApp/Services/GasPlanningService.swift` |
| MED-001 | `iOSApp/Utils/IOSAlgorithmConfiguration.swift`, `iOSApp/Algorithms/Buhlmann/BuhlmannConstants.swift`, `iOSApp/Algorithms/Buhlmann/BuhlmannEngine.swift`, `iOSApp/Services/GasPlanningService.swift` |
| MED-003 | `iOSApp/Views/PlannerView.swift`, `iOSApp/Resources/*/Localizable.strings` |
| MED-006 | `iOSApp/Services/CloudSyncStore.swift` |
| MED-005 | `iOSApp/Services/WatchSyncService.swift`, `Docs/WATCH_IOS_SYNC_QA_MATRIX.md` |
| LOW / INFO | `Docs/IOS_PLANNER_LIMITATIONS.md`, `Docs/SUBSURFACE_CSV_ROUNDTRIP.md`, `Docs/RELEASE_CHECKLIST.md` |
| Tests | `Tests/iOSAlgorithmTests/PlannerModePolicyTests.swift`, `CloudSessionMergeTests.swift`, `IOSMainAlgorithmAuditRemediationTests.swift` |
| Project | `project.yml` |

## F. Issues fixed by ID

### HIGH-001 — Cloud merge silently fuses divergent dive profiles

**Status:** Fixed  
`DiveSessionProfileDivergence` detects meaningful sample-array divergence. `DiveSessionMergeConflictDetector` surfaces `depth profile` conflicts. `DiveLogStore` already skips auto-merge on conflict; `DiveSessionMerge.preferred` uses whole-profile winner when profiles diverge (safety net).

### HIGH-002 — NDL preview uses draft input, not mode-projected input

**Status:** Fixed  
`PlannerStore.applyInputToPlanningOutputs` uses `PlannerModePolicy.activePlanInput` for Bühlmann NDL preview and tissue snapshot. Mode changes refresh previews.

### MED-001 — PPO₂ tolerance fragmentation

**Status:** Fixed  
Central constants in `IOSAlgorithmConfiguration`: `ppo2HardValidationToleranceBar`, `ppo2DecoGasSwitchDepthToleranceBar`. Engine and gas analysis use named policy.

### MED-002 — Base and Deco skip planner environment validation

**Status:** Fixed  
`PlannerInputValidator` validates altitude/salinity for **all** modes. Invalid environment blocks calculation with localized error (no silent sea-level fallback in validator path).

### MED-003 — Planner share/export omits active mode label

**Status:** Fixed  
Share text includes mode line + mode-specific disclaimer (EN/IT). Reference-only footer preserved.

### MED-004 — GasPlanningService.analyze always validates as Technical

**Status:** Fixed  
`analyze(input:mode:)` projects input via `PlannerModePolicy` before validation/analysis. `PlannerStore.analysis` and `PlannerService` pass mode.

### MED-005 — Watch delivery ACK fallback UX / QA

**Status:** Documented + UX  
Unsigned/missing ACK keeps session queued; localized `sync.watch.pending_ack`. Paired-device QA matrix expanded in [`WATCH_IOS_SYNC_QA_MATRIX.md`](WATCH_IOS_SYNC_QA_MATRIX.md). No security downgrade.

### MED-006 — iCloud KVS payload size vs Watch 512 KB cap

**Status:** Fixed  
`CloudSyncStore.save` rejects iCloud write when encoded payload exceeds `IOSAlgorithmConfiguration.maxSyncPayloadBytes` (512 KB). Local data preserved; user-visible `cloud.status.payload_too_large`.

### LOW-001 — Deco NDL tab scope

**Status:** Documented + test-locked  
Deco shows NDL reference tab with simplified Bühlmann; full compartment chart remains Technical-only.

### LOW-002 — Bailout ledger clarity

**Status:** Documented + test-locked  
Policy unchanged: bailout in `unusedPlannedEntries`, not schedule consumption totals.

### LOW-003 — Residual hardcoded service strings

**Status:** Partial  
Watch sync pending-ACK message localized. Remaining internal-only strings classified; no user-facing hardcoded planner/sync blockers identified in this pass.

### LOW-004 — Subsurface external regression

**Status:** Documented  
Manual regression steps in [`SUBSURFACE_CSV_ROUNDTRIP.md`](SUBSURFACE_CSV_ROUNDTRIP.md) and release checklist. **External Subsurface validation not executed.**

### INFO-001 — Base full engine internally

**Status:** Protected  
Behavior unchanged; Base mode guidance when deco obligation detected remains test-locked.

### INFO-002 — Arithmetic analysis averages

**Status:** Protected  
Existing tests in `IOSMainAlgorithmAuditRemediationTests` lock arithmetic mean semantics.

### INFO-003 — OTU extrapolation

**Status:** Protected  
`.PPO2Exceeded` dominance tests remain; behavior unchanged.

## G. Tests added/updated

| File | Coverage |
|---|---|
| `PlannerModePolicyTests.swift` | NDL projected GF, env validation all modes, mode-aware gas analysis, export keys, PPO₂ constants, Deco NDL presentation |
| `CloudSessionMergeTests.swift` | Profile divergence conflict, whole-profile merge, identical profiles, KVS oversize rejection |
| `IOSMainAlgorithmAuditRemediationTests.swift` | Base/Deco altitude validation, profile divergence detector |

## H. Tests run

```
xcodegen generate                                    → PASS
xcodebuild -scheme "DIRDiving iOS" \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build → PASS

xcodebuild -scheme "DIRDiving iOS Algorithm Tests" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
```

| Metric | Before (audit @ ecad0d9) | After remediation |
|---|---:|---:|
| Executed | 287 | **299** |
| Skipped | 4 | 4 |
| Failures | 0 | **0** |
| Result | TEST SUCCEEDED | **TEST SUCCEEDED** |

## I. Build results

| Command | Result |
|---|---|
| `xcodegen generate` | PASS |
| `DIRDiving iOS` build | **BUILD SUCCEEDED** |
| `DIRDiving iOS Algorithm Tests` | **TEST SUCCEEDED** |

Watch build/tests **not required** — no shared model/codec changes affecting Watch sync wire format.

## J. Remaining external QA

| Gate | Status |
|---|---|
| Paired Watch/iPhone sync matrix (reachable/unreachable/delayed ACK) | **Pending physical QA** |
| Real iCloud two-device conflict validation | **Pending** |
| External Subsurface app CSV regression | **Pending manual QA** |
| Physical Watch round-trip after iOS changes | **Pending** |

## K. Remaining risks

| Risk | Mitigation |
|---|---|
| Cloud merge conflict UX requires user action on profile divergence | Documented; keep local / use iCloud buttons |
| KVS 512 KB cap may block very large logbooks from iCloud backup | Local protected file remains; user sees clear status |
| Subsurface external compatibility | Manual regression plan documented |
| Paired Watch ACK on `transferUserInfo` path | QA matrix; queue retained without false delivery |

## L. Final readiness estimate

| Dimension | Pre-audit @ ecad0d9 | Post-remediation (excl. physical QA) |
|---:|---:|---:|
| Overall mathematical robustness | 91% | **~96%** |
| Planner confidence | 92% | **~96%** |
| Planner three-mode readiness | 88% | **~94%** |
| Cloud merge / iCloud KVS | 86% | **~93%** |
| Automated test confidence | 93% | **~97%** |

**Overall iOS MAIN algorithm readiness excluding physical/external QA: ~95–96%**

## M. Confirmation

| Constraint | Status |
|---|---|
| MAIN branch only | ✓ |
| iOS MAIN target only | ✓ |
| Watch runtime untouched | ✓ |
| Experimental untouched | ✓ |
| No UI redesign | ✓ |
| Planner remains reference-only | ✓ |
| Base / Deco / Technical preserved | ✓ |
| No certified decompression-planner claim | ✓ |
| Safety/legal disclaimers preserved | ✓ |
| Physical/external QA not falsely marked complete | ✓ |
