# DIR DIVING - Complete UX / Interaction / Feature Accessibility Audit

Pre-modification report - MAIN branches only  
Date: 2026-05-18  
Scope: Apple Watch MAIN branch and iOS Companion MAIN branch only

## Executive Summary

This audit inspected the current MAIN worktrees:

- Apple Watch MAIN: `C:\Users\egopf\Documents\GitHub\DirDiving-App` on branch `main`.
- iOS Companion MAIN: `C:\Users\egopf\Documents\GitHub\DirDiving-App-main-iOS-ui` on branch `main-iOS`.

No runtime code was modified for this audit. The report reflects the current working tree, including uncommitted pre-release fixes already present in the MAIN worktrees. Experimental Apnea, Snorkeling, Buddy Assist and iOS Explore Lab files were not audited as features; they were only considered through `project.yml` target membership, which excludes experimental-only files from MAIN.

Current working-tree note:

- Watch MAIN has uncommitted pre-release changes in `Config/DIRDiving.entitlements`, `DiveManager`, `WatchSyncAuth`, `AscentGaugeView`, `AscentWarningView`, `DiveLiveView`, `GPSStartRegisteredView` and `GPSEndRegisteredView`.
- iOS MAIN has uncommitted pre-release changes in Watch sync, cloud/log stores, CSV import, Explore, Logbook, More and Planner.

## 1. Feature Inventory

### Apple Watch MAIN

1. Mode selection: implemented and reachable as the first vertical `TabView` page. MAIN exposes only Diving. Experimental modes are deliberately excluded from MAIN target membership. Mostly complete; no broken route found.
2. Live dive computer: implemented and reachable through the second vertical page and the Diving card. Shows depth, max/average depth, TTV, runtime, temperature, ascent gauge, stopwatch, warnings, manual fallback and haptics-off state. Main risk is crowding on smaller Watch sizes.
3. Automatic dive lifecycle: implemented through CoreMotion water-submersion callbacks. Reachability depends on entitlement, hardware and signing. Cannot be considered complete until physical-device validation passes.
4. Manual dive fallback: implemented and reachable only when depth automation is unavailable. It is truthful about limitations: runtime and GPS yes, automatic depth no.
5. Manual stopwatch: implemented through live controls and App Intents. START, STOP and RESET are reachable and have haptics.
6. GPS entry/exit capture: implemented for start/end lifecycle. Current working tree distinguishes success, fallback last-known point and no-fix states. Dive detail/export do not persist whether a coordinate was fallback.
7. GPS confirmation screens: implemented and reachable from lifecycle events. Success/fallback/no-fix states are visually distinct.
8. Ascent warning: implemented and reachable when ascent rate exceeds configured limits. Current working tree includes depth and runtime context. The warning still replaces much of the normal live screen.
9. Depth/runtime/battery alarms: implemented and configurable in Watch settings. They are persisted and applied, but battery/depth behavior needs device QA.
10. Ascent-rate settings: implemented and reachable from Settings. Per-band limits persist and apply.
11. Haptics: implemented and configurable. Used for stopwatch actions, alarms, ascent warnings, GPS confirmations, compass actions, export and sync retry. Haptics-off status is now visible during dive.
12. Compass: implemented and reachable as a vertical page. SET BEARING and CLEAR are operable and haptic-enabled. Permission/unavailable states are text-based.
13. Dive log list: implemented and reachable. Listing, row navigation, export latest and share are reachable. Delete is context-menu-only, which is a discoverability/glove-usability risk.
14. Dive detail: implemented and reachable from log rows. Shows summary, GPS rows and export/share. Watch-side profile review/chart is not present despite samples being stored.
15. Subsurface export on Watch: implemented from list and detail. Potential edge case: header-only CSV can be generated for sessions with no samples.
16. User image viewer: implemented and reachable. Bundled images can be opened and closed. Placeholder rows appear when no assets exist and may look release-unfinished.
17. Info/battery screen: implemented and reachable through Settings > Info. Version, device, battery and sync status are visible.
18. Watch sync queue: implemented and reachable through Settings. Retry is available conditionally. Individual queued sessions cannot be inspected or cleared.
19. Watch persistence/cloud sync: implemented internally. User visibility is limited to status rows; conflict handling is not user-reviewable on Watch.
20. Depth entitlement/signing: present in current working-tree config, but not validated. This is a release-critical external validation item.

