# AUDIT 13 — Audit integrato Diving / Apnea / Snorkeling

**Date:** 2026-06-19  
**Auditor:** Independent automated + manual code/doc review (no application code modified during this audit)  
**Command:** `13_AUDIT_INTEGRATO_TRE_MODALITA.md`  
**Branch:** `main`  
**Baseline:** `9794ce5` (post Audit 12 Snorkeling release-gate remediation)  
**Scope:** Read-only integrated coexistence audit — Gauge, Full Computer, Apnea, Snorkeling on Watch MAIN + iOS Companion.

**Prerequisites:** Per-activity release gates Audits 04 (FC), 08 (Apnea), 12 (Snorkeling); Commands 04–12 merged on `main`.

---

## Executive summary

| Dimension | Readiness | Verdict |
|-----------|----------:|---------|
| **Cross-domain architecture** | **98%** | Namespaces, runtime isolation, activity guards verified |
| **Modalità e navigazione** | **97%** | Single-session policy; Watch + iOS routing coherent |
| **Automated release-hard (per activity)** | **95%** | FC + Snorkeling PASS; Apnea script blocked by 1 stale iOS test |
| **Physical / device evidence (all activities)** | **0%** | Apnea 19 + Snorkeling 21 QA folders **PENDING**; Diving matrices unsigned |
| **Integrated external release** | **0%** | **NO-GO** until per-activity physical QA + integrated field matrix |

### Release decision

```
GO WITH CONDITIONS
```

| Audience | Decision |
|----------|----------|
| **Internal integrated development** | **GO WITH CONDITIONS** |
| **Integrated TestFlight / App Store** | **NO-GO** |

### Conditions before integrated external GO

1. Fix stale `IOSApneaCompanionTests.testApneaSelectionAvailableAfterCommand08` (expects Snorkeling unavailable on iOS; product + `IOSCompanionActivitySelectionTests` disagree).
2. Execute and sign physical QA for **each** activity (`Docs/QA_EVIDENCE/APNEA_*`, `SNORKELING_*`, Diving/FC matrices).
3. Run integrated field matrix: sequential Gauge → FC → Apnea → Snorkeling without state bleed (manual; no fabricated evidence).
4. Add or refresh integrated release script chaining per-activity validators (optional tooling debt).

---

## Readiness matrix per modalità

| Modalità | Code / arch | Automated gate | Documentation | Physical QA | Cross-domain isolation |
|----------|------------:|---------------:|--------------:|------------:|------------------------|
| **Diving Gauge** | **98%** | Partial (MAIN readiness; no dedicated Gauge-only gate) | **95%** | **0%** PENDING | **PASS** — baseline unchanged |
| **Diving Full Computer** | **96%** | **PASS** `validate_full_computer_release_readiness.sh` | **98%** | **0%** PENDING | **PASS** — `FullComputerWatchArchitectureGuardTests` (7) |
| **Apnea** | **98%** | **FAIL** `validate_apnea_release_readiness.sh` (1 stale iOS test) | **95%** | **0%** (19 folders PENDING) | **PASS** — `ApneaArchitectureIsolationTests` (6) |
| **Snorkeling** | **100%** | **PASS** `validate_snorkeling_release_readiness.sh --internal` | **100%** | **0%** (21 folders PENDING) | **PASS** — `SnorkelingCrossDomainIsolationTests` (6) |

---

## Audit evidence (2026-06-19)

| Check | Result |
|-------|--------|
| `./Scripts/check_main_target_isolation.sh` | **PASS** |
| `./Scripts/check_secrets.sh` | **PASS** |
| `./Scripts/audit_localization.sh` | **PASS** (Watch EN=1195 IT=1195; iOS EN=2512 IT=2512) |
| `validate_full_computer_release_readiness.sh` | **PASS** |
| `validate_snorkeling_release_readiness.sh --internal` | **PASS** (Watch 212 + iOS 89 tests, 0 failures) |
| `validate_apnea_release_readiness.sh --internal` | **FAIL** — `IOSApneaCompanionTests.testApneaSelectionAvailableAfterCommand08` |
| Cross-domain Watch batch (51 tests) | **PASS** — Apnea/Snorkeling/FC architecture + startup |
| `ApneaSuspendResumeLifecycleIntegrationTests` | **PASS** (26 tests) — prior Audit 08 failure not reproduced |
| `IOSCompanionActivitySelectionTests` | **PASS** (16 tests) — Apnea + Snorkeling both available on iOS |
| `IOSSnorkelingCompanionTests` | **PASS** (5 tests, excluding stale sibling in Apnea suite) |

---

## Aree trasversali

### Modalità e navigazione

