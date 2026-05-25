# DIR DIVING — MAIN Branch Complete Readiness Audit

**Date:** 2026-05-25  
**Branch audited:** `main` @ `21a7f41`  
**Targets audited:** `DIRDiving Watch App`, `DIRDiving iOS`  
**Audit type:** Pre-modification readiness audit only. No app code, planner logic, dive algorithms, or experimental branches were modified.  
**Reference UI:** `Docs/ReferenceUI/Watch_LIVE_reference.png`, `Docs/ReferenceUI/iOS_Companion_reference.png`, watch inline ascent warning conventions already documented in MAIN docs.

---

## Audit Delta at Current `main`

The sections below capture the original pre-modification audit run performed on `main` @ `21a7f41`.

Since that audit, the branch advanced to `main` @ `ab398eb` and the repo-side readiness issues identified in the original pass were addressed and revalidated:

- Terms / Privacy links now point to dedicated legal docs instead of the repository root
- Watch `InfoView` entitlement wording now distinguishes static target config from Apple provisioning approval
- Watch compass bearing copy and iOS Planner / More localization cleanup were completed
- disabled non-advanced planner modes were removed from stable MAIN
- per-item sync activity visibility was added on Watch and iOS sync surfaces
- the Watch stopwatch reset now requires confirmation when there is something to reset
- README, INDEX, roadmap, release notes, and UX conventions were realigned so the current MAIN architecture no longer points readers at stale branch/UX assumptions
- `xcodegen generate` passes
- both simulator builds pass:
  - `DIRDiving Watch App` -> `generic/platform=watchOS Simulator`
  - `DIRDiving iOS` -> `generic/platform=iOS Simulator`

Current unresolved blockers are now external to the repository:

1. Apple provisioning approval for `com.apple.developer.coremotion.water-submersion`
2. generic signed Watch/iOS device builds that depend on that approved entitlement
3. real Apple Watch Ultra field/device QA for the automatic dive lifecycle and underwater evidence

---

## A. Branch Confirmed

| Item | Result |
| --- | --- |
| Branch | `main` |
| Local vs remote | `main...origin/main` with no ahead/behind markers at audit time |
| HEAD | `21a7f41` |
| Watch target | `DIRDiving Watch App` |
| iOS target | `DIRDiving iOS` |
| Watch bundle ID | `com.egopfe.dirdiving.ios.watch` |
| iOS bundle ID | `com.egopfe.dirdiving.ios` |
| Watch companion bundle ID | `WKCompanionAppBundleIdentifier = com.egopfe.dirdiving.ios` |
| Experimental source exclusion | Confirmed in `project.yml` for watch (`Apnea`, `Snorkeling`, `Buddy Assist`, experimental concepts) and iOS (`ExplorationCenterView`, `ExperimentalFutureConceptsView`, `BuddyExperimentalView`, related models/stores) |
| Accidental experimental imports | Not found in current MAIN entry points: `Views/ContentView.swift` and `iOSApp/Views/ContentView.swift` reference only stable MAIN screens |
| WatchConnectivity | Declared in `project.yml`; sync services present on both targets |
| iCloud / KVS | Present in watch and iOS entitlements; `CloudSyncStore` exists on iOS |
| Water-submersion entitlement | Present only in watch entitlements, not in iOS entitlements |
| iOS misuse of submersion entitlement | Not found |

### Build / project validation

Fresh validation on the current `main` checkout:

- `xcodegen generate` -> **PASS**
- `xcodebuild -scheme "DIRDiving Watch App" -destination 'generic/platform=watchOS' -configuration Debug build` -> **FAIL**
- `xcodebuild -scheme "DIRDiving Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Ultra 3 (49mm)' -configuration Debug build` -> **PASS**
- `xcodebuild -scheme "DIRDiving iOS" -destination 'generic/platform=iOS' -configuration Debug build` -> **FAIL**
- `xcodebuild -scheme "DIRDiving iOS" -destination 'platform=iOS Simulator,name=iPhone 17' -configuration Debug build` -> **PASS**

Current generic device build blocker:

> `Entitlement com.apple.developer.coremotion.water-submersion not found and could not be included in profile.`

Interpretation:

