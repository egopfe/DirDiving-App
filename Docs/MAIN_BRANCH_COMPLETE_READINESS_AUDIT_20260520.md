# DIR DIVING — MAIN BRANCH COMPLETE READINESS AUDIT

**Date:** 2026-05-20 (re-audit)  
**Type:** Audit-only — no code changes, no merges, no fixes  
**Branch:** `main` @ `9def114`  
**Scope:** Apple Watch MAIN (`DIRDiving Watch App`) + iOS Companion MAIN (`DIRDiving iOS` in unified `project.yml`)  
**Out of scope:** `codex/experimental-features`, `codex/ios-experimental-features`, `main-iOS` worktree (not this checkout)

**Visual benchmarks (mandatory):**

- Watch: `Docs/ReferenceUI/Watch_LIVE_reference.png`
- iOS: `Docs/ReferenceUI/iOS_Companion_reference.png`

**Method:** Static code review, `project.yml` / target membership, `xcodegen generate`, `xcodebuild` both schemes, cross-check with `Docs/MAIN_ISSUES_IMPLEMENTATION_REPORT_20260520.md` and feature CSV.

---

## A. Branch Confirmed

| Item | Result |
|------|--------|
| Current branch | `main` |
| HEAD | `9def114` (`docs` + `fix(i18n)` after `a75a6c3` implementation) |
| Targets inspected | `DIRDiving Watch App` (watchOS 10+), `DIRDiving iOS` (iOS 17+, embeds Watch) |
| `project.yml` | Valid; experimental files **excluded** from MAIN (Apnea, Snorkeling, Buddy, Exploration) |
| `xcodegen generate` | **PASS** → `DIRDiving.xcodeproj` |
| `xcodebuild` Watch (`DIRDiving Watch App`, Ultra 3 sim) | **BUILD SUCCEEDED** |
| `xcodebuild` iOS (`DIRDiving iOS`, iPhone 17 sim) | **BUILD SUCCEEDED** |
| Bundle IDs | Watch `com.egopfe.dirdiving`, iOS `com.egopfe.dirdiving.ios`, `WKCompanionAppBundleIdentifier` aligned |
| Entitlements | Watch: iCloud KVS + `com.apple.developer.coremotion.water-submersion`; iOS: iCloud KVS |
| Experimental dependency | **None** — MAIN does not import experimental-only Swift in target membership |
| Warnings (build) | No blocking errors observed in successful simulator builds; full warning log not archived in this audit |

---

## B. Executive Summary

| Dimension | Readiness % | Notes |
|-----------|-------------|-------|
| **Overall MAIN readiness** | **84%** | Compiles and runs in simulator; field depth + pairing QA + residual UX/i18n gaps |
| Apple Watch MAIN | **88%** | Core dive loop strong; Mode Selection friction; depth on real Ultra unproven |
| iOS Companion MAIN | **86%** | Five-tab companion complete; notifications/tones minimal; planner advanced modes visible |
| UX completeness | **80%** | Average user can dive/log/sync with guidance; settings sync still “planned” |
| Safety / disclaimers | **82%** | Disclaimers documented; not certified dive computer |
| Compile readiness | **92%** | Both schemes build on host with SDK 26.5; device signing/entitlement field test remains |

**One-line verdict:** MAIN is **ready for internal / simulator testing** and **developer-led device QA**; it is **not 100% ready** for an average consumer or App Store without real Watch Ultra depth validation, first-pairing sync education, completion of residual i18n on planner/technical screens, and App Store legal/asset review.

**Changes since prior audit (`b92e03a`):** P0 Watch inbound sync, unified tombstones, GPS compact banner (~1.4 s), alarm OK + cooldown, sync status strip on live dive, secondary i18n pass (~240 EN keys Watch), builds now succeed.

---

## C. Feature Inventory

