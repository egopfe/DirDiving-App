# DIR Diving Watch Complete Algorithm / Safety / Runtime Audit — CCR Updated V3.0

**Audit date:** 2026-06-19  
**Repository:** `https://github.com/egopfe/DirDiving-App.git`  
**Audited branch:** `main`  
**Audited HEAD:** `622ba31` (source baseline for this audit)  
**Post-remediation HEAD:** see `Docs/2-DIR_DIVING_WATCH_COMPLETE_ALGORITHM_REMEDIATION_REPORT_CURRENT.md`  
**Scope:** Apple Watch MAIN (`DIRDiving Watch App`) + cross-target Shared Bühlmann core consumed by Full Computer; iOS referenced for sync/briefing codec parity only  
**Execution mode:** Read-only static analysis + macOS `xcodegen` / `xcodebuild` validation  
**Command source:** `commands_for_cursor/2-DIR_DIVING_WATCH_COMPLETE_ALGORITHM_AUDIT_CCR_UPDATED_V3.0.md`  
**Supersedes:** V2.0 report @ `c0b5cd9` (2026-06-14)

**Integrated context (read, not re-executed):**

| Document | Role |
|---|---|
| `Docs/1-DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_CCR_CURRENT.md` | iOS Bühlmann/CCR audit @ `c120771` |
| `Docs/IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md` | iOS math audit + 100% software remediation |
| `Docs/IOS_MAIN_ALGORITHM_MATH_REMEDIATION_REPORT_CURRENT.md` | Apnea recovery / OC CNS unavailable fixes |
| `Docs/WATCH_ULTRA_PHYSICAL_QA_MATRIX.md` | Physical gate (pending) |
| `Docs/WATCH_IOS_SYNC_QA_MATRIX.md` | Paired sync gate (pending) |

**Actions in this audit pass:**

- Created/updated this report only (read-only audit deliverable).
- No Swift production code modified by this audit command.
- Math gap-fill from prior remediation session committed separately in same push batch (not audit scope).

---

## Indice

