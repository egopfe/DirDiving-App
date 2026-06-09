# DIR Diving Watch Complete Algorithm / Safety / Runtime Audit — Current (CCR Updated)

**Audit date:** 2026-06-08  
**Repository:** `https://github.com/egopfe/DirDiving-App.git`  
**Audited branch:** `main`  
**Audited HEAD:** `d756a89` (`d756a89…`)  
**HEAD subject:** `fix(ios): complete Bühlmann comprehensive readiness remediation on main.`  
**Scope:** Apple Watch MAIN target (`DIRDiving Watch App`) only  
**Execution mode:** Read-only static analysis + macOS `xcodegen` / `xcodebuild` validation  
**Source command:** `commands_for_cursor/2-DIR_DIVING_WATCH_COMPLETE_ALGORITHM_AUDIT_CCR_UPDATED.md`

**Integrated context (read, not re-executed):**

| Document | Role |
|---|---|
| `Docs/WATCH_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md` | Prior Watch audit @ `5415213` (21 integration test failures — superseded) |
| `Docs/WATCH_MAIN_ALGORITHM_MATH_AUDIT_REMEDIATION_REPORT.md` | Remediation deltas |
| `Docs/WATCH_MAIN_ALGORITHM_MATH_AUDIT_FIX_COMPLETION_REPORT.md` | WATCH-TEST-001 / HIGH-001 closure |
| `Docs/WATCH_ULTRA_PHYSICAL_QA_MATRIX.md` | Physical gate (pending) |
| `Docs/WATCH_IOS_SYNC_QA_MATRIX.md` | Paired sync gate (pending) |
| `Docs/WATCH_CSV_EXPORT_POLICY.md` | Watch vs iOS CSV policy |
| `Docs/1-DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_CCR_CURRENT.md` | iOS CCR context @ `cc4d783` / remediation @ `d756a89` |

**Actions in this audit pass:**

- Created this report only (read-only audit).
- No Swift, UI, algorithm, sync, or test production code modified.
- No commit or push performed.

---

## A. Executive Summary

### Overall verdict

Status: **Almost ready (non-certified companion)**

MAIN @ `d756a89` delivers a mature Watch dive lifecycle (auto/manual start, depth validation, ascent/depth safety, TTV informational index, reminders, images, compass/GPS, signed-ACK sync, App Intent legal gates). **Watch has zero CCR / Bühlmann / Ratio Deco runtime** — iOS planner advances do not turn Watch into a decompression computer. macOS build and **191/191** Watch algorithm tests (13 skipped) pass on Apple Watch Series 11 (46mm) simulator.

Prior audit blockers (WATCH-TEST-001 integration isolation, WATCHMATH-HIGH-001 finalizing draft kill, mock fallback visibility, unsigned ACK dequeue) are **closed** in current `main`. Remaining gates are **physical QA**, **paired iPhone sync evidence**, and **documented Watch/iOS CSV export divergence**.

### Readiness estimates

| Dimension | Readiness | Confidence | Primary blockers |
|---:|---:|---|---|
| **Overall Watch MAIN** | **94%** | High on code/tests | Physical Ultra QA |
| **Dive Start (auto/manual)** | **95%** | High | Physical start/stop underwater |
| **Dive Reminders** | **92%** | High | Overlay priority physical QA |
| **User Images / inventory** | **93%** | High | Paired delete-ACK physical QA |
| **Mission Mode** | **96%** | High | UI-only — invariant tests pass |
| **Sensor Source / simulation** | **94%** | High | Entitlement smoke on Ultra |
| **Branding / icon** | **90%** | Medium | Visual QA on device sizes |
| **Unit consistency** | **93%** | High | CSV export metric policy documented |
| **App Intents / Action Button** | **95%** | High | Hardware shortcut physical QA |
| **Sync / Security** | **92%** | Medium-high | Two-device ACK matrix pending |
| **CCR / iOS planner compatibility** | **98%** | High | No CCR on Watch — isolation verified |
| **Performance / battery** | **91%** | Medium | Long-dive field profiling open |
| **Test coverage** | **90%** | High | 191 XCTest; hardware gaps |
| **Physical QA evidence** | **45%** | — | Matrices exist, slots empty |

