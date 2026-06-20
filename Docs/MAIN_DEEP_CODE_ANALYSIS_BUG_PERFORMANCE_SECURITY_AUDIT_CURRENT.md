# DIR DIVING MAIN Deep Code Analysis, Bug, Performance, and Security Audit

Date: 2026-06-20  
Scope: MAIN branch — multi-activity (Diving, Apnea, Snorkeling)  
Target branch: `main`  
Audited baseline commit: `79e242e` (working tree includes iOS algorithm, UI/UX, Watch math, and prior MAIN-DCA remediations pending commit)  
Repository: DIR DIVING  
Command: `5-DIR_DIVING_MAIN_DEEP_CODE_ANALYSIS_COMMAND_CCR_UPDATED_V3.0.md`  
Prior audit: `7c79105` (2026-06-14, V2.0)  
Output file: `Docs/MAIN_DEEP_CODE_ANALYSIS_BUG_PERFORMANCE_SECURITY_AUDIT_CURRENT.md`

---

## A. Executive Summary

This V3.0 audit was performed against branch `main` at baseline **`79e242e`**, including all uncommitted remediation work in the working tree (iOS complete-algorithm remediation, UI/UX remediation, Watch mathematical remediation, and prior MAIN-DCA P1–P3 fixes). **No production source code was modified during this audit pass** — only this report and related audit artifacts were created or updated.

### Build and Test Evidence (macOS / Xcode, 2026-06-20)

| Command | Result |
|---|---|
| `xcodegen generate` | **PASS** |
| `./Scripts/check_main_target_isolation.sh` | **PASS** |
| `./Scripts/check_secrets.sh` | **PASS** |
| `./Scripts/audit_localization.sh` | **PASS** — 2235 inventory rows; 0 hardcoded Watch MAIN findings |
| `xcodebuild -scheme "DIRDiving iOS" -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build` | **BUILD SUCCEEDED** |
| `xcodebuild -scheme "DIRDiving Watch App" -destination 'generic/platform=watchOS Simulator' CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build` | **BUILD SUCCEEDED** |
| `./Scripts/validate_ios_complete_algorithm_readiness.sh` | **PASS** — **1342 passed**, 0 skipped, **0 failed** |
| `./Scripts/validate_ui_ux_main_readiness.sh` | **PASS** — iOS + Watch UI/UX regression suites green |
| `./Scripts/validate_watch_complete_algorithm_readiness.sh` | **PASS** — **880 passed**, 0 skipped, **0 failed** |
| `xcodebuild -scheme "DIRDiving Watch Algorithm Tests" -destination 'platform=watchOS Simulator,name=Apple Watch Ultra 3 (49mm)' test` | **TEST SUCCEEDED** — 880 passed, 0 failed |

**Combined automated tests:** **2,222 passed**, **0 skipped**, **0 failed** (iOS 1342 + Watch 880).

### Readiness Percentages

Static-audit + build/test estimates. Physical and external QA remain **PENDING** and are not counted as passed.

| Readiness area | Estimate | Rationale |
|---|---:|---|
| Overall static code readiness | **97%** | Both builds green; 2,222 automated tests pass; prior MAIN-DCA P1–P3 closed; iOS/UI/UX/Watch math software gates at 100%. |
| Watch MAIN readiness | **98%** | Gauge + Full Computer + Apnea + Snorkeling in MAIN target; 880 tests; independent Bühlmann oracle; physical Ultra QA pending. |
| iOS MAIN readiness | **97%** | Three-mode planner + CCR; lazy store coordinator; typed cloud capabilities; 1342 tests. |
| Multi-activity routing readiness | **98%** | `DIRActivitySelectionStore`, separate logbooks, settings visibility guards; sequential flow tests. |
| Apnea software readiness | **100%** | Lifecycle engine, sync codec, cloud EXPLICITLY_UNAVAILABLE; wet QA pending. |
| Snorkeling software readiness | **100%** | GPS runtime, logbook isolation, cloud status-only; field GPS QA pending. |
| Bug risk readiness | **97%** | No CRITICAL crash path confirmed; all prior P1 data-integrity items closed with regression tests. |
| Performance readiness | **92%** | Draft throttle, alarm blink decoupled from 1 Hz `@Published`; Full Computer 1 s loop profiled in tests; long-dive battery QA pending. |
| Security readiness | **94%** | HMAC v2, signed ACKs, briefing filename sanitizer, photo ACK queue, schema v1 policy; TOFU peer secret documented tradeoff. |
| Privacy readiness | **92%** | Complete file protection on sync/log/PDF; GPS local-only for Snorkeling; iCloud opt-in; Apnea/Snorkeling cloud truthfulness. |
| Data integrity readiness | **96%** | Metadata merge on Watch import; aggregate KVS budget; atomic briefing swap; cross-activity payload rejection tested. |
| Sync/cloud readiness | **96%** | Bidirectional signed dive sync; activity-discriminated Apnea transport; durable photo ACK queue. |
| Planner readiness | **98%** | Three-mode projection, MOD gate, ascent-speed settings link, briefing cards; external Bühlmann pending. |
| CCR / Rebreather readiness | **95%** | Engine, validator, checklist import, density unavailable, MOD presentation policy; external CCR QA pending. |
| Watch image-management readiness | **97%** | Signed payloads, path traversal blocked, delete ACK queue; paired physical QA pending. |
| UI/UX code readiness | **100%** | Software-verifiable UIUX-002–012 closed; external VoiceOver/Dynamic Type pending. |
| Internal TestFlight readiness | **Near ready** | All software-verifiable audit findings closed; paired sim + physical QA recommended before external. |
| External TestFlight readiness | **Not ready** | Physical Watch Ultra, paired-device, iCloud two-device, Subsurface, field GPS all **PENDING**. |
| App Store readiness | **Not ready** | External QA + App Store assets + final privacy review required. |

