# DIR DIVING MAIN Deep Code Analysis, Bug, Performance, and Security Audit

Date: 2026-06-14  
Scope: MAIN branch only  
Target branch: `main`  
Audited commit: `7c79105` (`7c79105…` — UI/UX remediation V1.0)  
Repository: DIR DIVING  
Command: `5-DIR_DIVING_MAIN_DEEP_CODE_ANALYSIS_COMMAND_CCR_UPDATED_V2.0.md`  
Prior audit: `dba1a22` (2026-06-09)  
Output file: `Docs/MAIN_DEEP_CODE_ANALYSIS_BUG_PERFORMANCE_SECURITY_AUDIT_CURRENT.md`

---

## A. Executive Summary

This audit was performed against branch `main` only at commit **`7c79105`**, immediately after UI/UX internal-readiness remediation (`7c79105`). The working tree was clean before the report was created; `git status -sb` reported `## main...origin/main`.

**No production source code, UI, business logic, algorithms, security model, sync model, planner mode logic, or experimental files were modified during this audit.**

### Build and Test Evidence (macOS / Xcode)

| Command | Result |
|---|---|
| `xcodegen generate` | **PASS** |
| `xcodebuild -scheme "DIRDiving iOS" -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build` | **BUILD SUCCEEDED** |
| `xcodebuild -scheme "DIRDiving Watch App" -destination 'generic/platform=watchOS Simulator' CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build` | **BUILD SUCCEEDED** |
| `xcodebuild -scheme "DIRDiving iOS Algorithm Tests" -destination 'platform=iOS Simulator,name=iPhone 17 Pro' CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO test` | **TEST SUCCEEDED** — **821 passed**, 13 skipped, **0 failed** |
| `xcodebuild -scheme "DIRDiving Watch Algorithm Tests" -destination 'platform=watchOS Simulator,name=Apple Watch Ultra 3 (49mm)' CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO test` | **TEST SUCCEEDED** — **229 passed**, 16 skipped, **0 failed** |

### Readiness Percentages

Static-audit + build/test estimates. Physical and external QA remain **PENDING** and are not counted as passed.

| Readiness area | Estimate | Rationale |
|---|---:|---|
| Overall static code readiness | **91%** | Both builds green; 1,050 automated tests pass; prior P1 DCA items largely remediated with regression tests. |
| Watch MAIN readiness | **92%** | Strong algorithm + sync ACK + draft throttle coverage; remaining gaps are ACK delivery when inactive, briefing path hardening, reminder-suppression matrix. |
| iOS MAIN readiness | **90%** | Mode-projected MOD gating fixed; typed PDF export gate; CCR density unavailable; metadata-only Watch import overwrite remains. |
| Bug risk readiness | **90%** | No CRITICAL crash path confirmed; HIGH items reduced to sync metadata, aggregate KVS budget, inactive-session photo ACK. |
| Performance readiness | **86%** | Active-dive draft throttled (8 s); alarm blink still toggles `@Published` every 1 s; briefing render/transfer bursts possible. |
| Security readiness | **89%** | HMAC v2, signed ACKs, photo-management auth, replay persistence option; briefing `fileName` sanitization weaker than photos; TOFU peer secret remains. |
| Privacy readiness | **88%** | Complete file protection on iOS log/sync/PDF paths; GPS local-only; iCloud opt-in on iOS. |
| Data integrity readiness | **87%** | iOS cloud merge rich; Watch→iOS metadata-only updates replace whole session; aggregate KVS budget not tracked. |
| Sync/cloud readiness | **88%** | Bidirectional signed dive sync + Watch userInfo ACK path fixed; photo delete ACK gap when session inactive. |
| CCR / Rebreather readiness | **90%** | Engine, validator, checklist import clamp, density unavailable UI/PDF; 0.5 m bailout MOD slack vs OC; external CCR QA pending. |
| UI/UX code readiness (post-remediation) | **100% code** | Semantic GPS/compass keys, compact Watch layout, sync badge, briefing freshness, typed PDF errors — external QA still PENDING. |
| Internal TestFlight readiness | **Near ready** | Remaining P1: metadata merge on Watch import, aggregate KVS cap, photo delete ACK when inactive; paired sim QA recommended. |
| External TestFlight readiness | **Not ready** | Physical Watch Ultra, paired-device, iCloud two-device, Subsurface external QA all **PENDING**. |
| App Store readiness | **Not ready** | External QA + App Store assets + final privacy review required. |

