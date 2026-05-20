# DIR DIVING — MAIN UX / Interaction / Feature Accessibility Audit

**Date:** 2026-05-19 · **Revision:** 2026-05-20 (stakeholder acceptances + 1 s ascent warning cap in code)

> **Aggiornamento prodotto 2026-05-20 (post-audit):** su `main` l'avviso risalita è implementato come **banner rosso inline non bloccante** (`AscentWarningBannerView`), non più takeover full-screen 1 s. Policy corrente: [`WATCH_MAIN_UX_CONVENTIONS.md`](WATCH_MAIN_UX_CONVENTIONS.md) e [`ASCENT_ALARM_IMPLEMENTATION_REPORT_20260520.md`](ASCENT_ALARM_IMPLEMENTATION_REPORT_20260520.md). Il corpo di questo audit resta valido per reachability/sync/GPS; le sezioni che citano full-screen 1 s sono **storiche** rispetto al codice attuale.
**Type:** Pre-modification audit (no code changes performed during this pass)
**Branches in scope:**

- Apple Watch MAIN: `main` (commit `8b20113`)
- iOS Companion MAIN: `main-iOS` (commit `929182a`)

**Branches explicitly out of scope:**

- `experimental`, `experimental-apnea`, `experimental-snorkeling`
- Any file excluded from MAIN targets in `project.yml`
  (`ApneaView.swift`, `SnorkelingView.swift`, `BuddyAssistView.swift`,
  `ExperimentalConceptsView.swift`, `ExplorationStore.swift`,
  `BuddyAssistService.swift`, `BuddyAssistPeripheralService.swift`,
  `BuddyPairingKeyAgreement.swift`, `SecureBuddyStore.swift`,
  `ExperimentalFeatures.swift`, `ExplorationModels.swift`,
  `BuddyAssistMessage.swift`, `BuddyPairingHandshake.swift`, plus their
  iOS counterparts `ExplorationModels.swift`, `BuddyExperimentalModels.swift`,
  `ExplorationPlanningStore.swift`, `BuddyExperimentalStore.swift`,
  `ExplorationCenterView.swift`, `ExperimentalFutureConceptsView.swift`,
  `BuddyExperimentalView.swift`).

**Method:**

- Static recon of `App/`, `Views/`, `Services/`, `Models/`, `Utils/` for Watch MAIN.
- Static recon of `iOSApp/App/`, `iOSApp/Views/`, `iOSApp/Services/`,
  `iOSApp/Models/`, `iOSApp/Utils/` for iOS MAIN (`.worktrees/main-iOS`).
- Cross-referenced shared keys, tombstones, sync handshakes between platforms.
- Cross-referenced `project.yml` to confirm target membership and excluded files.
- No runtime build (watchOS / iOS simulator runtimes are not installed on this
  machine). Findings below are based on source inspection; safety-critical
  findings are flagged so they can be re-verified on hardware.

### Stakeholder acceptances (2026-05-20)

The following items were raised in the initial audit but are **accepted for
the current release** and are no longer treated as UX blockers or mandatory
pre-release fixes:

| ID | Original severity | Decision |
|---|---|---|
| UX-H1 / SAF-1 | HIGH | **Accepted and implemented.** Full-screen ascent warning replaces the live dashboard for **1 s** per over-limit episode, then returns to depth + gauge while limits/haptics may continue. See `DiveLiveView.ascentWarningTakeoverSeconds`. |
| UX-H4 | HIGH | **Accepted for now.** `ModeSelectionView` as the first vertical page on cold launch is acceptable. Removed from blocker lists and from pre-release mandatory fixes. |

---

## 1. FEATURE INVENTORY

Legend: **Impl?** = present in source · **Reach?** = can the user actually open
it · **Complete?** = function actually works end-to-end · **Issue** = any
finding worth raising. Hidden / partial are sub-cases of Reach/Complete.

### 1.1 Apple Watch MAIN

