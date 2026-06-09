# DIR DIVING MAIN Deep Code Analysis, Bug, Performance, and Security Audit

Date: 2026-06-09  
Scope: MAIN branch only  
Target branch: `main`  
Audited commit: `dba1a22` (`dba1a227aa96fcd22c257c7029aa8979b238d1e3`)  
Repository: DIR DIVING  
Output file: `Docs/MAIN_DEEP_CODE_ANALYSIS_BUG_PERFORMANCE_SECURITY_AUDIT_CURRENT.md`

---

## A. Executive Summary

This audit was performed against branch `main` only at commit `dba1a22`, immediately after UI/UX remediation (`dba1a22`). The working tree was clean before the report was created; `git status -sb` reported `## main...origin/main`.

**No production source code, UI, business logic, algorithms, security model, sync model, planner mode logic, or experimental files were modified during this audit.**

### Build and Test Evidence (macOS / Xcode)

| Command | Result |
|---|---|
| `xcodegen generate` | **PASS** — project created at `DIRDiving.xcodeproj` |
| `xcodebuild -scheme "DIRDiving iOS" -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build` | **BUILD SUCCEEDED** |
| `xcodebuild -scheme "DIRDiving Watch App" -destination 'generic/platform=watchOS Simulator,name=Apple Watch Ultra 3 (49mm)' CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build` | **BUILD SUCCEEDED** (preflight) |
| `xcodebuild -scheme "DIRDiving iOS Algorithm Tests" -destination 'platform=iOS Simulator,name=iPhone 17 Pro' CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO test` | **TEST SUCCEEDED** — 554 passed, 13 skipped, 0 failed |
| `xcodebuild -scheme "DIRDiving Watch Algorithm Tests" -destination 'platform=watchOS Simulator,name=Apple Watch Ultra 3 (49mm)' CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO test` | **TEST SUCCEEDED** — 188 passed, 13 skipped, 0 failed |

### Readiness Percentages

These percentages are static-audit + build/test readiness estimates. Physical and external QA remain **PENDING** and are not counted as passed.

| Readiness area | Estimate | Rationale |
|---|---:|---|
| Overall static code readiness | 82% | Builds and algorithm tests pass; several HIGH planner/sync/Watch-runtime issues remain. |
| Watch MAIN readiness | 86% | Strong algorithm coverage, legal gate, HMAC sync, mission-mode tests; ACK-on-userInfo gap and per-sample draft I/O remain. |
| iOS MAIN readiness | 78% | Broad planner/CCR coverage; mode-projected MOD gating and analysis cache staleness are user-visible bugs. |
| Bug risk readiness | 80% | Confirmed logic bugs in planner gating and Watch manual-end intent; no CRITICAL crash found statically. |
| Performance readiness | 74% | Per-sample active-dive draft persistence and planner SwiftUI churn need budgets. |
| Security readiness | 84% | HMAC v2, TOFU pinning, signed ACKs, photo-management auth, replay cache; peer secret in `applicationContext` and Watch KVS cap gap remain. |
| Privacy readiness | 81% | Protected persistence on iOS log/sync files; PDF export now uses complete file protection. |
| Data integrity readiness | 76% | iOS outbound queue retains pending until signed ACK (fixed); Watch inbound ACK on `transferUserInfo` and merge-policy divergence remain. |
| Sync/cloud readiness | 74% | Bidirectional dive sync mostly sound; Watch KVS lacks iOS-style payload preflight. |
| CCR / Rebreather readiness | 83% | CCR planner, validator, checklist import present; Ratio Deco correctly blocked in CCR; external CCR QA pending. |
| Internal TestFlight readiness | **Not ready** | Fix HIGH planner + Watch sync ACK issues; complete simulator paired-sync QA. |
| External TestFlight readiness | **Not ready** | Physical Watch Ultra, paired-device, iCloud two-device, Subsurface QA all pending. |
| App Store readiness | **Not ready** | External QA, privacy wording review, and HIGH issue remediation required. |

### Most Urgent Issues

1. **MAIN-DCA-004** — Planner `liveMODIssues` validates full draft gases, not mode-projected input; can block Base/Deco calculate after Technical editing.
2. **MAIN-DCA-001** — Watch does not parse inbound `diveImportAck` on `transferUserInfo`; Watch→iOS pending queue may not drain when iPhone replies via queued path.
3. **MAIN-DCA-008** — `persistActiveDiveDraft()` runs on every accepted depth sample during an active dive (I/O and battery risk).
4. **MAIN-DCA-007** — `EndManualDiveIntent` becomes a no-op after manual→automatic handoff on submersion.
5. **MAIN-DCA-002** — Watch `CloudSyncStore` writes unbounded payloads to KVS without iOS-style size guard.

