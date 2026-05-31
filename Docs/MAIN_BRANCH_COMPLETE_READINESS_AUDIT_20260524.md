# DIR DIVING — MAIN Branch Complete Readiness Audit

**Date:** 2026-05-24  
**Branch:** `main` @ `db72dce`  
**Audit type:** Read-only — no code changes  
**Scope:** DIRDiving Watch App + DIRDiving iOS (MAIN targets only)  
**Visual benchmarks:** `Docs/ReferenceUI/Watch_LIVE_reference.png`, `Docs/ReferenceUI/iOS_Companion_reference.png`  
**Prior audits:** UX audit `20260524`, targeted fixes `db72dce`, final readiness report

---

## A. Branch Confirmed

| Check | Result |
|-------|--------|
| Current branch | **`main`** @ `db72dce` |
| Sync with remote | **Up to date** with `origin/main` |
| Targets inspected | `DIRDiving Watch App`, `DIRDiving iOS` |
| `project.yml` | Valid; experimental sources **excluded** from MAIN |
| XcodeGen | **PASS** (`xcodegen generate`) |
| Watch build | **BUILD SUCCEEDED** (watchOS Simulator, Apple Watch Series 11 46mm) |
| iOS build | **BUILD SUCCEEDED** (iPhone 17 Simulator) |
| Compile warnings (sampled) | **None** in final build output |
| Bundle IDs | iOS `com.egopfe.dirdiving.ios`; Watch `com.egopfe.dirdiving.ios.watch` |
| Entitlements | Watch: iCloud KVS + **water submersion**; iOS: iCloud KVS |
| WC / iCloud | Coherent; shared KVS identifier; companion bundle linked |
| Experimental dependency | **None** — Snorkeling/Apnea/Buddy/Explore excluded from targets |
| Blocking TODO in MAIN Swift | **0** (one non-blocking `TODO(F11-followup)` in `WatchDiveSyncCodec.swift`) |

---

## B. Executive Summary

| Dimension | Readiness % | Notes |
|-----------|-------------|-------|
| **Overall readiness** | **~91%** | Strong MAIN product; not literal 100% until device QA + store polish |
| **Compile readiness** | **100%** | Both targets build clean in CI-like sim environment |
| **Apple Watch MAIN** | **~93%** | Core dive UX complete; hardware/submersion device-dependent |
| **iOS Companion MAIN** | **~92%** | Logbook/planner/sync solid; minor i18n + cloud UX gaps |
| **UX completeness** | **~94%** | Post-`876bcd2`/`db72dce` fixes closed prior audit blockers |
| **Safety readiness** | **~88%** | Disclaimers strong; planner remains indicative-only |
| **UI consistency (vs reference)** | **~90%** | Premium dark/neon Watch + marine cyan iOS; minor mixed-language labels |

**Verdict snapshot:** Ready to **compile** and **internal/TestFlight test**; **not** certifiable as 100% for an average user without real Ultra depth QA and App Store metadata review.

---

## C. Feature Inventory

Legend: **Y** = yes · **P** = partial · **N** = no · **—** = not in MAIN

### Apple Watch MAIN

| Feature | Impl | Reach | Usable | Complete | Notes | Sev |
|---------|------|-------|--------|----------|-------|-----|
| Legal onboarding | Y | Y | Y | Y | Hard gate | — |
| Companion disclaimer | Y | Y | Y | Y | Persisted via `CompanionDisclaimerAcceptance` | — |
| Mode selection | Y | N | — | — | Hidden (`hasMultipleStableModes = false`) | LOW |
| Live dive dashboard | Y | Y | Y | Y | Matches reference layout intent | — |
| Depth display | Y | Y | Y | P | Imperial units on Live; sensor needs Ultra | MED* |
| Runtime / TTV | Y | Y | Y | Y | TTV labeled informative | — |
| Stopwatch START/STOP/RESET | Y | Y | Y | Y | On-screen + Shortcuts | — |
| Avg / max depth | Y | Y | Y | Y | Unit preference applied | — |
| Temperature | Y | P | P | P | When sensor provides data | LOW |
| Ascent gauge | Y | Y | Y | Y | m/min or ft/min labels per units | — |
| Ascent alarm banner | Y | Y | Y | Y | Inline; depth/gauge remain visible | — |
| BUSSOLA / bearing | Y | Y | Y | Y | SET/CLEAR + intents | — |
| Dive log list | Y | Y | Y | Y | | — |
| Dive detail | Y | Y | Y | Y | Export + delete confirm | — |
| GPS start/end | Y | Y | Y | Y | Inline banner on Live; detail shows fix source | — |
| Export Subsurface CSV | Y | Y | Y | Y | Latest + per-dive + ShareLink | — |
| User images tab | Y | P | Y | P | Tab only if images exist | LOW |
| Settings hub | Y | Y | Y | Y | Ascent, alarms, units, legal, shortcuts help | — |
| Alarms | Y | Y | Y | Y | Runtime default aligned (30 min) | — |
| Info / battery / depth diag | Y | Y | Y | Y | Via `InfoView` push | — |
| Units metric/imperial | Y | Y | Y | Y | Live, Log, gauge labels | — |
| Haptics | Y | Y | Y | Y | Toggle; ascent/depth/alarms/confirm | — |
| Tones / sounds | — | — | — | — | Informational row only (by design) | — |
| Auto dive start/stop | Y | P | P | P | Submersion entitlement + hardware | HIGH* |
| Side button dive control | N | — | — | — | Documented; Shortcuts only | — |
| Snorkeling / Apnea / Buddy | — | — | — | — | Excluded from MAIN | — |

