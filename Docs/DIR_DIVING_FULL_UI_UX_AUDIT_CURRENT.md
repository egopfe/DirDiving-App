# DIR DIVING — Full UI/UX Audit (CURRENT)

**Date:** 2026-06-02  
**Branch / baseline:** `main` @ `bea4f74`  
**Mode:** Static code inspection + selective build validation — **report only**  
**Scope:** Apple Watch MAIN + iOS Companion MAIN (no experimental targets)

---

## 1. Executive summary

| Platform | UI/UX readiness | Assessment |
|----------|-----------------|------------|
| **Apple Watch** | **79%** | Premium in-water dashboard, compass, and warning hierarchy are strong. Settings and sync diagnostics remain dense; micro-typography and banner stacking are the main polish risks. |
| **iOS Companion** | **76%** | Cohesive dark DIR design system, functional tab navigation, and improved Planner result charts/tables. PlanResultView is information-dense; Dynamic Type support is limited; fullscreen/safe-area mitigations exist in code but need device QA confirmation. |

**Ready for broader internal TestFlight?** **Conditional yes** — safe for focused internal testing on Watch live dive + iOS Planner/Logbook, with known P2 readability/density issues documented below. Not ready for external/marketing QA without addressing P1 fullscreen verification on physical iPhones and Planner result scroll depth.

### Top 10 risks

| # | Platform | Priority | Risk |
|---|----------|----------|------|
| 1 | iOS | P1 | Black bands above/below content on iPhone 15 Pro / 17 Pro if UIKit chrome or TabView slot sizing regresses despite `IOSRootShell` mitigations — **needs physical/simulator visual QA** |
| 2 | iOS | P1 | `PlanResultView` stacks many warnings, footnotes, and metric rows — critical outputs (TTS, ascent table, tissue chart) may sit below the fold |
| 3 | iOS | P2 | Bühlmann tissue chart uses `caption2` axis labels and four overlapping series — readability on iPhone 14 width at default text size |
| 4 | iOS | P2 | Limited Dynamic Type scaling (`DIRTypography` fixed sizes; few `@ScaledMetric` uses) |
| 5 | Watch | P2 | `SettingsView` sync/hardware section is long and diagnostic-heavy for a wrist device |
| 6 | Watch | P2 | Active dive can stack sync strip + ascent banner + GPS + alarm + error banners — depth hero may compress |
| 7 | Watch | P2 | Mixed hardcoded Italian strings in Settings sync rows (`Sync impostazioni`, `%lld in attesa ack`) hurt EN consistency |
| 8 | Watch | P2 | Micro text (`9–10 pt`) with aggressive `minimumScaleFactor` (down to `0.42` in live metrics) — larger accessibility text sizes may clip |
| 9 | Shared | P2 | Watch `DiveUI` vs iOS `DIRTheme` are conceptually aligned but not token-linked — drift risk over time |
| 10 | iOS | P3 | Ascent table four columns at `caption`/`caption2` — tight on narrow phones |

### Most urgent fixes (no code applied in this audit)

1. **iOS:** Physical/simulator visual pass for fullscreen background on iPhone 15 Pro + iPhone 17 Pro after `IOSRootShell` / `IOSWindowChromeConfigurator`.
2. **iOS:** Planner result information architecture — elevate TTS + ascent table + tissue chart; collapse secondary tiles.
3. **Watch:** Settings sync section — collapse diagnostics behind a detail screen.
4. **Watch:** Replace hardcoded Italian Settings strings with localized keys.
5. **Both:** Dynamic Type audit pass on Planner result and Watch Settings.

---

## 2. Repository scope

### Targets (`project.yml`)

| Target | Platform | Deployment |
|--------|----------|------------|
| `DIRDiving Watch App` | watchOS | 10.0 |
| `DIRDiving iOS` | iOS | 17.0 |
| `DIRDiving Watch Algorithm Tests` | watchOS | — |
| `DIRDiving iOS Algorithm Tests` | iOS | — |

