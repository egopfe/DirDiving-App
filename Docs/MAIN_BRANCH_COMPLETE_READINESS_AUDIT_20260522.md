# DIR DIVING — MAIN BRANCH COMPLETE READINESS AUDIT

**Date:** 2026-05-22 (re-audit)  
**Type:** Audit-only — no code changes, no merges, no fixes  
**Branch:** `main` @ `800bfa8`  
**Scope:** Apple Watch MAIN (`DIRDiving Watch App`) + iOS Companion MAIN (`DIRDiving iOS` in unified `project.yml`)  
**Out of scope:** `codex/experimental-features`, `codex/ios-experimental-features`, `main-iOS` worktree (not required for this checkout)

**Visual benchmarks (mandatory):**

- Watch: `Docs/ReferenceUI/Watch_LIVE_reference.png` (present)
- iOS: `Docs/ReferenceUI/iOS_Companion_reference.png` (present)

**Method:** Static code review, `project.yml` target membership, `xcodegen generate`, `xcodebuild` both schemes (named simulators), cross-check with prior audit @ `9def114` / `800bfa8` docs, feature CSV, agent-assisted file traces.

**Delta since [`MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260520.md`](MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260520.md):** HEAD moved `9def114` → `800bfa8` (internal testing playbook + audit artifacts); remote docs @ `670386e` merged earlier. Core sync/i18n fixes remain from `a75a6c3` / `2e7cf12`. This run re-validates builds and surfaces **new** gaps: iPhone→Watch dive push missing, iOS sync-conflict UI absent, substantial hardcoded Italian on Watch Settings / iOS More / Planner.

---

## A. Branch Confirmed

| Item | Result |
|------|--------|
| Current branch | `main` |
| HEAD | `800bfa8` (`docs: add internal testing playbook and MAIN readiness audit`) |
| Targets inspected | `DIRDiving Watch App` (watchOS 10+), `DIRDiving iOS` (iOS 17+, embeds Watch) |
| `project.yml` | Valid; experimental files **excluded** from MAIN (Apnea, Snorkeling, Buddy, Exploration) |
| `xcodegen generate` | **PASS** → `DIRDiving.xcodeproj` |
| `xcodebuild` Watch (`DIRDiving Watch App`, Apple Watch Ultra 3 (49mm), watchOS 26.5) | **BUILD SUCCEEDED** |
| `xcodebuild` iOS (`DIRDiving iOS`, iPhone 17, iOS 26.5) | **BUILD SUCCEEDED** |
| `xcodebuild` iOS (`generic/platform=iOS Simulator`, `CODE_SIGNING_ALLOWED=NO`) | **BUILD FAILED** — duplicate output `DIR DIVING.app` (both targets share product name; use named simulator destination) |
| Bundle IDs | Watch `com.egopfe.dirdiving`, iOS `com.egopfe.dirdiving.ios`, `WKCompanionAppBundleIdentifier` aligned |
| Entitlements | Watch: iCloud KVS + `com.apple.developer.coremotion.water-submersion`; iOS: iCloud KVS (`iCloud.com.egopfe.dirdiving`) |
| Info.plist (Watch) | `WKSupportsAutomaticDepthLaunch`, `underwater-depth` background mode, motion/location usage strings |
| Experimental dependency | **None** — MAIN `ContentView` files do not reference excluded views |
| Build warnings (Watch) | 3× AppIcon `icon_92_2x.png` unassigned child in `Resources/Assets.xcassets` |
| Build warnings (iOS named dest.) | None blocking in successful log tail |
| TODO/FIXME in included Watch Swift | **0** |
| Reference UI assets | **Present** under `Docs/ReferenceUI/` |

---

## B. Executive Summary

| Dimension | Readiness % | Notes |
|-----------|-------------|-------|
| **Overall MAIN readiness** | **83%** | Compiles on named simulators; not 100% for consumer/App Store |
| Apple Watch MAIN | **87%** | Strong live dive UX; depth unproven on real Ultra; Settings largely hardcoded IT |
| iOS Companion MAIN | **85%** | Five-tab companion functional; conflict UI missing; planner result partial chrome |
| UX completeness | **79%** | Mode Selection friction; settings not cross-synced; EN incomplete on key iOS screens |
| Safety / disclaimers | **82%** | Documented non-certified; planner lacks mandatory ack gate |
| Compile readiness | **90%** | Named-simulator builds OK; generic iOS sim build fails (tooling caveat) |