| Feature | Impl? | Reach? | Complete? | Issue / Notes |
|---|---|---|---|---|
| Mode Selection screen (single "Diving" mode) | yes | yes (1st page on launch) | yes | **Accepted (2026-05-20):** first-page mode selector is OK for current release. One swipe to Live remains. |
| Dive Live dashboard (depth, TTV, runtime, gauge, stopwatch, controls) | yes | yes (2nd page) | yes | GPS confirmation still full-screen ~2.4 s. Ascent warning: **1 s** full-screen takeover, then live layout with gauge (2026-05-20). |
| Auto dive start / stop (CMWaterSubmersionManager) | yes | n/a (system) | partial | Dedicated dive-start / dive-end haptic missing: `confirm()` fires only when GPS confirmation appears, not on the submersion event itself. |
| Manual dive start (`startManualDive`) | yes | conditional | yes | Surfaced only when `isDepthAutomationAvailable == false` (sensor missing). Button "AVVIO MANUALE" appears in pre-dive panel. |
| Manual dive end (`endManualDive`) | yes | conditional | yes | Surfaced only while `isManualLifecycleActive` is true. Button "FINE MANUALE" appears under controls. |
| Stopwatch START / STOP / RESET | yes | yes | yes | Three large buttons, confirm haptic on start / reset, notify haptic on stop. No accessibility label/hint on the buttons themselves. |
| Ascent gauge (continuous, with limits) | yes | yes | yes | Hidden while full-screen ascent warning is shown; acceptable per product for brief takeover. |
| Ascent warning overlay | yes | yes | yes | Full-screen **1 s** per over-limit episode (`DiveLiveView`), then live UI + gauge. Not a release blocker. |
| Depth / temperature live readout | yes | yes | yes | Localized strings in code (Italian), no Localizable.strings extraction. |
| Compass + bearing set / clear | yes | yes (3rd page) | yes | "SET BEARING" confirmation is haptic-only; no visible toast or banner. "CLEAR" disabled state is grey-on-grey, weakly disambiguated. |
| GPS start / end registered overlay | yes | yes | yes | Full-screen replacement during ~2.4 s (`Task.sleep(2_400_000_000)`); hides depth + gauge (see UX-H2). |
| Dive log list | yes | yes (6th page) | yes | Ordered after UserImages in the tab stack. Pull-to-delete via context menu **plus** explicit "ELIMINA LOG" inside detail = two delete paths. |
| Dive detail (incl. GPS rows, summary cards, share, delete) | yes | yes (push from list) | yes | Back returns via system `dismiss()`. |
| CSV export Subsurface (single dive + latest from list) | yes | yes | yes | Local file write + ShareLink. Export-completion screen uses an iCloud upload icon → misleading (no iCloud upload happens). |
| ShareLink for exported CSV | yes | yes | yes | Appears under the export button after a successful write. Discoverability mostly OK because it follows the green CTA. |
| Watch settings screen (all controls) | yes | yes (4th page) | partial | Most rows are informational but use the same chrome as tappable rows; only the chevron distinguishes them (see UX-M8). |
| Ascent rate settings sub-screen | yes | yes (push from Settings) | yes | Persistent via `AscentRateSettingsStore`. |
| Alarm settings sub-screen | yes | yes (push from Settings) | yes | Soglie persistenti. Bandiera "non sincronizzate con iPhone" presente in UI. |
| Language picker (System / Italiano / English) | yes | yes | yes | Persisted via `@AppStorage(DIRAppLanguage.storageKey)`. |
| Unit preference picker | yes | yes | partial | Single-option picker (only "m"). Not useful as a picker — should be an info pill until imperial is wired. |
| Haptics on/off toggle | yes | yes | yes | Persists `dirdiving_watch_haptics_enabled`. |
| Haptics-off badge (pre-dive warning) | yes | partial | partial | Rendered only inside `activeDiveContent`, NOT in `preDiveWaitingContent`. Pre-dive user has no visible reminder that haptics are disabled. |
| Sync companion status rows (activation, pending, sent, ack, failed) | yes | yes | yes | Useful telemetry, but the underlying activation state is just rendered as the localized string from system; cf. UX-M9 on the iOS side which has been hardened. |
| Sync retry button | yes | conditional | yes | Shown only when pending > 0 OR not activated. Has a confirm haptic on tap. |
| Sync queue clear (failed queue) | yes | conditional | yes | Confirmation dialog, persists state in protected file (F9 hardening applied). |
| Watch shortcut help page (`WatchShortcutHelpView`) | yes | yes (push from Settings) | yes | Explains that the side button cannot be intercepted by an arbitrary app. |
| App Intents — `ToggleStopwatchIntent`, `ResetStopwatchIntent` | yes | yes (Shortcuts / Action Button) | yes | Only stopwatch intents exist. **No** intents for manual dive start/end, bearing set/clear, alarm acknowledge. |
| InfoView (build / device / battery / depth diagnostics / sync) | yes | yes (push from Settings) | yes | Battery monitoring enabled on appear. |
| UserImages tab | yes | yes (5th page) | partial | When the bundle ships no images, tab still occupies the page stack and renders the "NESSUNA IMMAGINE" empty state. Page count cost is high. |
| Watch → iPhone log sync (HMAC envelope, signed ack) | yes | n/a | yes | F11 signed-ack path active; legacy `status == acknowledged` is tolerated for backward compatibility. |
| iPhone → Watch log push | partial | n/a | **NO** | `WatchSyncService` does NOT implement `didReceiveMessage` / `didReceiveUserInfo`; only `didReceiveApplicationContext` (used for the peer secret). Any payload pushed from iOS is silently dropped by the Watch. |
| Tombstone (deleted sessions) consumer on Watch | yes | n/a | **broken cross-device** | Watch uses hardcoded key `dirdiving_watch_deleted_session_ids`; iOS uses `dirdiving_shared_deleted_session_ids` (`WatchSyncKeys`). The two keys never meet → delete on iOS is not reflected on Watch (and vice-versa via cloud KVS). |
| Units preference consumer on Watch | partial | n/a | **NO** | iOS pushes `units` via `updateApplicationContext`. Grepping the Watch tree finds zero references to `unitsPreferenceKey` or `"units"` outside of the iOS worktree. Broadcast is to a deaf endpoint. |
| Session recovery (pending sync queue persisted) | yes | n/a | yes | `dirdiving_watch_pending_sync_sessions.json` with `.completeFileProtection` (F9). Legacy UserDefaults key migrated once. |
| iCloud KVS backup (Watch dive logs) | yes | n/a | yes (within Watch) | Watch writes to `dirdiving_watch_dive_sessions`; iOS writes to `dirdiving_ios_dive_sessions`. Cloud channels are intentionally separate (see Sync section). |
| Onboarding / first-launch UX | absent | — | — | No dedicated onboarding; first tab is Mode Selection (**accepted**). |
| Locale-aware UI strings | partial | n/a | partial | Most labels are inline Italian literals. No `Localizable.strings` file under `Resources/`. |

### 1.2 iOS MAIN

