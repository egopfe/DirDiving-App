# DIR DIVING — MAIN Pre-Release Simulator QA Checklist

**Date:** 2026-05-19
**Branches in scope:** `main` (Apple Watch MAIN), `main-iOS` (iOS Companion MAIN)
**Companion doc:** `MAIN_PRE_RELEASE_OPEN_ITEMS_20260519.md`

This document is the executable QA pass that must be performed **before tagging the pre-release**. It is the verification side of the 2026-05-19 backlog: every fix shipped to `main` / `main-iOS` has at least one scenario here.

> **Prerequisite:** Xcode 26.5 with both iOS 26.5 and watchOS 26.5 *platform runtimes* installed. SDKs alone are not enough.

---

## 0. Environment setup

### 0.1 Install platform runtimes (one-time)

If `xcrun simctl list devices available` is empty:

```bash
xcodebuild -downloadPlatform iOS
xcodebuild -downloadPlatform watchOS
```

(Or use Xcode → Settings → Components → install **iOS 26.5** and **watchOS 26.5**.)

### 0.2 Regenerate Xcode projects

From the repo root (`main` checkout):

```bash
xcodegen generate
```

From the iOS worktree (`main-iOS` checkout):

```bash
cd .worktrees/main-iOS   # or wherever your main-iOS worktree lives
xcodegen generate
```

### 0.3 Build smoke tests

```bash
# Watch (from main checkout)
xcodebuild -project DIRDiving.xcodeproj \
  -scheme "DIRDiving Watch App" \
  -sdk watchsimulator \
  -destination 'generic/platform=watchOS Simulator' \
  -configuration Debug \
  CODE_SIGNING_ALLOWED=NO \
  build

# iOS (from main-iOS checkout)
xcodebuild -project DIRDiving.xcodeproj \
  -scheme "DIRDiving iOS" \
  -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' \
  -configuration Debug \
  CODE_SIGNING_ALLOWED=NO \
  build
```

Both builds must exit with `** BUILD SUCCEEDED **` and zero warnings before continuing.

### 0.4 Simulators to use

| Form factor | Simulator | Why |
|---|---|---|
| Watch Ultra | Apple Watch Ultra 2 (49 mm), watchOS 26.5 | Widest hero-metric layout. |
| Watch small | Apple Watch SE 40 mm or Series 9 41 mm | Tightest layout — `.minimumScaleFactor` stress. |
| iPhone small | iPhone SE (3rd generation), iOS 26.5 | Dynamic Type stress. |
| iPhone large | iPhone 15 Pro Max, iOS 26.5 | Charts + safe-area stress. |

---

## 1. Apple Watch — DiveLive

### 1.1 Pre-dive idle layout (Ultra + small Watch)

- [ ] `PRONTO PER L'IMMERSIONE` is visible.
- [ ] Octopus logo + “DIR DIVING” in yellow at top.
- [ ] *“In attesa di avvio...”* row visible.
- [ ] If `hapticsEnabled = false` (Settings → Vibrazione off): the `APTICA DISATTIVATA / AVVISI SOLO VISIVI` yellow badge is rendered **above** the “PRONTO PER L'IMMERSIONE” block. (SAF-7)
- [ ] If depth automation is unavailable in the simulator, the yellow `AVVIO MANUALE` panel is shown at the bottom with the start button accessible.

### 1.2 Active dive layout (Ultra + small Watch)

Trigger an in-dive session (`DiveManager.startManualDive()` is a fast path).

- [ ] Top bar: octopus + clock + temperature `drop.fill` row.
- [ ] `IN IMMERSIONE` / `IMMERSIONE MANUALE` heading is green.
- [ ] If haptics off, the yellow badge appears below the heading. (SAF-7)
- [ ] `TTV INFO` / `RunTime` panel renders with the TTV value in muted color (`DiveUI.secondaryText`). (SAF-3)
  - [ ] VoiceOver reads: *“TTV sessione X, runtime Y”* + hint *“TTV informativo derivato da profondita media e durata; non e un valore decompressivo o time to surface.”*.
- [ ] Depth hero `Formatters.one(currentDepthMeters) m` is large; the `m` suffix is blue.
- [ ] Max + Avg depth cards are visible side by side under the hero.
- [ ] `AscentGaugeView` is rendered on the right of the depth row at all times.
- [ ] Stopwatch panel is yellow with `START / STOP / RESET` buttons; if manual mode active, `FINE MANUALE` appears under them.
  - [ ] VoiceOver: each control has label + hint. (UX-L6)

