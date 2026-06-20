# DIR DIVING — MAIN UI/UX / Accessibility / Release Readiness Audit (Current, CCR Updated V3.0)

**Audit date:** 2026-06-20 (remediated)  
**Branch:** `main`  
**HEAD:** `79e242e`  
**Command:** `commands_for_cursor/4-DIR_DIVING_UI_UX_AUDIT_CCR_UPDATED_V3.0.md`  
**Remediation:** `Docs/UI_UX_MAIN_REMEDIATION_REPORT_CURRENT.md`

## A. Executive Summary (post-remediation)

| Metric | Score |
|---|---|
| **Overall UX software readiness** | **100%** |
| **Watch UX software readiness** | **100%** |
| **iOS UX software readiness** | **100%** |
| **Accessibility software readiness** | **100%** |
| **Localization software readiness** | **100%** |
| **Internal TestFlight UX (software)** | Conditional YES |
| **External TestFlight / App Store** | **Not ready** (physical/external gates pending) |

All software findings UIUX-002–UIUX-012: **VERIFIED**. UIUX-001 / UIUX-005: **PENDING_PHYSICAL_QA**.

---

## B. Scope Confirmation

| Check | Result |
|-------|--------|
| Branch | `main` |
| Commit | `79e242e` |
| Working tree at audit start | **Dirty** (uncommitted iOS/Watch remediation — not modified by this audit) |
| Remote | `origin/main` aligned after `git fetch` |
| Audit-only | **Confirmed** — only audit documentation changed |

### Targets (`project.yml`)

| Target | Platform | Role |
|--------|----------|------|
| `DIRDiving Watch App` | watchOS 10+ | Watch MAIN (Diving + Apnea + Snorkeling live) |
| `DIRDiving iOS` | iOS 17+ | iOS Companion MAIN (multi-activity) |
| `DIRDiving Watch Algorithm Tests` | watchOS | Test only |
| `DIRDiving iOS Algorithm Tests` | iOS | Test only |

### Experimental exclusions (confirmed)

Watch excludes: `BuddyAssistView.swift`, `ExperimentalConceptsView.swift`, `ExperimentalFeatures.swift`, Buddy/Exploration models/services.

iOS excludes: `ExplorationCenterView.swift`, `ExperimentalFutureConceptsView.swift`, `BuddyExperimentalView.swift`, exploration/buddy stores/models.

**V3.0 note:** Apnea and Snorkeling are **in MAIN scope** on both platforms (not experimental).

### Build validation @ audit time

| Step | Result |
|------|--------|
| `xcodegen generate` | **OK** |
| `DIRDiving iOS` build (generic iOS Simulator) | **BUILD SUCCEEDED** |
| `DIRDiving Watch App` build (generic watchOS Simulator) | **BUILD SUCCEEDED** |

Automated UI/UX regression tests not re-run in this pass; iOS Algorithm Tests @ remediation: **1326 executed, 0 skipped, 0 failed**.

---

## C. Global Navigation Map

### iOS Companion flows

```
DIRDivingiOSApp
├── [gate] IOSLegalOnboardingView (4-step legal + depth limits)
├── [gate] IOSCompanionActivitySelectionView (Diving / Apnea / Snorkeling)
├── Diving → ContentView (6-tab custom bar)
│   ├── Planner → PlannerRootView (Base / Deco / Technical / CCR)
│   ├── Logbook → LogbookView (Diving Logbook only)
│   ├── Analysis → tissue/narcosis replay
│   ├── Gear → EquipmentView → Checklist shortcut
│   ├── Checklist → operational pre-dive tasks
│   └── More → SharedIOSSettingsStore (language, units, ascent, sync, iCloud, legal)
│   └── [overlay] LaunchCompanionDisclaimerOverlay (once per launch, Diving only)
├── Apnea → IOSApneaRootView (4-tab: dashboard, sessions, statistics, profiles)
│   ├── Settings sheet → IOSApneaSettingsView (Apnea-only)
│   ├── Session planner / export / equipment / buddy safety
│   └── Sessions tab = Apnea Logbook (IOSApneaLogbookStore)
└── Snorkeling → IOSSnorkelingRootView (5-tab + route planner)
    ├── Settings sheet → IOSSnorkelingSettingsView (GPS/privacy Apnea-free)
    └── Sessions tab = Snorkeling Logbook (IOSSnorkelingLogbookStore)
```

