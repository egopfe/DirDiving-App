# Activity Architecture, Settings & Logbook Audit (Current)

**Command:** 7 — `7-DIR_DIVING_ACTIVITY_ARCHITECTURE_SETTINGS_LOGBOOK_AUDIT_V3.0`  
**Date:** 2026-06-20  
**Branch:** `main` @ `8d65daf`  
**Working tree at audit start:** Clean  
**Task type:** Read-only audit (reports only; no production code changes)

---

## Executive summary

Multi-activity architecture on `main` is **well-separated on iOS** and **strong at the data/write layer on Watch**, with one **P0 Watch UI gap**: `DiveLogListView` remains in the global vertical `TabView` regardless of selected activity, allowing Apnea/Snorkeling users to crown-navigate to the Diving logbook when idle.

| Dimension | Score (0–100) | Verdict |
|-----------|---------------|---------|
| Diving | **84** | Gauge/FC flow solid; fragmented diving settings; Watch logbook tab not activity-scoped |
| Apnea | **88** | Clean iOS root, settings, logbook; inherits Watch logbook tab leak |
| Snorkeling | **88** | Dedicated GPS/route settings and logbook on iOS; same Watch logbook tab leak |
| Cross-activity isolation (overall) | **74** | Data/sync isolation strong; Watch UI routing + missing navigation tests pull score down |

**P0 findings:** 1 (Watch logbook UI routing)  
**P1 findings:** 4 (latent iOS env injection, Watch GPS status row, fragmented diving settings, naming drift)

---

## Scope

Activities audited:

```text
Diving → Gauge / Full Computer
Apnea
Snorkeling
```

Areas: startup selection (iOS + Watch), activity-owned roots, vertical features, Settings ownership, strict Logbook ownership, forbidden cross-activity routes.

---

## Preflight

```text
Branch: main
HEAD:   8d65daf
Status: clean, up to date with origin/main
```

Environmental limitations: Physical-device QA, underwater crown navigation, and pixel-level UI diff not executed. Findings are from static code inspection and existing automated tests (not re-run in this audit pass).

---

## Root flow

### Onboarding / legal gate — PASS

| Platform | Entry | Gate |
|----------|-------|------|
| Watch | `App/DIRDivingApp.swift` | `LegalAcceptanceStore` → `WatchLegalOnboardingView` |
| iOS | `iOSApp/App/DIRDivingiOSApp.swift` | `LegalAcceptanceStore` → `IOSLegalOnboardingView` |

Tests: `LegalAcceptanceGateTests`, `IOSCompanionActivitySelectionTests.testLegacyUserWithLegalAcceptanceMigratesToDivingWithoutSelection`.

### iOS activity selection — PASS

Flow:

```text
DIRDivingiOSApp
├── legalAcceptance.requiresAcceptance → IOSLegalOnboardingView
├── companionActivity.shouldPresentSelectionScreen → IOSCompanionActivitySelectionView
├── selectedMode == .apnea → IOSApneaRootView (applyApneaEnvironment)
├── selectedMode == .snorkeling → IOSSnorkelingRootView (applySnorkelingEnvironment)
└── else → ContentView (Diving, applySharedEnvironment)
```

Persistence: `CompanionActivityPreferenceStore` (`dirdiving_ios_companion_activity_preference_v1`).  
Watch guard: `CompanionActivityWatchSessionGuard` shows note during active Watch session; selection not blocked.

### Watch activity selection — PASS

`StartupFlowView` → `ActivitySelectionView` → (Diving) `DivingModeSelectionView` → FC predive/confirm when applicable.  
Policy: `Utils/DIRStartupSelectionPolicy.swift` (`resolveLaunchStep()`).  
Store: `Services/DIRActivitySelectionStore.swift`.

### Diving mode selection (Gauge / Full Computer) — PASS

Apnea/Snorkeling skip to `.ready`; Diving requires mode pick. Full Computer requires predive configuration + `confirmFullComputerPredive()`.  
Tests: `DIRModesAndStartupFlowTests`.