### Most Urgent Open Issues

1. **MAIN-DCA-011** — iOS Watch import replaces full session when metadata-only diff (notes/site/buddy not in `WatchSyncSessionDiff`).
2. **MAIN-DCA-019** — Watch photo delete ACK/inventory publish skipped when `WCSession` not activated (file deleted locally, iPhone may never ACK).
3. **MAIN-DCA-025** — Aggregate iCloud KVS budget not enforced across multiple keys (per-key 512 KB cap only).
4. **MAIN-DCA-020** — Planner briefing `fileName` not path-sanitized on Watch (weaker than `UserImageStore`).
5. **MAIN-DCA-022** — Reminder suppression incomplete vs depth caution/critical banners (documented deferral in UI/UX remediation).

No **CRITICAL** (unmitigated crash / silent data loss without recovery) issue was confirmed at `7c79105`.

### Improvements Since Prior Audit (`dba1a22` → `7c79105`)

| Prior ID | Status at `7c79105` |
|---|---|
| MAIN-DCA-001 Watch inbound `diveImportAck` on userInfo | **Fixed** — `WatchSyncService.didReceiveUserInfo` + `parseImportAck`; tests in `MainDeepCodeRemediationDCATests` |
| MAIN-DCA-002 Watch KVS per-key cap | **Fixed** — `Services/CloudSyncStore.swift` uses `maxSyncPayloadBytes`; tested |
| MAIN-DCA-004 Planner MOD gate on full draft | **Fixed** — `liveMODIssues` uses `PlannerModePolicy.activePlanInput`; tested |
| MAIN-DCA-005 Analysis cache staleness | **Fixed** — `AnalysisCacheKey` includes SAC, planning ref, avg-depth toggle, signatures; tested |
| MAIN-DCA-007 End manual dive after handoff | **Fixed** — `endManualDive()` accepts `sessionStartedManually` |
| MAIN-DCA-008 Per-sample draft I/O | **Fixed** — `activeDiveDraftPersistenceIntervalSeconds` (8 s) + deferred flush; tested |
| MAIN-DCA-009 Mission pending not in draft | **Fixed** — `missionModeManualPendingForSession` in `ActiveDiveDraft` |
| MAIN-DCA-010 Base END labeled MOD | **Fixed** — Base results use `END` tile (`PlannerView.swift`) |
| MAIN-DCA-014 In-memory-only replay cache | **Improved** — `SyncNonceReplayCache.persistProtected`; tested |
| MAIN-DCA-015 CCR import switch depth | **Fixed** — `CCRChecklistImportCoordinator` clamps bailout MOD; tested |
| UI/UX P1–P3 (GPS keys, density unavailable, PDF errors, briefing freshness, 40 mm layout) | **Remediated** — see `Docs/UI_UX_MAIN_AUDIT_REMEDIATION_REPORT_V1.0.md` |

---

## B. Scope Confirmation

### Git / Remote State

| Check | Result |
|---|---|
| Branch | `main` |
| Commit | `7c79105` |
| Remote alignment | `## main...origin/main` |
| Dirty files before report | None |
| Experimental branches | Not touched |

### Targets In `project.yml`

| Target | Platform | Bundle ID |
|---|---|---|
| `DIRDiving Watch App` | watchOS | `com.egopfe.dirdiving.ios.watch` |
| `DIRDiving iOS` | iOS | `com.egopfe.dirdiving.ios` |
| `DIRDiving Watch Algorithm Tests` | watchOS tests | `com.egopfe.dirdiving.watch.algorithmtests` |
| `DIRDiving iOS Algorithm Tests` | iOS tests | `com.egopfe.dirdiving.ios.algorithmtests` |

### Experimental Exclusions Confirmed

**Watch:** `ApneaView`, `SnorkelingView`, `BuddyAssistView`, `ExperimentalConceptsView`, `ExperimentalFeatures`, Buddy/Exploration services excluded.

**iOS:** `ExplorationModels`, `BuddyExperimentalModels`, `ExplorationPlanningStore`, `BuddyExperimentalStore`, exploration/buddy views excluded.

### Static Scan Summary