| Feature | Impl? | Reach? | Complete? | Issue / Notes |
|---|---|---|---|---|
| Logbook tab (search, group-by-month) | yes | yes | yes | Demo logbook toggle in Settings → reviewer-friendly. |
| Logbook empty state | yes | yes | yes | Plain empty card; no "Open Watch sync" / "Import CSV" shortcuts from logbook itself (only via Settings or Explore). |
| Per-row delete with confirmation | yes | yes | yes | Demo dives correctly hide their trash button. Haptic confirmed on tap. |
| Dive detail (tabs: RIEPILOGO / GRAFICI / DETTAGLI) | yes | yes (push from Logbook) | yes | Back chevron in custom header; navigation bar hidden. |
| Dive detail TTV semantics | yes | yes | yes | TTV labeled as derived (a11y label + muted footnote present). |
| Dive detail CSV export | yes | yes | yes | Local URL + ShareLink. |
| Explore (Route Review based on GPS entry/exit) | yes | yes | yes | Empty state surfaces three shortcuts: Sync Watch / Sync iCloud / Import CSV. |
| Analysis (charts + aggregates) | yes | yes | yes | Aggregates max depth, runtime, avg temp, SAC, route count. Honest empty state. |
| Planner (simple / advanced / technical) | yes | yes | partial | Default mode is `.advanced`. Validation enforces sane gas mixes. Disabled / preview modes are still tappable in the picker. |
| Planner safety acknowledgement | yes | yes | yes | `safetyAcknowledged` is non-persistent → resets per launch (SAF-9 OK). |
| Planner result view (PIANO / CURVA BUHLMANN / GRAFICI) | yes | yes | yes | Has explicit Back affordance + navigationTitle. |
| Equipment / gear (editable, checklist, reset) | yes | yes | yes | Reset has destructive confirmation + haptic + savedFeedback. |
| Settings → language picker | yes | yes | yes | Persisted, locale applied. |
| Settings → unit preference picker (Metric / Imperial) | yes | yes | yes | Persisted; broadcast to Watch via `updateApplicationContext`. (Watch ignores the broadcast — see iOS→Watch finding.) |
| Settings → onboarding toggle | yes | yes | yes | Shows operative notes about depth entitlement, GPS, sync, export. |
| Settings → notifications permission request | yes | yes | yes | UNUserNotificationCenter prompt + deep-link to iOS Settings. |
| Settings → Watch sync card | yes | yes | yes | Localized activation label, peer trust state, retry, reset trust (re-pair). |
| Settings → Cloud backup card | yes | yes | yes | iCloud availability, sync-now action. |
| Settings → Reviewer demo logbook toggle | yes | yes | yes | Adds 5 demo dives for App Store review. |
| Settings → Export card | yes | yes | partial | Only Subsurface CSV is wired; GPX / UDDF are honest "Planned". |
| iPhone → Watch session push (HMAC envelope, peer-gated) | yes | n/a | partial-by-design | Implemented end-to-end on iOS side. On the Watch the consumer is missing (see Watch finding). |
| Watch → iPhone session ingest (HMAC verify, conflict store) | yes | n/a | yes | `importSessionPayload` parses, verifies tombstone, stores conflict on mismatch. |
| Conflict resolution UI | yes | yes (Settings/Watch card) | yes | "Mantieni locale" / "Usa Watch" buttons with haptics. |
| Units preference broadcast iPhone → Watch | yes | n/a | partial | iOS push works; Watch consumer absent (see Watch finding). |
| CSV import (Subsurface) | yes | yes (Logbook / Explore / Analysis) | yes | SAF-4 bounds applied (≤200 m, ≤480 min, -2…40 °C); per-row error report present. |
| Reset trust / re-pair Watch | yes | yes | yes | Destructive confirmation. |
| iCloud KVS persistence (logs / planner / equipment) | yes | n/a | yes | `cloudSyncDidChangeExternally` triggers reload. |
| Tombstone consumer on iOS | yes | n/a | yes (iOS-local) | Uses unified `WatchSyncKeys.deletedSessionIDsKey`. |
| Haptic feedback (`HapticFeedback.swift`) on confirm/destructive/tap/notify/success/error | yes | n/a | yes | Wired into Settings, Logbook, Planner, Equipment, etc. |
| Onboarding card on first launch | yes | yes | yes | Surfaced inside Settings → ONBOARDING. Not a full-screen onboarding flow. |
| Localizable strings | partial | n/a | partial | UI labels mostly inline Italian; `DIRIOSAppLanguage` only switches the locale at the `.environment(\.locale, …)` level. No `Localizable.strings` extraction. |

---

## 2. NAVIGATION MAP

### 2.1 Apple Watch MAIN

Root: `NavigationStack { ContentView() }`
Container: `TabView(selection: $navigation.selectedPage) { … }.tabViewStyle(.verticalPage)`

Vertical paging order (top → bottom, swipe vertically):

1. `ModeSelectionView` (tag `.modeSelection`) — single-mode selector.
2. `DiveLiveView` (tag `.live`) — depth / TTV / runtime / gauge / stopwatch.
3. `CompassView` (tag `.compass`).
4. `SettingsView` (tag `.settings`).
5. `UserImagesView` (tag `.userImages`).
6. `DiveLogListView` (tag `.diveLog`).

Stack pushes:

- From `SettingsView` → `AscentRateSettingsView`, `AlarmSettingsView`,
  `WatchShortcutHelpView`, `InfoView`.
- From `DiveLogListView` → `DiveDetailView`, then `ExportView`
  (after export success), and a context-menu delete confirmation.
- From `DiveDetailView` → `ExportView`, plus delete confirmation dialog.

Modal flows:

- Confirmation dialogs: clear sync queue (Settings), delete log
  (DiveLogList context menu, DiveDetail explicit button).
- `gpsConfirmation` ephemeral state inside `DiveManager` replaces the
  active dive layout for ~2.4 s.
- `ascentStatus.isOverLimit` triggers a **1 s** full-screen `AscentWarningView`,
  then the live layout returns with depth + ascent gauge (2026-05-20).

Entry points: only the system app launcher / WC handoff. No deep
links / URL handler.

Dead ends and orphans found: **none catastrophic** — every screen has a
return path through tab swipe or `dismiss()`. However:

- Mode Selection on launch is **accepted** (not counted as friction for
  this release).
- `UserImagesView` is reachable but offers no value if the bundle does
  not ship images. The whole tab is then a glorified empty-state.
- GPS confirmation views are full-screen takeovers that block depth/gauge
  visibility for ~2.4 s (still flagged — see UX-H2 / SAF-2).

Missing routes:

- No shortcut from `DiveLiveView` to `SettingsView` (must swipe two
  pages); not blocking but slow under stress.
- No shortcut from any tab to "open last dive detail" / "share latest
  export" (must navigate via DiveLog).
- No "in app" entry point to the Watch shortcut help except via
  Settings → "Azione / Comandi". This is fine but discovery is low.

### 2.2 iOS MAIN

Root: `WindowGroup { ContentView() }`
Container: `TabView(selection: $navigation.selectedTab) { … }`.

Tab order: Logbook → Explore → Analysis → Planner → Gear → Settings.
Each tab wraps its own `NavigationStack { … }`.

Stack pushes per tab:

- Logbook → `DiveDetailView` (per row), file importer presented inline.
- Explore → no destinations (empty-state buttons trigger sync /
  importer / tab switches).
- Analysis → file importer (CSV) only.
- Planner → `PlanResultView` (via NavigationLink from PlannerView).
- Gear → reset confirmation only.
- Settings → none (all cards inline).

Modal flows:

- File importers: Logbook, Explore, Analysis (CSV).
- Confirmation dialogs: delete dive (Logbook), reset gear (Gear),
  reset Watch trust / re-pair (Settings).
- System sheets: ShareLink from DiveDetail.
- Deep-link out: `UIApplication.openSettingsURLString` from Settings.

Entry points: app launcher. No URL scheme / Universal Links.

Dead ends and orphans found: **none observable**. Empty states all
either offer a shortcut (Explore) or are clearly informational
(Logbook empty card, Analysis empty card).

Missing routes:

- No way to reach `PlanResultView` from outside Planner (no shortcut
  from Analysis or Logbook). Probably acceptable.
- No deep-link from a notification (no notification scheduling logic
  beyond permission request).
- Logbook empty state does not offer the same shortcuts that Explore
  empty state does (Sync Watch / Sync iCloud / Import CSV). Minor UX
  inconsistency.

---

## 3. SETTINGS REPORT

### 3.1 Apple Watch MAIN

Persisted via `@AppStorage` / `UserDefaults`:

| Key | Where set | Where read | Persisted? | Synced to iPhone? |
|---|---|---|---|---|
| `dirdiving_watch_haptics_enabled` | SettingsView toggle | HapticService, DiveLiveView badge | yes | no |
| `dirdiving_watch_units` | SettingsView picker (single option) | nowhere consequential | yes | no (and read-only "metric" today) |
| `DIRAppLanguage.storageKey` | SettingsView segmented picker | App locale | yes | no |
| `dirdiving_watch_alarm_ascent_enabled` | AlarmSettingsView toggle | DiveManager.evaluateAscentRate | yes (default = true) | no |
| `dirdiving_watch_alarm_depth_enabled` | AlarmSettingsView toggle | DiveManager.evaluateDepthAlarm | yes | no |
| `dirdiving_watch_alarm_runtime_enabled` | AlarmSettingsView toggle | DiveManager.evaluateRuntimeAlarms | yes | no |
| `dirdiving_watch_alarm_battery_enabled` | AlarmSettingsView toggle | DiveManager.evaluateRuntimeAlarms | yes (default = true) | no |
| `dirdiving_watch_alarm_depth_threshold_m` | AlarmSettingsView stepper | DiveManager.depthAlarmThresholdMeters | yes | no |
| `dirdiving_watch_alarm_runtime_threshold_min` | AlarmSettingsView stepper | DiveManager.runtimeAlarmThresholdMinutes | yes | no |
| `dirdiving_watch_alarm_battery_threshold_pct` | AlarmSettingsView stepper | DiveManager.batteryAlarmThresholdPercent | yes | no |
| `AscentRateSettingsStore.limits` (deep/mid/shallow/surface/fallback) | AscentRateSettingsView steppers / RESET STD | DiveManager.updateAscentRate | yes (via store) | no |

Inaccessible / partially accessible:

- Single-option "Unità" picker is technically a control but offers no
  user choice. Should be an informational pill.
- All sync telemetry rows (`Sync companion`, `Sync pending`,
  `Sync sent`, `Sync acknowledged`, `Errori sync`) look identical to
  tappable rows but are non-interactive (UX-M8).

Missing settings UI:

- No "Allarmi avanzati" → "Acknowledge / silenzia banner allarme"
  (banner has no tap-to-dismiss).
- No "Sync settings cross-device" panel — only export side is
  exposed via informational copy.
- No way to clear / reset persistent IDs of imported sessions
  beyond "Cancella coda fallita" (works only on outbound queue).

Not persisted:

- `gpsConfirmation`, `redWarningBlink`, `alarmWarningMessage`,
  `lastErrorMessage` are all in-memory (expected).

### 3.2 iOS MAIN

Persisted via `@AppStorage` / `UserDefaults` / iCloud KVS via `CloudSyncStore`:

| Key | Where set | Where read | Persisted? | Synced (Watch / Cloud)? |
|---|---|---|---|---|
| `dirdiving_ios_units` | MoreView segmented picker | every view via `IOSUnitPreference` | yes | broadcast to Watch (deaf consumer), cloud no |
| `dirdiving_ios_export_format` | MoreView locked preference | informational | yes | no |
| `dirdiving_ios_show_onboarding` | MoreView toggle | MoreView onboarding card | yes | no |
| `DIRIOSAppLanguage.storageKey` | MoreView segmented picker | App locale | yes | no |
| `DiveLogStore.includeDemoLogbookKey` | MoreView reviewer toggle | DiveLogStore demo seeding | yes | no |
| `dirdiving_ios_dive_sessions` | DiveLogStore | DiveLogStore + CloudSyncStore | yes | iCloud yes |
| `WatchSyncKeys.deletedSessionIDsKey` (`dirdiving_shared_deleted_session_ids`) | DiveLogStore + migrations | DiveLogStore + WatchSync | yes | shared with cloud KVS; **NOT shared with Watch** because Watch uses a different key (see Sync section) |
| `dirdiving_ios_pending_watch_outbound_sessions` | WatchSyncService | WatchSyncService | yes (UserDefaults) | n/a |
| `dirdiving_ios_watch_sync_conflicts` | WatchSyncService | WatchSyncService | yes (UserDefaults) | n/a |
| `dirdiving_ios_planner_state` | PlannerStore | PlannerStore (loaded from CloudSyncStore) | yes (cloud KVS) | yes (cloud) |
| `dirdiving_ios_equipment_profile` (via EquipmentStore) | EquipmentView | EquipmentStore (cloud KVS) | yes | yes (cloud) |

Inaccessible / partially accessible:

- "Settings Watch" → "Solo unità · Planned per allarmi" → settings cross-sync
  for alarms is explicitly TODO (honest copy).
- "Delivery per log" row reads "TODO: stato per-sessione planned" →
  honest but feature missing.

Missing settings UI:

- No iOS-side mirror for Watch alarm thresholds (they are local to Watch).
- No iOS toggle for "enable haptics in iOS UI" (haptics fire
  unconditionally via `HapticFeedback`).
- No persistent iOS-side privacy / share consent toggle.

Not persisted:

- `notificationStatus` is reloaded each appearance from
  `UNUserNotificationCenter` — correct.

### 3.3 Shared / cross-device settings

| Setting | Source of truth | Cross-device behaviour |
|---|---|---|
| Units | iOS `dirdiving_ios_units` | Broadcast via `WatchSyncKeys.unitsPreferenceKey = "units"` in `updateApplicationContext`. **Watch never reads it.** Net effect: iOS persists locally, Watch stays metric. |
| Language | each device has its own `@AppStorage` | No cross-sync. Acceptable. |
| Tombstones (deleted sessions) | iOS `dirdiving_shared_deleted_session_ids`, Watch `dirdiving_watch_deleted_session_ids` | Disjoint keys → **delete on one side does not tombstone the other side**. (See UX-C2 in section 5.) |
| Logs cloud KVS | iOS `dirdiving_ios_dive_sessions`, Watch `dirdiving_watch_dive_sessions` | Disjoint keys → no cloud-mediated cross-device merge. Logs travel exclusively via WatchConnectivity Watch → iOS. |
| Alarm thresholds | Watch-only `UserDefaults` | Not propagated to iOS (honest TODO). |
| Haptics on/off | Watch `dirdiving_watch_haptics_enabled` / iOS unmanaged | Not propagated. |
| Pairing trust (peer secret) | both sides via `WatchSyncAuth` | Bidirectional in principle; iOS re-publishes via `publishSharedSecretIfNeeded`. Bidirectional handshake is implemented. |

---