### Preference persistence — PASS

| Platform | Mechanism | Keys |
|----------|-----------|------|
| Watch | UserDefaults via `DIRStartupSelectionPolicy` | `showActivitySelectionAtLaunchKey`, `defaultActivityModeKey`, diving mode keys |
| iOS | JSON `CompanionActivityPreference` | `dirdiving_ios_companion_activity_preference_v1` |

### Migration — PASS

- Watch: legacy `WatchModeSelectionPreferences.skipWhenSingleModeKey` → `showActivitySelectionAtLaunchKey`
- iOS: legal acceptance timestamp → `.legacyDivingMigration()` (skip re-selection for legacy diving users)

### Feature flags — PASS (all enabled)

`DIRActivityMode.isLaunchableOnWatchMAIN` and `isLaunchableOnIOSCompanionMAIN` return `true` for all three modes.  
`CompanionActivityAvailability.isAvailable` infrastructure exists for coming-soon UI but all modes are enabled at `8d65daf`.

### Active-session lock — PASS

`DIRActivitySelectionStore.canChangeModes` blocks activity/mode changes during:
- `DiveManager.isDiveActive`
- `ApneaWatchRuntimeStore` active session
- `SnorkelingWatchRuntimeStore` active session

Toast via `presentModeChangeBlocked()`. iOS defers preference sync only (`CompanionActivityWatchSessionGuard`).

### Deep links — PASS (N/A)

No `onOpenURL`, URL types, or universal-link handlers found. Consistent with prior audit `Docs/DIR_DIVING_IOS_ACTIVITY_SELECTION_AND_LINKS_AUDIT_CURRENT.md`.

### State restoration — PARTIAL

Per-session checkpoint restore exists:
- Diving: `DiveManager` draft recovery
- Full Computer: `FullComputerRuntimeEngine`
- Apnea: `ApneaSessionEngine` / `ApneaWatchRuntimeStore`
- Snorkeling: `SnorkelingSessionEngine`

No SwiftUI scene / tab / activity **navigation** restoration after process death.

---

## Settings audit

### Store naming map (spec vs code)

| Audit spec name | Actual implementation | Storage namespace |
|-----------------|----------------------|-------------------|
| SharedSettingsStore | `SharedIOSSettingsStore` | `dirdiving.settings.shared.v1` |
| DivingSettingsStore | **Not consolidated** — fragmented across `MoreView`, `PlannerAscentSpeedSettingsStore`, Watch `AscentRateSettingsStore`, `DIRStartupSelectionPolicy`, `FullComputerPrediveConfigurationStore` | Multiple keys (see matrix CSV) |
| ApneaSettingsStore | `IOSApneaSettingsStore` | `dirdiving_ios_apnea_settings_v1` |
| SnorkelingSettingsStore | `IOSSnorkelingSettingsStore` | `dirdiving.settings.snorkeling.v1` |

Registry: `iOSApp/Utils/ActivitySettingsVisibility.swift` — tested by `IOSActivitySettingsCoherenceTests.testRegistryHasNoCrossScopeLeakage`.

### Target membership — PASS

iOS-only: `SharedIOSSettingsStore`, `IOSApneaSettingsStore`, `IOSSnorkelingSettingsStore`, `ActivitySettingsVisibility`.  
Watch: `AscentRateSettingsStore`, activity-scoped sections in `WatchActivitySettingsSections.swift`.

### Watch/iOS sync policy — PARTIAL

Activity-specific WatchConnectivity namespaces verified in isolation tests. Gauge TTV synced via `watchSync.publishGaugeTTVPreference`. No unified settings sync policy document; per-activity WC transfer on demand for Apnea/Snorkeling companion settings.

### Negative settings exposure checks

