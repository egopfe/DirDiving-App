# DIR Diving UI/UX Readiness Audit — Current

**Audit date:** 2026-06-07  
**Repository:** DIR DIVING (`DirDiving-App`)  
**Branch:** `main` @ `c5d48b4`  
**Mode:** Read-only static audit + macOS build/test validation  
**Scope:** Apple Watch MAIN (`DIRDiving Watch App`) + iOS Companion MAIN (`DIRDiving iOS`)  
**No source changes:** Only this report file was created/updated.

---

## Executive Summary

| Dimension | Readiness |
|---|---:|
| **Apple Watch MAIN UI/UX** | **82%** |
| **iOS Companion MAIN UI/UX** | **84%** |
| **Shared design system** | **81%** |
| **Overall UI/UX readiness** | **83%** |

Both MAIN apps are **feature-complete at the UI layer** and suitable for **broader internal testing** (TestFlight-style QA with device matrices). They are **not yet at external/App Store UI polish** without closing P1 localization, accessibility, and device-verified fullscreen/layout items.

### Top 10 remaining risks

| # | ID | App | Risk |
|---|---|---|---|
| 1 | IOS-UX-P1-001 | iOS | Legal onboarding steps 0–3 hardcoded English while app supports IT/EN elsewhere |
| 2 | WATCH-UX-P1-001 | Watch | Hardcoded Italian visible strings in dive detail/export/GPS rows (`ESPORTA`, `ELIMINA LOG`, `PROF. MASSIMA/MEDIA`) |
| 3 | IOS-UX-P1-002 | iOS | Fullscreen black-band fix implemented in code but **not visually verified** on iPhone 15 Pro / 17 Pro hardware or unavailable legacy simulators |
| 4 | IOS-UX-P1-003 | iOS | Logbook delete via `.swipeActions` inside `ScrollView` — likely non-functional in SwiftUI |
| 5 | WATCH-UX-P1-002 | Watch | Active Live Dive stacks many banners; compressed spacing may push depth hero below fold on 41/45 mm |
| 6 | IOS-UX-P1-004 | iOS | Full-plan CNS warning uses color/icon only — no banner or dedicated VoiceOver label |
| 7 | WATCH-UX-P2-001 | Watch | Depth safety caution (35 m) vs critical (38 m) share identical banner copy — color-only differentiation |
| 8 | IOS-UX-P2-001 | iOS | Stale `planner.mode.footer` strings claim only Advanced mode active; all three modes are live |
| 9 | WATCH-UX-P2-002 | Watch | Compass screen has no `ScrollView` — dial + metrics may clip on smallest supported faces |
| 10 | IOS-UX-P2-002 | iOS | Planner charts/tables lack full VoiceOver summaries; depth profile chart has no a11y label |

### Internal testing readiness

| Gate | Verdict |
|---|---|
| Compile + algorithm tests | **Pass** — builds succeed; iOS 387 tests / Watch 161 tests (skipped keychain cases) |
| Internal QA / TestFlight UI pass | **Proceed with documented P1 matrix** |
| External TestFlight / App Store UI | **Blocked** on P1 localization, a11y, device fullscreen verification |

### Build/test result

| Step | Result |
|---|---|
| `xcodegen generate` | **Succeeded** |
| iOS build (`iPhone 17` sim) | **BUILD SUCCEEDED** |
| Watch build (`Apple Watch Ultra 3 (49mm)`) | **BUILD SUCCEEDED** |
| iOS Algorithm Tests (`iPhone 17`) | **387 executed, 5 skipped, 0 failures** |
| Watch Algorithm Tests (`Ultra 3`) | **161 executed, 8 skipped, 0 failures** |

**Simulators used:** iPhone 17, Apple Watch Ultra 3 (49mm)  
**Unavailable destinations:** iPhone 15 Pro, iPhone 15 Pro Max, iPhone 14 Pro, iPhone 14 Pro Max, Apple Watch Ultra 2 (49mm) — not installed on this Mac (OS 26.5 runtime lists iPhone 17 family only).