\*Device/entitlement — not a code compile blocker.

### iOS Companion MAIN

| Feature | Impl | Reach | Usable | Complete | Notes | Sev |
|---------|------|-------|--------|----------|-------|-----|
| Legal onboarding | Y | Y | Y | Y | Scroll gate fixed | — |
| Companion disclaimer | Y | Y | Y | Y | Persisted | — |
| Logbook | Y | Y | Y | Y | CSV import + manual add | — |
| Manual dive edit | Y | Y | Y | Y | From detail; refreshes after save | — |
| Dive detail / charts | Y | Y | Y | Y | Manual pressures when present | — |
| Planner input | Y | Y | Y | Y | Safety ack gates calculate | — |
| Plan result | Y | Y | Y | Y | Mock row removed; ShareLink summary | — |
| Bühlmann curve tab | Y | Y | Y | P | Indicative model; not certified | MED |
| Analysis | Y | Y | Y | Y | CSV import when logbook populated | — |
| Equipment checklist | Y | Y | Y | Y | CRUD | — |
| More / settings | Y | Y | Y | Y | Units, sync, cloud, demo, legal | — |
| Watch sync import/push | Y | Y | Y | P | Conflicts UI; trust reset exposed | MED |
| iCloud backup | Y | Y | P | P | KVS; silent decode possible | MED |
| Units + WC sync | Y | Y | Y | Y | Bidirectional `units` context | — |
| Photo → Watch | Y | Y | P | P | Needs paired Watch | LOW |
| CSV export | Y | Y | Y | Y | Subsurface per dive | — |
| GPX/KML export | N | — | — | — | Not in MAIN | — |
| Notifications / alert sounds | N | — | — | — | No UNUserNotificationCenter flow | LOW |
| Demo logbook | Y | Y | Y | Y | Reviewer toggle | — |
| Explore Lab / Buddy experimental | — | — | — | — | Excluded from target | — |

---

## D. Navigation Map

### Watch (vertical Crown `TabView`)

```
Launch → [Legal if required] → ContentView
  → Live (default)
  → BUSSOLA
  → Settings → Ascent | Alarms | Legal | Shortcut Help | Info
  → [User Images] (if any)
  → Dive Log → Detail → Export
fullScreenCover: companion disclaimer (revision-gated)
```

**Dead ends:** Legal gate (intentional). **No orphan screens** in MAIN after GPS full-screen views removed.

### iOS (`TabView`)

```
Launch → [Legal if required] → Tabs
  Planner → PlanResult (share)
  Logbook → DiveDetail → ManualDiveEditor
  Analysis (CSV import)
  Equipment
  More → Legal push | sync | cloud | import
fullScreenCover: companion disclaimer (revision-gated)
```

**Dead ends:** None critical. **Planner safety ack** resets each session (`@State`) — user must re-ack each visit.

---

## E. UI Consistency Report

### Apple Watch (vs `Watch_LIVE_reference.png`)