No **CRITICAL** (crash/data-loss-without-mitigation) issue was confirmed. Highest confirmed severity is **HIGH** across planner gating, sync ACK asymmetry, and Watch runtime I/O.

### Improvements Since Prior Audit (`8c7d6e6`)

| Prior ID | Status at `dba1a22` |
|---|---|
| iOS outbound sync drops pending without signed ACK | **Fixed** — `IOSWatchSyncPendingQueuePolicy`, protected outbound queue, `confirmSignedAck` |
| PDF temp without complete file protection | **Fixed** — `PDFDocumentBuilder.swift` uses `.completeFileProtection` |
| Unsigned photo management (partial) | **Improved** — `CompanionPhotoManagementAuth` + replay caches |
| UI/UX P1 localization/a11y gaps | **Remediated** in `dba1a22` UI/UX pass (separate report) |

---

## B. Scope Confirmation

### Git / Remote State

| Check | Result |
|---|---|
| Branch | `main` |
| Commit | `dba1a22` |
| Remote alignment | `## main...origin/main` |
| Dirty files before report | None |
| Experimental branches | Not touched |
| Apnea/Snorkeling/Buddy Assist/Exploration Lab | Excluded from MAIN targets; not edited |

### Targets In `project.yml`

| Target | Platform | Bundle ID |
|---|---|---|
| `DIRDiving Watch App` | watchOS | `com.egopfe.dirdiving.ios.watch` |
| `DIRDiving iOS` | iOS | `com.egopfe.dirdiving.ios` |
| `DIRDiving Watch Algorithm Tests` | watchOS tests | `com.egopfe.dirdiving.watch.algorithmtests` |
| `DIRDiving iOS Algorithm Tests` | iOS tests | `com.egopfe.dirdiving.ios.algorithmtests` |

### Entitlements

Both Watch and iOS declare iCloud container `iCloud.com.egopfe.dirdiving`, CloudKit, and ubiquity KVS `$(TeamIdentifierPrefix)com.egopfe.dirdiving`.

### Static Scan Summary

| Scan | Result |
|---|---|
| Force unwrap / `try!` / `as!` | No production `try!`/`as!` blocker. `PlannerView.swift` retains guarded `columnHeaders!` in table helper (~2420). |
| Hardcoded secrets | None found in MAIN production code. |
| TODO/FIXME | No MAIN release blocker from scan. |
| File protection | iOS log/sync/outbound queue use `.completeFileProtection`; PDF export protected. |
| WatchConnectivity | HMAC v2 envelopes, signed ACKs, nonce replay cache on Watch codec; asymmetric ACK ingestion on Watch `didReceiveUserInfo`. |

### Inspected Areas

`App/`, `Models/`, `Services/`, `Utils/`, `Views/`, `iOSApp/**`, `Tests/WatchAlgorithmTests/`, `Tests/iOSAlgorithmTests/`, `Config/`, `Docs/` (release/QA context).

---

## C. Architecture Analysis

### Watch

Watch MAIN excludes experimental features via `project.yml`. Runtime is centered on:

- **Dive lifecycle:** `DiveManager.swift`, `DiveLogStore.swift`
- **Sensors:** `DepthSensorProvider`, `AppleDepthSensorProvider`, `MockDepthSensorProvider`, `SensorProviderFactory`
- **Sync:** `WatchSyncService.swift`, `WatchDiveSyncCodec.swift`, `WatchSyncAuth.swift`
- **Cloud:** `CloudSyncStore.swift` (Watch copy — simpler than iOS)
- **Safety / mission mode:** `MissionModeLifecycle`, depth safety, legal gate on App Intents
- **Photos:** companion photo import, inventory/delete via signed management payloads

Strengths: two-phase active dive draft, simulation release migration, mission mode invariant tests, legal acceptance gate on all safety intents.

### iOS Companion

- **Planner:** three-mode OC architecture (Base / Deco / Technical) plus CCR mode via `PlannerModePolicy`, `PlannerStore`, `PlannerService`, `GasPlanningService`
- **Bühlmann / deco:** `BuhlmannPlanner`, tissue snapshots, Ratio Deco (OC only)
- **CCR:** `CCRPlannerService`, `CCRPlanValidator`, checklist import/export coordinators
- **Logbook / sync:** `DiveLogStore`, `WatchSyncService` (iOS), cloud merge via rich `iOSApp/Utils/DiveSessionMerge.swift`
- **Import/export:** Subsurface CSV, PDF builder, CCR PDF paths

Strengths: mode-projected planning in `PlannerModePolicy.activePlanInput`, divergent profile merge policy on iOS, KVS payload cap on iOS `CloudSyncStore`.

### Cross-App Integration