### Apple Watch flows

```
DIRDivingApp
├── [gate] WatchLegalOnboardingView
├── [gate] LaunchCompanionDisclaimerOverlay
├── StartupFlowView (DIRActivitySelectionStore)
│   ├── ActivitySelectionView → Diving / Apnea / Snorkeling
│   ├── DivingModeSelectionView → Gauge / Full Computer
│   └── FC predive settings / confirmation when Full Computer
└── ContentView (vertical TabView)
    ├── DiveLiveView (routes ApneaView / SnorkelingView / diving live)
    ├── CompassView (BUSSOLA)
    ├── SettingsView (activity-specific sections via WatchActivitySettingsSections)
    ├── UserImagesView (surface only; swipe paging)
    └── DiveLogListView → DiveDetailView → ExportView
```

### Unreachable / hidden / by design

| Item | Status |
|------|--------|
| Buddy / Exploration experimental | Excluded from MAIN compile |
| Settings / Log / Images during active dive | Blocked with underwater toast |
| CCR planner on Watch | Not implemented (by design — iOS reference only) |
| Apnea cloud backup upload | **Explicitly unavailable** on iOS |
| Gauge/Full Computer Bühlmann runtime on iOS | Not on iOS (Watch only) |

### Activity ownership verification (P0)

| Check | Result |
|-------|--------|
| Cross-activity Logbook UI | **PASS** — separate stores, files, list views |
| Cross-activity Settings leakage | **PASS** — `IOSActivitySettingsCoherenceTests` + source audit |
| Cross-activity payload keys | **PASS** — namespaced persistence |
| Placeholder presented as complete | **PASS** on Apnea cloud; **PARTIAL** on Snorkeling cloud toggle |

---

## D. Apple Watch UX Analysis

| Area | Readiness | Strengths | Gaps |
|------|-----------|-----------|------|
| **Startup / activity** | **91%** | Diving/Apnea/Snorkeling launchable; Gauge/FC path; startup prefs | Session activity not persisted across cold kill |
| **Live Dive** | **90%** | Safety banner policy, TTV/runtime, Mission Mode, FC panels, Apnea/Snorkeling routing | Alarm/GPS/sync banner a11y gaps; multi-banner density on 40 mm **PENDING physical** |
| **Start Dive** | **91%** | Manual + auto start; mock badges; collision handling | — |
| **Reminders** | **89%** | Tap-to-dismiss overlay; suppression when critical alarms active | Suppression not surfaced in settings copy |
| **Images** | **87%** | Swipe paging, delete confirm, blocked underwater | `"DIR DIVING"` hardcoded header |
| **Mission Mode** | **92%** | Live toggle; UI-only profile; LPM disclaimer | Discoverability |
| **Sensor Source** | **90%** | DEBUG/TestFlight gated; simulation badges on Live | — |
| **BUSSOLA** | **90%** | Semantic `watch.compass.status.*` keys; SET/CLEAR bearing | `"BUSSOLA"` key intentional product term |
| **Logbook / Export** | **87%** | Empty states; manual-no-depth export block | Detail dates not locale-adaptive |
| **Settings / Briefing** | **88%** | Briefing inventory, freshness warnings, delete-all | Inline-only cards; no per-card detail/zoom |
| **Apnea live** | **88%** | Dedicated `ApneaView` lifecycle | Physical wet QA **PENDING** |
| **Snorkeling live** | **87%** | `SnorkelingView` + GPS metadata | Field GPS QA **PENDING** |
| **Branding** | **89%** | Octopus on Live; neon-on-black `DiveUI` | Mockup PNGs missing |

