# DIR DIVING — MAIN Branch Complete Readiness Audit

**Date:** 2026-05-25  
**Branch audited:** `main` @ `21a7f41`  
**Targets audited:** `DIRDiving Watch App`, `DIRDiving iOS`  
**Audit type:** Pre-modification readiness audit only. No app code, planner logic, dive algorithms, or experimental branches were modified.  
**Reference UI:** `Docs/ReferenceUI/Watch_LIVE_reference.png`, `Docs/ReferenceUI/iOS_Companion_reference.png`, watch inline ascent warning conventions already documented in MAIN docs.

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
| Overall readiness | **76%** | MAIN is coherent and mostly reachable on simulator, but not yet release-ready because generic device builds are blocked and a few UX/legal/localization gaps remain. |
| Watch readiness | **82%** | The watch Diving MAIN flow is strong: Live, BUSSOLA, alarms, sync, export, settings, and images are all present. Remaining blockers are mostly entitlement/device QA and a few mixed-language labels. |
| iOS readiness | **80%** | The iOS companion has full stable tabs and good flow coverage: Planner, Logbook, Analysis, Equipment, More, sync, import/export. Remaining gaps are planner honesty polish, mixed-language strings, and release-process checks. |
| UX readiness | **85%** | Core flows are reachable and understandable. No serious dead-end navigation was found. Most remaining issues are clarity/polish, not broken flow. |
| Safety readiness | **80%** | Safety positioning is mostly correct: non-certified wording, inline underwater alarms, GPS surface-only framing, planner caution. Biggest missing piece is real Watch Ultra depth/submersion validation. |
| Compile readiness | **86%** | `xcodegen` and both simulator builds pass. Signed/generic device builds fail on entitlement/provisioning, so compile readiness is not yet release compile readiness. |
| TestFlight readiness | **63%** | Blocked by generic device build failure, missing physical Watch Ultra QA, and legal-link/reviewer polish gaps. |
| App Store readiness | **54%** | Blocked by the same device/entitlement issue, plus legal destination quality and final bilingual cleanup. |

### Executive verdict