```
Watch dive complete → WatchSyncService (HMAC) → iOS import → signed ACK → Watch dequeue
iOS dive export → iOS WatchSyncService (pending queue) → Watch import → signed ACK → iOS dequeue
iCloud KVS ← CloudSyncStore (iOS capped, Watch uncapped) → DiveLogStore merge
```

---

## D. iOS Planner Three-Mode Architecture Audit

| Check | Status | Evidence |
|---|---|---|
| Modes affect visible inputs | **PASS** | `PlannerModePresentation`, mode-specific sections in `PlannerView.swift` |
| Modes affect calculation projection | **PASS** | `PlannerModePolicy.activePlanInput`, `PlannerService.makePlan(input:mode:)` |
| Mode switching preserves draft technical gases | **PASS** | Draft retained; projection strips non-mode gases |
| NDL / Bühlmann uses projected input | **PASS** | `PlannerStore.applyInputToPlanningOutputs` uses `activePlanInput` |
| Gas preview analysis uses mode projection | **PASS** | `GasPlanningService.analyze(input:mode:)` projects first |
| **MOD live gating uses projected input** | **FAIL** | `liveMODIssues` calls `PlannerMODValidator.liveInputIssues(input: store.input)` on full draft (`PlannerView.swift:819-820`) |
| **Analysis cache invalidation completeness** | **PARTIAL** | `AnalysisCacheKey` omits SAC, planning depth reference, avg depth (`PlannerStore.swift:386-407`) |
| CCR mode separate from OC three-mode | **PASS** | `mode.isCCR` branches in `PlannerStore` |
| Ratio Deco blocked in CCR | **PASS** | `PlannerService.makePlan` returns `nil` ratio bundle when `mode == .ccr` |
| Share/export includes planner mode | **PASS** | `PlannerState` persists `mode`; export paths tested |

**Regression scenario (MAIN-DCA-004):** User edits Technical travel gas with MOD violation, switches to Base mode. `PlannerModePolicy.validate` passes (projected Base input), but `liveMODIssues` still flags hidden Technical cylinders → **Calculate** disabled incorrectly.

---

## E. iOS Planner MOD / PPO2 / Switch-Depth Audit

| Check | Status | Notes |
|---|---|---|
| O2 / max PPO2 recalculates MOD | **PASS** | `PlannerMODValidator`, `GasMix.modMeters(environment:)` |
| Switch depth clamped to MOD | **PASS** | `clampAllSwitchDepthsToMOD`, cylinder bindings |
| Environment-aware MOD | **PASS** | `PlannerEnvironment` used in validator |
| Non-bottom gases normalized | **PASS** | `syncLegacyGasesFromPlannerCylinders` + validator |
| **Altitude/salinity reclamp on env change** | **PARTIAL** | `clampAllSwitchDepthsToMOD` only wired in Technical UI block (`PlannerView.swift:287-308`) |
| **Base results END labeled MOD** | **FAIL** | `PlannerView.swift:2422` — `DIRMetricTile(title: "MOD", value: … endMeters …)` |
| Recursive `.onChange` loops | **PASS** | No confirmed infinite loop; debounced planner updates in `PlannerStore` |
| CCR bailout MOD tolerance | **PASS** | `CCRPlanValidator` allows `switchDepthMeters > mod + 0.5` (OC uses tighter policy) |
| CCR checklist import switch depth | **PARTIAL** | Import matches gases/setpoints; switch depth not reconciled (`MAIN-DCA-015`) |

---

## F. CCR / Rebreather Audit

| Area | Status | Notes |
|---|---|---|
| CCR planning engine | **PASS** | `CCRPlannerService`, tissue/CNS/OTU integration |
| Setpoint / diluent / bailout validation | **PASS** | `CCRPlanValidator` |
| Ratio Deco in CCR | **PASS** | Blocked at `PlannerService` |
| CCR checklist import (UI/UX remediation) | **PASS** | `CCRChecklistImportCoordinator`, `CCRChecklistImportSheet` |
| CCR cloud persistence | **PASS** | `CCRPlanInput` in `PlannerState` |
| CCR PDF/export | **PASS** | Covered in iOS algorithm tests |
| CCR external physical QA | **PENDING** | No in-water CCR validation executed |

---

## G. Apple Watch MAIN Semantics Audit

| Semantics | Status | Notes |
|---|---|---|
| Manual vs automatic dive start | **PASS** with gap | Handoff on submersion works; end-intent gap (`MAIN-DCA-007`) |
| Mission Mode invariants | **PASS** | Tests in `WatchCompleteAlgorithmAuditRemediationTests` |
| Mission pending lost on crash restore | **FAIL** | `missionModeManualPendingForSession` not in `ActiveDiveDraft` (`MAIN-DCA-009`) |
| Sensor source / simulation release | **PASS** | Release migration tested |
| App Intents legal gate | **PASS** | `requireLegalAcceptanceForSafetyIntent()` on all safety intents |
| TTV / ascent / depth algorithms | **PASS** | 188 Watch algorithm tests pass |
| End manual dive via Action Button | **PARTIAL** | No-op after handoff (`MAIN-DCA-007`) |