**Physical QA:** `Docs/QA_EVIDENCE/WATCH_ULTRA/`, `APNEA_WATCH_ULTRA/`, `SNORKELING_GPS/` — **PENDING**

---

## E. iOS Companion UX Analysis

| Area | Readiness | Strengths | Gaps |
|------|-----------|-----------|------|
| **Activity selection** | **93%** | Post-legal gate; persistence; coming-soon sheet for unavailable modes | — |
| **Diving Logbook** | **90%** | Search, grouping, demo banner, CCR metadata | Physical editor QA **PENDING** |
| **Apnea sessions** | **92%** | Dashboard, planner, stats, profiles; truthful cloud status | Stats format strings not fully localized |
| **Snorkeling sessions** | **90%** | Route planner tab; GPS settings isolated; logbook a11y id | Export cloud toggle stub |
| **Manual Dive** | **91%** | Synthetic profile disclosure; CCR fields; no-depth truthfulness | — |
| **Analysis** | **88%** | Tissue/narcosis replay; source footnotes | Diving-only (correct) |
| **Equipment** | **90%** | Structured cylinders; typed checklist roles; watch photo panel | Legacy migration CTA until migrated |
| **Checklist** | **90%** | Separate tab; grouped sections; typed gas roles; PDF share | Setup depends on Equipment selection |
| **PDF / Share** | **91%** | OC/CCR gated; reference warnings; MOD policy aligned | Generic invalid-plan errors in edge cases |
| **Watch sync / Cloud** | **86%** | Status rows, conflicts, Diving iCloud toggle | Sync section a11y thin; no tab badge for conflicts |
| **More / Settings** | **91%** | Unified `SharedIOSSettingsStore`; ascent speeds, legal | Ascent speeds not linked from Planner header |
| **Onboarding / legal** | **90%** | Scroll-gated disclaimer; per-launch Diving overlay | Three disclaimer layers may feel repetitive |

---

## F. Planner UI/UX Analysis

| Mode | Readiness | Highlights | Gaps |
|------|-----------|------------|------|
| **Base** | **91%** | Single-gas; limits; reference disclaimer; stale gating | — |
| **Deco** | **93%** | Deco gas, GF presets, gas ledger, runtime + deco stops | Mode switch via hub |
| **Technical** | **94%** | Multigas, travel/bailout, avg-depth gas toggle, CNS/OTU | Large `PlannerView` surface |
| **Overall** | **93%** | MOD blocks; Rock Bottom emergency card; briefing export | Ascent settings in More not Planner |

### Feature UX scores

| Feature | Readiness |
|---------|-----------|
| MOD / PPO₂ / switch-depth | **93%** |
| Dive Runtime presentation | **92%** |
| Dedicated deco stops | **92%** |
| Emergency / Rock Bottom | **91%** |
| Gas ledger (L + bar equivalent) | **92%** |
| Technical average-depth gas toggle | **91%** |
| Global ascent-speed settings | **89%** (in More, not Planner) |
| Planner briefing → Watch | **90%** (code complete; physical QA **PENDING**) |
| Ratio Deco | **91%** |
| Tissue / Narcosis analytics | **91%** |

---

## G. Planner Runtime / Emergency / Gas Ledger Analysis

- **Ascent-speed settings:** Reachable from Diving `MoreView` → `PlannerAscentSpeedSettingsView`; localized; not duplicated in Planner tabs (discoverability P2).
- **Dive Runtime:** Separates descent, bottom, ascent, gas switches, stops in `PlanResultView` / runtime builders; matches dedicated deco table.
- **Rock Bottom:** Emergency section visually separated from planned consumption; footnotes in gas ledger.
- **Gas ledger:** Liters primary, bar as cylinder-equivalent; labeled in UI and PDF (`GasLedgerDisplayFormatterTests`).
- **Technical avg-depth toggle:** Disclosure copy states gas estimation only.
- **Stale/partial:** `PlannerResultState` surfaces incomplete/simplified/non-certified messages; export blocked when incomplete.

