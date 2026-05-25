# DIR DIVING — MAIN Branch UX / Interaction / Feature Accessibility Audit

**Date:** 2026-05-25  
**Branch audited:** `main` @ `df9d886`  
**Functional baseline on `main`:** feature code previously landed through `d962117`; this audit covers the current branch state as checked out today.  
**Audit type:** Pre-modification audit of runtime UX, navigation, settings, hardware interaction, localization, sync UX, and build/release readiness.  
**Scope included:** Apple Watch MAIN target, iOS Companion MAIN target.  
**Scope excluded:** experimental branches and excluded sources in `project.yml` (`Snorkeling`, `Apnea`, `Buddy Assist`, exploration/experimental-only UI).  
**Reference UI:** `Docs/ReferenceUI/Watch_LIVE_reference.png`, `Docs/ReferenceUI/iOS_Companion_reference.png`, inline ascent banner conventions in `Docs/WATCH_MAIN_UX_CONVENTIONS.md`.  

**Build verification performed on macOS:**

- `xcodegen generate` — **PASS**
- `xcodebuild -scheme "DIRDiving Watch App" -destination 'generic/platform=watchOS' -configuration Debug build` — **FAIL**
- `xcodebuild -scheme "DIRDiving iOS" -destination 'generic/platform=iOS' -configuration Debug build` — **FAIL**
- `xcodebuild -scheme "DIRDiving Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Ultra 3 (49mm)' -configuration Debug build` — **PASS**
- `xcodebuild -scheme "DIRDiving iOS" -destination 'platform=iOS Simulator,name=iPhone 17' -configuration Debug build` — **PASS**

**Current device-build blocker:** `Config/DIRDiving.entitlements` declares `com.apple.developer.coremotion.water-submersion`, but the current provisioning/profile context does not include it. Generic device builds stop before physical-device QA:

> `Entitlement com.apple.developer.coremotion.water-submersion not found and could not be included in profile.`

This is the dominant release blocker in the current audit.

---

## 1. Feature Inventory

Legend:

- `Implemented`: present in MAIN target
- `Reachable`: accessible through normal user navigation
- `Complete`: flow can be completed without developer knowledge
- `Broken`: blocked in current runtime/build context
- `Hidden`: intentionally dormant/conditional
- `Partial`: usable, but with important caveats

### 1.1 Apple Watch MAIN

