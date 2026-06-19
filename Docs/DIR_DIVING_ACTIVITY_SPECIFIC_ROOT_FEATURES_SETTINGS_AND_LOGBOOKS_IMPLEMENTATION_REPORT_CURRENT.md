# Command 14 — Activity-Specific Root, Features, Settings and Logbooks Implementation Report (Current)

**Date:** 2026-06-17  
**Authoritative command:** `14_ACTIVITY_SPECIFIC_ROOT_FEATURES_SETTINGS_AND_LOGBOOKS_IMPLEMENTATION_UPDATED.md`  
**Branch:** `main` @ `9e8c797` (uncommitted working tree — Audit 13 + Command 14 layered)  
**Validation baseline:** automated re-run 2026-06-17  

---

## Executive summary

Command 14 consolidates a **strictly activity-specific** iOS Companion architecture for Diving, Apnea and Snorkeling. The repository already had strong activity roots, selection, and separate logbooks; this pass closes the largest **settings coherence gaps** on iOS: shared settings store, snorkeling settings persistence, activity switching from all settings surfaces, visibility registry, and automated coherence tests.

| Gate | Verdict |
|------|---------|
| **iOS activity roots / selection / logbooks** | **PASS** — pre-existing + verified |
| **iOS shared + activity-scoped settings (software)** | **PASS** — new stores, views, registry, tests |
| **Watch activity-scoped settings refactor** | **DEFERRED** — Watch `SettingsView` remains diving-centric |
| **Physical / external QA** | **PENDING** — unchanged from Audit 13 |

**Final result: CONDITIONAL PASS**

Software gates for iOS settings separation and automated coherence pass. Watch settings scoping, full Diving settings consolidation (`IOSDivingSettingsStore`), and signed physical QA remain open before a full PASS.

---

## Architecture discovered (pre-implementation audit)

### iOS entry and routing

```
Onboarding / Legal
    → CompanionActivityPreferenceStore.shouldPresentSelectionScreen
    → IOSCompanionActivitySelectionView (Diving | Apnea | Snorkeling)
    → ContentView (Diving) | IOSApneaRootView | IOSSnorkelingRootView
```

Implemented in `DIRDivingiOSApp.swift` with per-activity `@StateObject` stores injected via `.environmentObject`.

### Activity roots (already present)

| Activity | Root view | Tabs / features |
|----------|-----------|-----------------|
| Diving | `ContentView` | Dashboard, Planner, Logbook, Equipment, More/Settings |
| Apnea | `IOSApneaRootView` | Dashboard, Profiles/Planner, Logbook, Statistics, Settings |
| Snorkeling | `IOSSnorkelingRootView` | Dashboard, Route/Map, Logbook, Markers/Photos, Settings |

### Logbooks (already isolated)

| Activity | Store | Namespace |
|----------|-------|-----------|
| Diving | `DiveLogStore` | diving log + cloud sync |
| Apnea | `IOSApneaLogbookStore` | apnea sessions |
| Snorkeling | `IOSSnorkelingLogbookStore` | snorkeling sessions |

Watch ↔ iOS sync uses activity-specific WC namespaces (Apnea/Snorkeling transfer services; diving plan/log sync unchanged).

### Watch (already present, settings gap)

- `DIRActivitySelectionStore` + `DiveLiveView` route Apnea/Snorkeling/Diving (Gauge/FC).
- **Gap:** `SettingsView` and Dive Log tab remain diving-centric; not refactored in this pass.

---

## Coherence issues found

| Item | Issue | Action taken |
|------|-------|--------------|
| Language / units / backup | Fragmented across `@AppStorage` in `MoreView`, duplicate Apnea units toggle | Added `SharedIOSSettingsStore`; Apnea/Snorkeling settings use `IOSCompanionSharedSettingsSection` |
| Snorkeling settings | Minimal placeholder view, no persistence model | Added `SnorkelingCompanionSettings` + `IOSSnorkelingSettingsStore` + expanded `IOSSnorkelingSettingsView` |
| Activity switching | Only in Diving `MoreView` | Added `IOSCompanionActivitySettingsSection` to Apnea/Snorkeling settings; card variant in Diving `MoreView` |
| Cross-scope visibility | No machine-readable audit | Added `ActivitySettingsVisibility` registry + `IOSActivitySettingsCoherenceTests` |
| Pressure unit (BAR/PSI) | Incorrectly classified as shared | Reclassified as **diving-only** (gas/planner/equipment); not shown in Apnea/Snorkeling shared section |
| Diving settings consolidation | Scattered in `MoreView`, planner stores, `@AppStorage` | **Partial** — Diving `MoreView` still uses direct `@AppStorage` (same keys as shared store; no `IOSDivingSettingsStore` yet) |
| Watch settings scoping | Diving controls visible globally on Watch | **Deferred** — documented as risk |