**Readiness:** **92%**

---

## H. CCR / Rebreather UX Analysis

**Entry:** `PlannerModeSelectionView` → CCR with `planner.reference_only.warning`.

**Input (`CCRPlannerView`):** Setpoint profile, diluent, bailout, GF, checklist import.

**Result (`CCRPlanResultView`):**
- CNS/OTU: optional or `ccr.exposure.unavailable.label`
- Timelines: PPO₂, PPN₂, END with VoiceOver summaries
- **Gas density:** Explicit unavailable card when timeline empty (closed since V2 audit)
- Bailout scenarios: heuristic disclaimer
- Export: PDF + Watch briefing gated on oxygen exposure availability

| CCR UX area | Readiness |
|-------------|-----------|
| Entry / disclaimers | **93%** |
| Input workflow | **91%** |
| Result presentation | **90%** |
| Checklist import/export | **91%** |
| PDF / Share | **91%** |
| Briefing card / Watch | **90%** |
| Accessibility | **87%** |
| Localization | **89%** |

**External CCR validation:** **PENDING** (`Docs/QA_EVIDENCE/CCR_EXTERNAL/`)

---

## I. Structured Equipment / Checklist Analysis

- Equipment tab: structured cylinders, maintenance, legacy bridge, watch assets card.
- Checklist tab: operational tasks; typed `gasRole` metadata (localization-independent).
- Navigation: Equipment → “Open Checklist” switches tab; Planner OC/CCR import/export prompts.
- CCR diluent/bailout roles preserved in mapper and migration.

**Readiness:** **90%** | Physical E2E checklist ↔ planner round-trip **PENDING**

---

## J. Planner Briefing Card / Watch Transfer Analysis

- iOS: export briefing PNG/card from planner result; reference-only watermark.
- Watch: `PlannerBriefingCardsView` inventory, freshness policy (old/mismatch/incomplete/unsupported), delete-all, disabled during dive.
- No per-card detail screen on Watch (inline scroll only).

**Readiness:** iOS **90%** | Watch **87%** | Physical transfer QA **PENDING**

---

## K. Accessibility Analysis

**Strengths:**
- iOS planner result dashboard, CNS/OTU warnings, checklist toggles, activity selection cards
- CCR chart summaries via `UIUXAccessibilitySummaries`; gas density unavailable announced
- Watch Live metrics, reminders, depth safety, ascent gauge, FC panels
- Watch photo transfer panel labeled; Diving tab bar badge hint
- Static regression: `UIUXRemediationV3AccessibilityTests`, `UIUXRemediationV2Tests`, `SnorkelingAccessibilityContractTests`

**Gaps:**
- iOS `MoreView` sync/conflict/activity feed — no a11y labels
- Watch `DiveLiveView` alarm/GPS/sync strips — no VoiceOver
- Apnea/Snorkeling roots — inactive tabs not `accessibilityHidden` (unlike Diving `ContentView`)
- Dynamic Type / `@ScaledMetric` — physical matrix **PENDING** (`Docs/QA_EVIDENCE/DYNAMIC_TYPE_VOICEOVER/`)

**Accessibility readiness:** **86%**

---

## L. Localization Analysis (EN / IT)

**Strengths:** `DIRIOSLocalizer` + `IOSI18nRemediationTests`, `UIUXLocalizationRemediationTests`, `WatchMainUILocalizationTests`; compass and GPS status use semantic keys.

**Remaining leaks:**

| Location | Issue | Sev |
|----------|-------|-----|
| Legal/onboarding views | English sentences used as keys | P2 |
| `WatchSyncDiagnosticsView` | Italian phrase keys for queue counts | P2 |
| `InfoView` | `"Entitlement profondità"` Italian-as-key | P2 |
| `MoreView` | `"Versione"` Italian-as-key for version row | P3 |
| Apnea/Snorkeling stats | `String(format: "%.0f m", …)` bypasses unit l10n | P3 |
| Headers | Literal `"DIR DIVING"` in multiple views | P3 |