### 1.3 Ascent warning + gauge co-visibility (UX-H3 / SAF-1)

Simulate `dive.ascentStatus.isOverLimit = true`.

- [ ] A compact red banner appears **above** the depth row: `RISALITA X m/min`.
- [ ] `AscentGaugeView` on the right continues to render the live needle. **Banner must not replace the gauge.**
- [ ] VoiceOver reads *“Avviso risalita oltre limite, gauge ancora visibile”*.

### 1.4 GPS confirmation banner (UX-H4 / SAF-2)

Trigger `dive.gpsConfirmation = .start(point, fallback: false)` via dive start.

- [ ] A thin banner appears at the top of the live view: icon + `START GPS REGISTRATO` + coordinate.
- [ ] Banner is **not** full-screen. Depth hero, AscentGauge, TTV panel and controls remain visible **at the same time**.
- [ ] Variants render the correct color:
  - `point == nil` → yellow `GPS START NON DISPONIBILE`.
  - `point != nil, fallback == true` → yellow `START: ULTIMO PUNTO NOTO`.
  - `point != nil, fallback == false` → green `START GPS REGISTRATO`.
- [ ] Same coverage for `.end(...)` at dive end.

### 1.5 Alarm acknowledge (SAF-8)

Trigger `dive.alarmWarningMessage = "..."`.

- [ ] Yellow `exclamationmark.triangle.fill` banner appears at bottom of live content.
- [ ] An `OK` button is visible and tappable.
- [ ] Tapping `OK` dismisses the banner (`dive.dismissAlarmWarning`) with a cooldown — the banner cannot immediately re-fire on the same condition.
- [ ] Equivalent behavior must work via the **Acknowledge Alarm** App Intent / Siri shortcut.

---

## 2. Apple Watch — Compass

- [ ] Heading numeric value renders to two decimals.
- [ ] Tap **SET BEARING** → green inline toast `Bearing impostato` appears for ~1.5 s; haptic plays. (UX-M5)
- [ ] Tap **CLEAR** with no bearing set → button is rendered with `DiveUI.secondaryText` + dashed border + reduced opacity; it is clearly inactive. (UX-L5)
- [ ] With a bearing set, **CLEAR** is fully active; tapping resets bearing and plays haptic.
- [ ] VoiceOver labels and hints are present on both buttons. (UX-L6)
- [ ] Siri shortcuts `Set Bearing` and `Clear Bearing` work end-to-end.

---

## 3. Apple Watch — Settings & Logbook

### 3.1 Settings page

- [ ] No `Mode` page exists; the TabView vertical pages are Live, Compass, Settings, (UserImages only if not empty), DiveLog. (UX-M1 / UX-M3)
- [ ] `Velocità risalita`, `Allarmi`, `Lingua`, `Info`, `Azione / Comandi` rows have chevrons (settingsRow).
- [ ] `Sync impostazioni`, `Comportamento GPS`, `Schermo`, `Toni audio`, `Avvio manuale`, `TTV live`, `Export` rows have **no** chevron (infoRow). (UX-M4 / UX-M8)
- [ ] `Sync per log` shows `TODO: stato consegna per singola immersione`. (SAF-10)
- [ ] `Unità di misura` block: static `Display Watch: metrico` pill + yellow disclaimer. No picker. (UX-L2)
- [ ] `Riprova sync` button is always rendered; when `retrySyncDisabled` it shows muted color, no chevron, and the title `Riprova sync` with subtitle `Nessun retry necessario`.
- [ ] `Cancella coda fallita` row appears only when there are pending or failed transfers; tapping opens a confirmation dialog.
- [ ] `Vibrazione` toggle persists across launches and immediately toggles the SAF-7 pre-dive badge.

### 3.2 DiveLog & DiveDetail

- [ ] DiveLog rows: tap opens detail. No context-menu delete option. (UX-L9)
- [ ] DiveDetail bottom toolbar: `Esporta` and `Elimina` buttons are visible with VoiceOver labels/hints.
- [ ] Deleting a session asks for confirmation, then writes the tombstone to the unified key `dirdiving_shared_deleted_session_ids`. (UX-H1 / SAF-6)
- [ ] The deleted session does **not** reappear after iOS push or iCloud re-sync.

