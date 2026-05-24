# DIR DIVING — MAIN Branch Complete Readiness Audit

**Date:** 2026-05-20  
**Branch:** `main`  
**Committed HEAD:** `db72dce` (*fix(main): targeted UX polish — gauge units, intents, detail refresh*)  
**Audit type:** Read-only — **no code changes**  
**Scope:** `DIRDiving Watch App` + `DIRDiving iOS` (MAIN targets only; experimental sources excluded per `project.yml`)  
**Visual benchmarks:** `Docs/ReferenceUI/Watch_LIVE_reference.png`, `Docs/ReferenceUI/iOS_Companion_reference.png`  
**Build workspace note:** Audit builds were run on the **current working tree**, which contains **uncommitted** changes (R2/R3/R4 WIP). See §A and §M.

---

## A. Branch Confirmed

| Check | Result |
|-------|--------|
| Current branch | **`main`** |
| Committed HEAD | **`db72dce`** |
| Remote sync | Verify before release (`git fetch`; prior audits reported in sync) |
| Uncommitted local changes | **Yes** — `PlannerSafetyAcknowledgment.swift` (new), `CloudSyncStore.swift`, `MoreView.swift`, `PlannerView.swift`, `DiveDetailView.swift`, `LogbookView.swift`, `AnalysisView.swift`, `Localizable.strings` (EN/IT) |
| Targets inspected | `DIRDiving Watch App`, `DIRDiving iOS` |
| `project.yml` | **Valid** — experimental Swift excluded from both MAIN targets |
| XcodeGen | **PASS** (`xcodegen generate`) |
| Watch build | **BUILD SUCCEEDED** (watchOS Simulator, Apple Watch Series 11 46mm) |
| iOS build | **BUILD SUCCEEDED** (iOS Simulator, iPhone 17) |
| Compile warnings | **1 non-blocking** — AppIntents metadata processor notes no AppIntents.framework on iOS target (expected; intents live on Watch) |
| Bundle IDs | iOS `com.egopfe.dirdiving.ios`; Watch `com.egopfe.dirdiving.ios.watch`; companion link via `WKCompanionAppBundleIdentifier` |
| Entitlements | Watch: iCloud KVS + CloudKit container + **water submersion**; iOS: iCloud KVS + CloudKit (no submersion — correct) |
| App Groups | **None** (by design; WC + signed payloads + KVS) |
| Experimental dependency in MAIN | **None** — Apnea/Snorkel/Buddy/Explore files excluded and not imported from MAIN entry points |
| Blocking TODO in MAIN Swift | **0** release blockers; `TODO(F11-followup)` in `WatchDiveSyncCodec.swift` (ack hardening, non-blocking) |
| Reference assets | **Present** at `Docs/ReferenceUI/` |

---

## B. Executive Summary

| Dimension | Committed `db72dce` | With local WIP (builds today) |
|-----------|---------------------|-------------------------------|
| **Overall readiness** | **~91%** | **~94%** |
| **Compile readiness** | **100%** | **100%** |
| **Apple Watch MAIN** | **~93%** | **~93%** |
| **iOS Companion MAIN** | **~90%** | **~93%** |
| **UX completeness** | **~93%** | **~95%** |
| **Safety readiness** | **~88%** | **~88%** |
| **UI vs reference** | **~88%** | **~90%** |

**Verdict snapshot (committed `db72dce`):** Ready to **compile** and **internal/TestFlight test**; **mostly** ready for an average user who owns a paired Apple Watch Ultra (or accepts manual dive). **Not** literal 100% for App Store without physical depth entitlement QA, metadata review, and closing R2–R4.

**Verdict snapshot (local WIP, not on `origin/main`):** R2 planner ack persistence, R3 iCloud decode surfacing, and R4 logbook/detail/analysis localization are implemented on disk and build clean — **re-audit after commit/push** to treat as shipped MAIN.

---

## C. Feature Inventory

Legend: **Y** yes · **P** partial · **N** no · **—** not in MAIN

### Apple Watch MAIN