### Most Urgent Open Items

1. **MAIN-DCA-018** — Physical/external QA matrices not executed (no fabricated evidence).
2. **MAIN-DCA-032** — Deferred reminder visibility indicator intentionally deferred; suppression policy closed.
3. **MAIN-DCA-024** — CCR bailout MOD 0.5 m slack vs 0.05 m OC documented as intentional (`CCRMODTolerancePolicy`).
4. **MAIN-DCA-003** — Legacy oversized KVS snapshots handled by caps; migration path documented.
5. **MAIN-DCA-013** — TOFU peer secret in `applicationContext`; threat model documented; no code bypass.

No **CRITICAL** (unmitigated crash / silent data loss without recovery) issue was confirmed at this audit baseline.

### Improvements Since Prior Audit (`7c79105` → current)

| Area | Status |
|---|---|
| MAIN-DCA-011 metadata merge on Watch import | **CLOSED** |
| MAIN-DCA-019 photo delete ACK queue | **CLOSED** |
| MAIN-DCA-025 aggregate KVS budget | **CLOSED** |
| MAIN-DCA-012 alarm blink performance | **CLOSED** |
| MAIN-DCA-020/021 briefing sanitize + atomic swap | **CLOSED** |
| MAIN-DCA-022 reminder suppression matrix | **CLOSED** |
| MAIN-DCA-027 schema v1 deprecation policy | **CLOSED** |
| MAIN-DCA-030 tissue chart axis localization | **CLOSED** |
| IOS-ALG-005–011 iOS algorithm remediation | **CLOSED** |
| UIUX-002–012 UI/UX remediation | **CLOSED** |
| WATCH-MATH-001/002/007 Watch math oracle regressions | **CLOSED** |

---

## B. Scope Confirmation

### Git / Remote State

| Check | Result |
|---|---|
| Branch | `main` |
| Baseline commit | `79e242e` |
| Working tree | Remediation bundle pending commit (this audit report included) |
| Remote alignment | `main...origin/main` (pre-push) |
| Experimental branches | Not touched |

### Product Architecture (V3.0)

```text
DIR Diving
├── Diving (Gauge | Full Computer)
├── Apnea
└── Snorkeling
```

Both Apple Watch and iOS Companion audited as multi-activity applications.

### Targets In `project.yml`

| Target | Platform | Bundle ID |
|---|---|---|
| `DIRDiving Watch App` | watchOS | `com.egopfe.dirdiving.ios.watch` |
| `DIRDiving iOS` | iOS | `com.egopfe.dirdiving.ios` |
| `DIRDiving Watch Algorithm Tests` | watchOS tests | `com.egopfe.dirdiving.watch.algorithmtests` |
| `DIRDiving iOS Algorithm Tests` | iOS tests | `com.egopfe.dirdiving.ios.algorithmtests` |

### Experimental Exclusions Confirmed

Legacy experimental-only views (`ExperimentalConceptsView`, `BuddyAssistView`, exploration stores) remain excluded from MAIN targets. **Apnea and Snorkeling production views are in MAIN scope** per V3.0.

### Static Scan Summary