| Platform | Feature | Impl. | Reachable | Usable | Complete | Severity | Notes |
|----------|---------|-------|-----------|--------|----------|----------|-------|
| Watch | Live dive (depth, TTV, runtime) | Y | Y | Y | Partial | MED | Auto depth needs submersion entitlement + **real Ultra** test |
| Watch | Stopwatch START/STOP/RESET | Y | Y | Y | Y | — | Haptics gated by setting |
| Watch | Avg / max depth cards | Y | Y | Y | Y | — | |
| Watch | Temperature display | Y | Y | Y | Partial | LOW | May be unavailable without sensor |
| Watch | Ascent gauge (zones) | Y | Y | Y | Y | — | Green/yellow/red |
| Watch | Ascent alarm (inline banner) | Y | Y | Y | Y | — | Non-blocking; haptic repeat ~1.75 s |
| Watch | BUSSOLA / SET BEARING / CLEAR | Y | Y | Y | Y | — | Terminology **BUSSOLA** (not COMPASSO) |
| Watch | Dive log / detail / delete | Y | Y | Y | Y | — | Confirm dialog on delete |
| Watch | GPS start/end metadata | Y | Y | Y | Y | — | Compact **banner** overlay ~1.4 s; metrics stay visible |
| Watch | Subsurface CSV export | Y | Y | Y | Y | — | `completeFileProtection` on Watch export path |
| Watch | User images viewer | Y | Y | Partial | Partial | LOW | Tab always visible; empty state if no `UserImages` assets |
| Watch | Settings (ascent, alarms, sync, language) | Y | Y | Y | Y | — | |
| Watch | Info / battery / depth diagnostics | Y | Y | Y | Partial | MED | Entitlement configured ≠ validated on device |
| Watch | Units | Partial | Y | Partial | Partial | LOW | Metric-only; imperial locked with disclaimer |
| Watch | Haptics | Y | Y | Y | Y | — | Toggle; ascent/alarm/GPS/confirm paths |
| Watch | Tones / audio | N | — | — | — | — | watchOS haptics only (expected) |
| Watch | Mode Selection on launch | Y | Y | Y | Partial | LOW | Extra step; only Diving active |
| Watch | Watch → iPhone sync | Y | Y | Y | Partial | MED | Outbound + queue + signed ack; first pairing needs secret |
| Watch | iPhone → Watch sync | Y | Y | Partial | Partial | MED | `didReceiveMessage` / `didReceiveUserInfo` implemented; needs device QA |
| Watch | Delete tombstone cross-device | Y | Y | Partial | Partial | MED | `dirdiving_shared_deleted_session_ids` + WC broadcast |
| Watch | Manual dive fallback | Y | Y | Y | Y | — | When auto depth unavailable |
| Watch | Sync status on live dive | Y | Y | Y | Y | — | Strip when pending/failed |
| Watch | Alarm dismiss (OK) | Y | Y | Y | Y | — | 15 s cooldown in `DiveManager` |
| Watch | App Intents (manual dive, bearing, alarm) | Y | Partial | Partial | Partial | LOW | Shortcuts; side button not mapped |
| iOS | Logbook + search + delete | Y | Y | Y | Y | — | Locale-aware month headers |
| iOS | Dive detail (tabs, charts, gas) | Y | Y | Y | Y | — | TTV safety note on detail |
| iOS | Planner input + Bühlmann result | Y | Y | Y | Partial | MED | Advanced modes visible; output indicative |
| iOS | Analysis + import CSV | Y | Y | Y | Y | — | Empty state with actions |
| iOS | Equipment profile + checklist | Y | Y | Y | Y | — | iCloud KVS when available |
| iOS | More (language, cloud, demo, disclaimer) | Y | Y | Y | Y | — | Long safety block |
| iOS | Watch sync import + conflicts | Y | Y | Y | Partial | MED | Tombstones aligned; conflict UI exists |
| iOS | CSV import bounds | Y | Y | Y | Y | — | 10 MB cap + depth/duration bounds |
| iOS | Subsurface export + share | Y | Y | Y | Y | — | |
| iOS | Notifications / alert sounds | N | Partial | Partial | Partial | LOW | No in-app sound layer |
| iOS | Demo logbook (reviewer) | Y | Y | Y | Y | — | Toggle in More |
| iOS | Language IT/EN/System | Y | Y | Y | Partial | MED | Secondary i18n; planner/GPS detail gaps |

---

## D. Navigation Map

### Apple Watch (`ContentView` — vertical `TabView`)

```
Cold launch → Tab 0: Mode Selection
  → user taps Diving → navigates to Live (or swipes)
Tabs: Mode Selection | Live | BUSSOLA | Settings | Images | Log
  Settings → NavigationLink: Ascent rate limits | Alarms | Info
  Settings → Shortcut help (watchOS limits)
  Log → DiveDetailView → Export / Delete (confirm)
```

**Friction (not dead ends):**

- **Mode Selection** is first tab — average user must select Diving then reach Live (product policy).
- **UserImages** tab visible even when bundle empty (empty state shown).
- No system back stack on TabView (normal for Watch).