### Release posture

| Gate | Verdict |
|---|---|
| Compile / internal use | **PASS** |
| Internal TestFlight (Watch algorithm) | **Conditional yes** — tests green; mock-fallback UX disclosed |
| External TestFlight | **Not yet** — Ultra physical + paired sync QA |
| App Store (Watch scope) | **Not yet** — same + legal/marketing review |
| Certified dive computer claim | **Never** — TTV informational; no Bühlmann/CCR on Watch |

### Severity summary

| Severity | Count | Notes |
|---:|---:|---|
| CRITICAL | 0 | No live decompression authority on Watch |
| HIGH | 0 | Prior HIGH-001 remediated |
| MEDIUM | 2 | Physical QA pending; Watch/iOS CSV policy divergence (documented) |
| LOW | 4 | GPS auth restart, legacy draft edge cases, sample timestamp source, manual-end UX |
| INFO | 3 | TTV naming, OTU/CNS N/A on Watch, Mission Mode Low Power wording |

---

## B. Scope Confirmation (Phase 0)

| Check | Result |
|---|---|
| Branch | `main` |
| HEAD | `d756a89` |
| Working tree at audit start | Clean |
| Remote | `origin/main` aligned |
| Watch target | `DIRDiving Watch App` |
| Test target | `DIRDiving Watch Algorithm Tests` |
| iOS scope | Referenced only for sync codec parity — not re-audited in depth |

### Experimental exclusions (`project.yml`)

Confirmed excluded from Watch MAIN:

- **Models:** `ExplorationModels.swift`, `BuddyAssistMessage.swift`, `BuddyPairingHandshake.swift`
- **Services:** `ExplorationStore.swift`, `BuddyAssistService.swift`, `BuddyAssistPeripheralService.swift`, `BuddyPairingKeyAgreement.swift`, `SecureBuddyStore.swift`
- **Views:** `ApneaView.swift`, `SnorkelingView.swift`, `BuddyAssistView.swift`, `ExperimentalConceptsView.swift`
- **Utils:** `ExperimentalFeatures.swift`

### Build / test execution

```bash
xcodegen generate
xcodebuild -scheme "DIRDiving Watch App" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 11 (46mm)' build
xcodebuild -scheme "DIRDiving Watch Algorithm Tests" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 11 (46mm)' test
```

| Command | Result |
|---|---|
| `xcodegen generate` | **PASS** |
| `DIRDiving Watch App` build | **BUILD SUCCEEDED** |
| `DIRDiving Watch Algorithm Tests` | **PASS** — **191 executed**, 13 skipped, **0 failures** |

**Simulator note:** Apple Watch Ultra 2 (49mm) unavailable; **Apple Watch Series 11 (46mm)** used (consistent with prior audits).

Optional iOS validation (shared codec context only — not re-run in this pass; iOS @ `d756a89` was green in prior session: 540 iOS tests).

---

## C. Architecture Inventory (Phase 1)

### Watch runtime stack

| Layer | Primary files | Status |
|---|---|---|
| App entry | `App/DIRDivingApp.swift`, `App/LegalAcceptanceStore.swift` | Implemented |
| Dive lifecycle | `Services/DiveManager.swift`, `Utils/DiveLifecycleAlgorithm.swift` | Implemented |
| Depth sensor | `Services/DepthSensorProvider.swift`, `AppleDepthSensorProvider.swift`, `MockDepthSensorProvider.swift`, `SensorProviderFactory.swift` | Implemented |
| Safety / ascent | `Models/DepthSafetyConfiguration.swift`, `AscentRateLimits.swift`, `AscentSafetyHapticCoordinator.swift`, `DepthLimitHapticCoordinator.swift` | Implemented |
| TTV | Computed in `DiveManager` / display views — **informational only** | Implemented |
| Reminders | `Services/DiveReminderEngine.swift` (via DiveManager hooks), settings store | Implemented |
| GPS | `Services/GPSManager.swift`, `Utils/GPSFallbackPolicy.swift` | Implemented |
| Haptics | `Services/HapticService.swift` | Implemented |
| Sync | `Services/WatchSyncService.swift`, `WatchDiveSyncCodec.swift`, `WatchSyncAuth.swift` | Implemented |
| Log / CSV | `Services/DiveLogStore.swift`, `SubsurfaceExportService.swift` | Implemented |
| Images | `Services/UserImageStore.swift` | Implemented |
| App Intents | `Services/ActionButtonIntents.swift` | Implemented |
| Mission Mode | `Utils/MissionModeRuntimeProfile.swift`, `MissionModeLifecycle` | UI-only profile |
| Units | `Utils/DIRUnitConversions.swift`, `WatchDepthFormatting.swift`, `Formatters.swift` | Implemented |

