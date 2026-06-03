# Watch MAIN Algorithm Math Audit — Remediation Report

**Date:** 2026-06-03  
**Branch:** `main`  
**Base commit (pre-remediation):** `3f93914`  
**Target:** `DIRDiving Watch App` (Watch MAIN only)  
**Source audit:** [`WATCH_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](WATCH_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md)

---

## A. Branch confirmed

`main` — verified via `git branch --show-current`.

## B. Commit confirmed

Remediation implemented on top of `3f93914` (`docs: update Watch main algorithm audit report`). Working-tree changes pending commit.

## C. Target confirmed

`DIRDiving Watch App` per `project.yml` — Watch MAIN application target only.

## D. Experimental exclusions confirmed

Watch MAIN `project.yml` exclusions unchanged:

- `Models/ExplorationModels.swift`, `BuddyAssistMessage.swift`, `BuddyPairingHandshake.swift`
- `Services/ExplorationStore.swift`, `BuddyAssistService.swift`, `BuddyAssistPeripheralService.swift`, `BuddyPairingKeyAgreement.swift`, `SecureBuddyStore.swift`
- `Views/ApneaView.swift`, `SnorkelingView.swift`, `BuddyAssistView.swift`, `ExperimentalConceptsView.swift`
- `Utils/ExperimentalFeatures.swift`

No experimental files modified.

## E. Files modified

| File | Purpose |
|------|---------|
| `Services/DiveManager.swift` | Pending finalization draft (HIGH-001); frozen-depth context (MED-002); test hooks |
| `Services/DiveLogStore.swift` | Load-time validation filter + resilient decode (MED-003) |
| `Utils/DiveLogbookPolicy.swift` | `filterValidLoadedSessions` helper |
| `Utils/DepthSampleValidation.swift` | Suppress frozen classification when inactive (MED-002) |
| `Services/DepthLimitHapticCoordinator.swift` | Transition-generation token for delayed haptics (LOW-004) |
| `Utils/DiveAlgorithmSelfCheck.swift` | Ascent limit 45 m → 1 m/min (LOW-005) |
| `Services/GPSManager.swift` | Test hooks for held GPS capture |
| `Tests/WatchAlgorithmTests/WatchMainAlgorithmAuditRemediationTests.swift` | New audit remediation test suite |
| `Tests/WatchAlgorithmTests/DiveAlgorithmTests.swift` | Frozen inactive surface, self-check, alarm `>` tests |
| `project.yml` | Include `DiveAlgorithmSelfCheck.swift` in Watch Algorithm Tests |

## F. Issues fixed by ID

### WATCHMATH-HIGH-001 — Active dive draft survives exit GPS finalization window

**Fix:** `ActiveDiveDraft` now carries `phase` (`.active` / `.finalizing`), stable `sessionID`, and end metadata. `endDiveIfNeeded` persists a **finalizing** draft immediately before the 6 s exit GPS capture. On launch, `restoreActiveDiveDraftIfAvailable` completes pending finalization instead of restoring an ended dive as active. Finalization is idempotent by `sessionID`; exit GPS uses best available data or `.noFix`.

### WATCHMATH-MED-002 — Frozen-depth false warnings for stable surface / simulator

**Fix:** `DepthSampleValidationState.validate(..., isDiveActive:)` only returns `.frozen` during an **active** dive. Inactive pre-dive streams (mock 0 m, stable surface) continue accepting samples without user-facing frozen errors. Active-dive frozen/stale protection unchanged.

### WATCHMATH-MED-003 — Invalid legacy sessions visible after load

**Fix:** `DiveLogbookPolicy.filterValidLoadedSessions` applied during `DiveLogStore` load/reload (after merge). Invalid sessions are quarantined; `loadErrorMessage` reports count. Resilient per-entry JSON decode prevents one corrupt row from blocking valid sessions. Valid manual/no-depth sessions still load per policy.

### WATCHMATH-LOW-004 — Delayed depth-limit haptics after state changes

**Fix:** `DepthLimitHapticCoordinator` increments `transitionGeneration` on state changes and reset. Delayed secondary pulses capture the token and verify `transitionGeneration`, `lastState`, and global haptics preference before playing.

### WATCHMATH-LOW-005 — DiveAlgorithmSelfCheck stale ascent-limit expectation

**Fix:** Self-check cases updated: 45 m and 40.01 m → **1 m/min**, aligned with `AscentRateLimits.standard` and `DiveAlgorithmTests.testAscentLimitBandsAndZoneBoundaries`.

### WATCHMATH-INFO-006 — Alarm exact-boundary strict `>` behavior

**Fix:** Preserved strict `>` semantics (`maxDepthMeters > threshold`, `runtime > threshold * 60`). Tests document boundary: at threshold does not fire; just above fires. UI copy already uses “>” wording.

### WATCHMATH-INFO-007 — Mission Mode remains non-mathematical

**Fix:** Verified unchanged — Mission Mode affects only UI/runtime decorative profile. Regression tests retained/extended in `MissionModeAlgorithmInvariantTests` and remediation suite.

## G. Tests added

New file `Tests/WatchAlgorithmTests/WatchMainAlgorithmAuditRemediationTests.swift`:

- Pending finalization: normal end, termination during GPS, active restore, idempotency, no-fix fallback
- Frozen depth: inactive 0 m stream, active dive frozen
- Load filter: invalid quarantine, depth cap, manual no-depth, 40-log cap
- Delayed haptics: critical/exceeded suppress on rapid clear; allow when state holds; global haptics off
- Self-check + alarm `>` boundaries + Mission Mode invariant

Updates in `DiveAlgorithmTests.swift`: inactive surface frozen acceptance, self-check pass, alarm strict `>`.

## H. Tests run

```text
xcodegen generate                          — PASS
xcodebuild -scheme "DIRDiving Watch App"   — PASS (watchOS Simulator, Apple Watch Ultra 3 49mm)
xcodebuild test -scheme "DIRDiving Watch Algorithm Tests" — PASS (88 tests, 0 failures)
```

iOS build/tests **not run** — no shared model/sync files required changes beyond Watch-local `DiveLogStore` (Watch target only).

## I. Build results

| Command | Result |
|---------|--------|
| `xcodegen generate` | PASS |
| Watch App build | PASS |
| Watch Algorithm Tests (88) | PASS |

## J. Remaining physical QA

Cannot be closed by code alone — see [`WATCH_MAIN_HARDWARE_ALGORITHM_QA_CHECKLIST.md`](WATCH_MAIN_HARDWARE_ALGORITHM_QA_CHECKLIST.md):

- Depth entitlement + real CoreMotion submersion API on Apple Watch Ultra
- Live depth sensor, stable-depth hold, real haptics
- GPS fix / fallback / no-fix in field
- Pending-finalization recovery on **forced app kill** during 6 s exit window (field confirmation)
- WatchConnectivity sync + tombstones
- App Intents / Action Button
- Underwater / paired-device scenarios

## K. Remaining risks

| Risk | Mitigation |
|------|------------|
| Physical kill during GPS window not exercised in CI | Field test B4/B5 in hardware checklist |
| Quarantined invalid sessions not shown in UI list | `loadErrorMessage` set; no silent corruption |
| Simulator mock 0 m ≠ real sensor jitter at surface | Ultra field validation for A6 |
| iOS `DiveLogStore` is separate codebase path | Watch-only load filter; iOS has its own policy |

## L. Final readiness estimate

**Algorithmic / code-fixable readiness: 100%** for Watch MAIN excluding physical QA.

All audit IDs WATCHMATH-HIGH-001 through WATCHMATH-INFO-007 addressed with tests or verification. Physical Watch Ultra QA remains the external gate before App Store.

## M. Confirmation

- [x] MAIN only (`main` branch)
- [x] Watch MAIN only (no iOS algorithm changes)
- [x] Experimental targets untouched
- [x] No UI redesign or graphics changes
- [x] Watch TTV unchanged (`timeWeightedAverageDepthMeters + runtimeMinutes`)
- [x] No NDL / TTS / decompression on Watch
- [x] Mission Mode remains non-mathematical
- [x] No certified dive-computer claim introduced
- [x] Safety / legal disclaimers preserved
- [x] Depth safety thresholds 35 / 38 / 40 m unchanged
- [x] Ascent-rate band policy unchanged