| Rule | Implementation | Status |
|------|----------------|--------|
| Activity selection at launch | `DIRStartupSelectionPolicy`, `DIRActivitySelectionStore`, iOS `CompanionActivityPreferenceStore` | **PASS** |
| Diving → mode selection (Gauge / FC) | `DIRModesAndStartupFlowTests` | **PASS** |
| Apnea / Snorkeling → `.ready` on Watch MAIN | `ApneaWatchMainPromotionTests`, `SnorkelingWatchMainPromotionTests` | **PASS** |
| Block mode change during active session | `DIRActivitySelectionStore.canChangeModes` checks Dive, Apnea, Snorkeling | **PASS** |
| Single active session policy | `ContentView` gates crown hint; sync flags `isApneaSessionInProgress` / `isSnorkelingSessionInProgress` | **PASS** |
| iOS companion activity availability | `CompanionActivityAvailability` → `isLaunchableOnIOSCompanionMAIN` for all three | **PASS** (product); **stale test** in `IOSApneaCompanionTests` |

### Sensori

| Rule | Evidence | Status |
|------|----------|--------|
| Shared depth feed, namespaced configs | `DepthMeasurementFeedConfiguration.apneaDefault` vs `.snorkelingDefault` (max depth 25 m snorkel) | **PASS** |
| No cross-runtime engine imports | Architecture isolation tests | **PASS** |
| Sensor degraded / fail-closed ready | `SnorkelingReleaseHardValidationTests`, Apnea lifecycle tests | **PASS** |
| Mock/simulation isolation | Experimental exclusions in `project.yml`; `check_main_target_isolation.sh` | **PASS** |

### Persistenza

| Domain | Checkpoint / store namespace | Collision check |
|--------|---------------------------|-----------------|
| Gauge / dive | `dirdiving_dive_session` | Isolated |
| Full Computer plan | `fullComputerPlanPackage`, `dirdiving_fc_plan_*` | Isolated from Apnea/Snorkeling |
| Apnea checkpoint | Apnea checkpoint files + `dirdiving_apnea_sessions` | **PASS** |
| Apnea sync | `dirdiving_apnea_session` | **PASS** |
| Snorkeling checkpoint | `dirdiving_snorkeling_session` | **PASS** |
| Snorkeling sync | `dirdiving_snorkeling_session_sync` | **PASS** ≠ checkpoint |
| Snorkeling logbook | `dirdiving_snorkeling_sessions` | **PASS** |
| Snorkeling route | `dirdiving_snorkeling_route_*` | **PASS** |

Verified by `SnorkelingCrossDomainIsolationTests`, `ApneaReleaseSelfCheck`, `SnorkelingReleaseSelfCheck`.

### WatchConnectivity

| Channel | Key / type | Isolation |
|---------|-----------|-----------|
| Dive session | `dirdiving_dive_session` | Diving only |
| Apnea plan | `apneaSyncPlanPackage` | Apnea only |
| Apnea session | `dirdiving_apnea_session` | Apnea only |
| FC plan | `fullComputerPlanPackage` | FC only |
| Snorkeling route | `snorkelingRoutePackage` | Snorkeling only |
| Snorkeling session | `dirdiving_snorkeling_session_sync` | Snorkeling only |

`WatchSyncService` maintains **separate pending queues** (`pendingTransfers`, `pendingApneaTransfers`, `pendingSnorkelingTransfers`) with independent persistence files. Replay caches bootstrapped per codec. **PASS** — no shared payload keys observed.

### UI / design system / localization

| Check | Result |
|-------|--------|
| Shared `DiveUI` / `DIRTheme` patterns | **PASS** — per-activity views use common tokens |
| EN/IT parity | **PASS** — `audit_localization.sh` |
| Accessibility hooks | Snorkeling a11y identifiers + procedures; Apnea/FC matrices PENDING device |
| Mission Mode | Snorkeling + dive paths respect `MissionModeSettings`; no cross-activity settings bleed |

### Logbook

| Activity | Watch store | iOS store | Cross-query |
|----------|-------------|-----------|-------------|
| Diving | `DiveLogStore` | `DiveLogStore` (iOS) | None |
| Apnea | `ApneaLogbookStore` | `IOSApneaLogbookStore` | None |
| Snorkeling | `SnorkelingLogbookStore` | `IOSSnorkelingLogbookStore` | None |

**PASS** — strict section ownership preserved in architecture docs and isolation tests.

---

## Test end-to-end minimi (policy)

The audit command lists eight sequential E2E scenarios. **None are automated as a single integrated script** on `main`. Coverage is **decomposed**:

| # | Scenario | Automated partial coverage | Physical |
|---|----------|---------------------------|----------|
| 1 | Gauge start/end/sync | Dive sync codec tests, `WatchDiveSyncCodec` | **PENDING** |
| 2 | FC simulated profile + recovery | FC release-hard, checkpoint tests | **PENDING** |
| 3 | Apnea multi-dive | Apnea lifecycle + suspend/resume integration | **PENDING** |
| 4 | Snorkeling GPS/dip/marker | Snorkeling lifecycle, nav, markers tests | **PENDING** |
| 5 | No state inheritance across modes | `DIRActivitySelectionStore`, isolation tests | **PASS** (static); **PENDING** field |
| 6 | Crash/restart per mode | Per-domain checkpoint tests | **PENDING** device |
| 7 | Concurrent sync + queue | Transport negative tests per domain; separate queues | **PASS** (unit); **PENDING** field |
| 8 | Upgrade from prior version | Per-domain schema migration tests | **PASS** (unit); **PENDING** field |

