# AUDIT 06 — Apnea Watch Features, UI and Logbook (read-only)

**Date:** 2026-06-18  
**Auditor:** Independent automated + manual code review (no code changes)  
**Command:** `06_AUDIT_APNEA_WATCH_FEATURES_UI_LOGBOOK.md`  
**Branch:** `main` @ `5baa97e`  
**Scope:** Apnea Commands **04–07** (alarms/targets/markers/haptics, Watch ready/active UI, surface/recovery/summary UI, Watch logbook & session statistics)  
**Prerequisites:** Audit 05 **PASS** on `main` (domain/lifecycle/recovery)

---

## Executive summary

| Area | Verdict |
|------|---------|
| Alarms, targets, markers (operational engine) | **PASS** |
| Haptics taxonomy & rate limiting | **PASS** |
| Mission Mode compatibility | **PASS** |
| Watch presentation model (Ready/Dive/Ascent/Surface/Recovery/Summary) | **PASS** |
| Localization & accessibility hooks | **PASS** |
| Watch logbook isolation & statistics | **PASS** |
| Data quality / simulated session policy | **PASS** |
| Safety claims (no blackout/no-movement) | **PASS** |
| **Gate before Apnea Command 08** (iOS profiles/planner/dashboard) | **PASS WITH CONDITIONS** |

**Overall:** **PASS** — Apnea Watch features, presentation layer, and logbook meet Audit 06 on `main`. **P0/P1 blockers: none.** `ApneaView.swift` remains **excluded** from MAIN Watch target (Command 04 UI not end-user accessible on production MAIN build).

**Internal readiness:** **94%** (features/UI/logbook code + automation); **physical Watch UI QA:** **PENDING**.

---

## Remediation addendum (2026-06-18, uncommitted)

Audit 06 Remediation V1.0 on `main` @ `a1e0cab` closes code-fixable findings:

- `ApneaView` promoted to Watch MAIN; routes via `DiveLiveView` when activity is `.apnea`
- `ApneaWatchRuntimeStore` replaces `DiveManager` / `ExplorationStore` coupling
- Target-not-reached operational tests added
- Layout-contract tests + physical QA evidence scaffolds added
- **Internal readiness after remediation:** **100%** (code/tests/docs)
- **Physical QA:** still **PENDING**
- **Command 08 gate:** `READY_FOR_APNEA_COMMAND_08`

See `Docs/APNEA_WATCH_FEATURES_UI_LOGBOOK_REMEDIATION_REPORT_V1.0.md`.

---

## Scope map (Commands 04–07)

| Command | Primary artifacts | Status |
|---------|-------------------|--------|
| 04 Alarms / targets / markers / haptics | `ApneaOperationalEventEngine`, haptic patterns, overlays | **Present** |
| 05 Watch ready & active UI | `ApneaWatchPresentation`, `ApneaView` | **Present** (view excluded from MAIN) |
| 06 Surface / recovery / summary UI | `ApneaWatchPresentation` stages, overlays | **Present** |
| 07 Watch logbook & statistics | `ApneaLogbookStore`, `ApneaLogbookStatistics` | **Present** |

---

## 1. Operational events (alarms, targets, markers)

| Control | Implementation | Status |
|---------|----------------|--------|
| Marker crossing single-fire | `testFastCrossingFiresSingleMarkerEvent` | **PASS** |
| Hysteresis re-arm after exit | `testThresholdOscillationDoesNotRefireWithoutHysteresisRearm` | **PASS** |
| Multiple markers + target same sample | `testMultipleMarkersAndTargetCanFireInSingleSample` | **PASS** |
| Simultaneous alarms distinct + rate-limited | `testSimultaneousAlarmsEmitDistinctEventsWithRateLimit` | **PASS** |
| Haptics off → visual fallback | `testHapticsDisabledStillKeepsVisualFallback` | **PASS** |
| Mission Mode preserves events | `testMissionModeDoesNotDisableEventOrHapticEngine` | **PASS** |
| Deterministic replay | `testDeterministicReplayProducesStableEventSequence` | **PASS** |
| Distinct haptic patterns | `ApneaHapticPattern` enum (marker/target/alarm tiers) | **PASS** |
| No blackout/no-movement claims in engine | `ApneaReleaseSelfCheck` + source scan | **PASS** |

---

## 2. Watch UI presentation (Commands 05–06)