- Source-level compile readiness is **good enough for simulator validation**
- Signed/generic device readiness is **blocked by provisioning / entitlement approval**
- The embedded watch app causes the same blocker to surface for generic iOS builds too

### Assets / Info / app relationship

- `project.yml` sets `GENERATE_INFOPLIST_FILE = YES` and overlays the required bundle keys
- Watch target also sets `INFOPLIST_KEY_WKCompanionAppBundleIdentifier = com.egopfe.dirdiving.ios`
- `Resources/Assets.xcassets/AppIcon.appiconset/Contents.json` and `iOSApp/Resources/Assets.xcassets/AppIcon.appiconset/Contents.json` both reference existing image files
- No broken AppIcon references were found in the current asset catalogs

### Entitlement status

| Target | Entitlement status |
| --- | --- |
| Watch | `Config/DIRDiving.entitlements` includes iCloud, KVS, and `com.apple.developer.coremotion.water-submersion` |
| iOS | `iOSApp/Config/DIRDivingiOS.entitlements` includes iCloud and KVS only |
| Readiness verdict | Correct separation of capability by target, but physical/signed build use is blocked until the watch entitlement is approved in the active provisioning context |

---

## B. Executive Summary

These percentages are engineering estimates based on current code, current build outputs, and current UI/accessibility review. They are not marketing scores.

| Area | Readiness | Summary |
| --- | --- | --- |
| Repo-side readiness | **100%** | All repo-actionable issues from the dated audit have been addressed on `main`; no remaining blocker identified by current validation requires further in-repo code or copy changes. |
| Overall readiness | **84%** | MAIN is coherent, simulator-ready, and now polished at repo level, but still not release-ready because generic signed device builds are blocked and core underwater behavior still lacks real-device proof. |
| Watch readiness | **88%** | Live, BUSSOLA, alarms, sync, export, settings, and images are present and polished in repo. Remaining blockers are entitlement approval and physical device QA. |
| iOS readiness | **90%** | The iOS companion stable tabs and sync/legal/planner surfaces are now polished in repo. Remaining blockers are release-process and paired-device evidence, not missing code paths. |
| UX readiness | **95%** | Core flows are reachable and understandable; the notable repo-side polish issues identified in the original audit were closed. |
| Safety readiness | **84%** | Safety positioning is responsible in code and copy, but real Watch Ultra depth/submersion evidence is still missing. |
| Compile readiness | **90%** | `xcodegen` and both simulator builds pass on current `main`; signed/generic device builds still fail on external entitlement/provisioning. |
| TestFlight readiness | **68%** | Blocked by generic device build failure and missing physical Watch Ultra validation. |
| App Store readiness | **60%** | Blocked by the same entitlement/device evidence gap; repo-side polish issues from the original audit are no longer the reason it is blocked. |

### Executive verdict

`main` is now **repo-ready and simulator-ready**, but **still not TestFlight-ready or App Store-ready**. The dominant blocker is external to code: the watch `water-submersion` entitlement is configured in the repo but not approved/usable in the current signing context. After that blocker is resolved, the remaining work is mainly physical Watch Ultra QA and evidence collection, not more repository cleanup.

---

## C. Feature Inventory

Legend:

- `Implemented`: present in MAIN target
- `Reachable`: reachable through normal user navigation
- `Usable`: operable without developer-only steps
- `Complete`: production-complete enough for average-user expectation
- `Severity`: release impact if incomplete