| Scan | Result |
|---|---|
| Production `try!` / `as!` | None in production paths; tests only |
| Hardcoded secrets | None — `check_secrets.sh` PASS |
| Legacy Italian-as-key in Swift | **None** |
| Cross-activity settings leakage | Guarded — `ActivitySettingsVisibility`, `WatchActivitySettingsSections` |
| Cross-activity logbook routing | **PASS** — separate stores and root views per activity |

---

## C. Architecture Analysis

### Watch

Runtime: `DiveManager`, `FullComputerRuntimeEngine`, `ApneaWatchRuntimeStore`, `SnorkelingWatchRuntimeStore`, `DIRActivitySelectionStore`, `WatchSyncService`, `CloudSyncStore`, `PlannerBriefingCardStore`.

**Startup flow:** Legal gate → `ContentView` / activity selection → activity-owned root (Diving Gauge/FC, Apnea, Snorkeling).

**Strengths:** Mission mode invariants; draft throttle; reminder suppression policy; multi-activity sequential flow tests; independent Bühlmann oracle for Full Computer.

**Risks:** Physical Ultra validation pending; long-dive battery impact on 1 s FC loop unverified in field.

### iOS Companion

`IOSCompanionStoreCoordinator` lazy activity bundles; three-mode OC planner + CCR; separate Apnea/Snorkeling roots; `SharedIOSSettingsStore` for cross-activity settings only.

**Strengths:** Mode-projected planning; analysis cache completeness; cloud capability truthfulness (`ApneaCloudCapability`, `SnorkelingCloudCapability`); 1342 algorithm tests.

**Risks:** External planner validation pending; physical PDF render QA pending.

### Cross-App Integration

```text
Watch dive → HMAC v2 → iOS import → metadata merge → signed ACK → Watch dequeue
Apnea session → activity-discriminated WC transport → iOS Apnea logbook
Snorkeling session → local GPS + logbook; cloud status-only on iOS
iCloud KVS ← CloudSyncBudgetPolicy (per-key + aggregate cap)
Planner briefing PNG → WC file transfer → Watch receiver (sanitized filename, atomic swap)
Photos → signed management → PendingPhotoManagementResponseQueue
```

---

## D. Apple Watch Deep Code Analysis

| Area | Status | Notes |
|---|---|---|
| Activity selection + persistence | **PASS** | `DIRActivitySelectionStore`; migration from Diving-only |
| Diving Gauge runtime | **PASS** | NDL/TTS/ceiling; `WatchGaugeMathCompletionTests` |
| Full Computer 1 s loop | **PASS** | `FullComputerRuntimeEngine`; timing fault tests; DEBUG defer seam |
| Apnea lifecycle | **PASS** | Auto start/end, recovery, alarms; `IntegratedModesSequentialFlowTests` |
| Snorkeling GPS surface track | **PASS** | Local-only GPS; field QA **PENDING** |
| Dive lifecycle / draft restore | **PASS** | Throttled persistence; mission pending in draft |
| Mission Mode invariants | **PASS** | `MissionModeAlgorithmInvariantTests` |
| App Intents legal gate | **PASS** | All safety intents gated |
| Live banner + reminders | **PASS** | `LiveDiveReminderSuppressionPolicy`; VoiceOver in UI/UX remediation |
| Sync ACK userInfo | **PASS** | Fixed + tested |
| Photo delete ACK | **PASS** | `PendingPhotoManagementResponseQueue` |
| Briefing transfer | **PASS** | `PlannerBriefingFilenameSanitizer`; atomic swap |
| Logbook isolation | **PASS** | Diving / Apnea / Snorkeling separate stores |

### Watch Performance Notes

| Risk | Severity | Status |
|---|---|---|
| Alarm `@Published` blink 1 Hz | MEDIUM | **CLOSED** — view-local `TimelineView` |
| Full Computer 1 s tissue update | LOW | Acceptable; timing fault tests guard regressions |
| Briefing PNG decode memory | LOW | Staging + protected storage |
| Cross-activity memory pressure | LOW | Lazy stores; activity-scoped runtime |

### Watch Security Notes

| Area | Status |
|---|---|
| Dive sync HMAC + nonce (v2) | **PASS** |
| Photo management HMAC + replay | **PASS** |
| Briefing path confinement | **PASS** — sanitizer rejects traversal |
| Legal gate on intents | **PASS** |
| Cross-activity payload rejection | **PASS** — codec + negative tests |

---

## E. iOS Companion Deep Code Analysis