### iOS (`ContentView` — five tabs)

```
Logbook → DiveDetailView (navigation push)
Analysis → empty → Import CSV | Sync Watch | Open Logbook
Planner → PlanResultView (push)
Equipment → profile edit + reset confirm
More → language, iCloud sync, demo logbook, disclaimer, Watch sync status rows
```

**Unreachable in MAIN target:** `ExplorationCenterView`, `BuddyExperimentalView`, `ExperimentalFutureConceptsView` (excluded in `project.yml`).

---

## E. UI Consistency Report

### Apple Watch vs `Watch_LIVE_reference.png`

| Screen | Match | Issue | Severity | Recommended fix |
|--------|-------|-------|----------|-----------------|
| DiveLiveView | **High** | Black canvas, neon panels, separated ascent column, octopus header | — | Maintain |
| Ascent banner | **High** | Inline red banner; depth/gauge/controls remain visible | — | Maintain policy in `WATCH_MAIN_UX_CONVENTIONS.md` |
| GPS confirmation | **High** | Compact top banner (~1.4 s), not full-screen takeover | — | Maintain |
| CompassView | **High** | Full-screen black, bordered SET/CLEAR | — | |
| Settings / Log / Export | **High** | Panel vocabulary, neon strokes | — | |
| Mode Selection | **Medium** | Extra pre-dive screen not in live reference | LOW | Optional default tab = Live |
| Localization | **Medium** | Secondary pass done; some literals may remain | LOW | Spot-check EN on device |
| UserImages empty tab | **Low** | Tab in bar without assets | LOW | Hide tab when `imageNames.isEmpty` |

### iOS vs `iOS_Companion_reference.png`

| Screen | Match | Issue | Severity | Recommended fix |
|--------|-------|-------|----------|-----------------|
| Tab bar + `DIRTheme` | **High** | Dark marine + cyan accent | — | |
| Logbook / Detail / Planner | **High** | Cards, charts, neon gas borders | — | |
| More disclaimer | **High** | Safety block present | — | |
| App icon set | **Medium** | Validate all `AppIcon.appiconset` slots in Xcode archive | MED | Asset pass before archive |
| Partial EN on planner result | **Medium** | Some table headers Italian | LOW | i18n keys for PlanResultView |

---

## F. Settings Report

### Watch MAIN

| Setting | Reachable | Editable | Persisted | Applied | Sync to iPhone |
|---------|-----------|----------|-----------|---------|----------------|
| Ascent rate limits | Y | Y | Y (`AscentRateSettingsStore`) | Immediate | No (copy: planned) |
| Alarm thresholds | Y | Y | Y (`@AppStorage`) | Immediate | No |
| Haptics on/off | Y | Y | Y | Immediate | No |
| Units | Y | Partial | Y | Metric forced | No |
| Language System/IT/EN | Y | Y | Y | Immediate | No |
| GPS / depth / sync status | Y | N (read-only rows) | — | Live status strings | — |
| Clear sync queue | Y | Y | Y | Immediate | — |

### iOS MAIN

| Setting | Reachable | Editable | Persisted | Notes |
|---------|-----------|----------|-----------|-------|
| Language | Y (More) | Y | Y | Does not change units/calculations |
| Watch sync / trust reset | Y | Y | Y | `resetPairingTrust()` |
| iCloud sync trigger | Y | Y | Y | Last-write-wins surfaced |
| Units / export labels | Y | **Read-only** in More | — | Honest “local-only” |
| Demo logbook | Y | Y | Y | Reviewer toggle |
| Equipment / planner | Y | Y | iCloud KVS | No per-field merge UI |

**Gaps:** Bidirectional settings sync still documented as planned; Watch imperial conversion not implemented; iOS notification permission UI thin.

---

## G. Haptics / Tones Report

### Watch — implemented

| Event | Haptic | Gated by setting |
|-------|--------|------------------|
| Stopwatch start/stop/reset | confirm / notify patterns | Y |
| Dive lifecycle / GPS confirm | confirm | Y |
| Ascent over-limit | failure + repeat ~1.75 s | Y |
| Depth / time / battery alarms | warnIfNeeded (2 s debounce) | Y |
| Compass SET / CLEAR | confirm / notify | Y |
| Log delete / export | notify / confirm | Y |
| Settings actions | notify / confirm | Y |

### Watch — gaps

- No audio tones underwater (acceptable).
- Buddy haptics exist in `HapticService` but Buddy not in MAIN target.