### Schemes

- `DIRDiving Watch App` (build + Watch algorithm tests)
- `DIRDiving iOS` (build + iOS algorithm tests)
- `DIRDiving Watch Algorithm Tests`
- `DIRDiving iOS Algorithm Tests`

### Watch MAIN sources (compiled)

- `App/`, `Models/` (excl. exploration/buddy models), `Services/` (excl. exploration/buddy), `Views/` (excl. Apnea, Snorkeling, BuddyAssist, ExperimentalConcepts), `Utils/` (excl. ExperimentalFeatures), explicit algorithm/runtime files, `Resources/`

### iOS MAIN sources (compiled)

- Entire `iOSApp/` except: `ExplorationCenterView`, `BuddyExperimentalView`, `ExperimentalFutureConceptsView`, exploration/buddy models & stores

### Experimental / excluded (NOT in MAIN UI audit runtime)

| Area | Excluded files |
|------|----------------|
| Watch | `ApneaView`, `SnorkelingView`, `BuddyAssistView`, `ExperimentalConceptsView`, `ExperimentalFeatures.swift`, buddy/exploration services |
| iOS | `ExplorationCenterView`, `BuddyExperimentalView`, `ExperimentalFutureConceptsView`, exploration/buddy models/stores |

### Stale-file risk

Files under `Views/` and `iOSApp/Views/` that are **excluded in `project.yml` still exist in the repo** — Cursor edits to those paths will **not** ship in MAIN builds. Always verify target membership via `project.yml` before UI work.

### Files inspected (representative)

**Watch:** `ContentView.swift`, `DiveLiveView.swift`, `CompassView.swift`, `SettingsView.swift`, `UserImagesView.swift`, `DiveLogListView.swift`, `DiveDetailView.swift`, `ExportView.swift`, `InfoView.swift`, `DeveloperSettingsView.swift`, `AlarmSettingsView.swift`, `AscentRateSettingsView.swift`, `WatchLegalOnboardingView.swift`, `AscentGaugeView.swift`, `AscentWarningBannerView.swift`, `DepthSafetyLiveViews.swift`, `MissionModeIndicatorView.swift`, `DiveUIComponents.swift`, `ModeSelectionView.swift`

**iOS:** `DIRDivingiOSApp.swift`, `ContentView.swift`, `PlannerView.swift` / `PlanResultView`, `LogbookView.swift`, `DiveDetailView.swift`, `AnalysisView.swift`, `EquipmentView.swift`, `MoreView.swift`, `IOSLegalOnboardingView.swift`, `ManualDiveEditorView.swift`, `DIRTheme.swift`, `DIRBackground.swift`, `DIRTypography.swift`, `IOSWindowChromeConfigurator.swift`, `IOSCompanionAdaptiveLayout.swift`, component files (`DIRCard`, `DIRMetricTile`, `DIRWarningBox`, etc.)

**Config:** `project.yml`

---

## 3. Apple Watch detailed audit

### 3.1 ContentView / navigation shell

| Aspect | Status | Findings |
|--------|--------|----------|
| UX | Good | Vertical `TabView`; active dive locks to Live + Compass; toast on blocked navigation |
| UI | Good | Crown hint overlay on pre-dive Live; companion disclaimer gate |
| Typography | P3 | Toast uses `10 pt black` — acceptable for transient message |
| Navigation | Good | `AppNavigationStore` clamps pages; auto-return to Live on dive start |
| Accessibility | P2 | Toast lacks explicit `accessibilityAnnouncement` |
| Severity | P2 | — |
| Fix | Add accessibility announcement for underwater navigation block |
| Effort | S | `Views/ContentView.swift` |
| Files | `ContentView.swift`, `AppNavigationStore` |

### 3.2 DiveLiveView (live dive dashboard)