`main` is **simulator-ready and structurally healthy**, but **not yet TestFlight-ready or App Store-ready**. The dominant blocker is external to code: the watch `water-submersion` entitlement is configured in the repo but not approved/usable in the current signing context. After that blocker is resolved, the remaining work is mostly small: legal destination cleanup, mixed-language cleanup, planner honesty polish, and physical Watch Ultra QA.

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
| Watch | Stopwatch START / STOP / RESET | Yes | Yes | Yes | Partial | Functional and exposed via App Intents; no long-press/reset safeguard | Low |
| Watch | Average / max depth | Yes | Yes | Yes | Yes | Visible in Live and detail surfaces | Low |
| Watch | Temperature | Yes | Yes | Yes | Partial | Code path exists; still needs physical validation with real depth session | Low |
| Watch | Ascent gauge | Yes | Yes | Yes | Yes | Still visible while inline warning is shown | Low |
| Watch | Inline ascent warning | Yes | Yes | Yes | Yes | Correct inline non-modal philosophy | Low |
| Watch | Depth safety warnings 35 / 38 / 40 | Yes | Yes | Yes | Yes | Visual + haptic coordination present | Low |
| Watch | GPS compact banners | Yes | Yes | Yes | Yes | Compact banner does not replace main metrics | Low |
| Watch | BUSSOLA / bearing | Yes | Yes | Yes | Partial | Core flow works; some controls remain mixed-language / hardcoded | Medium |
| Watch | SET / CLEAR BEARING | Yes | Yes | Yes | Partial | Works, but `SET BEARING` / dynamic bearing line should be fully localized | Medium |
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
| Watch | Units setting | Yes | Yes | Yes | Partial | Applied broadly; still needs physical QA and some polish wording | Low |
| Watch | Haptics toggle | Yes | Yes | Yes | Yes | Global toggle is respected by `HapticService` | Low |
| Watch | Sync status | Yes | Yes | Partial | Partial | Aggregate status is good; no per-dive delivery ledger | Medium |
| Watch | Retry queue / clear failed queue | Yes | Yes | Yes | Yes | Queue actions are visible and understandable | Low |
| Watch | InfoView / diagnostics | Yes | Yes | Yes | Partial | Helpful, but entitlement wording can overstate readiness | Medium |
| Watch | App Intents | Yes | Partial | Partial | Partial | Implemented and extracted in build; needs hardware QA | Medium |
| Watch | Shortcut help | Yes | Yes | Yes | Yes | Honest about Action Button / Side Button limitations | Low |
| iOS | Legal onboarding | Yes | Yes | Yes | Yes | Hard-gates entry until accepted | Low |
| iOS | Launch disclaimer | Yes | Yes | Yes | Yes | Session-based overlay appears after legal onboarding | Low |
| iOS | Tab navigation | Yes | Yes | Yes | Yes | Stable tabs only: Planner, Logbook, Analysis, Equipment, More | Low |
| iOS | Planner | Yes | Yes | Yes | Partial | Broad feature coverage; remaining issue is honesty/polish, not absence | Medium |
| iOS | Planner safety acknowledgment | Yes | Yes | Yes | Yes | Proper gate before planning inputs | Low |
| iOS | PlanResultView | Yes | Yes | Yes | Partial | Functional, but still has several mixed-language labels in result cards | Medium |
| iOS | Logbook | Yes | Yes | Yes | Yes | Good list, sections, add manual, delete non-demo entries | Low |
| iOS | DiveDetailView | Yes | Yes | Yes | Yes | Metrics, charts, GPS, export, edit for manual dives | Low |
| iOS | Manual dive add | Yes | Yes | Yes | Yes | Reachable from Logbook `+` | Low |
| iOS | Manual dive edit | Yes | Yes | Yes | Yes | Proper return path and refresh behavior | Low |
| iOS | DiveDetail refresh after edit | Yes | Yes | Yes | Yes | Confirmed by current code path and earlier UX audit | Low |
| iOS | Analysis | Yes | Yes | Yes | Yes | Good empty state and useful actions | Low |
| iOS | Charts | Yes | Yes | Yes | Yes | Present in Analysis and DiveDetail | Low |
| iOS | CSV import | Yes | Yes | Yes | Yes | Available from Analysis, Logbook, and More | Low |
| iOS | CSV export | Yes | Yes | Yes | Yes | Per-dive export works from detail view | Low |
| iOS | Equipment | Yes | Yes | Yes | Partial | Functional templates/checklist/gas toggle, but a few strings remain mixed-language | Medium |
| iOS | More / settings | Yes | Yes | Yes | Yes | Good centralization of sync/cloud/legal/demo controls | Low |
| iOS | Cloud sync | Yes | Yes | Partial | Partial | Clear visibility, but still needs real iCloud account-state QA | Medium |
| iOS | Reset pairing trust | Yes | Yes | Yes | Yes | Explicit confirmation flow | Low |
| iOS | Push to Watch | Yes | Yes | Yes | Yes | Clearly exposed in More | Low |
| iOS | Conflict handling | Yes | Yes | Yes | Yes | Conflict card is actionable and understandable | Low |
| iOS | Language | Yes | Yes | Yes | Yes | App-wide locale environment applied | Low |
| iOS | Units | Yes | Yes | Partial | Partial | Broadly supported, but planner still stays metric internally by design | Medium |
| iOS | Demo logbook | Yes | Yes | Yes | Yes | Helpful reviewer/testing feature | Low |
| iOS | Legal / safety surface | Yes | Yes | Yes | Partial | Good visibility, but Terms/Privacy links still point to repository root | Medium |

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
| Watch Compass | Core screen fits the style, but remaining hardcoded labels (`SET BEARING`, bearing/delta string) weaken bilingual consistency | Medium | Localize the remaining literal controls/format strings |
| Watch Info | Useful diagnostics fit the style, but title/rows still use some direct literals and entitlement wording can overstate readiness | Medium | Localize literals and soften entitlement certainty |
| Watch legal/help surfaces | Side Button wording is truthful and consistent with product philosophy | Low | Keep |
| iOS Companion overall | Dark marine / cyan visual system remains consistent across tabs | Low | Keep |
| iOS Planner | Strong structure, but result cards still contain mixed-language labels and disabled future modes remain visible | Medium | Finish localization pass and visually reframe non-active modes |
| iOS More | Feature-dense but understandable; a few labels remain mixed-language (`Planner safety`, `Legal & Safety` keying style) | Low | Normalize copy |
| Legal destinations | Terms / Privacy are visible, but destination quality is not release-grade because both currently point to the repo root | Medium | Replace with real reviewer-facing legal destinations |

### Terminology consistency