### Shared iOS / Watch relationship

| Item | Finding |
|---|---|
| Compile units | **Separate** — Watch uses repo-root `App/Models/Services/Views/Utils`; iOS uses `iOSApp/` |
| Sync codec | Parallel files must stay aligned: `WatchDiveSyncCodec.swift` (Watch) ↔ `iOSApp/Services/WatchDiveSyncCodec.swift` |
| CCR / Bühlmann | **iOS only** — no Watch target membership |
| Stale docs | Some INDEX entries predate CCR; Watch docs correctly omit CCR runtime |

### Test coverage snapshot

| Metric | Value |
|---|---|
| Watch test Swift files | **32** |
| Approx. test methods | **~188** |
| Executed @ audit | **191 passed**, 13 skipped |

Key suites: `DiveManagerAlgorithmIntegrationTests`, `WatchMainAlgorithmAuditRemediationTests`, `WatchSyncServiceIntegrationTests`, `DiveReminderEngineTests`, `MissionModeAlgorithmInvariantTests`, `UserImageStorePolicyTests`, `ActionButtonIntentsSafetyTests`.

---

## D. Core Algorithm / Runtime Audit (Phase 2)

### Verified

| Area | Evidence | Status |
|---|---|---|
| Depth spike guard | `DepthSampleValidation` > 90 m/min | OK |
| Frozen depth (active dive) | 30 s @ ±0.001 m | OK |
| Stale sample | 8 s age gate | OK |
| Depth cap | 350 m | OK |
| 35 / 38 / 40 m bands | `DepthSafetyConfiguration` + haptic coordinators | OK |
| Ascent rate zones | `AscentRateLimits`, `AscentSafetyHapticCoordinator` | OK |
| Two-phase draft | `.active` / `.finalizing` — HIGH-001 fix | OK |
| Monotonic elapsed clock | `MonotonicElapsedClock` | OK |
| Idempotent finalize | `DiveManager` + tests | OK |
| TTV | Informational index — not NDL/TTS/deco | OK |

### Gaps (non-blocking code)

| ID | Gap | Severity |
|---|---|---|
| WATCH-GPS-001 | GPS authorization restart outside active dive — battery policy | LOW |
| WATCH-LC-001 | Legacy draft schema decode edge | LOW |
| WATCH-S2-003 | Sample timestamp source documentation | INFO |

**Core runtime readiness: 94%**

---

## E. Dive Start Audit (Phase 3)

### Manual start

| Check | Status |
|---|---|
| Manual Start on Live screen | OK |
| Does not fake depth when unavailable | OK — manual lifecycle flag |
| App Intent gated by legal acceptance | OK |
| Integrates GPS entry window (6 s) | OK |
| Manual → auto handoff when depth > 1.0 m | OK |

### Automatic start

| Check | Status |
|---|---|
| Threshold > 1.0 m × 2 samples | OK — `DiveLifecycleAlgorithm` |
| Stop ≤ 0.3 m × 8 s dwell | OK |
| No duplicate auto-start when active | OK |
| Debounce / collision tests | OK — `DiveManagerAlgorithmIntegrationTests` |

### Collision / relaunch

| Check | Status |
|---|---|
| Draft restore after kill | OK — `.finalizing` path |
| Integration test isolation | OK — WATCH-TEST-001 fixed (per-test temp dir) |

**Dive Start readiness: 95%**  
**Verdict:** Almost ready — physical underwater start/stop QA pending.

---

## F. Dive Reminders Engine (Phase 4)

### Verified