| Scan | Result |
|---|---|
| Production `try!` / `as!` | None in production paths; tests only |
| `Dictionary(uniqueKeysWithValues:)` | None found |
| TODO/FIXME in MAIN production | Only in excluded experimental views |
| Hardcoded secrets | None in repo |
| Legacy Italian-as-key in Swift | **None** — semantic `watch.gps.status.*` / `watch.compass.status.*` |
| Legacy Italian-as-key in `.strings` catalogs | **Residual aliases** remain (`Fix disponibile`, `Bussola pronta`) — not referenced from Swift |
| Tissue chart `"Time"` axis | Hardcoded in `TissueAnalyticsCharts.swift` (pre-existing; CCR charts now localized) |

---

## C. Architecture Analysis

### Watch

Runtime centered on `DiveManager`, sensor providers, `WatchSyncService` (HMAC v2, signed ACKs, photo management, briefing routing), `CloudSyncStore` (capped), `UserImageStore`, `PlannerBriefingCardStore`.

**Strengths:** Legal gate on all safety App Intents; mission mode invariant tests; draft throttle; compact live banner policy; briefing freshness warnings.

**Risks:** Briefing filename confinement; delete ACK when session inactive; reminder suppression vs banner policy mismatch.

### iOS Companion

Three-mode OC planner + CCR mode; rich iOS `DiveSessionMerge`; capped iOS `CloudSyncStore`; `PDFExportGate` typed export blocks; CCR gas-density unavailable presentation.

**Strengths:** Mode-projected planning and MOD gating; analysis cache completeness; equipment/checklist/CCR checklist coordinators; 821 algorithm tests.

**Risks:** Watch import metadata overwrite; aggregate KVS budget; tissue chart localization leak.

### Cross-App Integration

```
Watch dive → HMAC payload → iOS import → signed ACK → Watch dequeue (direct + userInfo)
iOS dive → pending queue → Watch import → signed ACK → iOS dequeue
iCloud KVS ← CloudSyncStore (per-key cap both platforms; aggregate budget gap)
Planner briefing PNG → WC file transfer → Watch receiver → Application Support/PlannerBriefing
Photos → signed management payloads → inventory/delete ACK
```

---

## D. Apple Watch Deep Code Analysis

| Area | Status | Notes |
|---|---|---|
| Dive lifecycle / draft restore | **PASS** | Throttled persistence; mission pending in draft |
| Manual/auto start + handoff | **PASS** | `sessionStartedManually` enables end after handoff |
| Mission Mode invariants | **PASS** | Tests in `MissionModeAlgorithmInvariantTests` |
| Sensor simulation release | **PASS** | Release migration tested |
| App Intents legal gate | **PASS** | All safety intents gated |
| Live banner density (40 mm) | **PASS** | `LiveDiveBannerPresentationPolicy` defer panels — UI/UX V1.0 |
| Reminder manual dismiss | **PASS** | Tap-to-dismiss overlay |
| Reminder vs safety suppression | **PARTIAL** | `shouldSuppressDiveReminders` misses `.critical`/`.caution` depth states |
| Sync ACK userInfo | **PASS** | Fixed + tested |
| Photo delete ACK | **PARTIAL** | Skipped when `activationState != .activated` |
| Briefing transfer | **PARTIAL** | Hash validation good; `fileName` path not sanitized |
| CSV export | **PASS** | Subsurface path tested |

### Watch Performance Notes

| Risk | Severity | Location |
|---|---|---|
| Alarm `@Published` blink toggle 1 Hz | MEDIUM | `DiveManager.blinkTimer` |
| `flushPendingTransfers` may re-send queue | LOW | `WatchSyncService` |
| Timer → `Task { @MainActor }` every tick | LOW | Runtime/stopwatch timers |
| Briefing PNG decode memory | LOW | Staging + final storage |

### Watch Security Notes

| Area | Status |
|---|---|
| Dive sync HMAC + nonce (v2) | **PASS** |
| Photo management HMAC + replay | **PASS** |
| Photo path traversal | **PASS** — `UserImageStore.sanitizedCompanionPhotoFileName` |
| Briefing path confinement | **FAIL** — no `..` rejection on `fileName` |
| Bundled image delete protection | **PASS** |
| Legal gate on intents | **PASS** |

---

## E. iOS Companion Deep Code Analysis