---

## H. Watch Image Inventory / Delete Analysis

| Check | Status | Notes |
|---|---|---|
| Watch source-of-truth for photos | **PASS** | Watch stores; iOS requests inventory |
| Signed management payloads | **PASS** | `CompanionPhotoManagementAuth` |
| Path traversal protection | **PASS** | `sanitizedPhotoFileName` on iOS |
| Delete ACK flow | **PASS** | Request/ACK via WC message + userInfo fallback |
| Replay protection | **PASS** | Separate request/response replay caches |
| Paired physical QA | **PENDING** | Not executed in this audit |

---

## I. Cross-App Sync / Data Integrity Analysis

### Watch → iOS

- HMAC v2 signed dive payloads with nonce replay cache (`WatchDiveSyncCodec`)
- iOS imports via `importSessionPayload`, replies with signed `ackSignature` on direct message
- iOS handles `diveImportAck` on both `didReceiveMessage` and `didReceiveUserInfo` (`WatchSyncService.swift:963-967`)

### iOS → Watch

- Outbound sessions queued in protected `dirdiving_ios_pending_watch_sync_sessions.json`
- Dequeue **only** after `confirmSignedAck` — **fixed** since prior audit
- Watch imports via `ingestIncomingPayload`, emits ACK via `deliverImportAck`

### Gap: iOS ACK → Watch on `transferUserInfo`

When iPhone imports Watch dive offline and sends ACK via `transferUserInfo`, Watch `didReceiveUserInfo` only calls `ingestIncomingPayload` (expects dive sessions, not ACKs). Watch codec has `isImportAck` but **no** `parseImportAck` (iOS-only in `iOSApp/Services/WatchDiveSyncCodec.swift`). Pending Watch→iOS transfers are not dequeued on this path.

### Cloud Merge

- **iOS:** Rich merge with divergent-profile policy, manual metadata, SAC, notes
- **Watch:** Simpler `Utils/DiveSessionMerge.swift` — drops site/buddy/notes/equipment (`MAIN-DCA-006`)
- Profile conflict: iOS uses `DiveSessionProfileDivergence` — **PASS** on iOS

### Peer Trust

- TOFU peer secret via `WatchSyncAuth`; mismatch flagged
- Peer secret also published in `applicationContext` — convenience vs. exposure tradeoff (`MAIN-DCA-013`)

---

## J. Performance Analysis

| Risk | Severity | Location | Impact |
|---|---|---|---|
| Per-sample active dive draft write | **HIGH** | `DiveManager.addSample` → `persistActiveDiveDraft()` | Disk I/O every depth tick; battery/flash wear |
| Planner debounced recalculation | **LOW** | `PlannerStore.schedulePlanningUpdate` 200ms debounce | Acceptable; cache staleness is correctness not perf |
| `redWarningBlink` timer toggle | **MEDIUM** | `DiveManager` ~2.2 Hz `redWarningBlink.toggle()` | SwiftUI invalidation during alarms |
| CSV import full-string parse | **LOW** | `DiveImportService` | Bounded by import caps in tests |
| Cloud sync status churn | **LOW** | `CloudSyncStore.publishDeferred` | Minor UI updates |
| CCR chart rendering | **LOW** | SwiftUI charts with accessibility summaries | Acceptable on simulator |

---

## K. Security / Privacy Analysis

| Area | Status | Notes |
|---|---|---|
| Dive sync HMAC + nonce replay | **PASS** | Watch codec; iOS codec mirrored |
| Signed import ACKs | **PASS** | Both platforms verify before dequeue |
| Photo management signing | **PASS** | `CompanionPhotoManagementAuth` |
| iOS KVS payload cap | **PASS** | `IOSAlgorithmConfiguration.maxSyncPayloadBytes` |
| Watch KVS payload cap | **FAIL** | `Services/CloudSyncStore.swift` — no preflight |
| PDF export protection | **PASS** | `.completeFileProtection` |
| GPS privacy | **PASS** | No network upload; local/logbook only |
| Peer secret in `applicationContext` | **MEDIUM** | Encrypted WC channel but broad exposure surface |
| Replay cache persistence | **MEDIUM** | In-memory only; replays possible after relaunch until window expires |
| Secret scanning | **PASS** | No keys/tokens in repo |
| App Intents safety gate | **PASS** | Legal acceptance required |

---

## L. Test Coverage Analysis

| Suite | Passed | Skipped | Failed |
|---|---:|---:|---:|
| iOS Algorithm Tests (iPhone 17 Pro sim) | 554 | 13 | 0 |
| Watch Algorithm Tests (Ultra 3 49mm sim) | 188 | 13 | 0 |

