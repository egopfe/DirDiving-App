# DIR DIVING Apnea and Snorkeling Main Integration Analysis

Date: 2026-06-05

Repository: `C:\Users\egopf\Documents\GitHub\DirDiving-App`

Current main baseline: `31f476e` (`fix(sync): implement truthful iOS→Watch photo transfer lifecycle and ACK.`)

Experimental Watch branch reviewed: `origin/codex/experimental-features` at `5f06084`

Experimental iOS branch reviewed: `origin/codex/ios-experimental-features` at `e872e8b`

Requested scope:

- Integrate only Apnea and Snorkeling feature enhancements into `main`.
- Cover both iOS companion and Apple Watch app.
- Do not bring messaging, Buddy Assist, buddy pairing, or BLE integration into `main`.
- Avoid introducing regressions into the current stable Diving, WatchConnectivity, photo transfer, security, or UI flows.

No application code was changed during this analysis.

## Executive Summary

The current `main` branch already contains dormant Apnea and Snorkeling code, but it is intentionally excluded from the production build:

- Watch `Views/ApneaView.swift` exists.
- Watch `Views/SnorkelingView.swift` exists.
- Watch `Models/ExplorationModels.swift` exists.
- Watch `Services/ExplorationStore.swift` exists.
- iOS `iOSApp/Views/ExplorationCenterView.swift` exists.
- iOS `iOSApp/Models/ExplorationModels.swift` exists.
- iOS `iOSApp/Services/ExplorationPlanningStore.swift` exists.

The main integration should therefore not be a raw branch merge. The experimental branches are behind the latest `main` in important areas, especially WatchConnectivity and photo transfer. A raw merge or wholesale `project.yml` import would:

- Reintroduce stale code over the current `main`.
- Pull in Buddy/BLE files and CoreBluetooth.
- Risk breaking the newly fixed iOS-to-Watch photo ACK lifecycle.
- Expose lab-only messaging or BLE UI.
- Add mock/experimental wording to production surfaces.

Recommended strategy:

1. Use current `main` as the base.
2. Selectively include only Apnea/Snorkeling support files currently excluded from targets.
3. Port only the useful non-BLE enhancements from the experimental Watch Apnea/Snorkeling views.
4. Keep Buddy Assist, BLE, pairing, and messaging source files excluded.
5. Rework sync as a production-named Apnea/Snorkeling WatchConnectivity contract only if needed; do not copy the experimental sync implementation directly.
6. Validate with build, unit tests, and Watch UI simulator/device QA.

## Branch and Version Reality

### Current Main Is Newer Than the Audited Report Commit

`main` is currently at:

```text
31f476e fix(sync): implement truthful iOS→Watch photo transfer lifecycle and ACK.
```

Recent main commits include:

```text
31f476e fix(sync): implement truthful iOS→Watch photo transfer lifecycle and ACK.
cac2c35 fix(watch): enlarge User Images display and index photo transfer audit
a1b074b docs: add watch photo transfer audit report
b59da6d fix(watch): hoist export navigation and normalize HEIC photos to JPEG
95b6ef3 fix(watch): rotate compass rose cardinals with tick ring
```

This matters because the experimental branches do not include all of this latest work.

### Experimental Branches Are Not Safe to Merge Wholesale

`origin/codex/experimental-features` contains large diffs against `main`, including:

- Apnea/Snorkeling Watch features.
- Buddy Assist UI.
- Buddy pairing and BLE services.
- `CoreBluetooth.framework` in `project.yml`.
- Experimental sync contracts.
- Older or divergent WatchConnectivity code.
- Document churn and deleted newer docs from `main`.

`origin/codex/ios-experimental-features` contains iOS exploration/route UI and buddy lab files, but does not cleanly expose a production iOS Apnea/Snorkeling tab in `ContentView`.

Conclusion: cherry-pick by file/function, not by commit or branch.

## Current Main State

### Watch: Dormant Apnea/Snorkeling Files