| Area | Status | Notes |
|---|---|---|
| Base / Deco / Technical modes | **PASS** | Real projection via `PlannerModePolicy` |
| MOD / switch-depth clamp | **PASS** | Environment-aware; mode-projected live gate |
| NDL / gas preview parity | **PASS** | Projected input + complete cache key |
| CCR planner | **PASS** | Separate mode; Ratio Deco blocked |
| CCR density unavailable | **PASS** | UI + PDF — UI/UX V1.0 |
| PDF/share typed errors | **PASS** | `PDFExportGate` |
| Cloud merge (iOS) | **PASS** | Divergent profile policy; conflict detector |
| Watch import metadata | **FAIL** | Full replace without merge when diff not "significant" |
| Aggregate KVS budget | **FAIL** | Multiple keys can exceed total quota |
| Tissue chart localization | **PARTIAL** | `"Time"` hardcoded in analytics charts |

---

## F. Planner-Specific Deep Analysis

| Check | Status |
|---|---|
| Modes affect inputs, gases, validation, results | **PASS** |
| Hidden Technical gases excluded from Base/Deco calc | **PASS** |
| `liveMODIssues` uses projected input | **PASS** (fixed) |
| Environment reclamp on altitude/salinity | **PARTIAL** — strongest in Technical UI block |
| PPO2 tolerance centralized | **PASS** — `GasMixValidator` / preflight |
| Export includes mode + typed block reasons | **PASS** |
| Deco-stop MOD `validateAll` dead path gas fallback | **INFO** — unused in production; documented in tests |

---

## G. CCR / Rebreather Deep Analysis

| Area | Status |
|---|---|
| Setpoint / diluent / bailout validation | **PASS** |
| Inspired gas / tissue / CNS / OTU integration | **PASS** |
| Bailout heuristic disclaimer | **PASS** |
| Checklist import switch-depth clamp | **PASS** (fixed) |
| Bailout MOD tolerance 0.5 m vs OC 0.05 m | **PARTIAL** — intentional slack? document or align |
| CCR UI density unavailable | **PASS** |
| CCR external physical QA | **PENDING** |

---

## H. Transit / Runtime / Deco Presentation

| Check | Status |
|---|---|
| `PlannerAscentTableBuilder` / `DecoStopsPresentationBuilder` | **PASS** — presentation-only; tests in `PlannerAscentTableTests` |
| Route summary / TTS consistency | **PASS** — `RouteSummaryService` tested |
| Stale result invalidation | **PASS** — `PlanCalculationCompleteness` / export gates |
| Presentation mutates canonical data | **PASS** — no mutation found |

---

## I. Emergency / Rock Bottom

| Check | Status |
|---|---|
| Separate from normal consumption | **PASS** |
| Technical avg-depth toggle isolation | **PASS** — tested in `PlannerTechnicalAverageDepthGasConsumptionTests` |
| Display vs canonical liters | **PASS** — `GasLedgerDisplayFormatter` tests |
| CCR bailout not reusing OC bottom assumptions silently | **PASS** |

---

## J. Schedule-Aware Gas / Gas Ledger

| Check | Status |
|---|---|
| Segment allocation | **PASS** — `ScheduleGasConsumptionServiceTests` |
| Liters/bar separation | **PASS** — `GasLedgerDisplayFormatterTests` |
| CCR diluent as OC consumption | **PASS** — blocked in CCR paths |

---

## K. Repetitive Dive / Residual Tissue

| Check | Status |
|---|---|
| Explicit prior-dive selection | **PASS** |
| No silent fresh-tissue fallback | **PASS** — validated in readiness tests |
| Chronology / surface interval | **PASS** |

---

## L. Structured Equipment / Operational Checklist

| Check | Status |
|---|---|
| Role mapping | **PASS** — `EquipmentPlannerMapperTests` |
| Checklist generation | **PASS** — `EquipmentChecklistGeneratorTests` |
| CCR checklist import/export round trip | **PASS** — coordinators + UI/UX remediation |

---

## M. Planner Briefing Card / Watch Transfer

