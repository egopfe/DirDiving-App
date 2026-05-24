# DIR DIVING — MAIN Branch UX / Interaction / Feature Accessibility Audit

**Date:** 2026-05-24  
**Branch audited:** `main` @ `c23d4d4`  
**Scope:** Apple Watch MAIN target + iOS Companion MAIN target only  
**Excluded:** Experimental branches (`codex/experimental-features`, `codex/ios-experimental-features`) and all paths excluded in `project.yml` (Snorkeling, Apnea, Buddy Assist, Exploration Lab, etc.)

**Audit type:** Pre-modification, read-only static code review. **No application code was changed** for this report.

**Method:** Navigation graph tracing, SwiftUI view / `@AppStorage` inventory, `WatchConnectivity` / iCloud flows, haptics and App Intents review, cross-check with `Docs/DIR_Diving_Complete_Development_Notes_25_05_2026.md` implementation (`c23d4d4`).

**Downloadable Word report:** `Docs/MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524_POST_DEV_NOTES.docx`  
Generate: `python3 Docs/generate_main_branch_ux_interaction_accessibility_audit_20260524_post_dev_notes_docx.py`

---

## 1. Feature Inventory

Legend: **I** implemented in MAIN binary · **R** reachable without dev tricks · **C** user can complete the flow · Status: **Complete** / **Partial** / **Hidden** / **Broken** / **Excluded**

### 1.1 Apple Watch MAIN

| Feature | I | R | C | Status | Notes |
|---------|:-:|:-:|:-:|--------|-------|
| Legal first-launch onboarding | ✓ | ✓ | ✓ | Complete | `WatchLegalOnboardingView`; Accept required |
| Launch companion disclaimer | ✓ | ✓ | ✓ | Partial | Every cold launch; `CompanionDisclaimerAcceptance` not persisted |
| Mode Selection (multi-mode) | ✓ | ✗ | — | Hidden | `WatchModeSelectionPreferences.hasMultipleStableModes = false`; tab omitted |
| Live dive dashboard | ✓ | ✓ | ✓ | Complete | Default tab; forced during active dive |
| Auto dive start/stop (submersion) | ✓ | ✓† | ✓ | Complete | †Ultra / entitlement; `CMWaterSubmersionManager` |
| Manual dive start/end | ✓ | ✓‡ | ✓ | Partial | ‡UI only when `!isDepthAutomationAvailable` |
| Stopwatch START/STOP/RESET | ✓ | ✓ | ✓ | Complete | Independent of dive session |
| Ascent rate gauge + banner alarm | ✓ | ✓ | ✓ | Complete | `AscentGaugeView`; haptics throttled |
| Depth safety bands 35/38/40 m | ✓ | ✓ | ✓ | Partial | Fixed in `DepthSafetyConfiguration`; not in Settings UI |
| Configurable max-depth alarm | ✓ | ✓ | △ | Partial | Alarms UI default **40 m**; toggle default **off** |
| Runtime / battery alarms | ✓ | ✓ | ✓ | Complete | Runtime default **30 min** (`WatchAlarmDefaults` + `DiveManager`) |
| Compass / bearing SET·CLEAR | ✓ | ✓ | ✓ | Complete | App Intents + on-screen buttons |
| Settings hub | ✓ | ✓ | ✓ | Mostly | Many rows informational |
| Ascent limits (ASC SET) | ✓ | ✓ | ✓ | Complete | Crown steppers; iCloud via `AscentRateSettingsStore` |
| Alarm thresholds | ✓ | ✓ | ✓ | Complete | Crown; local only (not WC-synced) |
| Units metric/imperial | ✓ | ✓ | ✓ | Complete | Picker; `WatchDepthFormatting` on Live + Log |
| Language IT/EN/System | ✓ | ✓ | ✓ | Complete | Watch-only scope note in UI |
| Haptics master toggle | ✓ | ✓ | ✓ | Complete | `dirdiving_watch_haptics_enabled` |
| Dive log list + detail | ✓ | ✓ | ✓ | Complete | `NavigationLink` + `WatchDetailBackButton` |
| Export Subsurface CSV | ✓ | ✓ | ✓ | Complete | Latest + per-dive; `ExportView` + ShareLink |
| User Images tab | ✓ | △ | ✓ | Conditional | Tab only if iPhone sent images |
| Watch → iPhone dive sync | ✓ | ✓ | △ | Partial | Status rows + retry/clear in Settings |
| iPhone → Watch import | ✓ | △ | △ | Partial | Sessions + photos via WC |
| App Intents (7) | ✓ | △ | ✓ | Partial | All in `DIRDivingAppShortcuts`; user must assign Shortcuts/Action Button |
| Back on pushed screens | ✓ | ✓ | ✓ | Complete | `watchSubscreenBackToolbar` / `WatchDetailBackButton` (post dev notes) |
| Snorkeling / Apnea / Buddy | ✗ | ✗ | — | Excluded | `project.yml` excludes views/services |
| Water Lock API | ✗ | — | — | N/A | OS feature only; documented in Shortcuts help |
| Audio tones | ✗ | ✗ | — | N/A | Copy: not implemented |