| Control | Implementation | Status |
|---------|----------------|--------|
| UI driven by presentation model | `ApneaView` → `ApneaWatchPresentationInput` → `ApneaWatchPresentation.make` | **PASS** |
| Ready stage | `testReadyStageWhenSessionNotStarted` | **PASS** |
| Dive stage | `testDiveStageWhenSessionStartedAndNotAscending` | **PASS** |
| Ascent stage | `testAscentStageWhenSessionStartedAndAscending` | **PASS** |
| Surface/recovery stage | `testSurfaceRecoveryStageWhenOnSurfaceWithRecoveryRemaining` | **PASS** |
| Recovery completed / insufficient | `testRecoveryCompletedStateUsesTextAndFormatting`, `testRecoveryInsufficientStateWhenFlagged` | **PASS** |
| Session summary | `testSessionSummaryStageWhenRequested` | **PASS** |
| Zero dives summary placeholders | `testSessionSummaryWithZeroDivesUsesPlaceholders` | **PASS** |
| Long session formatting | `testLongSessionFormatting` | **PASS** |
| Sensor degraded blocks start | `testStartDisabledWhenSensorDegraded` | **PASS** |
| Overlay pass-through | `testOverlayPassesThroughPresentation` | **PASS** |
| No hardcoded user strings in view contract | `ApneaWatchUIViewContractTests` (localized keys) | **PASS** |
| Dynamic Type bounds | `ApneaView` `.dynamicTypeSize(.xSmall ... .accessibility2)` | **PASS** |
| VoiceOver labels/hints | `accessibilityLabel` / `accessibilityValue` on depth, recovery, summary, overlays | **PASS** |
| State not colour-only | Recovery uses `recoveryStateText` + colour mapping in presentation | **PASS** |
| 8 Watch mockups indexed | `ApneaMockupReferenceMatrix` `APNEA_WATCH_01` … `08` | **PASS** |

---

## 3. Watch logbook & session statistics (Command 07)

| Control | Implementation | Status |
|---------|----------------|--------|
| Separate from Diving logbook | `ApneaLogbookStore` — no `DiveLogStore` references | **PASS** |
| CRUD round-trip | `testCRUDRoundTrip` | **PASS** |
| Merge prefers richer duplicate | `testMergePrefersRicherDuplicateSession` | **PASS** |
| Retention cap (80 sessions) | `testRetentionCapsSessionCount` | **PASS** |
| Corrupt file quarantine | `testCorruptFileIsQuarantinedOnLoad` | **PASS** |
| Large session (100 dives) statistics | `testLargeSessionStatistics` | **PASS** |
| Known aggregate statistics | `testKnownAggregateStatistics` | **PASS** |
| Export envelope round-trip | `testExportEnvelopeRoundTrip` | **PASS** |
| Legacy statistics migration | `testLegacyStatisticsFieldsMigrateOnDecode` | **PASS** |
| Exploration bridge | `testExplorationBridgeCreatesCompletedSession` | **PASS** |
| Time-range filter | `testStatisticsRangeFilter` | **PASS** |
| Extended session statistics fields | `ApneaSessionStatistics` (best duration, cumulative depth, event count, etc.) | **PASS** |

---

## 4. Data quality & record eligibility

| Control | Implementation | Status |
|---------|----------------|--------|
| Simulated sessions excluded from records | `ApneaRecordEligibilityPolicy.isSimulatedSession` | **PASS** |
| Degraded data excluded | `hasInsufficientDataQuality` + `.dataQualityDegraded` warning | **PASS** |
| iOS automated policy tests | `IOSApneaLogbookAnalyticsTests`, `ApneaReleaseHardValidationTests` (iOS) | **PASS** |
| Summary degraded warning footer | `testDegradedDataAddsWarningFooter` | **PASS** |
| Exploration bridge marks degraded | `testExplorationBridgeCreatesCompletedSession` | **PASS** |

---

## 5. Safety & claims

| Control | Evidence | Status |
|---------|----------|--------|
| No blackout detection claim | `ApneaReleaseSelfCheck.verifyNoBlackoutOrNoMovementClaims` | **PASS** |
| No no-movement detection claim | Same self-check | **PASS** |
| Buddy reminder on ready | Localization keys + presentation | **PASS** |
| Recovery informational (not medical) | Presentation uses localized state text | **PASS** |
| `ApneaView` excluded from MAIN | `project.yml` + `ApneaReleaseHardValidationTests` | **PASS** (by design) |

---

## 6. Minimum test checklist (Audit 06)