Full matrix: [`DIR_DIVING_ACTIVITY_SETTINGS_COHERENCE_MATRIX_CURRENT.csv`](DIR_DIVING_ACTIVITY_SETTINGS_COHERENCE_MATRIX_CURRENT.csv)

---

## Startup flows

### iOS Companion

```
iOS Startup
→ LegalAcceptanceStore (if required)
→ CompanionActivityPreferenceStore
   ├── no preference / show-at-launch / settings reopen → IOSCompanionActivitySelectionView
   └── persisted mode → activity root
→ Activity Root → Features → Activity Settings / Logbook
```

Rules enforced by existing `CompanionActivityPreferenceStore` + tests (`IOSCompanionActivitySelectionTests`):
- iOS selection changes Companion UI only
- Active Watch session shows note, does not block selection
- Legacy legal-accepted users migrate to Diving without re-selection

### Watch

```
Watch Startup
→ DIRActivitySelectionStore
→ Diving (Gauge | Full Computer) | Apnea | Snorkeling
→ Operational mode screens
```

Unchanged in this pass; activity selection and mode routing pre-validated by integrated mode tests.

---

## Shared settings (new / consolidated)

**Store:** `SharedIOSSettingsStore` (`dirdiving.settings.shared.v1` logical namespace; keys below)

| Setting | Storage key | Surfaces |
|---------|-------------|----------|
| Language | `dirdiving_app_language` | Apnea/Snorkeling settings; Diving `MoreView` (same key) |
| Depth/units | `dirdiving_ios_units` | All three via shared section or MoreView |
| Cloud backup | `dirdiving_ios_cloud_backup_enabled` | Diving MoreView; wired through `CloudBackupSettings` |
| Pressure unit | `dirdiving_ios_pressure_unit` | **Diving only** — MoreView, planner, equipment |

**UI component:** `IOSCompanionSharedSettingsSection` — language + depth units; optional `includePressureUnit` for Diving.

---

## Activity-specific settings

### Diving

- Remains in `MoreView` cards: planner ascent speeds, CNS descent/bottom check, sync scope, diving-only preferences.
- Pressure unit, gas/planner/deco settings **not** exposed in Apnea/Snorkeling.

### Apnea

- Store: `IOSApneaSettingsStore` (`dirdiving_ios_apnea_settings_v1`)
- View: `IOSApneaSettingsView` — detection, recovery, equipment, buddy, feedback; **removed duplicate units toggle**; syncs `useMetricUnits` from shared store.

### Snorkeling (new)

- Model: `SnorkelingCompanionSettings` (`dirdiving.settings.snorkeling.v1`)
- Store: `IOSSnorkelingSettingsStore`
- View: `IOSSnorkelingSettingsView` — water detection, GPS/return-to-entry, alerts, equipment, buddy, privacy note.

---

## Settings excluded per activity

Verified by `ActivitySettingsVisibility.verifyNoCrossScopeLeakage()` and unit tests:

| Excluded from Apnea/Snorkeling | Excluded from Diving/Apnea | Excluded from Diving/Snorkeling |
|-------------------------------|----------------------------|--------------------------------|
| CNS, GF, PPO2, gas, deco, pressure unit, planner ascent | Apnea recovery, targets, apnea detection | GPS tracking, return-to-entry, dip threshold, snorkeling alerts |

---

## Stores and schemas

| Store | Scope | Persistence |
|-------|-------|-------------|
| `SharedIOSSettingsStore` | Shared | UserDefaults (existing keys) |
| `IOSApneaSettingsStore` | Apnea | JSON `dirdiving_ios_apnea_settings_v1` |
| `IOSSnorkelingSettingsStore` | Snorkeling | JSON `dirdiving.settings.snorkeling.v1` |
| `CompanionActivityPreferenceStore` | Companion routing | UserDefaults |
| `DiveLogStore` / `IOSApneaLogbookStore` / `IOSSnorkelingLogbookStore` | Per-activity logbooks | Separate files / cloud paths |

---

## Sync routing