### 1.2 iOS Companion MAIN

| Feature | I | R | C | Status | Notes |
|---------|:-:|:-:|:-:|--------|-------|
| Legal onboarding | ✓ | ✓ | ✓ | Complete | Blocks app until accepted |
| Launch companion disclaimer | ✓ | ✓ | ✓ | Partial | Every launch after legal |
| Tab: Planner (default) | ✓ | ✓ | ✓ | Complete | Advanced-only usable |
| Tab: Logbook | ✓ | ✓ | ✓ | Complete | Unit-aware depth display |
| Tab: Analysis | ✓ | ✓ | ✓ | Complete | Empty → import / logbook |
| Tab: Equipment + templates | ✓ | ✓ | ✓ | Complete | “My equipment” sheet + editor (`c23d4d4`) |
| Tab: More (settings) | ✓ | ✓ | ✓ | Complete | All settings in More, not separate app |
| Dive detail (3 tabs) | ✓ | ✓ | ✓ | Complete | Charts, gas, GPS accuracy |
| Manual dive add | ✓ | ✓ | ✓ | Complete | Logbook `+` |
| Manual dive edit | ✓ | ✓ | △ | Partial | Button on detail for `isManual`; editor hides nav bar |
| CSV import | ✓ | ✓ | ✓ | Complete | Logbook, Analysis, More |
| CSV export | ✓ | ✓ | ✓ | Complete | Per dive ShareLink |
| Planner + MOD validation | ✓ | ✓ | ✓ | Complete | Cylinders, switch depths, warnings (`c23d4d4`) |
| Planner safety ack | ✓ | ✓ | ✓ | Complete | Gates inputs until toggled |
| Watch sync + conflicts | ✓ | ✓ | △ | Partial | More UI; user-driven resolve |
| Watch photo → Watch | ✓ | ✓ | ✓ | Complete | Preprocess + warning (`WatchPhotoTransferPanel`) |
| iCloud KVS | ✓ | ✓ | △ | Partial | Decode errors surfaced in More |
| Units + WC push | ✓ | ✓ | △ | Partial | Planner still metric-only (honest notice) |
| Demo logbook | ✓ | ✓ | ✓ | Complete | Reviewer toggle |
| Reset Watch pairing | ✓ | ✓ | ✓ | Complete | More → reset trust button |
| Exploration / Buddy UI | ✗ | ✗ | — | Excluded | Not in iOS target |

---

## 2. Navigation Map

### 2.1 Watch MAIN