**One-line verdict:** MAIN is **ready for internal / simulator testing** and **developer-led device QA** with [`Docs/INTERNAL_TESTING_PLAYBOOK_20260520.md`](INTERNAL_TESTING_PLAYBOOK_20260520.md). It is **not 100% ready** for an average consumer or App Store without real Watch Ultra depth validation, physical sync/tombstone QA, i18n pass on hardcoded screens, and App Store legal/asset review.

---

## C. Feature Inventory

| Platform | Feature | Impl. | Reachable | Usable | Complete | Severity | Notes |
|----------|---------|-------|-----------|--------|----------|----------|-------|
| Watch | Live dive (depth, TTV, runtime) | Y | Y | Y | Partial | HIGH | Auto depth needs submersion entitlement + **real Ultra** test |
| Watch | Stopwatch START/STOP/RESET | Y | Y | Y | Y | — | Haptics gated |
| Watch | Avg / max depth cards | Y | Y | Y | Y | — | |
| Watch | Temperature display | Y | Y | Y | Partial | LOW | Sensor-dependent |
| Watch | Ascent gauge (zones) | Y | Y | Y | Y | — | Co-visible with inline banner |
| Watch | Ascent alarm (inline banner) | Y | Y | Y | Y | — | OK dismiss + 15s cooldown |
| Watch | BUSSOLA / SET BEARING / CLEAR | Y | Y | Y | Y | — | Terminology **BUSSOLA** |
| Watch | Dive log / detail / delete | Y | Y | Y | Y | — | Confirm on delete |
| Watch | GPS start/end metadata | Y | Y | Y | Y | — | Compact banner ~1.4s |
| Watch | Subsurface CSV export | Y | Y | Y | Y | — | Temp dir + `completeFileProtection` |
| Watch | User images viewer | Y | Y | Partial | Partial | LOW | Tab always visible; empty state |
| Watch | Settings (ascent, alarms, sync, language) | Y | Y | Y | Partial | MED | Many rows hardcoded Italian |
| Watch | Info / battery / depth diagnostics | Y | Y | Y | Partial | MED | Configured ≠ validated on device |
| Watch | Units | Partial | Y | Partial | Partial | LOW | Metric-only; imperial locked |
| Watch | Haptics | Y | Y | Y | Y | — | `HapticService` central gate |
| Watch | Tones / audio | N | — | — | — | — | Haptics only (expected) |
| Watch | Mode Selection on launch | Y | Y | Y | Partial | LOW | Extra step; only Diving active |
| Watch | Watch → iPhone sync | Y | Y | Y | Partial | MED | Queue + HMAC; device QA required |
| Watch | iPhone → Watch (sessions) | Partial | Y | Partial | Partial | MED | Inbound handlers exist; **iOS never sends sessions** |
| Watch | Delete tombstone cross-device | Y | Y | Partial | Partial | MED | Shared key + WC broadcast |
| Watch | Manual dive fallback | Y | Y | Y | Y | — | When auto depth unavailable |
| Watch | Sync status on live dive | Y | Y | Y | Y | — | Strip when pending/failed |
| Watch | App Intents | Y | Partial | Partial | Partial | LOW | Stopwatch in shortcuts; manual dive not promoted |
| iOS | Logbook + search + delete | Y | Y | Y | Y | — | Demo dives protected |
| iOS | Dive detail (tabs, charts, gas) | Y | Y | Y | Y | — | TTV safety note |
| iOS | Planner input + Bühlmann result | Y | Y | Y | Partial | MED | Indicative; result share icon inert; mode unused in math |
| iOS | Analysis + import CSV | Y | Y | Y | Y | — | Import from empty state; errors IT hardcoded |
| iOS | Equipment profile + checklist | Y | Y | Y | Y | — | iCloud KVS |
| iOS | More (language, cloud, demo, disclaimer) | Y | Y | Y | Partial | MED | Disclaimer IT hardcoded; export card display-only |
| iOS | Watch sync import + tombstones | Y | Y | Y | Partial | MED | Tombstones implemented; **conflict UI missing** |
| iOS | CSV import bounds | Y | Y | Y | Y | — | 10 MB cap |
| iOS | Subsurface export + share | Y | Y | Y | Y | — | From dive detail |
| iOS | Notifications / alert sounds | N | Partial | Partial | Partial | LOW | No push/audio layer |
| iOS | Demo logbook (reviewer) | Y | Y | Y | Y | — | More → REVIEWER toggle |
| iOS | Language IT/EN/System | Y | Y | Y | Partial | MED | Secondary i18n; More/Planner hardcoded IT |
| iOS | iPhone → Watch dive push | N | — | — | — | MED | One-way session sync by design gap |