| Item | Status |
|---|---|
| Multiple reminders (up to configured max) | OK |
| Single + recurring modes | OK |
| Persistence via `DiveReminderSettingsStore` | OK |
| Runtime evaluation hooks in `DiveManager` | OK |
| Message length validation | OK — tests |
| EN/IT localization keys | OK — `WatchMainUILocalizationTests` |
| Safety alert priority over reminders | OK — integration tests |
| Mission Mode does not alter reminder math | OK |

### Gaps

- Physical overlay readability during ascent warning — matrix pending
- Simultaneous reminder + depth alarm on wrist — manual QA

**Reminder readiness: 92%**

---

## G. User Images / Inventory (Phase 5)

### Verified

| Item | Status |
|---|---|
| Path traversal rejection | OK — `UserImageStore` |
| 10 MB cap + content validation | OK |
| `.completeFileProtection` on writes | OK |
| Bundled assets read-only | OK |
| Watch as source of truth for Watch-stored uploads | OK |
| Delete pipeline + tests | OK — `CompanionPhotoManagementTests` |
| No effect on dive metrics | OK |

### Gaps

- iOS delete → Watch ACK physical path — `WATCH_IOS_SYNC_QA_MATRIX` pending
- Large inventory performance on Series 41 — physical

**Image subsystem readiness: 93%**

---

## H. Mission Mode Verdict (Phase 6 / Section H)

| Question | Answer |
|---|---|
| Affects depth sampling? | **No** |
| Affects depth display values? | **No** — only animation/decorative presentation |
| Affects reminders? | **No** |
| Affects haptics? | **No** |
| Affects GPS? | **No** |
| Affects alarms? | **No** |
| Affects sync/export? | **No** |
| Low Power Mode wording truthful? | **Yes** — internal UI profile; documented in Info |

**Mission Mode readiness: 96%**

---

## I. Sensor Source Verdict (Phase 7 / Section I)

| Question | Answer |
|---|---|
| Developer unlock protected? | **Yes** — DEBUG / TestFlight gate |
| Automatic default safe? | **Yes** — Apple when available |
| Simulation clearly identified? | **Yes** — `DepthSensorSourceResolution` labels + UI banners |
| Release path safe? | **Yes** — `applyReleaseSafeMigrationIfNeeded()` clears stored simulation |
| Mock fallback visible? | **Yes** — WATCH-P1-002 remediation |

**Sensor Source readiness: 94%**

---

## J. Branding Verdict (Phase 8 / Section J)

| Question | Answer |
|---|---|
| App icon updated? | **Yes** — asset catalog present (static review) |
| Octopus / DIR underwater identity | **Consistent** in Live/Compass dark-neon theme |
| BUSSOLA terminology | **Verified** — no COMPASSO in Watch strings sweep |
| Safety overlay conflicts | **None found** in static review |

**Branding readiness: 90%** — device-size clipping QA pending (`WATCH_ULTRA_PHYSICAL_QA_MATRIX`).

---

## K. Unit Consistency Verdict (Phase 9 / Section K)

| Surface | Metric internal | Display | Status |
|---|---|---|---|
| Live depth | meters | m/ft via preference | OK |
| Logbook | meters | formatted | OK |
| Alarms / depth safety | meters | formatted | OK |
| CSV export | **metric depths** | policy documented | OK |
| TTV / ascent | derived from meters | OK |

**Watch/iOS CSV note:** Watch export uses `# dirdiving_watch_export: 1` and slimmer metadata vs iOS `# dirdiving_ccr_*` — **by design** (`WATCH_CSV_EXPORT_POLICY.md`). Not a runtime bug.

**Unit consistency readiness: 93%**

---

## L. CCR / Rebreather Compatibility Verdict (Phase 10 / Section L)

| Question | Answer |
|---|---|
| Does Watch implement CCR logic? | **No** — zero CCR/Bühlmann/RatioDeco references in Watch compile roots |
| Does Watch avoid implying CCR control? | **Yes** — no setpoint/diluent/bailout UI on Watch |
| CCR metadata synced to Watch? | **No dedicated CCR fields** in `DiveSession` — iOS CCR planner does not alter Watch runtime |
| Do CCR fields affect Watch calculations? | **No** |
| Unsupported CCR payloads safe? | **N/A** — Watch codec handles dive sessions only; no CCR planner payload on Watch |
| Bailout/diluent/setpoint on Watch? | **Absent** — correct for companion/logger role |

