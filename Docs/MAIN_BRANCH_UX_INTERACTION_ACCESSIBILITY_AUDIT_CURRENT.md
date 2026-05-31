# DIR DIVING — MAIN Branch UX / Interaction / Feature Accessibility Audit

**Date:** 2026-05-25  
**Branch audited:** `main` @ `ab398eb`
**Functional baseline on `main`:** stable MAIN including legal revision flow, inline ascent warning policy, compact GPS overlays, visible Watch `Start Dive`, App Intents catalog, iPhone -> Watch push, recent sync activity surfaces, Mission Mode on Watch, stopwatch reset safeguard, and aligned current documentation.
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
| Manual dive start | Yes | Yes | Yes | No | No | Yes | MEDIUM | Visible on-screen `Start Dive` path exists on the Watch surface/live state; automatic depth-driven lifecycle still needs real hardware QA. |
| Depth readout | Yes | Yes | Yes | No | No | No | LOW | Depth stays visually dominant on Live and respects unit preference. |
| TTV | Yes | Yes | Yes | No | No | No | LOW | Visible on Live; disclaimer copy clarifies it is informative, not decompression/TTS. |
| Runtime | Yes | Yes | Yes | No | No | No | LOW | Co-visible with TTV on Live. |
| Max / average depth | Yes | Yes | Yes | No | No | No | LOW | Shown below current depth when safety state allows. |
| Temperature | Yes | Yes | Yes | No | No | No | LOW | Visible in Live header and Compass in-dive metrics. |
| Stopwatch START / STOP / RESET | Yes | Yes | Yes | No | No | No | LOW | On-screen and via App Intents; reset now asks confirmation when there is active stopwatch time to clear. |
| Ascent gauge | Yes | Yes | Yes | No | No | No | LOW | Remains visible during ascent alarm banner. |
| Inline ascent alarm banner | Yes | Yes | Yes | No | No | No | LOW | Matches inline non-blocking policy; no modal takeover. |
| Depth safety 35 / 38 / 40 m UI | Yes | Yes | Yes | No | No | No | LOW | Banner + depth styling + haptic coordination. |
| GPS compact banner | Yes | Yes | Yes | No | No | No | LOW | Compact confirmation banner does not replace live metrics. |
| BUSSOLA / SET BEARING / CLEAR | Yes | Yes | Yes | No | No | No | LOW | Flow works and current stable labels/copy are aligned with localized MAIN terminology. |
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
| Sync status | Yes | Yes | Partial | No | No | Yes | MEDIUM | Aggregate status is supplemented by recent activity items; a persisted per-session delivery ledger is still not present. |
| Retry / clear sync queue | Yes | Yes | Yes | No | No | No | LOW | Present in watch Settings when queue is pending/failed. |
| Mission Mode | Yes | Yes | Yes | No | No | No | LOW | Watch setting is visible and local; activation is limited to active dive runtime. |
| Mission Mode active indicator | Yes | Yes | Yes | No | No | No | LOW | Small icon-only status indicator near the live header logo; visible only during active dive with Mission Mode active. |
| App Intents catalog | Yes | Partial | Partial | No | No | Yes | MEDIUM | Intents are compiled and metadata-extracted, but physical Watch QA is still required. |
| Shortcut help | Yes | Yes | Yes | No | No | No | LOW | Help screen honestly explains Action Button/Side Button limits. |
| Info / diagnostics | Yes | Yes | Yes | No | No | No | LOW | Useful diagnostics; copy now distinguishes static target config from real Apple provisioning/device validation. |
| Side button direct control | No | No | — | No | Intentionally | — | LOW | Correctly documented as system-controlled and not directly remappable by the app. |

### 1.2 iOS Companion MAIN