| Feature | Implemented | Reachable | Complete | Broken | Hidden | Partial | Severity | Notes |
|---------|-------------|-----------|----------|--------|--------|---------|----------|-------|
| Legal onboarding | Yes | Yes | Yes | No | No | No | LOW | `WatchLegalOnboardingView` hard-gates app access until acceptance. |
| Launch disclaimer | Yes | Yes | Yes | No | No | No | LOW | `LaunchCompanionDisclaimerOverlay` appears once per app launch after legal onboarding. |
| Live Dive default entry | Yes | Yes | Yes | No | No | No | LOW | `ContentView` defaults to `.live` when only Diving is stable. |
| Automatic dive lifecycle | Yes | Conditional | Partial | No | No | Yes | HIGH | Requires Watch hardware + approved water-submersion entitlement; simulator cannot certify it. |
| Manual dive fallback | Yes | Conditional | Yes | No | No | Yes | MEDIUM | Clear fallback path exists when depth automation is unavailable; intentionally absent when automation is available. |
| Depth readout | Yes | Yes | Yes | No | No | No | LOW | Depth stays visually dominant on Live and respects unit preference. |
| TTV | Yes | Yes | Yes | No | No | No | LOW | Visible on Live; disclaimer copy clarifies it is informative, not decompression/TTS. |
| Runtime | Yes | Yes | Yes | No | No | No | LOW | Co-visible with TTV on Live. |
| Max / average depth | Yes | Yes | Yes | No | No | No | LOW | Shown below current depth when safety state allows. |
| Temperature | Yes | Yes | Yes | No | No | No | LOW | Visible in Live header and Compass in-dive metrics. |
| Stopwatch START / STOP / RESET | Yes | Yes | Yes | No | No | No | LOW | On-screen and via App Intents; reset has no extra confirmation guard. |
| Ascent gauge | Yes | Yes | Yes | No | No | No | LOW | Remains visible during ascent alarm banner. |
| Inline ascent alarm banner | Yes | Yes | Yes | No | No | No | LOW | Matches inline non-blocking policy; no modal takeover. |
| Depth safety 35 / 38 / 40 m UI | Yes | Yes | Yes | No | No | No | LOW | Banner + depth styling + haptic coordination. |
| GPS compact banner | Yes | Yes | Yes | No | No | No | LOW | Compact confirmation banner does not replace live metrics. |
| BUSSOLA / SET BEARING / CLEAR | Yes | Yes | Partial | No | No | Yes | MEDIUM | Flow works; on-screen control labels remain partly non-localized. |
| Dive log list | Yes | Yes | Yes | No | No | No | LOW | Clean list, delete affordance, latest export action, empty state. |
| Dive detail | Yes | Yes | Yes | No | No | No | LOW | Back affordance present; export/delete available. |
| Delete confirmation | Yes | Yes | Yes | No | No | No | LOW | Confirmation dialog present in log list/detail flows. |
| Subsurface CSV export | Yes | Yes | Yes | No | No | No | LOW | Export completion + share flow present. |
| User Images tab behavior | Yes | Yes | Yes | No | No | No | LOW | Surface-only access through main `TabView`; clear empty state when no images exist. |
| Settings hub | Yes | Yes | Yes | No | No | No | LOW | Rich watch settings root with status, actions, and pushes. |
| Ascent-rate settings | Yes | Yes | Yes | No | No | No | LOW | `AscentRateSettingsView` reachable and simulator-buildable; Crown tuning works in code path. |
| Alarm settings | Yes | Yes | Yes | No | No | No | LOW | Toggle + threshold UI for ascent, depth, runtime, battery. |
| Units | Yes | Yes | Yes | No | No | No | LOW | Watch display switches metric/imperial; published to paired iPhone via app context. |
| Language | Yes | Yes | Yes | No | No | No | LOW | Watch-local setting in `SettingsView`. |
| Haptics toggle | Yes | Yes | Yes | No | No | No | LOW | Global watch haptic toggle is respected by `HapticService`. |
| Sync status | Yes | Yes | Partial | No | No | Yes | MEDIUM | Aggregate counts/status available; no per-session sync timeline. |
| Retry / clear sync queue | Yes | Yes | Yes | No | No | No | LOW | Present in watch Settings when queue is pending/failed. |
| App Intents catalog | Yes | Partial | Partial | No | No | Yes | MEDIUM | Intents are compiled and metadata-extracted, but physical Watch QA is still required. |
| Shortcut help | Yes | Yes | Yes | No | No | No | LOW | Help screen honestly explains Action Button/Side Button limits. |
| Info / diagnostics | Yes | Yes | Partial | No | No | Yes | MEDIUM | Useful diagnostics, but entitlement status copy can overstate readiness versus actual provisioning. |
| Side button direct control | No | No | — | No | Intentionally | — | LOW | Correctly documented as system-controlled and not directly remappable by the app. |

### 1.2 iOS Companion MAIN

