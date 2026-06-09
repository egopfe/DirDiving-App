# DIR DIVING — MAIN UI/UX / Accessibility / Release Readiness Audit (Current)

**Date:** 2026-06-09  
**Branch:** `main` @ `7fd3891`  
**Command:** `commands_for_cursor/4-DIR_DIVING_UI_UX_AUDIT_CCR_UPDATED.md` (4th audit in recurring sequence)  
**Scope:** Apple Watch MAIN (`DIRDiving Watch App`) + iOS Companion MAIN (`DIRDiving iOS`)  
**Audit type:** Read-only — **no source code modified**  
**Prior audits:** iOS Bühlmann readiness, Watch complete algorithm, iOS complete algorithm (remediated @ `7fd3891`)

---

## A. Executive Summary

| Metric | Score | Notes |
|--------|-------|-------|
| **Overall UX readiness** | **88%** | Both apps are functionally complete, safety-gated, and coherent; remaining gaps are polish, CCR a11y/localization parity, and external evidence |
| **Watch UX readiness** | **87%** | Strong live-dive safety UX; ascent settings IT leak, reminder dismiss, image swipe, sync string hygiene |
| **iOS UX readiness** | **89%** | Five-tab IA solid; planner/CCR/tissue/export mature; watch photo panel a11y and sync copy gaps |
| **Planner UX readiness** | **91%** | Base/Deco/Technical mode gating clear; MOD/PPO2 proactive; monolithic `PlannerView` maintenance risk |
| **CCR UX readiness** | **84%** | First-class mode with disclaimers, validation, PDF, checklist export; sparse chart a11y, no checklist import, GF/gas stepper localization |
| **Accessibility readiness** | **79%** | Strong on Live/OC planner/tissue; weak on CCR charts, watch photo transfer, equipment checklist toggles |
| **Localization readiness** | **81%** | ~1,500+ keyed strings EN/IT; Italian-as-key pattern persists in Watch sync/diagnostics and ascent settings |
| **Internal TestFlight UX** | **Conditional YES** | Team QA viable with documented caveats; legal gates and disclaimers layered correctly |
| **External TestFlight UX** | **Not ready** | Physical Watch Ultra QA, paired sync evidence, localization P1 fixes required |
| **App Store UX** | **Not ready** | No canonical reference PNGs, marketing checklist incomplete, physical/external QA **PENDING** |

### Top blockers (UX-facing)

1. **Physical / external QA not executed** — Watch Ultra underwater matrix, two-device iCloud/sync, Subsurface CSV validation, Dynamic Type/VoiceOver matrix — all **PENDING** (evidence folders exist; no PASS claims).
2. **Reference UI PNGs missing** — `Docs/ReferenceUI/` documents required baselines; files not in repo (`README.md` L3–4).
3. **Localization leaks** — `AscentRateSettingsView` hardcoded `LIMITI PERSONALIZZATI` / `RESET STD`; mixed Italian-as-key in Watch/iOS sync diagnostics.
4. **CCR accessibility gap** — Result timelines (PPO2, END, PPN2) lack VoiceOver summaries unlike tissue analytics module.
5. **Watch photo transfer a11y** — `WatchPhotoTransferPanel.swift` has zero `accessibilityLabel` coverage.
6. **App Store marketing assets** — Screenshot set, preview video, localized store copy gate per `IOS_APP_STORE_ALGORITHM_MARKETING_REVIEW_CHECKLIST.md` — **PENDING**.

---

## B. Scope Confirmation

| Check | Result |
|-------|--------|
| Branch | `main` |
| Commit | `7fd3891f518612838abf12c01c76928bf5d8a0dd` |
| Working tree | Clean (audit-only doc add expected) |
| Remote | `main...origin/main` aligned |
| Audit-only | **Confirmed** — no Swift/business-logic changes |

### Targets (`project.yml`)

| Target | Platform | Bundle ID | Role |
|--------|----------|-----------|------|
| `DIRDiving Watch App` | watchOS 10+ | `com.egopfe.dirdiving.ios.watch` | Watch MAIN |
| `DIRDiving iOS` | iOS 17+ | `com.egopfe.dirdiving.ios` | iOS Companion MAIN |
| `DIRDiving Watch Algorithm Tests` | watchOS | — | Test only |
| `DIRDiving iOS Algorithm Tests` | iOS | — | Test only |

Watch companion relationship: iOS embeds Watch app (`dependencies: target: DIRDiving Watch App, embed: true`).

### Experimental exclusions (confirmed)

