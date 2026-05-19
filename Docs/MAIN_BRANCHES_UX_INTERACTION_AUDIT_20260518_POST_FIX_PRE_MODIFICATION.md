# DIR DIVING - Complete UX / Interaction / Feature Accessibility Audit

Pre-modification report after current MAIN fixes  
Date: 2026-05-18  
Scope: Apple Watch MAIN branch and iOS Companion MAIN branch only

## Executive Summary

This audit inspected the current MAIN worktrees:

- Apple Watch MAIN: `C:\Users\egopf\Documents\GitHub\DirDiving-App` on branch `main`.
- iOS Companion MAIN: `C:\Users\egopf\Documents\GitHub\DirDiving-App-main-iOS-ui` on branch `main-iOS`.

No runtime code was modified for this audit. Experimental Apnea, Snorkeling, Buddy Assist and experimental-only files were not audited as product features. They were considered only for MAIN target isolation. Current target membership still excludes the Watch experimental files through `project.yml`; the iOS-only worktree includes the stable `iOSApp` source root and no experimental tab is exposed by `ContentView`.

Release readiness is currently blocked by two likely compile issues:

1. Watch `AscentWarningView` calls `Formatters.zero`, but Watch `Utils/Formatters.swift` defines only `time` and `one`.
2. iOS `PlannerView.swift` appears structurally invalid near `ResultPanelStyle` and `PlanTab`; `PlanTab` is nested under `ResultPanelStyle` instead of clearly closed at file scope.

Because Apple tooling is unavailable on this Windows host, `xcodegen generate` and `xcodebuild` must still be run on macOS to confirm the full build.

## 1. Feature Inventory

### Apple Watch MAIN

1. Mode selection: implemented and reachable from the first vertical `TabView` page. Only Diving is exposed on MAIN. Complete for current stable scope.
2. Live dive screen: implemented and reachable. Displays current depth, max/average depth, temperature, TTV, runtime, ascent gauge, stopwatch controls, haptics-off badge, GPS confirmations and ascent warning. Blocked by the missing `Formatters.zero` compile issue in the warning path.
3. Automatic dive lifecycle: implemented through CoreMotion water-submersion callbacks. UI entry exists, but release completeness depends on entitlement/profile and real Apple Watch Ultra validation.
4. Manual dive fallback: implemented and reachable when depth automation is unavailable. Risk: if hardware is initially reported available but later fails, manual fallback may not become visible quickly enough.
5. Stopwatch: implemented through visible START/STOP/RESET controls and App Intents. Controls are reachable and haptic-enabled. Shortcut failure now reports unavailable app state instead of silently succeeding.
6. GPS entry/exit capture: implemented. Success, fallback and no-fix states are visually distinct, and new GPS fix-source metadata persists real fix, fallback or no-fix.
7. Ascent warning: implemented with live depth/runtime context. Compile issue must be fixed. UX remains dense on smaller watches and still replaces most normal live-screen context.
8. Compass: implemented and reachable as a vertical page. Set/clear bearing actions are visible and haptic-enabled. Calibration/permission recovery copy is limited.
9. Alarms: ascent, depth, runtime and battery alarms are implemented and configurable from settings. Persistence exists. Device QA is still required.
10. Haptics: implemented globally and configurable. Used for safety warnings, confirmations, GPS, compass, export and sync. Haptics-off is visible during active dives.
11. Dive log list: implemented and reachable. Rows open detail, export latest is available, delete remains available through context menu.
12. Dive detail: implemented and reachable. Summary, GPS metadata, export/share and visible delete confirmation are present.
13. Subsurface export on Watch: implemented from detail/list flows. Export creates a local CSV and uses a share flow; wording can still imply cloud upload in some completion states.
14. UserImages: implemented as a tab, but no bundled assets are present. The UI now shows an empty state; it is understandable but remains low-value as a release feature.
15. Settings: implemented and reachable. Includes ascent limits, alarms, unit picker, GPS/depth/sync/export status, haptics, shortcut help and Info diagnostics.
16. Info diagnostics: implemented and reachable. Shows version, device, battery, sync and depth entitlement/sensor/callback information with real-device validation warning.
17. Watch sync queue: implemented and visible. Retry and clear-queue controls exist. Delivery truthfulness remains weak because queue status cannot fully confirm transfer delivery.