---

## D. Navigation Map

### Apple Watch (`ContentView` — `.verticalPage` `TabView`, Crown scrolls tabs)

```
Cold launch → Tab 0: Mode Selection
  → tap Diving → AppNavigationStore → Live (or swipe)
Tabs: Mode Selection | Live | BUSSOLA | Settings | User Images | Log
  Settings → NavigationLink: Ascent limits | Alarms | Info | Shortcut help
  Log → DiveDetailView → Export / Delete (confirm)
```

**Friction (not dead ends):**

- Mode Selection is first tab — user must select Diving before Live.
- UserImages tab visible when bundle empty.
- No custom global back (normal Watch TabView).

### iOS (`ContentView` — five tabs, `DIRTheme.cyan` tint)

```
Logbook → DiveDetailView (push)
Analysis → empty: Import CSV | Sync Watch | Open Logbook
Planner → PlanResultView (push) — all result sections always visible
Equipment → profile + checklist + reset
More → language, iCloud, demo logbook, Watch status rows, disclaimer
```

**Unreachable in MAIN target:** `ExplorationCenterView`, `BuddyExperimentalView`, `ExperimentalFutureConceptsView` (excluded in `project.yml`).

**Dead / decorative UI (reachable but no action):** Logbook header `+` / menu; More EXPORT card; PlanResult toolbar share; Planner mode picker (persisted, not used in calculations).

---

## E. UI Consistency Report

### Apple Watch vs `Watch_LIVE_reference.png`

| Screen | Match | Issue | Severity | Recommended fix |
|--------|-------|-------|----------|-----------------|
| DiveLiveView | **High** | Black canvas, neon via `DiveUI` / `DivePanel`, gauge column | — | Maintain |
| Ascent banner | **High** | Inline red; depth/gauge/controls co-visible | — | Policy in `WATCH_MAIN_UX_CONVENTIONS.md` |
| GPS confirmation | **High** | Thin top banner ~1.4s | — | Maintain |
| CompassView | **High** | Full-screen black, SET/CLEAR panels | — | |
| Settings / Log | **Medium** | Panel style OK; **large IT hardcoded blocks** in `SettingsView` | MED | Wire `String(localized:)` / EN keys |
| Mode Selection | **Medium** | Extra pre-dive screen | LOW | Optional default tab = Live |
| UserImages empty tab | **Low** | Tab in bar without assets | LOW | Hide when empty |
| AppIcon | **Medium** | Unassigned `icon_92_2x.png` warning | MED | Fix `AppIcon.appiconset` |

### iOS vs `iOS_Companion_reference.png`

| Screen | Match | Issue | Severity | Recommended fix |
|--------|-------|-------|----------|-----------------|
| Tab bar + `DIRTheme` | **High** | Dark marine + cyan | — | |
| Logbook / Detail | **High** | Cards, charts | — | |
| Planner / PlanResult | **Medium** | Disclaimer present; result tabs cosmetic; hardcoded IT strings | MED | i18n + wire share |
| More | **Medium** | Safety block present but **Italian hardcoded** | MED | Localize `DIRWarningBox` |
| App icon set | **Medium** | Validate all slots before archive | MED | Asset pass |

---

## F. Settings Report

### Watch MAIN

| Setting | Reachable | Editable | Persisted | Applied | Sync to iPhone |
|---------|-----------|----------|-----------|---------|----------------|
| Ascent rate limits | Y | Y | Y (`AscentRateSettingsStore` + iCloud) | Immediate | No |
| Alarm thresholds | Y | Y | Y (`@AppStorage`, 7 keys) | Immediate | No (copy: local Watch only) |
| Haptics on/off | Y | Y | Y (`dirmotion_watch_haptics_enabled`) | Immediate | No |
| Units | Y | Partial | Y | Forced metric on appear | No (iOS does not publish units in WC context) |
| Language System/IT/EN | Y | Y | Y (`dirmotion_app_language`) | Immediate | No |
| GPS / depth / sync status | Y | N | — | Live strings | — |
| Clear sync queue / retry | Y | Y | Y | Immediate | — |