Current main has:

- `Views/ApneaView.swift`
- `Views/SnorkelingView.swift`
- `Models/ExplorationModels.swift`
- `Services/ExplorationStore.swift`

But `project.yml` excludes them from the Watch app target:

```yaml
Models:
  excludes:
    - ExplorationModels.swift
Services:
  excludes:
    - ExplorationStore.swift
Views:
  excludes:
    - ApneaView.swift
    - SnorkelingView.swift
    - BuddyAssistView.swift
    - ExperimentalConceptsView.swift
```

Current main also keeps mode selection dormant:

```swift
static let hasMultipleStableModes = false
```

The Watch app injects no `ExplorationStore` into the environment. If `ApneaView` or `SnorkelingView` were simply un-excluded without app wiring, runtime would fail when SwiftUI resolves `@EnvironmentObject private var exploration`.

### iOS: Dormant Exploration Companion Files

Current main has:

- `iOSApp/Views/ExplorationCenterView.swift`
- `iOSApp/Models/ExplorationModels.swift`
- `iOSApp/Services/ExplorationPlanningStore.swift`

But `project.yml` excludes them from the iOS target.

`iOSApp/Views/ExplorationCenterView.swift` includes:

- Snorkeling map / waypoint planning card.
- Route card.
- Apnea analytics card.
- Sync/settings card.
- Export controls.

However, it also links to `ExperimentalFutureConceptsView`, which is currently excluded and is broader than the requested scope. That link must be removed or replaced before production inclusion.

## Experimental Feature Inventory

### Watch Apnea Enhancements

Experimental `Views/ApneaView.swift` expands current main Apnea from a simple timer/recovery screen into a multi-screen workflow:

- Menu screen.
- Session screen.
- Surface-end screen.
- Recovery countdown screen.
- Apnea summary screen.
- Depth profile screen.
- Detail screen.
- Save confirmation screen.
- Apnea logbook screen.
- Statistics screen.
- Depth state screens for descent/bottom/ascent/ascent alarm/surface/recovery/summary.
- Session type screen.
- Open water config screen.
- Alarms settings screen.
- Countdown screens.
- Depth profile shape drawing.

Useful candidates to port:

- Recovery countdown UX.
- Summary screen.
- Depth profile visualization, if backed by real samples or clearly marked as unavailable.
- Apnea statistics based on persisted `ApneaDiveRecord`.
- Configurable surface interval and max-depth alarm.
- Depth unavailable display when no depth sensor is available.
- Haptic warning on ascent/depth alarm if already supported by stable haptics.

Must not port as-is:

- `WatchSyncService.shared.transferExperimentalApneaRecord(...)`.
- `ExperimentalSyncEnvelope`.
- "experimental" sync boundary panels.
- Lab-only settings sync copy.
- "Buddy reminder..." copy.
- Any mock rows that look like real history.

### Watch Snorkeling Enhancements

Experimental `Views/SnorkelingView.swift` expands current main Snorkeling into a multi-screen surface navigation tool:

- Live screen.
- Waypoint map screen.
- Return map screen.
- Waypoint direction screen.
- Activity metrics panel.
- Depth/GPS section.
- Summary cards.
- GPS quality column.
- Waypoint and return summary cards.
- Marker saved screen.
- Marker log screen.
- Marker detail screen.
- Settings screen.
- Alarms screen.
- Compass calibration screen.
- Map legend screen.
- Schematic route/map panels.
- Direction dial.
- Marine depth/grid backdrop shapes.

Useful candidates to port:

- Marker log and marker detail screens.
- Return-to-entry map/direction screen.
- Waypoint direction screen.
- GPS quality display.
- Alarm thresholds for max depth, runtime, distance, battery.
- Better no-GPS states.
- Schematic map notice that makes clear this is not an underwater GPS map.
- Marker deletion and richer marker metadata.

Must not port as-is:

- `WatchSyncService.shared.transferExperimentalPOI(...)`.
- Experimental sync status panels.
- `experimentalHapticsEnabledKey` unless converted to a stable feature flag.
- Any text implying lab sync or incomplete ACK behavior.
- Any route/offline map wording that implies real MBTiles/offline maps unless implemented.

### iOS Exploration / Apnea / Snorkeling Companion Enhancements

Current dormant iOS `ExplorationCenterView` can become a production companion surface if narrowed:

Useful candidates:

- Snorkeling route planner.
- Waypoint list/order controls.
- Route distance calculation.
- Apnea analytics summary.
- Apnea settings such as duration warning and recovery ratio.
- Local route/export status, if honest.

Must not port or expose:

- `iOSApp/Views/BuddyExperimentalView.swift`
- `iOSApp/Services/BuddyExperimentalStore.swift`
- `iOSApp/Models/BuddyExperimentalModels.swift`
- Messaging presets.
- BLE or buddy lab content.
- Broad `ExperimentalFutureConceptsView` unless it is split and narrowed to Apnea/Snorkeling only. It currently contains future/premium/community concept content beyond the requested feature set.

## Explicit Exclusion List

These must stay excluded from `main` production targets:

Watch:

- `Models/BuddyAssistMessage.swift`
- `Models/BuddyPairingHandshake.swift`
- `Services/BuddyAssistService.swift`
- `Services/BuddyAssistPeripheralService.swift`
- `Services/BuddyPairingKeyAgreement.swift`
- `Services/SecureBuddyStore.swift`
- `Views/BuddyAssistView.swift`
- `Utils/ExperimentalFeatures.swift`, unless retained only as a disabled internal compile-time holder
- `CoreBluetooth.framework`

iOS:

- `iOSApp/Models/BuddyExperimentalModels.swift`
- `iOSApp/Services/BuddyExperimentalStore.swift`
- `iOSApp/Views/BuddyExperimentalView.swift`

Also avoid:

- Adding `CoreBluetooth.framework` to the Watch or iOS production targets.
- Adding `buddyAssist` to `AppPage`.
- Adding Buddy UI cards to `ModeSelectionView`.
- Adding buddy/messaging strings to production localization.
- Adding BLE entitlements or background modes.

## Recommended Integration Architecture

### Watch Target Membership

Change `project.yml` selectively.

Allow into Watch target:

- `Models/ExplorationModels.swift`
- `Services/ExplorationStore.swift`
- `Views/ApneaView.swift`
- `Views/SnorkelingView.swift`

If porting the richer experimental Snorkeling UI:

- Add `Views/SnorkelingAlarmsView.swift`
- Add `Views/SnorkelingMarkerDetailView.swift`
- Add `Views/GPSMarkerView.swift` if needed

Keep excluded:

- Buddy models/services/views.
- `ExperimentalConceptsView.swift`.
- `ExperimentalFeatures.swift`, unless the file is cleaned and contains no Buddy flags.

Do not add:

- `CoreBluetooth.framework`.

### Watch App Object Graph

Update `App/DIRDivingApp.swift`:

- Add `@StateObject private var explorationStore: ExplorationStore`.
- Initialize it in `init`.
- Inject `.environmentObject(explorationStore)`.

This is mandatory because both `ApneaView` and `SnorkelingView` depend on:

```swift
@EnvironmentObject private var exploration: ExplorationStore
```

### Watch Navigation

Update `Models/AppPage.swift`:

- Add `.apnea`.
- Add `.snorkeling`.
- Do not add `.buddyAssist`.
- Avoid adding settings subpages as TabView pages unless there is a separate UX reason.

Update `Views/ContentView.swift`:

- Add `ApneaView().tag(AppPage.apnea)`.
- Add `SnorkelingView().tag(AppPage.snorkeling)`.
- Keep Buddy out.
- Decide placement carefully:
  - `Live`
  - `Snorkeling`
  - `Apnea`
  - `Compass`
  - `Settings`
  - `Screens`
  - `Dive Log`