### iOS Companion MAIN

1. Tab navigation: implemented and reachable. Tabs: Logbook, Explore, Analysis, Planner, Gear and Settings.
2. Logbook: implemented and reachable. Search, dynamic month grouping, CSV import, delete confirmation, detail navigation and demo logbook filtering are present.
3. CSV import: implemented and reachable from Logbook, Explore and Analysis. Quoted-field parsing and partial import summaries exist. Safety validation is still weaker than Watch sync validation.
4. Dive detail: implemented and reachable. Summary, charts, details, GPS fix-source labels, CSV export/share and unit conversion are present.
5. Explore: implemented and reachable. Route review uses entry/exit GPS only. Empty state now provides separate Apple Watch sync, iCloud sync, CSV import and system settings actions.
6. Analysis: implemented and reachable. Empty state includes CSV import, Watch sync and open Logbook actions.
7. Planner: implemented and reachable in design, but likely blocked by `PlannerView.swift` structure. Simple mode is usable by intent, advanced/technical are marked Planned, validation and safety acknowledgement exist.
8. Planner result: implemented in the same file. Result tabs, warnings, ascent table and chart exist, but compile structure must be corrected before this can be considered reachable.
9. Equipment/Gear: implemented and reachable. Editable profile, checklist, reset confirmation and subtle saved feedback exist. Auto-save is persisted.
10. Settings/More: implemented and reachable. Units, notification status, Watch sync status, trust reset/re-pair, cloud backup, demo toggle, export roadmap and safety warning are visible.
11. Watch sync: implemented with trust hardening, HMAC validation, conflict list, retry and reset trust. Settings sync is not bidirectional.
12. Cloud backup: implemented via iCloud KVS and local storage. Merge policy is documented in UI, but cloud conflicts are not fully previewable or resolvable per field.
13. Export: implemented from dive detail. Settings lists Subsurface CSV as default and GPX/UDDF as Planned.

## 2. Navigation Map

### Apple Watch MAIN

Root: `NavigationStack` -> `ContentView` -> vertical `TabView`.

Pages:

1. `ModeSelectionView`: tap Diving to move to the live page.
2. `DiveLiveView`: pre-dive, active dive, manual fallback, ascent warning and GPS confirmation states swap in place.
3. `CompassView`: set and clear bearing actions in place.
4. `SettingsView`: links to ascent limits, alarms, shortcut help and info; inline sync retry/clear controls.
5. `UserImagesView`: empty state when no assets exist; image detail is reachable only if assets are bundled.
6. `DiveLogListView`: row to `DiveDetailView`; context-menu delete; export latest and share flow.
7. `DiveDetailView`: export/share, visible delete confirmation and dismiss after delete.

Dead ends or weak routes:

- UserImages is reachable but has no real content in the current build.
- Ascent warning path is blocked by a likely compile issue.
- No custom Digital Crown route exists beyond system paging/scrolling.
- No explicit back route problem was found, but warning/GPS overlays replace the live screen rather than layering above it.

### iOS MAIN

Root: `ContentView` -> `TabView` with stable tabs.

Tabs and child routes:

1. Logbook -> `DiveDetailView`; CSV importer modal; delete confirmation dialog.
2. Explore -> route review; CSV importer modal; Watch/iCloud sync actions; system Settings opener.
3. Analysis -> dashboard or empty actions; CSV importer modal; can switch to Logbook through navigation store.
4. Planner -> result view after valid input and acknowledgement.
5. Gear -> inline editable form and reset confirmation.
6. Settings -> inline cards; Watch retry/reset trust; cloud sync; system Settings opener.

Dead ends or weak routes:

- Planner result is likely unreachable until the file structure compiles.
- Explore "Impostazioni" opens system Settings, not in-app Settings. This is useful for permissions but may not match all user expectations.
- Settings warning/status cards still include some state text that looks action-like but is intentionally not tappable.

## 3. Settings Report

### Apple Watch Settings Available