**Watch excluded from compile:** `ApneaView.swift`, `SnorkelingView.swift`, `BuddyAssistView.swift`, `ExperimentalConceptsView.swift`, `ExperimentalFeatures.swift`, exploration/buddy models and services.

**iOS excluded from compile:** `ExplorationCenterView.swift`, `BuddyExperimentalView.swift`, `ExperimentalFutureConceptsView.swift`, exploration/buddy stores/models.

Experimental Swift may exist in repo but is **not** in MAIN binaries.

### Build validation (2026-06-09)

| Step | Result |
|------|--------|
| `xcodegen generate` | **OK** |
| `xcodebuild` Watch (`Apple Watch Ultra 3 (49mm)`) | **BUILD SUCCEEDED** |
| `xcodebuild` iOS (`generic/platform=iOS Simulator`) | **BUILD SUCCEEDED** (retry after transient DerivedData lock) |

### Files / directories inspected

`iOSApp/Views/`, `iOSApp/Views/CCR/`, `iOSApp/Views/TissueAnalytics/`, `Views/` (Watch), `Services/`, `Resources/`, `iOSApp/Resources/`, `Docs/RELEASE_CHECKLIST.md`, `Docs/TESTFLIGHT_RELEASE_GATE_CHECKLIST.md`, `Docs/APP_STORE_RELEASE_GATE_CHECKLIST.md`, `Docs/ReferenceUI/README.md`, algorithm audit remediation reports.

---

## C. Global Navigation Map

### iOS Companion flows

```
DIRDivingiOSApp
├── [gate] IOSLegalOnboardingView (4-step, scroll-gated disclaimer)
├── [overlay] LaunchCompanionDisclaimerOverlay (per cold launch, session-only)
└── ContentView (TabView)
    ├── Planner → PlannerRootView
    │   ├── PlannerModeSelectionView (Base / Deco / Technical / CCR)
    │   ├── PlannerView → PlanResultView (OC)
    │   └── CCRPlannerView → CCRPlanResultView
    ├── Logbook → DiveDetailView, ManualDiveEditorView, CSV import
    ├── Analysis → tissue/narcosis replay, CSV import
    ├── Gear (Equipment) → checklist, templates, checklist PDF
    └── More (Settings) → language, units, watch sync, iCloud, legal, demo logbook, CSV export
```

### Apple Watch flows

```
DIRDivingApp
├── [gate] WatchLegalOnboardingView
├── [overlay] LaunchCompanionDisclaimerOverlay
└── ContentView (TabView .verticalPage, Crown)
    ├── DiveLiveView (default)
    ├── CompassView (BUSSOLA — reachable underwater)
    ├── SettingsView → ascent, alarms, reminders, legal, sync, mission, dev, info, shortcuts
    ├── UserImagesView (surface only)
    └── DiveLogListView → DiveDetailView, ExportView
```

### Unreachable / hidden / dead ends

| Item | Status |
|------|--------|
| `ModeSelectionView` (Watch) | Dormant — `hasMultipleStableModes = false` |
| Apnea / Snorkeling / Buddy / Exploration | Excluded from MAIN compile |
| Settings / Log / Images during active dive | Blocked with underwater toast |
| CCR on Watch | **Not implemented** (by design — iOS only) |
| Planner mode switch in-flow | Requires back to `PlannerModeSelectionView` |

### Missing / weak entry points

| Gap | Impact |
|-----|--------|
| No tab badge when Watch sync conflicts or pending queue | User must open More to discover issues |
| CCR checklist **import** (OC has import) | CCR users must re-enter gas manually |
| No deep link from Action Button help to watchOS Settings | Discoverability friction |

---

## D. Apple Watch UX Analysis

### Live Dive (`DiveLiveView.swift`)

| Aspect | Assessment |
|--------|------------|
| Reachability | Default tab; only tab + Compass underwater |
| Safety overlays | Ascent banner, depth tiers (35/38/40), stale depth, manual-no-depth, GPS — prioritized via `LiveDiveBannerPresentationPolicy` |
| Ascent gauge | Color bands + pointer; localized a11y |
| TTV / runtime | Visible during alarms (policy-compliant) |
| Mission Mode | Reduces decorative effects; bolt on logo |
| Dive start | Manual panel + auto-waiting when automation available; simulation/mock badges |
| Sync strip | Photo/dive transfer status on Live |

**Strengths:** Safety-first hierarchy; scroll container post-remediation; stopwatch reset confirmation on-screen; haptics-off visual badge.