| Feature | Implemented | Reachable | Complete | Broken | Hidden | Partial | Severity | Notes |
|---------|-------------|-----------|----------|--------|--------|---------|----------|-------|
| Legal onboarding | Yes | Yes | Yes | No | No | No | LOW | `IOSLegalOnboardingView` blocks normal app entry until accepted. |
| Launch disclaimer | Yes | Yes | Yes | No | No | No | LOW | Session-based overlay after legal onboarding. |
| Tab navigation | Yes | Yes | Yes | No | No | No | LOW | Stable tab set: Planner, Logbook, Analysis, Equipment, More. |
| Planner | Yes | Yes | Yes | No | No | No | LOW | Safety acknowledgment, cylinders, gas roles/mixes, planning reference, warnings. |
| PlanResultView | Yes | Yes | Partial | No | No | Yes | MEDIUM | Functional tabs and share action; some visible labels remain hardcoded English. |
| Logbook | Yes | Yes | Yes | No | No | No | LOW | Search, sections by month, add manual dive, delete non-demo entries. |
| Manual dive add | Yes | Yes | Yes | No | No | No | LOW | Accessible from Logbook header `+`. |
| Manual dive edit | Yes | Yes | Yes | No | No | No | LOW | Manual sessions expose edit action from detail view. |
| DiveDetail refresh after edit | Yes | Yes | Yes | No | No | No | LOW | `onChange(of: logStore.sessions)` refreshes edited session snapshot. |
| Analysis | Yes | Yes | Yes | No | No | No | LOW | Useful empty state, charts, metrics, route summary, CSV import. |
| CSV import | Yes | Yes | Yes | No | No | No | LOW | Reused `CSVImportPanel`; malformed rows reported. |
| CSV export | Yes | Yes | Yes | No | No | No | LOW | Per-dive export/share works from detail view. |
| Equipment | Yes | Yes | Partial | No | No | Yes | MEDIUM | Checklist + gas toggles + templates work; a few visible strings remain partially unlocalized or mixed-language. |
| More / settings | Yes | Yes | Yes | No | No | No | LOW | Units, language, watch sync, cloud backup, reviewer toggle, legal, import/export. |
| Watch sync | Yes | Yes | Partial | No | No | Yes | MEDIUM | Aggregate state, push-to-watch, reset trust, conflict resolution present; no per-session delivery UI. |
| Conflict UI | Yes | Yes | Yes | No | No | No | LOW | Incoming/local conflict card is actionable. |
| Push to Watch | Yes | Yes | Yes | No | No | No | LOW | `syncUnpushedSessionsToWatch()` exposed in More. |
| Reset pairing trust | Yes | Yes | Yes | No | No | No | LOW | Explicit destructive confirmation flow in More. |
| iCloud KVS | Yes | Yes | Partial | No | No | Yes | MEDIUM | Decode failures are surfaced; cloud availability is transparent; physical account-state QA still required. |
| Demo logbook | Yes | Yes | Yes | No | No | No | LOW | Reviewer support present and clearly scoped. |
| Language | Yes | Yes | Yes | No | No | No | LOW | `.environment(\.locale)` applied at app root. |
| Units | Yes | Yes | Partial | No | No | Yes | MEDIUM | Global units work broadly, but planner remains metric internally and warns about it. |
| Safety disclaimer | Yes | Yes | Yes | No | No | No | LOW | Legal and planner safety disclaimers are visible and explicit. |
| TestFlight / reviewer readiness notes surfaced in UI | Partial | Yes | Partial | No | No | Yes | LOW | Demo/reviewer toggle exists; broader TestFlight/device-readiness remains doc-driven, not fully in-app. |

---

## 2. Navigation Map

### 2.1 Apple Watch MAIN

```text
DIRDivingApp
└─ NavigationStack
   ├─ [if required] WatchLegalOnboardingView
   └─ ContentView (TabView, vertical page style)
      ├─ [hidden by policy] ModeSelectionView
      ├─ DiveLiveView
      ├─ CompassView (BUSSOLA)
      ├─ SettingsView
      │  ├─ AscentRateSettingsView
      │  ├─ AlarmSettingsView
      │  ├─ WatchLegalSafetyView
      │  ├─ WatchShortcutHelpView
      │  └─ InfoView
      ├─ UserImagesView
      │  └─ in-view detail state
      └─ DiveLogListView
         ├─ DiveDetailView
         │  └─ ExportView
         └─ latest-export flow

Overlay after legal gate:
└─ LaunchCompanionDisclaimerOverlay
```

**Entry points**

- Fresh install: legal onboarding
- Accepted user: launch disclaimer, then `DiveLiveView`
- Surface navigation: vertical Crown/swipe paging across Live, BUSSOLA, Settings, User Images, Dive Log

**Underwater restrictions**

- While `dive.isDiveActive`, `ContentView` forces navigation back to `Live` unless the target page is `Live` or `Compass`.
- Result: Settings, User Images, and Dive Log are intentionally unavailable during an active dive.
- This is safer and more restrictive than older docs that still describe Dive Log as reachable underwater.

**Return paths**

- Pushed watch sub-screens use `watchSubscreenBackToolbar()` or `WatchDetailBackButton()`
- User image detail returns to its list in-place
- ExportView and DiveDetailView have explicit back affordances

**Dead ends / hidden routes**