---

## Scope Confirmation

| Check | Status |
|---|---|
| Watch MAIN included | ✓ `DIRDiving Watch App` |
| iOS Companion MAIN included | ✓ `DIRDiving iOS` |
| Experimental UI excluded from audit scope | ✓ Not compiled in MAIN targets |
| Algorithm / business logic unchanged | ✓ Audit read-only |
| Bühlmann / decompression / CNS / gas math unchanged | ✓ UI audit only |
| Non-certified positioning preserved | ✓ Disclaimers present; planner reference-only copy exists |
| Only this report modified | ✓ |

---

## Repository / Target Inspection

### Targets and schemes

| Target | Platform | Role |
|---|---|---|
| `DIRDiving Watch App` | watchOS 10+ | Apple Watch MAIN |
| `DIRDiving iOS` | iOS 17+ iPhone | iOS Companion MAIN (embeds Watch) |
| `DIRDiving Watch Algorithm Tests` | watchOS | Unit/integration tests |
| `DIRDiving iOS Algorithm Tests` | iOS | Unit/integration tests |

Schemes: `DIRDiving Watch App`, `DIRDiving iOS`, `DIRDiving Watch Algorithm Tests`, `DIRDiving iOS Algorithm Tests`.

### Watch MAIN compiled sources

From `project.yml`: `App/`, `Models/` (minus exploration/buddy), `Services/` (minus exploration/buddy), `Views/` (minus apnea/snorkel/buddy/experimental), `Utils/` (minus `ExperimentalFeatures.swift`), explicit algorithm/runtime files, `Resources/`.

**Excluded from Watch MAIN (must not treat as active UI):**

- `Views/ApneaView.swift`, `SnorkelingView.swift`, `BuddyAssistView.swift`, `ExperimentalConceptsView.swift`
- `Utils/ExperimentalFeatures.swift`
- Exploration/buddy models and services

### iOS MAIN compiled sources

Entire `iOSApp/` minus:

- `ExplorationCenterView.swift`, `ExperimentalFutureConceptsView.swift`, `BuddyExperimentalView.swift`
- Exploration/buddy models and stores

### Stale / duplicate UI risk

| Item | Risk | Mitigation |
|---|---|---|
| `DiveBearingRing` in `DiveUIComponents.swift` vs custom dial in `CompassView.swift` | Alternate compass design path unused | Document; avoid editing dead component in future tasks |
| Two Watch back patterns (`WatchDetailBackButton` vs `WatchSubscreenBackToolbar`) | Inconsistent navigation polish | Unify in future UI pass |
| iOS `DiveLogCard` ad-hoc fonts vs `DIRTypography` | Token drift | Migrate cards to design tokens later |

Previous algorithm/remediation fixes were applied to **compiled MAIN targets** (confirmed by passing Watch/iOS test suites on `c5d48b4`).

---

## Apple Watch Findings

### Dive Live (`Views/DiveLiveView.swift`)

| Aspect | Assessment |
|---|---|
| **Status** | Strong hierarchy: depth hero dominant; runtime/TTV secondary; ascent gauge adjacent |
| **UI** | Sync strip, mission bolt, mock/simulation badges, GPS/alarm banners integrated |
| **UX** | Pre-dive manual/auto paths clear; active dive restricts tabs via `ContentView` |
| **Typography** | `DiveUI.Typography.metricValueHero` (72pt) with `minimumScaleFactor(0.42)` — aggressive on 40 mm (**P2**) |
| **Layout** | `ScrollView` with dynamic banner compression (`activeDiveSpacing` → 3pt when ≥4 banners) — depth may scroll off-screen (**P1**) |
| **Accessibility** | Depth hero, stopwatch, ascent banner labeled; TTV a11y partially Italian-hardcoded (**P1**) |
| **Readiness** | **84%** |

**Issues:** WATCH-UX-P1-001 (hardcoded `PROF. MASSIMA/MEDIA`), WATCH-UX-P1-002 (banner stacking), WATCH-UX-P2-003 (hardcoded `RunTime`/`TTV` visible text).