| Check | Verdict | Evidence |
|-------|---------|----------|
| CNS/PPO2/GF/gas/deco absent from Apnea/Snorkeling (iOS) | **PASS** | Registry + `IOSApneaSettingsView` / `IOSSnorkelingSettingsView`; diving keys in `MoreView` only |
| CNS/PPO2/GF/gas/deco absent from Apnea/Snorkeling (Watch) | **PASS** | Watch safety/mission sections gated `activitySelection.selectedActivity == .diving` in `SettingsView` |
| Apnea recovery/targets absent from Diving/Snorkeling | **PASS** | Recovery UI in `IOSApneaSettingsView`, `WatchApneaActivitySettingsSection` only |
| GPS/route/return absent from Diving/Apnea settings | **PARTIAL** | Snorkeling route/return/GPS only in snorkeling surfaces. Watch `SettingsView` shows **global hardware GPS status row** for all activities (informational, not route planner). Diving live view uses GPS for dive start/end (diving-scoped runtime behavior). |

### Diving settings consolidation — PARTIAL (P1)

No `IOSDivingSettingsStore` or registry entries for all diving keys. Correct today but harder to audit on future `MoreView` edits. See `diving.settings.consolidated_store` in settings matrix.

---

## Logbook audit

### Ownership model

| Activity | Watch store / UI | iOS store / UI |
|----------|------------------|----------------|
| Diving | `DiveLogStore`, `DiveLogListView` (`AppPage.diveLog`) | `DiveLogStore`, `LogbookView` (Diving `ContentView` tab) |
| Apnea | `ApneaLogbookStore`, save via `ApneaView` (no browse tab) | `IOSApneaLogbookStore`, `IOSApneaSessionsListView` |
| Snorkeling | `SnorkelingLogbookStore`, save via `SnorkelingView` (no browse tab) | `IOSSnorkelingLogbookStore`, `IOSSnorkelingSessionsListView` |

Write-path isolation tested: `IntegratedModesSequentialFlowTests.testSequentialGaugeFullComputerApneaSnorkelingWithoutCrossDomainBleed`, `ApneaWatchRuntimeStoreTests.testCompletedSessionWritesOnlyToApneaLogbook`.

### Six forbidden cross-activity logbook routes

| Route | iOS | Watch | Severity |
|-------|-----|-------|----------|
| Diving → Apnea Logbook | PASS | PASS | — |
| Diving → Snorkeling Logbook | PASS | PASS | — |
| Apnea → Diving Logbook | PASS | **FAIL** | **P0** |
| Apnea → Snorkeling Logbook | PASS | PASS | — |
| Snorkeling → Diving Logbook | PASS | **FAIL** | **P0** |
| Snorkeling → Apnea Logbook | PASS | PASS | — |

**Watch failure detail:** `Views/ContentView.swift` always mounts `DiveLogListView().tag(AppPage.diveLog)` with no `selectedActivity == .diving` gate. Crown navigation reaches diving logbook when idle. During active Apnea/Snorkeling sessions, navigation to non-live pages is blocked, which **temporarily hides** the leak but does not fix idle-state access.

**Note:** `SettingsView` correctly gates the export-logbook shortcut to diving only (`activitySelection.selectedActivity == .diving`); the TabView tab remains the gap.

### iOS section → logbook mapping — PASS

```text
Diving section   → Diving Logbook only   (LogbookView / DiveLogStore)
Apnea section    → Apnea Logbook only    (IOSApneaSessionsListView)
Snorkeling section → Snorkeling Logbook only (IOSSnorkelingSessionsListView)
```

No cross-root tab exposure on iOS.

---

## Findings register

### P0 — wrong Logbook or safety settings exposure

| ID | Issue | Impact | Location |
|----|-------|--------|----------|
| **P0-LOGBOOK-WATCH-001** | Watch `DiveLogListView` tab always reachable regardless of `DIRActivitySelectionStore.selectedActivity` | Apnea/Snorkeling users can view/export **Diving** logbook via crown when idle | `Views/ContentView.swift`, `Models/AppPage.swift` |
| **P0-TEST-GAP-001** | No automated test for six forbidden logbook **navigation** routes | Regression risk on Watch logbook gating | Missing test in Watch/iOS targets |

