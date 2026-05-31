# DIR DIVING — MAIN Branch UX / Interaction / Feature Accessibility Audit

**Date:** 2026-05-24  
**Branch audited:** `main` @ `13b4a16`  
**Scope:** Apple Watch MAIN target + iOS Companion MAIN target only  
**Excluded:** `codex/experimental-features`, `codex/ios-experimental-features`, and all files excluded from `project.yml` (Snorkeling, Apnea, Buddy Assist, Explore Lab, etc.)

**Audit type:** Pre-modification, read-only code review. **No code changes** were made for this report.

**Method:** Static analysis of navigation graphs, SwiftUI views, `@AppStorage` keys, `WatchConnectivity` flows, haptics, App Intents, and alignment with `Docs/DIR_DIVING_Feature_Comparison.csv`.

---

## 9. Final Summary

| Dimension | Estimate | Notes |
|-----------|----------|--------|
| **Release readiness (UX)** | **~78%** | Core Diving + log + compass + iOS logbook/planner usable; several misleading or incomplete flows |
| **UX completeness** | **~72%** | Many features reachable; gaps in edit paths, unit display consistency, planner result honesty |
| **Stability (interaction)** | **~85%** | Few crash-class issues found statically; sync/conflict paths mostly surfaced |
| **Safety completeness (UX)** | **~80%** | Ascent + depth limits + legal gates strong; alarm default mismatch + planner mock row weaken trust |

**Verdict:** Safe to continue TestFlight-style testing on MAIN, but **not** “feature-complete” from a strict UX audit. Address **3 BLOCKER** items before marketing planner/manual-dive as production-ready.

**Downloadable report:** `Docs/MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524.docx` (generate via `python3 Docs/generate_main_branch_ux_interaction_accessibility_audit_20260524_docx.py`).

---

## 1. Feature Inventory

Legend: **I** = implemented in MAIN build · **R** = reachable without dev tricks · **C** = flow completable · **—** = partial

### Apple Watch MAIN

| Feature | I | R | C | Status | Notes |
|---------|---|---|---|--------|-------|
| Legal first-launch onboarding | ✓ | ✓ | ✓ | Complete | Hard gate; no back; Exit → alert only |
| Launch companion disclaimer | ✓ | ✓ | ✓ | Partial | Every cold launch; not persisted |
| Mode Selection (Diving) | ✓ | ✗* | — | Hidden | `hasMultipleStableModes = false`; auto-skip to Live |
| Live dive dashboard | ✓ | ✓ | ✓ | Complete | Crown tab; default entry |
| Auto dive start/stop (submersion) | ✓ | ✓† | ✓ | Complete | †Requires entitlement/hardware |
| Manual dive start/end | ✓ | ✓‡ | ✓ | Partial | ‡Only when depth automation unavailable |
| Stopwatch START/STOP/RESET | ✓ | ✓ | ✓ | Complete | Independent of dive session |
| Ascent rate gauge + inline alarm | ✓ | ✓ | ✓ | Complete | Haptics throttled; visual when haptics off |
| Depth safety 35/38/40 m UI | ✓ | ✓ | ✓ | Complete | Fixed thresholds in code; not user-configurable |
| GPS entry/exit confirmation | ✓ | ✓ | ✓ | Complete | Inline banner ~1.4 s on Live |
| Runtime/depth/battery alarms | ✓ | ✓ | △ | Partial | △Runtime default 30 in UI vs 60 in engine until key set |
| BUSSOLA (compass) | ✓ | ✓ | ✓ | Complete | SET/CLEAR bearing; Crown tab |
| Settings hub | ✓ | ✓ | ✓ | Mostly | Export row informational only |
| Ascent rate limits (ASC SET) | ✓ | ✓ | ✓ | Complete | Push from Settings |
| Alarm thresholds | ✓ | ✓ | ✓ | Partial | See runtime default mismatch |
| Units metric/imperial | ✓ | ✓ | △ | Partial | Picker in Settings; Live/Log still show `m` |
| Language IT/EN | ✓ | ✓ | ✓ | Complete | Settings wheel |
| Haptics toggle | ✓ | ✓ | ✓ | Complete | |
| Dive log list + detail | ✓ | ✓ | ✓ | Complete | NavigationStack push |
| Delete dive | ✓ | ✓ | ✓ | Complete | Confirm dialog |
| Export Subsurface (latest + per dive) | ✓ | ✓ | ✓ | Complete | ShareLink / ExportView |
| User Images tab | ✓ | △ | ✓ | Conditional | Tab hidden if no bundle/imported images |
| Watch → iPhone sync | ✓ | ✓ | △ | Partial | Status + retry; user must open Settings |
| iPhone → Watch session import | ✓ | △ | △ | Partial | When companion pushes |
| App Intents (stopwatch) | ✓ | △ | ✓ | Partial | Only 2/7 in Shortcuts catalog |
| Side button / long-press dive control | ✗ | ✗ | — | By design | Documented limitation |
| Snorkeling / Apnea / Buddy | ✗ | ✗ | — | Excluded | Not in MAIN target |