```
DIRDivingApp
└─ NavigationStack
   ├─ [if legal required] WatchLegalOnboardingView → Accept → ContentView
   └─ ContentView (TabView .verticalPage)
      ├─ [hidden] ModeSelectionView → .live
      ├─ DiveLiveView          ← default / forced when dive active
      ├─ CompassView
      ├─ SettingsView          ← root tab (no back)
      │   ├─ push → AscentRateSettingsView     [← watchSubscreenBackToolbar]
      │   ├─ push → AlarmSettingsView          [← watchSubscreenBackToolbar]
      │   ├─ push → WatchLegalSafetyView       [← WatchDetailBackButton]
      │   ├─ push → WatchShortcutHelpView      [← watchSubscreenBackToolbar]
      │   └─ push → InfoView                   [← WatchDetailBackButton]
      ├─ [if images] UserImagesView
      │   └─ detail state                      [← WatchDetailBackButton → list]
      └─ DiveLogListView
          ├─ push → DiveDetailView             [← WatchDetailBackButton]
          │   └─ dest → ExportView             [← WatchDetailBackButton + dismiss]
          └─ dest → ExportView (export latest)

Overlays: LaunchCompanionDisclaimer (fullScreenCover, each launch)
```

**Active-dive gating** (`ContentView`): While `dive.isDiveActive`, only `.live`, `.compass`, `.diveLog` allowed; Settings and User Images redirect to Live.

**Dead ends:** None critical. `ExportView` and pushed settings have explicit back. Tab roots use vertical swipe only.

**Missing routes:** Mode Selection, Apnea, Snorkeling (excluded). No in-app path to bulk-export from Settings (by design).

### 2.2 iOS MAIN

```
DIRDivingiOSApp
├─ [legal] IOSLegalOnboardingView
└─ ContentView (TabView)
   ├─ Planner → NavigationStack
   │   ├─ PlannerView (root)
   │   └─ destination → PlanResultView (share toolbar)
   ├─ Logbook → NavigationStack
   │   ├─ LogbookView
   │   ├─ link → DiveDetailView
   │   │   ├─ destination → ManualDiveEditorView (manual only)
   │   │   └─ export ShareLink
   │   └─ destination → ManualDiveEditorView (+)
   ├─ Analysis → NavigationStack (single level)
   ├─ Equipment → NavigationStack
   │   └─ sheet → EquipmentTemplatesSheet
   │       └─ sheet → EquipmentTemplateEditorView
   └─ More → NavigationStack
       ├─ link → IOSLegalSafetyView
       └─ inline panels (sync, CSV, photo)

Overlay: LaunchCompanionDisclaimer (each launch)
```

**Dead ends:** None. **Weak return:** `ManualDiveEditorView` uses hidden toolbar — relies on swipe-back.

---

## 3. Settings Report

### 3.1 Watch — exposed in UI

| Setting | UI location | Persisted | Applied | Synced to iPhone |
|---------|-------------|-----------|---------|------------------|
| Ascent rate limits | Settings → ASC SET | ✓ iCloud KVS | ✓ Live gauge | ✗ |
| Alarm toggles + thresholds | Settings → Allarmi | ✓ `@AppStorage` | ✓ `DiveManager` | ✗ |
| Units | Settings picker | ✓ | ✓ Live, Log, alarms label | ✓ publish on change |
| Language | Settings picker | ✓ | ✓ Watch UI | ✗ |
| Haptics | Settings toggle | ✓ | ✓ `HapticService` | ✗ |
| Legal | Settings link | ✓ acceptance store | ✓ gate | ✗ |

**Informational only (no control):** underwater settings notice, GPS behavior, export/TTV, display, audio, sync scope, depth sensor status, WC queue status.

**In code but no Settings UI:** `dirdiving_watch_skip_mode_selection_when_single`, depth safety 35/38/40 m bands, `hasMultipleStableModes`, iCloud dive blob (implicit).

**Not synced via WC:** alarm thresholds, haptics, language, ascent limits (ascent uses Watch iCloud KVS).

### 3.2 iOS — exposed in More

| Setting | Persisted | Synced Watch | Notes |
|---------|-----------|--------------|-------|
| Language | `dirdiving_app_language` | ✗ | `.environment(\.locale)` |
| Units | `dirdiving_ios_units` | ✓ push | Planner excluded |
| Watch sync / conflicts | WC + files | ↔ | Push all, reset pairing |
| iCloud sync now | KVS | — | Logbook, planner, equipment |
| Demo logbook | ✓ | ✗ | Reviewer |
| Planner safety ack | session revision | ✗ | Not in iCloud |
| CSV import | — | — | Multi-entry |
| Legal & Safety | acceptance | ✗ | Read-only view |