## 4. HARDWARE INTERACTION REPORT

### 4.1 Apple Watch MAIN

Digital Crown:

- `TabView(.verticalPage)` → Crown rotates through the 6 vertical pages. No
  custom `digitalCrownRotation` modifiers anywhere in MAIN sources.
- Inside `ScrollView`s (Settings, AlarmSettings, AscentRateSettings,
  DiveLogList, DiveDetail, InfoView, UserImagesView, ExportView) the
  Crown drives scroll. No conflict observed.

Side button: not configurable from inside the app on watchOS. The
"Azione / Comandi" help page (`WatchShortcutHelpView`) explicitly
states: "DIR DIVING non puo intercettare direttamente il tasto laterale
o una pressione lunga arbitraria." This is honest. Action Button (on
Ultra) can target App Intents (see below).

Long press: none implemented (also acknowledged in the help page).

Tap gestures:

- All standard `Button` / `NavigationLink` / `Toggle` controls.
- `UserImagesView` uses `onTapGesture` on a row to push the detail
  inline (state-based, not stack-based). Recoverable via the bottom
  "SCHERMI" button.

Confirmation states: present where destructive (delete, clear queue).

Haptic events (Watch):

- `HapticService.confirm()` (`.success`) — stopwatch start, stopwatch
  reset, GPS start/end confirmation overlay appearing, settings retry
  taps, conflict-dialog cancel, compass SET BEARING.
- `HapticService.notify()` (`.notification`) — stopwatch stop, dive
  detail delete tap, log-list delete tap, sync retry tap, clear queue
  destructive, settings export errors, compass CLEAR.
- `HapticService.warnIfNeeded()` (`.failure`, 2 s cooldown) — ascent
  over limit, depth/runtime/battery alarms.
- `buddyMessageReceived` / `buddyNearPulseIfNeeded` /
  `buddyDistantPulseIfNeeded` — present in code but **only buddy code
  paths call them**, and Buddy is experimental (excluded from MAIN).
  Their presence in HapticService is harmless dead code from the
  shared service; not reachable in MAIN UX.

Missing hardware interactions on Watch:

- No dedicated **dive start / dive end haptic** at the
  CMWaterSubmersionManager state-transition site. The confirm haptic
  fires when GPS confirmation appears — which can be up to ~6 s later
  if a fix attempt is still in flight. Under heavy task pressure
  haptic timing can drift from the actual submersion event.
- No haptic on **alarm acknowledged** (banner has no acknowledge
  affordance).
- No haptic on **manual dive start / end** path (no call to
  `HapticService.confirm()` inside `startManualDive` /
  `endManualDive`).
- No App Intent for **manual dive start / end**, **bearing set /
  clear**, **acknowledge alarm**, **start / stop dive log**.
- No Smart Stack widget, no complication beyond app icon.

### 4.2 iOS MAIN

Hardware interactions are limited to standard UIKit / SwiftUI gestures.

Haptic events (iOS via `HapticFeedback.swift`):

- `tap()` — open Settings, request permission, language picker change.
- `confirm()` — sync now, retry watch sync, retry activation, conflict "Usa Watch".
- `destructive()` — reset profile, delete dive, reset pairing trust.
- `notify()` — conflict "Mantieni locale".
- `success()` — import CSV success.
- `error()` — import CSV failure, fileImporter failure.

Missing hardware interactions on iOS:

- No notification scheduling for safety reminders even though
  permissions are requested. (Acceptable for now — keep informational.)
- No Live Activity / Lock Screen widget. Out of scope today.

---

## 5. UX BLOCKERS

Severity scale: LOW · MEDIUM · HIGH · CRITICAL.

### CRITICAL

- **UX-C1 — Watch silently drops every iPhone → Watch payload.**
  `WatchSyncService` (Watch) only implements `didReceiveApplicationContext`.
  Imported CSV sessions on iPhone are queued with HMAC envelope and
  sent via `sendMessage` / `transferUserInfo`, but no consumer is wired
  on the Watch side. From the user's point of view, the iPhone says
  "Push verificato attivo" while the Watch never displays the session.
  **Impact:** advertised feature visibly does not work end-to-end.
  *File:* `Services/WatchSyncService.swift`.
- **UX-C2 — Tombstone keys diverge across MAIN branches.**
  Watch hardcodes `let deletedCloudKey = "dirdiving_watch_deleted_session_ids"`
  in `Services/DiveLogStore.swift` line 15. iOS uses
  `WatchSyncKeys.deletedSessionIDsKey = "dirdiving_shared_deleted_session_ids"`.
  Result: a delete performed on iOS (and synced to iCloud KVS) is
  never read by the Watch, and vice-versa. A previously-deleted dive
  can resurrect after a cloud-mediated reload. The Watch tree does not
  even ship the `WatchSyncKeys` module (`Utils/WatchSyncKeys.swift`
  does not exist on `main`).

### Accepted by product (not blockers)

- **UX-H1 / SAF-1 — Ascent warning replaces live dashboard (1 s).**
  Full-screen `AscentWarningView` for **1 s** when ascent goes over limit,
  then live dashboard with gauge. **Implemented** in `DiveLiveView` (2026-05-20).
- **UX-H4 — Mode Selection on cold launch.**
  First vertical page is `ModeSelectionView` (single "Diving" mode).
  **Accepted for current release** (2026-05-20).

### HIGH

- **UX-H2 — GPS confirmation hides depth + gauge.**
  Same view: when `dive.gpsConfirmation` is non-nil, the live layout is
  replaced by `GPSStartRegisteredView` / `GPSEndRegisteredView` for
  ~2.4 s (`Task.sleep(2_400_000_000)`). At dive start the Watch shows
  the GPS card instead of depth right after submersion.
- **UX-H3 — iOS unit broadcast is to a deaf endpoint.**
  Picking imperial on iOS sets a context key the Watch never reads.
  Apparently working feature; in practice no effect on Watch.

### MEDIUM

- **UX-M1 — Decorative rows look interactive in Watch Settings.**
  `statusRow(...)` calls `settingsRow(...)` with no chrome
  differentiation; the only signal for "this row is tappable" is the
  presence of a chevron, which is easy to miss. Most rows in
  `SettingsView` are informational.
- **UX-M2 — Single-option "Unità" picker on Watch.**
  Picker shows a single segment "m". On rotation/focus, the segmented
  picker invites interaction that has no outcome.
- **UX-M3 — `UserImagesView` is a permanent tab.**
  Always present in `ContentView`'s TabView, even when
  `imageStore.imageNames.isEmpty`. Adds a swipe between Settings and
  DiveLog. Costs a page slot that could be hidden.
