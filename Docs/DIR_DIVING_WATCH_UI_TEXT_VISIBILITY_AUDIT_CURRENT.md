# DIR DIVING Watch UI Font Fit / Text Visibility Audit - Current

Date: 2026-06-25
Repository: `https://github.com/egopfe/DirDiving-App.git`
Branch audited: `main`
Audited HEAD: `b6f4c30` (`Fix Apnea settings crash when switching activity-scoped settings mode.`)
Target audited: Apple Watch / watchOS SwiftUI code only
Audit mode: static SwiftUI inspection plus UI-only remediation
Code changes: Watch SwiftUI layout/font-fitting only

## 1. Executive Summary

The local repository was first updated from `origin/main` with a fast-forward pull. After the update, local `main` and `origin/main` were aligned at `b6f4c30`.

Overall Watch font-fit readiness after remediation: **92% static confidence**.

No P0 text-fit blocker was found by static inspection. The Watch UI uses a strong centralized visual system in `DiveUIComponents.swift`, and many critical controls already include `lineLimit`, `minimumScaleFactor`, fixed touch heights, scroll containers, and high-contrast color treatment. The live Diving surface remains the strongest area: large depth, runtime, stopwatch, inline warning banners, and glove-friendly buttons are broadly aligned with the premium black/neon DIR DIVING benchmark.

The remaining risk is not a global failure of the design system. The static P1/P2/P3 font-fit risks identified in this report have been remediated with Watch SwiftUI-only layout and typography changes. The residual risk is validation-driven: rendered screenshots and physical Watch QA are still required to prove the new layout under 41/45/49 mm sizes, IT/EN strings, metric/imperial units, and extreme values.

Remediation status:
- **P1 fixed:** Full Computer live decompression metrics no longer depend on a three-column row with `minimumScaleFactor(0.5)`; decompression mode now uses a more readable two-row arrangement.
- **P1 fixed:** Full Computer predive gas controls now use protected custom `Stepper` labels and fitted title/value rows.
- **P2 fixed:** Live stopwatch, depth hero, dashboard values, and live badges now avoid very aggressive text compression.
- **P2 fixed:** Ascent gauge, Apnea, Snorkeling, Compass, Buddy/Experimental micro-labels, shared buttons, and shared status pills received targeted fit guards.
- **P3 partially fixed:** Shared command/pill typography is more resilient. A project-wide Dynamic Type policy remains a documentation and QA decision.

Build/screenshot verification was not run because this environment is Windows and does not provide Xcode/watchOS simulator tooling. This report is therefore a static code audit plus UI-only remediation record, not a pixel-proof visual QA pass.

## 1.1 Remediation Files

SwiftUI files updated:
- `Views/FullComputerLivePanels.swift`
- `Views/FullComputerPrediveSettingsView.swift`
- `Views/DiveLiveView.swift`
- `Views/AscentGaugeView.swift`
- `Views/ApneaView.swift`
- `Views/SnorkelingView.swift`
- `Views/CompassView.swift`
- `Views/DiveUIComponents.swift`
- `Views/BuddyAssistView.swift`
- `Views/ExperimentalConceptsView.swift`

Documentation updated:
- `Docs/DIR_DIVING_WATCH_UI_TEXT_VISIBILITY_AUDIT_CURRENT.md`
- `Docs/DIR_DIVING_WATCH_UI_TEXT_VISIBILITY_IMPLEMENTATION_REPORT_CURRENT.md`

No managers, stores, models, algorithms, sync logic, GPS behavior, persistence, or calculation code was modified.

## 2. Scope Confirmed

Included:
- `Views/*.swift` Apple Watch SwiftUI screens and shared Watch UI components.
- Watch production surfaces on `main`: live dive, full computer live panels, compass, settings, legal onboarding, alarms, ascent gauge, warnings, dive log/detail, export, info, user images.
- Watch optional/activity surfaces present in the main branch such as Apnea and Snorkeling views, because they are Apple Watch UI code and can affect future activity-scoped presentation.