- Ascent-rate limits: reachable, persisted and applied.
- Alarms: reachable, persisted and applied for ascent/depth/runtime/battery.
- Haptics: reachable, persisted and applied.
- Units: visible and editable-looking, but only metric is actually implemented; imperial is labeled Planned.
- GPS behavior: visible as surface-only/fallback-labeled copy.
- Export: visible as Subsurface CSV metric; other formats Planned.
- Depth diagnostics: visible through Info.
- Sync queue: pending count, failed count, last retry, retry and clear queue controls.
- Shortcut help: reachable.
- Screen/brightness/always-on: informational only, controlled by watchOS.
- Audio tones: informational only.

Settings gaps:

- Watch unit setting can be changed to imperial in UI but does not convert live data.
- Watch/iOS settings sync is not bidirectional; UI now scopes it as local/planned.
- Sync queue status does not prove delivery or receipt.
- Brightness/always-on are informational only; this is acceptable if kept clearly non-actionable.

### iOS Settings Available

- Units: editable, persisted locally and applied to display formatters.
- Export: visible with Subsurface CSV default and GPX/UDDF Planned.
- Notification authorization: actual status is read and system Settings can be opened.
- Watch sync: support/state/result, peer verification, last sync, conflicts, retry and reset/re-pair are visible.
- Cloud backup: availability, manual sync, merge-policy copy and last event are visible.
- Demo logbook: toggle is reachable and persisted.
- Planner safety: enforced in planner and summarized in settings.

Settings gaps:

- Watch settings are not synchronized bidirectionally.
- Notification permission cannot be requested in-app; only status and system Settings are available.
- Cloud conflicts are documented but not previewed with full local/cloud/result cards.
- Equipment and planner cloud conflict handling is last-write/merge-policy copy, not per-field resolution.
- Export alternatives are not actually selectable, only listed as Planned.

## 4. Hardware Interaction Report

### Apple Watch

- Digital Crown: supported through system `TabView` paging and scroll views. No custom `digitalCrownRotation` controls are implemented.
- Swipe navigation: vertical page navigation is available through the root `TabView`.
- Tap navigation: core actions are tap-driven and reachable.
- Long press: used implicitly by context menu delete in log list, but visible delete now exists in detail.
- Side button: no direct side-button interception, matching watchOS limitations.
- Action Button / Shortcuts: App Intents exist for stopwatch toggle and reset only.
- Haptics: centralized through `HapticService`; safety and confirmation events are covered.

Missing or weak hardware interactions:

- No shortcut/intents for manual dive start/end, bearing set/clear or alarm acknowledgement.
- No crown-specific adjustment for planner/settings values.
- No explicit VoiceOver/accessibility hints for many custom icon or safety controls.

### iOS

- Standard tab, navigation stack, file importer, confirmation dialog and share sheet interactions are used.
- System Settings links are used for notification/permission recovery.
- No custom iOS haptic layer is implemented for destructive/import/export actions.

## 5. UX Blockers

### CRITICAL

1. Watch target likely does not compile because `AscentWarningView` calls missing `Formatters.zero`.
2. iOS target likely does not compile because `PlannerView.swift` has an invalid brace/scope structure around `ResultPanelStyle` and `PlanTab`.

### HIGH

1. Depth entitlement and automatic depth lifecycle still require real Apple Watch Ultra validation before release.
2. Watch manual fallback may remain hidden if depth automation initially appears available and then fails.
3. Watch sync queue state is not fully truthful about delivery/receipt; pending count can clear before real delivery is user-confirmable.
4. TTV is displayed prominently but appears derived from average depth plus runtime minutes, not a validated decompression/safety metric.
5. Accessibility is incomplete across custom Watch and iOS UI: fixed font sizes, icon-only controls, color-coded status and charts lack sufficient accessibility summaries.

### MEDIUM

1. Watch imperial unit option is selectable but not implemented.
2. Watch UserImages remains a contentless tab when no assets are bundled.
3. iOS CSV import accepts data with weaker bounds than Watch sync; unrealistic depth/duration/GPS values can enter the logbook.
4. iOS cloud conflicts are not user-previewable; merge policy is only documented.
5. Equipment/planner cloud conflicts do not have per-field resolution.
6. Some missing data displays can look like real values, especially SAC/gas pressure summaries.
7. Explore system Settings action may be confused with in-app Settings.

### LOW