Update active-dive navigation:

- During scuba diving (`dive.isDiveActive == true`), continue to restrict to `.live` and `.compass`.
- During Apnea/Snorkeling sessions, avoid using `dive.isDiveActive` unless intentionally sharing the depth sensor session.
- If Apnea starts a true depth session through `DiveManager`, then the current guard would force navigation back to Live and break Apnea. This must be resolved before enabling real depth capture.

### Watch Mode Selection

Update `Utils/WatchModeSelectionPreferences.swift`:

- Set `hasMultipleStableModes = true`.
- Update comments to reflect production availability.

Rewrite `Views/ModeSelectionView.swift` conservatively:

- Use `DIRActivityMode` cards for Diving, Apnea, Snorkeling.
- Keep current main styling/l10n pattern.
- Do not copy experimental `buddyCard`.
- Do not copy hardcoded Italian/English strings.
- Do not add unrelated `ascentSettingsCard` or `settingsCard` unless deliberately redesigning navigation.

### Watch Apnea Integration

Recommended production path:

1. Start from current main `ApneaView.swift`, not the full experimental file.
2. Add safe enhancements incrementally:
   - Surface interval setting.
   - Max-depth alarm setting.
   - Recovery countdown polish.
   - Summary/logbook panel.
   - Depth unavailable UI.
   - Remove the debug-like `WARN` button or hide it behind developer settings.
3. Replace:

```text
Buddy reminder, no-movement e depth warning attivi.
```

with neutral non-buddy copy.

4. Avoid experimental sync calls in the first pass.
5. If real depth capture is required, define a stable Apnea sensor lifecycle instead of piggybacking blindly on scuba `DiveManager`.

Key technical risk:

Current Apnea reads `dive.currentDepthMeters` and `dive.maxDepthMeters`. If `DiveManager` is not active, those may stay zero. If `DiveManager` is activated, current navigation guards and log semantics may treat Apnea as a scuba dive. This needs a small design decision before release:

- Option A: Apnea v1 is timer/recovery only, with depth shown only when already available.
- Option B: Add a mode-aware depth sampling path in `DiveManager` or a new `ApneaSessionStore`.

Option A is lower risk for initial main integration.

### Watch Snorkeling Integration

Recommended production path:

1. Start from current main `SnorkelingView.swift`.
2. Add experimental enhancements selectively:
   - Marker log.
   - Marker detail.
   - Return-to-entry direction.
   - GPS quality state.
   - Alarm threshold screen.
   - Better no-GPS screen.
3. Add richer marker metadata to `GPSInterestMarker`:
   - `temperatureCelsius`
   - `activeWaypointName`
   - `sessionID`
   - `isEnriched`
4. Preserve backward-compatible `Codable` decoding, as the experimental branch already does.
5. Avoid experimental sync calls in the first pass.

Key technical risk:

Snorkeling uses `GPSManager` and compass and should remain a surface workflow. It must not imply underwater GPS routing. UI copy should say route/map panels are schematic or surface GPS based.

### iOS Companion Integration

Recommended iOS production path:

1. Add an `Explore` or `Modes` tab to `IOSTab`.
2. Include `ExplorationCenterView`.
3. Add `@StateObject private var explorationPlanningStore: ExplorationPlanningStore`.
4. Inject `.environmentObject(explorationPlanningStore)`.
5. Include in iOS target:
   - `iOSApp/Models/ExplorationModels.swift`
   - `iOSApp/Services/ExplorationPlanningStore.swift`
   - `iOSApp/Views/ExplorationCenterView.swift`
6. Keep excluded:
   - `ExperimentalFutureConceptsView.swift`
   - `BuddyExperimentalView.swift`
   - `BuddyExperimentalStore.swift`
   - `BuddyExperimentalModels.swift`

Required cleanup before exposing `ExplorationCenterView`:

- Remove or replace the `NavigationLink` to `ExperimentalFutureConceptsView`.
- Replace "Mock UI" status text with honest production language:
  - "Local route plan updated"
  - "Watch route sync not enabled"
  - "Export not available yet"
- Do not claim GPX/CSV export unless implemented.
- Do not claim Watch route sync unless implemented.

### Optional Production Sync Contract

The experimental branches define:

```swift
ExperimentalSyncKind.watchPOI
ExperimentalSyncKind.watchApneaRecord
ExperimentalSyncKind.companionRouteManifest
ExperimentalSyncKind.companionSettings
```

This is conceptually useful but should not be copied under the `ExperimentalSync` name into `main`.

If sync is desired for main, create production-named contracts, for example:

- `ExplorationSyncKind.watchPOI`
- `ExplorationSyncKind.watchApneaRecord`
- `ExplorationSyncKind.companionSnorkelingRoute`
- `ExplorationSyncKind.companionApneaSettings`

Implementation rules:

- Add this on top of current `main` `WatchSyncService`, not by replacing it.
- Preserve the current photo transfer lifecycle and ACK code from `31f476e`.
- Use `transferUserInfo` for durable background delivery.
- Use direct `sendMessage` only as an optimization.
- Include schema version and IDs for de-duplication.
- Consider signing/HMAC if it reuses the existing Watch sync trust boundary.
- Keep it separate from buddy/messaging/BLE.

Recommended staging:

- Phase 1: No Apnea/Snorkeling sync; local Watch and local iOS companion features only.
- Phase 2: Watch to iOS sync for Apnea records and Snorkeling POIs.
- Phase 3: iOS to Watch route/settings sync.

## Main Bug Risks and Mitigations

### Risk 1: Pulling BLE/Buddy into production

Cause:

- Experimental `project.yml` includes all Watch sources and adds `CoreBluetooth.framework`.

Mitigation:

- Do not merge experimental `project.yml`.
- Keep Buddy files excluded.
- Add a CI check that `CoreBluetooth.framework` is absent from production targets.
- Add a grep/static check for `BuddyAssistService`, `BuddyExperimentalStore`, and `CBPeripheralManager` in compiled production target membership.

### Risk 2: Regressing WatchConnectivity

Cause:

- Experimental Watch/iOS `WatchSyncService` is older than latest main and lacks current photo ACK lifecycle.

Mitigation:

- Never replace `WatchSyncService.swift` wholesale.
- Apply only additive exploration-sync methods if needed.
- Re-run photo transfer tests and manual photo QA.

### Risk 3: Missing environment object crash

Cause:

- Apnea/Snorkeling views need `ExplorationStore`.

Mitigation:

- Add `@StateObject ExplorationStore` to Watch app root.
- Inject it into the `WindowGroup`.
- Add a launch smoke test for `ModeSelectionView`, `ApneaView`, and `SnorkelingView`.

### Risk 4: Apnea depth behavior is misleading

Cause:

- Apnea reads `DiveManager` depth values but does not independently start depth sampling.

Mitigation:

- For v1, label depth as unavailable unless active sensor data exists.
- Do not save depth values that are just stale/default zero.
- Before real Apnea depth logging, add mode-aware depth lifecycle tests.

### Risk 5: Snorkeling route/map implies underwater GPS

Cause:

- Rich map UI can be misunderstood.

Mitigation:

- Use explicit surface-GPS and schematic-map language.
- No underwater GPS promise.
- No "offline map ready" unless an actual offline map asset/cache exists.

### Risk 6: Mock iOS companion states ship as production

Cause:

- `ExplorationPlanningStore` currently has mock statuses and fake analytics data.

Mitigation:

- Replace mock labels.
- Use actual local route state for snorkeling.
- Mark apnea analytics as "sample/local planning" or hide until real Watch records sync.

### Risk 7: Localization regression

Cause:

- Many dormant/experimental views use hardcoded Italian/English strings.

Mitigation:

- Add `Localizable.strings` keys for all production-visible Apnea/Snorkeling UI.
- Run both English and Italian UI reviews.

## Suggested Implementation Plan

### Phase 0: Guard Rails

1. Create a feature branch from latest `main`.
2. Add a checklist forbidding:
   - CoreBluetooth production dependency.
   - Buddy files in target membership.
   - Experimental sync type names in production UI.
3. Keep all changes small and reviewable.

### Phase 1: Watch Minimal Stable Integration

Files likely changed:

- `project.yml`
- `App/DIRDivingApp.swift`
- `Models/AppPage.swift`
- `Utils/WatchModeSelectionPreferences.swift`
- `Views/ContentView.swift`
- `Views/ModeSelectionView.swift`
- `Views/ApneaView.swift`
- `Views/SnorkelingView.swift`
- `Resources/en.lproj/Localizable.strings`
- `Resources/it.lproj/Localizable.strings`

Actions:

1. Include `ExplorationModels`, `ExplorationStore`, `ApneaView`, and `SnorkelingView`.
2. Inject `ExplorationStore`.
3. Add Apnea/Snorkeling pages.
4. Enable mode selection.
5. Remove buddy copy from Apnea.
6. Keep current simple Apnea/Snorkeling UI first.
7. Build and run Watch tests.

Expected result:

- Watch launches to mode selection.
- User can choose Diving, Apnea, or Snorkeling.
- Existing Diving remains unchanged.
- No Buddy/BLE UI appears.

### Phase 2: Watch Feature Enhancements

Actions:

1. Add richer Snorkeling marker log/detail.
2. Add return-to-entry map/direction UI.
3. Add GPS quality and no-GPS states.
4. Add Apnea recovery summary/statistics.
5. Add Apnea and Snorkeling alarm settings.
6. Add tests for `ExplorationStore`.

Do not add sync in this phase unless separately scoped.

### Phase 3: iOS Companion Local Exploration Surface

Files likely changed:

- `project.yml`
- `iOSApp/App/DIRDivingiOSApp.swift`
- `iOSApp/Views/ContentView.swift`
- `iOSApp/Views/ExplorationCenterView.swift`
- `iOSApp/Models/ExplorationModels.swift`
- `iOSApp/Services/ExplorationPlanningStore.swift`
- `iOSApp/Resources/en.lproj/Localizable.strings`
- `iOSApp/Resources/it.lproj/Localizable.strings`

Actions:

1. Add an iOS Explore tab.
2. Inject `ExplorationPlanningStore`.
3. Include only exploration model/store/view files.
4. Remove link to `ExperimentalFutureConceptsView`.
5. Remove mock-success wording.
6. Keep Buddy lab excluded.

Expected result:

- iOS companion gains a route/apnea planning/review surface.
- No buddy/messaging/BLE feature appears.

### Phase 4: Optional WatchConnectivity Exploration Sync

Only after Phases 1-3 are stable:

1. Add production `ExplorationSyncEnvelope`.
2. Watch sends Apnea records and Snorkeling POIs to iOS.
3. iOS stores and displays received Apnea/POI data.
4. iOS optionally sends route/settings to Watch.
5. Add duplicate handling and schema migration.
6. Preserve current signed dive sync and photo ACK paths.

## Test Plan

### Static Checks

Run on macOS:

```bash
xcodegen generate
xcodebuild -scheme "DIRDiving Watch App" -destination 'generic/platform=watchOS' build
xcodebuild -scheme "DIRDiving iOS" -destination 'generic/platform=iOS' build
```

Static grep checks:

```bash
grep -R "CoreBluetooth.framework" project.yml
grep -R "BuddyAssistService\\|BuddyExperimentalStore\\|CBPeripheralManager" project.yml App Models Services Views Utils iOSApp
```

Expected:

- No production target dependency on CoreBluetooth.
- Buddy files remain excluded.
- No Buddy UI reachable in main navigation.

