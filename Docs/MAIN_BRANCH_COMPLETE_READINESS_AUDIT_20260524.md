# MAIN BRANCH COMPLETE READINESS AUDIT

Converted from the DOCX readiness report.

MAIN BRANCH COMPLETE READINESS AUDIT

DIR DIVING - Apple Watch MAIN app and iOS Companion MAIN app

| Field | Value |
| --- | --- |
| Repository | C:\Users\egopf\Documents\GitHub\DirDiving-App |
| Branch | main |
| Commit inspected | 91f3c8dd303a376dd65ed2af70bf1171682ca2e8 (local == origin/main) |
| Audit date | 2026-05-24 |
| Mode | Audit-only: no code changes, no experimental branch edits |

| Verdetto breve: MAIN non e ancora al 100% per utente medio/TestFlight/App Store. La configurazione sembra coerente, ma la build non e verificabile su questo host Windows; ci sono blocker funzionali/documentali su disclaimer ogni launch, default runtime alarm, unit display in Log/Compass, e convalida reale Watch Ultra. |
| --- |

## A. Branch Confirmed

- Branch corrente: main.

- Stato locale: main allineato a origin/main; HEAD e origin/main entrambi su 91f3c8d.

- Target ispezionati: DIRDiving Watch App e DIRDiving iOS.

- Nessuna modifica codice eseguita. Output creato: questo file DOCX in Docs/.

- project.yml esclude i file sperimentali Apnea, Snorkeling, Buddy Assist, Exploration e Experimental dai target MAIN.

- xcodegen e xcodebuild non disponibili in questo ambiente Windows: build non provata localmente.

## B. Executive Summary

| Area | Readiness | Sintesi |
| --- | --- | --- |
| Overall | 74% | Buona copertura funzionale MAIN, ma non 100% a causa di build non verificata e blocker UX/safety. |
| Apple Watch | 78% | Live Dive, BUSSOLA, log, export, settings e sync presenti; bug su unita in Compass/Log e runtime alarm fallback. |
| iOS Companion | 72% | Planner, log, detail, analysis, equipment, sync, export presenti; unita incomplete in alcune liste/planner e disclaimer non ogni launch. |
| UX | 76% | Flussi principali raggiungibili; restano copy placeholder/future, partial i18n e alcune azioni non confermate da device QA. |
| Safety | 70% | Disclaimer/onboarding robusti, ma avviso companion non every launch e validazione Watch Ultra/depth entitlement non provata. |
| Compile | 55% | Configurazione XcodeGen leggibile e asset completi; compilazione non eseguita per toolchain assente. |

| Conclusione: Pronto per audit tecnico e correzioni mirate. Non pronto da dichiarare 100% compilabile, TestFlight-ready o App Store-ready senza macOS/Xcode build, device QA e fix dei blocker indicati. |
| --- |

## C. Feature Inventory