**Gaps:** Dense banner stack may still push depth/gauge below fold on 40 mm when multiple alerts fire; collapsed secondary chip not expandable; `hapticsOffBadge` lacks a11y label; GPS banners at bottom of scroll.

**Readiness:** **88%**

### Start Dive UX

Manual `dive.startManualDive()` and automatic depth trigger coexist with collision handling and handoff copy. Simulator/mock clearly marked. **91%**

### Reminders (`DiveReminderSettingsView`, `DiveReminderOverlayView`)

Configurable types, intervals, haptics, presets; settings blocked during dive; overlay suppressed when ascent/depth alarms active.

**Gaps:** 3s auto-dismiss only — no tap dismiss; no indication when suppressed by higher-priority alarms.

**Readiness:** **85%**

### Images (`UserImagesView.swift`)

Empty state directs to iPhone; delete confirmation; row/detail/fullscreen a11y. Blocked during dive (by design).

**Gaps:** No swipe between images despite page dots; bundled vs uploaded not explained in UI.

**Readiness:** **83%**

### Mission Mode (`MissionModeIndicatorView`, `SettingsView`)

Clear separation from Apple LPM; live toggle; auto-enable option. Does not alter safety metrics (verified in algorithm audits).

**Readiness:** **92%**

### Developer Sensor Source (`DeveloperSettingsView.swift`)

Hidden behind 7× version tap on Info; release-safe migration to automatic; simulation badges on Live.

**Readiness:** **90%**

### BUSSOLA (`CompassView.swift`)

Dial, SET/CLEAR bearing, in-dive metrics, idle states. Uses **BUSSOLA** terminology (not COMPASSO). Localized a11y.

**Readiness:** **90%**

### Logbook / Export

Empty state with export guidance; manual-no-depth export blocked with messaging; ShareLink on completion view.

**Gaps:** Export latest = first session only; date format `dd/MM/yyyy` not locale-adaptive.

**Readiness:** **86%**

### Settings / Info / Haptics

Comprehensive hub; underwater informational row; haptic throttling. Ascent settings **P1 localization leak** (`LIMITI PERSONALIZZATI`, `RESET STD` hardcoded in `AscentRateSettingsView.swift` L33, L47).

**Readiness:** **85%**

### Branding

Octopus icon on Live top bar; AppIcon in asset catalog; consistent `DiveUI` neon-on-black. Mission bolt may be hard to discover.

**Readiness:** **88%**

---

## E. iOS Companion UX Analysis

### Logbook (`LogbookView.swift`)

Search, monthly grouping, demo banner with a11y, delete confirm, CSV import, manual dive entry (+).

**Readiness:** **90%**

### Manual Dive (`ManualDiveEditorView.swift`)

Synthetic profile disclosure; CCR metadata when `gasLabel == .ccr`; metadata-only mode for watch-imported no-depth sessions; Policy A depth preservation (post-fix).

**Readiness:** **91%**

### Analysis (`AnalysisView.swift`)

Tissue/narcosis replay; CSV import entry (duplicated with Logbook/More).

**Readiness:** **88%**

### Planner (OC)

See Section F.

### CCR

See Section G.

### Ratio Deco / Tissue / Narcosis

See Sections H (planner subsection) and dedicated phase outputs below.

### Checklist / Gear (`EquipmentView.swift`)

Editable profile, gas-linked items, templates, checklist PDF share. Planner ↔ checklist sync sheet on OC planner.

**Gaps:** Per-item checklist toggles lack a11y; CCR export-only (no import).

**Readiness:** **87%**

### PDF / Share

OC: plan, briefing, dive pack (input + result). CCR: plan PDF on result. Equipment: checklist PDF. Share via `ShareSheetView`.

**Readiness:** **90%**

### Watch sync / Cloud (`MoreView.swift`, `WatchSyncService`, `CloudSyncStore`)

Status rows, push, reset pairing, conflicts, iCloud toggle, decode errors. Photo panel in More.

**Gaps:** Hardcoded/mixed-language sync status strings in service layer; no tab-level conflict indicator; `WatchPhotoTransferPanel` zero a11y labels.

**Readiness:** **84%**

### More / Settings

Language (system/it/en), units, CNS summary toggle, developer unlock, legal, demo logbook, safety footer.

**Readiness:** **89%**

### Onboarding / legal

`IOSLegalOnboardingView` — 4 steps, scroll gate, 5 acceptance toggles. `LegalAcceptanceStore` revision `2026-05-23`. Per-launch companion disclaimer. Planner safety acknowledgment separate toggle on OC planner.

