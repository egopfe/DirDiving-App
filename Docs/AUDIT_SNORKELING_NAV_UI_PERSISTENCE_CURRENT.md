# AUDIT 10 — Snorkeling Navigation, UI and Persistence (read-only)

**Date:** 2026-06-18  
**Auditor:** Independent automated + manual code review  
**Command:** `10_AUDIT_SNORKELING_NAV_UI_PERSISTENCE.md`  
**Branch:** `main` (uncommitted worktree; baseline `f5d9112`)  
**Scope:** Snorkeling Commands **04–07** — navigation/return engine, alarms/markers/haptics/Mission Mode, Watch UI all states, persistence/recovery, Watch logbook  
**Prerequisites:** Commands 01–03 audited PASS ([`AUDIT_SNORKELING_DOMAIN_INGESTION_LIFECYCLE_CURRENT.md`](AUDIT_SNORKELING_DOMAIN_INGESTION_LIFECYCLE_CURRENT.md)); `ExplorationStore` excluded from Watch MAIN

---

## Executive summary

| Area | Verdict |
|------|---------|
| Command 04 — Navigation / return engine | **PASS** |
| Command 05 — Alarms / markers / haptics / Mission Mode | **PASS** |
| Command 06 — Watch UI all states + MAIN promotion | **PASS** |
| Command 07 — Persistence / recovery / logbook | **PASS WITH CONDITIONS** |
| Localization EN/IT (shipped UI keys) | **FAIL** |
| Accessibility / VoiceOver hooks | **PARTIAL** |
| **Gate before Snorkeling Command 08** | **PASS WITH CONDITIONS** |

**Overall:** **PASS WITH CONDITIONS** — engine, presentation, checkpoint recovery, and Watch MAIN promotion are implemented with strong automated coverage. **Primary blocker for a clean gate:** eleven localization keys referenced by the return advisor and operational overlays are absent from `Localizable.strings` (EN/IT), so Watch may show raw key strings at runtime. Secondary gaps: no dedicated `SnorkelingLogbookStoreTests`, no release self-check script (Apnea/FC parity), no physical VoiceOver QA.

**Internal readiness (Commands 04–07):** **~95%** (localization remediation closes gap)  
**Physical device / Water Lock / wet-glove / haptic feel:** **not in scope** (documented PENDING)

---

## Scope map (Commands 04–07)

| Command | Primary artifacts | Status |
|---------|-------------------|--------|
| 04 Navigation / return | `SnorkelingNavigationEngine`, `SnorkelingReturnAdvisor`, `SnorkelingNavigationModels` | **Present** |
| 05 Alarms / markers / haptics | `SnorkelingOperationalEventEngine`, `SnorkelingMarkerCaptureEngine`, Mission Mode profile | **Present** |
| 06 Watch UI | `SnorkelingWatchPresentation`, `SnorkelingWatchRuntimeStore`, `SnorkelingView` | **Present** |
| 07 Persistence / logbook | `SnorkelingSessionCheckpointPersistence`, `SnorkelingLogbookStore` | **Present** |

Implementation reports: [`DIR_DIVING_SNORKELING_NAVIGATION_RETURN_ENGINE_IMPLEMENTATION_REPORT_CURRENT.md`](DIR_DIVING_SNORKELING_NAVIGATION_RETURN_ENGINE_IMPLEMENTATION_REPORT_CURRENT.md), [`DIR_DIVING_SNORKELING_ALARMS_MARKERS_HAPTICS_MISSION_MODE_IMPLEMENTATION_REPORT_CURRENT.md`](DIR_DIVING_SNORKELING_ALARMS_MARKERS_HAPTICS_MISSION_MODE_IMPLEMENTATION_REPORT_CURRENT.md), [`DIR_DIVING_SNORKELING_WATCH_UI_ALL_STATES_IMPLEMENTATION_REPORT_CURRENT.md`](DIR_DIVING_SNORKELING_WATCH_UI_ALL_STATES_IMPLEMENTATION_REPORT_CURRENT.md), [`DIR_DIVING_SNORKELING_PERSISTENCE_RECOVERY_LOGBOOK_IMPLEMENTATION_REPORT_CURRENT.md`](DIR_DIVING_SNORKELING_PERSISTENCE_RECOVERY_LOGBOOK_IMPLEMENTATION_REPORT_CURRENT.md).