### Start Dive / pre-dive

Centered ready state, auto-dive vs manual fallback panels, crown hint in `ContentView`. Readable; minor micro-text at 9–11pt in hints (**P3**). **Readiness: 86%**.

### Mission Mode (`MissionModeIndicatorView.swift`, `SettingsView.swift`, `DiveLiveView.swift`)

Bolt overlay on logo; settings block with disclaimers (not Apple Low Power Mode). Runtime profile disables decorative animation only — no false system claim. Good a11y on indicator. **Readiness: 88%**.

### Depth safety 35 / 38 / 40 m (`DepthSafetyLiveViews.swift`, `Utils/DepthSafetyConfiguration.swift`)

| Depth band | Visual | Copy |
|---|---|---|
| &lt;35 m | White depth, blue label | None |
| 35–37.99 m | Yellow depth + stroke | `depth.safety.approaching.title` |
| 38–39.99 m | Orange depth + stroke | **Same title as caution** |
| ≥40 m | Red + blink; max/avg cards hidden | Exceeded + ascend/readings subtitles |

Threshold logic unchanged. UI uses color progression appropriately. **P2:** caution vs critical not distinguished in copy or VoiceOver. Banner lacks explicit `accessibilityLabel` (**P2**). **Readiness: 86%**.

### Ascent warnings (`AscentWarningBannerView.swift`, `AscentGaugeView.swift`)

Inline red pulsing banner with rate + instruction; full a11y. Gauge vertical bands green/yellow/red with labeled pointer. Does not obscure depth when single banner; competes with depth-safety stack when combined (**P2**). **Readiness: 90%**.

### Alarm / GPS overlays

Compact inline banners at bottom of Live stack; GPS confirmation post-dive with fix/fallback/noFix coloring. Pre-dive GPS hint copy localized. Coordinates in detail when available. **Readiness: 87%**.

### Compass / BUSSOLA (`Views/CompassView.swift`)

Fixed 148px dial; SET/CLEAR; bearing toast. **BUSSOLA** in VoiceOver label (EN strings use "COMPASS" key — product rule: IT uses BUSSOLA). Mission Mode disables dial animation only. **P2:** no scroll — clip risk on 41 mm. Status line may truncate long permission messages. **Readiness: 80%**.

### Settings (`Views/SettingsView.swift` + sub-screens)

Six sections including sync diagnostics, mission mode, developer entry. Wheel pickers for units/language add vertical length (**P2**). Sensor source subtitle uses `DepthSensorSourceResolution.localizedLabel` — post-remediation copy present. Underwater restrictions disable risky controls. Alarm/reminder sub-screens use `WatchSubscreenBackToolbar`. **Readiness: 76%**.

### Developer / sensor source (`DeveloperSettingsView.swift`, `InfoView.swift`, `WatchSyncDiagnosticsView.swift`)

Simulation/unavailable/mock labels visible in Settings/Info when applicable. Diagnostics dense but appropriate for internal QA. **Readiness: 85%**.

### App Intents / Action Button (`WatchShortcutHelpView.swift`, `ActionButtonIntents.swift`)

Help screen reachable from Settings; legal gate enforced in runtime (not UI audit scope). Copy references safety acceptance. **Readiness: 88%**.

### Images / logbook / export

`UserImagesView` — strong row/detail a11y; delete error at 9pt (**P2**).  
`DiveLogListView` — readable rows with GPS icon.  
`DiveDetailView` — **P1:** hardcoded `"ESPORTA (SUBSURFACE)"`, `"ELIMINA LOG"`, `"PROF. MASSIMA"`, GPS row titles not using `String(localized:)`.  
`ExportView` — functional share flow; duplicate `.lineLimit` modifiers (**P3**).  
**Readiness: 83%**.

### Legal / Info (`WatchLegalOnboardingView.swift`, `InfoView.swift`)

Multi-step legal gate; safety disclaimers preserved. Some toggles lack explicit a11y traits (**P2**). **Readiness: 85%**.