### iOS

- **No** `AVAudioPlayer` / system alert sounds for sync/export.
- Visual-only feedback (colors, captions).
- No push notification onboarding flow in MAIN.

**Safety-critical:** Ascent and alarm paths have haptic + visual; GPS save uses confirm haptic.

---

## H. Hardware Controls Report

| Control | Status |
|---------|--------|
| Digital Crown | Scroll in Settings, log lists, Mode Selection (standard SwiftUI) |
| Side button / Action Button | **Not** mapped to arbitrary dive start/stop; documented in `WatchShortcutHelpView` |
| App Intents | `StartManualDiveIntent`, `EndManualDiveIntent`, `SetBearingIntent`, `ClearBearingIntent`, `AcknowledgeAlarmIntent`, stopwatch toggle/reset |
| Long press | No global custom long-press for dive |
| Crown vs swipe | Vertical page `TabView` — Crown scrolls within scroll views |

**Safe:** Copy does not promise side button = START dive. Fallback UI buttons always present.

---

## I. Sync Report

### Implemented paths

| Direction | Mechanism | Status |
|-----------|-----------|--------|
| Watch → iPhone | `sendMessage` / `transferUserInfo`, HMAC payload, pending queue in Documents + `completeFileProtection` | Implemented |
| iPhone → Watch | `didReceiveMessage`, `didReceiveUserInfo`, `ingestIncomingPayload`, signed ack reply | Implemented (`a75a6c3`) |
| Tombstones | `dirdiving_shared_deleted_session_ids` + `dirdiving_deleted_session_ids` WC broadcast | Implemented |
| Peer secret | `WatchSyncAuth`, `applicationContext` merge | Implemented |
| iPhone conflicts | Persisted conflicts file + resolve UI patterns | Implemented |
| Offline queue | Watch pending JSON; retry in Settings | Implemented |

### Remaining risks (not code-missing on paper)

| Risk | Severity | Notes |
|------|----------|-------|
| First pairing without peer secret | MED | Sessions queue until secret exchanged — document in TestFlight notes |
| Per-session delivery status | LOW | Aggregate counters in Settings/More; not per-dive UUID UI |
| Stale status after language change | LOW | `lastSyncStatus` string set at event time |
| Device QA not executed in this audit | MED | Simulator WC limited |

**Mock-only:** None identified on MAIN sync path.

---

## J. Export Report

| Format | Watch | iOS | User feedback |
|--------|-------|-----|---------------|
| Subsurface CSV | Y | Y | Error message if write fails |
| ShareLink | Y | Y | From detail/list |
| GPX/KML | N | N | Post-release (documented) |

**Validity:** CSV business format documented in `Docs/iOS/SUBSURFACE_EXPORT.md`; manual round-trip QA recommended.

**Reachability:** Export from log list (latest) and dive detail; export completion screen on Watch.

---

## K. Safety Report

| Item | Status |
|------|--------|
| Certified dive computer | **Not claimed** — `Docs/SAFETY_DISCLAIMER.md`, README, More |
| Planner / Bühlmann | Indicative; in-app + doc disclaimers |
| TTV | Labeled informative; not NDL/TTS |
| Ascent warning | Inline banner + haptics; UI-reliable |
| GPS | Surface-only; no-fix/fallback labeled |
| Depth | Manual fallback when auto unavailable |
| Alarm dismiss | User can OK; cooldown prevents spam |
| App Store risk | **Real-device depth entitlement**; privacy policy; partial i18n on technical screens |

---

## L. Error / Empty State Report

| Condition | Watch | iOS |
|-----------|-------|-----|
| No dives | `NESSUNA IMMERSIONE` + export hint | Logbook + Analysis empty + CTAs |
| No GPS | Banner “unavailable”; detail fallback text | Route empty in analysis |
| No depth / manual | Manual panel + error banner | Charts may be flat |
| Compass denied | Yellow status in CompassView | n/a |
| Sync pending/fail | Settings rows + **live strip** | More last event |
| Export fail | Yellow message | Import error string |
| Permissions denied | GPS status in Settings | System dialogs |
| Load error | Red banner in log list | — |

**Silent failures:** User who never opens Settings may miss queue growth (mitigated partially by live sync strip).

**Crashes:** None observed in simulator build run (not a substitute for device soak test).

---

## M. Bugs To Fix

