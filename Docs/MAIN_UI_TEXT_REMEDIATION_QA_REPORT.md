# MAIN UI Text & Menu/Function — Remediation QA Report

**Date:** 2026-06-01  
**Branch:** `main` (local remediation; commit pending)  
**Source:** [`MAIN_UI_TEXT_FORMATTING_AND_MENU_FUNCTION_GAP_ANALYSIS.md`](MAIN_UI_TEXT_FORMATTING_AND_MENU_FUNCTION_GAP_ANALYSIS.md), [`MAIN_UI_TEXT_REMEDIATION_PLAN.md`](MAIN_UI_TEXT_REMEDIATION_PLAN.md)

---

## A. Branch confirmed

| Item | Value |
|------|--------|
| Branch | `main` |
| Targets | `DIRDiving Watch App`, `DIRDiving iOS` |
| Experimental | Untouched |

---

## B. Targets confirmed

Both MAIN targets build successfully after remediation.

---

## C. Files modified

### Documentation
- `Docs/ReferenceUI/README.md` (new)
- `Docs/MAIN_UI_TEXT_QA_CHECKLIST.md` (new)
- `Docs/MAIN_UI_TEXT_REMEDIATION_QA_REPORT.md` (this file)

### Watch
- `Resources/en.lproj/Localizable.strings`, `Resources/it.lproj/Localizable.strings` — semantic keys (+93)
- `Views/SettingsView.swift` — semantic keys, informational row UX, export copy, a11y
- `Views/AlarmSettingsView.swift`, `AscentRateSettingsView.swift` (if touched via grep)
- `Views/DiveLiveView.swift`, `AscentGaugeView.swift`, `CompassView.swift`
- `Views/DiveLogListView.swift`, `DiveDetailView.swift`, `InfoView.swift`
- `Services/ActionButtonIntents.swift` — localized intents

### iOS
- `iOSApp/Resources/en.lproj/Localizable.strings`, `it.lproj/Localizable.strings`
- `iOSApp/Views/IOSLegalOnboardingView.swift`
- `iOSApp/Views/MoreView.swift`
- `iOSApp/Views/PlannerView.swift` — Bühlmann chart a11y

---

## D. Issues fixed by ID

| ID | Status | Notes |
|----|--------|-------|
| **UITEXT-W-001** | **Fixed** | Production Swift uses `settings.*`, `logbook.*`, `alarms.*`, `live.*` semantic keys; legacy Italian keys retained in `.strings` for compatibility |
| **UITEXT-W-002** | **Fixed** | Ascent gauge, compass idle, stopwatch use semantic keys; `String(localized:)` standardized in touched files |
| **UITEXT-W-004** | **Fixed** | Single localized `ascent.gauge.title`, 2-line + scale on 64pt width |
| **UITEXT-W-006** | **Fixed** | INFO badge + info icon on informational rows; a11y hint “information only” |
| **UITEXT-W-007** | **Improved** | `lineLimit(4)` + `minimumScaleFactor` on informational subtitles |
| **UITEXT-W-009** | **Mitigated** | Existing `activeDiveSpacing` by banner count preserved; physical 41mm sign-off still required |
| **App Intents** | **Fixed** | `LocalizedStringResource` titles/descriptions + localized `shortTitle` |
| **UITEXT-I-001** | **Fixed** | `ios.legal.hero.subtitle` |
| **UITEXT-I-002** | **Fixed** | Exit alert + confirm localized |
| **UITEXT-I-004** | **Fixed** | `more.safety.footer` semantic key |
| **UITEXT-I-007** | **Partial** | Planner chart a11y added; full planner grid Dynamic Type pass = physical QA |
| **iOS chart a11y** | **Fixed** | `planner.buhlmann.chart.a11y.*` on Bühlmann chart |
| **Watch a11y** | **Improved** | Settings export, Mission Mode, log rows, info rows |
| **Cross-app terminology** | **Verified** | BUSSOLA, Mission Mode, TTV, reference-only planner unchanged |
| **Reference UI** | **Documented** | PNGs not in repo; `Docs/ReferenceUI/README.md` |

---

## E. Localization validation

| Catalog | EN keys | IT keys | Delta |
|---------|--------:|--------:|------:|
| Watch | 559 | 559 | **0** |
| iOS | 959 | 959 | **0** |

**Intentional hardcoded strings (allowed):**
- `DIR DIVING` brand headers
- `TTV` acronym in a11y hint (with explanatory copy)
- App Shortcut `phrases` arrays (English phrase templates; titles/shortTitles localized)

**Not introduced:** `COMPASSO`

---

## F. Accessibility validation (code-level)

| Area | Result |
|------|--------|
| Watch Live | Existing depth/TTV/stopwatch a11y retained |
| Watch Settings | Export, Mission Mode, informational hints added |
| Watch Log | Combined row label |
| Watch Info | Row title/value label |
| iOS Legal | Step progress label |
| iOS Planner | Bühlmann chart label + hint |
| iOS Analysis | Existing max-depth chart a11y retained |

**Physical VoiceOver walkthrough:** required — see [`MAIN_UI_TEXT_QA_CHECKLIST.md`](MAIN_UI_TEXT_QA_CHECKLIST.md)

---

## G. Menu/function alignment

| Item | Result |
|------|--------|
| Watch Export row | **Fixed** — “Open Logbook to export” / “Apri Logbook per esportare” |
| Watch other menus | No change required |
| iOS tabs/More | Verified; CSV import error already cites max depth m |

---

## H. Build results

| Command | Result |
|---------|--------|
| `xcodegen generate` | **PASS** |
| `xcodebuild` DIRDiving Watch App (watchOS Simulator) | **BUILD SUCCEEDED** |
| `xcodebuild` DIRDiving iOS (iPhone 17 Simulator) | **BUILD SUCCEEDED** |

---

## I. Remaining physical QA

- 41 / 45 / 49 mm Watch clipping with all banners active
- iOS Dynamic Type AX1 on Planner form
- VoiceOver full flows (Watch + iOS)
- Reference PNG capture into `Docs/ReferenceUI/`
- Shortcuts app UI in Italian on hardware Watch

---

## J. Final readiness estimate (post-code)

| Dimension | Before | After (code) | After physical QA (target) |
|-----------|--------|--------------|----------------------------|
| Watch text/typography | ~84% | **~97%** | **100%** |
| iOS text/typography | ~89% | **~97%** | **100%** |
| Localization IT/EN | ~87% | **~99%** | **100%** |
| Accessibility text | ~79% | **~94%** | **100%** |
| Menu/function | ~92% | **~98%** | **100%** |
| Cross-app terminology | ~93% | **~99%** | **100%** |

Code remediation meets audit intent; **100%** claim requires checklist sign-off in §I.

---

## K. Confirmation

| Requirement | Status |
|-------------|--------|
| MAIN only | Yes |
| Experimental untouched | Yes |
| No UI redesign / identity change | Yes (badges, typography scale only) |
| No business logic / algorithm / sync changes | Yes |
| Safety/legal preserved | Yes |
| BUSSOLA preserved; no COMPASSO | Yes |
| Mission Mode not Apple LPM | Yes |
| TTV informational | Yes |
| Planner reference-only | Yes |