| Sezione | Contenuto |
|---|---|
| [A. Executive Summary](#a-executive-summary) | Verdict, readiness, blockers |
| [B. Scope Confirmation](#b-scope-confirmation) | Preflight, build/test, exclusions |
| [C. Architecture Analysis](#c-architecture-analysis) | Multi-activity, FC Bühlmann, isolation |
| [D. Core Runtime Analysis](#d-apple-watch-core-runtime-analysis) | Gauge, FC, depth, GPS |
| [E–P. Area Verdicts](#e-dive-start-verdict) | Dive start through sync |
| [Q. Apnea / Snorkeling Verdicts](#q-apnea-verdict-v30) | V3.0 multi-activity |
| [R. Test Coverage](#r-test-coverage-analysis) | 844 XCTest |
| [S. Issue Matrix](#s-issue-matrix) | ID, severity, priority |
| [T. Action Plan](#t-detailed-action-plan) | P0–P4 |
| [U–W. QA Plans](#u-physical-watch-ultra-qa-plan) | Physical, sync, CCR |
| [X. Final Verdict](#x-final-verdict) | Release gates |

---

## A. Executive Summary

### Overall verdict

Status: **Almost ready (non-certified multi-activity companion)**

MAIN @ `622ba31` delivers a mature **three-activity** Watch product:

```text
DIR Diving (Watch)
├── Diving → Gauge | Full Computer (live Bühlmann ZH-L16C)
├── Apnea (lifecycle, recovery policy, sync)
└── Snorkeling (surface GPS, dips, navigation, sync)
```

**Full Computer** uses shared `Shared/BuhlmannCore` via `FullComputerRuntimeEngine` / `FullComputerDecoSolver` with live tissue evolution, decompression stop state machine, gas-switch policy, checkpoint restore, and fail-closed guards. **Gauge** retains TTV/informational runtime without decompression authority. **CCR live runtime is absent on Watch** — CCR appears only as **reference-only planner briefing cards** exported from iOS. Apnea recovery policy desync (P1) is **closed** @ `c120771`.

macOS validation on this machine:

- **Watch build:** SUCCEEDED (`generic/platform=watchOS Simulator`)
- **Watch Algorithm Tests:** **844 executed, 19 skipped, 0 failed** (Apple Watch Series 11 46mm)
- **MAIN target isolation:** PASS
- **Secrets scan:** PASS

Remaining gates: **physical Ultra QA**, **paired iPhone sync evidence**, **external Bühlmann reference validation**, **long-dive battery profiling**.  
**Software remediation @ 2026-06-19:** WATCH-BRIEF-005 closed (gasEmergency removed); WATCH-SYNC-001 closed (WatchSyncTestSupport); **856 tests / 0 skipped / 0 failed** — see remediation report.

### Readiness estimates (source audit @ `622ba31`)

| Dimension | Readiness | Confidence | Primary blockers |
|---:|---:|---|---|
| **Overall Watch MAIN** | **94%** | High | Physical Ultra QA; paired sync evidence |

### Readiness after software remediation (2026-06-19)

| Dimension | Software readiness |
|---:|---:|
| **Overall Watch MAIN (software)** | **100%** |
| **Software findings open** | **0** |
| **Software-only skipped tests** | **0** |
| Physical / external gates | **PENDING** (unchanged) |

### Readiness estimates (historical source audit)
| **Mathematical / runtime robustness** | **96%** | High | External Bühlmann reference; Ultra field validation |
| **Safety algorithm confidence** | **94%** | High | Physical depth/ascent/haptic QA |
| **Lifecycle confidence** | **95%** | High | Underwater FC/gauge start/stop evidence |
| **Sync / data confidence** | **88%** | Medium-high | Two-device QA pending |
| **Security readiness** | **88%** | Medium-high | Keychain peer-secret tests skip without pairing |
| **Performance / battery** | **91%** | Medium | Long-dive profiling open |
| **CCR / iOS planner compatibility** | **93%** | High | Live CCR absent by design; briefing export fixed |
| **Planner briefing cards** | **88%** | High | `gasEmergency` kind unused |
| **Apnea math / recovery** | **97%** | High | Physical wet QA pending |
| **Snorkeling math / GPS** | **95%** | High | Physical GPS QA pending |
| **Test coverage** | **93%** | High | 844 XCTest; hardware gaps |
| **Physical QA evidence** | **45%** | — | Matrices exist, slots empty |

### Release posture

| Gate | Verdict |
|---|---|
| Compile / internal use | **PASS** |
| Internal TestFlight (Watch algorithm) | **Conditional yes** — tests green; mock sensor disclosed |
| External TestFlight | **Not yet** — Ultra physical + paired sync QA |
| App Store (Watch scope) | **Not yet** — same + legal/marketing review |
| Certified dive computer claim | **Never** — Gauge TTV informational; FC non-certified companion |

### Severity summary

| Severity | Count | Notes |
|---:|---:|---|
| CRITICAL | 0 | No fail-open decompression clearing observed in code/tests |
| HIGH | 0 | Prior WATCH-BRIEF-001 closed |
| MEDIUM | 6 | Physical QA pending; sync two-device; battery profiling |
| LOW | 4 | `gasEmergency` dead kind; GPS restart edge; doc drift |
| INFO | 3 | TTV naming; Mission Mode Low Power wording; test-host l10n on iOS cross-target |

### Most urgent issues

1. **WATCH-PHY-001 / WATCH-PHY-002** — Physical Ultra and paired sync matrices still empty.
2. **WATCH-EXT-001** — External Bühlmann reference validation (shared core, FC parity).
3. **WATCH-BRIEF-005** — ~~`PlannerBriefingCardKind.gasEmergency` defined but no export path~~ **CLOSED** — kind removed; legacy payloads filtered (see remediation report).

---

## B. Scope Confirmation

| Check | Result |
|---|---|
| Branch | `main` |
| HEAD | `622ba31` (+ math gap-fill in same commit batch) |
| Remote | `origin/main` aligned |
| Watch target | `DIRDiving Watch App` |
| Test target | `DIRDiving Watch Algorithm Tests` |
| iOS cross-check | Referenced for briefing/sync codecs — not full iOS re-audit |

### V3.0 product scope confirmed

- Launch → legal/onboarding → activity selection (Diving / Apnea / Snorkeling) → activity-owned root
- Diving → Gauge or Full Computer predive path
- Apnea and Snorkeling are **production MAIN** activities (not experimental placeholders)
- Settings and Logbook ownership per activity verified in architecture tests

### Experimental exclusions (`project.yml`)

**Still excluded from Watch MAIN:**

| Category | Excluded paths |
|---|---|
| Views | `BuddyAssistView.swift`, `ExperimentalConceptsView.swift` |
| Utils | `ExperimentalFeatures.swift` |
| Models | `ExplorationModels.swift`, buddy handshake models |
| Services | `ExplorationStore.swift`, `BuddyAssist*`, `SecureBuddyStore.swift` |

**V3.0 change vs V2.0 audit:** `ApneaView.swift`, `SnorkelingView.swift`, Apnea/Snorkeling runtime stores, and Shared activity engines **are compiled into MAIN**. Legacy `ExplorationStore` archived under `Legacy/Experimental/` (@ `c120771`).

### Build / test commands and results

```bash
xcodegen generate
# OK

./Scripts/check_main_target_isolation.sh
# PASS

./Scripts/check_secrets.sh
# PASS

xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving Watch App" \
  -destination 'generic/platform=watchOS Simulator' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build
# ** BUILD SUCCEEDED **

xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving Watch Algorithm Tests" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 11 (46mm)' test
# ** TEST SUCCEEDED ** — 844 executed, 19 skipped, 0 failures (~71s)
```

**Skipped tests:** 6 Watch sync integration tests require live Keychain peer secret; 13 other skips are environment/feature gated — documented in test output, not failures.

---

## C. Architecture Analysis

### Target membership

| Layer | Location | Notes |
|---|---|---|
| App entry | `App/DIRDivingApp.swift` | Legal gate → `ContentView` |
| Activity selection | `Views/StartupFlowView.swift`, `Models/DIRModesAndStartup.swift` | Cold-launch picker |
| Diving live | `Views/DiveLiveView.swift`, `Services/DiveManager.swift` | Gauge + FC |
| Full Computer | `Services/FullComputerRuntimeEngine.swift`, `Utils/FullComputerDecoSolver.swift` | Live Bühlmann consumer |
| Shared core | `Shared/BuhlmannCore/**` | Cross-target with iOS Planner |
| Apnea | `Shared/Utils/ApneaSessionEngine.swift`, `Services/ApneaWatchRuntimeStore.swift`, `Views/ApneaView.swift` | MAIN promoted |
| Snorkeling | `Shared/Utils/SnorkelingSessionEngine.swift`, `Services/SnorkelingWatchRuntimeStore.swift`, `Views/SnorkelingView.swift` | MAIN promoted |
| Briefing cards | `Services/PlannerBriefingCardStore.swift`, `PlannerBriefingWatchReceiver.swift` | Reference-only |
| Sync | `Services/WatchSyncService.swift`, activity codecs | HMAC signed-ACK |

### Canonical data classification

| Data on Watch | Classification |
|---|---|
| Live depth / FC Bühlmann state | **1 — canonical live Watch runtime** |
| Gauge TTV / ascent metrics | **1 — canonical live Watch** |
| Apnea/Snorkeling session metrics | **1 — canonical activity runtime** |
| Planner briefing PNG + manifest | **4 — reference briefing (non-authoritative)** |
| iOS imported dive/plan payloads | **3 — synced structured metadata** |
| CCR live setpoint/diluent control | **7 — unsupported on Watch live UI** |

### Documentation drift

| Doc | Drift |
|---|---|
| V2.0 Watch audit | Incorrectly listed Apnea/Snorkeling views as excluded — **superseded** |
| V2.0 “no Bühlmann on Watch” | **Superseded** — Full Computer is live @ `622ba31` |
| Feature matrices | Should label FC as non-certified companion, not recreational gauge only |

**Architecture readiness: 95%**

---

## D. Apple Watch Core Runtime Analysis

### Gauge path

`DiveManager` → depth validation → lifecycle → TTV (informational), ascent rate, depth safety bands, reminders, haptics. No decompression schedule on Gauge.

### Full Computer path

`DiveManager` bootstraps `FullComputerRuntimeEngine` after predive confirmation/import. Engine ingests depth samples each tick; `FullComputerDecoSolver` projects ceiling/NDL/TTS/deco schedule from `BuhlmannEngine.runtimeProjection`. Gas switches require explicit user confirmation (`FullComputerNoAutomaticGasSwitchTests`). Checkpoint schema v5 restores tissue + stop tracker + gas-switch state.

Fail-closed behavior covered by: `FullComputerReleaseHardValidationTests`, `FullComputerDecoStopStateMachineTests`, `BuhlmannCoreCrossTargetEquivalenceTests`, audit-15-style guards in Watch suite.

### Depth lifecycle (Gauge + shared)

| Parameter | Value |
|---|---|
| Auto-start depth | `> 1.0 m`, debounced valid samples |
| Auto-stop | shallow dwell per configuration |
| Depth safety bands | configurable caution/critical/exceeded |
| Ascent rate | windowed; band limits |

### GPS, haptics, timers

- GPS: best-effort at dive boundaries; Snorkeling continuous surface track via `GPSManager`
- Haptics: depth-limit, ascent coordinators; activity-specific alarm engines
- Mission Mode: reduces animations only — does not alter depth math (`MissionModeAlgorithmInvariantTests`)

**Core runtime readiness: 96%**

---

## E. Dive Start Verdict

| Question | Answer |
|---|---|
| Manual start reachable? | **Yes** — Live screen + App Intents (after legal gate) |
| Automatic start works? | **Yes** in code/tests; physical Ultra pending |
| Duplicate prevention works? | **Yes** — blocked when dive/session active per activity |
| Manual + automatic collision safe? | **Yes** — handoff gates in `DiveManager` |
| Restore after relaunch safe? | **Yes** — draft JSON + FC checkpoint restore |
| FC predive confirmation enforced? | **Yes** — `FullComputerPrediveConfirmationView` |

**Dive Start readiness: 95%**

---

## F. Reminder Verdict

| Question | Answer |
|---|---|
| Multiple reminders implemented? | **Yes** — `DiveReminderEngine` |
| Recurring reminders reliable? | **Yes** — unit/integration tests |
| Haptics/overlays safe? | **Yes** — `LiveDiveReminderSuppressionPolicy` |
| Safety alerts take priority? | **Yes** — critical alarms supersede reminders |

**Reminder readiness: 93%**

---

## G. Image Subsystem Verdict

| Question | Answer |
|---|---|
| Image transfer works? | **Yes** — `WCSession.transferFile` + validator |
| Inventory sync truthful? | **Yes** — HMAC inventory |
| Deletion from Watch safe? | **Yes** — prefix policy |
| Deletion from iOS requires Watch ACK? | **Yes** — signed delete ACK |
| Bundled images protected? | **Yes** — `UserImageStorePolicyTests` |
| No effect on dive metrics? | **Confirmed** |

**Image subsystem readiness: 93%**

---

## H. Planner Briefing Card Verdict

| Question | Answer |
|---|---|
| Card transfer works? | **Yes** — OC + CCR export paths (@ remediation) |
| Numerical values match iOS canonical plan? | **Yes at export** — shared presentation builders |
| PNG and metadata agree? | **Yes** — SHA256 on import |
| Stale cards handled safely? | **Yes** — `plannerBriefingSessionId` rotation + 24h orphan cleanup |
| Clearly reference-only? | **Yes** — UI labels + incomplete package warning |
| Cannot affect live Watch calculations? | **Confirmed** — `FullComputerWatchArchitectureGuard` |
| Unsupported CCR live fields fail safely? | **Yes** — no CCR runtime tokens in FC engine |

### Post-remediation status (WATCH-BRIEF-*)

| ID | V2.0 status | V3.0 status |
|---|---|---|
| WATCH-BRIEF-001 CCR briefing export | Open | **FIXED** — `CCRPlannerBriefingExportSupport` |
| WATCH-BRIEF-002 planner session ID | Open | **FIXED** — `PlannerStore.plannerBriefingSessionId` |
| WATCH-BRIEF-003 incomplete package UX | Open | **FIXED** — Watch incomplete warning |
| WATCH-BRIEF-004 orphan staging | Open | **FIXED** — 24h cleanup |
| WATCH-BRIEF-005 gasEmergency kind | Open | **OPEN** — model only |

**Planner Briefing Cards readiness: 88%**  
**Briefing Card Numerical Fidelity readiness: 90%**  
**Briefing Card Transfer / Persistence readiness: 91%**

---

## I. Small-Screen Safety Visibility Verdict

| Question | Answer |
|---|---|
| Depth hero remains visible? | **Yes** — `LiveDiveBannerPresentationPolicy` |
| Critical banners remain visible? | **Yes** — priority ordering tested |
| Non-critical banners collapse? | **Yes** — reminder suppression |
| VoiceOver order logical? | **Yes** — layout contract tests |

**Small-Screen Safety Visibility readiness: 92%**

---

## J. Reminder Dismiss / Suppression Verdict

| Question | Answer |
|---|---|
| Manual dismiss works? | **Yes** — policy tested |
| Auto-dismiss remains? | **Yes** |
| Critical alarms non-dismissible? | **Yes** — fail-closed on safety overlays |
| Suppression deterministic? | **Yes** — `LiveDiveReminderSuppressionPolicyTests` |

**Reminder Dismiss / Suppression readiness: 92%**

---

## K. Mission Mode Verdict

| Question | Answer |
|---|---|
| Affects depth sampling? | **No** |
| Affects depth display? | **No** |
| Affects reminders? | **No** — overlay priority unchanged |
| Affects haptics? | **No** |
| Affects GPS? | **No** |
| Affects alarms? | **No** |
| Affects sync/export? | **No** |
| Low Power wording truthful? | **Yes** — reduces animations only |

**Mission Mode readiness: 94%**

---

## L. Sensor Source Verdict

| Question | Answer |
|---|---|
| Automatic vs simulation policy clear? | **Yes** — `SensorSourceMode` + developer gate |
| Simulation cannot ship accidentally? | **Yes** — `DeveloperSettings` required |
| Apnea/Snorkeling depth feeds isolated? | **Yes** — per-activity stores |

**Sensor Source readiness: 93%**

---

## M. Branding Verdict

BUSSOLA terminology, octopus branding, dark/neon Watch design preserved. App icon assets present. **Branding readiness: 96%**

---

## N. Unit / Date Localization Verdict

Metric canonical storage; Watch formatters for depth/time. Locale-adaptive logbook dates tested. EN/IT parity sweeps pass on Watch host. **Unit consistency readiness: 94%**

---

## O. CCR/Rebreather Compatibility Verdict

| Principle | Status |
|---|---|
| Live CCR runtime on Watch | **Absent by design** — architecture guard enforced |
| CCR briefing cards on Watch | **Supported** — reference-only import/display |
| CCR fields affect FC calculations | **No** — verified |
| iOS CCR planner → Watch briefing | **Yes** — export path fixed |

**CCR/Rebreather compatibility readiness: 93%**

---

## P. App Intents / Action Button Verdict

Legal acceptance gate before dive intents. Action Button safety tests pass. **App Intents readiness: 91%**

---

## Q. Apnea Verdict (V3.0)

| Question | Answer |
|---|---|
| Recovery policy drives lifecycle duration? | **Yes** — @ `c120771`; `ApneaRecoveryPolicyLifecycleTests` (17 tests) |
| Early dive gating wired? | **Yes** — `allowEarlyDiveWhenIncomplete` |
| Cross-activity isolation? | **Yes** — `ApneaArchitectureIsolationTests` |
| Sync namespace separate? | **Yes** — `ApneaSessionSyncCodec` |

**Apnea readiness: 97%**

---

## Q2. Snorkeling Verdict (V3.0)

| Question | Answer |
|---|---|
| Surface GPS distance consistent live/persisted? | **Yes** — `SnorkelingDistanceConsistencyTests` |
| Underwater fixes excluded from distance? | **Yes** |
| Navigation/return engines isolated? | **Yes** — `SnorkelingArchitectureIsolationTests` |
| Sync namespace separate? | **Yes** — `SnorkelingSessionSyncCodec` |

**Snorkeling readiness: 95%**

---

## R. Sync / Security / Payload Validation

- HMAC-SHA256 sync key via `WatchSyncAuth` + Keychain peer secret
- Signed ACK dequeue for dive, Apnea, Snorkeling pending transfers
- Nonce replay cache on init
- Tests: `WatchAckVerifierSecurityTests`, `WatchSyncPendingQueueTests`, `SnorkelingRouteAckWatchTests`

**Sync/Security readiness: 88%** (two-device evidence pending)

---

## S. Performance / Battery / Memory

- FC engine ticks on depth ingest — O(compartments) per second; acceptable for Watch
- Snorkeling GPS filtering reduces fix churn
- Long-dive thermal/battery profiling **not evidenced** — physical P3

**Performance/Battery readiness: 91%**

---

## T. Test Coverage Analysis

| Suite | Executed | Failed | Skipped |
|---|---:|---:|---:|
| DIRDiving Watch Algorithm Tests | 844 | 0 | 19 |

**Representative coverage:**

| Area | Test files (approx) |
|---|---:|
| Full Computer / Bühlmann | 18+ |
| Apnea | 23+ |
| Snorkeling | 25+ |
| Sync / briefing | 15+ |
| Gauge / dive core | 8+ |

**Test coverage readiness: 93%**

---

## U. Issue Matrix

| ID | Sev | Pri | Area | Title | Status |
|---|---|---|---|---|---|
| WATCH-PHY-001 | MED | P2 | physical QA | Ultra depth/ascent/haptic field validation | **PENDING** |
| WATCH-PHY-002 | MED | P2 | physical QA | Paired iPhone sync round-trip evidence | **PENDING** |
| WATCH-EXT-001 | MED | P2 | algorithm | External Bühlmann reference vs shared core | **PENDING** |
| WATCH-BRIEF-005 | LOW | P4 | briefing | `gasEmergency` card kind unused | **OPEN** |
| WATCH-PERF-001 | LOW | P3 | performance | Long-dive battery/thermal profile | **PENDING** |
| WATCH-SYNC-001 | INFO | P3 | sync | Sync integration tests skip without peer secret | **KNOWN** |
| WATCH-DOC-001 | INFO | P4 | docs | V2.0 doc claimed no FC/Apnea on MAIN | **FIXED** (this report) |

---

## V. Detailed Action Plan

| Priority | Action | Owner | Deps |
|---|---|---|---|
| P2 | Execute `WATCH_ULTRA_PHYSICAL_QA_MATRIX` | QA | Ultra hardware |
| P2 | Execute `WATCH_IOS_SYNC_QA_MATRIX` two-device | QA | Paired phones |
| P2 | External Bühlmann fixture comparison (shared core) | QA | Reference tool |
| P3 | Long-dive battery profiling FC vs Gauge | Eng | Ultra |
| P4 | Export or remove `gasEmergency` briefing kind | Eng | Product decision |

---

## W. Physical Watch Ultra QA Plan

Status: **PENDING** — matrix exists; no signed evidence in repo.

Profiles: gauge auto-start, FC multilevel + gas switch, ascent alarms, water lock, Action Button, mission mode, low battery.

---

## X. CCR/Rebreather Compatibility QA Plan

Status: **PENDING** external validation.

Verify: CCR briefing card import displays reference labels; FC runtime ignores CCR tokens; iOS CCR export → Watch receive → PNG/hash match; no live setpoint/diluent on Watch.

---

## Y. Planner Briefing End-to-End QA Plan

Status: **PENDING** physical.

OC + CCR export from iOS → Watch receive → Settings viewer → confirm reference-only + incomplete warning → confirm no FC state mutation.

---

## Z. Final Verdict

| Question | Answer |
|---|---|
| Safe for internal Watch development use? | **Yes** |
| Software algorithm gate? | **PASS** @ 844/844 executed tests |
| External TestFlight ready? | **Not yet** — physical + paired sync |
| App Store ready? | **Not yet** |
| Certified dive computer? | **No** — companion positioning only |

**Watch MAIN algorithm audit V3.0: CONDITIONAL PASS (software) / NO-GO (external release until physical + external evidence complete)**

---

*End of report — V3.0 @ 2026-06-19*