| Feature | Implemented | Reachable | Complete | Broken | Hidden | Partial | Severity | Notes |
|---------|-------------|-----------|----------|--------|--------|---------|----------|-------|
| Legal onboarding | Yes | Yes | Yes | No | No | No | LOW | `IOSLegalOnboardingView` blocks normal app entry until accepted. |
| Launch disclaimer | Yes | Yes | Yes | No | No | No | LOW | Session-based overlay after legal onboarding. |
| Tab navigation | Yes | Yes | Yes | No | No | No | LOW | Stable tab set: Planner, Logbook, Analysis, Equipment, More. |
| Planner | Yes | Yes | Yes | No | No | No | LOW | Safety acknowledgment, cylinders, gas roles/mixes, planning reference, warnings. |
| PlanResultView | Yes | Yes | Yes | No | No | No | LOW | Functional tabs and share action; stable MAIN labels are aligned with the current localization pass. |
| Logbook | Yes | Yes | Yes | No | No | No | LOW | Search, sections by month, add manual dive, delete non-demo entries. |
| Manual dive add | Yes | Yes | Yes | No | No | No | LOW | Accessible from Logbook header `+`. |
| Manual dive edit | Yes | Yes | Yes | No | No | No | LOW | Manual sessions expose edit action from detail view. |
| DiveDetail refresh after edit | Yes | Yes | Yes | No | No | No | LOW | `onChange(of: logStore.sessions)` refreshes edited session snapshot. |
| Analysis | Yes | Yes | Yes | No | No | No | LOW | Useful empty state, charts, metrics, route summary, CSV import. |
| CSV import | Yes | Yes | Yes | No | No | No | LOW | Reused `CSVImportPanel`; malformed rows reported. |
| CSV export | Yes | Yes | Yes | No | No | No | LOW | Per-dive export/share works from detail view. |
| Equipment | Yes | Yes | Yes | No | No | No | LOW | Checklist, GAS toggles, templates, and visible labels are aligned with the current stable localization pass. |
| More / settings | Yes | Yes | Yes | No | No | No | LOW | Units, language, watch sync, cloud backup, reviewer toggle, legal, import/export. |
| Watch sync | Yes | Yes | Partial | No | No | Yes | MEDIUM | Aggregate state, push-to-watch, reset trust, conflict resolution, and recent activity are present; no persisted per-session delivery ledger yet. |
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
| Mission Mode auto-enable | Yes | Yes | Yes | No | Watch-local setting; enabled only for post-start active dive runtime. |
| Legal / safety | Yes | Yes | Yes | No | Acceptance and current disclaimer visible. |
| GPS status | Yes | Read-only | Yes | No | Surface-only behavior explained. |
| Depth diagnostics | Yes | Read-only | Yes | No | Good diagnostics; current wording distinguishes target configuration from Apple entitlement/provisioning approval. |
| Sync queue status | Yes | Runtime state | Yes | N/A | Pending/sent/acknowledged/failed counters and retry/clear actions. |
| Export info | Info only | — | — | No | Export action lives in Dive Log, not Settings. |
| Brightness / Always-On | Info only | — | — | No | Honest watchOS-managed copy. |
| Audio tones | Info only | — | — | No | Honest: not implemented. |

**Intentional underwater limits**

- `AscentRateSettingsView`, `AlarmSettingsView`, units picker, and language picker are disabled during an active dive
- `SettingsView` shows a clear underwater advisory row explaining surface-only editing

**Inaccessible or missing watch settings**

- No user-facing Settings UI for fixed depth-safety band values (35 / 38 / 40 m)
- No separate persisted per-session sync ledger beyond the recent activity list
- No Settings UI for app-icon/cache troubleshooting, which remains documentation-only

**Truthfulness / documentation notes**

- `InfoView` copy is now aligned with the actual provisioning limitation: configured target != approved entitlement/profile
- `Docs/WATCH_MAIN_UX_CONVENTIONS.md` should be kept aligned with the compact GPS banner and auto-skip launch policy after future UI passes

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
- No dedicated persisted per-session sync ledger; current UI shows aggregate sync/conflict status plus recent activity

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
| Long press behavior | Minimal by design | No custom long-press workflow is required; destructive actions rely on explicit confirmation where needed, including stopwatch reset. |
| On-screen fallback for critical actions | Implemented | Stopwatch, manual dive start, bearing set/clear, alarm acknowledge all have visible on-screen paths. |

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
| UX-M-01 | MEDIUM | iOS | Planner remains metric internally despite global unit preference | Honest notice exists, but imperial users still encounter mixed behavior by design |
| UX-M-02 | MEDIUM | Both | No persisted per-session sync ledger yet; current UI shows summary/conflict state plus recent activity, not a full delivery history | Harder to prove end-to-end delivery for a specific dive over time |
| UX-L-01 | LOW | Docs/process | Historical docs can drift from the rolling MAIN state unless README, readiness audit, and UX conventions are refreshed together | Reviewer confusion risk rather than runtime failure |
| UX-L-02 | LOW | Build docs | Simulator names vary by installed runtime (`Ultra 2` vs `Ultra 3`) | QA instructions should always point to `xcodebuild -showdestinations` |