### iOS Companion MAIN

| Feature | I | R | C | Status | Notes |
|---------|---|---|---|--------|-------|
| Legal onboarding | ✓ | ✓ | ✓ | Complete | Same pattern as Watch |
| Launch companion disclaimer | ✓ | ✓ | ✓ | Partial | Every launch |
| Tab: Planner (default) | ✓ | ✓ | ✓ | Complete | |
| Tab: Logbook | ✓ | ✓ | △ | Partial | △Manual edit unreachable |
| Tab: Analysis | ✓ | ✓ | ✓ | Complete | Empty state actions |
| Tab: Equipment | ✓ | ✓ | ✓ | Complete | Checklist CRUD |
| Tab: More (settings) | ✓ | ✓ | ✓ | Complete | No separate Settings app section |
| Dive detail (tabs, charts) | ✓ | ✓ | △ | Partial | Manual pressures not shown |
| CSV import | ✓ | ✓ | ✓ | Complete | Logbook, More, Analysis empty |
| CSV export Subsurface | ✓ | ✓ | ✓ | Complete | Per dive detail |
| Manual dive add | ✓ | ✓ | ✓ | Complete | Logbook `+` |
| Manual dive edit | ✓ | ✗ | ✗ | **Broken** | Editor supports `existing:` but no entry |
| Manual dive delete | ✓ | ✓ | ✓ | Complete | Logbook trash only |
| Planner input + calculate | ✓ | ✓ | ✓ | Complete | Safety ack gates form |
| Planner result (tabs) | ✓ | ✓ | △ | Partial | Hardcoded ascent row + dead share icon |
| Watch sync import | ✓ | ✓ | △ | Partial | Conflicts UI in More |
| Push sessions to Watch | ✓ | ✓ | ✓ | Complete | Button in More |
| Units + WC sync | ✓ | ✓ | △ | Partial | Display; export stays metric |
| Photo → Watch | ✓ | ✓ | △ | Partial | PhotosPicker; needs paired Watch |
| iCloud KVS backup | ✓ | ✓ | △ | Partial | Silent decode failures possible |
| Demo logbook toggle | ✓ | ✓ | ✓ | Complete | Reviewer mode |
| Reset Watch pairing trust | ✓ | ✗ | — | Hidden | API exists; no More UI |

---

## 2. Navigation Map

### Watch MAIN (vertical `TabView` + `NavigationStack` root)

```
App launch
  → [Legal onboarding] (if required) — dead-end except Accept / Force quit
  → ContentView (TabView, verticalPage / Digital Crown)
       ├─ [Mode Selection] — ONLY if hasMultipleStableModes (currently OFF)
       ├─ Live (default)
       ├─ Compass (BUSSOLA)
       ├─ Settings
       │    ├─ push → AscentRateSettingsView  (← back)
       │    ├─ push → AlarmSettingsView      (← back)
       │    ├─ push → WatchLegalSafetyView    (← back)
       │    ├─ push → WatchShortcutHelpView   (← back)
       │    └─ push → InfoView               (← back)
       ├─ [User Images] — if imageNames non-empty
       │    └─ in-tab detail (SCHERMI button)
       └─ Dive Log
            ├─ push → DiveDetailView
            │    └─ push → ExportView (TORNA AI LOG)
            └─ export latest → ExportView
  → fullScreenCover: Launch companion disclaimer (each session)
```

**Dead ends / weak return:** Legal onboarding (intentional); companion disclaimer (Continue only).  
**Missing routes:** No in-app path to Mode Selection; no Settings → Export action (export only from Log).

### iOS MAIN (`TabView` + per-tab `NavigationStack`)

```
App launch
  → [IOSLegalOnboardingView] if required
  → ContentView TabView
       ├─ Planner → PlanResultView (navigationDestination)
       ├─ Logbook → DiveDetailView | ManualDiveEditorView (add only)
       ├─ Analysis (fileImporter on stack)
       ├─ Equipment
       └─ More → IOSLegalSafetyView (push)
  → fullScreenCover: Launch companion disclaimer
```

**Dead ends:** None critical beyond legal gate.  
**Missing routes:** Logbook → ManualDiveEditor(existing); More → resetPairingTrust; DiveDetail → delete.

---

## 3. Settings Report

### Watch — exposed in UI (`SettingsView` + pushes)

