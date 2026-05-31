# DIR DIVING — MAIN Branch UX / Interaction / Feature Accessibility Audit

**Date:** 2026-05-24  
**Branch:** `main`  
**HEAD:** `8a4d10e` (*fix: address main readiness audit blockers*)  
**Audit type:** Read-only — **PRE-MODIFICATION** (no code changes in this pass)  
**Scope:** Apple Watch MAIN + iOS Companion MAIN (`project.yml` excludes experimental sources)  
**Method:** Static review of SwiftUI navigation, settings, services, and build verification on macOS  
**Benchmarks:** `Docs/ReferenceUI/Watch_LIVE_reference.png`, `Docs/ReferenceUI/iOS_Companion_reference.png`

---

## 9. Final Summary

| Dimension | Estimate | Notes |
|-----------|----------|-------|
| **UX / feature accessibility** | **~82%** | Most MAIN flows reachable; gaps in tones, iOS alarms UI, per-session sync UI, planner metric-only |
| **Navigation completeness** | **~88%** | Clear tab/stack structure; Watch redirects during dive; no orphan MAIN screens |
| **Settings completeness** | **~78%** | Watch ascent/alarms/units/haptics strong; brightness/export prefs informational only; iOS alarms not editable |
| **Hardware interaction** | **~75%** | Crown paging + Crown steppers; 7 App Intents; **no** direct side-button mapping |
| **Haptics / safety feedback** | **~85%** | Gated toggle; ascent/depth/confirm paths; no stopwatch-specific pattern |
| **Sync UX** | **~80%** | Status + conflicts + retry/clear on Watch; iOS push/reset; device QA still required |
| **Compile / run readiness** | **~0%** (this snapshot) | **BUILD FAILED** — `AscentRateSettingsView.swift:41` missing `return` in `limitControl` |

| Release posture (static): | Verdict |
|---------------------------|---------|
| Internal QA after compile fix | **Conditional** |
| Average user | **Mostly** — pending device depth QA (R1) |
| TestFlight | **Blocked** until build green + Ultra QA |
| App Store | **Not yet** |

---

## 1. Feature Inventory

Legend: **Y** yes · **P** partial · **N** no · **—** not in MAIN target

### Apple Watch MAIN

| Feature | Impl | Reachable | Complete | Notes | Severity |
|---------|------|-----------|----------|-------|----------|
| Legal onboarding (first launch) | Y | Y | Y | `WatchLegalOnboardingView` gates `ContentView` | — |
| Launch companion disclaimer | Y | Y | Y | **Every cold launch** via `CompanionDisclaimerAcceptance` (session flag, not persisted revision) | — |
| Mode selection | Y | N* | — | Hidden: `hasMultipleStableModes = false` | LOW |
| Live dive (depth, TTV, runtime, gauge) | Y | Y | P | Unit-aware live; submersion device-dependent | MED* |
| Manual dive start/end | Y | Y | Y | Panel when automation unavailable + App Intents | — |
| Stopwatch START/STOP/RESET | Y | Y | Y | On-screen; no long-press guard on RESET | LOW |
| Ascent warning + gauge | Y | Y | Y | Inline banner; haptic loop while active | — |
| Depth safety 35/38/40 m | Y | Y | Y | Banners + `DepthLimitHapticCoordinator` | — |
| BUSSOLA / SET/CLEAR bearing | Y | Y | Y | Toast + haptic; in-dive depth uses unit formatter | — |
| Dive log list + detail | Y | Y | Y | Delete confirm; export; **list depth unit-aware** (`WatchDepthFormatting`) | — |
| Export Subsurface CSV | Y | Y | Y | Detail + latest from list; share + error text | — |
| User images viewer | Y | P | P | Tab only if `imageStore` non-empty | LOW |
| Settings hub | Y | Y | P | Ascent/alarms/legal/info/shortcuts; some rows disabled in-dive | — |
| Ascent rate limits (ASC SET) | Y | Y | P | Crown steppers; **build broken** in `AscentRateSettingsView` | **CRITICAL** |
| Alarm thresholds | Y | Y | Y | `AlarmSettingsView`; Crown/touch; runtime uses `WatchAlarmDefaults` | — |
| Units metric/imperial | Y | Y | P | Picker + WC sync; applied Live/Log/Compass depth | — |
| Language IT/EN | Y | Y | Y | Settings picker | — |
| Haptics toggle | Y | Y | Y | `dirdiving_watch_haptics_enabled` | — |
| Audio tones | N | — | — | Informational copy only | LOW |
| Brightness / Always On | N | — | — | watchOS-managed; info only | — |
| Watch ↔ iPhone sync | Y | Y | P | Pending/sent/failed counts; retry/clear queue in Settings | MED |
| App Shortcuts (7 intents) | Y | P | P | Catalog present; **not device-verified** in this pass | MED |
| Side button dive control | N | — | — | Documented in `WatchShortcutHelpView` | — |
| Snorkeling / Apnea / Buddy | — | — | — | Excluded from target | — |