**Strengths:** Planner mode projection, MOD validator, sync ACK policy, mission mode, CCR validator, UI/UX remediation tests (`UIUXRemediationV3AccessibilityTests`, `UIUXLocalizationRemediationTests`), `MainDeepCodeAuditRemediationTests`.

**Gaps (missing or weak):**

- Watch inbound `diveImportAck` via `transferUserInfo` end-to-end
- `EndManualDiveIntent` after manual→auto handoff
- `liveMODIssues` mode-projected gating regression
- `AnalysisCacheKey` SAC / planning-reference staleness
- Watch `CloudSyncStore` oversized payload rejection
- Active dive draft write frequency budget
- Physical/external QA matrices (all **PENDING**)

---

## M. Issue Matrix

| ID | Severity | Priority | App | Area | File / Function | Title | User Impact | Sec/Perf Impact | Proposed Fix | Effort |
|---|---|---|---|---|---|---|---|---|---|---|
| MAIN-DCA-001 | HIGH | P1 | Watch | Sync | `Services/WatchSyncService.swift` `didReceiveUserInfo`; `WatchDiveSyncCodec` | Watch ignores inbound `diveImportAck` on userInfo path | Duplicate dive exports; stale pending queue | Data integrity | Add `parseImportAck` on Watch; handle ACK in `didReceiveUserInfo` like iOS | M |
| MAIN-DCA-002 | HIGH | P1 | Watch | Cloud | `Services/CloudSyncStore.swift` `save` | No KVS payload size cap | Sync failures / KVS rejection at runtime | Perf/privacy | Mirror iOS `maxSyncPayloadBytes` preflight before write | S |
| MAIN-DCA-003 | HIGH | P1 | Watch | Cloud | `Services/CloudSyncStore.swift` `load`/`save` | Legacy full sessions may populate KVS | Slow sync, quota exhaustion | Privacy | Migration to cap-compliant snapshots; reject oversize on load | M |
| MAIN-DCA-004 | HIGH | P1 | iOS | Planner | `PlannerView.swift` `liveMODIssues` | MOD gate uses full draft not mode-projected input | Base/Deco calculate blocked incorrectly | Safety UX | Use `PlannerModePolicy.activePlanInput` before `liveInputIssues` | S |
| MAIN-DCA-005 | HIGH | P1 | iOS | Planner | `PlannerStore.swift` `AnalysisCacheKey` | Cache omits SAC, planning ref, avg depth | Stale gas preview after SAC/depth ref change | Correctness | Extend cache key fields | S |
| MAIN-DCA-006 | HIGH | P1 | Both | Merge | `Utils/DiveSessionMerge.swift` vs `iOSApp/Utils/DiveSessionMerge.swift` | Divergent merge implementations | Metadata loss on Watch cloud path | Data integrity | Unify or document single policy; port iOS fields to Watch | L |
| MAIN-DCA-007 | HIGH | P1 | Watch | Runtime | `ActionButtonIntents.swift` `EndManualDiveIntent`; `DiveManager.endManualDive` | End intent no-op after manual→auto handoff | User cannot end dive via Action Button | Safety UX | End dive when `sessionStartedManually` even if `isManualLifecycleActive` false | S |
| MAIN-DCA-008 | HIGH | P1 | Watch | Performance | `DiveManager.addSample` → `persistActiveDiveDraft` | Draft persisted every depth sample | Battery drain; UI jank risk | Performance | Throttle/coalesce draft writes (e.g. every N seconds) | M |
| MAIN-DCA-009 | MEDIUM | P2 | Watch | Mission | `DiveManager.ActiveDiveDraft` | `missionModeManualPendingForSession` not persisted | Mission mode intent lost on crash mid-dive | UX/safety | Add field to draft schema v2 | M |
| MAIN-DCA-010 | MEDIUM | P2 | iOS | Planner UI | `PlannerView.swift` ~2422 | Base result shows END value under "MOD" label | Misleading gas metrics | Safety UX | Change title to "END" or bind MOD field | S |
| MAIN-DCA-011 | MEDIUM | P2 | iOS | Planner | `PlannerView.swift` altitude/salinity onChange | Env reclamp only in Technical UI | Stale switch depths in Base/Deco if env edited elsewhere | Safety | Call `clampAllSwitchDepthsToMOD` on env change for all modes | S |
| MAIN-DCA-012 | MEDIUM | P2 | Watch | UI perf | `DiveManager` red warning blink timer | ~2.2 Hz SwiftUI toggle | Extra CPU during alarms | Performance | Reduce frequency or use animation API | S |
| MAIN-DCA-013 | MEDIUM | P2 | Both | Security | `WatchSyncAuth.publishSharedSecretIfNeeded` | Peer secret in `applicationContext` | Broader secret exposure if context leaked | Security | Document threat model; consider message-only secret bootstrap | M |
| MAIN-DCA-014 | MEDIUM | P2 | Both | Security | `SyncNonceReplayCache` | Replay cache in-memory only | Replay after relaunch within TTL | Security | Optional persisted replay window or monotonic issuedAt ledger | M |
| MAIN-DCA-015 | MEDIUM | P2 | iOS | CCR | `CCRChecklistImportCoordinator` | Import ignores bailout switch depth reconciliation | Manual fix after import | CCR safety | Map switch depths through MOD validator on import | S |
| MAIN-DCA-016 | LOW | P3 | iOS | Privacy | Photo staging temp files | Staging paths may lack complete protection | Forensic exposure window | Privacy | Apply complete protection to staged imports | S |
| MAIN-DCA-017 | LOW | P3 | iOS | Hardening | `PlannerView.swift` table helper | Reachable `columnHeaders!` force unwrap | Crash on malformed table config | Stability | Safe index or empty fallback | S |
| MAIN-DCA-018 | INFO | P1 | Both | QA process | All physical QA matrices | External QA not executed | Unknown real-device behavior | Release | Execute matrices; mark PENDING only | L |