### 3.3 Alarm settings

- [ ] Each stepper shows the step granularity in copy (`Step Xm/min/%`). (UX-L8)
- [ ] VoiceOver reads stepper values + step hint.

---

## 4. Apple Watch — App Intents

For each shortcut, verify behavior in Shortcuts.app on the paired iPhone:

| Intent | Expected behavior |
|---|---|
| Start Manual Dive | `DiveManager.startManualDive()`, success haptic, dive UI enters in-dive state. |
| End Manual Dive | `DiveManager.endManualDive()`, success haptic, returns to pre-dive UI. |
| Set Bearing | Stores current heading as bearing, haptic, toast appears on compass when re-opened. |
| Clear Bearing | Removes bearing, haptic, CLEAR button shows disabled state. |
| Acknowledge Alarm | Dismisses current `alarmWarningMessage` if any, haptic. |

No intent claims side-button capture. (HARD-W3)

---

## 5. iOS — Logbook & Dive Detail

### 5.1 Logbook list

- [ ] List loads correctly with `.minimumScaleFactor` not clipping titles on iPhone SE. (UX-L7)
- [ ] Search bar filters by site name / date.
- [ ] Empty state offers `Impostazioni Sync` shortcut → opens the `IOSNavigationStore` MoreView. (UX-M10)
- [ ] Swipe-to-delete fires `HapticFeedback.destructive()`; tombstone written to `dirdiving_shared_deleted_session_ids`. (UX-H1 / SAF-6)
- [ ] CSV import (file picker):
  - Valid Subsurface CSV → success haptic; `pushSession` queues iOS→Watch payload.
  - Invalid rows (depth > 200 m, duration > 480 min, temperature outside −2…40 °C) → rows are skipped, `skippedMalformedCount` is reported in the import alert. (SAF-4)
  - Invalid lat/lon → row skipped.
  - Completely unparseable file → user-readable error.

### 5.2 Dive detail

- [ ] Header shows the cyan circular back chevron with VoiceOver label `Torna al logbook`. (UX-M2)
- [ ] `RIEPILOGO` tab → `Tempo / Max Profondita / Prof. Media` row, then `TTV info / SAC / Temperatura` row.
- [ ] **TTV info tile** carries the muted footnote: *“TTV informativo: derivato da profondità media + runtime; non è un valore decompressivo o time-to-surface.”* (SAF-3)
- [ ] VoiceOver on TTV tile reads label + hint clarifying its informational nature. (SAF-3)
- [ ] Depth chart and gas block render without overlap on iPhone SE and iPhone Pro Max.
- [ ] Export block: `Genera CSV Subsurface` then `Condividi CSV` ShareLink. Both have a11y labels + hints. (UX-L6)
- [ ] Delete dive triggers `HapticFeedback.destructive()` and writes the tombstone.

---

## 6. iOS — Planner

- [ ] On every fresh app launch, the **safety toggle resets to off** the first time PlannerView appears. (SAF-9)
- [ ] After ticking once in a launch, switching tabs and returning to Planner preserves the ack.
- [ ] **Calcola Piano** button:
  - With invalid input → red banner + `HapticFeedback.error()`.
  - Without safety ack → red banner `Conferma prima l'avviso safety…` + `HapticFeedback.error()`.
  - All clear → opens `PlanResultView` + `HapticFeedback.success()`.
  - VoiceOver label + hint present. (UX-L6)
- [ ] `Modalita` segmented control:
  - `Semplice` is interactive (Button) and selectable.
  - `Avanzato` / `Tecnico` render with `.opacity(0.55)` **without** a Button wrapper — tapping them does nothing. (UX-M13)
  - VoiceOver announces them as `Avanzato Planned` / `Tecnico Planned`.

---

## 7. iOS — More / Settings

### 7.1 Preferences card

- [ ] Lingua picker (System / Italiano / English) persists; companion-detail caption visible.
- [ ] Unità picker (Metrico / Imperiale): changing the value triggers `watchSync.pushUnitsPreference(newValue)`.
- [ ] Caption clarifies: *“Persistita localmente; broadcast iOS → Watch via WatchConnectivity context (solo metric oggi).”* (UX-M7)
- [ ] `Export predefinito` is locked at Subsurface CSV with yellow note.
- [ ] `Sync impostazioni: Locale-only` and `Planner safety: Disclaimer richiesto` infoRows present (no chevron). (UX-M8)