- **UX-M4 — Compass SET BEARING has no visible confirmation.**
  Only a `.success` haptic; the user must look for the small
  "BEARING xxx° | DELTA xxx°" line to verify, which is a side effect,
  not a confirmation cue.
- **UX-M5 — Compass CLEAR disabled state is weakly disambiguated.**
  Same shape, similar opacity (38% vs 100%) and similar border color
  → underwater it can read as a still-active control.
- **UX-M6 — Alarm banner cannot be tapped to acknowledge.**
  `DiveLiveView.warningBanner` is purely visual; the only way to make
  it disappear is the 30 s internal cooldown. No tap-to-silence, no
  haptic cooldown shown to the user.
- **UX-M7 — Haptics-off badge is not shown pre-dive.**
  In `DiveLiveView.activeDiveContent` only; if the user opens the
  Watch app on the surface with haptics off, no banner warns them
  until the next dive starts.
- **UX-M8 — Two delete paths for the same dive on Watch.**
  `DiveLogListView` has a context-menu "Elimina" *and* `DiveDetailView`
  has a button "ELIMINA LOG". Both go through the same confirmation,
  but discoverability is inconsistent and double-paths increase the
  surface for accidental deletes (context menu fires on long press).
- **UX-M9 — Cloud conflict resolution is dive-only.**
  Conflict UI in iOS Settings is wired only for dive sessions.
  Equipment / planner cloud merges use "last writer wins" silently
  (acknowledged in copy as a TODO).
- **UX-M10 — Logbook empty state lacks the shortcut chips that Explore offers.**
  Inconsistent helpfulness across empty states.
- **UX-M11 — Planner modes are technically all tappable.**
  Advanced/Technical modes show non-trivial extra UI; "advanced" is the
  default in code. Simple mode is also fully functional. There is no
  visual cue that a given mode is "experimental" or "preview".
- **UX-M12 — `ExportView` export-completion screen uses an iCloud upload icon.**
  Icon `icloud.and.arrow.up` and copy "ESPORTAZIONE COMPLETATA" → user
  may believe the file was uploaded to iCloud, while the operation is
  a local file write + ShareLink.
- **UX-M13 — No accessibility labels on stopwatch / depth controls.**
  Critical Watch controls (START / STOP / RESET, AscentGaugeView,
  TTV/RunTime panel) only have ONE custom accessibility wrapper
  (TTV panel). VoiceOver users miss everything else on the live screen.

### LOW

- **UX-L1 — No `Localizable.strings`.** All UI strings are inline
  Italian literals on both platforms. `DIRAppLanguage` only changes
  `\.locale`, which affects formatters but not view labels.
- **UX-L2 — No Dynamic Type tuning on iOS Logbook / Settings rows.**
  Many `font(.system(size: …))` with `minimumScaleFactor(0.78)` are
  acceptable but not tied to Dynamic Type sizes.
- **UX-L3 — `DiveLogListView` empty-state banner reads
  "EXPORT NON DISPONIBILE"** even when sync from iPhone is possible
  later. Minor copy issue.
- **UX-L4 — `WatchShortcutHelpView` is not discoverable** outside
  Settings → "Azione / Comandi". No first-launch tip.
- **UX-L5 — `ExportView` "TORNA AI LOG" button uses generic capsule;
  the rest of the app uses `DiveCommandButton`** with neon borders.
  Minor inconsistency.
- **UX-L6 — `InfoView` reports "Spazio libero: Gestito da watchOS"** with
  no actual figure. Honest, but feels like a stub.
- **UX-L7 — Alarm step granularity not annotated.**
  Stepper increments are 1 m / 5 min / 5 % but the row only shows the
  current value; no "+1 m" hint.

---

## 6. SAFETY ISSUES

Safety items are the subset of UX blockers that can degrade dive
awareness or produce silent/incorrect feedback. All algorithmic logic
(decompression / TTV / ascent rate model) is intentionally **out of
scope** for modification per the audit constraints — these items are
about *exposing* the existing logic safely.

| ID | Severity | Description | Where |
|---|---|---|---|
| SAF-1 | — | **Accepted + implemented (2026-05-20).** Ascent warning replaces live UI for **1 s** (`ascentWarningTakeoverSeconds`), then depth/gauge visible. | `DiveLiveView` |
| SAF-2 | HIGH | GPS start/end overlay replaces live UI for ~2.4 s; depth/gauge invisible at dive-start. | `DiveLiveView.body`, `DiveManager.showGPSConfirmation` |
| SAF-3 | MEDIUM | TTV semantics: Watch labels it "TTV" with no inline disclaimer. Accessibility hint says "informativo derivato da profondita media e durata; non e un valore decompressivo o time to surface" but a sighted user must look at Settings to find the same wording. | `DiveLiveView.ttvRuntimePanel`, `SettingsView` "TTV live" row |
| SAF-4 | MEDIUM | CSV import bounds applied on iOS only (200 m / 480 min / -2…40 °C). Watch ingestion path does not exist in MAIN — neutral for safety. | `iOSApp/Services/DiveImportService.swift` |
| SAF-5 | MEDIUM | Alarm banner has no tap-to-silence / acknowledge with cooldown; relies entirely on internal 30 s window. | `DiveManager.triggerAlarm`, `DiveLiveView.warningBanner` |
| SAF-6 | MEDIUM | Tombstone divergence (UX-C2) → "zombie dive" possible after restore from cloud. | `Services/DiveLogStore.swift` vs `iOSApp/Services/DiveLogStore.swift` |
| SAF-7 | MEDIUM | Haptics-off badge missing on pre-dive screen. | `DiveLiveView.preDiveWaitingContent` |
| SAF-8 | MEDIUM | Dive-start haptic depends on GPS confirmation overlay (`.success`). On a no-fix start, the haptic only plays once the 6 s window expires. | `DiveManager.beginDiveIfNeeded` + `showGPSConfirmation` |
| SAF-9 | LOW | Planner safety acknowledgement is per launch (good) but never gated against the user changing input mid-session; if the user goes back to PlannerView and edits inputs without re-acknowledging, the result view still shows yellow notices but no second acknowledgement is asked. | `iOSApp/Services/PlannerStore.swift` |
| SAF-10 | LOW | No per-session sync-delivery status on iOS (copy reads "TODO: stato per-sessione planned"). The user can see global counts but not which dive is pending vs acknowledged. | `iOSApp/Views/MoreView.swift` |
| SAF-11 | LOW | Notification permission is requested in iOS Settings but the app does not actually schedule notifications anywhere; user may grant permission expecting alerts that never come. | `iOSApp/Views/MoreView.swift` |
| SAF-12 | LOW | Compass SET BEARING confirmation is haptic-only; if haptics are disabled, the user has no positive confirmation (only the delta line changes). | `Views/CompassView.swift` |