Excluded:
- `iOSApp/*`
- iOS Companion views and services.
- Experimental remote branches.
- Business logic, algorithms, managers, persistence, sync, GPS, compass math, dive math.

## 3. Static Inspection Metrics

Files scanned:
- `44` Swift files under `Views/`.

Text/layout signals found:
- `.font(...)` occurrences: `535`
- `.lineLimit(...)` occurrences: `121`
- `.minimumScaleFactor(...)` occurrences: `82`
- `.fixedSize(horizontal: false, vertical: true)` occurrences: `45`
- Screen-level `.dynamicTypeSize(...)` occurrences: `2`

Interpretation:
- The codebase already uses many anti-clipping tools.
- The current design intentionally favors fixed Watch typography and visual hierarchy.
- The main missing layer is systematic per-screen pixel validation against 41/45/49 mm Watch sizes and IT/EN localization.

## 4. UI/UX Font-Fit Criteria Used

The audit checked the Watch UI against these project-specific criteria:
- Black premium underwater UI remains high contrast.
- Primary underwater metrics stay readable at a glance.
- Text does not overlap adjacent metrics, icons, gauges, or controls.
- Critical labels do not depend on very small compressed text.
- Buttons remain glove-friendly.
- Long IT/EN strings have wrapping, scaling, or scrolling.
- Live warning banners remain inline and do not hide depth/runtime/ascent information.
- Metric values remain legible when using imperial units or larger numeric values.
- Scrollable screens avoid dead zones or clipped bottom controls.

## 5. Positive Findings

### Central Typography And Layout

`Views/DiveUIComponents.swift` centralizes the Watch design tokens:
- `DiveUI.Typography` defines shared title, row, warning, metric, dashboard, hero, and button fonts.
- `DiveUI.Layout` defines touch-friendly min heights such as `settingsRowInteractiveMinHeight = 44`, `commandButtonMinHeight = 40`, and `compassActionMinHeight = 38`.
- `DiveCommandButton` uses `lineLimit(2)` and `minimumScaleFactor(0.85)`.
- `WatchSettingsRow` uses row title/subtitle limits and at least `44 pt` interactive height.

Static conclusion: the project has a solid UI foundation. Most fixes should be targeted refinements, not a redesign.

### Live Dive Screen

`Views/DiveLiveView.swift` keeps the primary information hierarchy strong:
- brand/logo/time/temperature top bar is compact.
- depth cards use `lineLimit` and `minimumScaleFactor`.
- stopwatch panel uses monospaced digits and a scale factor.
- controls reuse `DiveCommandButton`.
- safety banners are inline rather than full-screen blocking.

Static conclusion: the primary dive screen is broadly coherent with the premium Watch reference and is not currently a P0 font-fit risk.

### Warning Banners

`Views/AscentWarningBannerView.swift` and `Views/DepthSafetyLiveViews.swift` use:
- compact icon/text layouts.
- high-contrast red/yellow/orange styling.
- `lineLimit` and `minimumScaleFactor` on key text.
- minimum heights around `44 pt`.

Static conclusion: the warning system is fit-conscious and aligned with the underwater non-blocking warning philosophy.

## 6. Findings By Priority

### P1 - Full Computer Live Three-Column Metrics Can Become Too Compressed

Files:
- `Views/FullComputerLivePanels.swift:65`
- `Views/FullComputerLivePanels.swift:86`
- `Views/FullComputerLivePanels.swift:106`
- `Views/FullComputerLivePanels.swift:151`

Evidence:
- `FullComputerTopMetricsPanel` uses a two-column layout in NDL mode and a three-column layout in decompression mode.
- Metric values use `DiveUI.Typography.dashboardValue`, defined as `34 pt`.
- Values have `minimumScaleFactor(0.5)`.
- Decompression mode displays TTS, ceiling, and runtime in a single horizontal row.