**Gaps:** “Sync impostazioni — bidirectional planned” (honest copy); imperial not implemented; informational export row in Settings has no action.

### iOS MAIN

| Setting | Reachable | Editable | Persisted | Notes |
|---------|-----------|----------|-----------|-------|
| Language | Y (More) | Y | Y (`dirdiving_app_language`) | Does not change units/calculations |
| Watch sync status | Y | N | — | Read-only rows in More |
| iCloud sync | Y | Y | Y | “Sincronizza ora” triggers KVS |
| Demo logbook | Y | Y | Y | Reviewer toggle |
| Units | Partial | N in UI | `dirdiving_ios_units` | No picker; metric default |
| Planner mode | Y | Y | Y | **Not used** in `PlannerService` math |
| Equipment / planner state | Y | Y | iCloud KVS | |

**Gaps:** Settings sync row “Locale-only”; no notification permission UI; export labels in More without action.

---

## G. Haptics / Tones Report

### Watch — implemented (`Services/HapticService.swift`, gated by `dirmotion_watch_haptics_enabled`)

| Event | Haptic | Gated |
|-------|--------|-------|
| Stopwatch start/stop/reset | confirm / notify | Y |
| Dive start / GPS confirm | confirm | Y |
| Ascent over-limit | failure + repeat ~1.75s | Y |
| Depth / time / battery alarms | warn (2s debounce) | Y |
| Compass SET / CLEAR | confirm / notify | Y |
| Export / delete / sync retry | confirm / notify | Y |
| Alarm OK dismiss | notify | Y |

**Badge when off:** `APTICA DISATTIVATA` on live pre-dive / in-dive.

### Watch — gaps

- No underwater audio tones (acceptable).
- Buddy-specific haptics in `HapticService` — Buddy target excluded.

### iOS

- **No** custom alert sounds or push notification onboarding.
- Visual feedback only (toasts, colored messages, `DIRWarningBox`).

**Safety-critical:** Ascent and threshold alarms have haptic + visual on Watch; not duplicated as audio on iOS.

---

## H. Hardware Controls Report

| Control | Status |
|---------|--------|
| Digital Crown | Vertical `TabView` pages (6 tabs); Crown scrolls within scroll views |
| Side button / Action Button | **Not** interceptable; documented in `WatchShortcutHelpView` |
| App Intents (promoted) | `ToggleStopwatchIntent`, `ResetStopwatchIntent` in `DIRDivingAppShortcuts` |
| App Intents (defined, not promoted) | Manual dive, bearing, alarm acknowledge |
| Long press | No app-global custom mapping |
| Manual fallback | **AVVIO MANUALE** / **FINE MANUALE** when submersion unavailable |

**Safe:** UI does not claim side button = START dive; on-screen buttons always available.

---

## I. Sync Report

### Implemented paths

| Direction | Mechanism | Status |
|-----------|-----------|--------|
| Watch → iPhone | `sendMessage` / `transferUserInfo`, HMAC envelope, pending JSON queue | **Implemented** |
| iPhone → Watch (tombstones) | `dirdiving_deleted_session_ids` WC broadcast + shared KVS key | **Implemented** |
| iPhone → Watch (sessions) | Watch `ingestIncomingPayload` | **Code present; iOS never sends** — **gap** |
| Tombstones | `dirdiving_shared_deleted_session_ids` + legacy key migration | **Implemented** |
| Auth | `WatchSyncAuth` peer secret + ordered-secret HMAC | **Implemented** → device QA |
| Signed ack | iOS reply `ackSignature`; Watch verifies (legacy ack fallback) | **Implemented** |
| Watch failure UI | `lastSyncStatus`, pending/failed counts, retry, live strip | **Implemented** |
| iOS conflicts | `SyncConflict` persisted to protected JSON | **Service only — no View** |

### Remaining risks

| Risk | Severity | Notes |
|------|----------|-------|
| First pairing without peer secret | MED | Queue until both apps open; document in TestFlight notes |
| Per-session delivery UI | LOW | SAF-10 TODO copy in Settings/More |
| iPhone → Watch full log sync | MED | Product expectation may assume bidirectional logs |
| Device QA | MED | Simulator WC limited |
| Units via WC context | LOW | Watch reads key; iOS does not publish |

**Mock-only:** None on MAIN sync path.

---

## J. Export Report