### Watch navigation (`Views/ContentView.swift`)

Vertical TabView: Live → Compass → Settings → Images → Logbook. Underwater lock to Live+Compass with toast. Mixed back affordances (**P2**). **Readiness: 82%**.

---

## iOS Companion Findings

### Root fullscreen / adaptive layout

**Implemented mitigations** (`IOSWindowChromeConfigurator.swift`, `DIRBackground.swift`, `ContentView.swift`):

- UIKit appearance: opaque tab bar `DIRTheme.uiKitBackground`, clear scroll/table backgrounds
- Window `backgroundColor` painted on scene activation
- `IOSRootShell` + `dirCompanionTabRoot` + `dirCompanionScrollSurface` edge-to-edge fill
- `scrollContentBackground(.hidden)` on scroll surfaces

**Black band status:** Code path is comprehensive and builds clean on iPhone 17 simulator. **Visual verification on iPhone 15 Pro / 17 Pro hardware not performed in this audit** — treat as **open P1** until device QA confirms bands eliminated. Minor `#000` vs `DIRTheme.background` delta could read as bands in bright environments (**P2**).

**Readiness: 85%** (code) / **70%** (device-verified confidence)

### Dashboard / tabs (`iOSApp/Views/ContentView.swift`)

Five tabs: Planner, Logbook, Analysis, Gear, More — lazy mounted with `dirCompanionTabRoot`. Tab bar uses DIR chrome. **Readiness: 88%**.

### Planner input (`PlannerView.swift`)

Three-mode segmented picker (Base / Deco / Technical) — **all active**. Safety acknowledgment gate before calculate. Mode-specific fields gated by `PlannerModePolicy`. Gas ledger, GF, reserve, repetitive (Technical only), environment altitude/salinity. **P2:** stale `planner.mode.footer` contradicts live modes. Disclaimer density high on first scroll. **Readiness: 88%**.

### Planner result — PIANO tab

Summary hero grid (TTS, runtime, deco stops, OTU, max depth, bottom time, CNS). Ascent table from `store.plan.ascentTableRows` with bottom/travel/deco/surface rows via `PlannerAscentTableBuilder`. Gas ledger on Deco+Technical. Base shows simplified messaging instead of full table. Legal/reference footnotes present. **Readiness: 90%**.

### CURVA BÜHLMANN tab

Real `Chart(store.plan.tissueHistory.groupedPoints)` with four compartment groups (1–4, 5–8, 9–12, 13–16). Empty state when no history. Deco: simplified presentation; Technical: full curve + optional NDL reference. Trimix disclaimer. Legend and axis labels present. Reference-only positioning in footnotes. **P2:** chart a11y summary exists for tissue load peak but table navigation still coarse. **Readiness: 89%**.

### GRAFICI tab (Technical only)

Depth profile chart (`depthProfilePoints`), segment timeline, GF comparison table. Empty states localized. **P1:** depth profile chart lacks VoiceOver label. **P2:** Y-axis `(m)` not imperial-aware. **Readiness: 86%**.

### CNS / OTU

| Surface | Status |
|---|---|
| CNS (full plan) hero tile | Yellow + triangle when `fullPlanCNSWarningActive` — **no banner, weak a11y (P1)** |
| CNS descent + bottom | Red tile + dedicated warning banner + a11y label/hint when threshold exceeded |
| CNS ascent/deco estimate | Shown as reference metric |
| OTU | In hero grid |
| Pre-calc CNS preview | Separate from full-plan result |

**Readiness: 87%**

### Gas ledger

Per-cylinder consumption/remaining/pressure; failure card; reserve warnings. Readable on iPhone 17 width. **Readiness: 90%**.

### Repetitive / environment

Repetitive planning card Technical-only (by policy). Environment altitude/salinity in Technical mode. Snapshot badge on result when tissue state applied. **Readiness: 88%**.

### Logbook (`LogbookView.swift`, `DiveDetailView.swift`)