Risk:
- The text will probably fit due to the scale factor, but at `0.5` it can become around `17 pt`, reducing premium underwater readability.
- Long TTS/runtime values, imperial conversion, or high ceilings can compress the central metrics.
- This is a UI/UX readability risk more than a hard clipping risk.

Recommended fix plan:
- Add Watch-size snapshot tests for decompression mode with TTS/runtime values of `99`, `120`, `240`, and ceiling with decimal/imperial formatting.
- Consider `ViewThatFits` or a two-row fallback for the three-column decompression panel on smaller watches.
- Keep visual style unchanged; only adjust layout resilience if screenshots prove compression.

### P1 - Full Computer Predive Settings Native Stepper Labels May Clip

Files:
- `Views/FullComputerPrediveSettingsView.swift:123`
- `Views/FullComputerPrediveSettingsView.swift:127`
- `Views/FullComputerPrediveSettingsView.swift:136`
- `Views/FullComputerPrediveSettingsView.swift:149`
- `Views/FullComputerPrediveSettingsView.swift:351`

Evidence:
- Native `Stepper` labels include long localized gas strings such as FO2, FHe, PPO2 max, and values.
- The labels use `DiveUI.Typography.rowSubtitle` but do not explicitly apply `lineLimit`, `minimumScaleFactor`, or `ViewThatFits`.
- Adjacent settings rows show title/value pairs with no explicit scaling on the value.

Risk:
- On watchOS, Stepper labels are constrained by the native control affordance.
- Italian strings and trimix values are likely to be longer than the available width.
- Because this is predive configuration, clipped gas/planner parameters would be a safety and usability concern.

Recommended fix plan:
- Screenshot-test predive gas setup on 41/45/49 mm with Italian and English.
- Add a no-code QA fixture matrix for Air, EAN, Trimix, GF, altitude/salinity/environment rows.
- If clipping is confirmed, keep the same look but split long Stepper labels into short title + value rows or use custom compact rows.

### P2 - Live Stopwatch Panel Can Over-Compress With Long Runtime Values

Files:
- `Views/DiveLiveView.swift:1082`
- `Views/DiveLiveView.swift:1089`
- `Views/DiveLiveView.swift:1090`
- `Views/DiveLiveView.swift:1102`

Evidence:
- Stopwatch panel uses `HStack(spacing: 15)`.
- Icon is `35 pt`.
- Time value is `39 pt`.
- Horizontal padding is `14 pt`.
- Time value has `minimumScaleFactor(0.66)`.

Risk:
- Typical `28:47` values fit well.
- Long values such as `123:45`, localized title pressure, or smaller Watch widths may force visible compression.
- This remains acceptable for common dives but should be hardened for edge cases.

Recommended fix plan:
- Add snapshot fixtures for stopwatch values: `28:47`, `99:59`, `123:45`, `999:59`.
- Consider a max display policy or responsive font step if the value exceeds five characters.

### P2 - Live Status Badges Can Squeeze Horizontal Text

Files:
- `Views/DiveLiveView.swift:786`
- `Views/DiveLiveView.swift:806`
- `Views/DiveLiveView.swift:826`

Evidence:
- `simulationDepthBadge`, `depthMockFallbackBadge`, and `hapticsOffBadge` use horizontal label rows.
- `hapticsOffBadge` contains two text labels separated by `Spacer`, but the text nodes do not both declare explicit line limits or scale factors.

Risk:
- With Italian localization, the right-side "visual only" wording can collide or truncate.
- The badge is non-primary but appears on the live dive surface, so it should remain clean.

Recommended fix plan:
- Use a screenshot fixture with haptics disabled + simulation depth + fallback state stacked.
- If needed later, convert the badge to a two-line layout on small widths.

### P2 - Ascent Gauge Fixed Width Needs Imperial And Localization QA

Files:
- `Views/AscentGaugeView.swift:11`
- `Views/AscentGaugeView.swift:17`
- `Views/AscentGaugeView.swift:21`
- `Views/AscentGaugeView.swift:24`
- `Views/AscentGaugeView.swift:27`
- `Views/AscentGaugeView.swift:130`