---

## N. Detailed Action Plan

### P0

No P0 blocker confirmed. Builds and algorithm tests pass.

### P1

1. **MAIN-DCA-004** — Mode-projected MOD gating  
   - Files: `PlannerView.swift`, `PlannerMODValidator.swift`, tests  
   - Order: Fix gating → add regression test (Technical gas hidden in Base)  
   - Risk: Low  
   - Acceptance: Base calculate works with stored Technical cylinders that are out of MOD for hidden gases  

2. **MAIN-DCA-001** — Watch ACK on userInfo  
   - Files: `WatchDiveSyncCodec.swift`, `WatchSyncService.swift`, sync tests  
   - Order: Port `parseImportAck` → wire delegate → paired sim test  
   - Risk: Medium sync regression  
   - Acceptance: Pending queue drains when iOS ACK arrives via `transferUserInfo`  

3. **MAIN-DCA-008** — Throttle draft persistence  
   - Files: `DiveManager.swift`, performance tests  
   - Order: Add coalescing → verify crash restore still within TTL  
   - Risk: Medium data-loss if throttle too aggressive  
   - Acceptance: Draft restore within configured max staleness; fewer writes per dive  

4. **MAIN-DCA-007** — End manual dive after handoff  
   - Files: `DiveManager.swift`, `ActionButtonIntents.swift`, intent tests  
   - Acceptance: `EndManualDiveIntent` ends active dive started manually after submersion handoff  

5. **MAIN-DCA-002 / MAIN-DCA-003** — Watch cloud payload cap  
   - Files: `Services/CloudSyncStore.swift`, `IOSAlgorithmConfiguration` shared constant  
   - Acceptance: Oversize save rejected; status message shown  

6. **MAIN-DCA-005** — Analysis cache key completeness  
   - Files: `PlannerStore.swift`, planner tests  
   - Acceptance: SAC / planning reference changes invalidate preview  

7. **MAIN-DCA-006** — Merge policy alignment  
   - Files: both `DiveSessionMerge.swift` copies  
   - Acceptance: Watch cloud merge preserves manual metadata or documents intentional subset  

8. **MAIN-DCA-018** — Execute external QA (process)  
   - No code change; evidence folders under `Docs/QA_EVIDENCE/`  

### P2

- MAIN-DCA-009 mission draft field  
- MAIN-DCA-010 MOD/END label  
- MAIN-DCA-011 env reclamp all modes  
- MAIN-DCA-012 blink frequency  
- MAIN-DCA-013 peer secret threat model / hardening  
- MAIN-DCA-014 replay persistence  
- MAIN-DCA-015 CCR import switch depths  

### P3

- MAIN-DCA-016 photo staging protection  
- MAIN-DCA-017 safe table headers  

### P4

- Documentation-only threat-model updates for sync/cloud  
- Legacy alias cleanup (`GasMixCard` shim) if still present  

---

## O. 7-Day Remediation Plan

| Day | Actions | Expected output | Verification |
|---|---|---|---|
| 1 | Fix MAIN-DCA-004, MAIN-DCA-005; add planner regression tests | Mode-correct MOD gating and cache | iOS algorithm tests |
| 2 | Fix MAIN-DCA-001; extend sync tests | Watch ACK on userInfo | Paired simulator sync script |
| 3 | Fix MAIN-DCA-007, MAIN-DCA-009 | Manual end + mission draft | Watch algorithm + intent tests |
| 4 | Fix MAIN-DCA-008 with throttling | Reduced draft I/O | Performance log / unit budget test |
| 5 | Fix MAIN-DCA-002/003, MAIN-DCA-010/011 | Cloud cap + planner labels | Cloud + planner tests |
| 6 | P2 security/perf (MAIN-DCA-012–015) | Hardening pass | Targeted tests |
| 7 | Full build/test + internal TestFlight checklist draft | Readiness note | Both schemes green |