- No confirmed dead ends on MAIN
- `ModeSelectionView` is intentionally dormant because `WatchModeSelectionPreferences.hasMultipleStableModes` is false
- `UserImagesView` is always part of the surface `TabView`, but content usefulness depends on received images; empty state is clear

### 2.2 iOS Companion MAIN

```text
DIRDivingiOSApp
├─ [if required] IOSLegalOnboardingView
└─ ContentView (TabView)
   ├─ Planner
   │  └─ PlanResultView
   ├─ Logbook
   │  ├─ DiveDetailView
   │  │  └─ ManualDiveEditorView (manual dives only)
   │  └─ ManualDiveEditorView (add)
   ├─ Analysis
   ├─ Equipment
   │  └─ EquipmentTemplatesSheet
   │     └─ EquipmentTemplateEditorView
   └─ More
      └─ IOSLegalSafetyView

Overlay after legal gate:
└─ LaunchCompanionDisclaimerOverlay
```

**Entry points**

- Fresh install: iOS legal onboarding
- Accepted user: tab bar opens on Planner
- Logbook `+`: manual dive creation
- More: watch sync actions, pairing reset, cloud sync, legal, reviewer toggle, photo-to-watch

**Return paths**

- Standard `NavigationStack` on all iOS main tabs
- `ManualDiveEditorView` exposes both Cancel and Save toolbar actions
- `DiveDetailView` refreshes after edits instead of getting stuck with stale state

**Dead ends / hidden routes**

- No broken push/pop paths found in MAIN
- No decorative tappable controls were found that incorrectly imply navigation, except for some planner mode tabs that look selectable but intentionally disable non-advanced modes

**Main route honesty findings**

- Planner route is truthful about metric-only internals via `planner.units.metric_notice`
- Analysis empty state gives meaningful next actions (`import`, `sync`, `open logbook`)
- More centralizes settings rather than pretending there is a separate settings app

---

## 3. Settings Report

### 3.1 Watch settings

| Setting | UI exposed | Persisted | Applied | Synced | Notes |
|--------|------------|-----------|---------|--------|------|
| Units | Yes | Yes | Yes | Yes | Published to paired iPhone via `applicationContext`. |
| Language | Yes | Yes | Yes | No | Watch-local only; scope note is visible. |
| Haptics | Yes | Yes | Yes | No | `dirdiving_watch_haptics_enabled`. |
| Ascent limits | Yes | Yes | Yes | No | Stored via `AscentRateSettingsStore`; cloud-backed on Watch side. |
| Alarm toggles + thresholds | Yes | Yes | Yes | No | Watch-local by design. |
| Legal / safety | Yes | Yes | Yes | No | Acceptance and current disclaimer visible. |
| GPS status | Yes | Read-only | Yes | No | Surface-only behavior explained. |
| Depth diagnostics | Yes | Read-only | Yes | No | Good diagnostics, but wording around entitlement readiness is too optimistic. |
| Sync queue status | Yes | Runtime state | Yes | N/A | Pending/sent/acknowledged/failed counters and retry/clear actions. |
| Export info | Info only | — | — | No | Export action lives in Dive Log, not Settings. |
| Brightness / Always-On | Info only | — | — | No | Honest watchOS-managed copy. |
| Audio tones | Info only | — | — | No | Honest: not implemented. |

**Intentional underwater limits**

- `AscentRateSettingsView`, `AlarmSettingsView`, units picker, and language picker are disabled during an active dive
- `SettingsView` shows a clear underwater advisory row explaining surface-only editing

**Inaccessible or missing watch settings**

- No user-facing Settings UI for fixed depth-safety band values (35 / 38 / 40 m)
- No separate user-facing UI to inspect per-session sync history
- No Settings UI for app-icon/cache troubleshooting, which remains documentation-only

**Misleading or outdated copy**

- `InfoView` reports entitlement configuration using bundle/static diagnostics, while the current generic device build proves the active provisioning context is not ready
- `Docs/WATCH_MAIN_UX_CONVENTIONS.md` is stale in two areas:
  - it still mentions mode selection as an accepted launch behavior, while `main` now skips it
  - it still mentions a full-screen GPS confirmation overlay, while `DiveLiveView` uses a compact inline banner

### 3.2 iOS settings