**Backend without dedicated UI:** bulk export from More (card is informational only).

---

## 4. Hardware Interaction Report

| Interaction | Watch | iOS | Notes |
|-------------|-------|-----|-------|
| **Digital Crown — tab paging** | ✓ (system `TabView`) | N/A | Vertical page style |
| **Digital Crown — threshold tuning** | ✓ | N/A | `AlarmSettingsView`, `AscentRateSettingsView` only |
| **Digital Crown — Live/Compass** | ✗ | N/A | Help mentions Crown for tabs (OS behavior) |
| **Swipe vertical** | ✓ tabs | ✓ tabs | Primary navigation |
| **Tap** | ✓ | ✓ | Buttons, toggles, lists |
| **Side button** | ✗ direct | N/A | 7 App Intents via Shortcuts; honest copy |
| **Long press** | ✗ | N/A | No dive long-press mapping |
| **Action Button** | △ optional | N/A | User-configured Shortcuts |

### Haptic events (Watch)

| Event | Mechanism | Respects toggle |
|-------|-----------|-----------------|
| Dive start/end | `criticalConfirm` | ✓ |
| Stopwatch / bearing / export OK | `confirm` | ✓ |
| Depth/runtime/battery alarms | `warnIfNeeded` | ✓ |
| Ascent over limit | `ascentAlarmTriggered` + repeat | ✓ |
| Depth 35/38/40 m | `DepthLimitHapticCoordinator` | ✓ |
| Alarm dismiss | `notify` | ✓ |

**Risks:** Depth-limit coordinator uses raw `WKInterfaceDevice` in addition to `HapticService` — generally respects `hapticsEnabled` in `DiveManager.updateDepthSafety`.

---

## 5. UX Blockers

| ID | Severity | Platform | Issue |
|----|----------|----------|-------|
| B1 | **HIGH** | Watch | No on-screen **Start Dive** when depth automation works — users must rely on submersion only |
| B2 | **MEDIUM** | Watch | During active dive, **Log** remains reachable (delete/export) while Settings blocked — inconsistent underwater policy |
| B3 | **MEDIUM** | Both | **Companion disclaimer every cold launch** — friction after full legal onboarding |
| B4 | **MEDIUM** | iOS | **Planner metric-only** despite global units — documented but limits real-world imperial users |
| B5 | **MEDIUM** | iOS | **Planner mode tabs** (Ricreativa/Tecnica/…) visible but disabled — misleading affordance |
| B6 | **MEDIUM** | iOS | **Manual dive editor** hides navigation bar — weak discoverable back |
| B7 | **LOW** | Watch | **Max-depth alarm off by default** — user may not enable 40 m threshold |
| B8 | **LOW** | Watch | **Depth safety 35/38/40** not configurable — separate from max-depth alarm setting |
| B9 | **LOW** | iOS | **Team gas matching** display-only — no edit UI for team SAC/cylinders |
| B10 | **LOW** | Both | **Localization gaps** — mixed IT/EN hardcoded strings (Watch Info, iOS Analysis empty state) |
| B11 | **LOW** | iOS | **Logbook header ellipsis** decorative — no menu attached |

**Resolved since prior audit (`13b4a16`):** manual dive edit entry, `DiveSessionMerge` manual fields, runtime 30 min engine default, Watch Live/Log unit formatting, planner ascent table from `decoStops`, all 7 App Intents in catalog, Watch back affordances on pushed screens.

---

## 6. Safety Issues

| ID | Severity | Issue | Mitigation in product |
|----|----------|-------|------------------------|
| S1 | **LOW** | Not a dive computer | Legal onboarding + disclaimers + TTV a11y copy |
| S2 | **LOW** | Planner is indicative | Safety ack + MOD warnings; deco not full Bühlmann desktop |
| S3 | **MEDIUM** | Max-depth **alarm disabled** by default | User must enable in Alarms |
| S4 | **LOW** | GPS labeled surface-only | Settings + detail fix-source labels |
| S5 | **LOW** | Manual dive without depth truth | Yellow copy on Compass/Live |
| S6 | **LOW** | MOD warnings do not block Calculate | By design — user must read warnings |
| S7 | **LOW** | Active dive: can still open Log | Potential distraction underwater |

