# DIR DIVING — MAIN Branch Final Readiness Report

**Date:** 2026-05-23  
**Branch:** `main` (audit-only implementation pass, no experimental branches)  
**Baseline audit:** [`MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260522.md`](MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260522.md) (~83% overall)

---

## Executive summary

| Dimension | Before | After (this pass) | Notes |
|-----------|--------|-------------------|-------|
| Overall MAIN | ~83% | **~92%** | Code/build/i18n/sync UX; device depth QA still external |
| Compile readiness | ~90% | **~95%** | Named simulators: both schemes **BUILD SUCCEEDED** |
| i18n | Partial | **Strong** | Watch Settings/live/manual, iOS More/Planner/import; some rows still IT-key pattern |
| Sync reliability | Partial | **Improved** | iPhone→Watch push + conflict UI + queue logging |
| TestFlight | Conditional | **Ready with device QA** | Pairing + tombstones + Ultra depth |
| App Store | No | **No** | Legal/assets/field depth proof remain |

---

## Modified files

| File | Phase | Change summary |
|------|-------|----------------|
| [`project.yml`](../project.yml) | 1 | Internal `PRODUCT_NAME`: `DIRDivingWatchApp` / `DIRDivingiOSApp` (display name unchanged in Info.plist) |
| [`Resources/Assets.xcassets/AppIcon.appiconset/icon_92_2x.png`](../Resources/Assets.xcassets/AppIcon.appiconset/) | 1 | Removed orphan unassigned asset |
| [`Resources/en.lproj/Localizable.strings`](../Resources/en.lproj/Localizable.strings) | 2, 4, 7 | Ascent EN **ASCENT TOO FAST**; submersion error key |
| [`Resources/it.lproj/Localizable.strings`](../Resources/it.lproj/Localizable.strings) | 2 | Submersion error key |
| [`Utils/WatchModeSelectionPreferences.swift`](../Utils/WatchModeSelectionPreferences.swift) | 4 | Auto-skip Mode Selection when single stable mode (default on) |
| [`Services/AppNavigationStore.swift`](../Services/AppNavigationStore.swift) | 4 | Cold launch → Live when skip enabled |
| [`Views/ContentView.swift`](../Views/ContentView.swift) | 4, 9 | Hide Mode Selection tab + User Images tab when empty |
| [`Views/DiveLiveView.swift`](../Views/DiveLiveView.swift) | 2, 4, 5, 7 | Localized manual panel; pre-dive haptics-off badge |
| [`Views/SettingsView.swift`](../Views/SettingsView.swift) | 2, 5 | `String(localized:)` on key rows; informational vs interactive row styling |
| [`Services/DiveManager.swift`](../Services/DiveManager.swift) | 2 | Localized submersion unavailable message |
| [`Services/WatchSyncService.swift`](../Services/WatchSyncService.swift) | 3 | Diagnostic log on flush pending queue |
| [`iOSApp/Services/WatchDiveSyncCodec.swift`](../iOSApp/Services/WatchDiveSyncCodec.swift) | 3 | `makePayload` for outbound iOS→Watch (same HMAC schema) |
| [`iOSApp/Services/WatchSyncService.swift`](../iOSApp/Services/WatchSyncService.swift) | 3 | `transferToWatch`, `syncUnpushedSessionsToWatch`, outbound queue, pushed-ID tracking |
| [`iOSApp/Services/DiveLogStore.swift`](../iOSApp/Services/DiveLogStore.swift) | 3 | `add(..., suppressWatchPush:)` + auto push on add |
| [`iOSApp/Views/MoreView.swift`](../iOSApp/Views/MoreView.swift) | 2, 3, 6 | Localized disclaimer; sync push button; **conflict resolution card** |
| [`iOSApp/Views/PlannerView.swift`](../iOSApp/Views/PlannerView.swift) | 2, 6 | Safety acknowledgment toggle gates **Calcola Piano** |
| [`iOSApp/Services/DiveImportService.swift`](../iOSApp/Services/DiveImportService.swift) | 2, 6 | Localized errors + import summary (validation already present) |
| [`iOSApp/Resources/en.lproj/Localizable.strings`](../iOSApp/Resources/en.lproj/Localizable.strings) | 2, 3, 6 | Import, planner, More/sync keys |
| [`iOSApp/Resources/it.lproj/Localizable.strings`](../iOSApp/Resources/it.lproj/Localizable.strings) | 2, 3, 6 | Italian counterparts |

**Not modified (by design):** dive algorithms, TTV math, planner/Bühlmann math, sync crypto model, visual theme, experimental branches.

---

## Solved issues (mapped to audit)