Evidence:
- Title and unit labels are fixed to `64 pt`.
- Scale label column is `27 pt`.
- Gauge bar is `31 x 126 pt`.
- Scale labels use `10 pt` monospaced digits with `minimumScaleFactor(0.75)`.

Risk:
- Metric mode is likely acceptable.
- Imperial `ft/min` and larger converted tick values may compress scale labels.
- Long localized title strings can shrink into two lines but need pixel validation.

Recommended fix plan:
- Run snapshot tests in metric and imperial mode.
- Include ascent bands at 1, 3, 5, 10 m/min and their imperial equivalents.
- Keep current gauge proportions unless actual overlap appears.

### P2 - Apnea Active Hero Depth And Vertical Speed Need Edge-Value QA

Files:
- `Views/ApneaView.swift:340`
- `Views/ApneaView.swift:348`
- `Views/ApneaView.swift:349`
- `Views/ApneaView.swift:365`
- `Views/ApneaView.swift:367`

Evidence:
- Active depth value uses `62 pt`.
- Vertical speed text uses `29 pt`.
- The depth value has `minimumScaleFactor(0.55)`.

Risk:
- Normal apnea values fit.
- Three-digit values, long unit variants, or simultaneous warning accents may compress.
- The screen already caps Dynamic Type to `.xSmall ... .accessibility2`, which helps fit.

Recommended fix plan:
- Validate apnea active/surface states on all target Watch sizes.
- Use maximum expected values in fixtures.

### P2 - Snorkeling Hero Row And Return Panel Need Long-Value QA

Files:
- `Views/SnorkelingView.swift:558`
- `Views/SnorkelingView.swift:560`
- `Views/SnorkelingView.swift:561`
- `Views/SnorkelingView.swift:292`
- `Views/SnorkelingView.swift:333`

Evidence:
- Hero metric value uses `40 pt` with `minimumScaleFactor(0.65)`.
- Waypoint name allows two lines with `minimumScaleFactor(0.7)`.
- Return distance uses dashboard typography.

Risk:
- Long waypoint names and large distance values are plausible in real use.
- Static code suggests the UI will fit, but readability can degrade on smaller screens.

Recommended fix plan:
- Test long waypoint names, `999 m`, `1.2 km`, GPS unavailable, and return advisor state.

### P3 - Compass Dial Is Fixed But Scroll-Contained

Files:
- `Views/CompassView.swift:18`
- `Views/CompassView.swift:22`
- `Views/CompassView.swift:100`
- `Views/CompassView.swift:138`

Evidence:
- Compass screen is inside `ScrollView`.
- Compass dial uses a fixed `156 x 156 pt` frame.
- Heading uses `36 pt` with `minimumScaleFactor(0.9)`.

Risk:
- No obvious clipping risk because the screen scrolls.
- On smaller watches, the dial can push controls below the fold, which is acceptable but should remain obvious.

Recommended fix plan:
- Confirm that bearing SET/CLEAR controls remain reachable without confusing scroll behavior on 41 mm.

### P3 - Dynamic Type Policy Is Not Uniform

Files:
- `Views/ApneaView.swift:42`
- `Views/SnorkelingView.swift:50`
- Many other Watch screens use fixed fonts without a screen-level `dynamicTypeSize` range.

Evidence:
- Only Apnea and Snorkeling declare `.dynamicTypeSize(.xSmall ... .accessibility2)`.
- Most Watch UI text is fixed-size `.system(size:)`.

Risk:
- Fixed fonts support layout predictability but reduce accessibility flexibility.
- The mismatch can produce inconsistent behavior across modes.

Recommended fix plan:
- Decide a Watch-wide Dynamic Type policy:
  - fixed-size underwater/live screens for safety-critical layout stability.
  - limited Dynamic Type range for settings/legal/logbook screens.
- Document the decision in UI guidelines before code changes.