Month grouping, search, CSV import, manual add. Detail tabs with depth chart, gas, export. **P1:** swipe delete inside `ScrollView` likely broken. **P3:** `DiveLogCard` typography outside tokens. **Readiness: 82%**.

### Analysis / Equipment / More

Analysis dashboard with max-depth chart (has a11y). Equipment checklist + PDF export. More: units, language, CNS check toggle, sync, iCloud, legal. **Readiness: 84%**.

### Onboarding / disclaimer

`IOSLegalOnboardingView` — **P1:** steps 0–3 hardcoded English ("Welcome", "Safety Warning", "Acceptance"). Post-accept companion overlay localized. **Readiness: 72%**.

---

## Planner Deep Dive

| Feature | Present | Notes |
|---|---|---|
| Base / Deco / Technical tabs | ✓ | Policy in `PlannerModePolicy.swift` |
| PIANO / CURVA BÜHLMANN / GRAFICI | ✓ | Tab availability mode-gated |
| Ascent/decompression table | ✓ | Dynamic `ascentTableRows`; bottom/travel/deco/surface |
| Tissue-history chart | ✓ | Real `groupedPoints`; not static fake |
| Depth-profile chart | ✓ | Technical GRAFICI only |
| CNS full plan + descent/bottom | ✓ | Warning asymmetry on full-plan a11y |
| Gas ledger + schedule allocation | ✓ | Deco + Technical |
| Repetitive planning | ✓ | Technical input only |
| Reference-only safety | ✓ | Footnotes + disclaimers; not certified deco advice |

---

## iOS Fullscreen / Adaptive Layout Deep Dive

| Question | Answer |
|---|---|
| Is black band issue fixed in code? | **Likely yes** — layered UIKit + SwiftUI mitigations |
| Visually verified? | **No** — P1 open |
| Root cause if bands persist | Unpainted window/scene edges, scroll default backgrounds, tab bar translucency — all addressed in code |
| Files | `IOSWindowChromeConfigurator.swift`, `DIRBackground.swift`, `ContentView.swift` |
| Device risks | Dynamic Island / home indicator — safe-area padding used; no hardcoded device frames found |
| Recommended fix if QA fails | Capture failing device screenshots; verify `paintConnectedWindows()` on cold launch + tab switch |

---

## Watch Deep Dive Summary

Live Dive is premium-coherent with DIR octopus branding and cyan/blue palette. Primary gap is **banner stacking under multiple simultaneous warnings** and **hardcoded Italian literals** breaking EN locale. Compass and Settings need **small-watch scroll/layout** pass. Mission Mode and depth-safety visuals meet product intent without threshold changes.

---

## Shared Design System Assessment

### Watch `DiveUI` (`Views/DiveUIComponents.swift`)

| Token | Value / pattern |
|---|---|
| Background | Black → deep blue gradient |
| Accent | Cyan `#05EBF5`, blue `#008FFF` |
| Warning | Yellow, orange, red family |
| Typography | Rounded system scale 11–72pt |
| Components | `DivePanel`, `WatchSettingsRow`, `DiveCommandButton`, `DiveInlineStatusBanner` |
| Min touch | 44pt settings, 40pt commands |

### iOS `DIRTheme` (`iOSApp/DesignSystem/DIRTheme.swift`)

| Token | Value / pattern |
|---|---|
| Background | `#010509` approx |
| Surface | Layered blue-grays |
| Accent | Cyan aligned with Watch |
| Components | `DIRCard`, `DIRMetricTile`, `DIRWarningBox`, `DIRTypography` |

### Coherence

| Coherent | Inconsistent |
|---|---|
| Dark ocean palette, cyan accent, non-certified tone | Watch uses pure black top; iOS uses tinted background |
| Warning red/yellow/orange semantics | Watch depth caution/critical copy identical |
| Card/panel metaphor | Ad-hoc fonts in logbook cards and some Watch hints |
| Reference-only planner disclaimers | Stale mode footer strings |

**Shared design system readiness: 81%**

Platform-specific divergence (compact Watch typography vs iPhone card grids) is **acceptable**.

---