| Platform | Feature | Implemented | Reachable | Usable | Complete | Notes | Severity |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Watch | Main Dive screen | Y | Y | Y | Partial | Premium dark/neon live UI; primary underwater page preserved. | MED |
| Watch | Depth display | Y | Y | Y | Partial | Live uses unit formatter; Compass and log list still hardcode meters. | HIGH |
| Watch | Runtime / TTV | Y | Y | Y | Partial | Visible; TTV labeled informational. Runtime alarm fallback mismatch. | HIGH |
| Watch | Stopwatch start/stop/reset | Y | Y | Y | Partial | Haptics present; reset is not long-press guarded. | MED |
| Watch | Average/max depth/temp | Y | Y | Y | Partial | Live/detail mostly unit-aware; log/Compass gaps. | HIGH |
| Watch | Ascent-rate indicator/warning | Y | Y | Y | Y | Inline banner, red state, repeated haptic; no modal observed. | LOW |
| Watch | BUSSOLA / bearing | Y | Y | Y | Partial | SET/CLEAR toast and haptic; in-dive depth metric fixed m. | MED |
| Watch | Dive log / detail | Y | Y | Y | Partial | Reachable, delete confirmation, CSV share; list max depth fixed m. | HIGH |
| Watch | GPS start/end | Y | Y | Y | Y | Surface best-effort capture, fallback/no-fix labels. | LOW |
| Watch | Export CSV | Y | Y | Y | Y | Subsurface CSV, failure message, share link. | LOW |
| Watch | Image viewer | Y | Conditional | Y | Partial | Visible only if images exist; empty state hidden because tab omitted when empty. | LOW |
| Watch | Settings / alarms | Y | Y | Y | Partial | Crown steppers present; runtime fallback in DiveManager still 60. | HIGH |
| Watch | Units | Y | Y | Partial | Partial | Persisted/synced, but not consistently applied everywhere. | HIGH |
| Watch | Haptics | Y | Y | Y | Y | Gated by setting; confirmation/warning semantics mostly coherent. | LOW |
| Watch | Tones/sounds | N | N | N | N | UI states tones not used underwater; no audio tone implementation found. | LOW |
| iOS | Logbook | Y | Y | Y | Partial | List card max depth string fixed as m; detail is unit-aware. | MED |
| iOS | Dive detail / charts | Y | Y | Y | Y | Metrics, chart, GPS, manual edit, CSV export present. | LOW |
| iOS | Planner / result | Y | Y | Y | Partial | Safety ack gate works; many planner values fixed metric/bar by design; visible PDF-ready copy. | MED |
| iOS | Gas configuration | Y | Y | Y | Y | Planner and equipment gas fields present; no gas calc added to checklist. | LOW |
| iOS | Buhlmann/analysis display | Y | Y | Y | Partial | Planner result/curve areas present; simulator/device render not verified. | MED |
| iOS | Export / import CSV | Y | Y | Y | Y | Subsurface CSV with manual metadata; import validation and share UX present. | LOW |
| iOS | Watch sync | Y | Y | Partial | Partial | WC, signed ack, tombstones, conflicts, photo transfer; device not verified. | MED |
| iOS | Settings / More | Y | Y | Y | Partial | Units/cloud/legal/sync present; stale units footer strings remain. | MED |
| iOS | Equipment checklist | Y | Y | Y | Y | Add/remove/toggle and gas/pressure text fields. | LOW |
| iOS | Manual dives | Y | Y | Y | Y | Add/edit/delete, manual badge, profile samples, CSV fields. | LOW |
| iOS | Permissions | Y | Partial | Partial | Partial | Info.plist location/photos text exists; no complete guided permission flow verified. | MED |
| iOS | Safety disclaimer | Y | Y | Partial | Partial | Legal onboarding exists; launch disclaimer persists by revision, not every launch. | HIGH |

## D. Navigation Map

Apple Watch flows: Legal onboarding -> Mode selection when multiple stable modes exist -> Live Dive -> BUSSOLA -> Settings -> User Images only when images exist -> Dive Log -> Dive Detail -> Export. During active dive, ContentView redirects unsafe tabs back to Live and allows only Live, BUSSOLA and Dive Log.

iOS flows: Planner first tab -> Logbook -> Dive Detail -> Manual editor/export; Analysis -> metrics/charts/CSV; Equipment -> editable profile/checklist; More -> preferences, Watch sync/photo transfer, cloud, reviewer demo, export/legal. No dead-end found in static review, but UI render/device navigation was not simulator-tested.

- Dead ends: none proven statically; Watch image tab is intentionally hidden when there are no images.

- Unreachable MAIN screens: none required by project.yml. Experimental screens remain in source tree but excluded.

## E. UI Consistency Report

| Screen | Issue | Severity | Recommended fix |
| --- | --- | --- | --- |
| Watch Live Dive | Matches premium black/neon reference in source: black background, neon panels, large metrics, inline alarms. Actual render not verified. | LOW | Run simulator/device visual QA on Apple Watch Ultra sizes. |
| Watch Compass | Uses same dark/neon style, but in-dive depth metric is hardcoded to m and may create mixed units. | MED | Use WatchDepthFormatting for Compass in-dive metric. |
| Watch Log list | Dark/neon list style present; max depth is fixed m and violates unit consistency. | HIGH | Format list depth via WatchDepthFormatting. |
| iOS Companion | Dark marine/cyan theme and rounded cards present across tabs. Actual render not verified. | LOW | Run iPhone simulator screenshot QA. |
| iOS Planner | Visible future copy: PDF-ready briefing text may look placeholder-like in MAIN. | MED | Localize/soften to a real Share summary or remove from production UI. |
| iOS Logbook | Thumbnail cards are generated gradients/icons, not real photos; acceptable but less close to reference mock. | LOW | Optional: attach real dive/user photo thumbnails later. |