- `BUSSOLA` terminology is preserved in MAIN
- No `COMPASSO` regression was found in MAIN watch-facing UX
- Some iOS surfaces still mix Italian and English in the same screen, especially planner/result/legal labels

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

Localization is substantially healthier than older audits suggested. Many literal SwiftUI strings are backed by entries in `Resources/*.lproj` and `iOSApp/Resources/*.lproj`. The remaining **confirmed** MAIN gaps are mostly mixed-language strings or direct literals in high-visibility areas.

### Remaining notable gaps

| File | String | Screen | Severity | Suggested key |
| --- | --- | --- | --- | --- |
| `Views/CompassView.swift` | `SET BEARING` | Watch `BUSSOLA` | Medium | `compass.bearing.set` |
| `Views/CompassView.swift` | `BEARING \(bearingText) \| DELTA \(deltaText)` | Watch `BUSSOLA` | Medium | `compass.bearing.delta_format` |
| `Views/InfoView.swift` | `INFO` | Watch Info | Low | `info.title` |
| `Views/InfoView.swift` | `Sync` | Watch Info | Low | `info.sync` |
| `Views/InfoView.swift` | `Richiede validazione reale su Apple Watch Ultra...` | Watch Info | Medium | `info.depth.validation_note` |
| `iOSApp/Views/PlannerView.swift` | `GF Low` / `GF High` | iOS Planner | Low | `planner.field.gf_low`, `planner.field.gf_high` |
| `iOSApp/Views/PlannerView.swift` | `SAC %@ L/min` | iOS Planner | Low | `planner.team.sac_format` |
| `iOSApp/Views/PlannerView.swift` | `GAS RESERVE` | iOS Planner | Low | `planner.card.reserve` |
| `iOSApp/Views/PlannerView.swift` | `Rock bottom` | iOS Planner | Low | `planner.metric.rock_bottom` |
| `iOSApp/Views/PlannerView.swift` | `Turn` | iOS Planner | Low | `planner.metric.turn_pressure` |
| `iOSApp/Views/PlannerView.swift` | `WARNING` | iOS Planner warnings | Low | `planner.warning.title` |
| `iOSApp/Views/PlannerView.swift` | `TEAM GAS MATCHING` | iOS Planner | Low | `planner.team.matching_title` |
| `iOSApp/Views/PlannerView.swift` | `TEAM GAS MATCH` | iOS Plan Result | Low | `planner.team.match_title` |
| `iOSApp/Views/PlannerView.swift` | `BRIEFING` | iOS Plan Result | Low | `planner.briefing.title` |
| `iOSApp/Views/PlannerView.swift` | `CURVA BUHLMANN ZH-L16C` | iOS Plan Result | Low | `planner.buhlmann.curve_title` |
| `iOSApp/Views/MoreView.swift` + `iOSApp/Resources/it.lproj/Localizable.strings` | `Planner safety` | iOS More | Low | `more.planner_safety.title` |
| `iOSApp/Resources/it.lproj/Localizable.strings` | `Subsurface CSV metrico; altri formati planned` | iOS units/export copy | Low | split into fully localized Italian phrasing |
| `iOSApp/Resources/it.lproj/Localizable.strings` | `BACKUP CLOUD`, `REVIEWER` | iOS More headers | Low | fully localized section labels if desired |

### Mixed-language screen summary

- Watch `BUSSOLA`: still the most visible remaining watch localization gap
- Watch `InfoView`: mostly small polish issue
- iOS `Planner` / `PlanResultView`: biggest remaining localization debt in stable iOS UX
- iOS `More`: mostly localized, but a few labels still mix English and Italian in Italian mode

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
| Terms / Privacy destination quality | Weak | Medium | Visible but both point to repository root, not reviewer-grade legal pages |
| Entitlement/device blocker | Critical | Critical | Generic device builds fail until water-submersion entitlement is approved in active provisioning |
| App Store rejection risk | Real | High | Current legal-link quality and lack of entitlement/device evidence remain submission risks |

Safety / legal verdict:

- Product positioning is mostly responsible
- The current release blocker is **not unsafe copy drift**, but missing real signed-device proof for the watch depth capability
- Legal destinations should still be improved before submission

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
| Terms and Privacy links point to repository root | Watch + iOS legal screens | `WatchLegalOnboardingView.swift`, `IOSLegalOnboardingView.swift` | Medium | Weak legal/reviewer experience; potential submission concern | Replace with dedicated legal destinations | Copy-only / UI-only |
| Watch Info entitlement diagnostics overstate readiness | Watch | `Views/InfoView.swift` | Medium | Testers may read “Configured” as “release-ready” even when signed builds fail | Reword diagnostics to distinguish static config from provisioning approval | Copy-only |
| Compass bearing controls still mixed-language | Watch | `Views/CompassView.swift` | Medium | Core navigation screen still looks partially unfinished in EN/IT audit | Localize control labels and formatted bearing line | UI-only |
| Planner result cards still mixed-language | iOS | `iOSApp/Views/PlannerView.swift` | Medium | High-value planning flow feels less polished and less reviewer-ready | Finish localization of remaining literal labels | UI-only |
| Planner shows disabled non-advanced modes | iOS | `iOSApp/Views/PlannerView.swift` | Medium | Users can see future modes that are not actually available | Keep visible but reframe as planned, or hide until active | UI-only |
| Planner metric-only behavior can feel inconsistent with global units | iOS | `iOSApp/Views/PlannerView.swift`, related strings | Medium | Imperial users encounter mixed expectations | Keep honest note and consider clearer framing or full presentation conversion later | Small functional or UI-only |
| Sync status is aggregate, not per-session | Watch + iOS | Sync surfaces | Medium | Harder to verify a specific dive/photo transfer | Add per-item delivery trace later | Small functional |
| Stopwatch reset lacks extra safeguard | Watch | `Views/DiveLiveView.swift` | Low | Surface/underwater accidental reset risk | Consider long-press or confirm flow after UX review | UI-only / small functional |
| More/legal copy still partially mixed-language | iOS | `iOSApp/Views/MoreView.swift`, localized strings | Low | Polish issue in stable settings surface | Normalize Italian/English labels | UI-only |

---

## N. Priority Roadmap

### 1. Must fix before compile/use

1. Resolve the Apple Developer / provisioning approval for `com.apple.developer.coremotion.water-submersion`
2. Re-run generic device builds for both schemes
3. Confirm that the Watch companion app pair archives/signs cleanly after profile regeneration

### 2. Must fix before TestFlight

1. Execute physical Apple Watch Ultra QA for automatic dive lifecycle, depth display, safety bands, and haptics
2. Run paired Watch <-> iPhone sync QA for dives, tombstones, conflicts, units, and photo transfer
3. Replace repo-root Terms / Privacy destinations with real reviewer-grade legal pages
4. Tighten `InfoView` wording so entitlement status is honest

### 3. Must fix before App Store

1. Finish remaining planner / compass / More mixed-language cleanup
2. Reconfirm bilingual screenshots and clipping on real device sizes
3. Keep all underwater/device claims aligned only to behavior verified on real hardware

### 4. Post-release improvements

1. Add per-session sync visibility instead of aggregate-only state
2. Revisit stopwatch reset safeguard
3. Decide whether disabled planner modes should remain visible in stable MAIN

---

## O. Final Verdict

| Question | Verdict | Why |
| --- | --- | --- |
| Ready to compile? | **Yes for simulator, no for signed/generic device release builds** | `xcodegen` passes and both simulator builds pass, but generic watch/iOS builds fail on the watch water-submersion entitlement provisioning context |
| Ready for internal QA? | **Yes, conditionally** | Simulator and code-level UX are strong enough to continue QA, but physical watch QA is still required for the core dive automation path |
| Ready for average user? | **Not yet** | Too much release confidence still depends on unverified Watch Ultra behavior and unresolved legal/reviewer polish |
| Ready for TestFlight? | **No** | Blocked by generic device build failure and missing physical Watch Ultra validation |
| Ready for App Store? | **No** | Same entitlement/device blocker, plus legal destination quality and final localization cleanup still need attention |
| What blocks 100% readiness? | **Provisioning approval + device evidence + polish** | The primary blocker is external signing/provisioning, followed by real device proof and a smaller cleanup pass on planner/compass/legal strings |

### Bottom line

The current `main` branch is **substantially ready from a stable-UI and simulator-readiness perspective**. This is no longer a branch suffering from major MAIN navigation collapse or accidental experimental dependency. The remaining blockers are narrower and well-defined:

1. the watch water-submersion entitlement must be usable in the active signing context  
2. the automatic dive lifecycle must be validated on real Apple Watch Ultra hardware  
3. a final polish pass should close mixed-language planner/compass/legal issues before release

No evidence from this audit suggests a required architectural rewrite, planner algorithm rewrite, or dive/depth/ascent/TTV logic rewrite.