---

## 6. Safety Issues

| Issue | Severity | Notes |
|-------|----------|-------|
| Water-submersion entitlement not provisioned for generic device build | CRITICAL | Primary readiness blocker for physical dive automation validation. |
| Automatic depth flow still requires real Apple Watch Ultra QA | HIGH | Simulator success does not certify underwater behavior, sensor callbacks, or launch-on-submersion behavior. |
| Persisted proof of individual sync deliveries is limited | MEDIUM | Recent activity helps, but long-lived dive-by-dive delivery evidence is still lightweight. |
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
2. Physical underwater/device claims must remain aligned with verified behavior only.

### Post-release improvements

1. Add a persisted per-session sync ledger if deeper delivery diagnostics become a product requirement.
2. Keep README / readiness / UX conventions aligned whenever MAIN UX policy changes.

---

## 8. Code Impact Report

| Issue | Likely impact |
|------|---------------|
| Entitlement/profile approval for water-submersion | External QA / process |
| Persisted per-session sync ledger | Small functional fix to medium functional enhancement |
| Docs drift (`WATCH_MAIN_UX_CONVENTIONS`, simulator target naming) | Docs-only |

**Architectural assessment**

- No architectural rewrite is required by the current findings
- No planner algorithm rewrite is indicated
- No dive/depth/ascent/TTV algorithm change is recommended from this audit
- Remaining issues are primarily:
  - provisioning/process
  - paired-device evidence collection
  - lightweight diagnostics/docs maintenance

---

## 9. Final Summary

| Dimension | Estimate | Notes |
|-----------|----------|-------|
| Release readiness estimate | ~84% | MAIN simulator flows and repo-side UX/docs are coherent, but device release readiness is still blocked by the Watch entitlement/profile issue. |
| UX completeness estimate | ~93% | Most implemented MAIN features are reachable, understandable, and aligned with the current stable copy/localization pass. |
| Navigation completeness estimate | ~93% | No significant dead ends found; watch active-dive restrictions are coherent. |
| Settings completeness estimate | ~88% | Watch settings are strong; iOS settings are honest, with some expected watch-local boundaries. |
| Hardware interaction readiness estimate | ~85% | Crown and touch are well covered; App Intents are present but still need device QA. |
| Sync readiness estimate | ~86% | Core sync/conflict flows exist and recent activity improves visibility, but a persisted dive-specific ledger is still limited. |
| Safety completeness estimate | ~84% | Good legal/safety framing and non-blocking alarm UX; physical entitlement/device validation still missing. |
| Compile readiness estimate | ~90% | `xcodegen` and simulator builds pass, but generic device builds fail due to provisioning/entitlement. |

**TestFlight readiness verdict:** **Blocked** pending water-submersion entitlement/profile approval and physical Watch QA.  
**App Store readiness verdict:** **Not ready** for the same entitlement/device-evidence reason.

**Bottom line**

The current MAIN branch is **substantially reachable and internally coherent from a UI perspective** on simulator. The most important problems are **not** navigation dead ends or broken core screens anymore. The release-critical risks are:

1. physical-device build/provisioning for the Watch depth entitlement  
2. physical Apple Watch Ultra validation for auto-dive/depth behavior  
3. ongoing paired-device evidence collection and release QA

---

## 10. Deliverables

Created for this audit:

- `Docs/MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_CURRENT.md`
- `Docs/MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_CURRENT.docx`

DOCX generation script used for this audit:

- `Docs/generate_main_branch_ux_interaction_accessibility_audit_current_docx.py`

No application business logic was modified to produce this report.