| Platform | Feature | Implemented | Reachable | Usable | Complete | Notes | Severity |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Watch | Legal onboarding | Yes | Yes | Yes | Yes | `WatchLegalOnboardingView` hard-gates entry until accepted | Low |
| Watch | Launch disclaimer | Yes | Yes | Yes | Yes | Shown once per cold launch after legal onboarding | Low |
| Watch | Live Dive primary screen | Yes | Yes | Yes | Yes | Default main screen when only Diving is stable | Low |
| Watch | Automatic dive lifecycle | Yes | Conditional | Partial | Partial | Code path exists, but real validation depends on Watch Ultra hardware plus approved entitlement | High |
| Watch | Manual dive fallback | Yes | Yes | Yes | Partial | Good fallback when automatic depth is unavailable; still needs device QA for real-world clarity | Medium |
| Watch | Depth display | Yes | Yes | Yes | Yes | Remains visually dominant in Live | Low |
| Watch | Runtime | Yes | Yes | Yes | Yes | Co-visible with TTV | Low |
| Watch | TTV | Yes | Yes | Yes | Yes | Informational wording is generally safe | Low |
| Watch | Stopwatch START / STOP / RESET | Yes | Yes | Yes | Yes | Functional, exposed via App Intents, and reset now has an explicit confirmation safeguard | Low |
| Watch | Average / max depth | Yes | Yes | Yes | Yes | Visible in Live and detail surfaces | Low |
| Watch | Temperature | Yes | Yes | Yes | Partial | Code path exists; still needs physical validation with real depth session | Low |
| Watch | Ascent gauge | Yes | Yes | Yes | Yes | Still visible while inline warning is shown | Low |
| Watch | Inline ascent warning | Yes | Yes | Yes | Yes | Correct inline non-modal philosophy | Low |
| Watch | Depth safety warnings 35 / 38 / 40 | Yes | Yes | Yes | Yes | Visual + haptic coordination present | Low |
| Watch | GPS compact banners | Yes | Yes | Yes | Yes | Compact banner does not replace main metrics | Low |
| Watch | BUSSOLA / bearing | Yes | Yes | Yes | Yes | Core flow works and bearing labels are localized in current MAIN | Low |
| Watch | SET / CLEAR BEARING | Yes | Yes | Yes | Yes | Works and is now localized in current MAIN | Low |
| Watch | Dive Log | Yes | Yes | Yes | Yes | Clean list, empty state, delete access | Low |
| Watch | Dive Detail | Yes | Yes | Yes | Yes | Export and delete reachable; back affordance present | Low |
| Watch | Delete confirmation | Yes | Yes | Yes | Yes | Proper confirmation dialog | Low |
| Watch | Manual dive edit | No | No | No | No | Not implemented on Watch MAIN; only manual fallback lifecycle exists | Low |
| Watch | CSV export | Yes | Yes | Yes | Yes | Subsurface-oriented export flow present | Low |
| Watch | ShareLink / share flow | Yes | Yes | Yes | Yes | Export route and share handoff exist | Low |
| Watch | User Images | Yes | Yes | Yes | Yes | MAIN now exposes a real empty state and detail view outside dives | Low |
| Watch | Settings hub | Yes | Yes | Yes | Yes | Rich and mostly honest settings surface | Low |
| Watch | Alarm settings | Yes | Yes | Yes | Yes | Surface-only editing during dive is clearly explained | Low |
| Watch | Language setting | Yes | Yes | Yes | Yes | Watch-local, clearly scoped | Low |
| Watch | Units setting | Yes | Yes | Yes | Partial | Applied broadly; remaining uncertainty is physical QA, not repo-side wording or reachability | Low |
| Watch | Haptics toggle | Yes | Yes | Yes | Yes | Global toggle is respected by `HapticService` | Low |
| Watch | Sync status | Yes | Yes | Yes | Yes | Summary status plus recent per-item activity are visible on Watch and iOS surfaces | Low |
| Watch | Retry queue / clear failed queue | Yes | Yes | Yes | Yes | Queue actions are visible and understandable | Low |
| Watch | InfoView / diagnostics | Yes | Yes | Yes | Yes | Helpful diagnostics now distinguish target config from provisioning approval | Low |
| Watch | App Intents | Yes | Partial | Partial | Partial | Implemented and extracted in build; needs hardware QA | Medium |
| Watch | Shortcut help | Yes | Yes | Yes | Yes | Honest about Action Button / Side Button limitations | Low |
| iOS | Legal onboarding | Yes | Yes | Yes | Yes | Hard-gates entry until accepted | Low |
| iOS | Launch disclaimer | Yes | Yes | Yes | Yes | Session-based overlay appears after legal onboarding | Low |
| iOS | Tab navigation | Yes | Yes | Yes | Yes | Stable tabs only: Planner, Logbook, Analysis, Equipment, More | Low |
| iOS | Planner | Yes | Yes | Yes | Yes | Broad feature coverage with current stable-mode framing and updated localization/copy | Low |
| iOS | Planner safety acknowledgment | Yes | Yes | Yes | Yes | Proper gate before planning inputs | Low |
| iOS | PlanResultView | Yes | Yes | Yes | Yes | Functional and current stable result cards are localized in MAIN | Low |
| iOS | Logbook | Yes | Yes | Yes | Yes | Good list, sections, add manual, delete non-demo entries | Low |
| iOS | DiveDetailView | Yes | Yes | Yes | Yes | Metrics, charts, GPS, export, edit for manual dives | Low |
| iOS | Manual dive add | Yes | Yes | Yes | Yes | Reachable from Logbook `+` | Low |
| iOS | Manual dive edit | Yes | Yes | Yes | Yes | Proper return path and refresh behavior | Low |
| iOS | DiveDetail refresh after edit | Yes | Yes | Yes | Yes | Confirmed by current code path and earlier UX audit | Low |
| iOS | Analysis | Yes | Yes | Yes | Yes | Good empty state and useful actions | Low |
| iOS | Charts | Yes | Yes | Yes | Yes | Present in Analysis and DiveDetail | Low |
| iOS | CSV import | Yes | Yes | Yes | Yes | Available from Analysis, Logbook, and More | Low |
| iOS | CSV export | Yes | Yes | Yes | Yes | Per-dive export works from detail view | Low |
| iOS | Equipment | Yes | Yes | Yes | Yes | Functional templates/checklist/gas toggle with stable localized surfaces | Low |
| iOS | More / settings | Yes | Yes | Yes | Yes | Good centralization of sync/cloud/legal/demo controls | Low |
| iOS | Cloud sync | Yes | Yes | Partial | Partial | Clear visibility, but still needs real iCloud account-state QA | Medium |
| iOS | Reset pairing trust | Yes | Yes | Yes | Yes | Explicit confirmation flow | Low |
| iOS | Push to Watch | Yes | Yes | Yes | Yes | Clearly exposed in More | Low |
| iOS | Conflict handling | Yes | Yes | Yes | Yes | Conflict card is actionable and understandable | Low |
| iOS | Language | Yes | Yes | Yes | Yes | App-wide locale environment applied | Low |
| iOS | Units | Yes | Yes | Partial | Partial | Broadly supported, but planner still stays metric internally by design | Medium |
| iOS | Demo logbook | Yes | Yes | Yes | Yes | Helpful reviewer/testing feature | Low |
| iOS | Legal / safety surface | Yes | Yes | Yes | Yes | Good visibility and Terms/Privacy now point to dedicated legal docs | Low |