| Setting | UI exposed | Persisted | Applied | Synced | Notes |
|--------|------------|-----------|---------|--------|------|
| Language | Yes | Yes | Yes | No | App-wide locale environment. |
| Units | Yes | Yes | Yes | Partial | Sent to Watch; planner still uses metric internals. |
| Watch sync support/state | Yes | Runtime state | Yes | N/A | MoreView shows supported/state/last event. |
| Push all to Watch | Yes | Runtime action | Yes | N/A | Clear surface action in More. |
| Reset pairing trust | Yes | Runtime action | Yes | N/A | Good destructive confirmation. |
| iCloud sync now | Yes | Runtime action | Yes | iCloud | Availability and last status surfaced. |
| Demo logbook | Yes | Yes | Yes | No | Reviewer/testing feature. |
| Planner safety acknowledgment | Yes | Yes | Yes | No | Gates planner inputs until acknowledged. |
| Legal / safety | Yes | Yes | Yes | No | Dedicated push to `IOSLegalSafetyView`. |
| CSV import | Yes | Runtime action | Yes | N/A | Available from More, Logbook, Analysis. |
| CSV export | Yes | Route exists | Yes | N/A | Exposed from per-dive detail, not from More. |

**Missing iOS settings UI**

- No iOS UI to directly edit watch-side alarm thresholds or watch haptics
- No notification/sound policy UI because iOS notifications are not implemented in MAIN
- No dedicated per-session sync ledger; only aggregate sync/conflict status

**Local-only or unsynced by design**

- Planner safety acknowledgment is local to iOS
- Watch alarms, watch haptics, and watch language remain watch-local
- Demo logbook is not intended to sync as a user feature

---

## 4. Hardware Interaction Report

### 4.1 Crown, touch, buttons

| Interaction | Status | Notes |
|-------------|--------|-------|
| Digital Crown vertical page navigation | Implemented | `ContentView` uses `.tabViewStyle(.verticalPage)`; consistent with watchOS paging. |
| Crown scroll on long screens | Implemented | Scroll-based watch views inherit native scroll behavior. |
| Crown value adjustment for alarms | Implemented | `AlarmSettingsView` uses `.digitalCrownRotation(...)`. |
| Crown value adjustment for ascent limits | Implemented | `AscentRateSettingsView` uses `.digitalCrownRotation(...)`. |
| Touch navigation | Implemented | Primary navigation and confirmation path across both apps. |
| Swipe navigation on Watch | Implemented | Vertical page movement via watchOS `TabView`. |
| Side Button direct control | Not supported | Correctly documented as system-controlled; no false hardware-override claim found. |
| Long press behavior | Mostly absent | No custom long-press guard on watch stopwatch reset or other critical controls. |
| On-screen fallback for critical actions | Implemented | Stopwatch, manual dive fallback, bearing set/clear, alarm acknowledge all have visible on-screen paths. |

### 4.2 App Intents catalog

`Services/ActionButtonIntents.swift` implements all requested MAIN intents:

| Intent | Implemented | Exposed in build metadata | Safe in design | Understandable | Documented | Physical Watch QA required |
|--------|-------------|---------------------------|----------------|----------------|------------|---------------------------|
| `ToggleStopwatchIntent` | Yes | Yes | Yes | Yes | Yes | Yes |
| `ResetStopwatchIntent` | Yes | Yes | Mostly | Yes | Yes | Yes |
| `StartManualDiveIntent` | Yes | Yes | Yes | Yes | Yes | Yes |
| `EndManualDiveIntent` | Yes | Yes | Yes | Yes | Yes | Yes |
| `SetBearingIntent` | Yes | Yes | Yes | Yes | Yes | Yes |
| `ClearBearingIntent` | Yes | Yes | Yes | Yes | Yes | Yes |
| `AcknowledgeAlarmIntent` | Yes | Yes | Yes | Yes | Yes | Yes |

**Evidence**

- `xcodebuild` simulator output includes `ExtractAppIntentsMetadata`
- `Docs/APP_INTENTS_DEVICE_QA_CHECKLIST.md` and `WatchShortcutHelpView` document the intended user path

**Remaining QA gap**

- App Intents are code-complete and metadata-complete, but still require physical Watch validation through Shortcuts / Action Button mapping

### 4.3 Haptic event audit