## Text Readability Audit

### Watch

| Screen | Issues |
|---|---|
| Dive Live | Hero depth readable; TTV/RunTime labels mixed EN/IT; micro-hints 9–11pt |
| Settings | Long scroll; wheel pickers; footnotes at 11pt OK |
| Compass | Dial numerals OK; status truncation risk |
| Dive detail | Hardcoded Italian button labels |
| Warnings | Concise banner copy; good contrast |

### iOS

| Screen | Issues |
|---|---|
| Planner input | Structured cards; disclaimer overload |
| Planner result | Dense tables on narrow phones; `minimumScaleFactor` on metrics |
| Logbook | 15pt/27pt ad-hoc card fonts |
| Onboarding | English-only steps |

**Dynamic Type:** iOS partial — fixed chart heights limit scaling (**P3**). Watch uses scale factors more than Dynamic Type.

---

## Accessibility Audit

| Area | Watch | iOS |
|---|---|---|
| VoiceOver warnings | Partial — depth banner, settings toggles gaps | Good on CNS descent banner; weak on full-plan CNS + depth chart |
| Chart a11y | N/A (minimal charts) | Tissue chart has peak summary; depth profile missing |
| Mission Mode | Labeled indicator | N/A |
| Color-only states | Depth bands, some settings | CNS full-plan warning |
| Touch targets | ≥44pt on settings rows | `buttonMinHeight` 44pt |
| Table navigation | N/A | `.accessibilityElement(children: .combine)` on rows — poor traversal |

**Watch accessibility readiness: 72%**  
**iOS accessibility readiness: 72%**

---

## P0/P1/P2/P3 Issue Table

| ID | App | Area | Pri | Description | Files | Fix | Effort | Risk |
|---|---|---|---|---|---|---|---|---|
| WATCH-UX-P1-001 | Watch | Logbook/Live | **P1** | Hardcoded IT strings in EN locale | `DiveDetailView.swift`, `DiveLiveView.swift` | Replace with `String(localized:)` / keys | S | EN users see wrong language; App Store i18n rejection risk |
| WATCH-UX-P1-002 | Watch | Live Dive | **P1** | Multi-banner stack compresses layout | `DiveLiveView.swift` | Priority/collapse banner policy (UI only) | M | Critical metrics scrolled off-screen underwater |
| IOS-UX-P1-001 | iOS | Onboarding | **P1** | Legal steps hardcoded English | `IOSLegalOnboardingView.swift` | Localize all step copy | S | IT users get English gate |
| IOS-UX-P1-002 | iOS | Layout | **P1** | Black bands not device-verified | `IOSWindowChromeConfigurator.swift` | Device QA + screenshot evidence | S | Regressed letterboxing on Pro models |
| IOS-UX-P1-003 | iOS | Logbook | **P1** | Swipe delete in ScrollView | `LogbookView.swift` | Move to `List` or explicit delete affordance | M | Delete unreachable |
| IOS-UX-P1-004 | iOS | Planner CNS | **P1** | Full-plan CNS warning weak a11y | `PlannerView.swift` | Banner + VoiceOver label mirroring descent/bottom | S | WCAG / App Store a11y |
| WATCH-UX-P2-001 | Watch | Depth safety | **P2** | 35 m vs 38 m same copy | `DepthSafetyLiveViews.swift` | Distinct localized strings + a11y | S | Users can't distinguish bands without color |
| WATCH-UX-P2-002 | Watch | Compass | **P2** | No scroll on dense layout | `CompassView.swift` | Wrap in `ScrollView` | S | Clip on 41 mm |
| WATCH-UX-P2-003 | Watch | Live | **P2** | TTV/RunTime hardcoded EN visible text | `DiveLiveView.swift` | Localize labels | S | Inconsistent IT/EN |
| WATCH-UX-P2-004 | Watch | A11y | **P2** | Depth banner no explicit a11y label | `DepthSafetyLiveViews.swift` | Add label/hint | S | VoiceOver gap |
| WATCH-UX-P2-005 | Watch | Navigation | **P2** | Mixed back button patterns | `WatchDetailBackButton.swift`, `WatchSubscreenBackToolbar.swift` | Unify component | M | UX inconsistency |
| IOS-UX-P2-001 | iOS | Planner | **P2** | Stale mode footer strings | `Localizable.strings` | Update copy for 3 live modes | S | User confusion |
| IOS-UX-P2-002 | iOS | Charts | **P2** | Depth chart no a11y; metric axis | `PlannerView.swift` | Labels + unit-aware axis | M | A11y fail |
| IOS-UX-P2-003 | iOS | Planner | **P2** | Disclaimer density | `PlannerView.swift` | Collapsible reference block | M | Calculate CTA below fold |
| IOS-UX-P2-004 | iOS | Tables | **P2** | Row combine hurts VO navigation | `PlannerView.swift` | Per-cell accessibility | M | Poor table traversal |
| WATCH-UX-P3-001 | Watch | Export | **P3** | Duplicate lineLimit | `ExportView.swift` | Remove duplicate modifier | XS | Minor |
| WATCH-UX-P3-002 | Watch | Design | **P3** | Unused `DiveBearingRing` | `DiveUIComponents.swift` | Document or remove later | XS | Maintainer confusion |
| IOS-UX-P3-001 | iOS | Typography | **P3** | Log card font drift | `LogbookView.swift` | Adopt `DIRTypography` | S | Visual inconsistency |
| IOS-UX-P3-002 | iOS | Dynamic Type | **P3** | Fixed chart heights | Planner, Analysis | Scroll + scalable containers | M | Large text clipping |