---

## D. Navigation Map

### Watch flows

```text
DIRDivingApp
└─ NavigationStack
   ├─ [if needed] WatchLegalOnboardingView
   └─ ContentView (vertical TabView)
      ├─ [dormant in MAIN] ModeSelectionView
      ├─ DiveLiveView
      ├─ CompassView (BUSSOLA)
      ├─ SettingsView
      │  ├─ AscentRateSettingsView
      │  ├─ AlarmSettingsView
      │  ├─ WatchLegalOnboardingView legal destinations
      │  ├─ WatchShortcutHelpView
      │  └─ InfoView
      ├─ UserImagesView
      └─ DiveLogListView
         ├─ DiveDetailView
         └─ ExportView

Overlay after legal gate:
└─ LaunchCompanionDisclaimerOverlay
```

### Underwater restrictions

- `DiveLiveView` remains the primary underwater destination
- During an active dive, `ContentView` forces navigation back to `Live` unless the page is `Live` or `Compass`
- Result: Settings, User Images, and Dive Log are intentionally blocked during active diving
- This is safe and consistent with underwater UX goals

### iOS flows

```text
DIRDivingiOSApp
├─ [if needed] IOSLegalOnboardingView
└─ ContentView (TabView)
   ├─ Planner
   │  └─ PlanResultView
   ├─ Logbook
   │  ├─ DiveDetailView
   │  │  └─ ManualDiveEditorView (manual dives)
   │  └─ ManualDiveEditorView (add)
   ├─ Analysis
   ├─ Equipment
   │  └─ EquipmentTemplatesSheet / EquipmentTemplateEditorView
   └─ More
      └─ IOSLegalOnboardingView legal section / More actions

Overlay after legal gate:
└─ LaunchCompanionDisclaimerOverlay
```