**Gap:** Three disclaimer layers may feel repetitive; CCR planner lacks identical safety-ack toggle block (warning-only when not ack'd).

**Readiness:** **88%**

---

## F. Planner UI/UX Analysis

| Mode | Readiness | Highlights | Gaps |
|------|-----------|------------|------|
| **Base** | **90%** | Single-gas, limits, no deco overload, reference disclaimer | No extended MOD/PPO2 preview tiles until calculate |
| **Deco** | **92%** | One deco gas, GF presets, simplified ascent, gas ledger | Mode switch requires hub navigation |
| **Technical** | **93%** | Full multigas, travel/bailout, manual GF, tissue entry, team preview labeled preview-only | Large `PlannerView.swift` surface area |
| **Overall Planner** | **91%** | `PlannerModePolicy` gates input + result presentation; MOD blocks calculate; Ratio Deco heuristic banner | `"Calcola Piano"` Italian key pattern; legacy `plannerModeTabLabel` helper |

### MOD / PPO2 / switch-depth

- Live MOD warnings via `PlannerMODValidator`; calculate blocked when invalid.
- PPO2 step 0.1; switch depth clamps to MOD on gas/PPO2 change.
- Extended analysis tiles in Deco/Technical (PPO2, END, EAD, CNS preview, OTU).

**MOD/PPO2 UX:** **92%** | **Switch-depth UX:** **91%** | **Dalton validation UX:** **90%**

### Ratio Deco (`RatioDecoPlannerViews.swift`)

Heuristic disclaimer, Bühlmann validation layer, overlay chart with `UIUXAccessibilitySummaries.ratioDecoOverlayChart`. Blocked in Base and CCR mode.

**Ratio Deco UX:** **90%**

### Tissue / Narcosis (`TissueNarcosisAnalyticsView.swift`)

16 compartments, grouped sections, controlling compartment, GF/M-value modes, planner/logbook/CCR entry points, disclaimer alert, chart a11y summaries.

**Tissue Loading UX:** **91%** | **Narcosis UX:** **90%**

---

## G. CCR / Rebreather UX Analysis

### Entry (`PlannerModeSelectionView`, `PlannerRootView`)

CCR isolated from OC; localized `planner.mode.ccr` + description; safety disclaimer on selection and input (`ccr.safety.disclaimer`).

### Input (`CCRPlannerView.swift`)

Setpoint low/high/switch, diluent editor (air/EAN/trimix), bailout list, GF fields, live validation card. Calculate navigates to result only when `validationResult.isValid`.

**Gaps:** Hardcoded `"GF Lo"` / `"GF Hi"`; diluent steppers use `"O₂"` / `"He"` not localized keys; no PDF export from input screen; no planner safety-ack toggle (OC parity).

### Results (`CCRPlanResultView.swift`)

Summary, tissue analytics link, CNS/OTU, PPO2/PPN2/END/density timelines, schedule, bailout heuristic disclaimer (`ccr.bailout.heuristic_disclaimer`), reference estimate banner.

### Integration

| Surface | Status |
|---------|--------|
| Checklist export | **Yes** — `CCRChecklistExportSheet`, `CCRChecklistExportCoordinator` (post `7fd3891` remediation) |
| Checklist import | **No** |
| PDF | `CCRPlannerPDFBuilder` — result toolbar when `canExportCCRPlan` |
| Logbook / Manual Dive | CCR metadata fields when applicable |
| Ratio Deco | Correctly blocked in CCR mode |

### CCR scores

| Metric | Score |
|--------|-------|
| CCR UX readiness | **84%** |
| CCR safety-copy readiness | **93%** |
| CCR planner-result readiness | **86%** |
| CCR release-readiness (UX only) | **82%** (blocked on physical QA + a11y) |
| CCR MOD / setpoint UX | **88%** |

---

## H. Accessibility Analysis

### Strengths

- Watch Live: depth, TTV, runtime, stopwatch, gauge, simulation badges — broad labels.
- iOS OC `PlannerView` / `PlanResultView`: ~32+ accessibility annotations; CNS/OTU warnings combined.
- Tissue analytics: `UIUXAccessibilitySummaries` for compartments, trend, narcosis.
- Ratio Deco overlay chart summary.
- Static test enforcement: `WatchMainUILocalizationTests`, `UIUXRemediationV2WatchTests`, `WatchLocalizationStaticSweepTests`.

### Gaps (priority)

| Area | Severity | Issue |
|------|----------|-------|
| CCR result charts | HIGH | No VoiceOver summaries for PPO2/END/PPN2 timelines |
| `WatchPhotoTransferPanel` | HIGH | Zero accessibility labels |
| Equipment checklist toggles | MEDIUM | No per-item labels |
| Tissue tab selector | MEDIUM | Missing `isSelected` trait on tabs |
| Watch `hapticsOffBadge` | LOW | Visual only |
| Legal acceptance toggles | LOW | Custom buttons — checkbox trait unclear |
| Underwater nav toast | LOW | Not explicitly labeled for VO |

**Accessibility readiness:** **79%**

---

## I. Localization Analysis

### Strengths

- `en.lproj` / `it.lproj` for Watch and iOS (~1,500+ keys).
- `DIRIOSAppLanguage` / `DIRAppLanguage` — system / en / it with locale injection.
- CCR namespace well-keyed (`ccr.*`, `planner.mode.ccr.*`, `gas.role.ccr_*`).
- Legal disclaimer external `LegalDisclaimer.txt` per language.

### Gaps

| Issue | Examples |
|-------|----------|
| Italian strings used as lookup keys | `Sync impostazioni`, `Spazio libero`, GPS status in Settings/Info |
| Hardcoded non-keyed UI | `AscentRateSettingsView`: `LIMITI PERSONALIZZATI`, `RESET STD` |
| Italian key in EN file | `"Calcola Piano" = "Calculate Plan"` |
| CCR GF labels | `"GF Lo"` / `"GF Hi"` hardcoded in view |
| Sync queue strings | `%lld in attesa ack` pattern in EN catalog |
| Date formatters | Fixed `dd/MM/yyyy` on Watch log |
| Siri phrases | English-only in `ActionButtonIntents.swift` |
| Default fallback language | Italian when system unsupported |

**Localization readiness:** **81%**

---

## J. Error / Empty State Analysis

| Surface | Empty state | Error handling | Grade |
|---------|-------------|----------------|-------|
| Watch logbook | Yes + export hint | Load error banner (no retry) | B+ |
| Watch images | Yes + iPhone direction | Delete failure banner | A- |
| Watch reminders | Yes | Editor validation messages | A |
| iOS logbook | Search empty | Delete confirm | A |
| iOS cloud sync | N/A | Decode error + retry copy | A |
| iOS watch sync | Status text | Conflict cards, queue clear | B+ |
| Planner calculate | MOD warnings block | Clear validation cards | A |
| CCR calculate | Stays on input if invalid | Validation card | A |

**Gas Role UX:** **88%** (localized roles; CCR diluent/bailout distinct in checklist/PDF; diluent not confused with OC consumption in export policy docs).

**Image Transfer UX:** **82%** | **Watch Inventory UX:** **84%** | **Image Delete UX:** **86%**

---

## K. Readiness Matrix

| Domain | Watch | iOS | Combined | Blocker tier |
|--------|-------|-----|----------|--------------|
| Navigation / IA | 90% | 92% | 91% | — |
| Live / safety UX | 88% | N/A | 88% | P2 layout density |
| Planner Base/Deco/Tech | N/A | 91% | 91% | — |
| CCR | N/A | 84% | 84% | P1 a11y, P2 import parity |
| Ratio Deco | N/A | 90% | 90% | — |
| Tissue / Narcosis | N/A | 91% | 91% | — |
| Checklist | N/A | 87% | 87% | P2 CCR import |
| PDF / Share | 86% | 90% | 88% | — |
| Image transfer | 83% | 82% | 82% | P1 iOS a11y |
| Watch sync / Cloud | 88% | 84% | 86% | P1 localization |
| Accessibility | 85% | 76% | 79% | P1 targeted passes |
| Localization | 82% | 81% | 81% | P1 ascent settings |
| Legal / disclaimers | 92% | 90% | 91% | — |
| Branding / icons | 88% | 88% | 88% | P3 reference PNGs |
| Physical QA evidence | **PENDING** | **PENDING** | **PENDING** | P0 external |
| App Store assets | **PENDING** | **PENDING** | **PENDING** | P0 external |

---

## L. Issue Matrix

| ID | Sev | Pri | Platform | Feature | Screen / file | Issue | User impact | Safety | A11y | Proposed fix | Effort | Risk | Acceptance |
|----|-----|-----|----------|---------|---------------|-------|-------------|--------|------|--------------|--------|------|------------|
| UX-001 | HIGH | P0 | Both | Release gate | `Docs/QA_EVIDENCE/*` | Physical Watch Ultra QA not attached | Cannot claim underwater validation | HIGH | — | Execute `WATCH_ULTRA_PHYSICAL_QA_MATRIX.md`; attach evidence | External | Low | Evidence README populated; no PASS without files |
| UX-002 | HIGH | P0 | Both | Release gate | `Docs/QA_EVIDENCE/*` | Two-device sync / iCloud QA **PENDING** | Store claims blocked | MED | — | Execute `ICLOUD_TWO_DEVICE_QA_MATRIX.md`, `WATCH_IOS_SYNC_QA_MATRIX.md` | External | Low | Signed evidence pack |
| UX-003 | HIGH | P1 | Watch | Localization | `AscentRateSettingsView.swift` | `LIMITI PERSONALIZZATI`, `RESET STD` not in `Localizable.strings` | EN users see Italian | LOW | MED | Add keys to EN/IT; replace literals | S | Low | EN locale shows English |
| UX-004 | HIGH | P1 | iOS | Accessibility | `WatchPhotoTransferPanel.swift` | No accessibility labels | VO users cannot use photo transfer | LOW | HIGH | Label picker, send, manage actions | S | Low | VoiceOver navigates panel |
| UX-005 | HIGH | P1 | iOS | CCR | `CCRPlanResultView.swift` | Chart timelines lack a11y summaries | VO users miss CCR analytics | MED | HIGH | Reuse `UIUXAccessibilitySummaries` pattern | M | Low | VO reads chart summaries |
| UX-006 | MED | P1 | iOS | Watch sync | `WatchSyncService.swift`, strings | Mixed IT-as-key sync status | Confusing EN UX | LOW | MED | Normalize to semantic keys | M | Low | EN file has English values |
| UX-007 | MED | P2 | iOS | CCR | `CCRPlannerView` | No checklist import (OC has) | Extra manual entry | LOW | — | Add CCR-aware import or document intentional omission | M | Med | Parity or explicit UX copy |
| UX-008 | MED | P2 | Watch | Reminders | `DiveReminderOverlayView` | No manual dismiss | Missed message if overlay timing short | LOW | MED | Optional tap-to-dismiss | S | Low | User can dismiss |
| UX-009 | MED | P2 | Watch | Live | `DiveLiveView` | Multi-banner scroll density on 40mm | Critical controls below fold | MED | — | Further collapse/pin depth hero | M | Med | 40mm sim: depth visible without scroll |
| UX-010 | MED | P2 | iOS | Sync UX | `MoreView` / tab bar | No conflict badge on tab | Silent sync issues | LOW | — | Badge when `conflicts.count > 0` | S | Low | Badge visible |
| UX-011 | LOW | P3 | Watch | Images | `UserImagesView` | No swipe between images | Awkward multi-image review | — | MED | Add horizontal paging | M | Low | Swipe changes image |
| UX-012 | LOW | P3 | Watch | Logbook | `DiveLogListView` | Fixed `dd/MM/yyyy` dates | Locale mismatch | — | LOW | Use `DateFormatter` with locale | S | Low | US locale shows localized date |
| UX-013 | LOW | P3 | Both | Reference UI | `Docs/ReferenceUI/` | PNG baselines missing | App Store visual gate blocked | — | — | Capture sim screenshots per README | External | Low | PNGs committed |
| UX-014 | MED | P1 | iOS | CCR | `CCRPlannerView.swift` | Hardcoded GF Lo/Hi, O₂/He steppers | IT/EN inconsistency | LOW | MED | Localize keys | S | Low | Strings in both catalogs |
| UX-015 | LOW | P3 | Watch | Shortcuts | `SettingsView` help | `"SHORTCUT"` hardcoded title | Minor EN/IT gap | — | LOW | Localize key | S | Low | Localized title |

---

## M. Prioritized Action Plan

### P0 — must fix before compile/use

No compile blockers. P0 items are **external evidence**, not code defects.

1. Execute Watch Ultra physical QA matrix; attach evidence to `Docs/QA_EVIDENCE/WATCH_ULTRA/`.
2. Execute paired Watch↔iOS sync QA; attach to `Docs/QA_EVIDENCE/WATCH_IOS_SYNC/`.
3. Execute iCloud two-device QA per matrix (**PENDING**).

### P1 — must fix before internal TestFlight polish / external TestFlight

1. **UX-003** — Localize ascent rate settings strings (Watch).
2. **UX-004** — Watch photo transfer accessibility (iOS).
3. **UX-005** — CCR chart VoiceOver summaries (iOS).
4. **UX-006** — Normalize sync status localization (iOS + Watch strings).
5. **UX-014** — CCR GF/gas stepper localization.

### P2 — must fix before external TestFlight

1. **UX-007** — CCR checklist import parity or explicit UX messaging.
2. **UX-008** — Reminder overlay dismiss option.
3. **UX-009** — Live layout density on smallest watch.
4. **UX-010** — Sync conflict tab indicator.
5. Dynamic Type / VoiceOver QA matrix execution (**PENDING** — `IOS_DYNAMIC_TYPE_VOICEOVER_QA_MATRIX.md`).

### P3 — must fix before App Store

1. **UX-013** — Capture and commit reference UI PNGs.
2. Complete `IOS_APP_STORE_ALGORITHM_MARKETING_REVIEW_CHECKLIST.md`.
3. **UX-011**, **UX-012**, **UX-015** — polish items.
4. Subsurface CSV external validation (**PENDING** — `CSV_SUBSURFACE_QA_MATRIX.md`).

### P4 — post-release improvements

- In-flow planner mode switcher (power users).
- CCR input-level PDF export.
- Reduce disclaimer layer perceived repetition (UX research).
- `PlannerView.swift` decomposition for maintainability.

---

## N. TestFlight UX Checklist

| Item | Internal TF | External TF |
|------|-------------|-------------|
| Legal onboarding completable EN/IT | ✅ | ✅ |
| Companion disclaimer dismissible | ✅ | ✅ |
| Watch Live dive usable (sim) | ✅ | ⚠️ physical required |
| iOS Planner Base/Deco/Tech reachable | ✅ | ✅ |
| CCR mode reachable with disclaimers | ✅ | ✅ |
| CCR checklist export works | ✅ | ✅ |
| Ratio Deco heuristic labeled | ✅ | ✅ |
| Tissue/narcosis analytics reachable | ✅ | ✅ |
| Watch↔iOS sync UI surfaces errors | ✅ | ⚠️ paired QA **PENDING** |
| iCloud opt-in/copy truthful | ✅ | ⚠️ two-device QA **PENDING** |
| Demo logbook labeled | ✅ | ✅ |
| No certification overclaims in UI | ✅ | ✅ |
| Localization P1 leaks fixed | ❌ | ❌ |
| CCR a11y P1 fixed | ❌ | ❌ |
| Physical Ultra QA evidence | **PENDING** | **PENDING** |
| Mock fallback banner screenshot | **PENDING** | **PENDING** |

---

## O. App Store UX Checklist

| Item | Status |
|------|--------|
| `APP_STORE_RELEASE_GATE_CHECKLIST.md` reviewed | Doc exists |
| TestFlight gate passed | **BLOCKED** on physical QA |
| Canonical screenshots (not AI-generated) | **PENDING** — no PNGs in `Docs/ReferenceUI/` |
| Localized store listing EN/IT | **PENDING** (process) |
| Privacy nutrition labels aligned | Doc in `SECURITY_PRIVACY_RELEASE_EVIDENCE.md` — evidence **PENDING** |
| Algorithm marketing review checklist | `IOS_APP_STORE_ALGORITHM_MARKETING_REVIEW_CHECKLIST.md` — **PENDING** |
| CCR/rebreather store copy non-certified | Policy docs exist; store copy not verified |
| Watch "not a dive computer" in review notes | `TESTFLIGHT_REVIEW_NOTES.md` / `APP_STORE_REVIEW_NOTES.md` exist |
| Accessibility App Store declaration | Requires P1 fixes + matrix QA **PENDING** |
| Entitlements / capabilities review | External process |

---

## P. Screenshot / Marketing Asset Checklist

| Asset | Status | Notes |
|-------|--------|-------|
| `Watch_LIVE_reference.png` | **Missing** | Capture 41/45/49 mm per `Docs/ReferenceUI/README.md` |
| `iOS_Companion_reference.png` | **Missing** | Planner, Logbook, More |
| `ascent_warning_inline_reference.png` | **Missing** | Safety UX baseline |
| App Store screenshot set (6.7", 6.1", Watch) | **PENDING** | No fabricated images |
| Preview video | **PENDING** | Optional |
| CCR planner screenshot for store | **PENDING** | Must include disclaimer visible |
| Localized IT screenshot variants | **PENDING** | |

---

## Q. Final Verdict

### Is the UI/UX ready for internal TestFlight?

**Yes, conditionally.** Both MAIN apps build, core flows are reachable, safety disclaimers are layered, and planner/CCR/Watch live UX is coherent for informed internal testers. Document P1 localization/a11y caveats in TestFlight release notes.

### Is the UI/UX ready for external TestFlight?

**No.** External gate requires physical Watch Ultra QA evidence, paired sync validation, P1 localization fixes (ascent settings, sync strings), CCR/watch-photo accessibility pass, and Dynamic Type/VoiceOver matrix execution — all currently **PENDING** or incomplete.

### Is the UI/UX ready for App Store?

**No.** In addition to external TestFlight blockers: reference UI PNGs missing, marketing/screenshot assets not captured, App Store privacy evidence pack incomplete, Subsurface external validation **PENDING**. UI does not claim certification; store-facing copy must be reviewed before submission.

### What blocks 100% UX readiness?

1. External physical QA (Watch Ultra underwater, mock banner evidence).
2. External paired-device QA (sync, iCloud, image transfer ACK).
3. Localization hygiene (ascent settings, sync diagnostics, CCR steppers).
4. Accessibility parity on CCR charts and watch photo transfer.
5. Reference screenshots and App Store marketing asset pipeline.
6. Subsurface CSV external validation and accessibility matrix sign-off.

### What must be fixed first?

1. **Execute physical QA matrices** and attach evidence (non-code, release-blocking).
2. **UX-003** — Watch ascent settings localization (quick win, high visibility).
3. **UX-004 / UX-005** — iOS accessibility on watch photos and CCR results.
4. **UX-006** — Sync string normalization across EN/IT catalogs.

---

## Phase Output Summary (command phases 2–16)

| Phase | Output metric | Score |
|-------|---------------|-------|
| 2 Planner Base | Base UX | 90% |
| 2 Planner Deco | Deco UX | 92% |
| 2 Planner Technical | Technical UX | 93% |
| 2 Planner overall | Planner mode UX | 91% |
| 3 CCR | CCR UX / safety / results / release | 84% / 93% / 86% / 82% |
| 4 MOD/PPO2 | MOD/PPO2 / Dalton / switch / CCR setpoint | 92% / 90% / 91% / 88% |
| 5 Ratio Deco | Ratio Deco UX | 90% |
| 6 Tissue | Tissue / CCR tissue | 91% / 89% |
| 7 Narcosis | Narcosis / CCR narcosis | 90% / 88% |
| 8 Gas roles | Gas role / CCR gas role | 88% / 87% |
| 9 Checklist | Checklist / sync / CCR checklist | 87% / 86% / 85% |
| 10 PDF/Share | PDF / CCR PDF / export | 90% / 88% / 90% |
| 11 Images | Transfer / inventory / delete | 82% / 84% / 86% |
| 12 Dive start | Dive start UX | 91% |
| 13 Reminders | Reminder UX | 85% |
| 14 Mission Mode | Mission Mode UX | 92% |
| 15 Sensor Source | Sensor Source UX | 90% |
| 16 Branding | Branding UX | 88% |

---

## Audit Limitations

| Limitation | Reason | Next step |
|------------|--------|-----------|
| No simulator visual walkthrough in this audit | Static code + string analysis; builds only | Run manual sim pass per `MAIN_UI_TEXT_QA_CHECKLIST.md` |
| Physical underwater behavior | Cannot verify in CI | Watch Ultra physical matrix |
| VoiceOver runtime behavior | Code presence ≠ runtime quality | Execute `IOS_DYNAMIC_TYPE_VOICEOVER_QA_MATRIX.md` |
| App Store Connect assets | Out of repo | Product/marketing capture session |
| Pixel-perfect layout on all watch sizes | Requires device/sim screenshots | Capture ReferenceUI PNGs |

---

## Related Documents

- [`MAIN_UI_UX_READINESS_AUDIT_POST_FIX.md`](MAIN_UI_UX_READINESS_AUDIT_POST_FIX.md) — prior post-fix baseline (2026-05-31)
- [`IOS_MAIN_COMPLETE_ALGORITHM_AUDIT_REMEDIATION_REPORT.md`](IOS_MAIN_COMPLETE_ALGORITHM_AUDIT_REMEDIATION_REPORT.md) — algorithm/CCR remediation @ `7fd3891`
- [`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md)
- [`TESTFLIGHT_RELEASE_GATE_CHECKLIST.md`](TESTFLIGHT_RELEASE_GATE_CHECKLIST.md)
- [`APP_STORE_RELEASE_GATE_CHECKLIST.md`](APP_STORE_RELEASE_GATE_CHECKLIST.md)
- [`CCR_REBREATHER_EXPORT_POLICY.md`](CCR_REBREATHER_EXPORT_POLICY.md)
- [`ReferenceUI/README.md`](ReferenceUI/README.md)

---

*Audit complete. No source code modified. Report path: `Docs/UI_UX_MAIN_AUDIT_CURRENT.md`.*