| Format | Watch | iOS | User feedback |
|--------|-------|-----|---------------|
| Subsurface CSV | Y (`SubsurfaceExportService`) | Y | Error string on failure |
| ShareLink | Y (`ExportView`, detail) | Y (`DiveDetailView`) | |
| GPX/KML | N | N | Post-release |
| More → EXPORT card | — | Display only | Misleading if user expects tap action |

**Validity:** Metric CSV with standard columns; 24h temp file cleanup on Watch.

**Reachability:** Log list (latest), dive detail; Settings shows info row only.

---

## K. Safety Report

| Item | Status |
|------|--------|
| Certified dive computer | **Not claimed** — `Docs/SAFETY_DISCLAIMER.md`, README, More |
| Planner / Bühlmann | Indicative; warnings in `PlannerView`; **no mandatory ack** before calculate |
| TTV | Labeled informative; accessibility hint on Watch |
| Ascent warning | Inline banner + haptics; gauge remains visible |
| GPS | Surface-only; unavailable/fallback banners |
| Depth | Manual fallback; `lastErrorMessage` banner; may show **0 m** without strong in-dive “no sensor” |
| Alarm dismiss | OK + cooldown |
| App Store risk | Ultra depth entitlement proof; privacy policy; partial i18n; planner result placeholders |

---

## L. Error / Empty State Report

| Condition | Watch | iOS |
|-----------|-------|-----|
| No dives | `NESSUNA IMMERSIONE` + sync hint | Logbook + Analysis empty + CTAs |
| No GPS | Compact banner unavailable; detail text | Analysis route empty |
| No depth / manual | Manual panel + warning banner | Flat charts |
| Compass inactive dive | “Dati immersione non disponibili” | n/a |
| Sync pending/fail | Settings + **live strip** | More status; Analysis retry |
| Export fail | Yellow message | `exportErrorMessage` |
| Import fail | — | IT hardcoded errors in `DiveImportService` |
| Permissions denied | Settings GPS rows | System dialogs |
| Load error | Red banner in log | — |
| iCloud unavailable | Cloud copy in Settings | More “Non disponibile” |

**Silent failures:** User who never opens Settings may miss queue growth (partially mitigated by live sync strip). iOS sync conflicts stored with **no UI**.

**Crashes:** None in 2026-05-22 simulator builds (not a soak test).

---

## M. Bugs To Fix

| # | Title | Platform | Location | Sev. | User impact | Fix type | Est. impact |
|---|-------|----------|----------|------|-------------|----------|-------------|
| 1 | Depth entitlement not validated on real Watch Ultra | Watch | Entitlements, `DiveManager` | **HIGH** | Auto depth may fail in water | Process / QA | Environment |
| 2 | Physical sync + tombstone QA not executed | Both | `WatchSyncService`, `DiveLogStore` | **HIGH** | Data trust risk | Process / QA | Environment |
| 3 | iPhone does not push dive sessions to Watch | iOS | `iOSApp/Services/WatchSyncService.swift` | **MED** | One-way log sync expectation | Small functional | Medium |
| 4 | iOS sync conflicts persisted without UI | iOS | `WatchSyncService`, views | **MED** | Silent duplicate handling | Small functional | UI-only |
| 5 | First-pairing sync appears broken without docs | Both | `WatchSyncAuth`, Settings | **MED** | Tester confusion | Process + copy | UI-only |
| 6 | Hardcoded Italian on Watch Settings / DiveLive manual panel | Watch | `SettingsView`, `DiveLiveView`, `DiveManager` | **MED** | EN mode shows IT | UI-only | Small |
| 7 | Hardcoded Italian on iOS More disclaimer / Planner | iOS | `MoreView`, `PlannerView` | **MED** | EN mode shows IT | UI-only | Small |
| 8 | iOS generic simulator build fails (duplicate app product) | Build | Xcode project / schemes | **LOW** | CI script using generic dest. | Build config | Small |
| 9 | Watch AppIcon unassigned child warning | Watch | `Resources/Assets.xcassets` | **MED** | Archive risk | Assets | UI-only |
| 10 | Mode Selection extra step on cold launch | Watch | `AppPage.modeSelection` | **LOW** | Friction | UI-only | Small |
| 11 | UserImages tab when bundle empty | Watch | `ContentView` | **LOW** | Empty tab | UI-only | Small |
| 12 | PlanResult share icon / tabs cosmetic | iOS | `PlanResultView` | **LOW** | Confusing chrome | UI-only | Small |
| 13 | Import errors not localized | iOS | `DiveImportService` | **LOW** | EN users see IT errors | UI-only | Small |
| 14 | Settings not synced Watch ↔ iPhone | Both | Settings/More | **LOW** | Expectation mismatch | Planned | Architectural |
| 15 | Per-session sync delivery status | Both | Settings/More | **LOW** | Power users | Small functional | Small |