| Aspect | Status | Findings |
|--------|--------|----------|
| UX | Strong | Depth hero dominant; TTV/Runtime panel; ascent gauge; Mission Mode control; pre-dive waiting state |
| UI | Good | Black canvas, neon panels, `DiveScreenBackground`, geometry-based gauge width |
| Typography | P2 | Hero depth uses `metricValueHero` (72 pt); secondary labels can scale to `0.42` — risk at AX text sizes |
| Layout | P2 | Multiple banners (sync, GPS, alarm, error) can stack and compress hero on smaller watches |
| Navigation | Good | In-place controls; stopwatch confirmation dialog |
| Accessibility | Good | Depth, TTV, stopwatch controls labeled; TTV hint clarifies non-deco semantics |
| Severity | P2 | Banner stacking |
| Fix | Collapse non-critical banners; cap concurrent warning height |
| Effort | M | `DiveLiveView.swift`, `AscentWarningBannerView.swift` |
| Files | `DiveLiveView.swift`, `DepthSafetyLiveViews.swift`, `AscentGaugeView.swift` |

### 3.3 CompassView

| Aspect | Status | Findings |
|--------|--------|----------|
| UX | Strong | Fixed pointer + rotating dial; bearing set/clear; in-dive depth/runtime panel |
| UI | Good | 148 pt dial, cardinal colors (N red), delta readout |
| Typography | Good | Heading `36 pt black`; cardinals `13–18 pt` |
| Navigation | Good | Self-contained; Mission Mode disables animations when active |
| Accessibility | Good | `BUSSOLA` label + heading value; bearing buttons labeled |
| Cardinal fix | **Present** | Dial uses `.rotationEffect(.degrees(-compass.headingDegrees))`; N/E/S/W markers rotate with ring — **correct fixed-pointer model** |
| Severity | P3 | Bearing delta text `10 pt` |
| Fix | Optional bump to `11 pt` for Ultra readability |
| Effort | S | `CompassView.swift` |
| Files | `CompassView.swift`, `CompassManager` |

### 3.4 SettingsView

| Aspect | Status | Findings |
|--------|--------|----------|
| UX | Partial | Section headers (`WatchSettingsSectionHeader`) improve scan; still long scroll |
| UI | Good | Row min heights 44/40/48 pt; chevrons; informational icons |
| Typography | Good | `DiveUI.Typography` hierarchy applied |
| Layout | P2 | Sync queue/sent/ack rows + activity panel + Mission Mode + Developer — high row count |
| Navigation | Good | Sub-screens for ascent, alarms, legal, developer, info |
| Accessibility | Partial | Export logbook labeled; Mission Mode toggle labeled; many status rows rely on visual icon color |
| Severity | P2 | Density + mixed localization |
| Fix | Move sync diagnostics to nested “Sync details”; localize hardcoded IT strings |
| Effort | M | `SettingsView.swift`, `Resources/*.lproj` |
| Files | `SettingsView.swift`, `DiveUIComponents.swift` |

**Hardcoded strings observed (P2):** `"Sync impostazioni"`, `"%lld in attesa ack"`, `"%lld inviati o in transito"`, `"%lld confermati da iPhone"`, `"%lld falliti · retry %@"`

### 3.5 UserImagesView / DiveLogListView / DiveDetailView / ExportView

| Screen | Status | Key findings | Severity |
|--------|--------|--------------|----------|
| UserImagesView | Good | Grid + detail + fullscreen; delete a11y | P3 polish on caption size |
| DiveLogListView | Good | Row accessibility; delete confirm | P2 long Italian date strings |
| DiveDetailView | Good | Profile metrics; export path via settings | P3 chart height on small watch |
| ExportView | Adequate | Functional export UI | P2 density |

### 3.6 Warnings & safety UI

| Component | Status | Findings |
|-----------|--------|----------|
| AscentWarningBannerView | Strong | Icon + title + body; red stroke; a11y label/hint |
| DepthSafetyLiveViews | Strong | State-driven readout styling + blink |
| MissionModeIndicatorView | Good | Compact `10 pt` badge |
| Haptics | Good | User preference in Settings; resync on change |