| Setting | UI | Persisted | Applied at runtime |
|---------|-----|-----------|------------------|
| Units metric/imperial | Picker | ✓ | Partial (alarms label only; not Live) |
| Language | Picker | ✓ | ✓ (locale) |
| Haptics | Toggle | ✓ | ✓ |
| Ascent limits | ASC SET screen | ✓ | ✓ |
| Alarm toggles + thresholds | Alarm screen | ✓ | △ runtime default bug |
| Legal re-read | Push | ✓ | Read-only |
| Sync retry / clear queue | Buttons | — | ✓ |

### Watch — in code but NOT in UI

| Key / preference | Notes |
|------------------|-------|
| `dirdiving_watch_skip_mode_selection_when_single` | Defaults true; no toggle |
| Depth safety 35/38/40 m | `DepthSafetyConfiguration` constants only |
| Always-On / brightness | **Not implemented** (informational row only) |

### iOS — exposed in `MoreView` (+ Planner ack)

| Setting | UI | Persisted | Synced to Watch |
|---------|-----|-----------|-----------------|
| Units | Segmented | ✓ | ✓ (`units` context) |
| Language | Segmented | ✓ | ✗ (companion only) |
| Demo logbook | Toggle | ✓ | ✗ |
| Cloud sync button | Button | — | — |
| Watch sync / conflicts | Cards | — | Partial |
| Planner safety ack | Toggle | Session `@State` only | ✗ |

### iOS — backend without UI

| API / key | Issue |
|-----------|--------|
| `WatchSyncService.resetPairingTrust` | No button in More |
| Per-field iCloud merge policy | Preview only; no resolver UI |

---

## 4. Hardware Interaction Report

| Mechanism | Watch MAIN | iOS MAIN |
|-----------|------------|----------|
| Digital Crown | Vertical tab paging (`TabView` + `.verticalPage`); scroll in lists | Scroll in `ScrollView` |
| Side button | **Not mapped** (documented in Shortcut help) | N/A |
| Long press | **Not found** in MAIN sources | N/A |
| Force Touch / Haptic | `HapticService` + depth coordinator | System only |
| Action Button / Shortcuts | 2 stopwatch intents in catalog; 5 more in code only | N/A |

### Haptic events (Watch, when enabled)

| Event | Haptic |
|-------|--------|
| Ascent over limit | Failure + repeat ~1.75 s |
| Depth 35/38/40 m | Throttled via `DepthLimitHapticCoordinator` |
| Depth/time/battery alarms | `warnIfNeeded` (2 s throttle) |
| Stopwatch / compass SET | confirm / notify |
| GPS confirmation | confirm |
| Dive begin | confirm (coordinator) |

**Gaps:** No haptic on log delete confirm; buddy haptics exist in code but Buddy target excluded.

---

## 5. UX Blockers

| ID | Severity | Platform | Issue |
|----|----------|----------|-------|
| B1 | **CRITICAL** | iOS | **Manual dive edit unreachable** — `ManualDiveEditorView(existing:)` never linked |
| B2 | **CRITICAL** | iOS | **`DiveSessionMerge` drops manual fields** — iCloud merge loses `isManual`, pressures, equipment, deco notes |
| B3 | **CRITICAL** | iOS | **Hardcoded planner ascent row** (`40.0 m`, `TRIMIX 18/45`) shown as real plan data |
| H1 | **HIGH** | iOS | **Launch companion disclaimer every launch** — no persistence |
| H2 | **HIGH** | iOS | **Manual entry/exit pressures not shown** in `DiveDetailView` gas block |
| H3 | **HIGH** | iOS | **Plan result share toolbar icon** has no action |
| H4 | **HIGH** | iOS | **`resetPairingTrust` not exposed** when Watch association fails |
| H5 | **HIGH** | Watch | **Runtime alarm threshold** UI default 30 min vs `DiveManager` fallback **60** until key written |
| H6 | **HIGH** | Watch | **Units picker does not affect Live/Log** depth labels (always metric display) |
| M1 | **MEDIUM** | Watch | **GPSStartRegisteredView / GPSEndRegisteredView** — dead code; production uses inline banner only |
| M2 | **MEDIUM** | iOS | **CSV import** not offered on Analysis when logbook non-empty |
| M3 | **MEDIUM** | iOS | **Conflict “keep local”** does not re-push local session to Watch |
| M4 | **MEDIUM** | iOS | **Legal disclaimer scroll gate** may pass without scroll if content fits |
| M5 | **MEDIUM** | Both | **Settings “sync impostazioni”** documented local-only — units only partial exception |
| L1 | **LOW** | iOS | Logbook decorative `ellipsis` / `plus` affordances |
| L2 | **LOW** | iOS | Mixed IT/EN strings in planner result / onboarding |
| L3 | **LOW** | Watch | Mode Selection dormant — OK for single-mode product |

---

## 6. Safety Issues