| Feature | Impl | Reach | Usable | Complete | Notes | Sev |
|---------|------|-------|--------|----------|-------|-----|
| Legal onboarding | Y | Y | Y | Y | Hard gate `WatchLegalOnboardingView` | — |
| Companion disclaimer | Y | Y | Y | Y | Revision-gated overlay | — |
| Mode selection | Y | N | — | — | Hidden (`hasMultipleStableModes = false`) | LOW |
| Live dive dashboard | Y | Y | Y | Y | Matches reference layout (black/neon, depth hero, gauge) | — |
| Depth display | Y | Y | Y | P | Requires Ultra + submersion entitlement for auto depth | HIGH* |
| Runtime / TTV | Y | Y | Y | Y | TTV informational; labels localized | — |
| Stopwatch START/STOP/RESET | Y | Y | Y | Y | On-screen + 7 App Shortcuts | — |
| Avg / max depth | Y | Y | Y | Y | Unit preference (metric/imperial) | — |
| Temperature | Y | P | P | P | When sensor provides data | LOW |
| Ascent-rate gauge | Y | Y | Y | Y | Vertical gauge; ft/min when imperial | — |
| Ascent warning | Y | Y | Y | Y | Inline banner; depth/gauge remain visible | — |
| Depth safety 35/38/40 m | Y | Y | Y | Y | Banners + haptics | — |
| BUSSOLA / bearing | Y | Y | Y | Y | SET/CLEAR + intents | — |
| Dive log list | Y | Y | Y | Y | Empty state + load error banner | — |
| Dive detail | Y | Y | Y | Y | GPS fix source, export, delete confirm | — |
| GPS start/end | Y | Y | Y | Y | Live messaging + detail coordinates | — |
| Export Subsurface CSV | Y | Y | Y | Y | Per-dive + latest; ShareLink | — |
| User images viewer | Y | P | Y | P | Tab only when images exist | LOW |
| Settings hub | Y | Y | Y | Y | Ascent, alarms, units, legal, shortcut help, info | — |
| Alarms (runtime/depth/battery/ascent) | Y | Y | Y | Y | Persisted `@AppStorage` | — |
| Units metric/imperial | Y | Y | Y | Y | Live, log, gauge labels | — |
| Haptics | Y | Y | Y | Y | Global toggle; safety events gated | — |
| Tones / sounds | N | — | — | — | Settings row informational only | — |
| Auto dive start/stop | Y | P | P | P | `CMWaterSubmersionManager`; sim limited | HIGH* |
| Side button dive control | N | — | — | — | Documented; App Intents / on-screen only | — |
| Snorkeling / Apnea / Buddy | — | — | — | — | Excluded from MAIN target | — |

\*Hardware/entitlement — not a compile blocker.

### iOS Companion MAIN

| Feature | Impl | Reach | Usable | Complete | Notes | Sev |
|---------|------|-------|--------|----------|-------|-----|
| Legal onboarding | Y | Y | Y | Y | Scroll-gated acceptance | — |
| Companion disclaimer | Y | Y | Y | Y | `CompanionDisclaimerAcceptance` persisted | — |
| Logbook | Y | Y | Y | Y | Search, grouping, CSV import, manual add | — |
| Logbook thumbnails | N | — | — | — | Reference shows photos; MAIN list has no thumbnails | LOW |
| Manual dive edit | Y | Y | Y | Y | From detail; refresh after save (`db72dce`) | — |
| Dive detail tabs | Y | Y | Y | Y | Summary / charts / details | — |
| Charts (depth profile) | Y | Y | Y | Y | Swift Charts | — |
| Planner | Y | Y | Y | Y | Safety ack gates calculate | — |
| Planner ack persistence | P | Y | Y | P | **Session-only @ `db72dce`**; **WIP: `@AppStorage`** | MED |
| Plan result + Bühlmann | Y | Y | Y | P | Indicative model; disclaimers present | MED |
| Analysis | Y | Y | Y | Y | Metrics, charts, gas/route summaries | — |
| Equipment checklist | Y | Y | Y | Y | CRUD; some IT literals | LOW |
| More / settings | Y | Y | Y | Y | Units, sync, cloud, demo, legal | — |
| Watch sync | Y | Y | Y | P | Signed codec; conflict UI in More | MED |
| iCloud backup (KVS) | Y | Y | P | P | Merge logic; **decode errors silent @ `db72dce`**; **WIP surfaces error** | MED |
| Units ↔ Watch | Y | Y | Y | Y | `applicationContext` | — |
| Photo → Watch | Y | Y | P | P | Paired Watch required | LOW |
| CSV export (Subsurface) | Y | Y | Y | Y | Per dive; share sheet | — |
| GPX/KML / .ssrf | N | — | — | — | Reference marketing only; CSV only in MAIN | — |
| iOS notifications / alert sounds | N | — | — | — | No UNUserNotificationCenter | LOW |
| Demo logbook (reviewer) | Y | Y | Y | Y | Toggle in More; excluded from WC push | — |
| Explore / Buddy experimental | — | — | — | — | Excluded from iOS target | — |
| Localization (main tabs) | P | Y | Y | P | **WIP:** logbook/detail/analysis keys; Planner/Equipment still mixed | LOW |