## 7. Screen-Level Readiness Matrix

| Screen / Component | Fit Status | Risk | Notes |
|---|---:|---|---|
| Live Dive main depth/runtime | Good | Low | Large typography and scale factors are present. |
| Live stopwatch | Mostly good | P2 | Long elapsed values need test fixtures. |
| Live safety banners | Good | Low | Inline, high contrast, protected by line limits. |
| Ascent gauge | Mostly good | P2 | Fixed width needs imperial QA. |
| Full Computer top panel | Needs QA | P1 | Three-column decompression mode can over-compress. |
| Full Computer deco stop panel | Mostly good | P2 | Long stop time/depth values need fixtures. |
| Full Computer predive settings | Needs QA | P1 | Native Stepper labels are the main clipping risk. |
| Compass | Mostly good | P3 | Fixed dial is scroll-contained. |
| Settings rows | Improved from previous audit | P2 | Shared row component is safer, but dense text remains. |
| Legal onboarding | Good | Low | Scroll and fixedSize protect long copy. |
| Dive log/detail | Mostly good | P2 | Dense rows should be screenshot-tested with long sites/dates. |
| Apnea | Mostly good | P2 | Dynamic Type range exists; hero values need edge tests. |
| Snorkeling | Mostly good | P2 | Long waypoint/distance values need edge tests. |
| User Images | Mostly good | P2 | Captions/buttons are compact; image overlays need pixel QA. |

## 8. Required Visual QA Matrix

Before declaring this area release-hard, run screenshot or physical-device QA for:

Devices:
- Apple Watch 41 mm
- Apple Watch 45 mm
- Apple Watch Ultra / 49 mm

Locales:
- Italian
- English

Units:
- Metric
- Imperial

States:
- normal live dive
- manual dive active
- automatic depth active
- haptics disabled
- simulation depth active
- depth mock fallback
- ascent warning active
- depth caution / critical / exceeded
- full computer no-deco
- full computer decompression with TTS/ceiling/runtime
- ceiling violation
- full computer predive Air / EAN / Trimix
- apnea active/surface/recovery summary
- snorkeling waypoint/return/GPS unavailable
- compass with and without bearing
- legal disclaimer with long copy

Edge values:
- depth `0.0`, `21.4`, `40.0`, `99.9`
- stopwatch `28:47`, `99:59`, `123:45`, `999:59`
- TTS/runtime `5`, `99`, `120`, `240`
- ceiling `3.0`, `6.0`, `21.0`, imperial equivalents
- waypoint name > 24 characters
- distance `999 m`, `1.2 km`
- gas labels: `AIR`, `EAN32`, `TRIMIX 18/45`, `OXYGEN`

## 9. Recommended Remediation Plan

Do not redesign. Keep the premium Watch UI.

1. Add screenshot fixtures for the risk matrix above.
2. Add SwiftUI snapshot checks or view-contract tests that assert text containers remain within expected frame boundaries where possible.
3. Harden `FullComputerTopMetricsPanel` with a fallback layout only if screenshot QA shows over-compression.
4. Harden Full Computer predive `Stepper` rows if IT/EN fixtures show clipping.
5. Add a small watch-wide typography policy document for Dynamic Type behavior.
6. Add a "minimum readable scale" rule: avoid planned production states that require values below roughly `0.7` scale on safety-critical metrics.
7. Re-run screenshots after every new Watch feature touching live surfaces.

## 10. Final Verdict

The Apple Watch UI is broadly aligned with the premium DIR DIVING underwater visual language and has no static P0 font-fit blocker.

The P1/P2/P3 static code risks identified in this audit have been remediated with UI-only SwiftUI changes. The code is still not pixel-certified release-hard because there is no current rendered proof across Watch sizes, IT/EN, metric/imperial, and edge-value states. The highest-priority QA areas remain Full Computer live metrics and predive gas settings.

This audit/remediation pass modified only Watch SwiftUI layout/font-fitting code and documentation.