### Dead ends / hidden routes

- No critical dead ends were found in current MAIN navigation
- Watch `ModeSelectionView` is intentionally dormant because MAIN exposes only stable Diving
- Watch `UserImagesView` is no longer hidden behind content existence; it now has a real empty state
- iOS planner shows non-advanced modes visually, but only `advanced` is selectable; this is not a broken route, but it is a clarity issue

---

## E. UI Consistency Report

| Area | Deviation | Severity | Recommended fix |
| --- | --- | --- | --- |
| Watch Live | Strong match with premium black/neon reference; no serious drift found in code | Low | Keep current structure; verify screenshots on physical devices |
| Watch Compass | Core screen fits the style and the previous bilingual consistency gap is resolved in current MAIN | Low | Keep current structure; verify screenshots on physical devices |
| Watch Info | Useful diagnostics fit the style and entitlement wording is now appropriately cautious | Low | Keep current structure; verify on hardware after provisioning approval |
| Watch legal/help surfaces | Side Button wording is truthful and consistent with product philosophy | Low | Keep |
| iOS Companion overall | Dark marine / cyan visual system remains consistent across tabs | Low | Keep |
| iOS Planner | Strong structure; previous stable-MAIN localization and disabled-mode concerns are resolved in current MAIN | Low | Keep current structure; validate on real device screenshots |
| iOS More | Feature-dense and understandable; previous mixed-language labels were normalized in current MAIN | Low | Keep |
| Legal destinations | Terms / Privacy now resolve to dedicated legal docs in the repository | Low | Keep destinations updated if public/legal URLs change later |

### Terminology consistency

- `BUSSOLA` terminology is preserved in MAIN
- No `COMPASSO` regression was found in MAIN watch-facing UX
- No confirmed `COMPASSO` or mixed-language regression remains in the audited stable-MAIN screens after the post-audit fix pass

---

## F. Settings Report

### Watch settings

| Setting | UI available | Persisted | Applied | Synced | Notes |
| --- | --- | --- | --- | --- | --- |
| Units | Yes | Yes | Yes | Yes | Published to paired iPhone |
| Language | Yes | Yes | Yes | No | Watch-local by design |
| Haptics | Yes | Yes | Yes | No | Global toggle respected |
| Ascent limits | Yes | Yes | Yes | No | Good watch-local behavior |
| Alarm toggles / thresholds | Yes | Yes | Yes | No | Surface-only editing is honest |
| GPS status | Yes | Runtime | Yes | No | Surface-only behavior explained |
| Depth diagnostics | Yes | Runtime | Yes | No | Useful but wording too optimistic on entitlement readiness |
| Sync queue | Yes | Runtime | Yes | N/A | Aggregate counters only |
| Export info | Info-only | N/A | N/A | No | Action lives in log/detail, not Settings |
| Display / Always-On copy | Info-only | N/A | N/A | No | Honest watchOS-managed messaging |
| Shortcut help | Yes | N/A | Yes | No | Good discoverability |

Watch settings verdict:

- Reachable, honest, and mostly complete
- No deceptive tappable rows were found
- Biggest remaining issue is not missing settings, but diagnostic honesty around entitlement readiness

### iOS settings

| Setting | UI available | Persisted | Applied | Synced | Notes |
| --- | --- | --- | --- | --- | --- |
| Language | Yes | Yes | Yes | No | App-wide locale environment |
| Units | Yes | Yes | Yes | Partial | Sent to Watch; planner stays metric internally |
| Watch sync state | Yes | Runtime | Yes | N/A | Good visibility but aggregate only |
| Push to Watch | Yes | Runtime action | Yes | N/A | Clear action |
| Reset pairing trust | Yes | Runtime action | Yes | N/A | Good destructive confirmation |
| iCloud sync | Yes | Runtime action | Yes | iCloud | Availability surfaced |
| Demo logbook | Yes | Yes | Yes | No | Testing/reviewer helper |
| Planner safety acknowledgment | Yes | Yes | Yes | No | Honest gate |
| Legal / safety | Yes | Yes | Yes | No | Good visibility; destination quality still weak |
| Import / export access | Yes | Runtime action / route | Yes | N/A | Good reachability |