**P2:** Multiple simultaneous warnings on Live — see §3.2.

### 3.7 Watch accessibility summary

| Area | Status |
|------|--------|
| VoiceOver | Good on Live, Compass, Images, Log list; partial on Settings status rows |
| Dynamic Type | P2 — `minimumScaleFactor` used heavily; no `@ScaledMetric` typography scale |
| Contrast | Strong dark UI + neon accents |
| Color-only | P2 — GPS/sync status rows use icon color without always duplicating state in text |
| Touch targets | Good — settings rows ≥ 40–44 pt |

---

## 4. iOS Companion detailed audit

### 4.1 Root shell & tab navigation

| Aspect | Status | Findings |
|--------|--------|----------|
| Entry | `DIRDivingiOSApp` wraps `ContentView` in `IOSRootShell` + legal gate |
| Tabs | Planner → Logbook → Analysis → Equipment → More (`IOSTab`) |
| Lazy mount | Tabs mount on first visit — good for launch performance |
| Toolbar | Hidden nav bars on tab roots; custom screen titles via `dirScreenTitleStyle` |
| Severity | P3 | Tab labels localized via `Label("tab.*")` |

**Files:** `DIRDivingiOSApp.swift`, `ContentView.swift`, `IOSNavigationStore.swift`

### 4.2 Fullscreen / adaptive layout (dedicated — §5)

See Section 5.

### 4.3 PlannerView (input)

| Aspect | Status | Findings |
|--------|--------|----------|
| UX | Good | Mode picker (Base/Deco/Technical); safety ack gate; reference warnings |
| UI | Good | `DIRCard`, gas mix cards, segmented GF presets in Deco |
| Typography | P2 | Many `caption2` footnotes; mode description small |
| Layout | P2 | Long form — calculate button may require substantial scroll |
| Accessibility | Good | Mode picker, calculate button, CNS warnings labeled |
| Severity | P2 | Form length |
| Fix | Sticky calculate CTA or collapsible advanced sections |
| Effort | M | `PlannerView.swift` |
| Files | `PlannerView.swift`, `PlannerGasMixCard.swift`, `PlannerModePolicy.swift` |

### 4.4 PlanResultView (result)

| Aspect | Status | Findings |
|--------|--------|----------|
| UX | Partial | Tabs Plan / Bühlmann / Charts; mode-specific visibility |
| UI | Good | Premium cards, result header badge, share export |
| Typography | P2 | Dense metric grid + multiple footnotes per CNS tile |
| Layout | P1 | Very long PIANO tab — TTS/Runtime row present but buried among NDL/CNS/density/END tiles |
| Accessibility | Good | Tab a11y, tissue chart a11y, export a11y |
| Severity | P1/P2 | Information architecture |
| Files | `PlannerView.swift` (`PlanResultView`) |

**Ascent table:** Uses `store.plan.ascentTableRows` with bottom/travel/deco/surface rows — **real data**. Columns Depth/Time/Gas/PPO₂ at `caption2`/`caption` — readable but tight (P2).

**Bühlmann tissue chart:** **Present** — `Chart(store.plan.tissueHistory.groupedPoints)` with four grouped series, legend, disclaimer, empty state. NDL reference chart secondary in Technical mode. **Uses real engine-sampled history** (P1 audit gap closed in code).

**GRAFICI:** Depth profile chart from `store.plan.depthProfilePoints` + segment timeline + GF comparison (Technical).

### 4.5 LogbookView

| Aspect | Status | Findings |
|--------|--------|----------|
| UX | Strong | Month sections, search, manual add, demo banner |
| UI | Good | `DiveLogCard` stacked cards, cyan accents |
| Accessibility | Good | Demo badge, card consolidated labels, delete a11y |
| Severity | P3 | Swipe delete only on non-demo |