---

## Findings

| ID | Priority | Finding | Status |
|----|----------|---------|--------|
| AUDIT13-INT-001 | **P1** | `IOSApneaCompanionTests.testApneaSelectionAvailableAfterCommand08` stale — asserts Snorkeling unavailable on iOS; contradicts `DIRActivityMode` + `IOSCompanionActivitySelectionTests` | **OPEN** |
| AUDIT13-INT-002 | **P1** | All integrated physical QA unsigned (Apnea 19 + Snorkeling 21 + Diving/FC matrices) | **OPEN** |
| AUDIT13-INT-003 | **P2** | No single integrated E2E automation across Gauge → FC → Apnea → Snorkeling | **OPEN** (tooling debt) |
| AUDIT13-INT-004 | **P2** | `validate_apnea_release_readiness.sh` can fail on concurrent `xcodegen` (race on `DIRDiving.xcodeproj`) | **OPEN** (environment) |
| AUDIT13-INT-005 | **P3** | Prior per-activity audit docs reference older SHAs; integrated view requires this document as canonical | **INFO** |
| AUDIT13-INT-006 | **P3** | Broader full algorithm suites not executed in this integrated pass | **OPEN** (out of scope) |

**No P0** cross-domain collisions, namespace violations, or runtime bleed detected in automated static/integration tests.

---

## Collisioni e isolamento (summary)

```
┌─────────────┬──────────────────┬──────────────────┬──────────────────┐
│             │ Diving / FC      │ Apnea            │ Snorkeling       │
├─────────────┼──────────────────┼──────────────────┼──────────────────┤
│ Runtime     │ DiveManager / FC │ ApneaSessionEng. │ SnorkelingEng.   │
│             │ engine           │                  │                  │
│ WC payload  │ dirdiving_dive_* │ dirdiving_apnea_*│ dirdiving_snork_*│
│ Logbook     │ dive sessions    │ apnea sessions   │ snork sessions   │
│ Bühlmann    │ FC allowlist     │ forbidden        │ forbidden        │
└─────────────┴──────────────────┴──────────────────┴──────────────────┘
```

Automated guards: `FullComputerWatchArchitectureGuardTests`, `ApneaArchitectureIsolationTests`, `SnorkelingCrossDomainIsolationTests`, `FullComputerTargetMembershipTests`.

---

## Debito tecnico e rischi residui

| Item | Risk | Mitigation |
|------|------|------------|
| Stale `IOSApneaCompanionTests` | Blocks Apnea release-hard script | Update assertion to match Snorkeling iOS companion availability |
| Physical QA 0% all activities | Integrated TestFlight NO-GO | Execute signed QA folders per index |
| No integrated E2E runner | Field regressions undetected | Manual matrix + future `validate_integrated_modes.sh` |
| Parallel xcodegen in CI | Flaky validator scripts | Serialize xcodegen or use pre-generated project |
| FC non-certified posture | Legal/marketing risk | `SAFETY_DISCLAIMER.md`; no certification claims |

---

## Gate labels

```
INTEGRATED_INTERNAL_GO_WITH_CONDITIONS
INTEGRATED_EXTERNAL_NO_GO_PHYSICAL_QA_PENDING
```

Per-activity internal gates remain:

- `SNORKELING_RELEASE_HARD_INTERNAL_GO`
- Apnea / FC internal gates **conditional** on fixing AUDIT13-INT-001 and physical QA

---

## Related documents

- [`AUDIT_FULL_COMPUTER_RELEASE_GATE_CURRENT.md`](AUDIT_FULL_COMPUTER_RELEASE_GATE_CURRENT.md)
- [`AUDIT_APNEA_RELEASE_GATE_CURRENT.md`](AUDIT_APNEA_RELEASE_GATE_CURRENT.md)
- [`AUDIT_SNORKELING_RELEASE_GATE_CURRENT.md`](AUDIT_SNORKELING_RELEASE_GATE_CURRENT.md)
- [`SNORKELING_RELEASE_GATE_REMEDIATION_REPORT_CURRENT.md`](SNORKELING_RELEASE_GATE_REMEDIATION_REPORT_CURRENT.md)
- [`SNORKELING_ARCHITECTURE.md`](SNORKELING_ARCHITECTURE.md)
- [`APNEA_ARCHITECTURE.md`](APNEA_ARCHITECTURE.md)
- [`FULL_COMPUTER_ARCHITECTURE.md`](FULL_COMPUTER_ARCHITECTURE.md)
- [`Docs/QA_EVIDENCE/SNORKELING_QA_EVIDENCE_INDEX.md`](QA_EVIDENCE/SNORKELING_QA_EVIDENCE_INDEX.md)