Contracts: [`SNORKELING_NAVIGATION_RETURN_ENGINE_CONTRACT.md`](SNORKELING_NAVIGATION_RETURN_ENGINE_CONTRACT.md), [`SNORKELING_PERSISTENCE_RECOVERY_CONTRACT.md`](SNORKELING_PERSISTENCE_RECOVERY_CONTRACT.md).

---

## 1. Navigation / return (Command 04)

| Control | Implementation | Status |
|---------|----------------|--------|
| Waypoint navigation + geodetic bearing | `SnorkelingNavigationEngine` | **PASS** |
| Turn guidance (left / right / on-line / unavailable) | `turnInstruction`, `permitsPreciseTurnGuidance` | **PASS** |
| No-fix disables precise guidance | Stale/no-fix → `.unavailable` turn | **PASS** |
| Stale heading disables precise turns | `testStaleHeadingDisablesPreciseTurnGuidance` | **PASS** |
| Dateline / bearing wrap | `testBearingAcrossDateline`, `testBearingWrapAndSignedDelta` | **PASS** |
| Route reorder deterministic | `testRouteReorderIsDeterministic` | **PASS** |
| Auto-switch next waypoint | `autoAdvanceToNextWaypoint` | **PASS** |
| Return-to-entry advisor (non-prescriptive) | `SnorkelingReturnAdvisor` — informational keys only | **PASS** (engine) / **FAIL** (UI strings missing) |
| Return distance / duration / battery thresholds | `testReturnDistanceThresholdActivatesAdvisor`, duration/battery tests | **PASS** |
| Entry point persistent with GPS quality | `SnorkelingEntryPoint.gpsQuality`, checkpoint round-trip | **PASS** |
| Underwater GPS not used for measured reach | `testUnderwaterGPSDoesNotProduceMeasuredWaypointReach` | **PASS** |
| Checkpoint preserves navigation runtime | `navigationRuntimeState` in envelope | **PASS** |

---

## 2. Alarms / markers / haptics / Mission Mode (Command 05)

| Control | Implementation | Status |
|---------|----------------|--------|
| Depth / duration / distance alarms + hysteresis | `SnorkelingOperationalEventEngine` | **PASS** |
| Simultaneous alarms + rate limit | Distinct events, rate-limited haptics | **PASS** |
| Marker position quality | `SnorkelingMarkerPositionQuality` (measured/degraded/unavailable/noFix) | **PASS** |
| Marker save without coordinates (explicit policy) | `allowSaveWithoutCoordinates` | **PASS** |
| Haptics off → visual overlay fallback | `testHapticsDisabledStillProvidesVisualFallback` | **PASS** |
| Mission Mode preserves alarms / sensors / persistence | `testMissionModeDoesNotDisableAlarmsOrHaptics` | **PASS** |
| Mission Mode reduces presentation refresh only | `SnorkelingMissionModePresentationProfile` | **PASS** |
| Deterministic operational replay | `testDeterministicOperationalReplay` | **PASS** |

---

## 3. Watch UI (Command 06)

| Control | Implementation | Status |
|---------|----------------|--------|
| Approved stages (ready / surface / dip / nav / return / marker / summary) | `SnorkelingWatchPresentation` + `SnorkelingView` | **PASS** |
| No `ExplorationStore` / `DiveManager` in snorkeling views | `SnorkelingWatchMainPromotionTests` | **PASS** |
| `SnorkelingView` on Watch MAIN | `project.yml` + `DIRActivityMode.snorkeling.isLaunchableOnWatchMAIN` | **PASS** |
| No live underwater GPS coordinates in UI | `showsLiveGPSCoordinates: !isUnderwater && tracking` | **PASS** |
| Underwater GPS informational overlay | `testUnderwaterGPSLabelIsInformational` | **PASS** |
| Sensor degraded as overlay (not separate stage) | Presentation overlay enum | **PASS** |
| Layout contract fixtures | `SnorkelingWatchLayoutContractTests` (5) | **PASS** |
| VoiceOver labels on hero / turn / GPS | `snorkeling.a11y.*` keys + `SnorkelingView` labels | **PARTIAL** |
| Recovered-session banner | `isRecoveredSession` + `snorkeling.recovery.*` | **PARTIAL** (no dedicated presentation test) |

---

## 4. Persistence / recovery / logbook (Command 07)