| Area | Match | Issue | Severity | Fix |
|------|-------|-------|----------|-----|
| Black canvas + neon palette | Strong | — | — | — |
| Large depth hero + gauge column | Strong | — | — | — |
| Rounded panels / hairline borders | Strong | — | — | — |
| Ascent alarm inline banner | Strong | Must not regress | — | — |
| Mixed IT/EN labels | Partial | Some hardcoded IT ("PROFONDITÀ", "CRONOMETRO") | LOW | Localize |
| Smaller Watch sizes | Partial | `minimumScaleFactor` used; physical spot-check advised | MED | QA on 41mm |

### iOS (vs `iOS_Companion_reference.png`)

| Area | Match | Issue | Severity | Fix |
|------|-------|-------|----------|-----|
| Dark marine + cyan accents | Strong | — | — | — |
| Tab bar + card layout | Strong | — | — | — |
| Charts / metric tiles | Strong | — | — | — |
| Tab/detail IT strings | Partial | "RIEPILOGO", "GRAFICI", "Genera CSV Subsurface" | LOW | Localize |
| Planner technical copy | Partial | Some IT in result tabs | LOW | i18n pass |

**No generic SwiftUI default styling** observed on primary surfaces; custom `DIRTheme` / `DiveUI` used throughout.

---

## F. Settings Report

### Watch (`SettingsView` + pushes)

| Setting | UI | Persisted | Applied | Synced |
|---------|-----|-----------|---------|--------|
| Units | Y | Y | Y (Live/Log/gauge) | Partial (WC to iOS) |
| Language | Y | Y | Y | N |
| Haptics | Y | Y | Y | N |
| Ascent limits | Y | Y | Y | N |
| Alarm thresholds | Y | Y | Y | N |
| Legal | Y | — | Read-only | N |
| Export | Info only | — | Export from Log | N |
| Display / Always-On | Info only | — | watchOS managed | N |
| Audio tones | Info only | — | Not implemented | N |
| Sync settings | Info (local) | — | Honest copy | N |

**Missing (acceptable):** User-configurable always-on; tone picker.

### iOS (`MoreView` + Planner ack)

| Setting | UI | Persisted | Applied | Synced |
|---------|-----|-----------|---------|--------|
| Units | Y | Y | Y (display) | Y (WC) |
| Language | Y | Y | Y (companion) | N |
| Demo logbook | Y | Y | Y | N |
| Cloud sync button | Y | — | On demand | iCloud |
| Watch sync / conflicts | Y | — | Runtime | Partial |
| Planner safety ack | Y | **Session only** | Gates form | N |
| Legal | Y | Y | Gate | N |

**Gaps:** Planner ack not persisted across launches; per-session WC delivery UI not exposed (aggregate status only).

---

## G. Haptics / Tones Report

### Watch (`HapticService`)

| Event | Haptic | Gated |
|-------|--------|-------|
| Ascent over limit | Failure + repeat | Y |
| Depth/time/battery alarms | `warnIfNeeded` | Y |
| Dive start/stop (manual) | `confirm` | Y |
| GPS confirmation | `confirm` | Y |
| Compass SET | `confirm` | Y |
| Export success/fail | confirm / notify | Y |
| Stopwatch | No dedicated pattern | — |
| Log delete | No | — |

**Tones:** Not implemented; Settings states audio not used underwater — **consistent**.

### iOS

| Feedback | Status |
|----------|--------|
| Haptics | **N/A** (iPhone) |
| Alert sounds | **Not implemented** |
| Push notifications | **Not implemented** |
| Sync/export errors | Text color + messages |

**Gap:** No audible iOS feedback — LOW for companion app.

---

## H. Hardware Controls Report

| Control | Implementation |
|---------|----------------|
| Digital Crown | Vertical tab paging (`.verticalPage`); scroll in lists |
| Side button | **Not mapped** to dive; documented in Shortcut Help + TestFlight notes |
| Action Button | 7 App Intents in `DIRDivingAppShortcuts` |
| Long press | Not used for dive control |
| On-screen START/STOP/RESET | Primary reliable path |

**Safe:** No false claim of direct hardware dive start.

---

## I. Sync Report

| Path | Status | User feedback |
|------|--------|---------------|
| Watch → iPhone dive | Implemented | Settings status + pending/ack counts |
| iPhone → Watch push | Implemented | More button + queue |
| Tombstones | Implemented | Broadcast + apply |
| Units | Implemented | `applicationContext` |
| Photos | Implemented | `transferFile` |
| Conflicts | Implemented | More card; keep local re-pushes |
| Offline queue | Implemented | `transferUserInfo` fallback |
| Signed ack | Implemented | HMAC + legacy fallback |