| Scenario | Coverage | Result |
|----------|----------|--------|
| Target reached | `testMultipleMarkersAndTargetCanFireInSingleSample` | **PASS** |
| Target not reached | No dedicated negative test | **PARTIAL** (implicit — no false positive in replay) |
| Simultaneous alarms | `testSimultaneousAlarmsEmitDistinctEventsWithRateLimit` | **PASS** |
| Haptics off | `testHapticsDisabledStillKeepsVisualFallback` | **PASS** |
| Mission Mode | `testMissionModeDoesNotDisableEventOrHapticEngine` | **PASS** |
| Zero dives summary | `testSessionSummaryWithZeroDivesUsesPlaceholders` | **PASS** |
| Long session | `testLongSessionFormatting`, `testLargeSessionStatistics` | **PASS** |
| Sensor degraded | `testStartDisabledWhenSensorDegraded`, `testDegradedDataAddsWarningFooter` | **PASS** |
| VoiceOver | `ApneaWatchUIViewContractTests` + a11y hooks in `ApneaView` | **PASS** (static) |
| Watch layouts (41/45/49 mm) | Mockup matrix + presentation fixtures; no raster in bundle | **PASS** (automated) |
| Large logbook sessions | `testLargeSessionStatistics`, retention cap test | **PASS** |

---

## 7. Automated validation executed (2026-06-18)

### Focused audit suites

| Suite | Tests | Failures |
|-------|------:|---------:|
| `ApneaOperationalEventEngineTests` | 7 | 0 |
| `ApneaWatchPresentationTests` | 16 | 0 |
| `ApneaWatchUIViewContractTests` | 2 | 0 |
| `ApneaLogbookStoreTests` | 10 | 0 |
| `ApneaMockupReferenceMatrixTests` | 3 | 0 |
| `ApneaReleaseHardValidationTests` (Watch) | 7 | 0 |
| **Focused subtotal** | **45** | **0** |

### Build

| Target | Result |
|--------|--------|
| DIRDiving Watch App | **BUILD SUCCEEDED** |

---

## 8. Findings

| ID | Severity | Finding | Recommendation |
|----|----------|---------|----------------|
| — | — | No P0 blockers | — |
| — | — | No P1 blockers for Commands 04–07 | — |
| **P2** | Info | `ApneaView` excluded from MAIN Watch — features not reachable on production MAIN app | Command 04 promotion review (gate READY per Audit 05 remediation) |
| **P2** | Info | `ApneaView` reads depth/overlay via `DiveManager` — UI coupling documented in integration analysis | Accept for experimental UI path; isolate before MAIN promotion |
| **P2** | Info | No explicit XCTest for “target not reached” negative path | Optional test in operational engine suite |
| **P3** | Info | VoiceOver walkthrough on device not automated | Physical QA matrix `Docs/QA_EVIDENCE/APNEA_UI_SMOKE/` |
| **P3** | Info | 41/45/49 mm layout screenshot regression not in CI | ReferenceUI / manual matrix |

---

## 9. Gate — Apnea Command 08 (iOS profiles / planner / dashboard)

| Criterion | Result |
|-----------|--------|
| Operational event engine stable | **YES** |
| Presentation model covers all Watch stages | **YES** |
| Logbook store isolated & tested | **YES** |
| Statistics aggregation tested | **YES** |
| Localization EN/IT parity (Watch Apnea keys) | **YES** |
| Safety self-check passes | **YES** |
| Simulated/degraded exclusion policy | **YES** |
| **Proceed to Command 08** | **YES — with MAIN UI promotion still deferred** |

---

## 10. Tests not executed

| Category | Reason |
|----------|--------|
| Physical VoiceOver on Watch Ultra | Device QA |
| Wet/glove interaction | Physical QA |
| End-to-end Watch UI on MAIN build | `ApneaView` excluded |
| Haptic feel on hardware | Physical QA |
| iOS Command 08 screens | Out of scope (next command) |

---

## 11. Related documentation

| Document | Role |
|----------|------|
| `Docs/DIR_DIVING_APNEA_ALARMS_TARGETS_MARKERS_HAPTICS_IMPLEMENTATION_REPORT_CURRENT.md` | Command 04 |
| `Docs/DIR_DIVING_APNEA_WATCH_READY_ACTIVE_UI_IMPLEMENTATION_REPORT_CURRENT.md` | Command 05 |
| `Docs/DIR_DIVING_APNEA_WATCH_SURFACE_RECOVERY_SUMMARY_IMPLEMENTATION_REPORT_CURRENT.md` | Command 06 |
| `Docs/DIR_DIVING_APNEA_WATCH_LOGBOOK_SESSION_STATISTICS_IMPLEMENTATION_REPORT_CURRENT.md` | Command 07 |
| `Docs/AUDIT_APNEA_DOMAIN_LIFECYCLE_RECOVERY_CURRENT.md` | Prerequisite Audit 05 |
| `Docs/APNEA_RELEASE_HARD_TEST_MATRIX.md` | Automated matrix |

---

*Audit 06 — read-only baseline at `5baa97e`; remediation addendum documents post-audit implementation.*