| Control | Implementation | Status |
|---------|----------------|--------|
| SHA-256 envelope + checksum validation | `SnorkelingSessionCheckpointIntegrity` | **PASS** |
| Atomic write + previous-checkpoint retention | `SnorkelingSessionCheckpointStore` | **PASS** |
| Corruption quarantine (no silent reset) | `Diagnostics/SnorkelingQuarantine/` | **PASS** |
| Recovery preserves route / entry / active dip | Crash-during-dip/nav/marker/return tests | **PASS** |
| Relaunch restore in runtime store | `SnorkelingWatchRuntimeStore.restoreCheckpointIfPresent` | **PASS** |
| Recovered-session UI banner | `recoveredSessionBannerText` | **PARTIAL** |
| Dedicated logbook store (80-session cap) | `SnorkelingLogbookStore` + policy | **PASS** |
| Logbook save from session summary | `saveCompletedSession(to:)` | **PASS** |
| Logbook CRUD / export / statistics suite | Apnea parity | **PARTIAL** — no `SnorkelingLogbookStoreTests` |
| Sample compression documented | Policy caps raw audit trails (2048/feed) | **PASS** (documented in reports) |

---

## 5. Isolation

| Boundary | Evidence | Status |
|----------|----------|--------|
| No Dive/Apnea/FC/Exploration coupling in snorkeling runtime | `SnorkelingArchitectureIsolation` + cross-domain tests | **PASS** |
| `ExplorationStore` excluded Watch MAIN | `check_main_target_isolation.sh` | **PASS** |
| Checkpoint namespace isolated | `dirdiving_snorkeling_session` | **PASS** |
| Logbook namespace isolated | `dirdiving_snorkeling_sessions` | **PASS** |

---

## 6. Minimum test checklist (Audit 10)

| Scenario | Test / evidence | Result |
|----------|-------------------|--------|
| Dateline / wrap bearing | `SnorkelingNavigationReturnEngineTests` | **PASS** |
| No-fix disables precise guidance | `testNoFixProducesUnavailableTurnGuidance` | **PASS** |
| Stale fix / stale heading | GPS stale + return degraded tests | **PASS** |
| Route reorder | `testRouteReorderIsDeterministic` | **PASS** |
| Auto-switch waypoint | `testAutoSwitchAdvancesToNextWaypoint` | **PASS** |
| Return threshold | distance / duration / battery tests | **PASS** |
| Crash during dip / nav / marker / return | `SnorkelingPersistenceRecoveryTests` | **PASS** |
| Mission Mode | `SnorkelingAlarmsMarkersHapticsMissionModeTests` | **PASS** |
| Layout + VoiceOver hooks | Layout contract + `testAccessibilityStringsPresentForNavigation` | **PARTIAL** |
| Checkpoint round-trip (foundation) | `SnorkelingCheckpointFoundationTests` | **PASS** |

---

## 7. Automated validation executed (2026-06-18)

**Target:** `DIRDiving Watch Algorithm Tests` — Apple Watch Series 11 (46mm) Simulator  
**Build:** `DIRDiving Watch App` — **BUILD SUCCEEDED**

### Commands 04–07 focused suites

| Suite | Tests | Failures |
|-------|------:|---------:|
| `SnorkelingNavigationReturnEngineTests` | 18 | 0 |
| `SnorkelingCommand04FoundationGateTests` | 5 | 0 |
| `SnorkelingAlarmsMarkersHapticsMissionModeTests` | 12 | 0 |
| `SnorkelingWatchPresentationTests` | 15 | 0 |
| `SnorkelingWatchLayoutContractTests` | 5 | 0 |
| `SnorkelingWatchMainPromotionTests` | 8 | 0 |
| `SnorkelingPersistenceRecoveryTests` | 11 | 0 |
| `SnorkelingWatchRuntimeStorePersistenceTests` | 2 | 0 |
| **Commands 04–07 subtotal** | **76** | **0** |

### Full Snorkeling focused suite (incl. 01–03 support + isolation)

| Metric | Value |
|--------|------:|
| Snorkeling `func test*` methods (static count) | 152 |
| Executed (full focused run, 2026-06-18) | 150 |
| Failures | 0 |

Isolation script: `Scripts/check_main_target_isolation.sh` — **PASS**

---

## 8. Findings & recommendations