### 4.6 DiveDetailView

| Aspect | Status | Findings |
|--------|--------|----------|
| UX | Good | Tabbed detail (summary/charts/details); depth chart |
| Charts | P2 | Chart a11y present; axis labels muted small |
| Severity | P2 | — |

### 4.7 AnalysisView

| Aspect | Status | Findings |
|--------|--------|----------|
| UX | Good | Hero + KPI grid + max depth bar chart + gas/route summaries |
| UI | Good | Consistent `DIRCard` / `DIRMetricTile` |
| Empty state | Good | Clear CTA copy |
| Severity | P3 | Chart height fixed 240 pt — OK across phones |

### 4.8 EquipmentView

| Aspect | Status | Findings |
|--------|--------|----------|
| UX | Adequate | Planning fields + checklist + templates sheet |
| UI | P2 | Checklist gas section adds many toggles/fields per item — dense |
| Accessibility | Partial | Pickers labeled in `EquipmentChecklistGasSection` |
| Severity | P2 | Checklist complexity for field use |

### 4.9 MoreView / Settings

| Aspect | Status | Findings |
|--------|--------|----------|
| UX | Good | Preferences, Watch sync card, iCloud, legal, developer unlock |
| UI | Good | Card grouping; destructive actions styled |
| Severity | P3 | Long scroll acceptable for settings |

### 4.10 iOS typography & visual system

| Token | Location | Notes |
|-------|----------|-------|
| Colors | `DIRTheme.swift` | Cyan/yellow/red/green semantic palette |
| Typography | `DIRTypography.swift` | Fixed sizes — **no Dynamic Type scaling** |
| Components | `DIRCard`, `DIRMetricTile`, `DIRWarningBox` | Consistent premium dark cards |
| Severity | P2 | Dynamic Type |

---

## 5. iOS fullscreen / adaptive layout audit

### Reported issue

Black bands above/below on **iPhone 15 Pro** (device) and **iPhone 17 Pro** (simulator).

### Current mitigation stack (code @ `bea4f74`)

```
DIRDivingiOSApp
  └─ IOSRootShell (.ignoresSafeArea + DIRBackground)
       └─ ContentView
            └─ TabView.dirCompanionTabSlot() (+ DIRBackground ignoresSafeArea top/bottom)
                 └─ per-tab NavigationStack
                      └─ DIRScreenContainer (background full-bleed; content respects safe area)
                           └─ ScrollView.dirCompanionScrollSurface()
```

Additional: `IOSWindowChromeConfigurator` paints `UIWindow.backgroundColor`, clears scroll/table backgrounds, opaque tab bar with `DIRTheme.uiKitBackground`.

### Likely causes (if bands persist)

| Cause | Likelihood | Notes |
|-------|------------|-------|
| Unpainted UIKit surfaces before chrome config | Mitigated | `applyUIKitAppearance()` in App init + `paintConnectedWindows()` on appear |
| TabView content shorter than slot | Medium | `Color.clear` placeholder tabs still use `dirCompanionTabRoot` |
| Mismatch between `#000` and `DIRTheme.background` (0.005,0.018,0.030) | Low | Could read as “bands” in bright environments |
| Launch screen vs runtime background | Medium | Needs device screenshot compare |
| Safe area double-padding | Low | Content uses standard safe area; background bleeds |

### Recommended approach (implementation plan only)

1. Device QA matrix on iPhone 15 Pro, 15 Pro Max, 17 Pro with screenshots at tab roots.
2. If bands remain: wrap `TabView` in `GeometryReader` + explicit `IOSCompanionViewportMetrics` at root (pattern already in `DIRDisclaimerScreen`).
3. Verify `Info.plist` `UILaunchScreen` generation matches `DIRTheme.uiKitBackground`.
4. Avoid fixed `.frame(height:)` on root containers.

### iPhone 14+ adaptability