---

## 7. RECOMMENDED PRIORITY ORDER

### 7.1 Immediate fixes (before any release / TestFlight)

1. **Fix UX-C1**: implement an iPhone → Watch consumer.
   - Either wire `didReceiveMessage(_:replyHandler:)` /
     `didReceiveUserInfo(_:)` on the Watch and call a tombstone-aware,
     HMAC-verified `parseSession` (mirroring iOS code), or
   - Until that is wired, make iOS Settings honest:
     replace "Push verificato attivo" with "Push Watch non ancora
     disponibile in questa build" and disable `pushSession` from the
     iOS importer.
2. **Fix UX-C2**: unify tombstone keys to
   `WatchSyncKeys.deletedSessionIDsKey = "dirdiving_shared_deleted_session_ids"`
   on Watch as well, including a migration that reads any value left
   in the legacy key and merges it into the unified key.
3. **Fix SAF-2 (UX-H2)**: turn GPS confirmation into a compact top
   banner (≤ 1.5 s) over the live layout; never hide depth + gauge.
4. **Fix UX-H3**: either implement the Watch consumer for the units key
   (preferred) or stop broadcasting and label the iOS picker as
   "Locale a iPhone".

*Not required for this release (accepted 2026-05-20):* ascent warning
full-screen takeover (UX-H1 / SAF-1); Mode Selection as launch page (UX-H4).

### 7.2 Pre-release fixes (same release, after the immediate set)

5. **UX-M3**: hide `UserImagesView` when the bundle has no images.
6. **UX-M1 / UX-M8**: separate `infoRow` from `settingsRow` visually on
   the Watch and add accessibility traits.
8. **UX-M2**: replace the single-segment "Unità" picker with a static
   pill until imperial conversion is wired on Watch.
9. **UX-M4 / SAF-12**: show an inline "BEARING impostato" toast in
   `CompassView` after `setBearing()`.
10. **UX-M5**: make the CLEAR button visibly inert when disabled (different
    color/opacity, no border glow).
11. **UX-M6 / SAF-5**: add tap-to-acknowledge for alarm banner with
    visible cooldown timer.
12. **UX-M7 / SAF-7**: show the haptics-off badge in
    `preDiveWaitingContent` too.
13. **UX-M8**: keep only the explicit "ELIMINA LOG" inside
    `DiveDetailView`; remove the context-menu delete from
    `DiveLogListView`.
14. **UX-M12 / UX-L5**: update `ExportView` icon + copy to a neutral
    file/share icon and align the bottom button to the rest of the app.
15. **UX-M13**: add accessibility labels and hints to the START / STOP /
    RESET buttons, the ascent gauge, depth readout and stopwatch panel.
16. **SAF-3**: add a thin muted footnote under TTV on Watch
    ("informativo – non NDL / TTS") so sighted users see the same
    disclaimer the VoiceOver hint already gives.
17. **SAF-8**: play `HapticService.confirm()` directly inside
    `beginDiveIfNeeded` / `endDiveIfNeeded` (and `startManualDive` /
    `endManualDive`) rather than only inside `showGPSConfirmation`.
18. **UX-M9**: surface conflict resolution UI for equipment + planner
    even if it's a single "Mantieni locale" / "Usa cloud" prompt; or
    label the TODO state more strongly.
19. **UX-M10**: align Logbook empty state with Explore (add Sync /
    Import shortcut buttons).
20. **UX-M11**: disable / grey out planner modes that are not actually
    production-ready (if any).

### 7.3 Post-release improvements

21. **UX-L1**: extract all UI strings to `Localizable.strings`. Today
    `DIRAppLanguage` only changes the locale, not the labels.
22. **UX-L2**: add Dynamic Type-aware scaling on iOS Logbook, Settings
    and Dive Detail.
23. **UX-L4**: add a one-time first-launch tip on Watch that points to
    "Azione / Comandi" once the user installs the app.
24. **UX-L7**: annotate alarm stepper granularity inline (e.g. "+1 m",
    "+5 min", "+5 %").
25. **UX-L6**: drop the "Spazio libero" row or replace it with an
    actual figure once `FileManager` size queries are wired.
26. **SAF-9**: re-ask planner acknowledgement if inputs change
    significantly between two opens.
27. **SAF-10**: implement per-session sync delivery status (per-UUID
    state machine), removing the TODO copy.
28. **SAF-11**: either schedule actual notifications (for example
    surface-interval reminders) or stop asking permission.
29. App Intents: add `StartManualDiveIntent`, `EndManualDiveIntent`,
    `SetBearingIntent`, `ClearBearingIntent`, `AcknowledgeAlarmIntent`
    so the Action Button can drive them safely.
30. Add a "Reset session state" diagnostic button to settings (clear
    cached pending/imported IDs) for support cases.

---

## 8. CODE IMPACT REPORT

For each item, the estimated code surface is:

- **Small UI fix** = single view file, < 30 lines net.
- **Medium refactor** = 2–4 files, possibly a new helper / extension.
- **Architectural issue** = cross-platform, contracts to change.