| Check | Status |
|---|---|
| Reference-only labeling | **PASS** — localized footer |
| Freshness warnings | **PASS** — `PlannerBriefingFreshnessPolicy` |
| Hash / size validation | **PASS** |
| PNG/metadata fidelity | **PASS** — export tests |
| `fileName` path sanitization | **FAIL** — MAIN-DCA-020 |
| Non-atomic manifest swap on partial failure | **PARTIAL** — MAIN-DCA-021 |
| Payload routing collision with photos | **PASS** when store attached |

---

## N. Watch Image Inventory / Delete

| Check | Status |
|---|---|
| Watch source-of-truth | **PASS** |
| Signed payloads | **PASS** |
| Path traversal (photos) | **PASS** |
| Delete ACK when session inactive | **FAIL** — MAIN-DCA-019 |
| Bundled read-only | **PASS** |
| Paired physical QA | **PENDING** |

---

## O. Cross-App Sync / Data Integrity

**Fixed:** Watch parses iOS signed import ACK on `transferUserInfo` path.

**Open:** iOS `importSessionPayload` uses `logStore?.add(session)` for non-significant updates — drops iPhone-edited notes/site/buddy when Watch re-syncs profile-compatible session.

**Open:** Aggregate KVS size across keys (sessions, equipment, planner state, tombstones).

**Trust model:** TOFU peer secret via `applicationContext`; HMAC v2 with optional persisted replay cache.

---

## P. Performance Analysis

| Risk | Severity | Symptom | Priority |
|---|---|---|---|
| Alarm blink `@Published` 1 Hz | MEDIUM | Extra SwiftUI work during alarms | P2 |
| Briefing PNG render + transfer | LOW | Memory spike on large packages | P3 |
| Planner debounced recompute 200 ms | LOW | Acceptable | P4 |
| Tissue analytics chart rebuild | LOW | Chart data regen on tab change | P4 |

Draft persistence throttling (**was HIGH**) is **closed**.

---

## Q. Security / Privacy Analysis

| Area | Status |
|---|---|
| HMAC v2 + signed ACKs | **PASS** |
| Photo management auth | **PASS** |
| Replay cache persistence (optional) | **PASS** |
| Legacy sync v1 without nonce | **MEDIUM** — backward compat window |
| Peer secret in `applicationContext` | **MEDIUM** — documented tradeoff |
| Briefing unsigned + weak filename rules | **MEDIUM** |
| GPS privacy (local only) | **PASS** |
| iCloud opt-in (iOS) | **PASS** |
| PDF complete file protection | **PASS** |

---

## R. Test Coverage Analysis

| Suite | Passed | Skipped | Failed |
|---|---:|---:|---:|
| iOS Algorithm Tests | 821 | 13 | 0 |
| Watch Algorithm Tests | 229 | 16 | 0 |
| **Total** | **1,050** | **29** | **0** |

**Strengths:** `MainDeepCodeRemediationDCATests` (both platforms), UI/UX V1.0 tests, planner MOD/switch-depth suites, sync ACK policy, CCR math remediation, mission mode, briefing receiver tests.

**Gaps:**

- End-to-end photo delete ACK when WCSession inactive
- Briefing path traversal / partial manifest failure
- Reminder suppression matrix (depth caution + ascent alarm disabled)
- Aggregate KVS budget simulation
- Paired Watch/iPhone E2E (documented out of scope for unit tests)
- All physical QA matrices — **PENDING**

---

## S. Issue Matrix