---

## D. Navigation Map

### Apple Watch (vertical `TabView`, Crown paging)

```
Launch → [Legal if required] → ContentView
  → Live (default when single mode)
  → BUSSOLA (CompassView)
  → Settings → Ascent | Alarms | Legal | Shortcut Help | Info
  → [User Images] (only if imageStore non-empty)
  → Dive Log → Detail → Export / Delete
fullScreenCover: companion disclaimer (revision-gated)
```

**Dead ends:** Legal gate (intentional). No orphan MAIN screens found.

### iOS (`TabView` — **order differs from reference mock**)

```
Launch → [Legal if required] → ContentView
  Planner → PlanResult (share)
  Logbook → DiveDetail → ManualDiveEditor (manual dives)
  Analysis (empty-state actions: import / sync / open logbook)
  Equipment
  More → Legal | Watch sync | Cloud | CSV import | Demo | Export info
fullScreenCover: companion disclaimer (revision-gated)
```

**Reference mock tab order:** Logbook → Analisi → Planner → Attrezzatura → Altro.  
**Shipped MAIN order:** Planner → Logbook → Analysis → Equipment → More.

**Dead ends:** None critical. Planner safety ack re-required each visit at `db72dce` (WIP fixes).

---

## E. UI Consistency Report

### Apple Watch (vs `Watch_LIVE_reference.png`)

| Area | Match | Issue | Severity | Recommended fix |
|------|-------|-------|----------|-----------------|
| Black canvas + neon palette | Strong | — | — | — |
| Large depth hero + ascent column | Strong | — | — | — |
| TTV / Runtime panel | Strong | "RunTime" English label in code | LOW | Localize key |
| Rounded panels / hairline borders | Strong | — | — | — |
| Stopwatch + START/STOP/RESET | Strong | — | — | — |
| Ascent alarm inline | Strong | Must not regress to full-screen block | — | — |
| Mixed IT/EN | Partial | Some keys IT-first | LOW | strings pass |
| 41mm / small Watch | Partial | `minimumScaleFactor` used; physical QA advised | MED | Device spot-check |

### iOS (vs `iOS_Companion_reference.png`)

| Area | Match | Issue | Severity | Recommended fix |
|------|-------|-------|----------|-----------------|
| Dark marine + cyan accents | Strong | `DIRTheme` throughout | — | — |
| Card layout + metric tiles | Strong | — | — | — |
| Tab bar | Partial | **Tab order** differs from reference | LOW | Product decision or reorder |
| Logbook rows | Partial | **No site thumbnails** in list | LOW | Optional image field |
| Dive detail hero image | Partial | No large hero photo block | LOW | Optional enhancement |
| Segment labels | Partial | IT strings @ `db72dce`; **WIP localizes** | LOW | Commit WIP |
| Planner / result screens | Strong | Dense technical UI; disclaimers present | — | — |
| Footer features (.ssrf) | Partial | Marketing shows .ssrf; app ships CSV | LOW | Update store copy |

**No generic SwiftUI default styling** on primary surfaces; custom `DIRTheme` / `DiveUI` components used.

---

## F. Settings Report

### Watch (`SettingsView` + child views)

| Setting | Reachable | Persisted | Applied | Synced to iOS |
|---------|-----------|-----------|---------|---------------|
| Units | Y | Y (`dirdiving_watch_units`) | Y (Live/Log/gauge) | Partial (WC context) |
| Language | Y | Y | Y | N |
| Haptics | Y | Y | Y (`HapticService`) | N |
| Ascent rate limits | Y | Y | Y | N |
| Alarm thresholds/toggles | Y | Y | Y | N |
| Legal / safety | Y | acceptance store | Read-only | N |
| Shortcut help | Y | — | Instructional | N |
| Display / Always-On | Info only | — | watchOS managed | N |
| Audio tones | Info only | — | Not implemented | N |

**Gaps:** No in-app brightness/always-on control (acceptable). Audio tones not implemented (documented).

### iOS (`MoreView` + Planner)