No **CRITICAL** safety UX blockers found at `c23d4d4` for MAIN targets.

---

## 7. Recommended Priority Order

### Immediate (pre–TestFlight marketing)

1. **B1** — Add optional “Start dive” education or surface manual path when automation silent fails.  
2. **S3** — Consider default-on max-depth alarm or first-run prompt (product decision).  
3. **B3** — Persist companion disclaimer or show only on version bump.

### Pre-release

4. **B4 / B5** — Planner: hide disabled modes or enable recreational path; imperial display where feasible.  
5. **B6** — Visible Cancel/Save bar on `ManualDiveEditorView`.  
6. **B2** — Align dive-active gating (block Log or document why allowed).

### Post-release

7. **B9** — Team planner editing.  
8. **B10** — i18n pass Watch Info + iOS Analysis.  
9. Device QA: App Intents on hardware, WC conflict torture tests.

---

## 8. Code Impact Report

| Issue cluster | Impact | Typical change size |
|---------------|--------|---------------------|
| B1 dive start affordance | Small | Copy + optional button or status |
| B3 disclaimer persistence | Small | `@AppStorage` revision key |
| B4 planner units | Medium | Formatters on planner fields |
| B5 planner modes | Small | Hide tabs vs enable modes |
| B6 manual editor nav | Small | Toolbar Done/Cancel |
| B2 dive gating | Small | Extend `ContentView` page guard |
| S3 alarm default | Small | Default toggle or onboarding tip |
| B10 i18n | Medium | String catalog sweep |

No architectural rewrite required for listed items.

---

## 9. Final Summary

| Dimension | Estimate | Notes |
|-----------|----------|--------|
| **Release readiness (UX)** | **~84%** | Core Watch diving + iOS logbook/planner/equipment usable |
| **UX completeness** | **~80%** | Dev-notes features reachable; planner/mode gaps remain |
| **Stability (interaction)** | **~88%** | Tab crash fixed; sync/conflict surfaced |
| **Safety completeness (UX)** | **~85%** | Strong legal/ascent/MOD; alarm defaults need user action |

**Verdict:** MAIN @ `c23d4d4` is **suitable for continued TestFlight / field testing**. Remaining issues are mostly **medium/low UX polish** and **expectation management** (sensor dive start, planner metric-only, launch disclaimer), not missing core navigation.

**Experimental isolation:** MAIN target does not link Apnea/Snorkeling/Buddy/Exploration — no accidental dependency found in audited paths.

**Validation:** Static audit only; device QA recommended per `Docs/APP_INTENTS_DEVICE_QA_CHECKLIST.md` and `Docs/WATCH_IOS_SYNC_DEVICE_QA_CHECKLIST.md`.

---

## Appendix A — Sync Audit Summary

| Data | Watch → iPhone | iPhone → Watch | iCloud |
|------|----------------|----------------|--------|
| Dive sessions | ✓ signed transfer | ✓ ingest | ✓ iOS KVS |
| Tombstones | ✓ | ✓ broadcast | ✓ |
| Units | ✓ on change | ✓ context | — |
| Photos | — | ✓ file transfer | — |
| Alarms / haptics / language | — | — | — |
| Ascent limits | — | — | ✓ Watch KVS |
| Equipment / planner | — | — | ✓ iOS KVS |

**Failure modes:** WC queue retry/clear in Watch Settings; iOS conflict cards; `lastDecodeError` on iCloud decode.

---

## Appendix B — Error / Edge Case Matrix

| Condition | Watch UI | iOS UI |
|-----------|----------|--------|
| GPS denied | Settings status | Detail labels |
| Depth unavailable | Live banner + Settings | N/A (companion) |
| WC inactive | Settings sync rows | More status + push disabled |
| Import failure | — | CSV panel message |
| Photo convert fail | — | `watch_photo.error.convert` |
| Empty logbook | Log empty state | Analysis/Logbook hints |
| MOD exceeded | Planner warnings | Planner warnings (no block) |

---

*End of report.*