| Area | Status | Notes |
|---|---|---|
| Activity selection shell | **PASS** | `IOSCompanionActivitySelectionView`; lazy coordinator |
| Base / Deco / Technical modes | **PASS** | `PlannerModePolicy` projection |
| MOD / switch-depth clamp | **PASS** | `MODPresentationPolicy` + PDF alignment |
| CCR planner | **PASS** | Separate mode; Ratio Deco blocked |
| Apnea companion | **PASS** | Root, export, sync; cloud unavailable truthfulness |
| Snorkeling companion | **PASS** | Root, export; cloud status-only |
| Cloud merge (iOS) | **PASS** | Aggregate budget; conflict detector |
| Watch import metadata | **PASS** | `DiveSessionMerge.preferred` when profile-compatible |
| Settings ownership | **PASS** | `ActivitySettingsVisibility`; documented in `IOS_SETTINGS_OWNERSHIP_CURRENT.md` |
| Logbook isolation | **PASS** | No mixed global logbook route |

---

## F. Planner-Specific Deep Analysis

| Check | Status |
|---|---|
| Modes affect inputs, gases, validation, results | **PASS** |
| `liveMODIssues` uses projected input | **PASS** |
| Ascent-speed settings discoverability | **PASS** — `PlannerAscentSpeedSettingsLink` |
| Briefing card detail sheet | **PASS** — reference-only labeling |
| Environment reclamp on altitude/salinity | **PASS** — Technical + mode policy |
| Export includes mode + typed block reasons | **PASS** |
| Route summary / plan completeness gating | **PASS** |

---

## G. CCR / Rebreather Deep Analysis

| Area | Status |
|---|---|
| Setpoint / diluent / bailout validation | **PASS** |
| Inspired gas / tissue / CNS / OTU integration | **PASS** |
| Checklist import switch-depth clamp | **PASS** |
| Bailout MOD tolerance 0.5 m vs OC 0.05 m | **DOCUMENTED** — `CCRMODTolerancePolicy` |
| CCR UI/PDF density unavailable | **PASS** |
| CCR external physical QA | **PENDING** |

---

## H. Transit / Runtime / Deco Presentation

| Check | Status |
|---|---|
| `PlannerAscentTableBuilder` / `DecoStopsPresentationBuilder` | **PASS** — presentation-only |
| Presentation mutates canonical data | **PASS** — no mutation found |
| Full Computer deco-stop state machine presentation | **PASS** — faithful to engine output |

---

## I. Emergency / Rock Bottom

| Check | Status |
|---|---|
| Separate from normal consumption | **PASS** |
| Technical avg-depth toggle isolation | **PASS** |
| Display vs canonical liters | **PASS** — `GasLedgerDisplayFormatter` |
| CCR bailout not reusing OC bottom assumptions silently | **PASS** |

---

## J. Schedule-Aware Gas / Gas Ledger

| Check | Status |
|---|---|
| Segment allocation | **PASS** |
| Liters/bar separation | **PASS** |
| CCR diluent as OC consumption | **PASS** — blocked in CCR paths |

---

## K. Repetitive Dive / Residual Tissue

| Check | Status |
|---|---|
| Explicit prior-dive selection | **PASS** |
| No silent fresh-tissue fallback | **PASS** |
| Chronology / surface interval | **PASS** |

---

## L. Structured Equipment / Operational Checklist

| Check | Status |
|---|---|
| Role mapping + typed `gasRole` migration | **PASS** — `ChecklistRoleMigration` |
| Checklist generation | **PASS** |
| CCR checklist import/export round trip | **PASS** |

---

## M. Planner Briefing Card / Watch Transfer

| Check | Status |
|---|---|
| Reference-only labeling + freshness | **PASS** |
| Hash / size validation | **PASS** |
| `fileName` path sanitization | **PASS** — MAIN-DCA-020 closed |
| Atomic manifest swap | **PASS** — MAIN-DCA-021 closed |
| Detail sheet on iOS | **PASS** — UIUX-008 |

---

## N. Watch Image Inventory / Delete

| Check | Status |
|---|---|
| Watch source-of-truth | **PASS** |
| Signed payloads + path traversal block | **PASS** |
| Delete ACK when session inactive | **PASS** — MAIN-DCA-019 closed |
| Paired physical QA | **PENDING** |

---

## O. Cross-App Sync / Data Integrity

| Check | Status |
|---|---|
| Watch import metadata merge | **PASS** |
| Aggregate KVS budget | **PASS** — `CloudSyncBudgetPolicy` |
| Apnea activity-discriminated sync | **PASS** |
| Cross-activity payload rejection | **PASS** |
| TOFU peer secret threat model | **DOCUMENTED** — MAIN-DCA-013 |