1. Watch log list still uses hidden context-menu delete in addition to the detail delete flow.
2. iOS settings cards include some status labels that look like actions.
3. iOS destructive/import/export flows do not use haptics.
4. Chart accessibility summaries are not implemented.

## 6. Safety Issues

1. Depth/pressure entitlement, provisioning and real-device behavior are not validated in this environment.
2. TTV label/meaning is potentially unsafe if interpreted as decompression or time-to-surface guidance.
3. Planner remains non-certified and must continue to require safety acknowledgement.
4. CSV import can accept unrealistic or unsafe data unless validation is tightened.
5. GPS remains correctly surface-only, but accuracy and fallback source should be more visible in iOS detail/export contexts.
6. Watch haptics can be disabled; the live badge helps, but pre-dive visibility could be stronger.
7. Sync trust is strict, but queue/delivery status can still create false confidence about whether a session reached iPhone.

## 7. Recommended Priority Order

### Immediate Fixes

1. Fix Watch compile blocker by adding a Watch formatter for zero-decimal values or replacing `Formatters.zero` usage.
2. Fix iOS `PlannerView.swift` brace/scope issue and verify `PlanTab` is at file scope.
3. Run `xcodegen generate` and Xcode builds for Watch and iOS on macOS.
4. Reassess or rename TTV unless it is backed by a validated safety algorithm.
5. Validate depth entitlement/profile and automatic depth lifecycle on real Apple Watch Ultra.

### Pre-release Fixes

1. Tighten CSV validation for depth, duration, temperature and GPS coordinate ranges.
2. Make Watch sync queue states more truthful: pending, sent, delivered/acknowledged, failed and last retry.
3. Disable or hide unimplemented Watch imperial units.
4. Add accessibility labels/hints and non-color status text for safety, destructive and chart-heavy controls.
5. Clarify missing SAC/gas pressure/accuracy displays so unknown data is never shown as a measured zero.
6. Improve cloud conflict visibility beyond merge-policy copy if release scope allows.

### Post-release Improvements

1. Full bidirectional Watch/iOS settings sync contract with version/timestamp conflict handling.
2. Per-field cloud conflict resolver for equipment and planner settings.
3. UserImages asset pipeline or removal from the release navigation until real reference content exists.
4. Additional App Intents for manual dive lifecycle, compass bearing and alarm acknowledgement.
5. Full Dynamic Type and VoiceOver pass for iOS and Watch.
6. Optional iOS haptics for destructive, import/export and sync recovery actions.

## 8. Code Impact Report

Small UI/build fixes:

- Add missing Watch formatter or adjust ascent warning runtime formatting.
- Close/fix `PlannerView.swift` scope around `ResultPanelStyle` and `PlanTab`.
- Disable/hide Watch imperial unit option until conversion exists.
- Update labels for TTV or unknown SAC/gas values.

Medium refactors:

- Accessibility labels, hints and chart summaries across custom UI.
- CSV validation hardening and clearer import errors.
- Watch sync queue state tracking and user-visible retry/delivery status.
- Cloud conflict preview cards.

Architectural issues:

- Bidirectional settings sync across Watch/iPhone.
- Real conflict resolution for cloud equipment/planner data.
- Certified/validated dive-computer behavior is out of scope unless backed by validated algorithms, device testing and product policy.

## 9. Final Summary

Release readiness estimate: not release-ready until the Watch and iOS likely compile blockers are fixed, macOS builds pass and real Apple Watch Ultra depth validation is completed.

UX completeness estimate: approximately 78 percent. Most stable features now have visible entry points and recovery paths, but settings sync, cloud conflict preview, accessibility and contentless Watch images remain incomplete.

Stability estimate: approximately 70 percent pending build verification. Sync trust and CSV handling improved, but Watch queue status, cloud conflicts and CSV safety validation need more hardening.

Safety completeness estimate: approximately 65 percent. Planner disclaimers, GPS truthfulness and haptics-off visibility are improved, but TTV semantics, depth validation, CSV bounds and sync delivery truthfulness remain safety-sensitive release blockers.

Final recommendation: fix the two compile blockers first, run full macOS/Xcode validation, then address TTV semantics, real-device depth validation, CSV safety bounds and accessibility before treating MAIN as release-ready.
