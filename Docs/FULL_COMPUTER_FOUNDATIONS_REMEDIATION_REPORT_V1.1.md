# Full Computer Foundations Remediation Report V1.1

**Date:** 2026-06-17  
**Authoritative audit:** `Docs/AUDIT_FULL_COMPUTER_FOUNDATIONS_CURRENT.md` (Audit 01, 2026-06-17)  
**Starting `main` SHA:** `8dbb896`  
**Branch:** `main` (direct remediation — no integration branch)

---

## Executive summary

Commands **01–03** were confirmed on `main` after the `integration/full-computer` merge. This remediation closed Audit 01 findings **P1–P3**: replaced the stale Watch Bühlmann token guard, split platform-specific activity launchability APIs, finalized Watch mode-selection UX (no permanent Mode tab), and aligned documentation with the validated test matrix.

**Verdict:** **PASS** — ready for Command 04.

---

## Commands 01–03 presence on `main`

| Command | Key artifacts | Present |
|---------|---------------|---------|
| 01 Modes & startup | `DIRModesAndStartup.swift`, `DIRStartupSelectionPolicy.swift`, `DIRActivitySelectionStore.swift`, startup views, `ContentView` / `DiveManager` wiring | **Yes** |
| 02 Gauge optional TTV | `GaugeLivePresentationPolicy.swift`, `GaugeOptionalTTVTests`, Settings / `DiveLiveView` / sync | **Yes** |
| 03 Shared Bühlmann core | `Shared/BuhlmannCore/*`, iOS `BuhlmannGas+GasMix.swift`, cross-target equivalence tests | **Yes** |

Duplicate scan: one production `enum BuhlmannEngine` in `Shared/BuhlmannCore/BuhlmannEngine.swift`; no iOS-local engine file.

---

## Findings closed

| ID | Finding | Remediation |
|----|---------|-------------|
| P1 | Stale `buhlmann` token ban in `WatchCompleteAlgorithmAuditRemediationTests` | Removed broad compile-root test; added `FullComputerWatchArchitectureGuard` + 7 focused tests |
| P2 | Ambiguous `isLaunchableInMAIN` | Replaced with `isLaunchableOnWatchMAIN` / `isLaunchableOnIOSCompanionMAIN` |
| P2 | Dual Mode tab + startup cover | `hasMultipleStableModes = false`; cold-launch + Settings only |
| P3 | Doc drift (test counts, branch refs, apnea wording) | Updated implementation reports + audit addendum |

---

## Architecture guard changes

- **Removed:** `testWatchCompileRootsExcludeDecompressionAndCCRRuntimeKeywords`
- **Added:** `Utils/FullComputerWatchArchitectureGuard.swift`
- **Added tests:** `FullComputerWatchArchitectureGuardTests` (7 cases)
- **Policy:** Explicit Full Computer runtime allowlist; strict engine/tissue/projection consumer check; CCR/Ratio Deco token prohibition (excluding guard definition file); Foundation-only shared core; no duplicate engine definitions outside `Shared/BuhlmannCore`

**Approved shared-core consumers (Watch roots):** `FullComputerDecoSolver.swift`, `FullComputerRuntimeEngine.swift`, `FullComputerRuntimeModels.swift`, `FullComputerGasSwitchPolicy.swift`, `FullComputerRuntimeCheckpoint.swift`, `FullComputerRuntimePlan.swift`, `FullComputerDecoSolverModels.swift`, `FullComputerGasProfileValidator.swift`, `DiveManager.swift` (unavailable FC snapshot placeholder only).

---

## Launchability API changes

```swift
// Models/DIRModesAndStartup.swift
var isLaunchableOnWatchMAIN: Bool       // diving only
var isLaunchableOnIOSCompanionMAIN: Bool // diving + apnea
```

- Watch: Apnea/Snorkeling → `comingSoon` / not launchable
- iOS Companion: Apnea remains selectable; Snorkeling not launchable
- `isLaunchableInMAIN` removed from production Swift (docs updated separately)

---

## Watch mode-selection UX (final policy)

| Surface | Policy |
|---------|--------|
| Cold launch | `StartupFlowView` when `showActivitySelectionAtLaunch` (default ON) |
| Settings | Reopen activity / diving mode selection while surfaced |
| Permanent Mode tab | **Hidden** (`hasMultipleStableModes = false`) |
| Active dive | Mode change blocked |
| Full Computer | Pre-dive confirmation always required |
| State store | Single canonical `DIRActivitySelectionStore` |

---

## Gauge TTV verification

- Default **OFF**; hidden when OFF; TTV label (not TTS) in Gauge
- `GaugeOptionalTTVTests`: **8** tests — **PASS**
- Full Computer top panel remains separate (no Gauge TTV bleed)

---

## Shared Bühlmann core purity