| # | Title | Platform | Location | Sev. | User impact | Fix type |
|---|-------|----------|----------|------|-------------|----------|
| 1 | Depth entitlement not validated on real Watch Ultra | Watch | Entitlements + `DiveManager` | **HIGH** | Auto depth may fail in water | Process / QA |
| 2 | First-pairing sync appears “broken” without docs | Both | `WatchSyncAuth`, Settings | **MED** | Tester confusion | Process + copy |
| 3 | Mode Selection extra step on every cold launch | Watch | `AppPage.modeSelection` | **LOW** | Friction | UI-only |
| 4 | UserImages tab visible when bundle empty | Watch | `ContentView` | **LOW** | Empty tab | UI-only |
| 5 | Residual i18n on planner result / GPS detail lines | iOS | `PlannerView`, `DiveDetailView` | **LOW** | Mixed EN/IT | UI-only |
| 6 | iOS AppIcon completeness for archive | iOS | `AppIcon.appiconset` | **MED** | Archive rejection risk | Assets |
| 7 | Settings not synced Watch ↔ iPhone | Both | Settings/More copy | **LOW** | Expectation mismatch | Planned / product |
| 8 | Imperial units Watch locked to metric | Watch | `SettingsView` | **LOW** | Documented | Planned |
| 9 | Per-session sync status not per dive UUID | Both | Sync services | **LOW** | Power users only | Small functional |

**Resolved since last audit (no longer open):**

- ~~Watch missing `didReceiveMessage`~~ → **Fixed** `a75a6c3`
- ~~Tombstone key mismatch~~ → **Fixed** shared key
- ~~GPS full-screen 2.4 s~~ → **Fixed** compact banner 1.4 s
- ~~Alarm no dismiss~~ → **Fixed** OK + cooldown
- ~~xcodebuild SDK missing~~ → **Fixed** on audit host (both schemes succeed)

---

## N. Priority Roadmap

### 1. Must fix before compile/use

- ✅ Simulator builds (done on audit host).
- Verify **release signing** + provisioning with water submersion entitlement on Apple Developer portal.

### 2. Must fix before TestFlight

- **Real Apple Watch Ultra** depth smoke test (automatic launch + submerged samples).
- End-to-end pairing: Watch log → iPhone → delete on iPhone → confirm absent on Watch (tombstone).
- End-to-end iPhone push / delete → Watch (inbound handlers).
- Reviewer notes: `Docs/TESTFLIGHT_REVIEW_NOTES.md`.

### 3. Must fix before App Store

- Entitlement proof + privacy policy (GPS, Health, iCloud).
- Complete i18n on **primary** flows or declare Italian-primary in metadata.
- App icon / screenshot asset validation.
- Legal review of planner + TTV copy.

### 4. Post-release

- Skip Mode Selection default to Live; hide empty UserImages tab; GPX export; per-session sync delivery UI; bidirectional settings sync.

---

## O. Final Verdict

| Question | Answer |
|----------|--------|
| **Ready to compile?** | **Yes** — XcodeGen + both schemes **BUILD SUCCEEDED** on simulator (2026-05-20 host). |
| **Ready for internal test?** | **Yes** — with pairing checklist and known depth-field validation gap. |
| **Ready for average user?** | **Conditional** — usable for diving/logging if user accepts Mode Selection step, metric-only Watch, and English not 100% on all screens. |
| **Ready for TestFlight?** | **After** real Ultra depth test + bidirectional sync QA on physical devices. |
| **Ready for App Store?** | **No** — depth entitlement validation, legal/metadata, residual i18n/assets. |

**What blocks 100% readiness:**

1. **Field validation** of water submersion depth on Apple Watch Ultra (not provable in simulator).  
2. **Physical Watch ↔ iPhone** sync/tombstone QA (code present; behavior unverified in this audit).  
3. **Product friction:** Mode Selection on launch; settings sync not bidirectional (documented).  
4. **Release packaging:** App icon completeness, privacy policy, App Store copy vs indicative planner.  
5. **Residual localization** on secondary/technical iOS screens.

---

## Reference: commit baseline for fixes

| Commit | Scope |
|--------|--------|
| `a75a6c3` | P0 inbound sync, P1 tombstones, GPS banner, alarm OK, sync strip, App Intents |
| `2e7cf12` | Secondary i18n (~240 keys Watch, services localized) |
| `9def114` | Documentation alignment (this audit supersedes doc claims at `b92e03a`) |

---

*Audit-only · DIR DIVING · `main` @ `9def114` · 2026-05-20*