| Setting | Reachable | Persisted | Applied | Synced |
|---------|-----------|-----------|---------|--------|
| Units | Y | Y | Y (formatters) | Y (WC) |
| Language | Y | Y | Y (companion UI) | N |
| Demo logbook | Y | Y | Y | N (demo not pushed) |
| Watch sync / conflicts | Y | runtime | Y | — |
| Cloud sync | Y | KVS | On demand | iCloud |
| Planner safety ack | Y | **N @ db72dce** / **Y WIP** | Gates planner | N |
| Legal | Y | Y | Gate | N |

**Gaps:** Alarms/haptics on iOS called out as local-only (Watch owns dive alarms). No per-transfer WC delivery UI (aggregate status only).

---

## G. Haptics / Tones Report

### Watch (`HapticService`, `DepthLimitHapticCoordinator`)

| Event | Haptic | Settings-gated |
|-------|--------|----------------|
| Ascent over limit | Failure + repeat loop | Y |
| Depth/time/battery alarms | `warnIfNeeded` | Y |
| Manual dive start/stop | `confirm` | Y |
| GPS point saved | `confirm` | Y |
| Compass SET/CLEAR | `confirm` | Y |
| Export success/failure | confirm / notify | Y |
| Stopwatch start/stop/reset | Partial / light | Y |
| Log delete | Minimal / none | — |

**Tones:** Not implemented; Settings states audio not used underwater — **consistent with product choice**.

### iOS

| Feedback | Status |
|----------|--------|
| Haptics | N/A |
| Alert sounds | Not implemented |
| Push notifications | Not implemented |
| Sync/export/cloud errors | Text + color (WIP: orange decode text in More) |

---

## H. Hardware Controls Report

| Control | Status |
|---------|--------|
| Digital Crown | Vertical tab paging; scroll in lists |
| Side button | **Not mapped** to dive lifecycle |
| Action Button / Shortcuts | **7 App Intents** in `ActionButtonIntents.swift` / `DIRDivingAppShortcuts` |
| Long press | Not used for dive control |
| On-screen START/STOP/RESET | Primary reliable path |
| Shortcut Help | `WatchShortcutHelpView` in Settings (`db72dce`) |

**Safe:** No false claim of direct hardware dive start; TestFlight notes should match (`Docs/TESTFLIGHT_REVIEW_NOTES.md`).

---

## I. Sync Report

| Path | Status | User feedback |
|------|--------|---------------|
| Watch → iPhone dives | Y | Settings failed/pending counts |
| iPhone → Watch push | Y | More sync button |
| Tombstones / deletes | Y | Codec + store |
| Units preference | Y | `applicationContext` |
| Photos to Watch | Y | File transfer |
| Conflict resolution | Y | More card; keep-local re-push |
| Offline queue | Y | `transferUserInfo` fallback |
| Signed ack (HMAC) | Y | Legacy fallback documented |
| iCloud KVS merge | Y | More status string |
| iCloud decode failure | **Silent @ db72dce** / **Visible WIP** | MED |

**Not mock-only** for MAIN dive sync. Experimental buddy/explore sync not in MAIN.

---

## J. Export Report

| Format | Watch | iOS |
|--------|-------|-----|
| Subsurface CSV | Y | Y |
| GPX/KML | N | N |
| .ssrf | N | N |
| Share sheet | Y | Y |
| Failure UX | Message + haptic | Inline error text |

`SubsurfaceExportService` writes real temp CSV files; stale file cleanup >24h.

---

## K. Safety Report

| Item | Status |
|------|--------|
| NOT a certified dive computer | Legal, onboarding, More, planner copy |
| Planner indicative only | Acknowledgment + export disclaimers |
| TTV not NDL/TTS | Stated on iOS detail |
| Ascent warning | Visible; gauge remains |
| GPS honesty | Fix source labels (surface / fallback / no-fix) |
| Depth 35/38/40 m | Fixed thresholds |
| App Store risk | Submersion entitlement proof; planner marketing language; auto-dive claims |

**Blockers:** Physical validation on Apple Watch Ultra with water submersion entitlement (HIGH for marketing automatic dive).

---

## L. Error / Empty State Report