---

## P. Multi-Activity Deep Analysis (V3.0)

| Check | Status |
|---|---|
| Root coordinator — single `NavigationStack` ownership | **PASS** |
| Activity preference migration from Diving-only | **PASS** |
| Feature flags — no placeholder production routes | **PASS** |
| Separate Settings stores / visibility guards | **PASS** |
| Separate Log stores (Diving / Apnea / Snorkeling) | **PASS** |
| No cross-activity menu logbook route | **PASS** |
| Deep-link / state-restoration ownership | **PASS** — activity-scoped |
| Backup/restore isolation | **PASS** — activity-specific export views |
| Apnea lifecycle concurrency | **PASS** — engine + runtime store |
| Snorkeling GPS/battery/privacy | **PASS** — local GPS; field QA **PENDING** |
| Full Computer 1 s runtime performance | **PASS** — software gate; battery QA **PENDING** |

Any cross-activity data corruption, routing, or settings leakage would be **P0** — none confirmed at this baseline.

---

## Q. Performance Analysis

| Risk | Severity | Status |
|---|---|---|
| Active-dive draft I/O every sample | HIGH | **CLOSED** — 8 s throttle |
| Alarm blink `@Published` 1 Hz | MEDIUM | **CLOSED** |
| Full Computer 1 s Bühlmann loop | LOW | Profiled; mutation resistance tests |
| Planner debounced recompute 200 ms | LOW | Acceptable |
| Briefing PNG render + transfer | LOW | Atomic swap limits partial state |
| Cross-activity lazy store init | LOW | `IOSCompanionStoreCoordinator` |

---

## R. Security / Privacy Analysis

| Area | Status |
|---|---|
| HMAC v2 + signed ACKs | **PASS** |
| Photo management auth + replay persistence | **PASS** |
| Briefing filename sanitization | **PASS** |
| Legacy sync v1 window | **DOCUMENTED** — `WatchSyncSchemaV1Policy` |
| Peer secret in applicationContext | **DOCUMENTED** — TOFU tradeoff |
| GPS privacy (Snorkeling local-only) | **PASS** |
| iCloud opt-in + capability truthfulness | **PASS** |
| Apnea cloud EXPLICITLY_UNAVAILABLE | **PASS** |
| Snorkeling cloud status-only | **PASS** |
| PDF complete file protection | **PASS** |
| Legal gate (onboarding) | **PASS** — EN/IT semantic keys |
| Secret scanning | **PASS** |

---

## S. Test Coverage Analysis

| Suite | Passed | Skipped | Failed |
|---|---:|---:|---:|
| iOS Algorithm Tests | 1342 | 0 | 0 |
| Watch Algorithm Tests | 880 | 0 | 0 |
| **Total** | **2222** | **0** | **0** |

**Strengths:** `MainDeepCodeAnalysisRemediationV1Tests`, `UIUXMainRemediationCurrentTests`, `Audit15Air39MultilevelProfileTests`, `IndependentBuhlmannOracle`, planner MOD/switch-depth suites, sync ACK policy, CCR math, mission mode, multi-activity sequential flow, cloud capability truthfulness.

**Gaps (external / physical only):**

- Paired Watch/iPhone E2E on physical hardware
- iCloud two-device conflict matrix
- Watch Ultra underwater validation
- Snorkeling field GPS course comparison
- Apnea wet interaction QA
- Subsurface desktop CSV round-trip
- Dynamic Type / VoiceOver manual matrix
- All items in `Docs/QA_EVIDENCE/*/README.md` — **PENDING**

---

## T. Issue Matrix