\*Device/entitlement for auto depth.

### iOS Companion MAIN

| Feature | Impl | Reachable | Complete | Notes | Severity |
|---------|------|-----------|----------|-------|----------|
| Legal onboarding | Y | Y | Y | Scroll-gated disclaimer | — |
| Launch companion disclaimer | Y | Y | Y | Every launch (session-based) | — |
| Planner + safety ack | Y | Y | Y | **Persisted** `@AppStorage` `PlannerSafetyAcknowledgment` | — |
| Plan result (PIANO/BÜHLMANN/GRAFICI) | Y | Y | P | Tabs; planner math metric internally | MED |
| Logbook + search | Y | Y | Y | Grouped list; **depth card uses `Formatters.depth`** | — |
| Manual dive add/edit | Y | Y | Y | Toolbar + `ManualDiveEditorView`; detail refresh | — |
| Dive detail (tabs, chart, GPS, export) | Y | Y | Y | CSV export + share; edit manual only | — |
| Analysis (metrics, charts, import) | Y | Y | Y | Empty-state actions; localized | — |
| Equipment checklist | Y | Y | P | CRUD; some **hardcoded IT** strings | LOW |
| More / settings | Y | Y | Y | Units, language, sync, cloud, demo, legal | — |
| Watch sync + conflicts | Y | Y | P | Push to Watch, reset pairing, conflict card | MED |
| iCloud backup | Y | Y | P | Manual sync; **decode error surfaced** (`lastDecodeError`) | — |
| Photo → Watch | Y | Y | P | `WatchPhotoTransferPanel` | LOW |
| CSV import/export | Y | Y | Y | `CSVImportPanel` in Logbook/More/Analysis | — |
| Demo logbook (reviewer) | Y | Y | Y | Toggle in More | — |
| iOS alarms / haptics prefs | N | — | — | Copy: local to Watch only | LOW |
| Push notifications | N | — | — | No `UserNotifications` | LOW |
| GPX/KML | N | — | — | Not in MAIN | — |
| Explore / Buddy experimental | — | — | — | Excluded from target | — |

---

## 2. Navigation Map

### Watch MAIN

```
[Legal onboarding if required]
  → ContentView (vertical TabView / Crown pages)
       → [ModeSelection] (hidden unless hasMultipleStableModes)
       → Live Dive (default)
       → BUSSOLA (CompassView)
       → Settings
            → AscentRateSettingsView (ASC SET)
            → AlarmSettingsView
            → WatchLegalSafetyView
            → WatchShortcutHelpView
            → InfoView
       → [UserImages] (only if images in bundle/store)
       → Dive Log
            → DiveDetailView → Export / Delete confirm
fullScreenCover: launch companion disclaimer (each launch)
```

**During active dive:** Crown page change to Settings/Images **blocked** (redirect to Live); allowed: Live, BUSSOLA, Dive Log.

**Dead ends:** None proven. **Orphan:** Mode Selection dormant. **Hidden:** User Images tab when empty.

### iOS MAIN

```
[Legal onboarding if required]
  → TabView
       → Planner → PlanResultView (navigationDestination)
       → Logbook → DiveDetailView → ManualDiveEditorView
       → Analysis (empty → import/sync/logbook actions)
       → Equipment (reset confirm)
       → More → Legal push; sync/cloud/export cards
fullScreenCover: launch companion disclaimer
```

**Dead ends:** None static. **No deep links** observed.

---

## 3. Settings Report

### Watch (`SettingsView` + children)

| Setting | UI | Persisted | Applied | Synced to iOS |
|---------|-----|-----------|---------|---------------|
| Units | Y | Y | Y (Live/Log/Compass) | Y (`applicationContext`) |
| Language | Y | Y | Y | N |
| Haptics | Y | Y | Y | N |
| Ascent limits | Y | Y | Y | N |
| Alarm toggles/thresholds | Y | Y | Y | N |
| Legal & Safety | Y | Y (legal store) | Gate | N |
| GPS / depth / sync status | Y | — | Read-only | N |
| Export | Info row | — | Export from Log | N |
| Brightness / tones | Info | — | N/A | N |
| Clear sync queue | Y | — | Action | N |