**P0:** None identified at UI layer (no missing safety surfaces; algorithms tested separately).

---

## Readiness Scoring Detail

### Apple Watch (weighted)

| Area | Weight | Score | Weighted |
|---|---:|---:|---:|
| Live Dive UI | 20% | 84% | 16.8 |
| Compass | 10% | 80% | 8.0 |
| Settings | 15% | 76% | 11.4 |
| Warnings/safety UI | 15% | 89% | 13.4 |
| Navigation | 10% | 82% | 8.2 |
| Images/logbook/export | 10% | 83% | 8.3 |
| Accessibility/localization | 10% | 72% | 7.2 |
| Design system | 10% | 88% | 8.8 |
| **Total** | | | **82%** |

### iOS Companion (weighted)

| Area | Weight | Score | Weighted |
|---|---:|---:|---:|
| Fullscreen/adaptive | 15% | 85% | 12.8 |
| Planner input | 15% | 88% | 13.2 |
| Planner result/charts/tables | 25% | 90% | 22.5 |
| Logbook/Analysis/Gear/More | 20% | 83% | 16.6 |
| Accessibility/localization | 10% | 72% | 7.2 |
| Design system | 10% | 86% | 8.6 |
| Navigation/share/export | 5% | 88% | 4.4 |
| **Total** | | | **85%** |

*Strict adjustment for unverified fullscreen: effective iOS score **84%** when device QA weighted.*

### Shared design system (weighted)

| Area | Weight | Score | Weighted |
|---|---:|---:|---:|
| Token consistency | 25% | 82% | 20.5 |
| Component consistency | 25% | 80% | 20.0 |
| Warning hierarchy | 20% | 85% | 17.0 |
| Chart/table patterns | 15% | 83% | 12.5 |
| Documentation/QA | 15% | 75% | 11.3 |
| **Total** | | | **81%** |

**Overall UI/UX readiness:** `(82×0.35 + 84×0.45 + 81×0.20) ≈ **83%**`

---

## Readiness-To-100 Roadmap

### Apple Watch