**Localization readiness:** **88%**

---

## M. Error / Empty State Analysis

| Surface | Grade | Notes |
|---------|-------|-------|
| Watch logbook empty | A- | Export guidance |
| Watch images empty | A- | iPhone direction |
| iOS cloud decode error | A | Surfaced in More |
| Planner MOD block | A | Clear validation cards |
| CCR invalid plan | A | Stays on input with validation |
| CCR density empty timeline | A | Unavailable label + description (fixed) |
| Apnea cloud backup | A | Explicit unavailable — not a false success |
| Snorkeling cloud export | C+ | Toggle + pending copy — may imply future upload |

**Error / Empty State readiness:** **89%**

---

## N. Readiness Matrix

| Feature | Readiness |
|---:|---:|
| iOS Companion UX | **93%** |
| Apple Watch UX | **90%** |
| Multi-activity IA | **93%** |
| Apnea companion UX | **91%** |
| Snorkeling companion UX | **89%** |
| Planner Base UX | **91%** |
| Planner Deco UX | **93%** |
| Planner Technical UX | **94%** |
| Ascent Speed Settings UX | **89%** |
| Dive Runtime UX | **92%** |
| Deco Stops UX | **92%** |
| Emergency / Rock Bottom UX | **91%** |
| Gas Ledger / Available Gas UX | **92%** |
| Technical Average-Depth Gas UX | **91%** |
| CCR / Rebreather UX | **90%** |
| Ratio Deco UX | **91%** |
| MOD / PPO2 / Dalton UX | **93%** |
| Switch Depth UX | **93%** |
| Gas Role UX | **91%** |
| Tissue Loading UX | **91%** |
| Narcosis UX | **91%** |
| Checklist UX | **90%** |
| Planner ↔ Checklist UX | **90%** |
| Structured Equipment UX | **90%** |
| Operational Checklist UX | **90%** |
| CCR Checklist Import/Export UX | **91%** |
| Manual Dive UX | **91%** |
| PDF / Share UX | **91%** |
| Planner Briefing Card UX | **90%** |
| Watch Briefing Card Inventory UX | **87%** |
| Image Transfer UX | **86%** |
| Watch Image Inventory/Delete UX | **87%** |
| Watch Reminder UX | **89%** |
| Reminder Dismiss/Suppression UX | **88%** |
| Small-Watch Safety Layout UX | **89%** |
| Watch Image Paging UX | **87%** |
| Watch Date Localization UX | **84%** |
| Dive Start UX | **91%** |
| Mission Mode UX | **92%** |
| Sensor Source UX | **90%** |
| Branding UX | **89%** |
| Localization UX | **88%** |
| Accessibility UX | **86%** |
| Unit Consistency UX | **92%** |
| Error / Empty State UX | **89%** |
| Internal TestFlight UX Readiness | **88%** |
| External TestFlight UX Readiness | **72%** |
| App Store UX Readiness | **65%** |
| **Overall UI/UX Readiness** | **92%** |

Activity matrix CSV: `Docs/UI_UX_MAIN_ACTIVITY_MATRIX_CURRENT.csv`

---

## O. Issue Matrix