| ID | Sev | Pri | App | Area | File / Function | Title | Status |
|---|---|---|---|---|---|---|---|
| MAIN-DCA-001 | HIGH | P1 | Watch | Sync | `WatchSyncService` userInfo ACK | Watch ignored inbound ACK on userInfo | **FIXED** |
| MAIN-DCA-002 | HIGH | P1 | Watch | Cloud | `CloudSyncStore.save` | No per-key KVS cap | **FIXED** |
| MAIN-DCA-003 | MEDIUM | P2 | Both | Cloud | Multi-key KVS writes | Legacy oversized snapshots | **OPEN** |
| MAIN-DCA-004 | HIGH | P1 | iOS | Planner | `PlannerView.liveMODIssues` | MOD gate used full draft | **FIXED** |
| MAIN-DCA-005 | HIGH | P1 | iOS | Planner | `AnalysisCacheKey` | Cache omitted SAC/planning ref | **FIXED** |
| MAIN-DCA-006 | HIGH | P1 | Watch | Merge | `DiveSessionMerge` | Watch merge subset documented | **MITIGATED** — intentional; union samples |
| MAIN-DCA-007 | HIGH | P1 | Watch | Runtime | `endManualDive` | End intent no-op after handoff | **FIXED** |
| MAIN-DCA-008 | HIGH | P1 | Watch | Perf | `persistActiveDiveDraft` | Every-sample draft I/O | **FIXED** |
| MAIN-DCA-009 | MEDIUM | P2 | Watch | Mission | `ActiveDiveDraft` | Mission pending not persisted | **FIXED** |
| MAIN-DCA-010 | MEDIUM | P2 | iOS | Planner UI | Base results | END labeled MOD | **FIXED** |
| MAIN-DCA-011 | HIGH | P1 | iOS | Sync | `WatchSyncService.importSessionPayload` | Metadata-only Watch sync overwrites iPhone edits | **OPEN** |
| MAIN-DCA-012 | MEDIUM | P2 | Watch | Perf | `blinkTimer` | 1 Hz `@Published` blink | **OPEN** |
| MAIN-DCA-013 | MEDIUM | P2 | Both | Security | `WatchSyncAuth` | Peer secret in applicationContext | **OPEN** |
| MAIN-DCA-014 | MEDIUM | P2 | Both | Security | `SyncNonceReplayCache` | Replay persistence optional | **IMPROVED** |
| MAIN-DCA-015 | MEDIUM | P2 | iOS | CCR | `CCRChecklistImportCoordinator` | Import switch depth | **FIXED** |
| MAIN-DCA-016 | LOW | P3 | iOS | Privacy | Photo staging temps | Staging file protection | **OPEN** — verify staging paths |
| MAIN-DCA-017 | LOW | P3 | iOS | Stability | Planner table helper | Force unwrap headers | **FIXED** — no `columnHeaders!` at HEAD |
| MAIN-DCA-018 | INFO | P1 | Both | QA | External matrices | Physical QA not executed | **PENDING** |
| MAIN-DCA-019 | HIGH | P1 | Watch | Sync/Photos | `deliverDeleteAck` | ACK skipped when session inactive | **OPEN** |
| MAIN-DCA-020 | MEDIUM | P2 | Watch | Security | `PlannerBriefingCardStore` | Briefing `fileName` not sanitized | **OPEN** |
| MAIN-DCA-021 | MEDIUM | P2 | Watch | Briefing | `importManifest` | Non-atomic package swap | **OPEN** |
| MAIN-DCA-022 | MEDIUM | P2 | Watch | Runtime | `shouldSuppressDiveReminders` | Incomplete vs depth banners | **OPEN** |
| MAIN-DCA-023 | LOW | P3 | iOS | Planner | `PlannerMODValidator.validateAll` | Deco-stop gas fallback dead path | **INFO** |
| MAIN-DCA-024 | LOW | P3 | iOS | CCR | `CCRPlanValidator` | 0.5 m bailout MOD slack | **OPEN** — document or tighten |
| MAIN-DCA-025 | HIGH | P1 | iOS | Cloud | `CloudSyncStore` multi-key | Aggregate KVS budget | **OPEN** |
| MAIN-DCA-026 | LOW | P3 | iOS | Cloud | `CloudSyncStore.synchronize` | Success date before sync completes | **OPEN** |
| MAIN-DCA-027 | MEDIUM | P2 | Both | Security | `WatchDiveSyncCodec` v1 | Legacy schema without nonce replay | **OPEN** |
| MAIN-DCA-028 | LOW | P3 | iOS | Merge | `DiveSessionMerge` | `gasLabel` LWW only | **OPEN** |
| MAIN-DCA-029 | LOW | P3 | Watch | Sync | `flushPendingTransfers` | Duplicate queue sends | **OPEN** |
| MAIN-DCA-030 | LOW | P3 | iOS | Localization | `TissueAnalyticsCharts` | Hardcoded `"Time"` axis | **OPEN** |
| MAIN-DCA-031 | INFO | P4 | Both | Localization | `.strings` catalogs | Legacy Italian-as-key aliases unused | **OPEN** — cleanup |
| MAIN-DCA-032 | INFO | P3 | Watch | UX | Reminder deferral | Suppression visibility deferred | **DOCUMENTED** — UI/UX V1.0 |

---

## T. Detailed Action Plan