### Unit Tests

Run:

```bash
xcodebuild test -scheme "DIRDiving Watch Algorithm Tests" -destination 'platform=watchOS Simulator,name=Apple Watch Ultra 3 (49mm)'
xcodebuild test -scheme "DIRDiving iOS Algorithm Tests" -destination 'platform=iOS Simulator,name=iPhone 16'
```

Add tests:

- `ExplorationStoreTests`
  - start snorkeling with no GPS
  - start snorkeling with GPS
  - update speed/distance
  - save marker with/without GPS
  - end snorkeling clears session state
  - start apnea session
  - block apnea dive during recovery
  - surface apnea creates record
  - recovery countdown completes

- `ExplorationModelsCodableTests`
  - decode old `GPSInterestMarker` without new fields
  - decode new marker with temperature/session/waypoint fields

- `ProjectMembershipPolicyTests` or script-level check
  - no buddy files in production target membership
  - no CoreBluetooth dependency

### Watch UI QA

Test devices/simulators:

- 41 mm
- 45 mm
- 49 mm / Ultra

Scenarios:

1. Fresh install opens mode selection.
2. Diving opens existing Live screen.
3. Apnea opens and does not require buddy/BLE.
4. Apnea start/dive/surface/recovery works.
5. Apnea with no depth sensor shows honest unavailable depth.
6. Snorkeling starts with GPS available.
7. Snorkeling starts with GPS unavailable.
8. Marker save works.
9. Return-to-entry does not appear as underwater GPS.
10. Active scuba dive still locks navigation to Live/Compass.
11. No Buddy page appears.
12. No messaging or pairing UI appears.

### iOS UI QA

Scenarios:

1. New Explore tab appears.
2. Route planner displays waypoints.
3. Waypoint order changes persist.
4. Apnea analytics surface does not claim real synced data unless synced data exists.
5. No Buddy Lab appears.
6. No messaging presets appear.
7. English and Italian strings fit.

### Regression QA

Must re-run:

- iOS to Watch photo transfer, including ACK/imported state.
- Watch to iOS dive log sync.
- iOS to Watch dive log sync.
- Unit preference sync.
- Tombstone/delete sync.
- Existing Diving mode start/stop/log.
- Existing GPS capture for dive entry/exit.

## Recommended First PR Scope

The safest first PR should be narrow:

Title:

```text
feat(watch): enable stable Apnea and Snorkeling mode shell
```

Scope:

- Include Watch exploration model/store/views.
- Inject `ExplorationStore`.
- Add `.apnea` and `.snorkeling` pages.
- Enable mode selection.
- Add clean mode cards for Diving, Apnea, Snorkeling.
- Remove buddy text from Apnea.
- Keep buddy/BLE excluded.
- No iOS companion changes yet.
- No exploration sync yet.

Why this first:

- It proves target membership and runtime object graph.
- It has a small blast radius.
- It avoids mixing UI enablement with cross-device sync and companion redesign.

Second PR:

```text
feat(watch): add Snorkeling markers and Apnea recovery summaries
```

Third PR:

```text
feat(ios): add Apnea and Snorkeling exploration companion
```

Fourth PR, optional:

```text
feat(sync): add Apnea and Snorkeling exploration sync
```

## Final Recommendation

Proceed with selective integration, not merge.

For Watch, integrate Apnea/Snorkeling by un-excluding the existing main files and wiring the mode/store/navigation path first. Then port richer experimental UI pieces in small chunks after compile/runtime stability is proven.

For iOS, expose a narrowed `ExplorationCenterView` as an Explore tab only after removing mock/future/buddy surfaces and adding `ExplorationPlanningStore` injection.

Do not copy experimental `project.yml`, `WatchSyncService`, `BuddyAssist*`, `BuddyExperimental*`, or CoreBluetooth changes. The current `main` WatchConnectivity code is newer and must remain the source of truth.

Messaging and buddy BLE should remain experimental-only.