| ID | Severity | Issue |
|----|----------|--------|
| S1 | **HIGH** | Planner UI can imply certified deco plan due to **mock ascent row** (B3) |
| S2 | **HIGH** | Manual dive pressure data loss on iCloud merge (B2) undermines safety log integrity |
| S3 | **MEDIUM** | Runtime alarm may not fire at user-expected 30 min until Alarm screen opened once (H5) |
| S4 | **MEDIUM** | Companion disclaimer fatigue may cause users to dismiss without reading (H1) |
| S5 | **LOW** | Ascent + depth limit UX is strong; haptics respect toggle |
| S6 | **LOW** | GPS labeled with fix source on detail — good surface-only honesty |

**Not in MAIN (expected):** Snorkeling return-to-entry, Apnea countdown safety — experimental only.

---

## 7. Recommended Priority Order

### Immediate (pre-release / next patch)

1. Remove or clearly label **mock planner row** (B3).  
2. Wire **Logbook → edit manual dive** (B1).  
3. Extend **`DiveSessionMerge`** for manual metadata (B2).  
4. Align **runtime alarm** default Watch UI ↔ `DiveManager` (H5).  
5. Show **manual pressures** in dive detail or hide block (H2).

### Pre-release

6. Persist or gate **launch companion disclaimer** (H1).  
7. Implement or remove **PlanResultView share** affordance (H3).  
8. Expose **resetPairingTrust** in More (H4).  
9. Apply **unit preference** to Watch Live/Log or update Settings copy (H6).

### Post-release

10. Register remaining **App Intents** in Shortcuts catalog.  
11. Delete or wire **GPS full-screen views**.  
12. iCloud error surfacing; Analysis CSV when logbook populated.  
13. Complete i18n pass (Settings shortcut help, hardcoded IT).

---

## 8. Code Impact Report

| Issue cluster | Impact size | Type |
|---------------|-------------|------|
| B1 Manual edit navigation | **Small** | Add `NavigationLink` or edit from detail |
| B2 DiveSessionMerge fields | **Small** | Add fields to merge initializer |
| B3 Planner mock row | **Small** | Delete one `tableRow` line |
| H1 Launch disclaimer persist | **Small** | `@AppStorage` flag |
| H5 Runtime alarm default | **Small** | Align default in `DiveManager` to 30 or write key on launch |
| H6 Units on Live | **Medium** | Pass `DIRUnitPreference` into formatters across Watch views |
| H3 Share export planner | **Medium** | Wire `ShareLink` + export builder |
| H4 resetPairingTrust UI | **Small** | Button in More sync card |
| M1 Dead GPS views | **Small** | Delete files or connect |
| iCloud silent failures | **Medium** | User-visible error state |

**No architectural blocker** identified for MAIN UX; issues are mostly wiring, copy, and merge completeness.

---

## Sync Audit (Watch ↔ iPhone)

| Flow | Entry point | User feedback | Gaps |
|------|-------------|---------------|------|
| Watch → iPhone dive | Auto after save | Settings status rows | Pending until peer secret |
| iPhone → Watch dive | More “push” | `lastMessage` | Queue when unreachable |
| Tombstones | Delete on either side | Count in status | User may not understand |
| Units | More / Watch Settings | Context merge | Live UI not updated |
| Photos | More PhotosPicker | `lastMessage` | Tab may stay hidden |
| Conflicts | More card | Use Watch / Keep Local | Keep local doesn’t re-push |

---

## Error / Edge Case Audit

| Condition | Watch | iOS |
|-----------|-------|-----|
| GPS denied | Status in Settings + Live copy | Route/ GPS in analysis may be empty |
| Depth unavailable | Manual dive path + sensor error | N/A |
| Watch disconnected | Sync status strings | More sync card |
| Export fails | Error text + notify haptic | Orange error in detail |
| Import fails | N/A | CSV panel message |
| Permissions denied | Location in Settings | Photo picker fails with message |

---

## Design / UX Consistency

| Area | Assessment |
|------|------------|
| Typography / color | Consistent premium dark + cyan/green/yellow/red |
| Terminology | **BUSSOLA** used on Watch; avoid COMPASSO |
| Watch vs iOS | Parallel legal/disclaimer; tab metaphors differ (Crown vs bottom tabs) |
| Units | **Inconsistent** — pickers exist but many screens hardcode metric |
| Planner vs Logbook | Planner positioned first on iOS; honest about indicative planning in copy |

---

## Assumptions

- Audit is **static**; runtime behavior on real Ultra hardware may differ (submersion, WC pairing).  
- Experimental code paths were not executed.  
- PR #8/#9 not merged; MAIN excludes experimental views per `project.yml`.

---

*End of report — DIR DIVING © Federico Lombardo di Monte Iato 2026*