### 7.2 Notifications card

- [ ] `Stato autorizzazione` row updates after first launch.
- [ ] **Richiedi permesso notifiche** button: tapping triggers `UNUserNotificationCenter.requestAuthorization`. If status is `.notDetermined`, the iOS prompt appears. (UX-M11)
- [ ] **Apri Impostazioni iOS** button: deep links to system settings via `UIApplication.openSettingsURLString`.

### 7.3 Watch Sync card

- [ ] `Stato` field uses Italian labels (`Attivo / Non attivo / In attesa / Sconosciuto`) — not `String(describing:)`. (UX-M9)
- [ ] `Peer verificato` shows `Si`/`No`.
- [ ] `iPhone → Watch` row reads `Push verificato attivo (N pending)` when peer secret is present, otherwise `In attesa peer secret · push gated`. (UX-H2)
- [ ] `Riprova Watch Sync` button is **always** visible; disabled with subtitle `(idle)` when activation is active and no failures. (UX-M4)
- [ ] **Reset trust / re-pair** opens a confirmation dialog and on confirm calls `watchSync.resetPairingTrust`. Plays destructive haptic.
- [ ] Conflict rows (if present) show `Mantieni locale` / `Usa Watch` buttons with haptic feedback and a11y labels. (UX-L6)
- [ ] `Delivery per log` row shows `TODO: stato per-sessione planned`. (SAF-10)
- [ ] When activation is active but peer secret is missing → empty state `Associazione Watch non verificata` appears.
- [ ] When activation not active → empty state `Sync Watch non attivo` appears.

### 7.4 Cloud backup card

- [ ] `Sincronizza ora` plays confirm haptic and forces KVS sync.
- [ ] `infoNote` accurately distinguishes dive-session merge from equipment/planner last-write-wins.

### 7.5 Reviewer card

- [ ] `Logbook dimostrativo` toggle adds 5 demo dives; toggling off removes them.

### 7.6 Export card

- [ ] All non-Subsurface formats labelled `Planned`. `Bundle` shows `com.egopfe.dirdiving.ios`.

---

## 8. iOS — Explore & Analysis

- [ ] `ExploreView` no longer renders the dead helpers (`mapPin`, `routeLine`, `bathymetryOverlay`, `gridOverlay`, `DepthTrendPreview`, `progressRing`, `infoRow`, `analyticsTile`). (UX-L3)
- [ ] Empty state offers `Apri Logbook` shortcut → switches `IOSNavigationStore.selectedTab`. (UX-M10)
- [ ] CSV import in Explore matches §5.1 behavior (success haptic + iOS→Watch push).
- [ ] `AnalysisView` no longer renders `analysisPill`, `trendCard`, `AnalysisDepthTrendPreview`. (UX-L4)
- [ ] Charts still render correctly with valid data.

---

## 9. Sync — Cross-device tombstone

Two-device test (Watch + iPhone, both paired):

| Step | Expected |
|---|---|
| Create a dive on Watch (or import on iPhone). | Session appears on both ends after sync. |
| Delete the dive on Watch. | Tombstone written to `dirdiving_shared_deleted_session_ids`. |
| Force iOS push (Logbook re-import or `Sincronizza ora`). | Session does **not** resurrect on either device. |
| Repeat in the opposite direction (delete on iPhone). | Same — no resurrection on Watch after WatchConnectivity replay. |
| Delete on iPhone while Watch offline; bring Watch online. | Watch consumes the tombstone via WC `applicationContext` / `transferUserInfo`. |

---

## 10. Sync — First pairing & failure modes

| Scenario | Expected |
|---|---|
| First-ever launch on both apps (no peer secret). | `MoreView` shows `Associazione Watch non verificata`. `pushSession` queues outbound; `pendingOutboundCount` increments. |
| `WatchSyncAuth.publishSharedSecretIfNeeded()` runs. | After WC `applicationContext` exchange, `hasPeerSecret() == true`; `flushPendingOutbound` drains the queue. |
| Watch unreachable. | `sendQueuedOutbound` falls back to `transferUserInfo`; status row shows `Push iPhone → Watch: in coda WatchConnectivity`. |
| Watch reachable, ack received. | Outbound entry removed; status row shows `Push iPhone → Watch: confermato`. |
| Forged payload (signature mismatch). | Watch rejects via `WatchDiveSyncCodec.parseSession`; iOS `failedImportCount` increments. |