### P0

No compile blocker. Builds and 1,050 tests pass.

### P1 (recommended before internal TestFlight)

1. **MAIN-DCA-011** — Merge Watch imports with `DiveSessionMerge.preferred` when profile-compatible, or expand `WatchSyncSessionDiff` to metadata fields.
2. **MAIN-DCA-019** — Queue photo delete ACK/inventory until `WCSession` activated; retry on activation.
3. **MAIN-DCA-025** — Track aggregate KVS bytes or move large blobs off KVS.

### P2

- MAIN-DCA-020 briefing filename sanitization  
- MAIN-DCA-021 atomic briefing package swap  
- MAIN-DCA-022 reminder suppression matrix alignment  
- MAIN-DCA-012 reduce alarm blink churn  
- MAIN-DCA-013 peer-secret threat model update  
- MAIN-DCA-027 v1 sync deprecation timeline  

### P3 / P4

- MAIN-DCA-024 CCR MOD tolerance alignment  
- MAIN-DCA-030 tissue chart axis localization  
- MAIN-DCA-031 legacy string catalog cleanup  
- MAIN-DCA-018 execute external QA matrices (**PENDING** until evidence)

---

## U. 7-Day Remediation Plan

| Day | Actions | Verification |
|---|---|---|
| 1 | MAIN-DCA-011 metadata merge on Watch import | `WatchSyncConflictTests` + new merge test |
| 2 | MAIN-DCA-019 queued delete ACK | Watch sync integration test |
| 3 | MAIN-DCA-025 aggregate KVS budget | Cloud sync tests |
| 4 | MAIN-DCA-020/021 briefing hardening | Watch briefing tests |
| 5 | MAIN-DCA-022 reminder suppression | `DiveReminderIntegrationTests` matrix |
| 6 | Paired simulator sync smoke | `WATCH_IOS_SYNC` evidence folder |
| 7 | Full build + both test schemes | 1,050+ tests green |

---

## V. 14-Day Remediation Plan

| Days | Focus |
|---|---|
| 1–4 | P1 sync/cloud/briefing fixes |
| 5–7 | P2 performance + security hardening |
| 8–10 | Paired Watch/iPhone + iCloud two-device QA (**evidence only — mark PENDING until done**) |
| 11–12 | Physical Watch Ultra QA (**PENDING**) |
| 13–14 | TestFlight / App Store checklist update |

---

## W. Pre-Internal-TestFlight Checklist

- [x] `xcodegen generate` passes
- [x] Watch + iOS build succeed
- [x] iOS tests: 821 passed, 13 skipped
- [x] Watch tests: 229 passed, 16 skipped
- [x] Prior MAIN-DCA-001/004/007/008 remediated with tests
- [ ] MAIN-DCA-011 metadata merge fixed
- [ ] MAIN-DCA-019 delete ACK queue fixed
- [ ] MAIN-DCA-025 aggregate KVS budget addressed
- [ ] No physical QA marked PASS without evidence

---

## X. Pre-External-TestFlight Checklist

- [ ] All internal items complete
- [ ] Paired sync both directions with signed ACK rejection cases
- [ ] Photo inventory/delete on paired simulators
- [ ] iCloud two-device conflict matrix — **PENDING**
- [ ] Watch Ultra physical QA — **PENDING**

---

## Y. Pre-App-Store Checklist

- [ ] External TestFlight complete
- [ ] Subsurface external validation — **PENDING**
- [ ] App Store assets — **PENDING** (`Docs/QA_EVIDENCE/APP_STORE_MARKETING/`)
- [ ] Privacy manifest matches behavior
- [ ] Non-certified / reference-only copy verified EN/IT
- [ ] No DEBUG simulation in release build

---

## Z. Recommended Cursor Remediation Commands

Do not execute during this audit.

### 1. Bug / Data-Integrity Fixes (P1)

```text
CURSOR COMMAND — DIR DIVING MAIN DCA P1 BUG/DATA-INTEGRITY PASS

Work only on branch main. Fix MAIN-DCA-011, MAIN-DCA-019, MAIN-DCA-025 from Docs/MAIN_DEEP_CODE_ANALYSIS_BUG_PERFORMANCE_SECURITY_AUDIT_CURRENT.md. Preserve algorithms, sync trust model, planner modes, CCR semantics. Add regression tests. Run xcodegen, both builds, both test schemes. Report results.
```