### P1 — settings / environment (data/safety-adjacent)

| ID | Issue | Impact | Location |
|----|-------|--------|----------|
| **P1-ENV-001** | `applyApneaEnvironment` / `applySnorkelingEnvironment` call `applySharedEnvironment`, injecting `DiveLogStore` | Latent cross-activity access if a view accidentally binds diving logbook | `iOSApp/Services/IOSCompanionStoreCoordinator.swift` |
| **P1-SETTINGS-WATCH-001** | Watch global hardware GPS status row visible in all activity settings | Informational blur of snorkeling-GPS policy | `Views/SettingsView.swift` hardware section |
| **P1-SETTINGS-IOS-001** | Fragmented diving settings (no consolidated store) | Audit/maintenance risk on future edits | `iOSApp/Views/MoreView.swift` |
| **P1-NAMING-001** | Spec store names differ from code | Documentation/audit tooling drift | Naming across docs vs implementation |

No P0 **settings control** leakage found on iOS.

---

## Test coverage referenced

| Test file | Coverage |
|-----------|----------|
| `Tests/WatchAlgorithmTests/DIRModesAndStartupFlowTests.swift` | Watch startup, migration, session lock, FC confirm |
| `Tests/iOSAlgorithmTests/IOSCompanionActivitySelectionTests.swift` | iOS selection, legal migration, watch-active note |
| `Tests/iOSAlgorithmTests/IOSActivitySettingsCoherenceTests.swift` | Settings registry leakage, store round-trips |
| `Tests/WatchAlgorithmTests/WatchActivitySettingsOwnershipTests.swift` | Watch SettingsView activity gating |
| `Tests/WatchAlgorithmTests/ApneaArchitectureIsolationTests.swift` | Apnea ↔ Diving/FC symbol isolation |
| `Tests/WatchAlgorithmTests/SnorkelingArchitectureIsolationTests.swift` | Snorkeling engine isolation |
| `Tests/WatchAlgorithmTests/IntegratedModesSequentialFlowTests.swift` | Sequential mode logbook write isolation |
| `Tests/WatchAlgorithmTests/ApneaWatchRuntimeStoreTests.swift` | Apnea write-path logbook isolation |

**Gap:** UI routing tests for six forbidden logbook paths not present.

---

## Related deliverables

- `Docs/ACTIVITY_FEATURE_OWNERSHIP_MATRIX_CURRENT.csv`
- `Docs/ACTIVITY_SETTINGS_COHERENCE_MATRIX_CURRENT.csv`
- `Docs/LOGBOOK_OWNERSHIP_ROUTING_MATRIX_CURRENT.csv`

Prior related docs (may reference older SHAs): `Docs/DIR_DIVING_ACTIVITY_SETTINGS_COHERENCE_MATRIX_CURRENT.csv`, `Docs/DIR_DIVING_LOGBOOK_OWNERSHIP_AND_ROUTING_MATRIX_CURRENT.csv`, `Docs/DIR_DIVING_IOS_ACTIVITY_SELECTION_AND_LINKS_AUDIT_CURRENT.md`.

---

## Remediation recommendations (documentation only; not applied in this pass)

1. Gate `DiveLogListView` in `ContentView` to `selectedActivity == .diving` (or remove tab for non-diving activities).
2. Add UI routing tests enumerating six forbidden logbook navigation paths.
3. Split `applySharedEnvironment` so Apnea/Snorkeling roots do not receive `DiveLogStore` unless required for sync adapters.
4. Consolidate diving settings into `IOSDivingSettingsStore` + registry entries (future hardening).
5. Activity-scope Watch hardware GPS status row for Snorkeling-only when product policy requires strict visual isolation.

---

**Audit completed:** 2026-06-20 on `main` @ `8d65daf`.