**Gaps:** iCloud merge/decode errors may be silent; user must open Settings/More for sync state. **Not mock-only.**

---

## J. Export Report

| Format | Watch | iOS |
|--------|-------|-----|
| Subsurface CSV | Y | Y |
| GPX/KML | N | N |
| Share sheet | Y | Y |
| Failure handling | Message + haptic | Orange text |

**Readiness:** **Production-ready** for Subsurface CSV scope documented in app.

---

## K. Safety Report

| Item | Status |
|------|--------|
| NOT a dive computer | Stated in legal, onboarding, More, planner |
| Planner indicative | Disclaimers + export footer; no mock deco row |
| Ascent warning | Visible banner; gauge/depth remain |
| GPS honesty | Fix source on detail; surface-only messaging |
| Depth 35/38/40 | Fixed thresholds; not user-editable |
| App Store risk | Entitlement proof for depth; planner marketing language |

**Blockers:** Physical validation of submersion depth on Ultra (HIGH for marketing "automatic dive").

---

## L. Error / Empty State Report

| Condition | Watch | iOS |
|-----------|-------|-----|
| No dives | Log empty hint | Logbook + Analysis empty actions |
| No GPS | Settings status + copy | Detail "n/d" |
| No depth sensor | Manual dive + error banner | N/A |
| Sync fail | failed count + retry | `lastMessage`, conflicts |
| Export fail | Text + haptic | Error text |
| Permissions denied | GPS row in Settings | Photo/import errors |
| iCloud unavailable | — | More shows unavailable |

**Silent failures:** iCloud decode (MED). No crash-class issues found statically.

---

## M. Bugs To Fix

| ID | Title | Platform | Severity | Impact | Fix | Impact |
|----|-------|----------|----------|--------|-----|--------|
| R1 | Physical depth/submersion QA | Watch | **HIGH** | Auto dive unproven in sim | TestFlight on Ultra with entitlement | QA |
| R2 | Planner safety ack not persisted | iOS | **MED** | Re-ack every planner visit | `@AppStorage` flag | Small |
| R3 | iCloud error surfacing | iOS | **MED** | User may think sync OK | Toast/banner on decode fail | Small |
| R4 | Mixed IT/EN main strings | iOS | **LOW** | Confusion for EN users | Localize tab/detail strings | UI-only |
| R5 | iOS no notification/sound feedback | iOS | **LOW** | Silent sync on phone | Optional UNNotification | Medium |
| R6 | User Images tab hidden until content | Watch | **LOW** | Feature discovery | Onboarding hint | Small |
| R7 | Watch "sync bidirezionale planned" copy | Watch | **LOW** | Expectation mismatch | Update copy to match units sync | UI-only |
| R8 | F11 legacy ack fallback | Both | **LOW** | Security hardening | Follow-up when floor build rises | Small |

**No CRITICAL code blockers** remain from the May 2024 UX audit after `876bcd2` + `db72dce`.

---

## N. Priority Roadmap

### 1. Must fix before compile/use
- **None** — builds succeed.

### 2. Must fix before TestFlight
- R1 Physical Ultra depth + sync smoke test
- R2 Planner ack persistence (optional but recommended)
- App icon / asset catalog verification on release Mac

### 3. Must fix before App Store
- R1 + legal/metadata review
- R3 iCloud failure visibility
- Entitlement documentation for water submersion
- Review notes (`Docs/TESTFLIGHT_REVIEW_NOTES.md`) aligned with build

### 4. Post-release
- R4 full i18n
- R5 iOS notifications
- R8 signed-ack only

---

## O. Final Verdict

| Question | Answer |
|----------|--------|
| **Ready to compile?** | **YES** |
| **Ready for internal test?** | **YES** (sim + paired devices) |
| **Ready for average user?** | **MOSTLY** (~91%) — requires paired Watch for full value |
| **Ready for TestFlight?** | **YES**, after R1 device QA |
| **Ready for App Store?** | **CONDITIONAL** — legal/assets/entitlement + physical depth validation |
| **What blocks 100%?** | Real-hardware depth path, App Store review items, minor i18n/cloud UX, no iOS sounds, planner ack session-only |

---

**Downloadable report:** `Docs/MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260524.docx`  
**Generate:** `python3 Docs/generate_main_branch_complete_readiness_audit_20260524_docx.py`