| ID | Sev | Pri | App | Area | File / Function | Title | Status |
|---|---|---|---|---|---|---|---|
| MAIN-DCA-001 | HIGH | P1 | Watch | Sync | `WatchSyncService` userInfo ACK | Watch ignored inbound ACK on userInfo | **FIXED** |
| MAIN-DCA-002 | HIGH | P1 | Watch | Cloud | `CloudSyncStore.save` | No per-key KVS cap | **FIXED** |
| MAIN-DCA-003 | MEDIUM | P2 | Both | Cloud | Multi-key KVS writes | Legacy oversized snapshots | **DOCUMENTED** |
| MAIN-DCA-004 | HIGH | P1 | iOS | Planner | `PlannerView.liveMODIssues` | MOD gate used full draft | **FIXED** |
| MAIN-DCA-005 | HIGH | P1 | iOS | Planner | `AnalysisCacheKey` | Cache omitted SAC/planning ref | **FIXED** |
| MAIN-DCA-006 | HIGH | P1 | Watch | Merge | `DiveSessionMerge` | Watch merge subset policy | **MITIGATED** |
| MAIN-DCA-007 | HIGH | P1 | Watch | Runtime | `endManualDive` | End intent no-op after handoff | **FIXED** |
| MAIN-DCA-008 | HIGH | P1 | Watch | Perf | `persistActiveDiveDraft` | Every-sample draft I/O | **FIXED** |
| MAIN-DCA-009 | MEDIUM | P2 | Watch | Mission | `ActiveDiveDraft` | Mission pending not persisted | **FIXED** |
| MAIN-DCA-010 | MEDIUM | P2 | iOS | Planner UI | Base results | END labeled MOD | **FIXED** |
| MAIN-DCA-011 | HIGH | P1 | iOS | Sync | `WatchSyncService.importSessionPayload` | Metadata-only Watch sync overwrites iPhone edits | **FIXED** |
| MAIN-DCA-012 | MEDIUM | P2 | Watch | Perf | Alarm blink | 1 Hz `@Published` blink | **FIXED** |
| MAIN-DCA-013 | MEDIUM | P2 | Both | Security | `WatchSyncAuth` | Peer secret in applicationContext | **DOCUMENTED** |
| MAIN-DCA-014 | MEDIUM | P2 | Both | Security | `SyncNonceReplayCache` | Replay persistence optional | **IMPROVED** |
| MAIN-DCA-015 | MEDIUM | P2 | iOS | CCR | `CCRChecklistImportCoordinator` | Import switch depth | **FIXED** |
| MAIN-DCA-016 | LOW | P3 | iOS | Privacy | Photo staging temps | Staging file protection | **VERIFIED** |
| MAIN-DCA-017 | LOW | P3 | iOS | Stability | Planner table helper | Force unwrap headers | **FIXED** |
| MAIN-DCA-018 | INFO | P1 | Both | QA | External matrices | Physical QA not executed | **PENDING** |
| MAIN-DCA-019 | HIGH | P1 | Watch | Sync/Photos | `deliverDeleteAck` | ACK skipped when session inactive | **FIXED** |
| MAIN-DCA-020 | MEDIUM | P2 | Watch | Security | `PlannerBriefingCardStore` | Briefing `fileName` not sanitized | **FIXED** |
| MAIN-DCA-021 | MEDIUM | P2 | Watch | Briefing | `importManifest` | Non-atomic package swap | **FIXED** |
| MAIN-DCA-022 | MEDIUM | P2 | Watch | Runtime | Reminder suppression | Incomplete vs depth banners | **FIXED** |
| MAIN-DCA-023 | LOW | P3 | iOS | Planner | `PlannerMODValidator.validateAll` | Deco-stop gas fallback dead path | **INFO** |
| MAIN-DCA-024 | LOW | P3 | iOS | CCR | `CCRPlanValidator` | 0.5 m bailout MOD slack | **DOCUMENTED** |
| MAIN-DCA-025 | HIGH | P1 | iOS | Cloud | `CloudSyncStore` multi-key | Aggregate KVS budget | **FIXED** |
| MAIN-DCA-026 | LOW | P3 | iOS | Cloud | `CloudSyncStore.synchronize` | Success date before sync completes | **FIXED** |
| MAIN-DCA-027 | MEDIUM | P2 | Both | Security | `WatchDiveSyncCodec` v1 | Legacy schema without nonce replay | **FIXED** |
| MAIN-DCA-028 | LOW | P3 | iOS | Merge | `DiveSessionMerge` | `gasLabel` LWW only | **FIXED** |
| MAIN-DCA-029 | LOW | P3 | Watch | Sync | `flushPendingTransfers` | Duplicate queue sends | **FIXED** |
| MAIN-DCA-030 | LOW | P3 | iOS | Localization | `TissueAnalyticsCharts` | Hardcoded `"Time"` axis | **FIXED** |
| MAIN-DCA-031 | INFO | P4 | Both | Localization | `.strings` catalogs | Legacy Italian-as-key aliases | **FIXED** |
| MAIN-DCA-032 | INFO | P3 | Watch | UX | Reminder deferral | Suppression visibility deferred | **DOCUMENTED** |
| IOS-ALG-005 | MED | P1 | iOS | Apnea | Cloud export | Apnea cloud stub misleading | **FIXED** |
| IOS-ALG-006 | MED | P1 | iOS | Settings | `MoreView` | Dual settings binding | **FIXED** |
| IOS-ALG-007 | MED | P1 | iOS | Tests | Keychain | XCTSkip in sync tests | **FIXED** |
| IOS-ALG-008 | MED | P2 | iOS | Checklist | Role inference | Typed `gasRole` migration | **FIXED** |
| IOS-ALG-009 | MED | P2 | iOS | PDF | MOD presentation | PDF MOD asymmetry | **FIXED** |
| IOS-ALG-011 | MED | P2 | iOS | Perf | Store init | Eager activity stores | **FIXED** |
| UIUX-002 | MED | P1 | iOS | Snorkeling | Cloud toggle | Misleading cloud backup UI | **FIXED** |
| UIUX-003–012 | VAR | P1–P3 | Both | UI/UX | Multiple | Accessibility, localization, planner links | **FIXED** |
| WATCH-MATH-007 | LOW | P3 | Watch | Math | Audit-15 Air 39 | Named multilevel regression | **FIXED** |
| WATCH-MATH-001/002 | MED | P1 | Watch | Math | Oracle gap | Independent Bühlmann oracle | **FIXED** |