**Inaccessible during dive:** Ascent settings, Alarms, unit/language pickers (disabled) — **intentional**.

**Stale copy:** Row “sync bidirezionale planned” vs units already sync.

### iOS (`MoreView` + per-screen)

| Setting | UI | Persisted | Applied | Synced |
|---------|-----|-----------|---------|--------|
| Units | Y | Y | Y (formatters) | Y (WC) |
| Language | Y | Y | Y | N |
| Planner safety ack | Y | Y | Gates planner | N |
| Watch sync / reset pairing | Y | — | Runtime | Partial |
| iCloud sync | Y | — | On demand | iCloud |
| Demo logbook | Y | Y | Y | N (demo not pushed) |
| Alarms / haptics | N | — | Documented Watch-local | N |
| Notifications | N | — | — | N |

**Backend without UI:** None critical found in MAIN scope.

---

## 4. Hardware Interaction Report

| Control | Watch MAIN | Notes |
|---------|------------|-------|
| Digital Crown — vertical paging | Y | `.tabViewStyle(.verticalPage)` on `ContentView` |
| Digital Crown — value steppers | Y | `AlarmSettingsView`, `AscentRateSettingsView` (when buildable) |
| Touch — primary actions | Y | Large bordered buttons on Live |
| Side button | **N** | No API mapping; help text + App Intents |
| Long press | **N** | Not used for RESET guard |
| Swipe | Implicit | TabView paging only |

### App Intents (`ActionButtonIntents.swift`)

1. Toggle stopwatch  
2. Reset stopwatch  
3. Start manual dive  
4. End manual dive  
5. Set bearing  
6. Clear bearing  
7. Acknowledge alarm  

**Gap:** Intents require Shortcuts/Action Button configuration by user; not discoverable from Live UI alone.

### Haptic events (gated by `dirdiving_watch_haptics_enabled`)

| Event | Haptic | Notes |
|-------|--------|-------|
| Ascent over limit | Failure + repeat loop | `DiveLiveView` + `HapticService` |
| Depth 35/38/40 | Notification/failure/retry | `DepthLimitHapticCoordinator` |
| Stopwatch start/reset | confirm | `DiveManager` |
| GPS saved | confirm | `DiveManager` |
| Bearing SET/CLEAR | confirm | `CompassView` / intents |
| Alarm dismiss | notify | `DiveManager` |
| Export success/fail | confirm/notify | Log/detail |
| Dive start/stop (manual) | confirm | `DiveManager` |
| Stopwatch only | — | No distinct pattern vs generic confirm |
| Audio tones | **None** | By design (informational) |

**Risks:** Duplicate ascent haptics throttled but still dense; no tones for users expecting sound on phone.

---

## 5. UX Blockers

| ID | Title | Platform | Severity | User impact | Fix type |
|----|-------|----------|----------|-------------|----------|
| UX-CR-01 | **Watch build fails** | Watch | **CRITICAL** | Cannot run app | Add `return` in `AscentRateSettingsView.limitControl` | Small |
| UX-H-01 | Depth automation requires Ultra + entitlement | Watch | **HIGH** | No auto depth without hardware/approval | QA + Apple portal | Process |
| UX-H-02 | Side button not mapped to dive | Watch | **MED** | Users expect hardware start/stop | Document + Shortcuts only (done) | Docs/UX |
| UX-H-03 | App Intents not verified on device | Watch | **MED** | Shortcuts may fail silently | Device QA | QA |
| UX-M-01 | User Images tab hidden when empty | Watch | **LOW** | Low discoverability | Onboarding hint | Small UI |
| UX-M-02 | Settings disabled in-dive without inline explanation on row | Watch | **LOW** | Confusion why ASC SET greyed | Copy on row | UI-only |
| UX-M-03 | Planner metric-only vs global units | iOS | **MED** | Imperial users see m/bar in planner | Label or convert display | UI-only |
| UX-M-04 | Equipment / partial planner IT strings | iOS | **LOW** | EN users see Italian | i18n keys | UI-only |
| UX-M-05 | No per-dive sync delivery UI | Both | **LOW** | Only aggregate counters | Future enhancement | Medium |
| UX-M-06 | Stale “sync planned” copy on Watch | Watch | **LOW** | Trust | Update string | UI-only |
| UX-M-07 | RESET stopwatch without long-press guard | Watch | **LOW** | Accidental reset | Optional long-press | Small |

---

## 6. Safety Issues