| Pattern | Status |
|---------|--------|
| Flexible stacks / ScrollView | Used throughout |
| LazyVGrid in Analysis | 2-column — OK |
| Planner tables | Equal-width columns — may wrap awkwardly on 14 width (P2) |
| No model-specific hacks | Good |

**Severity:** P1 until confirmed fixed on physical iPhone 15 Pro.

---

## 6. Planner deep dive

### Input screen

- **Strengths:** Mode segmentation; safety acknowledgment; reference-only warnings; cylinder cards; MOD warnings.
- **Weaknesses:** High vertical length; technical cards hidden by mode but Deco/Technical still heavy; repetitive planning card adds complexity.
- **Above the fold:** Mode + profile + calculate not guaranteed without scroll.

### PlanResultView

| Element | Present | UX note |
|---------|---------|---------|
| TTS + Runtime summary | Yes | Top row of grid — good |
| Ascent table w/ bottom/travel/deco/surface | Yes | Real rows; narrow columns |
| Tissue chart 1–4…13–16 | Yes | `groupedPoints` + legend + disclaimer |
| NDL secondary chart | Technical only | Correctly demoted |
| Depth profile | Charts tab | Inverted Y via negative depth values |
| Gas ledger / contingency / team / briefing | Technical | Adds scroll depth |

### Alignment with premium reference direction

- **Matches:** Dark cards, cyan accents, tab structure PIANO / CURVA / GRAFICI, ascent table columns, grouped tissue curves.
- **Gaps:** Result grid still exposes many secondary metrics (NDL, CNS variants, density, END, turn pressure) before/around core outputs; disclaimer + warning density high.

**Severity:** P2 overall; P1 for scroll depth hiding primary outputs on smaller phones.

---

## 7. Watch Settings deep dive

| Topic | Finding |
|-------|---------|
| Row density | ~25+ rows including sync diagnostics |
| Typography | Improved via `DiveUI.Typography` — readable at default watch text |
| Sync overload | Pending/sent/ack/failed/retry/clear queue rows — operational, not dive-critical |
| Mission Mode | Toggle + auto-enable — clear |
| Developer | Gated — good |
| Dive safety | Ascent + alarms disabled during active dive — good |
| Real-device readability | Likely OK on Ultra; tight on 41 mm with large text |

**Recommendation:** Split “Sync diagnostics” into `Settings → Sync details` navigation link.

**Severity:** P2

---

## 8. Compass deep dive

| Item | Status |
|------|--------|
| Heading degrees | Large center readout + cardinal text |
| Cardinal rotation | **Fix present:** ring rotates `-headingDegrees`; labels at fixed angles on ring |
| Fixed pointer | Red diamond at top — clear |
| Bearing controls | Set/Clear with toast feedback + a11y |
| Mission Mode | Animations suppressed when active |
| Readability | Strong on Ultra; dial 148 pt may feel large on 40 mm — acceptable |

**Severity:** P3 polish only

---

## 9. Shared design system assessment

| Dimension | Watch `DiveUI` | iOS `DIRTheme` | Alignment |
|-----------|----------------|----------------|-----------|
| Background | Black + blue/green radial | Black + cyan/green radial | **Strong** |
| Primary accent | Blue/cyan | Cyan | **Strong** |
| Warning red/yellow | Yes | Yes | **Strong** |
| Typography | Watch-specific rounded scale | iOS rounded titles + callout body | **Appropriate platform split** |
| Cards/panels | `DivePanel` | `DIRCard` | Conceptually similar |
| Octopus logo | `DiveOctopusLogo` in compass header | Less prominent on iOS tabs | P3 brand parity |
| Mission Mode | Watch runtime profile | N/A on iOS companion | OK |

**Recommendation:** Document shared semantic color tokens in a single design reference (not necessarily shared code).

---

## 10. Accessibility assessment