---

## P. 14-Day Remediation Plan

| Days | Focus | Output |
|---|---|---|
| 1–3 | P1 planner + sync fixes | Green regression suite |
| 4–6 | Watch runtime + cloud | Draft I/O + KVS cap |
| 7–8 | CCR import hardening + merge alignment | CCR + merge tests |
| 9–10 | Paired Watch/iPhone simulator QA | `WATCH_IOS_SYNC_QA_MATRIX` evidence |
| 11–12 | iCloud two-device QA | `ICLOUD_TWO_DEVICE_QA_MATRIX` evidence |
| 13 | Physical Watch Ultra QA | `WATCH_ULTRA_PHYSICAL_QA_MATRIX` — **PENDING until executed** |
| 14 | Release dossier update | TestFlight gate checklists |

---

## Q. Pre-Internal-TestFlight Checklist

- [x] `xcodegen generate` passes on macOS
- [x] `DIRDiving Watch App` builds (Ultra 3 simulator)
- [x] `DIRDiving iOS` builds (iOS Simulator)
- [x] Watch algorithm tests pass (188/188 executed, 13 skipped)
- [x] iOS algorithm tests pass (554/554 executed, 13 skipped)
- [ ] MAIN-DCA-001 Watch ACK userInfo fixed
- [ ] MAIN-DCA-004 planner MOD gating fixed
- [ ] MAIN-DCA-008 draft I/O throttled
- [ ] Legal/safety onboarding blocks safety shortcuts until accepted
- [ ] No experimental views in MAIN targets
- [ ] No physical QA claimed as passed

---

## R. Pre-External-TestFlight Checklist

- [ ] All internal TestFlight items complete
- [ ] Paired Watch/iPhone direct + queued sync both directions
- [ ] Signed ACK rejection scenarios pass
- [ ] Companion photo inventory/delete with signed payloads
- [ ] iCloud opt-in/off/tombstone/conflict on two devices
- [ ] Planner rapid-edit performance acceptable
- [ ] Physical Watch Ultra QA — **PENDING**
- [ ] App copy remains non-certified and reference-only

---

## S. Pre-App-Store Checklist

- [ ] All external TestFlight items complete
- [ ] Physical QA evidence archived with device/OS versions
- [ ] Subsurface import/export external validation — **PENDING**
- [ ] Privacy manifest matches GPS, iCloud, logbook, image behavior
- [ ] No certified dive-computer claims
- [ ] Legal/safety disclaimers intact and localized (en/it verified in remediation)
- [ ] No DEBUG simulation sensor in App Store release
- [ ] Crash/performance telemetry from TestFlight reviewed
- [ ] Final target membership and entitlements reviewed

---

## T. Recommended Cursor Remediation Commands

Do not execute during this audit.

### 1. Bug / Data-Integrity Fixes

```text
CURSOR COMMAND — DIR DIVING MAIN BUG/DATA-INTEGRITY FIX PASS

Work only on branch main. Fix MAIN-DCA-001, MAIN-DCA-004, MAIN-DCA-005, MAIN-DCA-006, MAIN-DCA-007 from Docs/MAIN_DEEP_CODE_ANALYSIS_BUG_PERFORMANCE_SECURITY_AUDIT_CURRENT.md. Preserve Watch dive algorithms, iOS Bühlmann math, planner mode architecture, CCR semantics, HMAC sync trust model, and legal disclaimers. Add focused regression tests. Run xcodegen, both builds, both algorithm test schemes. Report exact results.
```

### 2. Performance Optimization Pass

```text
CURSOR COMMAND — DIR DIVING MAIN PERFORMANCE OPTIMIZATION PASS

Work only on branch main. Address MAIN-DCA-008 and MAIN-DCA-012. Throttle active-dive draft persistence without breaking crash restore. Reduce alarm blink SwiftUI churn. Add performance budget tests. Do not alter decompression or depth algorithms.
```

### 3. Security / Privacy Hardening Pass

```text
CURSOR COMMAND — DIR DIVING MAIN SECURITY/PRIVACY HARDENING PASS

Work only on branch main. Address MAIN-DCA-002, MAIN-DCA-003, MAIN-DCA-013, MAIN-DCA-014, MAIN-DCA-016. Add Watch KVS payload cap, optional replay persistence, photo staging file protection. Document peer-secret threat model. Add negative security tests.
```

### 4. Test Coverage Pass