| ID | Impact | Notes |
|---|---|---|
| UX-C1 | **Medium refactor** | Add a delegate hook on Watch `WatchSyncService` that calls `WatchDiveSyncCodec.parseSession` (must port the parsing extension from iOS), add a `logStore` attach, ensure tombstones are checked. No business logic changes. |
| UX-C2 | **Architectural (small)** | Add `Utils/WatchSyncKeys.swift` to Watch sources, update `DiveLogStore.swift` and any place that reads `dirdiving_watch_deleted_session_ids`, plus a one-shot migration. ~80 lines + project.yml include. |
| UX-H1 / SAF-1 | **Done** | 1 s full-screen takeover in `DiveLiveView` (`ascentWarningTakeoverSeconds = 1`); live layout restored afterward while over limit. |
| UX-H2 / SAF-2 | **Small UI fix** | Render `GPSStartRegisteredView` / `GPSEndRegisteredView` as compact banner (shorter Task.sleep ≤ 1.5 s, padded top of the live screen). |
| UX-H3 | **Medium refactor** | Add `didReceiveApplicationContext` handler (or extend the existing one) on Watch to read `WatchSyncKeys.unitsPreferenceKey` and persist to `dirdiving_watch_units`. |
| UX-H4 | **N/A (accepted)** | Mode Selection as first page accepted for current release (2026-05-20). |
| UX-M3 | **Small UI fix** | `ContentView` TabView: conditionally include `.userImages` when bundle has images. |
| UX-M1 / UX-M8 | **Small UI fix** | Add `infoRow` variant in `SettingsView` (no chevron, lower contrast title) and switch decorative rows to it. |
| UX-M2 | **Small UI fix** | Replace single-option `Picker` with a static pill in `unitPreferenceControl`. |
| UX-M4 / SAF-12 | **Small UI fix** | Add `@State` flag in `CompassView` that shows "Bearing impostato" for 1.5 s. |
| UX-M5 | **Small UI fix** | Add explicit disabled style branch in CLEAR button. |
| UX-M6 / SAF-5 | **Small UI fix** | Add tap action on warning banner that clears `alarmWarningMessage` (with cooldown) — `DiveManager.dismissAlarmWarning()`. No threshold change. |
| UX-M7 / SAF-7 | **Small UI fix** | Move `hapticsOffBadge` rendering to a wrapper that shows it both in pre-dive and active. |
| UX-M11 | **Small UI fix** | Add `.disabled(true)` and a tint change on disabled planner modes, plus a "Preview" pill. |
| UX-M12 / UX-L5 | **Small UI fix** | Swap icon, copy and button style in `ExportView`. |
| UX-M13 / UX-L6 / SAF-3 | **Small UI fix** | Add `.accessibilityLabel` / `.accessibilityHint` on Watch controls and a muted footnote under TTV. |
| SAF-8 | **Small UI fix** | Add `HapticService.shared.confirm()` direct call inside `beginDiveIfNeeded`, `endDiveIfNeeded`, `startManualDive`, `endManualDive`. |
| UX-M9 | **Medium refactor** | Persist conflicts for equipment/planner with a small `PlannerConflict` / `EquipmentConflict` Codable type, add resolution UI. |
| UX-M10 | **Small UI fix** | Reuse `emptyAction` style from `ExploreView` inside `LogbookView` empty state. |
| UX-L1 | **Architectural (small)** | Extract all UI literals to `Localizable.strings` on both platforms; touch many files but each diff is mechanical. |
| UX-L2 | **Small UI fix per view** | Add `.dynamicTypeSize` and `.minimumScaleFactor` plumbing where needed. |
| UX-L3 / UX-L4 / UX-L6 / UX-L7 | **Small UI fix** | Copy/text-only changes. |
| App Intents extension | **Medium refactor** | Add four new `AppIntent` types + `AppShortcutsProvider` entries; thin wrappers around DiveManager / CompassManager. |
| Notifications scheduling | **Medium refactor** | Add a `NotificationService` for iOS surface interval reminders; or revert permission ask. |
| Tombstone migration | **Small** | Read-once shim documented above. |

No item identified requires changing decompression math, TTV math,
gas model, ascent thresholds or any safety algorithm.

---

## 9. FINAL SUMMARY

### Release readiness estimate

**65–70%** for an internal TestFlight, **45–55%** for App Store. The
two CRITICAL items (UX-C1 and UX-C2) remain blockers because they make
the user-visible "Watch ↔ iPhone sync" contract dishonest. With those
fixed and the remaining HIGH items (UX-H2, UX-H3) addressed, the build
moves to **82–88%** readiness for a closed beta on real Apple Watch
hardware. Ascent-warning layout (UX-H1) and Mode Selection on launch
(UX-H4) are **not** counted against readiness (accepted 2026-05-20).

### UX completeness estimate

**70%**. All core flows exist and persist correctly within each
platform. Cross-platform contracts (units, tombstones, log push) are
the weak link. Several decorative rows still mimic interactive rows;
several settings expose UI without effect (units picker on Watch).
Accessibility coverage on the Watch live screen is the lowest
sub-score (single accessibility wrapper present).

### Stability estimate

**75–80%**. No crashes spotted in inspection. Persistence is robust
(`completeFileProtection` for the pending sync queue, JSON in
Documents). Cloud KVS reload via NotificationCenter is correctly
debounced. The main risk areas are:

- `Task.sleep(2_400_000_000)` inside `DiveManager.showGPSConfirmation`
  blocks GPS confirmation visibility for a known-fixed duration; if
  another dive event arrives during that window the second
  confirmation cancels the first. Not crash-prone, but timing fragile.
- `WatchSyncService` (Watch) re-activates on every retry; ensure
  multiple retries do not stack delegate notifications. The current
  guard `WCSession.default.delegate = self` is idempotent.

### Safety completeness estimate

**65–75%**. The dive safety logic itself (ascent monitor, alarms,
GPS fallback semantics) is implemented and persisted; what is
incomplete is the *exposure layer*:

- GPS overlay still hides the live dashboard for ~2.4 s (`SAF-2`) —
  pre-release fix recommended.
- Ascent warning full-screen takeover (`SAF-1`) is capped at **1 s** in
  `DiveLiveView` (2026-05-20); gauge remains visible afterward.
- Alarm banner cannot be acknowledged manually (`SAF-5`).
- Tombstone divergence (`SAF-6`) could lead to data inconsistency
  after a restore.
- Dive-start haptic depends on GPS confirmation (`SAF-8`).
- TTV semantics need a sighted-user disclaimer (`SAF-3`).

None of these require changes to the dive math; all are UI layer
fixes.

### Downloadable artefacts

- This Markdown report:
  `Docs/MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260519_CURRENT_PRE_MODIFICATION.md`
- Word version of the same content:
  `Docs/MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260519_CURRENT_PRE_MODIFICATION.docx`

Both files are produced from the same source so any text in this
report is also in the docx.

**Revision 2026-05-20:** UX-H1 / SAF-1 ascent warning capped at **1 s** in
`DiveLiveView`; UX-H4 (Mode Selection on launch) product-accepted. Audit
report only unless noted — code change applied for ascent warning duration.

### Audit guarantees

- No code in `main-iOS` was modified during this audit pass.
- Watch `Views/DiveLiveView.swift` updated 2026-05-20: 1 s ascent-warning
  full-screen takeover (`ascentWarningTakeoverSeconds`).
- No file under any `experimental*` branch was touched.
- No file marked as `excludes:` in `project.yml` for the MAIN targets
  was added to MAIN sources.
- All UX findings reference existing code paths in the currently
  checked-out trees (`main` @ `8b20113`, `main-iOS` @ `929182a`).