### 2. Watch Briefing / Photo Sync Hardening

```text
CURSOR COMMAND — DIR DIVING WATCH BRIEFING AND PHOTO ACK HARDENING

Fix MAIN-DCA-020, MAIN-DCA-021, MAIN-DCA-019. Sanitize briefing filenames; atomic manifest swap; queue delete ACK until session active. Add Watch tests. Do not weaken HMAC photo management.
```

### 3. Performance Optimization Pass

```text
CURSOR COMMAND — DIR DIVING MAIN PERFORMANCE PASS

Address MAIN-DCA-012 alarm blink churn. Reduce SwiftUI invalidation during alarms without changing alarm semantics. Add budget test.
```

### 4. Security Hardening Pass

```text
CURSOR COMMAND — DIR DIVING MAIN SECURITY HARDENING

Address MAIN-DCA-013, MAIN-DCA-027, MAIN-DCA-020. Document peer-secret threat model; plan v1 sync deprecation; sanitize briefing paths. Negative tests required.
```

### 5. Reminder / Safety UX Alignment

```text
CURSOR COMMAND — DIR DIVING WATCH REMINDER SUPPRESSION ALIGNMENT

Fix MAIN-DCA-022. Extend shouldSuppressDiveReminders to match LiveDiveBannerPresentationPolicy critical states without weakening alarms. Add integration tests. Optionally surface deferred reminder state if safe.
```

### 6. Localization Cleanup

```text
CURSOR COMMAND — DIR DIVING LOCALIZATION CATALOG CLEANUP

Remove unused Italian-as-key aliases (MAIN-DCA-031). Localize tissue analytics chart axes (MAIN-DCA-030). EN/IT parity tests.
```

### 7. External QA Evidence Execution

```text
CURSOR COMMAND — DIR DIVING EXTERNAL QA EVIDENCE EXECUTION

Execute matrices in Docs/QA_EVIDENCE/ (Watch Ultra, paired sync, iCloud, Dynamic Type/VoiceOver, Subsurface, Reference UI). Mark PASS only with attached evidence. Do not fabricate screenshots.
```

---

## AA. Final Verdict

### Is the code ready to compile?

**Yes.** Watch and iOS builds succeeded at `7c79105`.

### Is it safe for internal TestFlight?

**Conditionally yes** after P1 fixes (MAIN-DCA-011, MAIN-DCA-019, MAIN-DCA-025) and paired simulator smoke. Code quality materially improved since `dba1a22`.

### Is it safe for external TestFlight?

**No.** Physical QA and P1 data-integrity fixes remain.

### Is it ready for App Store?

**No.** Blocked by external QA, assets, and remaining HIGH sync/metadata issues.

### What blocks 100% code readiness?

- Watch→iOS metadata overwrite (MAIN-DCA-011)
- Photo delete ACK when inactive (MAIN-DCA-019)
- Aggregate KVS budget (MAIN-DCA-025)
- External QA not executed (MAIN-DCA-018)

### What blocks 100% CCR readiness?

- External in-water / reference validation (**PENDING**)
- Optional bailout MOD tolerance alignment (MAIN-DCA-024)

### Are presentation layers faithful to canonical data?

**Yes** — ascent/runtime/deco builders are presentation-only; tests confirm ordering and export gating.

### Is Rock Bottom conservative and isolated?

**Yes** — separate from normal consumption; avg-depth toggle isolated.

### Are briefing cards numerically faithful and reference-only?

**Yes** — with freshness warnings; filename sanitization still needed (MAIN-DCA-020).

### What must be fixed first?

1. **MAIN-DCA-011** — preserve iPhone logbook metadata on Watch re-sync  
2. **MAIN-DCA-019** — reliable photo delete ACK delivery  
3. **MAIN-DCA-025** — aggregate iCloud KVS budget guard  

---

## AB. Validation Notes

| Check | Result |
|---|---|
| Report file exists | Yes |
| Issue matrix exists | Yes (Section S) |
| Action plan + roadmaps | Yes |
| No source code modified | Yes — docs only |
| Build/test claims | PASS only where commands succeeded |
| Physical/external QA | **PENDING** — not passed |

---

*End of audit report — `7c79105` — 2026-06-14*