```text
CURSOR COMMAND — DIR DIVING MAIN TEST COVERAGE PASS

Work only on branch main. Add tests for: Watch userInfo ACK dequeue, planner mode-projected MOD gating, analysis cache SAC invalidation, EndManualDiveIntent after handoff, mission draft restore, Watch cloud oversize rejection. Update QA evidence READMEs only — mark physical gates PENDING until executed.
```

### 5. Planner MOD / Switch-Depth Remediation

```text
CURSOR COMMAND — DIR DIVING PLANNER MOD/SWITCH-DEPTH REMEDIATION

Work only on branch main. Fix MAIN-DCA-004, MAIN-DCA-010, MAIN-DCA-011. Use PlannerModePolicy.activePlanInput for live MOD validation. Correct Base END/MOD labels. Reclamp switch depths on environment changes in all modes. Add MOD regression tests including O2 100% at PPO2 1.6 ≈ 6 m case.
```

### 6. CCR / Rebreather Hardening

```text
CURSOR COMMAND — DIR DIVING CCR HARDENING PASS

Work only on branch main. Address MAIN-DCA-015 and audit CCR checklist import/export round-trip. Reconcile bailout switch depths on import. Add CCR MOD tolerance tests. Do not enable Ratio Deco in CCR.
```

### 7. Watch Image Inventory / Delete Hardening

```text
CURSOR COMMAND — DIR DIVING WATCH PHOTO SYNC HARDENING

Work only on branch main. Verify signed inventory/delete end-to-end on paired simulators. Add stale offset and replay tests. Document paired QA steps in WATCH_IOS_SYNC_QA_MATRIX.md. Mark physical QA PENDING.
```

### 8. Cloud Merge / iCloud Conflict Remediation

```text
CURSOR COMMAND — DIR DIVING CLOUD MERGE REMEDIATION

Work only on branch main. Align Watch and iOS DiveSessionMerge policies (MAIN-DCA-006). Add Watch KVS cap (MAIN-DCA-002/003). Add two-device conflict tests. Preserve divergent-profile-no-fusion policy on iOS.
```

### 9. App Intent / Action Button Safety Remediation

```text
CURSOR COMMAND — DIR DIVING WATCH APP INTENTS SAFETY PASS

Work only on branch main. Fix MAIN-DCA-007. Ensure EndManualDiveIntent works after manual→auto handoff. Verify legal gate on all safety intents. Add intent tests. Do not bypass legal acceptance.
```

---

## U. Final Verdict

### Is the code ready to compile?

**Yes.** Watch and iOS builds succeeded at `dba1a22` on macOS with Xcode.

### Is it safe for internal TestFlight?

**Not yet.** Fix P1 issues MAIN-DCA-001, MAIN-DCA-004, MAIN-DCA-007, and MAIN-DCA-008 first; complete paired simulator sync smoke.

### Is it safe for external TestFlight?

**No.** Requires physical Watch Ultra QA, iCloud two-device QA, and P1 fixes above.

### Is it ready for App Store?

**No.** Blocked by external QA, remaining HIGH issues, and final privacy/safety App Store review.

### What blocks 100% code readiness?

- Planner mode-projected MOD gating bug (MAIN-DCA-004)
- Watch inbound ACK on userInfo (MAIN-DCA-001)
- Per-sample draft I/O (MAIN-DCA-008)
- Merge policy divergence (MAIN-DCA-006)
- Physical/external QA not executed (MAIN-DCA-018)

### What blocks 100% CCR readiness?

- CCR checklist import switch-depth reconciliation (MAIN-DCA-015)
- External in-water / operational CCR QA (**PENDING**)

### What blocks 100% security readiness?

- Watch KVS uncapped writes (MAIN-DCA-002/003)
- Peer secret in applicationContext (MAIN-DCA-013)
- In-memory-only replay cache (MAIN-DCA-014)

### What blocks 100% performance readiness?

- Per-sample active dive draft persistence (MAIN-DCA-008)
- Alarm blink SwiftUI churn (MAIN-DCA-012)

### What must be fixed first?

1. **MAIN-DCA-004** — incorrect Calculate blocking in Base/Deco (user-visible, safety-adjacent)  
2. **MAIN-DCA-001** — Watch pending queue not draining on iOS ACK userInfo path  
3. **MAIN-DCA-007** — Action Button cannot end dive after manual handoff  

---

## Validation Notes

Post-report validation:

| Check | Result |
|---|---|
| Report file exists | Yes |
| Report non-empty | Yes |
| Issue matrix exists | Yes (Section M) |
| Detailed action plan exists | Yes (Section N) |
| No source code modified | Yes — docs only |
| `git status` | Only this report file expected |
| Experimental files untouched | Yes |
| Build/test claims | Only PASS where commands succeeded |
| Physical/external QA | **PENDING** — not passed |

---

*End of audit report — `dba1a22` — 2026-06-09*