| Event | Status | Notes |
|-------|--------|-------|
| Dive start | Implemented | `criticalConfirm()` in `DiveManager.beginDiveIfNeeded`. |
| Dive stop | Implemented | `criticalConfirm()` in `DiveManager.endDiveIfNeeded`. |
| Stopwatch start / stop / reset | Implemented | Generic confirmation haptic, not distinct per action. |
| Ascent warning | Implemented | Initial + repeated failure haptic with throttle. |
| Depth safety 35 / 38 / 40 | Implemented | `DepthLimitHapticCoordinator`. |
| GPS confirmation | Implemented | Confirmation on successful lifecycle points. |
| Bearing SET / CLEAR | Implemented | Confirmation haptic from on-screen and intent path. |
| Alarm acknowledge | Implemented | `dismissAlarmWarning()` calls `notify()`. |
| Export success / failure | Implemented | Confirm on success, notify on failure. |
| Sync retry / success / failure | Partial | Retry button produces confirmation; runtime sync state has visual feedback, but not every state transition has a unique haptic. |
| Delete confirmation | Partial | Confirmation dialog exists; delete action itself does not expose a distinct dedicated haptic pattern. |

**Haptic conclusions**

- Global haptics toggle is consistently respected
- Safety events have visual fallback when haptics are off (`hapticsOffBadge`)
- No evidence of full-screen alarm takeover replacing visuals
- No evidence of excessive repeated ascent haptics beyond the intended repeat interval

---

## 5. UX Blockers

| ID | Severity | Platform | Blocker | Impact |
|----|----------|----------|---------|--------|
| UX-CR-01 | CRITICAL | Watch + iOS release | Generic device builds fail because the Watch target entitlement/profile is not approved in the active provisioning context | Blocks TestFlight/archive/device validation for the embedded app pair |
| UX-H-01 | HIGH | Watch | Automatic depth / submersion lifecycle cannot be fully verified without Apple Watch Ultra hardware and approved entitlement | Core diving flow remains only simulator-verified, not device-verified |
| UX-H-02 | HIGH | Legal/release | Terms and Privacy buttons in watchOS and iOS legal screens both point to the repository root instead of dedicated legal destinations | Weakens reviewer/legal clarity and can become an App Store blocker |
| UX-M-01 | MEDIUM | Watch | `InfoView` entitlement wording can imply readiness even when device builds still fail on provisioning | Misleading diagnostics for testers/reviewers |
| UX-M-02 | MEDIUM | iOS | Planner result areas remain partly mixed-language / unlocalized (`GAS RESERVE`, `Rock bottom`, `BRIEFING`, `TEAM GAS MATCH`, `CURVA BUHLMANN ZH-L16C`) | EN/IT consistency is incomplete in a high-value flow |
| UX-M-03 | MEDIUM | Watch | Compass primary controls remain mixed-language and partly hardcoded (`SET BEARING`, dynamic bearing/delta line) | Watch localization consistency gap in a core navigation screen |
| UX-M-04 | MEDIUM | iOS | Planner shows multiple mode tabs while only `advanced` is actually selectable | Disabled-but-visible modes create expectation of unavailable features |
| UX-M-05 | MEDIUM | iOS | Planner remains metric internally despite global unit preference | Honest notice exists, but imperial users still encounter mixed behavior |
| UX-M-06 | MEDIUM | Both | Per-session sync visibility is missing; UI is aggregate (`lastMessage`, counts, conflicts) rather than dive-specific | Harder to audit whether a specific dive or photo has synced |
| UX-L-01 | LOW | Watch | No extra confirmation or long-press safeguard on stopwatch reset | Accidental reset is possible underwater/surface |
| UX-L-02 | LOW | Docs/process | `Docs/WATCH_MAIN_UX_CONVENTIONS.md` no longer matches current MAIN behavior for GPS banner and mode selection | Audit docs and implementation are out of sync |
| UX-L-03 | LOW | Build docs | Requested Watch Ultra 2 simulator destination was unavailable locally; installed runtime uses Ultra 3 | QA instructions need a more resilient simulator note |

---

## 6. Safety Issues