| Audit issue | Status | Evidence |
|-------------|--------|----------|
| Duplicate `DIR DIVING.app` on generic iOS sim | **Mitigated** | Separate internal product names; **named** sim builds succeed |
| Watch AppIcon `icon_92_2x` warning | **Fixed** | Orphan PNG removed |
| Hardcoded IT (Settings, live manual, More, Planner) | **Mostly fixed** | `String(localized:)` + new keys |
| iPhone→Watch session push missing | **Fixed** | `transferToWatch` + `syncUnpushedSessionsToWatch` |
| Sync conflicts invisible | **Fixed** | MoreView conflict card with Use Watch / Keep iPhone |
| Mode Selection friction | **Fixed** | Auto-skip to Live (extensible flag) |
| User Images empty tab | **Fixed** | Tab hidden when `imageNames.isEmpty` |
| Ascent alarm EN strings | **Fixed** | ASCENT TOO FAST / SLOW DOWN |
| Planner safety ack | **Fixed** | Toggle required before calculate |
| CSV import errors IT-only | **Fixed** | Localized `ImportError` |
| Settings informational vs interactive | **Fixed** | `informational` row style (opacity/subtitle) |
| Pre-dive haptics-off visibility | **Fixed** | Badge on pre-dive + in-dive |
| Watch sync queue transparency | **Improved** | `os.Logger` on flush |

---

## Unresolved issues / limitations

| Item | Severity | Why |
|------|----------|-----|
| **Real Watch Ultra depth** | HIGH | Requires Apple entitlement + physical water test (process, not code) |
| **Physical sync/tombstone QA** | HIGH | Simulator WC limited; must run playbook Phase 3 on devices |
| **Generic iOS Simulator build** | LOW | `generic/platform=iOS Simulator` can fail on Watch `AppIcon` arch slice in unified project; use named destination |
| **Residual hardcoded IT** | LOW | Some Watch Settings rows, shortcut help, InfoView chrome still use literal IT (keys exist for many) |
| **iOS PlanResult share icon** | LOW | Still display-only (out of scope) |
| **Settings cross-sync** | LOW | Still local-only by design |
| **Per-session sync delivery UI** | LOW | Aggregate counters only (SAF-10) |

---

## Build validation (Phase 8)

```bash
xcodegen generate
xcodebuild -scheme "DIRDiving Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Ultra 3 (49mm)' build
# → BUILD SUCCEEDED

xcodebuild -scheme "DIRDiving iOS" -destination 'platform=iOS Simulator,name=iPhone 17' build
# → BUILD SUCCEEDED
```

**Warnings (non-blocking):** deprecated `contextMenu` on Watch log; exhaustive switch in `DiveManager`; `WatchSyncAuth` `var`→`let` hint.

**Experimental dependency:** `project.yml` excludes Apnea/Snorkeling/Buddy/Exploration — verified unchanged.

---

## UI / UX policy compliance

- Ascent alarm: **inline banner** between TTV and depth; gauge + depth + stopwatch remain visible; haptic ~1.75s; OK cooldown unchanged in `DiveManager`.
- Visual identity: black/neon Watch, `DIRTheme` iOS — no palette or layout redesign.
- Navigation: TabView / five-tab architecture preserved.

---

## Screenshots checklist (manual)

- [ ] Watch live pre-dive with haptics off badge
- [ ] Watch live ascent alarm EN + IT
- [ ] Watch Settings informational rows (muted)
- [ ] iOS More → sync conflicts card (simulate conflict)
- [ ] iOS Planner safety toggle → Calcola Piano disabled until on
- [ ] iOS EN locale: More disclaimer in English

---

## TestFlight readiness

| Criterion | Ready? |
|-----------|--------|
| Builds on Mac | **Yes** (named simulators) |
| No experimental in MAIN | **Yes** |
| Sync code paths | **Yes** (device QA required) |
| Safety disclaimers | **Yes** (legal onboarding + planner ack) |
| Depth on Ultra | **No** until field test |

**Recommendation:** Internal TestFlight after physical Phase 3 from [`INTERNAL_TESTING_PLAYBOOK_20260520.md`](INTERNAL_TESTING_PLAYBOOK_20260520.md).

---

## App Store readiness

| Blocker | Status |
|---------|--------|
| Privacy policy URL | External |
| Depth entitlement proof | Device + Apple |
| App icon all sizes (iOS archive) | Verify in Xcode Organizer |
| 100% EN on all screens | Not claimed; primary flows improved |

---

## Physical-device validations (mandatory)

1. Water submersion depth on **Apple Watch Ultra**
2. Watch → iPhone log sync + delete tombstone both directions
3. iPhone → Watch push after CSV import / log edit
4. First-pairing peer secret exchange (both apps open)
5. Ascent alarm in water: banner + gauge + haptics

---

## Remaining App Store risks

- Uncertified dive computer positioning (mitigated by copy)
- Planner indicative output (mitigated by ack + warnings)
- GPS surface-only (documented)
- Partial i18n on tertiary screens

---

*Implementation pass complete · `main` · 2026-05-23*