### iOS Companion MAIN

1. Tab navigation: implemented and reachable. Tabs: Logbook, Explore, Analysis, Planner, Gear and Settings.
2. Logbook: implemented and reachable. Search, CSV import, empty state, delete confirmation and detail navigation are present. Month heading is hardcoded as `MAGGIO 2024`, which is wrong for imported/current sessions.
3. CSV import: implemented and reachable from Logbook and Explore. Current working tree improves source-date preservation, duplicate detection and malformed-row messages. Parser is still simple comma splitting, not robust quoted CSV parsing.
4. Dive detail: implemented and reachable. Summary/charts/details tabs, chart, gas block, GPS details, CSV export/share and unit conversion are present.
5. Subsurface export on iOS: implemented and reachable from Dive Detail. User generates CSV first, then share appears.
6. Explore / Route Review: implemented and reachable. It uses real entry/exit GPS data. Empty state now has actions. The `Sincronizza` action currently triggers cloud sync, which may mislead users expecting Watch sync.
7. Analysis: implemented and reachable. Empty state is informative but has no direct import/sync action.
8. Planner: implemented and reachable. Simple mode is usable; Advanced/Technical are disabled and labeled Planned. Validation and safety acknowledgement are present.
9. Planner result: implemented and reachable after valid input plus acknowledgement. Result tabs, warnings, ascent table and Buhlmann chart are present. No save/export plan flow exists.
10. Equipment / Gear: implemented and reachable. Editable profile, checklist, SAC stepper and reset confirmation are present. Auto-save exists but no explicit saved feedback.
11. Settings / More: implemented and reachable. Units, onboarding, export status, permission link, Watch sync status/retry/conflicts, cloud backup and demo logbook are visible.
12. Unit conversion: implemented and reachable. Display-only conversion covers depth, temperature, distance and SAC. Data/model/export remain metric.
13. Watch sync import: implemented and reachable through automatic activation plus Settings status/retry. Trust hardening and unverified state are present. There is no guided reset/re-pair flow.
14. Cloud backup / KVS: implemented and reachable. Availability, status and manual sync are visible. Cloud conflicts are not user-reviewable.
15. Demo logbook: implemented and reachable from Settings. It can mask empty states if enabled.
16. Permissions: partially implemented. System Settings link exists; live notification authorization is not read in-app.

## 2. Navigation Map

### Apple Watch MAIN

Root: `NavigationStack` -> `ContentView` -> vertical `TabView`.

Pages:

1. `ModeSelectionView`: tap Diving -> `navigation.selectedPage = .live`.
2. `DiveLiveView`: pre-dive, active dive, ascent warning and GPS confirmation states swap in-place.
3. `CompassView`: in-place SET BEARING and CLEAR actions.
4. `SettingsView`: links to `AscentRateSettingsView`, `AlarmSettingsView`, `WatchShortcutHelpView` and `InfoView`; conditional sync retry button.
5. `UserImagesView`: tap row -> in-place detail; SCHERMI button returns to list.
6. `DiveLogListView`: row -> `DiveDetailView`; export -> completion screen and ShareLink; delete -> context menu then confirmation dialog.

Dead ends/missing routes:

- No blocking dead-end screen found.
- Delete is hidden behind a context menu and should not be the only destructive entry point on Watch.
- Export is a two-step generate/share flow; usable but should be device-tested.

### iOS MAIN

Root: `ContentView` `TabView`.

Tabs:

1. Logbook -> `NavigationStack` -> `DiveDetailView`; CSV import via `fileImporter`; delete via `confirmationDialog`.
2. Explore -> route review; empty-state CSV import; Settings opens system Settings.
3. Analysis -> dashboard only; no push routes.
4. Planner -> validation/acknowledgement -> `PlanResultView`.
5. Gear -> editable form; reset confirmation.
6. Settings -> inline cards; retry/sync/conflict buttons; system Settings link.

Dead ends/missing routes:

- No broken push/pop logic found.
- Analysis empty state lacks direct import/sync action.
- Some Settings empty-state cards show action-looking text while the actual button is separate.

## 3. Settings Report

### Watch Settings Available

- Ascent-rate limits: reachable, persisted and applied.
- Alarms: ascent/depth/runtime/battery toggles and thresholds are reachable, persisted and applied.
- Haptics: reachable, persisted and applied.
- Units: visible but fixed metric; no editable Watch unit setting.
- Sync settings: visible as local-only, not synced.
- GPS status: visible, not configurable.
- Depth sensor status: visible.
- Companion sync/coda/retry: visible.
- Screen/brightness/always-on: informational only, controlled by watchOS.
- Audio tones: informational only.
- Shortcut/action help: reachable.
- Manual lifecycle help/status: visible.
- Info: reachable.

### Watch Settings Gaps

- No editable Watch units.
- No export preferences.
- No GPS behavior preferences.
- No Watch-to-iOS settings sync.
- No inspectable/clearable sync queue.
- No pairing/sync-secret reset UI.

### iOS Settings Available

- Units: editable metric/imperial, persisted locally, display-only.
- Export format: visible but read-only Subsurface CSV.
- Sync settings: marked local-only.
- Planner safety: visible and enforced in Planner.
- Notifications/permissions: system Settings link.
- Watch sync: support/state/result/retry/import counts/conflicts visible.
- Cloud backup: availability/status/manual sync visible.
- Demo logbook: persisted toggle.
- Safety warning: visible.

### iOS Settings Gaps

- Watch alarm/haptics/settings are not synchronized to iOS or from iOS to Watch.
- Export format alternatives are not editable.
- Notification authorization is not read directly.
- No reset/re-pair Watch sync trust UI.
- No cloud conflict preview.
- Equipment/planner cloud conflicts have no per-setting resolution UI.

## 4. Hardware Interaction Report

### Apple Watch

Digital Crown:

- Vertical `TabView` and `ScrollView` screens rely on system crown navigation/scrolling.
- No custom Digital Crown focus or precision controls are implemented.

Side button / Action button:

- No direct side-button or arbitrary long-press callback exists, matching watchOS limitations.
- App Intents exist for stopwatch toggle and reset.
- Settings includes shortcut/action help.

Long press:

- Dive log delete uses `contextMenu`, likely via long press.
- This is implemented but weak for discoverability and glove use.

Haptics:

- Stopwatch start/reset/stop: yes.
- Ascent warning: yes.
- Depth/runtime/battery alarms: yes.
- GPS confirmations: yes.
- Compass set/clear: yes.
- Export success/failure: yes.
- Sync retry: yes.
- Settings steppers/delete confirmation: no or weak.

### iOS

- Standard tab, navigation, file importer, confirmation dialog and share sheet interactions are used.
- No custom iOS haptics are implemented.
- System Settings links are used for permissions.

## 5. UX Blockers

### CRITICAL

1. Depth entitlement and device validation are not verified locally. Automatic depth lifecycle cannot be considered release-ready until portal/profile/Xcode/real-watch validation passes.

### HIGH

1. Watch log delete is context-menu-only. Users may not discover it; glove usability is weak. Code impact: small UI fix.
2. iOS cloud merge has no user-visible cloud conflict preview. Code impact: medium data/UX work.
3. Watch/iOS settings sync is not implemented. Code impact: medium to architectural.
4. iOS Watch pairing/trust recovery has retry/status but no guided reset/re-pair flow. Code impact: medium.

### MEDIUM

1. Watch live screen may crowd on smaller Watch sizes. Code impact: small/medium responsive layout QA.
2. iOS Logbook month heading is hardcoded. Code impact: small UI fix.
3. Explore `Sincronizza` action may imply Watch sync but calls cloud sync. Code impact: small UI copy/action fix.
4. CSV parser is not robust for quoted CSV. Code impact: medium parser improvement.
5. Analysis empty state lacks direct action. Code impact: small UI fix.
6. Watch image viewer placeholder rows may look like release mockups. Code impact: small content/empty-state fix.

### LOW

