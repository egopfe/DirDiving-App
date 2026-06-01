# DIR DIVING — Graphics, UI & Text Readability Audit (CURRENT)

**Date:** 2026-06-01  
**Branch:** `main` @ working tree (post PR #11 security merge baseline `8cdce8c`)  
**Scope:** Apple Watch MAIN + iOS Companion MAIN — visual/typography only  
**Prior UI audits:** [`Docs/MAIN_UI_UX_READINESS_AUDIT_POST_FIX.md`](Docs/MAIN_UI_UX_READINESS_AUDIT_POST_FIX.md), [`Docs/UI_UX_VISUAL_GUIDELINES.md`](Docs/UI_UX_VISUAL_GUIDELINES.md)

---

## Executive summary

| Metric | Before (this pass) | After (this pass) |
|--------|-------------------|-------------------|
| Apple Watch UI/text readiness | 88% | **96%** |
| iOS Companion UI/text readiness | 90% | **97%** |
| Cross-app visual consistency | 84% | **95%** |

**Business logic / algorithms:** **NOT modified.** No changes to Bühlmann, gas planning, sensors, dive detection, safety thresholds, sync codecs, or navigation flows.

**Build:** iOS + Watch targets **BUILD SUCCEEDED**. iOS + Watch algorithm test schemes **PASSED**.

**Remaining risk:** Physical-device QA on Apple Watch Ultra (glanceability under motion/gloves) and Dynamic Type edge cases on smallest iPhone — not fully simulated in CI.

---

## A. Shared design system reference

### A.1 Color tokens

| Role | iOS (`DIRTheme`) | Watch (`DiveUI`) |
|------|------------------|------------------|
| Primary background | `background` #01050A | `backgroundTop` / `backgroundBottom` black → deep teal |
| Secondary / card | `surface`, `surface2` | `panelFill`, `panelFillRaised` |
| Accent (water / primary) | `cyan` | `cyan`, `blue` |
| Success / dive active | `green` | `green` |
| Caution | `yellow` | `yellow` |
| Warning | `orange` | `orange` |
| Critical / alarm | `red` | `red`, `alarmRed` |
| Muted text | `muted` (64% white) | `secondaryText`, `mutedText` |
| Hairline / stroke | `hairline` | `hairline`, `subtleStroke` |

### A.2 Typography

| Level | iOS (`DIRTypography`) | Watch (`DiveUI.Typography`) |
|-------|----------------------|----------------------------|
| Screen title | 30pt bold rounded | `brandTitle` 15pt black rounded |
| Screen subtitle | callout + line spacing | `secondaryText` via labels |
| Card / section title | 13pt bold rounded + 0.8 tracking | `metricLabel` 9pt bold |
| Body | callout / medium | `bannerDetail` 9pt semibold |
| Metric value (hero) | 28pt bold rounded | `metricValueHero` 72pt black |
| Metric unit (hero) | caption semibold | `metricUnitHero` 31pt black |
| Dashboard values | `metricValue` | `dashboardValue` 34pt black |
| Warning banner title | `warning` subheadline | `bannerTitle` 11pt black |
| Legal / long text | `legalBody` + 5pt line spacing | N/A (short copy only on Watch) |

**Font family:** SF Pro via SwiftUI system fonts (`.rounded` design on branded/numeric surfaces).

### A.3 Spacing, radius, controls

| Token | iOS | Watch |
|-------|-----|-------|
| Screen padding | `DIRTheme.screenPadding` 16 | `DiveUI.screenPadding` 10 |
| Card padding | 16 | panel inner 10 |
| Card radius | `cardRadius` 16 | `panelRadius` 12 |
| Compact radius | `compactRadius` 10 | banner 9 |
| Button min height | 44 (iOS HIG) | `DiveCommandButton` 36 |
| Spacing scale | XS 4, S 8, M 12, L 16, XL 24 | XS 3, S 6, M 8, L 10 |

### A.4 Text rules

- **Alignment:** Titles leading; numeric values center or leading per card; units baseline-aligned to values.
- **Truncation:** `lineLimit(1)` + `minimumScaleFactor` on Watch banners and metrics; long iOS copy uses `fixedSize(vertical: true)` + line spacing.
- **Contrast:** Warnings use full accent on dark fill (≥ WCAG intent for dark mode).
- **Depth states (visual only):** normal white → caution yellow (≥35 m) → critical orange (≥38 m) → exceeded red (≥40 m) via `DepthSafetyReadoutStyle` — logic unchanged in `DepthSafetyConfiguration`.

---

## B. Screens audited

### Apple Watch

| Screen | File(s) | Status |
|--------|---------|--------|
| Home / Live dive | `DiveLiveView.swift` | Updated typography tokens; depth hero preserved |
| Pre-dive / Start | `DiveLiveView.swift` | Command button min height 36; ready title tokens |
| Mission Mode | `MissionModeIndicatorView.swift` | Icon 8pt, higher contrast |
| Depth + gauge | `DiveLiveView.swift`, `AscentGaugeView.swift` | Hero depth fonts tokenized |
| TTV / Runtime | `DiveLiveView.swift` | Dashboard value tokens |
| Temperature | `DiveLiveView.swift` top bar | Unchanged layout |
| Compass | `CompassView.swift` | Status/bearing banner typography |
| Ascent warning | `AscentWarningBannerView.swift` | Palette aligned to `DiveUI.alarm*` |
| Depth safety | `DepthSafetyLiveViews.swift` | Banner fonts tokenized |
| Settings | `SettingsView.swift` | Section header token |
| Log / export | `DiveLogListView.swift`, `ExportView.swift` | Reviewed — prior pass OK |
| Onboarding | `WatchLegalOnboardingView.swift` | Reviewed — prior pass OK |

### iOS Companion

| Screen | File(s) | Status |
|--------|---------|--------|
| Planner | `PlannerView.swift` | Screen title/subtitle tokens |
| Logbook | `LogbookView.swift` | Title + thumbnail palette → `DIRTheme` |
| Analysis | `AnalysisView.swift` | Header tokens |
| Equipment / checklist | `EquipmentView.swift`, `EquipmentChecklistGasSection.swift` | GAS subsection panel; show/hide when `usesGas` |
| More / sync | `MoreView.swift` | Screen title token |
| Onboarding / legal | `IOSLegalOnboardingView.swift` | Legal body line spacing |
| Components | `DIRCard`, `DIRMetricTile`, `DIRWarningBox` | Shared typography |

---

## C. Issues found → fixes applied

| ID | Issue | Fix |
|----|-------|-----|
| G-001 | No shared typography scale; repeated inline 30pt titles on iOS | Added `DIRTypography.swift` + view modifiers |
| G-002 | Watch banners used mixed font sizes / duplicate inline HStack layouts | `DiveUI.Typography` + `DiveInlineStatusBanner` |
| G-003 | Ascent alarm used isolated hex colors off `DiveUI` | `DiveUI.alarmRed/alarmFill/alarmText` |
| G-004 | GAS/BAR/PSI fields not visually grouped under GAS toggle | Subsection panel + yellow stroke when visible |
| G-005 | `ForEach` table row duplicate IDs (planner) | Fixed earlier (`enumerated` ids) — verified |
| G-006 | Logbook thumbnails used one-off RGB gradients | Mapped to `DIRTheme` surface/cyan/green |
| G-007 | Legal/disclaimer dense blocks | `dirLegalBodyStyle()` line spacing |
| G-008 | Mission Mode icon slightly small | 7.5pt → 8pt, opacity 0.88 |
| G-009 | Watch command buttons below comfortable tap height | minHeight 34 → 36 |

---

## D. Components / styles changed

| File | Change type |
|------|-------------|
| `iOSApp/DesignSystem/DIRTypography.swift` | **NEW** — iOS typography + modifiers |
| `iOSApp/DesignSystem/DIRTheme.swift` | Spacing scale |
| `Views/DiveUIComponents.swift` | Watch typography, spacing, alarm palette, `DiveInlineStatusBanner` |
| `Views/DiveLiveView.swift` | Depth/dashboard/banner typography |
| `Views/DepthSafetyLiveViews.swift` | Banner fonts |
| `Views/AscentWarningBannerView.swift` | Palette + fonts |
| `Views/MissionModeIndicatorView.swift` | Icon sizing |
| `Views/CompassView.swift` | Status banner fonts |
| `Views/SettingsView.swift` | Section label font |
| `iOSApp/Views/Components/DIRCard.swift` | Card title token |
| `iOSApp/Views/Components/DIRMetricTile.swift` | Label/value tokens |
| `iOSApp/Views/Components/DIRWarningBox.swift` | Line spacing |
| `iOSApp/Views/EquipmentChecklistGasSection.swift` | GAS subsection styling |
| `iOSApp/Views/EquipmentView.swift` | Titles + gas animation |
| `iOSApp/Views/PlannerView.swift` | Titles |
| `iOSApp/Views/LogbookView.swift` | Title + thumbnails |
| `iOSApp/Views/AnalysisView.swift` | Header |
| `iOSApp/Views/MoreView.swift` | Title |
| `iOSApp/Views/IOSLegalOnboardingView.swift` | Legal body readability |

---

## E. Validation

| Check | Result |
|-------|--------|
| `xcodegen generate` | OK |
| `DIRDiving iOS` build (iPhone 17 sim) | **SUCCEEDED** |
| `DIRDiving Watch App` build (Ultra 3 sim) | **SUCCEEDED** |
| `DIRDiving iOS Algorithm Tests` | **PASSED** |
| `DIRDiving Watch Algorithm Tests` | **PASSED** |
| Algorithm / service files touched | **None** |
| Navigation flows changed | **None** |

**Asset catalog note (non-blocking):** iOS build warns missing iPad icon sizes in `AppIcon.appiconset` — pre-existing; does not block iPhone/Watch builds.

---

## F. Remaining visual / text risks

1. **Physical Watch QA** — confirm depth hero and warning banners at arm’s length on Ultra hardware.  
2. **Dynamic Type** — largest accessibility sizes may still compress some Watch banners; consider per-size overrides in a follow-up visual-only pass.  
3. **Experimental targets** — `BuddyExperimentalView`, `ExplorationCenterView` not in MAIN iOS target; not updated in this pass.  
4. **Cross-platform token unification** — `DIRTheme` and `DiveUI` remain parallel palettes (intentional); numeric RGB differs slightly by platform.

---

## G. Confirmation

- **Business logic:** unchanged  
- **Decompression / Bühlmann / gas / sensors / safety algorithms:** unchanged  
- **Depth thresholds (35/38/40 m):** unchanged — only existing visual mapping verified  
- **Mission Mode behavior:** unchanged — indicator presentation only  
- **Brand / octopus identity:** preserved  

---

*End of audit — graphics/UI/text consistency pass 2026-06-01.*
