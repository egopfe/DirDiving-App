# DIR Diving — Full Computer release-hard validation (Command 12)

**Date:** 2026-06-02 (updated 2026-06-17)  
**Branch:** `main`  
**Automation:** `./Scripts/validate_full_computer_release_readiness.sh`

---

## Executive summary

Command 12 adds release-hard automated validation, documented tolerances, a 25-mockup audit matrix, and architecture/release documentation for the Full Computer experimental branch.

**This report does not certify the product for diving.** DIR DIVING Full Computer remains an experimental decompressive runtime. Physical validation, external algorithm cross-checks, and regulatory certification are **out of scope** for this command.

---

## Tests executed (automated)

### New suites

| Suite | Tests | Result |
|-------|-------|--------|
| `FullComputerReleaseHardValidationTests` | 14 | PASS (sim) |
| `FullComputerMockupReferenceMatrixTests` | 3 | PASS |

### Existing FC suites (included in validation script)

| Suite | Coverage |
|-------|----------|
| `FullComputerRuntimeEngineTests` | startup, ticks, replay, planner TTS, performance measure |
| `FullComputerDecoSolverTests` | NDL, ceiling, stops, violations |
| `FullComputerRecoveryCheckpointTests` | checkpoint codec, schema v4, logbook merge |
| `FullComputerUIStateMatrixTests` | 20-state fixtures, l10n, predive gate |
| `BuhlmannGoldenFixtureTests` (iOS) | independent golden vectors |
| `PlannerRegressionFixtureTests` (iOS) | planner regression |

### Builds

- Watch (`DIRDiving Watch App`) — BUILD SUCCEEDED
- iOS (`DIRDiving iOS`) — BUILD SUCCEEDED

---

## Differential tolerances (motivated)

| Quantity | Tolerance | Rationale |
|----------|-----------|-----------|
| Planner vs runtime TTS | ±3 min | 1 Hz tick quantization, linear depth segments vs planner segment solver, stop minute rounding |
| Tissue pressure (replay) | ±0.0001 bar | Floating-point parity across ingest paths |
| Deco solver wall time | ≤ 50 ms | Ultra-class Watch UI refresh budget |
| Checkpoint encode+decode | ≤ 50 ms | Recovery must not block main thread |

Constants: `Utils/FullComputerReleaseHardTolerances.swift`

---

## Mockup matrix (25 FC_UI PNGs)

All external mockup files are indexed in `Utils/FullComputerMockupReferenceMatrix.swift`.

- **23 / 25** map to executable fixtures or SwiftUI preview surfaces on Watch.
- **FC_UI_04** (settings activity default) and **FC_UI_07** (iOS plan transfer) are view-level references without deterministic Watch fixtures.
- **No raster mockups** are embedded in the application bundle (verified by test).

Primary live-deco visual regression remains the **20-state** matrix in `FullComputerLivePanelFixtures` (multiple mockups share the same runtime presentation state by design).

---

## Safety gates verified

| Gate | Status |
|------|--------|
| Invalid gas / GF blocks engine start | PASS (automated) |
| Predive sensor unavailable blocks start | PASS (automated) |
| NaN / Inf depth rejected without tissue reset | PASS (automated) |
| No `sessionDivingMode = .gauge` mid-session | PASS (static + integration) |
| Corrupt checkpoint quarantine | PASS (existing recovery tests) |
| Feature remains experimental / non-certified | DOCUMENTED |

---

## Residual gaps and risks

| Gap | Risk | Mitigation path |
|-----|------|-----------------|
| No pool / open-water depth validation | Incorrect sensor → wrong deco state | `WATCH_ULTRA_PHYSICAL_QA_MATRIX.md` |
| No EN13319 / ISO 6425 certification | Legal / safety liability | Do not market as certified DC |
| Screenshot regression not captured in repo | Visual drift undetected | `ReferenceUI/README.md` evidence pack |
| Battery / thermal profiling not automated | Runtime throttling under load | Physical long-dive session QA |
| WatchConnectivity offline edge cases | Plan transfer failure at dive site | `WATCH_IOS_SYNC_QA_MATRIX.md` |
| Mission Mode + FC combined stress | Interaction bugs | Manual mission QA matrix |
| External Bühlmann cross-validation pending | Planner vs third-party tools unknown | `PLANNER_GOLDEN_VALIDATION_QA_MATRIX.md` |

---

## Explicitly not validated

- CE marking, EN13319, or any regulatory dive-computer certification
- Real submersion depth accuracy across temperature / salinity
- CCR / rebreather behaviour (not in FC scope)
- Multi-day repetitive dive surface interval modelling
- Production iCloud conflict resolution under load
- App Store marketing claims
- User skill / training adequacy

---

## Deliverables (Command 12)

| Artifact | Path |
|----------|------|
| Tolerances | `Utils/FullComputerReleaseHardTolerances.swift` |
| Mockup matrix | `Utils/FullComputerMockupReferenceMatrix.swift` |
| Release-hard tests | `Tests/WatchAlgorithmTests/FullComputerReleaseHardValidationTests.swift` |
| Validation script | `Scripts/validate_full_computer_release_readiness.sh` |
| Architecture | `Docs/FULL_COMPUTER_ARCHITECTURE.md` |
| Test matrix | `Docs/FULL_COMPUTER_RELEASE_HARD_TEST_MATRIX.md` |
| Release checklist | `Docs/FULL_COMPUTER_RELEASE_CHECKLIST.md` |
| This report | `Docs/DIR_DIVING_FULL_COMPUTER_RELEASE_HARD_VALIDATION_REPORT.md` |

---

## Prior command reports (context)

Commands 01–11 reports remain authoritative for their respective scopes under `Docs/DIR_DIVING_FULL_COMPUTER_*_REPORT.md` and `Docs/DIR_DIVING_*_REPORT.md`.