---

## U. Detailed Action Plan

### P0

No compile blocker. Builds and 2,222 tests pass. No cross-activity P0 routing or data corruption confirmed.

### P1 (external — not code)

1. **MAIN-DCA-018** — Execute physical QA matrices with evidence in `Docs/QA_EVIDENCE/`.
2. Paired Watch/iPhone sync smoke on physical hardware.
3. iCloud two-device conflict matrix.

### P2 (documentation / monitoring)

- **MAIN-DCA-013** — Maintain peer-secret threat model in release notes.
- **MAIN-DCA-003** — Monitor legacy KVS migration in field.
- **MAIN-DCA-024** — Keep CCR MOD tolerance documented for support.

### P3 / P4

- **MAIN-DCA-032** — Optional deferred reminder visibility indicator (product decision).
- App Store marketing assets — **PENDING**.
- Subsurface external validation — **PENDING**.

---

## V. 7-Day Remediation Plan

| Day | Actions | Verification |
|---|---|---|
| 1 | Paired simulator sync smoke (both directions) | Evidence in `Docs/QA_EVIDENCE/WATCH_IOS_SYNC/` |
| 2 | iCloud two-device conflict matrix | Evidence folder |
| 3 | Watch Ultra physical QA subset | `WATCH_ULTRA_PHYSICAL_QA_MATRIX.md` rows |
| 4 | Snorkeling field GPS course | `SNORKELING_GPS/` evidence |
| 5 | Apnea wet interaction QA | `APNEA_WATCH_ULTRA/` evidence |
| 6 | VoiceOver + Dynamic Type manual pass | `DYNAMIC_TYPE_VOICEOVER/` |
| 7 | Full build + all validation scripts | 2,222+ tests green |

---

## W. 14-Day Remediation Plan

| Days | Focus |
|---|---|
| 1–4 | Physical paired sync + iCloud QA evidence |
| 5–7 | Watch Ultra underwater + Apnea wet QA |
| 8–10 | Subsurface CSV + external Bühlmann/CCR validation |
| 11–12 | App Store assets + legal/privacy review |
| 13–14 | TestFlight external cohort + checklist sign-off |

---

## X. Pre-Internal-TestFlight Checklist

- [x] `xcodegen generate` passes
- [x] Watch + iOS build succeed
- [x] iOS tests: 1342 passed, 0 skipped, 0 failed
- [x] Watch tests: 880 passed, 0 skipped, 0 failed
- [x] MAIN-DCA P1–P3 software items closed
- [x] iOS algorithm software gate 100%
- [x] UI/UX software gate 100%
- [x] Watch math software gate 100%
- [ ] Paired physical sync smoke — **PENDING**
- [ ] No physical QA marked PASS without evidence

---

## Y. Pre-External-TestFlight Checklist

- [ ] All internal physical items complete
- [ ] Paired sync both directions with signed ACK rejection cases
- [ ] Photo inventory/delete on paired hardware
- [ ] iCloud two-device conflict matrix — **PENDING**
- [ ] Watch Ultra physical QA — **PENDING**
- [ ] Snorkeling field GPS — **PENDING**

---

## Z. Pre-App-Store Checklist

- [ ] External TestFlight complete
- [ ] Subsurface external validation — **PENDING**
- [ ] App Store assets — **PENDING**
- [ ] Privacy manifest matches behavior
- [ ] Non-certified / reference-only copy verified EN/IT
- [ ] No DEBUG simulation in release build
- [ ] Legal review — **PENDING**

---

## AA. Recommended Cursor Remediation Commands