- `Shared/BuhlmannCore/`: **Foundation-only** imports (static scan clean)
- Watch Full Computer runtime consumes shared core via allowlisted files only
- `BuhlmannCoreCrossTargetEquivalenceTests`: **PASS**

---

## Apnea / Snorkeling isolation

- Watch: not launchable; routes to `comingSoon`; Apnea/Snorkeling views excluded from Watch target in `project.yml`
- iOS: Apnea companion selection preserved

---

## Target membership

- `FullComputerTargetMembershipTests` (6 cases): shared core on both targets, Apnea UI excluded, no duplicate iOS engine, platform launchability APIs, permanent Mode tab hidden — **PASS**

---

## Files changed (remediation)

| File | Change |
|------|--------|
| `Models/DIRModesAndStartup.swift` | Platform-specific launchability |
| `Utils/DIRStartupSelectionPolicy.swift` | Watch launchability routing |
| `Utils/WatchModeSelectionPreferences.swift` | `hasMultipleStableModes = false` + documented UX |
| `iOSApp/Models/CompanionActivityPreference.swift` | iOS launchability API |
| `Services/AppNavigationStore.swift` | Comment update |
| `Utils/FullComputerWatchArchitectureGuard.swift` | **New** architecture guard helper |
| `Tests/WatchAlgorithmTests/FullComputerWatchArchitectureGuardTests.swift` | **New** |
| `Tests/WatchAlgorithmTests/FullComputerTargetMembershipTests.swift` | **New** |
| `Tests/WatchAlgorithmTests/WatchCompleteAlgorithmAuditRemediationTests.swift` | Stale test removed |
| `Tests/WatchAlgorithmTests/DIRModesAndStartupFlowTests.swift` | Launchability + Mode tab tests |
| `Tests/iOSAlgorithmTests/IOSCompanionActivitySelectionTests.swift` | iOS launchability assertion |
| `project.yml` | Guard helper in Watch targets |
| `Docs/*` | Audit addendum + implementation report updates |

---

## Build results (2026-06-17)

| Target | Result |
|--------|--------|
| `xcodegen generate` | **PASS** |
| DIRDiving Watch App | **BUILD SUCCEEDED** |
| DIRDiving iOS | **BUILD SUCCEEDED** |

Simulators: iPhone 17 Pro, Apple Watch Ultra 3 (49mm).

---

## Focused test results

| Suite | Tests | Result |
|-------|-------|--------|
| `BuhlmannGoldenFixtureTests` | (golden) | **PASS** |
| `DIRModesAndStartupFlowTests` | 14 | **PASS** |
| `GaugeOptionalTTVTests` | 8 | **PASS** |
| `BuhlmannCoreCrossTargetEquivalenceTests` | — | **PASS** |
| `IOSCompanionActivitySelectionTests` | 12 | **PASS** |
| `WatchCompleteAlgorithmAuditRemediationTests` | — | **PASS** |
| `FullComputerWatchArchitectureGuardTests` | 7 | **PASS** |
| `FullComputerTargetMembershipTests` | 6 | **PASS** |

---

## Full suite results

| Suite | Executed | Skipped | Failures | Result |
|-------|----------|---------|----------|--------|
| DIRDiving iOS Algorithm Tests | 932 | 14 | 0 | **PASS** |
| DIRDiving Watch Algorithm Tests | 441 | 16 | 0 | **PASS** |

---

## Command 04 readiness matrix

| Area | Result |
|------|--------|
| Commands 01–03 on `main` | **PASS** |
| Stale Watch guard remediated | **PASS** |
| Shared-core architectural guard | **PASS** |
| Activity launchability semantics | **PASS** |
| Mode-selection UX policy | **PASS** |
| Startup flow / FC confirmation / dive lock | **PASS** |
| Gauge TTV default OFF | **PASS** |
| Shared core Foundation-only | **PASS** |
| No duplicate Bühlmann engine | **PASS** |
| Cross-target equivalence | **PASS** |
| Apnea/Snorkeling Watch isolation | **PASS** |
| iOS + Watch builds | **PASS** |
| Full test suites | **PASS** |
| Documentation | **PASS** |
| **Ready for Command 04** | **YES** |

---

## Remaining risks

- Experimental worktrees (`codex-experimental`, `codex-ios-experimental`) may still predate `main` merge — sync separately if needed.
- `FullComputerDecoGasListView` references `BuhlmannConstants` for display-side gas checks; allowed outside strict runtime allowlist (no engine/tissue/projection).

---

## Git

| Field | Value |
|-------|-------|
| Commit message | `fix: complete Full Computer foundations remediation` |
| Commit SHA | *(filled after commit)* |
| Push | `origin/main` |
| Final alignment | local `HEAD` == `origin/main` |

---

*Remediation V1.1 — implemented directly on `main`.*