1. No haptic feedback on settings steppers.
2. iOS Settings action-looking text is sometimes not tappable.
3. Gear auto-save has no explicit saved feedback.

## 6. Safety Issues

1. Depth entitlement validation remains external and critical.
2. Planner remains simplified and non-certified, mitigated by current safety acknowledgement and warning copy.
3. GPS is surface-only and must continue to avoid underwater tracking claims.
4. Haptics-off warning risk is mitigated by current visual badge.
5. Alarm settings are local-only; UI says this, but cross-device expectations remain a risk.
6. Sync trust unverified state is now visible and no longer silently trusted.

## 7. Recommended Priority Order

### Immediate Fixes

1. Validate and commit current MAIN pre-release fixes separately from this audit report.
2. Run macOS `xcodegen generate` and Xcode builds for Watch and iOS.
3. Validate depth entitlement in Apple Developer portal and on Apple Watch Ultra.
4. Add visible Watch log delete affordance or Edit/Delete flow.
5. Correct iOS Logbook hardcoded month grouping.
6. Rename or rewire Explore empty-state sync action.

### Pre-release Fixes

1. Add iOS Analysis empty-state direct actions.
2. Add Watch smaller-screen layout QA and adjust live warning/haptics-off stacking if needed.
3. Add Watch sync trust reset/re-pair guidance in iOS Settings.
4. Add cloud conflict warning/preview or clearly document merge policy in UI.
5. Replace UserImages placeholders with true empty state or bundled release assets.
6. Test CSV import with quoted, malformed, empty and duplicate files.

### Post-release Improvements

1. Bidirectional settings sync contract.
2. Full cloud conflict resolver with revisions/tombstones.
3. Structured CSV parser.
4. Planner save/export if product policy allows, with safety gating.
5. Optional iOS haptics for destructive/import/export actions.
6. Full accessibility pass for Dynamic Type, VoiceOver and small screens.

## 8. Code Impact Report

Small UI fixes:

- Visible Watch delete affordance.
- Dynamic Logbook month grouping.
- Explore sync label/action correction.
- Analysis empty-state actions.
- UserImages real empty state.
- Gear saved feedback.
- Settings copy/button cleanup.

Medium refactors:

- Watch sync reset/re-pair UI.
- CSV parser and partial import reporting.
- Responsive Watch live layout.
- iOS cloud conflict preview.

Architectural issues:

- Bidirectional Watch/iOS settings sync.
- Complete KVS/cloud conflict policy with revisions/tombstones.
- Certified decompression planning should remain out of scope unless product/legal requirements change.

## 9. Final Summary

Release readiness estimate: 72/100. MAIN navigation is coherent and most features are reachable. Readiness is held back by macOS/device validation, Watch depth entitlement verification, sync/cloud edge cases and a few discoverability issues.

UX completeness estimate: 78/100. Major features are reachable. Key gaps are hidden Watch delete, local-only settings, cloud conflict clarity and a few empty-state/action issues.

Stability estimate: 70/100. Static inspection found coherent code paths, but Xcode builds and device tests are unavailable in this Windows environment. Current MAIN worktrees also contain uncommitted pre-release fixes.

Safety completeness estimate: 75/100. Safety copy and warnings are stronger after the current working-tree fixes. Remaining safety readiness depends on real depth entitlement/device tests, Watch alarm tests and sync trust QA.

Manual QA checklist:

- Apple Watch Ultra hardware test.
- Smaller Watch screen test.
- Depth entitlement validation on real device.
- GPS no-fix and GPS fallback tests.
- Haptics on/off tests.
- Ascent warning test with current depth/runtime visible.
- Watch log delete discoverability test.
- Watch export/share test with no samples and with real samples.
- iOS Watch pairing/trust test.
- iOS cloud merge/delete/tombstone test.
- CSV import/re-import/malformed/quoted CSV tests.
- Planner invalid-input and safety acknowledgement tests.
- iOS small/large screen tab and chart UI tests.

Conclusion: DIR DIVING MAIN is not blocked by unreachable primary navigation, but it is not fully release-ready until external Apple validation, CI/build validation and HIGH-priority UX blockers are addressed. The next work should be targeted fixes, not a redesign.