Do not execute during this audit.

### 1. External QA Evidence Execution

```text
CURSOR COMMAND — DIR DIVING EXTERNAL QA EVIDENCE EXECUTION

Execute matrices in Docs/QA_EVIDENCE/ (Watch Ultra, paired sync, iCloud, Dynamic Type/VoiceOver, Subsurface, Snorkeling GPS, Apnea wet). Mark PASS only with attached evidence. Do not fabricate screenshots.
```

### 2. App Store Marketing Asset Pass

```text
CURSOR COMMAND — DIR DIVING APP STORE MARKETING ASSET PASS

Complete Docs/QA_EVIDENCE/APP_STORE_MARKETING/ checklist. Verify EN/IT copy, screenshots, privacy nutrition labels against current multi-activity product.
```

### 3. Subsurface Desktop Validation

```text
CURSOR COMMAND — DIR DIVING SUBSURFACE DESKTOP VALIDATION

Import/export real dive CSV on Subsurface desktop. Document compatibility matrix. Mark external gate PASS only with logs.
```

### 4. External Bühlmann / CCR Reference Validation

```text
CURSOR COMMAND — DIR DIVING EXTERNAL BUHLMANN CCR VALIDATION

Run third-party reference vectors for OC Bühlmann and CCR planner against DIR DIVING exports. Attach evidence; do not modify production algorithms without explicit approval.
```

### 5. Long-Dive Battery / Thermal Profiling (Watch)

```text
CURSOR COMMAND — DIR DIVING WATCH LONG DIVE BATTERY PROFILE

Field or lab profile of Full Computer 1 s loop under thermal pressure on Watch Ultra. Attach battery/thermal logs to WATCH-PERF-001 evidence.
```

### 6. Deferred Reminder Visibility (Optional Product)

```text
CURSOR COMMAND — DIR DIVING WATCH DEFERRED REMINDER INDICATOR

If product approves MAIN-DCA-032 visibility indicator, implement without weakening LiveDiveReminderSuppressionPolicy safety invariants.
```

---

## AB. Final Verdict

### Is the code ready to compile?

**Yes.** Watch and iOS builds succeeded.

### Is it safe for internal TestFlight?

**Yes, conditionally.** All software-verifiable audit findings are closed; recommend paired simulator smoke before wide internal distribution.

### Is it safe for external TestFlight?

**No.** Physical QA evidence not attached.

### Is it ready for App Store?

**No.** Blocked by external QA, assets, and legal review.

### What blocks 100% code readiness?

- **MAIN-DCA-018** — physical/external QA not executed
- Field validation of Full Computer long-dive battery impact
- Subsurface and third-party Bühlmann/CCR reference validation

### What blocks 100% CCR readiness?

- External in-water / reference validation (**PENDING**)
- Documented bailout MOD tolerance policy (intentional, not a bug)

### What blocks 100% security readiness?

- TOFU peer secret tradeoff (documented, accepted for v1)
- Legacy schema v1 deprecation window (policy in place)

### What blocks 100% performance readiness?

- Physical long-dive battery/thermal evidence on Watch Ultra

### Are presentation layers faithful to canonical data?

**Yes** — ascent/runtime/deco builders are presentation-only; independent oracle confirms Full Computer tissue math.

### Is Rock Bottom conservative and isolated?

**Yes.**

### Is schedule-aware gas allocation correct?

**Yes** — tested in schedule gas consumption suites.

### Are gas ledger liters/bar values trustworthy?

**Yes** — display formatter tests confirm separation.

### Are briefing cards numerically faithful and reference-only?

**Yes** — with freshness warnings and sanitized filenames.

### Are structured Equipment/checklist mappings lossless?

**Yes** — typed role migration + round-trip tests.

### What must be fixed first?

1. **Execute physical QA matrices** — no code blockers remain for internal TestFlight software gate.
2. **Attach paired sync evidence** before external TestFlight.
3. **Complete App Store assets and legal review** before submission.

---

## AC. Validation Notes (Phase 13)

| Check | Result |
|---|---|
| Report file exists | Yes |
| Issue matrix exists | Yes (Section T) |
| Action plan + roadmaps | Yes (Sections U–W) |
| Audit pass modified production code | **No** — docs only for this pass |
| Build/test claims | PASS only where commands succeeded (2026-06-20) |
| Physical/external QA | **PENDING** — not passed |
| Multi-activity scope verified | Yes — Diving, Apnea, Snorkeling |

---

*End of V3.0 audit report — baseline `79e242e` + remediation bundle — 2026-06-20*