| Criterion | Watch | iOS |
|-----------|-------|-----|
| VoiceOver | Good Live/Compass/Images; partial Settings status | Good Planner/Logbook; partial charts as aggregated labels |
| Dynamic Type | P2 — scale factors, not semantic fonts | P2 — fixed `DIRTypography` sizes |
| Contrast | Strong | Strong |
| Color-only warnings | P2 GPS/sync rows | P2 MOD tiles use color + text mostly |
| Touch targets | ≥ 38–44 pt on interactive rows | `buttonMinHeight` 44 defined; not always enforced |
| Chart a11y | Limited charting on Watch | Tissue + analysis charts have labels; no data table fallback |

---

## 11. Prioritized improvement backlog

### Apple Watch backlog

| ID | P | Area | Issue | Fix | Files | Effort | Risk if unfixed |
|----|---|------|-------|-----|-------|--------|-----------------|
| W-01 | P2 | Settings | Sync diagnostics overload | Nested sync detail screen | `SettingsView.swift` | M | Settings feel “engineer UI” |
| W-02 | P2 | Settings | Hardcoded IT strings | Localize EN/IT keys | `SettingsView.swift`, strings | S | EN users see Italian |
| W-03 | P2 | Live | Banner stacking | Priority queue / collapse | `DiveLiveView.swift` | M | Depth hero compressed |
| W-04 | P2 | A11y | Dynamic Type clipping | `@ScaledMetric` for hero metrics | `DiveLiveView.swift` | M | Unreadable at AX sizes |
| W-05 | P2 | A11y | Color-only status rows | Append state text | `SettingsView.swift` | S | VO users miss GPS/sync state |
| W-06 | P3 | Nav | Crown hint overlaps content | Auto-dismiss timing | `ContentView.swift` | S | Minor clutter |
| W-07 | P3 | Logbook | Export path via Settings only | Optional log row action | `DiveLogListView.swift` | S | Extra navigation |

### iOS Companion backlog

| ID | P | Area | Issue | Fix | Files | Effort | Risk if unfixed |
|----|---|------|-------|-----|-------|--------|-----------------|
| I-01 | P1 | Layout | Black bands unverified | Device QA + root geometry fix | `IOSWindowChromeConfigurator.swift`, `ContentView.swift` | M | Unprofessional fullscreen appearance |
| I-02 | P1 | Planner | Result scroll depth | Collapse secondary metrics; sticky summary | `PlannerView.swift` | M | Miss TTS/table/chart |
| I-03 | P2 | Planner | Tissue chart axis density | Larger axis fonts; optional toggle series | `PlannerView.swift` | S | Misread curves |
| I-04 | P2 | Planner | Ascent table column width | Rotated headers or horizontal scroll | `PlannerView.swift` | S | Trimix labels clip |
| I-05 | P2 | A11y | No Dynamic Type | Scale `DIRTypography` with `@ScaledMetric` | `DIRTypography.swift` | L | AX users struggle |
| I-06 | P2 | Equipment | Checklist gas density | Progressive disclosure per item | `EquipmentChecklistGasSection.swift` | M | Field checklist errors |
| I-07 | P3 | Analysis | Chart data table fallback | Accessibility rotor summary | `AnalysisView.swift` | S | VO limited insight |

### Shared / design-system backlog

| ID | P | Area | Issue | Fix | Files | Effort | Risk if unfixed |
|----|---|------|-------|-----|-------|--------|-----------------|
| S-01 | P2 | Tokens | Divergent color constants | Shared design doc / generated tokens | `DiveUI`, `DIRTheme` | M | Visual drift |
| S-02 | P3 | Brand | Octopus underused on iOS | Header mark on Planner/Logbook | iOS views | S | Weak brand link |
| S-03 | P2 | QA | No screenshot matrix | Add UI snapshot tests (optional) | `Tests/`, `Docs/` | L | Regressions unnoticed |

---

## 12. Development roadmap by app

### Apple Watch