## F. Settings Report

| Setting | Watch | iOS | Persisted | Synced | Status |
| --- | --- | --- | --- | --- | --- |
| Units | Picker in Settings | Picker in More | Yes via AppStorage/UserDefaults | Yes via WatchConnectivity applicationContext | Partial: display gaps in Watch Compass/Log and iOS Logbook/Planner. |
| Alarms | AlarmSettingsView with Crown/touch steppers | Explained as Watch-local | Yes | No, documented local-only | Partial: runtime fallback bug still 60 min in DiveManager. |
| Ascent thresholds | AscentRateSettingsView | No direct iOS editor observed | Yes | No | Implemented on Watch. |
| Haptics | Toggle in Watch settings | N/A | Yes | No | Implemented and gated. |
| Tones/sounds | Copy says no underwater tones | No tone preference found | N/A | N/A | Not implemented; acceptable if product is haptic-only but user asked to audit tones. |
| Cloud/iCloud | Watch entitlements present | CloudSyncStore + More UI | Yes | KVS/iCloud | Partial: cloud conflict policy still needs device/account QA. |
| Export prefs | Status/copy only | CSV import/export surfaces | N/A | N/A | Export reachable; no user-selectable export preference beyond CSV. |
| Permissions | Info/status screens | Info.plist + More/legal copy | N/A | N/A | Partial guided permission UX. |

## G. Haptics / Tones Report

- Haptics: HapticService gates all patterns behind dirdiving_watch_haptics_enabled and uses success/notification/failure patterns for confirmation, notifications and warnings.

- Dive start/end use criticalConfirm, which currently maps to confirm; acceptable but not a stronger repeated pattern.

- Ascent warning uses failure plus repeated failure at configured interval while banner remains active.

- Depth limit uses DepthLimitHapticCoordinator and warning feedback; visible inline warnings retained.

- Stopwatch start/stop/reset use confirm.

- GPS confirmation uses confirm.

- Tones/sounds: no actual audio/notification tone system found; settings copy explicitly says underwater feedback is haptic/visual.

## H. Hardware Controls Report

| Control | Implemented mapping | Risk / gap | Recommendation |
| --- | --- | --- | --- |
| Digital Crown | Vertical TabView page navigation and digitalCrownRotation on alarm/ascent numeric settings. | Actual Crown QA not run. | Device/simulator QA. |
| Touch | All critical settings retain touch plus/minus or buttons. | Good fallback. | Keep touch alternatives. |
| Side Button | Help copy says app cannot override it directly. | Truthful; no fake mapping found. | Keep wording. |
| Action Button / Shortcuts | AppShortcutsProvider exposes stopwatch, manual dive, bearing and acknowledge actions. | Cannot verify Shortcuts catalog on Windows. | Validate on Watch Ultra/watchOS. |
| Long press | STOP/RESET not generally long-press guarded. | Accidental reset/stop risk, but changing lifecycle may affect emergency UX. | Treat as UX follow-up, not audit-time fix. |

## I. Sync Report

Watch to iPhone: WatchSyncService queues sessions, signs payloads, uses direct message when reachable and transferUserInfo fallback, tracks pending/sent/ack/failed counts and writes pending queue to protected file. iOS validates payloads, stores conflicts, replies with signed ack where possible.

iPhone to Watch: iOS can push sessions, tombstones, unit preferences and compressed photos. Watch receives sessions, units, tombstones and photo files. Duplicate prevention exists through imported/pushed ID sets.

- Critical limitation: all WC flows are statically present but not device-verified in this Windows environment.

- Known gap: per-session delivery status remains aggregate/status-copy oriented, not a detailed per-dive queue UI.

## J. Export Report

- Subsurface CSV export is reachable on Watch log/detail and iOS detail/analysis surfaces.