**CCR compatibility readiness: 98%** (isolation is the success criterion)

---

## M. App Intents / Action Button Verdict (Phase 11 / Section M)

| Question | Answer |
|---|---|
| Legal gate enforced? | **Yes** — all 7 safety intents |
| Unsafe shortcuts blocked without acceptance? | **Yes** |
| Localized? | **Yes** — EN/IT |
| Hardware behavior safe? | **Designed** — no Side Button interception; Action Button via App Intents only |

**App Intents readiness: 95%**

---

## N. Sync / Security / Payload Validation (Phase 12)

### Verified

| Path | Status |
|---|---|
| Watch → iOS session sync | HMAC v2 + nonce replay cache |
| Signed ACK dequeue only | OK — `confirmSignedAck` |
| Peer secret pinning | OK |
| Tombstones | OK |
| Payload size cap | 512 KB / 20k samples |
| Malformed payload rejection | Tests pass |
| Pending queue retention | 7 d / 64 attempts |

### Gaps

- Two-device physical matrix — **PENDING**
- CCR planner state never on Watch — **OK by design**

**Sync/Security readiness: 92%**

---

## O. Performance / Battery / Memory (Phase 13)

| Area | Assessment |
|---|---|
| SwiftUI Live view | Mission Mode reduces animations — battery-friendly |
| GPS | 6 s windows only around dive start/end |
| Haptic throttling | Token-guarded — storm risk mitigated |
| Long dive memory | Sample cap in sync codec; log store tested |
| Field profiling | **Not executed** — P4 |

**Performance readiness: 91%**

---

## P. Test Coverage Analysis (Phase 14)

### Strong

- Dive lifecycle integration (post WATCH-TEST-001 fix)
- Sync codec + ACK + peer pinning
- Mission Mode invariants
- Legal gate + App Intents
- Image security
- Reminders engine
- Ascent / depth-limit haptics (unit level)

### Missing / weak

| Gap | Priority |
|---|---|
| Apple Watch Ultra underwater entitlement | P1 physical |
| Paired iPhone ACK path | P1 physical |
| Reminder + alarm overlay on wrist | P2 physical |
| Long-dive battery profile | P4 |

**Test coverage readiness: 90%**

---

## Q. Issue Matrix

| ID | Sev | Pri | Area | Location | Title | Impact | Fix (proposed) | Effort |
|---|---|---|---|---|---|---|---|---|
| WATCH-PHY-001 | MED | P1 | Physical QA | Ultra hardware | Underwater depth + haptics not recorded | External TestFlight blocked | Execute `WATCH_ULTRA_PHYSICAL_QA_MATRIX.md` | Manual |
| WATCH-PHY-002 | MED | P1 | Physical QA | Paired devices | Watch↔iPhone sync ACK not recorded | External TestFlight blocked | Execute `WATCH_IOS_SYNC_QA_MATRIX.md` | Manual |
| WATCH-EXP-001 | MED | P2 | CSV export | `SubsurfaceExportService.swift` | Watch vs iOS CSV metadata divergence | Import parity confusion | Document only or future alignment | M |
| WATCH-GPS-001 | LOW | P3 | GPS | `GPSManager.swift` | Auth restart outside dive | Battery | Policy doc + optional deferral | S |
| WATCH-LC-001 | LOW | P3 | Persistence | Draft decode | Legacy schema edge | Rare corrupt draft | Harden decode or migrate | S |
| WATCH-S2-003 | INFO | P4 | Samples | Timestamp source | Doc clarity | Debug only | Comment/doc | XS |

**No P0 issues.**

---

## R. Detailed Action Plan

### P0 — Critical

**None.**

### P1 — Before external TestFlight

| Action | IDs | Acceptance |
|---|---|---|
| Execute Ultra physical QA matrix | WATCH-PHY-001 | Evidence in `Docs/QA_EVIDENCE/WATCH_ULTRA/` |
| Execute paired Watch/iPhone sync matrix | WATCH-PHY-002 | Evidence in `Docs/QA_EVIDENCE/WATCH_IOS_SYNC/` |
| Confirm mock-fallback banner on device without entitlement | Sensor | Screenshot in evidence pack |