| Issue | Severity | Notes |
|-------|----------|-------|
| Water-submersion entitlement not provisioned for generic device build | CRITICAL | Primary readiness blocker for physical dive automation validation. |
| Automatic depth flow still requires real Apple Watch Ultra QA | HIGH | Simulator success does not certify underwater behavior, sensor callbacks, or launch-on-submersion behavior. |
| Info diagnostics overstate entitlement readiness | MEDIUM | `InfoView` can show "Configured" even when current device builds fail on entitlement/profile. |
| Terms / Privacy destinations are weak | MEDIUM | Legal access exists, but the destination quality is not yet release-grade. |
| Planner claims | LOW | Current copy is generally safe: planner is clearly informational and non-certified; metric notice is honest. |
| TTV wording | LOW | Current watch/iOS copy explains TTV is informative and not decompression/TTS. |
| GPS underwater expectations | LOW | UI consistently frames GPS as surface-only and distinguishes fix/fallback/no-fix. |
| Safety alarm presentation | LOW | Current watch design is correct: inline, non-blocking, metrics remain visible. |
| Haptics-off fallback | LOW | Visual fallback is present; no safety-only reliance on haptics found. |

### Localization audit — remaining notable gaps

The codebase is much better localized than older audits suggested. Many exact-string SwiftUI literals are backed by entries in `Resources/*.lproj` or `iOSApp/Resources/*.lproj`. The remaining visible gaps verified in current code are:

| File | String | Screen | Severity | Suggested key |
|------|--------|--------|----------|---------------|
| `Views/CompassView.swift` | `SET BEARING` | Watch `BUSSOLA` | MEDIUM | `compass.bearing.set` |
| `Views/CompassView.swift` | `BEARING \(bearingText) \| DELTA \(deltaText)` | Watch `BUSSOLA` | MEDIUM | `compass.bearing.delta_format` |
| `Views/InfoView.swift` | `INFO` | Watch Info | LOW | `info.title` |
| `Views/InfoView.swift` | `Sync` | Watch Info | LOW | `info.sync` |
| `Views/InfoView.swift` | `Richiede validazione reale su Apple Watch Ultra...` | Watch Info | MEDIUM | `info.depth.validation_note` |
| `iOSApp/Views/PlannerView.swift` | `GAS RESERVE` | iOS Planner | LOW | `planner.card.reserve` |
| `iOSApp/Views/PlannerView.swift` | `Rock bottom` | iOS Planner | LOW | `planner.metric.rock_bottom` |
| `iOSApp/Views/PlannerView.swift` | `Turn` | iOS Planner | LOW | `planner.metric.turn_pressure` |
| `iOSApp/Views/PlannerView.swift` | `WARNING` | iOS Planner warnings card | LOW | `planner.warning.title` |
| `iOSApp/Views/PlannerView.swift` | `TEAM GAS MATCHING` | iOS Planner | LOW | `planner.team.matching_title` |
| `iOSApp/Views/PlannerView.swift` | `GF Low` / `GF High` | iOS Planner | LOW | `planner.field.gf_low`, `planner.field.gf_high` |
| `iOSApp/Views/PlannerView.swift` | `SAC %@ L/min` | iOS Planner team card | LOW | `planner.team.sac_format` |
| `iOSApp/Views/PlannerView.swift` | `"%@ L - %@”` contingency line | iOS Planner contingencies | LOW | `planner.contingency.line_format` |
| `iOSApp/Views/PlannerView.swift` | `TEAM GAS MATCH` | iOS Plan Result | LOW | `planner.team.match_title` |
| `iOSApp/Views/PlannerView.swift` | `BRIEFING` | iOS Plan Result | LOW | `planner.briefing.title` |
| `iOSApp/Views/PlannerView.swift` | `CURVA BUHLMANN ZH-L16C` | iOS Plan Result | LOW | `planner.buhlmann.curve_title` |
| `Views/DiveLiveView.swift` | `TTV sessione ...` accessibility label | Watch Live a11y | LOW | `live.ttv_runtime.a11y` |

**BUSSOLA terminology check**

- No `COMPASSO` regression was found in MAIN
- Watch help and current UI continue to use `BUSSOLA` where the product expects it

---

## 7. Recommended Priority Order

### Immediate fixes