| Issue | Severity | Detail |
|-------|----------|--------|
| NOT a dive computer | — | Stated in legal, onboarding, More, planner |
| TTV not decompression | LOW | Clarified on iOS detail |
| GPS surface-only | — | Labels fix/fallback/no-fix |
| Ascent banner non-blocking | — | Depth/gauge remain visible |
| Launch disclaimer each session | — | Implemented (`dismissedThisLaunch`) |
| Silent iCloud decode | — | **Fixed** — orange text in More |
| Missing phone notifications | LOW | No UNUserNotificationCenter |
| Accidental stopwatch reset | LOW | No confirmation on RESET |
| Build failure blocks safety QA | **CRITICAL** | Cannot validate haptics on device until compile fixed |

---

## 7. Recommended Priority Order

### Immediate (before any QA)

1. **UX-CR-01** — Fix `AscentRateSettingsView` compile error  
2. Run `xcodegen generate` + Watch + iOS builds  
3. Simulator smoke: onboarding → Live → BUSSOLA → Settings → Log → export  

### Pre-release

4. **UX-H-01** — Ultra depth/submersion device QA (`Docs/TESTFLIGHT_ENTITLEMENT_AND_DEVICE_QA_20260523.md`)  
5. **UX-H-03** — App Intents on physical Watch  
6. Watch ↔ iPhone sync + conflict resolution on paired devices  
7. **UX-M-03** — Planner units honesty or conversion  
8. i18n pass Equipment + planner leftovers  

### Post-release

9. Per-session sync delivery UI  
10. Long-press RESET guard  
11. Optional GPX export  
12. iOS notification policy decision  

---

## 8. Code Impact Report

| Category | Count | Examples |
|----------|-------|----------|
| **Small UI fix** | 6 | Stale strings, Equipment i18n, settings hint copy |
| **Small functional** | 1 | AscentRateSettingsView `return` |
| **QA / device** | 4 | Depth entitlement, intents, sync, screenshots |
| **Medium** | 2 | Planner unit presentation, sync delivery UI |
| **Architectural** | 0 | None required for UX accessibility in MAIN |

---

## Design / UX Consistency (brief)

| Area | Assessment |
|------|------------|
| Watch visual | Black/neon aligned with reference; premium panels |
| iOS visual | Dark marine + cyan; `DIRTheme` consistent |
| Terminology | **BUSSOLA** used; avoid COMPASSO |
| Watch vs iOS tabs | Planner-first iOS vs Live-first Watch — intentional |
| Mixed IT/EN | Reduced on Logbook/Detail/Analysis; Planner/Equipment remain |
| Paradigm | Watch vertical pages vs iOS tab bar — acceptable platform split |

---

## Sync Audit (summary)

| Path | UI feedback | Gap |
|------|-------------|-----|
| Watch → iPhone dives | Pending/sent/failed in Settings | No per-session list |
| iPhone → Watch push | Button in More | Requires pairing |
| Conflicts | Card in More with resolution | Manual |
| Tombstones | Implemented in codec/store | — |
| Units | WC `applicationContext` | — |
| Photos | File transfer panel | Paired Watch required |
| iCloud | Status + decode error | Conflict resolver limited |
| Offline | `transferUserInfo` fallback | User sees counts not queue detail |

---

## Error / Edge Cases (summary)

| Condition | Watch | iOS |
|-----------|-------|-----|
| No GPS | Status row + copy | Detail “not available” |
| No depth sensor | Manual panel + error banner | N/A |
| WC disconnected | Settings sync strip | More status message |
| Export fail | Text + haptic | Orange error text |
| iCloud decode fail | — | Orange `lastDecodeError` |
| Empty logbook | Empty card | Empty + hints |
| Permissions denied | GPS status row | Photo picker errors |

---

## Experimental Dependency Check

- `project.yml` excludes Apnea/Snorkeling/Buddy/Explore from MAIN targets.  
- `App/DIRDivingApp.swift` and `iOSApp/DIRDivingiOSApp.swift` **do not import** experimental modules.  
- Experimental files remain in tree but are not linked to MAIN builds.

---

## Validation Log (this audit)

| Check | Result |
|-------|--------|
| `git branch` | `main` @ `8a4d10e` |
| `xcodegen generate` | PASS |
| Watch `xcodebuild` | **FAIL** — `AscentRateSettingsView.swift:41` |
| iOS `xcodebuild` | **FAIL** (same root cause likely blocks workspace) |
| Static navigation review | PASS |
| Experimental imports in MAIN entry | None |

---

**Downloadable Word report:** [`MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524_CURRENT_PRE_MODIFICATION.docx`](MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524_CURRENT_PRE_MODIFICATION.docx)  
**Generate:** `python3 Docs/generate_main_branch_ux_interaction_accessibility_audit_20260524_pre_mod_docx.py`