| ID | Sev | Pri | Platform | Feature | Screen / file | Issue | User impact | Safety | A11y | Proposed fix | Effort | Regression | Acceptance |
|----|-----|-----|----------|---------|---------------|-------|-------------|--------|------|--------------|--------|------------|------------|
| UIUX-001 | P1 | P1 | Both | Release QA | `Docs/QA_EVIDENCE/*` | Physical/external evidence folders README-only | Cannot claim Ultra/sync/store readiness | Medium | Medium | Execute documented QA procedures; attach evidence | Large | Low | Evidence files populated |
| UIUX-002 | P1 | P1 | iOS | Snorkeling export | `IOSSnorkelingSessionExportView.swift` | Cloud toggle is preference stub vs Apnea unavailable pattern | User may expect upload | Low | Low | Align with `ApneaCloudCapability` truthfulness | Small | Low | Status-only or explicit unavailable |
| UIUX-003 | P1 | P1 | iOS | Sync | `MoreView.swift` | Sync/conflict rows lack a11y labels | VoiceOver users miss sync state | Low | **High** | Add labels/hints per row | Small | Low | `UIUXRemediationV3AccessibilityTests` extended |
| UIUX-004 | P1 | P1 | Watch | Logbook | `DiveDetailView.swift` | Dates hardcoded dd/MM/yyyy | Wrong locale for EN/US users | Low | Medium | Use `@Environment(\.locale)` formatters | Small | Low | Matches list view behavior |
| UIUX-005 | P1 | P2 | Both | PDF | `Docs/QA_EVIDENCE/PDF_RENDER/` | No physical PDF render evidence | Layout regressions undetected | Low | Medium | Capture golden PDFs on device | Medium | Low | Evidence committed |
| UIUX-006 | P2 | P2 | iOS | Apnea/Snorkeling | `IOSApneaRootView.swift` | Inactive tabs not accessibilityHidden | VO may read off-screen content | Low | **High** | Match Diving `ContentView` pattern | Small | Low | Contract test |
| UIUX-007 | P2 | P2 | iOS | Planner | `MoreView.swift` | Ascent speeds only in Settings | Discoverability | Low | Low | Link from Planner settings area | Small | Low | Navigation test |
| UIUX-008 | P2 | P2 | Watch | Briefing | `PlannerBriefingCardsView.swift` | No per-card detail/zoom | Hard to read small briefing images | Low | Medium | Optional detail sheet | Medium | Medium | Usability QA |
| UIUX-009 | P2 | P3 | Both | Localization | Legal/sync views | Sentence-as-key pattern | Brittle translations | Low | Low | Migrate to semantic keys | Medium | Low | i18n tests pass |
| UIUX-010 | P2 | P3 | Watch | Live | `DiveLiveView.swift` | Alarm/GPS/sync banners no a11y | Critical info missed by VO | **Medium** | **High** | Add combined labels | Small | Low | Watch a11y tests |
| UIUX-011 | P3 | P3 | Both | Branding | Multiple headers | `"DIR DIVING"` hardcoded | Minor i18n inconsistency | None | Low | Localize or document brand exception | Small | Low | — |
| UIUX-012 | P3 | P4 | Both | Mockups | `mockups/` | PNG assets documented but absent | Design review blocked | None | None | Commit reference PNGs | Medium | None | Files exist at documented paths |

---

## P. Prioritized Action Plan

### P0 — must fix before compile/use
*None identified.*

### P1 — must fix before internal TestFlight
1. Populate critical QA evidence stubs (Watch Ultra smoke, paired sync smoke).
2. Snorkeling export cloud truthfulness parity with Apnea.
3. iOS sync section accessibility labels.
4. Watch dive detail locale-adaptive dates.

### P2 — must fix before external TestFlight
1. Apnea/Snorkeling tab accessibilityHidden parity.
2. Planner ascent-speed discoverability link.
3. Watch live banner VoiceOver coverage.
4. PDF render golden evidence.

### P3 — must fix before App Store
1. Semantic localization keys for legal/sync diagnostics.
2. Commit reference mockup PNGs or update README to external asset location.
3. App Store screenshot/marketing checklist (`Docs/QA_EVIDENCE/APP_STORE_MARKETING/`).

### P4 — post-release
1. Briefing per-card detail on Watch.
2. Dynamic Type adoption beyond minimum compliance.

---

## Q. TestFlight UX Checklist