1. Resolve the Apple Developer / provisioning issue for `com.apple.developer.coremotion.water-submersion`.
2. Re-run generic device builds for both schemes after profile regeneration.
3. Validate automatic dive lifecycle, depth display, safety bands, and haptics on a real Apple Watch Ultra.

### Pre-release fixes

1. Replace repository-root Terms/Privacy links with reviewer-grade legal destinations.
2. Tighten watch diagnostics copy so entitlement status is reported honestly.
3. Finish the remaining planner and compass localization pass.
4. Decide whether disabled planner mode tabs should remain visible or be visually re-framed as future modes.

### TestFlight blockers

1. Generic watchOS device build must pass.
2. Generic iOS device build must pass with embedded Watch target.
3. Apple Watch Ultra device QA must confirm submersion lifecycle and depth safety UI.
4. Action Button / Shortcuts intent matrix must be executed once on hardware.

### App Store blockers

1. Same entitlement/device items as TestFlight blockers.
2. Dedicated legal destination quality should be improved before submission.
3. Physical underwater/device claims must remain aligned with verified behavior only.

### Post-release improvements

1. Add per-session sync visibility instead of aggregate-only status.
2. Consider a deliberate guard for stopwatch reset.
3. Refresh stale docs (`WATCH_MAIN_UX_CONVENTIONS`, simulator references) so implementation and QA docs stay aligned.

---

## 8. Code Impact Report

| Issue | Likely impact |
|------|---------------|
| Entitlement/profile approval for water-submersion | External QA / process |
| Terms / Privacy destination cleanup | Copy-only / docs / small UI wiring |
| Watch `InfoView` entitlement wording | Copy-only |
| Watch compass localization cleanup | Small UI fix |
| Planner result localization cleanup | Small UI fix |
| Planner disabled-tab affordance refinement | Small UI fix |
| Per-session sync visibility | Small functional fix to medium functional enhancement |
| Stopwatch reset safety guard | Small UI / small functional fix |
| Docs drift (`WATCH_MAIN_UX_CONVENTIONS`, simulator target naming) | Docs-only |

**Architectural assessment**

- No architectural rewrite is required by the current findings
- No planner algorithm rewrite is indicated
- No dive/depth/ascent/TTV algorithm change is recommended from this audit
- Remaining issues are primarily:
  - provisioning/process
  - copy/localization
  - small UI honesty/discoverability improvements

---

## 9. Final Summary

| Dimension | Estimate | Notes |
|-----------|----------|-------|
| Release readiness estimate | ~72% | Main simulator flows are healthy, but device release readiness is blocked by the Watch entitlement/profile issue. |
| UX completeness estimate | ~86% | Most implemented MAIN features are reachable and understandable. |
| Navigation completeness estimate | ~91% | No significant dead ends found; watch active-dive restrictions are coherent. |
| Settings completeness estimate | ~84% | Watch settings are strong; iOS settings are honest, with some expected watch-local gaps. |
| Hardware interaction readiness estimate | ~83% | Crown and touch are well covered; App Intents are present but still need device QA. |
| Sync readiness estimate | ~80% | Core sync/conflict flows exist; dive-specific delivery visibility remains limited. |
| Safety completeness estimate | ~82% | Good legal/safety framing and non-blocking alarm UX; physical entitlement/device validation still missing. |
| Compile readiness estimate | ~85% | Simulator builds pass, but generic device builds fail due to provisioning/entitlement. |

**TestFlight readiness verdict:** **Blocked** pending water-submersion entitlement/profile approval and physical Watch QA.  
**App Store readiness verdict:** **Not ready** for the same reason, plus legal-link quality should be improved before submission.

**Bottom line**

The current MAIN branch is **substantially reachable and internally coherent from a UI perspective** on simulator. The most important problems are **not** navigation dead ends or broken core screens anymore. The release-critical risks are:

1. physical-device build/provisioning for the Watch depth entitlement  
2. physical Apple Watch Ultra validation for auto-dive/depth behavior  
3. a smaller cleanup pass for mixed-language UI and legal/reviewer polish

---

## 10. Deliverables

Created for this audit:

- `Docs/MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_CURRENT.md`
- `Docs/MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_CURRENT.docx`

DOCX generation script used for this audit:

- `Docs/generate_main_branch_ux_interaction_accessibility_audit_current_docx.py`

No application business logic was modified to produce this report.