| Condition | Watch | iOS @ db72dce | iOS WIP |
|-----------|-------|---------------|---------|
| No dives | Log empty card | Logbook + Analysis empty actions | Same |
| No GPS | Settings + Live copy | Detail "Not available" | Same |
| No depth sensor | Manual dive panel | N/A | Same |
| WC disconnected | Settings sync strip | More status | Same |
| Sync fail | failedImportCount | lastMessage + conflicts | Same |
| Export fail | Text + haptic | Orange error | Same |
| iCloud decode fail | — | **Silent** | **Orange text in More** |
| Permissions denied | GPS status row | Photo picker errors | Same |
| Low battery | Alarm path | N/A on phone | Same |

No static crash paths identified; runtime QA still required.

---

## M. Bugs To Fix

| ID | Title | Platform | File/screen | Severity | User impact | Fix | Code impact |
|----|-------|----------|-------------|----------|-------------|-----|-------------|
| R1 | Physical depth/submersion QA | Watch | `DiveManager`, entitlement | **HIGH** | Auto dive unproven in sim | TestFlight on Ultra | QA / device |
| R2 | Planner safety ack not persisted | iOS | `PlannerView` | **MED** | Re-ack every visit @ `db72dce` | `@AppStorage` revision (**WIP on disk**) | Small |
| R3 | iCloud decode errors silent | iOS | `CloudSyncStore`, `MoreView` | **MED** | User thinks cloud OK | `lastDecodeError` UI (**WIP on disk**) | Small |
| R4 | Mixed IT/EN strings | iOS | Logbook, Detail, Analysis, Planner | **LOW** | EN users see IT | Localize (**WIP partial**) | UI-only |
| R5 | Tab order vs reference | iOS | `ContentView` | **LOW** | Planner-first vs mock Logbook-first | Reorder or accept | UI-only |
| R6 | Logbook thumbnails missing | iOS | `LogbookView` | **LOW** | Visual mismatch vs mock | Optional photos | Medium |
| R7 | User Images tab hidden until content | Watch | `ContentView` | **LOW** | Low discoverability | Onboarding hint | Small |
| R8 | iOS no notification/sound feedback | iOS | — | **LOW** | Silent phone sync | Optional UNNotification | Medium |
| R9 | F11 legacy ack fallback | Both | `WatchDiveSyncCodec` | **LOW** | Security hardening | Floor build follow-up | Small |
| R10 | Reference claims .ssrf export | Docs/marketing | — | **LOW** | Store expectation mismatch | Align metadata to CSV | Docs |

**No CRITICAL compile blockers.** R2–R4 have local fixes not yet on `origin/main`.

---

## N. Priority Roadmap

### 1. Must fix before compile/use
- **None** — both targets build.

### 2. Must fix before TestFlight
- **R1** Ultra depth + WC smoke test on hardware  
- Commit/push **R2–R4 WIP** (or re-verify on `db72dce` without them)  
- App icons / signing on release Mac  

### 3. Must fix before App Store
- **R1** + entitlement documentation  
- **R3** shipped (iCloud decode visibility)  
- Legal/metadata aligned with actual features (CSV only, no side-button dive start)  
- `Docs/TESTFLIGHT_REVIEW_NOTES.md` aligned with build  

### 4. Post-release
- **R4** full i18n (Planner, Equipment)  
- **R5–R6** UI polish vs reference  
- **R8–R9** security/export extras  
- GPX/KML export (documented backlog)

---

## O. Final Verdict

| Question | Committed `db72dce` | After committing local WIP |
|----------|----------------------|----------------------------|
| **Ready to compile?** | **YES** | **YES** |
| **Ready for internal test?** | **YES** | **YES** |
| **Ready for average user?** | **MOSTLY (~91%)** | **MOSTLY (~94%)** |
| **Ready for TestFlight?** | **YES** after R1 device QA | **YES** after R1 + commit WIP |
| **Ready for App Store?** | **CONDITIONAL** | **CONDITIONAL** (R1 + metadata) |
| **What blocks 100%?** | Hardware depth path, App Store review, R2–R4 on remote, reference/UI gaps, no iOS sounds | Primarily **R1** hardware QA and store/legal review |

---

## Prior MAIN fixes (landed on `db72dce`)

- `876bcd2` — UX audit batch: manual edit, merge metadata, planner mock row removal, disclaimer persistence, sync/conflict improvements, legal scroll gate, etc.  
- `db72dce` — Ascent gauge imperial labels, 7 App Shortcuts catalog, Watch shortcut help copy, dive detail refresh after manual edit.

---

**Downloadable report:** `Docs/MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260520.docx`  
**Generate:** `python3 Docs/generate_main_branch_complete_readiness_audit_20260520_docx.py`