iOS settings verdict:

- Reachable and understandable
- Main gap is **sync visibility depth** rather than missing actions
- Planner metric-only behavior is disclosed, but it still creates mixed expectation for imperial users

---

## G. Haptics / Hardware Report

### Crown / touch / buttons

| Interaction | Status | Notes |
| --- | --- | --- |
| Digital Crown vertical navigation | Implemented | `TabView` vertical page style on watch |
| Crown scrolling on long watch screens | Implemented | Native scroll behavior |
| Crown threshold adjustment for alarms | Implemented | `AlarmSettingsView` uses crown rotation |
| Crown threshold adjustment for ascent settings | Implemented | `AscentRateSettingsView` uses crown rotation |
| Touch navigation | Implemented | Primary fallback everywhere |
| Side Button direct control | Not supported | Correctly documented as system-controlled |
| Action Button support model | Implemented via App Intents | Honest and within platform limits |
| Long press behavior | Mostly absent | No notable long-press guard on stopwatch reset |

### App Intents audit

All requested MAIN intents are implemented in `Services/ActionButtonIntents.swift`:

- `ToggleStopwatchIntent`
- `ResetStopwatchIntent`
- `StartManualDiveIntent`
- `EndManualDiveIntent`
- `SetBearingIntent`
- `ClearBearingIntent`
- `AcknowledgeAlarmIntent`

App Intents verdict:

- **Implemented:** yes
- **Exposed in build metadata:** yes (`ExtractAppIntentsMetadata` occurs in simulator build)
- **Documented:** yes
- **Safe in concept:** yes
- **Physical Watch QA required:** yes

### Haptic audit

| Event | Status | Notes |
| --- | --- | --- |
| Dive start | Implemented | Confirmation pattern |
| Dive stop | Implemented | Confirmation pattern |
| Stopwatch start / stop / reset | Implemented | Generic confirmation haptic |
| Ascent warning | Implemented | Initial + repeated throttled warning haptic |
| Depth safety warnings | Implemented | Coordinated through depth-limit haptic path |
| GPS confirmation | Implemented | Confirmation feedback on successful lifecycle points |
| Bearing SET / CLEAR | Implemented | Confirmation feedback |
| Alarm acknowledge | Implemented | Notify feedback |
| Export success / failure | Implemented | Distinct success/failure behavior |
| Sync retry / success / failure | Partial | Retry action confirms; not every state transition has a unique haptic |
| Delete confirmation | Partial | Confirmation dialog exists; delete action itself has no dedicated distinct haptic |

Haptic verdict:

- Global haptics toggle is respected
- Safety events still have visual fallback when haptics are off
- No evidence of excessive repeated haptics beyond the intended repeat interval

---

## H. Sync Report

### Watch -> iPhone

- `WatchSyncService` queues pending sessions and tracks pending, sent, acknowledged, and failed counts
- It uses direct message when reachable and transfer fallback when needed
- Signed-ack / peer-trust flows are present from prior work and still represented in current services

### iPhone -> Watch

- More screen exposes push-to-watch
- Tombstones and photo transfer flows are present
- Units are propagated via app context

### Failure / duplicate / queue handling

| Area | Status | Notes |
| --- | --- | --- |
| Duplicate suppression | Present | Service-level logic exists |
| Conflict UI | Present | iOS conflict card is actionable |
| Offline handling | Present in design | Needs paired-device QA |
| Queue handling | Present | Aggregate counts/actions exposed |
| Keep-local re-push | Present | Resolved through current sync service path |
| Silent failure risk | Reduced | User-visible last event/status exists, but still aggregate rather than per-session |

Sync verdict:

- Architecturally solid enough for MAIN
- Biggest UX gap is **per-dive traceability**
- Biggest release gap is **paired-device QA**, not missing code structure

---

## I. Export Report

### Formats and behavior

- Watch export: Subsurface-oriented CSV
- iOS export: Subsurface-oriented CSV with additional manual-dive metadata
- Share flow exists on both sides

### File naming and temporary file handling

Confirmed in current export services:

- filenames use opaque UUID-based names like `DIRDiving_Export_<UUID>.csv`
- files are written to temporary directory
- files use `.atomic` and `.completeFileProtection`
- stale CSV files older than 24 hours are cleaned up

### Empty / failure handling

| Platform | Empty / invalid handling |
| --- | --- |
| Watch | Export returns unavailable/failure states cleanly; share flow depends on generated URL |
| iOS | `SubsurfaceExportService.ExportError` reports `emptySamples` and write failures clearly |

Export verdict:

- Export pipeline is solid and appropriately conservative
- No major export blocker was found inside MAIN code
- Remaining validation need is UI QA of share sheets on real devices

---

## J. Localization Report

Localization is substantially healthier than older audits suggested. Many literal SwiftUI strings are backed by entries in `Resources/*.lproj` and `iOSApp/Resources/*.lproj`.

Post-audit implementation work on current `main` closed the confirmed stable-MAIN localization gaps originally listed here:

- Watch `BUSSOLA` bearing controls were localized
- Watch `InfoView` labels and entitlement note were localized/reworded
- iOS `Planner` / `PlanResultView` literal labels were localized
- iOS `More` mixed-language labels were normalized for Italian mode

Current residual localization risk is no longer a confirmed code-string gap in stable MAIN surfaces, but rather final real-device screenshot / clipping verification across supported sizes.

### Remaining notable gaps

| File | String | Screen | Severity | Suggested action |
| --- | --- | --- | --- | --- |
| None currently confirmed in stable MAIN code paths after post-audit fixes | — | — | Low | Verify bilingual screenshots and clipping on real device sizes before release |

### Mixed-language screen summary

- Watch `BUSSOLA`: repo-side localization gap resolved
- Watch `InfoView`: repo-side wording gap resolved
- iOS `Planner` / `PlanResultView`: repo-side localization debt resolved in current MAIN
- iOS `More`: stable labels normalized in current MAIN

### Terminology check

- `BUSSOLA` is preserved
- No `COMPASSO` regression found in MAIN

---

## K. Safety / Legal Report

| Area | Status | Severity | Notes |
| --- | --- | --- | --- |
| Non-certified dive computer wording | Good | Low | Present in onboarding/legal surfaces and docs |
| TTV wording | Good | Low | Framed as informational, not decompression authority |
| Planner disclaimers | Good | Low | Safety acknowledgment gate and metric notice exist |
| Ascent warning philosophy | Good | Low | Inline and non-blocking |
| Depth-limit warnings | Good | Low | Inline + visual + haptic support |
| GPS limitation framing | Good | Low | Surface-only behavior is consistently explained |
| Silent GPS/depth failure risk | Partial | Medium | UI gives status, but real underwater/device behavior still needs field QA |
| Terms / Privacy destination quality | Good | Low | Dedicated legal destinations now exist in `Docs/TERMS_OF_USE.md` and `Docs/PRIVACY_AND_DATA_USE.md` |
| Entitlement/device blocker | Critical | Critical | Generic device builds fail until water-submersion entitlement is approved in active provisioning |
| App Store rejection risk | Real | High | Remaining risk is now driven mainly by entitlement/device evidence, not by missing legal destinations in the repo |

Safety / legal verdict:

- Product positioning is mostly responsible
- The current release blocker is **not unsafe copy drift**, but missing real signed-device proof for the watch depth capability
- Legal destinations are now present; remaining safety/readiness work is external provisioning plus real hardware evidence

---

## L. Error / Empty State Report

| Scenario | Current behavior | Verdict |
| --- | --- | --- |
| No GPS | Watch and iOS expose unavailable/fallback/fix status messaging | Good |
| No depth automation | Watch exposes manual fallback path and diagnostic status | Good |
| No temperature | Metrics handle missing values conservatively | Good |
| No paired Watch / iPhone | Sync status and reset trust flows are visible | Good |
| Sync fails | Aggregate retry/failed state is surfaced | Partial |
| Export fails | Failure message / no-URL handling exists | Good |
| Permissions denied | GPS and legal/status copy exist; full permission-guidance polish could still improve | Partial |
| No User Images | Real empty state now exists on watch | Good |
| No peer secret | Sync state messaging exists | Good |
| No entitlement | Device build fails before field QA; InfoView wording is more optimistic than actual provisioning result | Partial |
| Haptics disabled | Visual fallback badge remains available | Good |
| No dives / empty logbook | Empty states exist on watch and iOS | Good |