**Resolved (do not reopen):**

- Watch missing `didReceiveMessage` / `didReceiveUserInfo` → **Fixed** `a75a6c3`
- Tombstone key mismatch → **Fixed** `dirdiving_shared_deleted_session_ids`
- GPS full-screen takeover → **Fixed** compact banner ~1.4s
- Alarm no dismiss → **Fixed** OK + 15s cooldown
- Secondary i18n pass → **Partial** `2e7cf12` (services + many screens; not all UI chrome)

**Stale documentation:** [`MAIN_BRANCH_ISSUES_AND_PRIORITIES_20260520.md`](MAIN_BRANCH_ISSUES_AND_PRIORITIES_20260520.md) still lists **P0-SYNC-01** as open — **incorrect** at `800bfa8`; update in a separate doc commit if desired.

---

## N. Priority Roadmap

### 1. Must fix before compile/use

- Named-simulator builds (verified 2026-05-22).
- Avoid `generic/platform=iOS Simulator` until duplicate-product issue addressed.
- Verify release signing + water submersion on Apple Developer portal.

### 2. Must fix before TestFlight

- Real Apple Watch Ultra depth smoke test.
- Physical pairing QA: Watch → iPhone log; delete on iPhone → absent on Watch; delete on Watch → absent on iPhone.
- Document first-pairing secret exchange (`Docs/TESTFLIGHT_REVIEW_NOTES.md`).
- Decide product stance on iPhone → Watch session push (implement or document one-way).

### 3. Must fix before App Store

- Entitlement proof + privacy policy (GPS, motion, iCloud).
- i18n on primary flows OR declare Italian-primary in metadata.
- App icon / screenshot validation; fix Watch AppIcon warning.
- Legal review of planner + TTV copy; optional planner safety-ack gate.

### 4. Post-release

- Skip Mode Selection; hide empty UserImages; GPX export; per-session sync UI; bidirectional settings sync; iOS conflict resolution UI; wire PlanResult share.

---

## O. Final Verdict

| Question | Answer |
|----------|--------|
| **Ready to compile?** | **Yes** — with **named** simulator destinations (Watch Ultra 3, iPhone 17). Generic iOS sim build **fails**. |
| **Ready for internal test?** | **Yes** — use [`INTERNAL_TESTING_PLAYBOOK_20260520.md`](INTERNAL_TESTING_PLAYBOOK_20260520.md); treat depth + sync as open until device QA passes. |
| **Ready for average user?** | **Conditional** — usable for manual dive + log + export; friction from Mode Selection, metric-only Watch, mixed EN/IT on settings/planner. |
| **Ready for TestFlight?** | **After** Ultra depth test + bidirectional tombstone QA on physical devices. |
| **Ready for App Store?** | **No** — depth field proof, legal/metadata, i18n/assets, conflict UI gap. |

**What blocks 100% readiness:**

1. **Field validation** of water submersion on Apple Watch Ultra.  
2. **Physical** Watch ↔ iPhone sync/tombstone QA (code largely present).  
3. **Product gaps:** iPhone → Watch session push absent; iOS conflict UI absent.  
4. **Localization:** Hardcoded IT on Watch Settings, iOS More, Planner; import errors IT-only.  
5. **Release packaging:** App icon warnings, privacy policy, planner result cosmetic UI.  
6. **Documentation drift:** Priorities doc still lists fixed P0 sync as open.

---

## Reference: commit baseline

| Commit | Scope |
|--------|--------|
| `a75a6c3` | P0 inbound sync, P1 tombstones, GPS banner, alarm OK, sync strip, App Intents |
| `2e7cf12` | Secondary i18n (~240 keys) |
| `9def114` / `670386e` | Docs alignment, safety, TestFlight notes |
| `800bfa8` | Internal testing playbook + audit artifacts (this report supersedes 20260520 audit conclusions at `9def114`) |

---

*Audit-only · DIR DIVING · `main` @ `800bfa8` · 2026-05-22*