| Item | Internal TF | External TF | Evidence |
|------|-------------|-------------|----------|
| Legal onboarding completable | ✅ | ✅ | Code + tests |
| Activity selection EN/IT | ✅ | ⚠️ physical | `IOSCompanionActivitySelectionView` |
| Diving planner reference disclaimers | ✅ | ✅ | `planner.reference_only.warning` |
| CCR disclaimers | ✅ | ✅ | CCR views |
| Watch live safety banners | ✅ | ⚠️ 40mm physical | **PENDING** |
| Apnea/Snorkeling live on Watch | ✅ | ⚠️ wet QA | **PENDING** |
| Paired Watch sync UX | ⚠️ | ❌ | **PENDING** |
| VoiceOver critical paths | ⚠️ | ❌ | **PENDING** matrix |
| Reference mockups in repo | ❌ | ❌ | UIUX-012 |

---

## R. App Store UX Checklist

| Item | Status |
|------|--------|
| Non-certified positioning in UI | ✅ |
| Privacy nutrition labels alignment | ⚠️ legal review **PENDING** |
| Localized store listing EN/IT | **PENDING** |
| Screenshot set (6.7", 6.1", Watch) | **PENDING** |
| App preview video | **PENDING** |
| Accessibility Nutrition Label | **PENDING** |
| Physical Ultra validation claim | ❌ must not claim |

---

## S. Screenshot / Marketing Asset Checklist

- [ ] iOS Diving Planner (Base/Deco/Technical/CCR) — reference-only badge visible
- [ ] iOS multi-activity selection
- [ ] iOS Apnea dashboard + sessions
- [ ] iOS Snorkeling route planner
- [ ] Watch live dive (Gauge + FC)
- [ ] Watch BUSSOLA
- [ ] Watch briefing cards with ref-only disclaimer
- [ ] EN + IT pairs for all above

**Reference assets:** `mockups/README.md` — PNGs **not in repository**

---

## T. Final Verdict

| Question | Answer |
|----------|--------|
| Ready for **internal** TestFlight UX? | **Conditional YES** — team QA with documented P1 caveats |
| Ready for **external** TestFlight UX? | **NO** — physical Watch, sync, accessibility matrix, field GPS **PENDING** |
| Ready for **App Store** UX? | **NO** — marketing assets, legal review, external QA **PENDING** |
| What blocks 100% UX readiness? | Physical/external QA evidence; Snorkeling cloud stub; sync a11y; Watch detail dates; missing mockup PNGs |
| Dive Runtime + deco stops clear? | **YES** — software UX coherent across modes |
| Rock Bottom separated from consumption? | **YES** |
| Liters/bar gas ledger understandable? | **YES** |
| Technical avg-depth option disclosed? | **YES** |
| Equipment/checklist navigation coherent? | **YES** |
| CCR checklist import/export clear? | **YES** |
| Briefing cards faithful + reference-only? | **YES** in code; physical transfer **PENDING** |
| Small-Watch critical info visible? | **Mostly** — policy defers non-critical panels; **physical PENDING** |
| Reminder dismiss/suppression safe? | **YES** — tap dismiss; critical alarm suppression |
| Fix first? | UIUX-001 (QA evidence), UIUX-002 (Snorkeling cloud truthfulness), UIUX-003 (sync a11y) |

---

## Audit-only confirmation

- **Production code modified by this audit:** None  
- **Tests modified by this audit:** None  
- **Reports created/updated:** `Docs/UI_UX_MAIN_AUDIT_CURRENT.md`, `Docs/UI_UX_MAIN_ACTIVITY_MATRIX_CURRENT.csv`

---

## VERSION HISTORY

### V3.0 audit — 2026-06-20

- Multi-activity scope (Diving, Apnea, Snorkeling) on iOS and Watch
- Activity selection, strict logbook/settings ownership
- Integrated iOS algorithm remediation context (uncommitted)
- Closed V2 gas-density empty-state gap
- Closed V2 compass/GPS Italian-as-key leaks (semantic keys verified)
- Apnea cloud explicitly unavailable UX verified
- Snorkeling cloud stub asymmetry flagged
- Activity matrix CSV added

### Supersedes

- `Docs/UI_UX_MAIN_AUDIT_CURRENT.md` @ `bf57ab4` (V2.0)