- iOS CSV export includes manual metadata fields: is_manual, equipment, entry_pressure, exit_pressure and deco_notes.

- CSV internal business format remains metric (depth_m, temperature_c), which is correct for Subsurface; UI/export display expectations should say this clearly.

- GPX/KML export not found in MAIN; report as missing/planned only if product requires it.

- Export failure messages exist; actual share sheet could not be simulator-tested.

## K. Safety Report

| Safety area | Status | Severity | Notes |
| --- | --- | --- | --- |
| Certified-computer claims | Mostly safe | LOW | Legal onboarding and TTV/planner notes say informational/non-certified. |
| Launch disclaimer every launch | Not compliant | HIGH | CompanionDisclaimerAcceptance persists revision, so it re-shows only on revision changes, not every launch. |
| Ascent warning UX | Good | LOW | Inline red banner; no modal/full-screen alarm found. |
| Depth alarm/default | Partial | HIGH | Depth default 40 m ok; runtime default mismatch could delay time warning if user never opens settings. |
| GPS limitations | Mostly clear | LOW | Surface/fallback/no-fix labels and documentation present. |
| Depth entitlement/device safety | Unverified | HIGH | Entitlements configured, but Apple Developer entitlement and real Watch Ultra depth data QA are not proven here. |

## L. Error / Empty State Report

- No dives: Watch and iOS empty states present.

- No GPS/no fix: Watch detail and live banners show unavailable/fallback states.

- No depth automation: Watch offers manual lifecycle with warning text.

- No compass/permission denied: Compass status banner uses warning text.

- No iPhone/Watch connection: sync state rows and retry/reset pairing UI present.

- Export fail: messages exist; share sheet not verified.

- Storage/cloud decode failure: cloud decode error appears in More; Watch loadErrorMessage appears in log list.

- Battery low: Watch alarm setting exists; actual haptic/device behavior not tested.

## M. Bugs To Fix