---

## 11. Haptics matrix

Verify each haptic fires once per event (no double-fire, no missing fire):

| Event | Watch | iOS |
|---|---|---|
| Auto dive start (depth-triggered) | `HapticService.confirm()` | n/a |
| Auto dive end | `HapticService.confirm()` | n/a |
| Manual dive start (button or App Intent) | `HapticService.confirm()` | n/a |
| Manual dive end | `HapticService.confirm()` | n/a |
| Alarm fires | `HapticService.failure()` | n/a |
| Alarm acknowledged | `HapticService.notify()` (cooldown) | n/a |
| Bearing set | `HapticService.confirm()` | n/a |
| Bearing cleared | `HapticService.notify()` | n/a |
| CSV import success | n/a | `HapticFeedback.success()` |
| CSV import failure | n/a | `HapticFeedback.error()` |
| Dive delete | n/a | `HapticFeedback.destructive()` |
| Planner calculate success | n/a | `HapticFeedback.success()` |
| Planner validation error | n/a | `HapticFeedback.error()` |
| MoreView retry sync | n/a | `HapticFeedback.confirm()` |
| MoreView reset trust | n/a | `HapticFeedback.destructive()` |
| Conflict resolve (Keep local) | n/a | `HapticFeedback.notify()` |
| Conflict resolve (Use Watch) | n/a | `HapticFeedback.success()` |
| Sync now (cloud) | n/a | `HapticFeedback.confirm()` |

Also: with `Vibrazione` toggle off on Watch, the SAF-7 yellow badge must be visible both pre-dive and in-dive; alarms must still fire visually.

---

## 12. Accessibility sweep (UX-L6 + UX-L7)

Run with VoiceOver and Dynamic Type ≥ XL on each platform:

- [ ] Watch DiveLive: START/STOP/RESET/MANUAL controls all readable; TTV panel reads label + hint; depth hero uses `monospacedDigit` so VoiceOver reads numbers cleanly.
- [ ] Watch DiveDetail: export + delete actions readable.
- [ ] Watch Compass: SET / CLEAR readable; CLEAR disabled state announced.
- [ ] Watch AlarmSettings: each stepper announces value + step.
- [ ] Watch DiveLogList: row reads site name + date + max depth.
- [ ] iOS MoreView: all action buttons (notification request, system settings, retry sync, reset trust, sync now, conflict resolve) have labels + hints; rows read combined (`accessibilityElement(children: .combine)`).
- [ ] iOS Planner: `Calcola Piano` reads label + hint; disabled mode tabs announce `Planned`.
- [ ] iOS Logbook: import button, search, swipe-delete all readable.
- [ ] iOS DiveDetail: back chevron, export, share, TTV info tile (a11y label/hint).
- [ ] Dynamic Type XL: `MoreView`, `LogbookView`, `DiveDetailView`, `PlannerView` use `.minimumScaleFactor` and wrap cleanly. No overflow, no truncation that loses meaning.

---

## 13. Edge cases (do not block release, but flag if regressed)

- [ ] GPS authorization denied at launch → Watch DiveLive proceeds without GPS; banners show `GPS START NON DISPONIBILE` truthfully.
- [ ] Depth sensor unavailable → AVVIO MANUALE panel appears pre-dive; manual lifecycle works end-to-end.
- [ ] Bluetooth off / Watch unpaired → iOS MoreView shows `Sync Watch non attivo`; retries do not crash.
- [ ] Permissions denied for notifications → iOS deep link still works.
- [ ] Sync interrupted mid-transfer → no crash, no duplicates after retry.
- [ ] Export disk full → user-facing error message, no crash.

---

## 14. Sign-off

Tester to fill in:

- iOS build SHA: `__________`
- Watch build SHA: `__________`
- iOS simulators tested: `__________`
- watchOS simulators tested: `__________`
- Open Items doc reviewed: yes / no
- Blocking issues found: yes / no — if yes, link issue IDs: `__________`

---

*Generated as part of the MAIN pre-release backlog execution, 2026-05-19. Pair with `MAIN_PRE_RELEASE_OPEN_ITEMS_20260519.md`.*