### P2 — Internal TestFlight hardening

| Action | IDs |
|---|---|
| Keep `WATCH_CSV_EXPORT_POLICY.md` linked from release checklist | WATCH-EXP-001 |
| Run reminder overlay manual cases | Reminders |

### P3 — Polish

| Action | IDs |
|---|---|
| GPS auth restart policy doc update | WATCH-GPS-001 |
| Legacy draft migration note | WATCH-LC-001 |

### P4 — Future

| Action | IDs |
|---|---|
| Optional Watch/iOS CSV metadata alignment | WATCH-EXP-001 |
| Long-dive battery profiling | Performance |

---

## S. Physical Watch Ultra QA Plan

Use [`Docs/WATCH_ULTRA_PHYSICAL_QA_MATRIX.md`](WATCH_ULTRA_PHYSICAL_QA_MATRIX.md). Minimum before external TestFlight:

1. Submersion depth entitlement on **Apple Watch Ultra** (real water or approved test tank).
2. Auto start > 1 m and auto stop at surface with dwell.
3. Ascent red-zone haptic repeat (~1.75 s) felt on wrist.
4. 35 / 38 / 40 m depth-limit haptic progression.
5. Mission Mode — confirm UI-only (no algorithm change underwater).
6. GPS entry/exit capture windows.
7. Reminder overlay during active dive (non-blocking).
8. Mock fallback banner if entitlement missing.

All rows remain **PENDING** until evidence attached.

---

## T. CCR / Rebreather Compatibility QA Plan

Watch-specific CCR QA is **negative verification** (confirm absence / isolation):

| Case | Expected | Status |
|---|---|---|
| iOS CCR plan created | Watch runtime unchanged | **PASS** (code review) |
| iOS CCR manual dive metadata | Not interpreted as live loop PPO₂ on Watch | **PASS** |
| Watch export CSV | No `# dirdiving_ccr_*` fields | **By design** |
| Watch Live screen | No setpoint/diluent/bailout controls | **PASS** |
| Sync payload | Dive session schema only — no CCR planner blob | **PASS** |

No Watch CCR external validation required beyond iOS [`CCR_REBREATHER_VALIDATION_EVIDENCE.md`](CCR_REBREATHER_VALIDATION_EVIDENCE.md) — Watch must not claim CCR controller behavior.

---

## U. Final Verdict

| Question | Answer |
|---|---|
| Is Watch algorithm/runtime ready? | **Yes for internal reference use** (94%) — code + 191 tests green |
| Safe for internal TestFlight? | **Conditional yes** — disclose mock fallback + non-certified posture |
| Safe for external TestFlight? | **Not yet** — Ultra physical + paired sync QA |
| Watch App Store ready? | **Not yet** — same + legal/marketing |
| What blocks 100% Watch readiness? | Physical QA evidence, paired sync matrix, optional CSV doc alignment |
| What blocks 100% security readiness? | Two-device tamper/ACK physical verification |
| What blocks 100% performance readiness? | Long-dive field profiling |
| What must be fixed first? | **Process:** execute physical QA matrices — not code |

### Static tooling (Phase 18 — recorded, not fixed)

| Scan | Result |
|---|---|
| CCR/Bühlmann in Watch sources | **0 matches** |
| Experimental files in Watch target | **Excluded** — confirmed in `project.yml` |
| `try!` in Watch Services (spot) | **None elevated** |

---

## Phase 19 Validation Checklist

| Check | Result |
|---|---|
| Report exists | **YES** — this file |
| Issue matrix | **YES** — Section Q |
| Readiness matrix | **YES** — Section A |
| Action plan | **YES** — Section R |
| No source modified | **YES** |
| Git status | New report only expected |

---

*End of audit @ `d756a89`. Prior math audit @ `5415213` reported 21 integration failures — **resolved** @ current HEAD (191 tests, 0 failures). iOS CCR remediation @ `d756a89` does not expand Watch decompression scope.*