| Title | Platform | File/screen | Severity | User impact | Recommended fix | Estimated impact |
| --- | --- | --- | --- | --- | --- | --- |
| Disclaimer not every launch | Both | Utils/CompanionDisclaimerAcceptance.swift; iOSApp/Utils/CompanionDisclaimerAcceptance.swift | HIGH | User/legal requirement says every app launch; current revision storage suppresses repeat display. | Make requiresDisplay launch-session based and do not persist OK for this lightweight launch sheet. | UI-only / small functional fix |
| Runtime alarm default mismatch | Watch | Services/DiveManager.swift: runtimeAlarmThresholdMinutes | HIGH | If setting key absent, monitoring uses 60 min even though UI/default docs say 30 min. | Use WatchAlarmDefaults.runtimeThresholdMinutes in DiveManager fallback. | small functional fix |
| Watch Log list ignores selected units | Watch | Views/DiveLogListView.swift | HIGH | Imperial users see m in Watch log list. | Use WatchDepthFormatting for session.maxDepthMeters. | UI-only |
| Watch Compass in-dive depth ignores selected units | Watch | Views/CompassView.swift | MEDIUM | Compass page can mix m with ft preference during active dive. | Use DIRUnitPreference + WatchDepthFormatting. | UI-only |
| iOS Logbook card ignores selected units | iOS | iOSApp/Views/LogbookView.swift and Localizable logbook.card.max_depth | MEDIUM | Imperial users see m in list even if detail/charts convert. | Read iOS unit preference and pass Formatters.depth text. | UI-only |
| Planner remains metric-only while global units imply shared units | iOS | iOSApp/Views/PlannerView.swift | MEDIUM | Planner fields/results use m/C/bar fixed; may be intentional internal-planner choice but conflicts with global unit promise. | Either apply presentation conversion or explicitly label planner as metric-only. | small functional fix if conversion; UI-only if copy |
| Stale unit footer copy | iOS | iOSApp/Resources/*.lproj/Localizable.strings units.ios.footer | MEDIUM | Strings say imperial not implemented and Watch metric-only, contradicting current picker/sync. | Update or remove stale localized copy. | UI-only |
| Launch disclaimer blocked by onboarding path | Both | App entry + ContentView overlays | MEDIUM | If legal onboarding is required, launch companion sheet appears only after acceptance/content, not necessarily immediately every launch. | Decide whether legal onboarding satisfies launch requirement or show companion notice after onboarding every launch. | UI-only |
| Action Button intents not device-verified | Watch | Services/ActionButtonIntents.swift | MEDIUM | Catalog cannot be verified on this host. | Run Shortcuts/Action Button QA on watchOS. | validation |
| No audio/tone implementation | Both | Settings/help surfaces | LOW | User asked to audit tones; app appears intentionally haptic/visual. | Document as intentional or add gated tone preference outside underwater use. | UI-only/small |
| Visible future copy in Planner | iOS | iOSApp/Views/PlannerView.swift: PDF-ready text | LOW | May look placeholder-like in MAIN. | Replace with real share/export label or remove. | UI-only |
| Ascent alarm reference image missing by name | Docs/Watch | Docs/WATCH_MAIN_UX_CONVENTIONS.md references ascent_alarm.png | LOW | ReferenceUI folder contains Watch_LIVE and iOS reference, not ascent_alarm.png. | Update doc reference or add reference image. | docs-only |

## N. Priority Roadmap

### 1. Must fix before compile/use

- Run xcodegen generate and both target builds on macOS/Xcode.

- Fix runtime alarm default mismatch in DiveManager.

- Fix disclaimer every-launch behavior if it remains a product/legal requirement.

- Fix unit display gaps in Watch Log/Compass and iOS Logbook.

### 2. Must fix before TestFlight

- Device-test Watch Ultra depth/submersion entitlement, ascent warning, depth alarm and haptics.

- Verify WatchConnectivity sync, signed ack, tombstones, units sync and photo transfer on paired devices.

- Run simulator screenshots for Watch/iOS UI reference alignment and text clipping.

- Clean stale/future-facing user copy in planner and units settings.

### 3. Must fix before App Store

- Confirm privacy policy, entitlement approval, App Review notes and non-certified dive-computer wording.

- Complete i18n review for English/Italian strings and hardcoded Italian in MAIN screens.

- Decide and document tone/sound policy; avoid implying unavailable audio alerts.

- Provide real TestFlight evidence for depth sensor/device behavior.

### 4. Can fix post-release

- Per-session sync delivery UI instead of aggregate counters.

- Optional real log thumbnails/photo attachment UX.

- Optional GPX/KML export if product roadmap requires it.

- Long-press guard for reset/stop after emergency UX review.

## O. Final Verdict

| Question | Verdict | Why |
| --- | --- | --- |
| Ready to compile? | Unknown / not proven | Toolchain unavailable on Windows; project.yml/assets look coherent but xcodegen/xcodebuild could not run. |
| Ready for internal test? | Conditionally, after macOS build | Static MAIN surface is broad enough for internal QA, but build/device validation is mandatory first. |
| Ready for average user? | No | Every-launch disclaimer, unit consistency, default alarm mismatch and device validation block average-user readiness. |
| Ready for TestFlight? | No | Needs macOS builds, Watch Ultra device QA, sync QA and safety/copy fixes. |
| Ready for App Store? | No | Needs entitlement proof, legal/disclaimer compliance, i18n cleanup, device evidence and validated builds. |
| What blocks 100% readiness? | Build validation + safety/UX bugs | The blockers are narrow and fixable; no evidence of required business-logic rewrite or experimental dependency. |

## Validation Log

- git status --short --branch: main...origin/main, clean before report generation.

- git rev-parse HEAD and origin/main: both 91f3c8dd303a376dd65ed2af70bf1171682ca2e8.

- xcodegen generate: failed because xcodegen command is not installed/available on this Windows host.

- Watch xcodebuild: failed because xcodebuild command is not installed/available on this Windows host.

- iOS xcodebuild: failed because xcodebuild command is not installed/available on this Windows host.

- Asset catalog filename check: Watch and iOS AppIcon Contents.json references all existing PNG files.

- Reference assets present: Docs/ReferenceUI/Watch_LIVE_reference.png, Docs/ReferenceUI/iOS_Companion_reference.png, Docs/ReferenceIcon assets.