| ID | Sev | Finding | Recommendation |
|----|-----|---------|----------------|
| AUDIT10-SNK-001 | **P1** | Eleven EN/IT keys missing: `snorkeling.return.advisor.*`, `snorkeling.return.gps.*`, `snorkeling.return.heading.stale`, `snorkeling.return.near.entry`, `snorkeling.alarm.title`, `snorkeling.gps.lost` | Add strings before production; add localization parity test |
| AUDIT10-SNK-002 | **P2** | No `SnorkelingLogbookStoreTests` (Apnea has dedicated suite) | Add CRUD/export/statistics tests in Command 08 prep |
| AUDIT10-SNK-003 | **P2** | No `SnorkelingReleaseSelfCheck` / validate script | Optional hardening before App Store |
| AUDIT10-SNK-004 | **P3** | No recovered-session banner presentation test | Add fixture in `SnorkelingWatchPresentationTests` |
| AUDIT10-SNK-005 | **P3** | Physical VoiceOver / wet-glove / haptic QA not automated | Document in QA evidence matrix |
| AUDIT10-SNK-006 | **Info** | `SnorkelingWatchMainIsolationTests` retired → `SnorkelingWatchMainPromotionTests` | Expected; promotion model changed in Command 06 |

**P0:** none.

---

## 9. Gate decision — Snorkeling Command 08

```
SNORKELING_NAV_UI_PERSISTENCE_INTERNAL_GO
READY_FOR_SNORKELING_COMMAND_08_WITH_CONDITIONS
```

| Criterion | Result |
|-----------|--------|
| Navigation/return engine stable + tested | **YES** |
| Operational events + Mission Mode stable | **YES** |
| Watch UI all approved states on MAIN | **YES** |
| Checkpoint recovery without silent reset | **YES** |
| Logbook isolated + basic persistence tested | **YES** (thin vs Apnea) |
| EN/IT localization complete for shipped UI keys | **NO** — close AUDIT10-SNK-001 first |
| Release self-check parity | **NO** |
| Physical Watch QA | **PENDING** |
| **Proceed to Command 08** | **YES WITH CONDITIONS** |

| Audience | Decision |
|----------|----------|
| **Proceed to Command 08** | **YES** — engine/UI/persistence ready; localization remediation recommended in parallel |
| **Production App Store release** | **NO-GO** |
| **Clean gate (no conditions)** | **NO** — until AUDIT10-SNK-001 closed |

---

## 10. Tests not executed

| Category | Reason |
|----------|--------|
| Physical VoiceOver on Watch hardware | Device QA |
| Wet-glove / crown interaction | Physical QA |
| Haptic feel on hardware | Physical QA |
| iOS companion snorkeling (Command 08 scope) | Out of scope |
| End-to-end cloud sync for snorkeling logbook | Out of scope (Command 07 local only) |

---

## 11. Related documentation

| Document | Role |
|----------|------|
| [`AUDIT_SNORKELING_DOMAIN_INGESTION_LIFECYCLE_CURRENT.md`](AUDIT_SNORKELING_DOMAIN_INGESTION_LIFECYCLE_CURRENT.md) | Audit 09 — Commands 01–03 |
| [`DIR_DIVING_SNORKELING_NAVIGATION_RETURN_ENGINE_IMPLEMENTATION_REPORT_CURRENT.md`](DIR_DIVING_SNORKELING_NAVIGATION_RETURN_ENGINE_IMPLEMENTATION_REPORT_CURRENT.md) | Command 04 |
| [`DIR_DIVING_SNORKELING_ALARMS_MARKERS_HAPTICS_MISSION_MODE_IMPLEMENTATION_REPORT_CURRENT.md`](DIR_DIVING_SNORKELING_ALARMS_MARKERS_HAPTICS_MISSION_MODE_IMPLEMENTATION_REPORT_CURRENT.md) | Command 05 |
| [`DIR_DIVING_SNORKELING_WATCH_UI_ALL_STATES_IMPLEMENTATION_REPORT_CURRENT.md`](DIR_DIVING_SNORKELING_WATCH_UI_ALL_STATES_IMPLEMENTATION_REPORT_CURRENT.md) | Command 06 |
| [`DIR_DIVING_SNORKELING_PERSISTENCE_RECOVERY_LOGBOOK_IMPLEMENTATION_REPORT_CURRENT.md`](DIR_DIVING_SNORKELING_PERSISTENCE_RECOVERY_LOGBOOK_IMPLEMENTATION_REPORT_CURRENT.md) | Command 07 |
| [`SNORKELING_NAVIGATION_RETURN_ENGINE_CONTRACT.md`](SNORKELING_NAVIGATION_RETURN_ENGINE_CONTRACT.md) | Navigation contract |
| [`SNORKELING_PERSISTENCE_RECOVERY_CONTRACT.md`](SNORKELING_PERSISTENCE_RECOVERY_CONTRACT.md) | Persistence contract |