| Phase | Tasks | Files | Acceptance | Effort | Readiness after |
|---|---|---|---|---|---|
| W-1 P1 | Localize hardcoded strings; TTV a11y EN | `DiveLiveView`, `DiveDetailView`, strings | EN/IT parity on log/export/depth labels | 1–2 d | 86% |
| W-2 P1 | Banner priority / collapse UI | `DiveLiveView` | Depth hero visible without scroll in 4-banner scenario on 45 mm sim | 2–3 d | 88% |
| W-3 P2 | Depth band copy + a11y; Compass scroll | `DepthSafetyLiveViews`, `CompassView` | VO distinguishes 35 vs 38 m | 1–2 d | 90% |
| W-4 P2 | Settings density + back unify | `SettingsView`, back utils | Crown travel reduced; one back pattern | 2 d | 92% |
| W-5 P3 | Token cleanup | `DiveUIComponents`, hints | No ad-hoc 9pt critical text | 1 d | 94% |

### iOS Companion

| Phase | Tasks | Files | Acceptance | Effort | Readiness after |
|---|---|---|---|---|---|
| I-1 P1 | Localize legal onboarding | `IOSLegalOnboardingView`, strings | IT/EN steps match app language | 1 d | 87% |
| I-2 P1 | Device fullscreen QA matrix | QA doc + chrome files | Screenshot proof on 15 Pro + 17 Pro | 1 d QA | 89% |
| I-3 P1 | Logbook delete UX | `LogbookView` | Delete works without swipe | 1 d | 90% |
| I-4 P1 | CNS full-plan warning a11y | `PlannerView` | Banner + VO label | 0.5 d | 91% |
| I-5 P2 | Stale strings; chart a11y; table VO | `PlannerView`, strings | Mode footer accurate; charts labeled | 2–3 d | 94% |
| I-6 P3 | Typography token adoption | Logbook, cards | Cards use `DIRTypography` | 1–2 d | 96% |

### Shared design system

| Phase | Tasks | Acceptance | Effort | Readiness after |
|---|---|---|---|---|
| D-1 | Document Watch/iOS token mapping | `Docs/` design reference | 1 d | 85% |
| D-2 | Unify warning banner components (doc + future refactor) | Same semantic colors/labels | 2 d | 88% |
| D-3 | UI QA matrices linked from INDEX | Matrices for Watch+iOS | 0.5 d | 90% |

---

## Validation Results

```
xcodegen generate → Succeeded
xcodebuild -scheme "DIRDiving iOS" -destination 'platform=iOS Simulator,name=iPhone 17' build → BUILD SUCCEEDED
xcodebuild -scheme "DIRDiving Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Ultra 3 (49mm)' build → BUILD SUCCEEDED
xcodebuild -scheme "DIRDiving iOS Algorithm Tests" -destination 'platform=iOS Simulator,name=iPhone 17' test → 387 executed, 5 skipped, 0 failures
xcodebuild -scheme "DIRDiving Watch Algorithm Tests" -destination 'platform=watchOS Simulator,name=Apple Watch Ultra 3 (49mm)' test → 161 executed, 8 skipped, 0 failures
```

**Unavailable simulators:** iPhone 15 Pro, 15 Pro Max, 14 Pro, 14 Pro Max, Apple Watch Ultra 2 — not installed (runtime 26.5 provides iPhone 17 family + Ultra 3).

**Unresolved build issues:** None on available destinations.

---

## Confirmation

| Statement | Status |
|---|---|
| No source code files changed | ✓ |
| No SwiftUI views changed | ✓ |
| No assets changed | ✓ |
| No localization files changed | ✓ |
| No business logic changed | ✓ |
| Algorithms unchanged | ✓ |
| Decompression/Bühlmann/gas/CNS math unchanged | ✓ |
| Sensor/dive detection/safety thresholds unchanged | ✓ |
| Logging/export/sync logic unchanged | ✓ |
| No features removed | ✓ |
| Only `Docs/DIR_DIVING_UI_UX_READINESS_AUDIT_CURRENT.md` created/updated | ✓ |
| DIR Diving remains non-certified dive companion | ✓ |
| iOS Bühlmann planner remains reference-only | ✓ |
| BUSSOLA terminology preserved on Watch | ✓ |

---

*Audit performed post Watch MAIN algorithm remediation @ `c5d48b4`. Physical device UI verification remains a separate QA gate.*