| Phase | Focus |
|-------|--------|
| **1** | W-03 banner stacking; W-04 Dynamic Type on Live hero |
| **2** | W-01 Settings sync split; W-02 localization |
| **3** | Logbook/export polish (W-07); image caption readability |
| **4** | VoiceOver pass on Settings status rows (W-05) |

**Validation:** Ultra + Series simulators; active dive; Mission Mode on/off; compass rotation; large text.

### iOS Companion

| Phase | Focus |
|-------|--------|
| **1** | I-01 fullscreen device QA + fix if needed |
| **2** | I-02 Planner result IA; I-03/I-04 chart/table readability |
| **3** | Logbook/Analysis/Equipment polish (I-06) |
| **4** | I-05 Dynamic Type; localization length pass |

**Validation:** iPhone 14 / 15 Pro / 17 Pro simulators; Planner three modes; result tabs; share sheet.

### Shared

| Phase | Focus |
|-------|--------|
| **1** | S-01 token documentation |
| **2** | Component catalog in `Docs/ReferenceUI/` |
| **3** | Manual QA matrix (§14) |
| **4** | Optional snapshot tests |

---

## 13. Validation recommendations

### Commands

```bash
xcodegen generate
xcodebuild -project DIRDiving.xcodeproj -list

# Watch (use available Ultra simulator)
xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving Watch App" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Ultra 3 (49mm)' build

# iOS — iPhone 15 Pro not installed on audit machine; use closest available
xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving iOS" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build

xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving iOS Algorithm Tests" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
```

### Audit build results (2026-06-02, `bea4f74`)

| Command | Result |
|---------|--------|
| `DIRDiving iOS` → iPhone 17 Pro | **BUILD SUCCEEDED** |
| `DIRDiving Watch App` → Apple Watch Ultra 3 (49mm) | **BUILD SUCCEEDED** |
| `DIRDiving iOS` → iPhone 15 Pro | **Not run** — simulator unavailable (use iPhone 17 Pro / 17 Pro Max) |
| UI test / screenshot | **Not run** — static inspection audit |

---

## 14. Manual QA matrix

### Apple Watch

- [ ] Apple Watch Ultra / Ultra 3 simulator — Live dive depth hero
- [ ] Default text + largest text — Live + Settings
- [ ] Active dive — navigation lock + toast
- [ ] Pre-dive — crown hint dismiss
- [ ] Mission Mode on/off — animation suppression
- [ ] Compass — N/E/S/W rotate with heading; bearing set/clear
- [ ] Settings — scroll entire sync section
- [ ] Ascent warning banner + haptics
- [ ] User images grid + fullscreen
- [ ] Logbook list + detail

### iOS

- [ ] iPhone 14 width simulator — Planner result table
- [ ] iPhone 15 Pro **physical** — black bands check all tabs
- [ ] iPhone 17 Pro simulator — black bands check
- [ ] Default + AX Large text — Planner + Logbook
- [ ] Planner Base / Deco / Technical modes
- [ ] PlanResult tabs — tissue chart legend + depth profile
- [ ] Logbook search + delete + manual dive
- [ ] Analysis empty + populated
- [ ] Equipment checklist gas expand
- [ ] More — Watch sync + legal
- [ ] Onboarding disclaimer scroll
- [ ] Share export from Planner result

---

## 15. No-code-change confirmation

- **No source files were modified** during this audit.
- **No SwiftUI view files were changed.**
- **No algorithms, models, assets, or business logic were changed.**
- **Only** `Docs/DIR_DIVING_FULL_UI_UX_AUDIT_CURRENT.md` was created/updated.

---

## Quick reference

| Metric | Value |
|--------|-------|
| Watch UI/UX readiness | **79%** |
| iOS UI/UX readiness | **76%** |
| Baseline commit | `bea4f74` |
| Bühlmann tissue chart in UI | **Yes** (`store.plan.tissueHistory.groupedPoints`) |
| Compass cardinal rotation fix | **Present** |
| iOS fullscreen mitigations | **Present in code** — device QA pending |