Error / empty-state verdict:

- No major crash-shaped empty state problem was found in MAIN
- The remaining gap is **specificity**, especially around sync and entitlement readiness

---

## M. Bugs To Fix

| Title | Platform | File / screen | Severity | User impact | Recommended fix | Estimated impact |
| --- | --- | --- | --- | --- | --- | --- |
| Water-submersion entitlement not usable in current signing context | Watch + iOS release pair | Signing / Apple Developer / provisioning | Critical | Blocks generic device build, TestFlight, and physical dive automation validation | Enable/approve capability for watch App ID, regenerate profiles, re-test generic builds | External QA/process |
| Generic iOS device build blocked by embedded watch entitlement failure | iOS release pair | Build / signing | Critical | Prevents release-grade iOS build with embedded watch target | Resolve the same watch entitlement/profile blocker | External QA/process |
| Automatic dive lifecycle not validated on real Watch Ultra | Watch | Physical device behavior | High | Core underwater automation is still not release-certified by evidence | Run real Watch Ultra field/device QA using updated profiles | External QA/process |
| Repo-side medium/low findings from the original audit | Watch + iOS stable UX | Legal / Info / Compass / Planner / More / Sync / Stopwatch surfaces | Resolved | No longer blocking current `main` | Fixed on current `main`; keep regression coverage via simulator builds and future QA | Resolved in repo |

---

## N. Priority Roadmap

### 1. Must fix before compile/use

1. Resolve the Apple Developer / provisioning approval for `com.apple.developer.coremotion.water-submersion`
2. Re-run generic device builds for both schemes
3. Confirm that the Watch companion app pair archives/signs cleanly after profile regeneration

### 2. Must fix before TestFlight

1. Execute physical Apple Watch Ultra QA for automatic dive lifecycle, depth display, safety bands, and haptics
2. Run paired Watch <-> iPhone sync QA for dives, tombstones, conflicts, units, and photo transfer
3. Archive/store device evidence that the underwater path behaves as documented on approved hardware

### 3. Must fix before App Store

1. Reconfirm bilingual screenshots and clipping on real device sizes
2. Keep all underwater/device claims aligned only to behavior verified on real hardware

### 4. Post-release improvements

1. Consider deeper sync history/ledger if QA wants more than the current recent-activity trace
2. Consider expanding planner unit presentation beyond the current honest metric/bar framing if product scope changes

---

## O. Final Verdict

| Question | Verdict | Why |
| --- | --- | --- |
| Ready to compile? | **Yes for simulator, no for signed/generic device release builds** | `xcodegen` passes and both simulator builds pass, but generic watch/iOS builds fail on the watch water-submersion entitlement provisioning context |
| Ready for internal QA? | **Yes, conditionally** | Simulator and code-level UX are strong enough to continue QA, but physical watch QA is still required for the core dive automation path |
| Ready for average user? | **Not yet** | Repo-side polish issues from the original audit are fixed, but release confidence still depends on unverified Watch Ultra behavior |
| Ready for TestFlight? | **No** | Blocked by generic device build failure and missing physical Watch Ultra validation |
| Ready for App Store? | **No** | The remaining blocker is the same entitlement/device-evidence gap; repo-side legal/localization cleanup is no longer the reason it is blocked |
| What blocks 100% readiness? | **Provisioning approval + device evidence** | Current validation indicates that 100% release readiness is no longer blocked by repo-side issues; the remaining blockers are Apple signing approval and real hardware proof |

### Bottom line

The current `main` branch is **repo-ready, polished, and simulator-ready**. This is no longer a branch suffering from major MAIN navigation collapse, accidental experimental dependency, or unresolved stable-UI polish debt. The remaining blockers are narrower and well-defined:

1. the watch water-submersion entitlement must be usable in the active signing context  
2. the automatic dive lifecycle must be validated on real Apple Watch Ultra hardware  
3. release confidence must be backed by real hardware evidence before submission

No evidence from this audit suggests a required architectural rewrite, planner algorithm rewrite, or dive/depth/ascent/TTV logic rewrite.