- Unchanged WC namespace isolation from prior Apnea/Snorkeling work.
- Companion activity preference sync does **not** interrupt active Watch sessions (`watchActiveSessionNote` pattern).
- Shared backup may include all activity stores; restoration preserves per-activity separation (existing `CloudSyncStore` behaviour).

---

## Migration

| Policy | Status |
|--------|--------|
| Existing Diving users keep preference + logbook | **PASS** — `CompanionActivityPreferenceStore` legacy migration tested |
| Common settings → shared keys | **PASS** — same UserDefaults keys; no data move required |
| Snorkeling settings | **N/A** — new namespace with defaults |
| Unknown keys quarantine | **NOT IMPLEMENTED** — no new quarantine layer; legacy keys untouched |

---

## Files modified / added (Command 14 scope)

### Added

- `iOSApp/Services/SharedIOSSettingsStore.swift`
- `iOSApp/Services/IOSSnorkelingSettingsStore.swift`
- `iOSApp/Models/SnorkelingCompanionSettings.swift`
- `iOSApp/Utils/ActivitySettingsVisibility.swift`
- `iOSApp/Views/Components/IOSCompanionSharedSettingsSection.swift`
- `iOSApp/Views/Components/IOSCompanionActivitySettingsSection.swift`
- `Tests/iOSAlgorithmTests/IOSActivitySettingsCoherenceTests.swift`

### Modified

- `iOSApp/App/DIRDivingiOSApp.swift` — inject shared + snorkeling settings stores
- `iOSApp/Views/Apnea/IOSApneaSettingsView.swift`
- `iOSApp/Views/Snorkeling/IOSSnorkelingSettingsView.swift`
- `iOSApp/Views/MoreView.swift` — activity settings card
- `iOSApp/Resources/en.lproj/Localizable.strings` + `it.lproj/Localizable.strings`
- `project.yml`

*(Audit 13 files also present in the same uncommitted tree — see [`AUDIT_INTEGRATO_TRE_MODALITA_REMEDIATION_REPORT_CURRENT.md`](AUDIT_INTEGRATO_TRE_MODALITA_REMEDIATION_REPORT_CURRENT.md).)*

---

## Tests added

| Test suite | Coverage |
|------------|----------|
| `IOSActivitySettingsCoherenceTests` | Registry leakage, scope isolation, shared/snorkeling store round-trip |
| `IOSCompanionActivitySelectionTests` | Startup selection, migration, watch guard (pre-existing, re-run) |

---

## Tests executed (2026-06-17)

| Command | Result |
|---------|--------|
| `xcodegen generate` | **PASS** |
| `xcodebuild … DIRDiving iOS` build | **PASS** |
| `IOSActivitySettingsCoherenceTests` | **PASS** (7 tests) |
| `IOSCompanionActivitySelectionTests` | **PASS** (11 tests) |
| `./Scripts/audit_localization.sh` | **PASS** (iOS EN=2526 IT=2526) |

---

## Unresolved risks

1. **Watch settings scoping** — diving-centric `SettingsView`; Command 14 §7–9 Watch settings not fully implemented.
2. **Diving settings store** — no `IOSDivingSettingsStore`; `MoreView` duplicates shared `@AppStorage` bindings instead of `SharedIOSSettingsStore` environment object.
3. **Physical QA** — Apnea/Snorkeling/Diving signed matrices remain **PENDING** (Audit 13 external NO-GO unchanged).
4. **Diving MoreView ↔ SharedIOSSettingsStore** — two UI paths write the same keys; functionally coherent but not a single settings surface.

---

## Related documents

- [`DIR_DIVING_ACTIVITY_SETTINGS_COHERENCE_MATRIX_CURRENT.csv`](DIR_DIVING_ACTIVITY_SETTINGS_COHERENCE_MATRIX_CURRENT.csv)
- [`AUDIT_INTEGRATO_TRE_MODALITA_REMEDIATION_REPORT_CURRENT.md`](AUDIT_INTEGRATO_TRE_MODALITA_REMEDIATION_REPORT_CURRENT.md)
- [`INTEGRATED_MODES_RELEASE_VALIDATION_MATRIX_CURRENT.csv`](INTEGRATED_MODES_RELEASE_VALIDATION_MATRIX_CURRENT.csv)

---

## Final result

**CONDITIONAL PASS**

iOS activity-specific roots, logbooks, shared settings consolidation (Apnea/Snorkeling), snorkeling settings domain, activity switching from all settings surfaces, and automated coherence tests meet Command 14 software requirements. Full PASS requires Watch settings scoping, optional Diving settings store consolidation, and signed physical QA evidence.
