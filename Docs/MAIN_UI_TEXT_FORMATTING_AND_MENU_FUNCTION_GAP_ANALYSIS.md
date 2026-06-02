# MAIN UI Text Formatting & Menu/Function Gap Analysis

**Audit date:** 2026-06-01  
**Branch:** `main` @ `34fe880`  
**Working tree:** clean  
**Mode:** Read-only — **no code modified**  
**Targets:** `DIRDiving Watch App`, `DIRDiving iOS` (Companion MAIN only)

---

## A. Executive Summary

| Dimension | Watch MAIN | iOS MAIN | Cross-app |
|-----------|----------:|---------:|----------:|
| **Text / typography readiness** | **~84%** | **~89%** | — |
| **Menu / function consistency** | **~91%** | **~93%** | **~92%** |
| **Localization readiness (IT/EN)** | **~86%** | **~88%** | **~87%** |
| **Accessibility text readiness** | **~76%** | **~82%** | **~79%** |
| **Safety copy correctness** | **~92%** | **~94%** | **~93%** |

**Overall UI text & menu alignment (code/static audit): ~87%.**

### Headline findings

1. **Localization key parity is complete** (466 Watch keys, 949 iOS keys — zero EN/IT mismatches in `.strings` catalogs).
2. **Watch still relies heavily on Italian literals used as localization keys** (`String(localized: "IMPOSTAZIONI")`, `"Velocità risalita"`, etc.). EN translations exist, but maintainability and translator workflow are weak.
3. **Several Watch surfaces use hardcoded `Text("…")` literals** (ascent gauge header, compass idle copy, stopwatch label, brand headers). Most have EN entries in `Localizable.strings` via `LocalizedStringKey`, but this is inconsistent with `String(localized:)` usage elsewhere.
4. **iOS legal onboarding** mixes localized `Text("key")` with **unlocalized** hero strings (`"iOS Companion"`, alert titles) and English-only `warningRow` keys on the safety screen.
5. **Menu ↔ function alignment is generally strong** (prior UX audit confirmed; re-verified in code). Residual gaps: Watch **Export** row in Settings navigates to logbook (discoverability), **ModeSelectionView** dormant unless multi-mode flag, App Intents **English-only** in Shortcuts catalog.
6. **Reference UI assets missing** from repo (`Docs/ReferenceUI/*.png` not present) — physical clipping QA cannot be signed off from screenshots in-repo.
7. **Accessibility:** Live Dive and Planner are relatively strong; Watch Settings/Log/Detail/Info have **sparse** `accessibilityLabel` coverage; iOS **Bühlmann chart** has no chart summary for VoiceOver.

### What blocks “100%” (excluding external field QA)

| Blocker class | Examples |
|---------------|----------|
| Localization hygiene | Italian-as-key pattern (Watch); missing IT for `"iOS Companion"`; long Italian sentence used as key in `MoreView` footer |
| Hardcoded / mixed patterns | Watch `CRONOMETRO`, `VELOCITA`/`RISALITA` split lines; iOS legal alert strings |
| Accessibility | Watch settings rows; iOS Analysis charts; custom tabs selected-state hints |
| Typography risk | Watch 8–10 pt secondary copy on 41 mm; iOS Planner dense grids without `lineLimit`/`minimumScaleFactor` on all fields |
| Process | No in-repo reference PNGs; Dynamic Type / 41–49 mm clipping requires simulator/device pass |

---

## B. Scope Confirmation

| Item | Status |
|------|--------|
| Branch | `main` @ `34fe880` |
| Watch target | `DIRDiving Watch App` — sources: `App/`, `Models/` (excl. exploration/buddy models), `Services/` (excl. buddy/exploration), `Views/` (excl. Apnea, Snorkeling, BuddyAssist, ExperimentalConcepts), `Utils/`, `Resources/` |
| iOS target | `DIRDiving iOS` — `iOSApp/` excl. Exploration/Buddy experimental views & stores |
| Experimental untouched | Yes (excluded from `project.yml` as listed in audit command) |
| Visual references | **Missing:** `Docs/ReferenceUI/Watch_LIVE_reference.png`, `Docs/ReferenceUI/iOS_Companion_reference.png` |
| Code changes | **None** |

### Files inspected (representative)

**Watch:** `Views/ContentView.swift`, `DiveLiveView.swift`, `CompassView.swift`, `SettingsView.swift`, `AlarmSettingsView.swift`, `AscentRateSettingsView.swift`, `DiveLogListView.swift`, `DiveDetailView.swift`, `ExportView.swift`, `InfoView.swift`, `WatchLegalOnboardingView.swift`, `MissionModeIndicatorView.swift`, `AscentGaugeView.swift`, `AscentWarningBannerView.swift`, `DepthSafetyLiveViews.swift`, `ModeSelectionView.swift`, `LaunchCompanionDisclaimerOverlay.swift`, `DiveUIComponents.swift`, `Services/ActionButtonIntents.swift`, `Resources/*/Localizable.strings`

**iOS:** `iOSApp/Views/ContentView.swift`, `LogbookView.swift`, `DiveDetailView.swift`, `ManualDiveEditorView.swift`, `AnalysisView.swift`, `PlannerView.swift` (+ `PlanResultView`), `EquipmentView.swift`, `MoreView.swift`, `CSVImportPanel.swift`, `IOSLegalOnboardingView.swift`, `LaunchCompanionDisclaimerOverlay.swift`, `WatchPhotoTransferPanel.swift`, components, `iOSApp/Resources/*/Localizable.strings`

**Cross-reference:** `Docs/MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_CURRENT.md`

---

## C. Apple Watch — Text Formatting Audit

### C.1 Screen inventory

| Screen | Primary strings source | Typography notes | Clipping / readability risk |
|--------|------------------------|------------------|----------------------------|
| Legal onboarding | Localized keys + `Text` literals | Rounded black 10–18 pt | Low |
| Launch disclaimer | Localized | Compact banner | Low |
| Live Dive | Mixed keys + `DIR DIVING`, `CRONOMETRO` | Depth hero large; TTV/runtime dashboard; banners 10–13 pt | **Medium** on 41 mm when GPS + depth + mission + sync badges stack |
| Mission Mode indicator | `mission_mode.*` keys | Icon-only + a11y labels | Low |
| Ascent gauge | **Hardcoded** `VELOCITA`/`RISALITA` 10 pt | Narrow column 64 pt width | **Medium** — label stack tight |
| Ascent warning banner | `ascent_alarm_*` keys | Inline, non-modal | Low — does not block depth (by design) |
| Depth safety | `depth.safety.*` | Banner title 3-line limit | Low–medium at 40 m exceeded (dual banner) |
| GPS banners | Localized compact | Yellow/cyan, 2-line caps in Live | Low |
| Stale depth | `live.depth.stale.*` | Yellow label swap | Low |
| Stopwatch | `CRONOMETRO` + START/STOP/RESET | Command buttons | Low |
| BUSSOLA | `BUSSOLA` a11y; SET/CLEAR localized | Heading 20 pt in metrics | Low |
| Settings | **Italian-as-key** rows | 11 pt title / 10 pt subtitle, informational 3 lines | **Medium** — long GPS behavior subtitle |
| Ascent rate settings | Localized + Crown UI | Stepper labels | Low (disabled underwater) |
| Alarm settings | Italian-as-key section | Crown threshold rows | Low |
| Legal & Safety | English keys in IT file too | Red NOT A DIVE COMPUTER | Low |
| Shortcut help | `shortcuts.help.*` | 9 pt body | Medium on small watch |
| Info / diagnostics | Mixed | Caption diagnostics | Low |
| Dive log list | `IMMERSIONI`, export messages | List rows | Low |
| Dive detail | Export/delete Italian keys | Buttons | Low |
| Export | Share CSV | Low | |
| User images | Brand header | Empty state localized | Low |
| Mode selection | `mode.selection.*` | Hidden unless multi-mode | N/A in default MAIN |

### C.2 Watch issues (text / typography)

| ID | Sev | Title | Screen | File | Issue |
|----|-----|-------|--------|------|-------|
| UITEXT-W-001 | MED | Italian literals as localization keys | Settings, alarms, log | `SettingsView.swift`, `AlarmSettingsView.swift` | Keys like `"IMPOSTAZIONI"`, `"Velocità risalita"` work (EN mapped) but confuse translators and grep; risk of untranslated new keys |
| UITEXT-W-002 | MED | Inconsistent localization API | Live, compass, gauge | `DiveLiveView.swift`, `CompassView.swift`, `AscentGaugeView.swift` | Mix of `String(localized:)`, `Text("literal")`, and hardcoded Italian; harder to audit |
| UITEXT-W-003 | LOW | Brand header not localized | Most screens | Multiple | `Text("DIR DIVING")` is intentional branding; acceptable |
| UITEXT-W-004 | MED | Ascent gauge label uses two lines | Live | `AscentGaugeView.swift` | `VELOCITA` / `RISALITA` at 10 pt; EN catalog has `ASCENT`/`RATE` but layout may truncate on 41 mm |
| UITEXT-W-005 | LOW | Stopwatch title `CRONOMETRO` | Live | `DiveLiveView.swift` | Localized via key; Italian-forward key name |
| UITEXT-W-006 | MED | Informational settings rows resemble actions | Settings | `SettingsView.swift` | Same chrome as navigable rows; `informational: true` only lowers opacity — no “info only” badge |
| UITEXT-W-007 | LOW | Long GPS disclaimer in settings | Settings | `SettingsView.swift` | 3-line subtitle; correct but dense |
| UITEXT-W-008 | INFO | `Metrico (m)` / `Imperial (ft)` picker tags | Settings | `SettingsView.swift` | Hardcoded picker labels (not keys) |
| UITEXT-W-009 | MED | Live layout stacking | Live | `DiveLiveView.swift` | Multiple badges (sync count, mission, haptics-off, GPS) — static audit cannot confirm 41/45/49 mm non-overlap |

**Terminology:** No `COMPASSO` in MAIN Watch sources. `BUSSOLA` preserved (`Resources/en.lproj`: `"BUSSOLA" = "COMPASS"` for EN UI label only). Mission Mode copy includes Apple LPM disclaimer (`settings.mission_mode.apple_lpm_disclaimer`).

---

## D. Apple Watch — Menu / Function Gap Analysis

| Menu / control | Label (summary) | Actual function | Reachable | Mismatch? | Priority |
|----------------|-----------------|-----------------|-----------|-----------|----------|
| Vertical pages: Live | (implicit) | Live dive UI | Yes | No | — |
| BUSSOLA tab | `BUSSOLA` | Compass, bearing SET/CLEAR | Yes | No | — |
| Settings tab | `IMPOSTAZIONI` | Settings hub | Yes | No | — |
| User images tab | Images | Surface photo gallery | Yes | No | — |
| Dive log tab | `IMMERSIONI` | Session list | Yes | No | — |
| Ascent rate row | Velocità risalita | `AscentRateSettingsView` | Yes | No | P3 |
| Alarms row | Allarmi | `AlarmSettingsView` | Yes | No | — |
| Mission Mode toggles | Modalità Missione | Runtime UI profile only; no math change | Yes | No | — |
| Export row | Export | **Navigates to dive log**, not inline export | Yes | **Partial** — label implies export here; export is in log/detail | P2 |
| Sync rows | Status / pending / sent | Read-only + retry/clear | Yes | No | — |
| Manual start row | Avvio manuale | Informational when auto available | Yes | No | — |
| Shortcut help | SHORTCUT / help | `WatchShortcutHelpView` | Yes | No | — |
| Info row | Info | `InfoView` diagnostics | Yes | No | — |
| Underwater navigation | Crown pages | Blocks non-Live/Compass with toast | Yes | No | — |
| App Intents | English titles | Stopwatch, manual dive, bearing, etc. | Shortcuts app | **EN-only** in `ActionButtonIntents.swift` | P1 |
| Mode selection | Diving selector | Hidden when single stable mode | Conditional | No user confusion in default SKU | INFO |

**Watch menu/function verdict:** **~91% aligned.** Main gap: **Export** settings row is a **navigation shortcut**, not an export action (copy could say “Open logbook to export” — already partially in `settings.export.from_logbook` subtitle).

---

## E. iOS — Text Formatting Audit

### E.1 Screen inventory

| Screen | Localization | Typography | Risk |
|--------|--------------|------------|------|
| Legal onboarding | Mixed `Text("key")` + **unlocalized** hero | Large titles, cards | **Medium** — `"iOS Companion"` stays EN in IT |
| Launch disclaimer | Localized overlay | Standard | Low |
| Tab bar | `tab.*` keys | System tab bar | Low |
| Logbook | Keys + demo badges | Search, sections | Low |
| Dive detail | Keys + metric tiles | GPS footnotes multi-line | Medium Dynamic Type |
| Manual editor | Keys + unit conversion | Steppers | Low |
| Analysis | `AnalysisDashboardMath` + charts | Chart legends | Medium — chart a11y |
| CSV import | Panel in More + Analysis | Error rows | Low |
| Planner | Extensive `planner.*` | Dense forms, Bühlmann chart | **Medium** — long disclaimers |
| Plan result | Embedded in PlannerView | Tabs PLAN/BUHLMANN/CHARTS | Low |
| Equipment | Localized checklist | Cards | Low |
| More | Keys; **footer uses Italian sentence as key** | Warning box multi-line | Low |
| Watch sync / iCloud | Truthful state strings | Conflict cards | Low |
| Watch photos | Panel | Low | |

### E.2 iOS issues (text / typography)

| ID | Sev | Title | Screen | File | Issue |
|----|-----|-------|--------|------|-------|
| UITEXT-I-001 | MED | `"iOS Companion"` not in IT catalog | Legal onboarding | `IOSLegalOnboardingView.swift` | Stays English when app language is Italian |
| UITEXT-I-002 | MED | Alert `Exit App` / `I Understand` hardcoded | Legal onboarding | `IOSLegalOnboardingView.swift` | `.alert("Exit App", …)` not using `String(localized:)` |
| UITEXT-I-003 | LOW | `DIRCard("Welcome", …)` English key | Legal onboarding | Same | Works via `LocalizedStringKey` if keys exist |
| UITEXT-I-004 | LOW | Footer disclaimer key is full Italian sentence | More | `MoreView.swift` | Works EN/IT but unmaintainable (`DIR DIVING e uno strumento…`) |
| UITEXT-I-005 | INFO | Planner reference copy post-remediation | Planner | `PlannerView.swift` | NDL chart disclaimer + model-backed axes — **aligned** with algorithm audit |
| UITEXT-I-006 | MED | Planner incomplete-calculation banner | Planner | `PlannerView.swift` | Clear EN/IT — good safety UX |
| UITEXT-I-007 | MED | Dynamic Type on dense planner grids | Planner | `PlannerView.swift` | Few `minimumScaleFactor` uses in main planner form |
| UITEXT-I-008 | LOW | Tab labels vs internal enum | Tabs | `ContentView.swift` | `IOSTab.settings` → label “More” — consistent |

---

## F. iOS — Menu / Function Gap Analysis

| Menu / tab | Label | Function | Reachable | Mismatch? | Priority |
|------------|-------|----------|-----------|-----------|----------|
| Planner | Planner | Bühlmann reference plan, gas, result | Yes | No | — |
| Logbook | Logbook | List, search, manual add, delete | Yes | No | — |
| Analysis | Analysis | Aggregates, charts, CSV import | Yes | No | — |
| Equipment | Equipment | Checklist, templates, gas section | Yes | No | — |
| More | More | Settings, sync, cloud, legal, import | Yes | No | — |
| Logbook `+` | Add manual | `ManualDiveEditorView` | Yes | No | — |
| Dive detail export | Share CSV | `SubsurfaceExportService` | Yes | No | — |
| Demo toggle | Reviewer | Shows demo in logbook; analysis excludes by default | Yes | No | — |
| Push to Watch | Button | `syncUnpushedSessionsToWatch()` | Yes | No | — |
| Reset pairing | Destructive | Clears trust with confirm | Yes | No | — |
| iCloud sync now | Button | `logStore.synchronizeCloud()` | Yes | No | — |
| Conflict cards | Use Watch / Keep iPhone | Merge resolution | Yes | No | — |
| CNS 15% toggle | More | Planner-only rule | Yes | No | — |
| Units picker | More | Syncs to Watch when paired | Yes | Partial — planner internal metric noted in strings | P3 |

**iOS menu/function verdict:** **~93% aligned.** No critical label/action mismatches found in static review.

---

## G. Cross-App Terminology Analysis

| Term | Watch | iOS | Consistent? | Notes |
|------|-------|-----|-------------|-------|
| **BUSSOLA** | Yes (`BUSSOLA` key; EN UI “COMPASS”) | N/A (no compass tab) | Yes | Never `COMPASSO` |
| **Mission Mode** | `settings.mission_mode.*`, live bolt | N/A | Yes | Not Apple Low Power Mode |
| **TTV** | Live + settings info | Analysis / detail | Yes | Informational index; not deco |
| **No-depth / manual** | `live.manual.nodepth.*`, log banners | Manual editor, detail | Yes | |
| **GPS no-fix** | Compact banners | Detail fix source labels | Yes | |
| **Export** | CSV via log/detail | CSV + More panel | Yes | Subsurface-oriented |
| **Sync** | WatchConnectivity status | Watch + iCloud cards | Yes | |
| **Planner** | N/A | Reference-only disclaimers | Yes | No certified deco claim on Watch |
| **Safety / not dive computer** | Onboarding + legal | Onboarding + planner ack | Yes | |

---

## H. Localization Gap Matrix (selected)

| File / area | Key / string | IT | EN | Screen | Sev | Proposed key |
|-------------|--------------|----|----|--------|-----|----------------|
| Watch | Italian-as-key rows (`IMPOSTAZIONI`, etc.) | ✓ | ✓ (mapped) | Settings | MED | Migrate to `settings.title` style semantic keys |
| Watch | App Intents titles | Partial | ✓ | Shortcuts | MED | `AppIntents.strings` / `LocalizedStringResource` tables |
| iOS | `"iOS Companion"` | **Missing** | hardcoded | Legal hero | MED | `ios.legal.hero.subtitle` |
| iOS | Alert `Exit App` | Partial | ✓ | Legal | MED | `ios.legal.exit_alert.title` |
| iOS | More footer | ✓ (key=IT sentence) | ✓ | More | LOW | `more.safety.footer` semantic key |
| Watch | `Metrico (m)` picker | N/A | N/A | Settings | LOW | `settings.units.metric` / `.imperial` |
| Both | Key parity | 466 / 949 | 466 / 949 | Global | INFO | **No missing keys between IT/EN files** |

**Hardcoded Italian in Swift (MAIN, in-build):** `CompassView` dive idle strings use `Text("Dati immersione…")` — **catalog has EN** via `LocalizedStringKey`. **AscentGaugeView** uses `Text("VELOCITA")` — catalog maps to EN “ASCENT”.

**Hardcoded English in Swift (MAIN iOS):** Legal hero `"iOS Companion"` — **no IT entry**.

---

## I. Accessibility Text Gap Matrix (selected)

| App | Screen | Element | Gap | Sev | Proposed fix |
|-----|--------|---------|-----|-----|--------------|
| Watch | Settings | Rows / toggles | No per-row a11y on most settings | MED | `accessibilityLabel` + hint on Mission Mode, sync, units |
| Watch | Dive log / detail | List rows | Minimal | MED | Combine depth/duration/date |
| Watch | Info | Diagnostic rows | Not announced as status | LOW | Header + value pattern |
| Watch | Alarm settings | Crown steppers | No increment a11y | MED | Value + hint on thresholds |
| iOS | Planner | Bühlmann chart | No chart summary | HIGH | `accessibilityLabel` summarizing NDL curve purpose |
| iOS | Analysis | Charts | Limited | MED | Summarize trend / empty state |
| iOS | Equipment | Some toggles | Partial | LOW | Match `EquipmentChecklistGasSection` pattern |
| iOS | Legal onboarding | Steps | No progress trait | LOW | “Step 1 of 4” value |
| Both | Custom tabs | Watch vertical / iOS tab | System handles tabs | LOW | Verify selected trait on Watch pages |

**Positive:** `DiveLiveView` (depth, TTV, stopwatch), `AscentGaugeView`, `MissionModeIndicatorView`, `PlannerView` (many planner warnings), `LogbookView` (demo badge), `DiveDetailView` tiles.

---

## J. Safety Copy Gap Matrix (selected)

| App | Screen | Current copy | Problem | Proposed | Priority |
|-----|--------|--------------|---------|----------|----------|
| Watch | Legal | NOT A DIVE COMPUTER | None | — | — |
| Watch | Mission Mode | `apple_lpm_disclaimer` | Clear not Apple LPM | — | — |
| Watch | Depth 35/38/40 | `depth.safety.*` | Non-certified tone | — | — |
| Watch | TTV | Informational disclaimers in settings | Does not claim TTS/NDL | — | — |
| iOS | Planner | Reference-only headers + NDL chart disclaimer | Post–algorithm audit OK | — | — |
| iOS | Planner | Incomplete calculation banner | Clear “do not use as dive plan” | — | — |
| iOS | More | Long footer disclaimer | Truthful; dense | Optional shorten for readability | P3 |
| iOS | CSV | Import errors in panel | Verify depth-cap message at 351 m | Ensure user-facing string references policy doc | P2 |

**No misleading “certified planner” or Watch NDL claims found in MAIN strings.**

---

## K. Menu/Function Mismatch Matrix (consolidated)

| App | Menu/row/button | Expected | Actual | Mismatch | Priority |
|-----|-----------------|----------|--------|----------|----------|
| Watch | Settings → Export | Export CSV | Opens dive log tab | Mild | P2 |
| Watch | App Intents | Localized Shortcuts | English metadata | Yes | P1 |
| iOS | Tab “Equipment” | Gear checklist | Equipment module | No | — |
| iOS | More → Subsurface row | CSV capability | Import panel + export from detail | No | — |
| iOS | Analysis demo toggle | In More (reviewer) | Excludes demo by default in analysis | No — intentional | — |
| Watch | Mode selection page | Mode picker | Hidden when single mode | No — dormant | INFO |

---

## L. Prioritized Remediation Plan

### Apple Watch

| Priority | IDs | Fix class | Effort |
|----------|-----|-----------|--------|
| **P0** | — | — | None identified for internal TestFlight **copy-only** blockers |
| **P1** | UITEXT-W-001, App Intents EN | localization-only | Medium |
| **P2** | UITEXT-W-006, Export row label, UITEXT-W-009 | copy + UI-only | Small–medium |
| **P3** | UITEXT-W-003, W-008, W-007 | copy / localization | Small |

### iOS Companion

| Priority | IDs | Fix class | Effort |
|----------|-----|-----------|--------|
| **P0** | — | — | None for copy-only |
| **P1** | UITEXT-I-001, UITEXT-I-002, chart a11y | localization + a11y | Small |
| **P2** | UITEXT-I-004, UITEXT-I-007 | localization + UI | Medium |
| **P3** | Footer shorten, Dynamic Type pass | UI-only | Medium |

### Cross-app

| Priority | Item | Fix class |
|----------|------|-----------|
| **P1** | Restore/add `Docs/ReferenceUI/*.png` for regression | documentation + QA |
| **P2** | Semantic localization key migration (Watch Italian keys) | localization-only |
| **P3** | Full Dynamic Type audit (iOS planner, Watch settings) | physical QA |

---

## M. Final Verdict

| Question | Answer |
|----------|--------|
| **Is Watch text/UI formatting ready?** | **Mostly** (~84%) — readable neon/dark UI, strong Live metrics, but small-screen stacking, Italian-as-key debt, and informational row styling need polish before external TestFlight. |
| **Is iOS text/UI formatting ready?** | **Mostly** (~89%) — strong planner disclaimers and tab structure; legal hero gaps and chart VoiceOver need work. |
| **Are menus aligned with functions?** | **Yes, broadly** (~92%) — no dangerous mismatches; Watch Export row wording is the main UX gap. |
| **Are settings complete and truthful?** | **Yes** — Mission Mode, units, language, haptics, sync, and safety disclaimers match implemented behavior. |
| **Is localization ready?** | **Functionally yes** (full IT/EN key parity); **process quality** needs semantic keys and a few missing IT strings. |
| **Is accessibility text ready?** | **Partial** (~79%) — critical Live/planner paths better than settings/log/chart summaries. |
| **What blocks 100%?** | (1) Missing reference screenshots in repo, (2) device/simulator clipping pass 41–49 mm / Dynamic Type, (3) localization hygiene + iOS legal hero, (4) VoiceOver chart/settings coverage, (5) App Intents localization — **plus** external field QA excluded from this audit. |

---

## Appendix — Inventory statistics

| Metric | Watch MAIN | iOS MAIN |
|--------|------------|----------|
| `Localizable.strings` keys | 466 | 949 |
| EN/IT key delta | 0 | 0 |
| MAIN View Swift files (in target) | ~22 | ~15 (+ components) |
| Files with `accessibility*` usage | 9 | 11 |
| `COMPASSO` in MAIN UI | 0 | 0 |

---

*Audit performed by static review of Swift sources and `Localizable.strings` on `main` @ `34fe880`. No runtime simulator screenshots were available in-repo for clipping sign-off.*

---

## Remediation plan

Actionable phased implementation (PR breakdown, acceptance criteria, QA): **[`MAIN_UI_TEXT_REMEDIATION_PLAN.md`](MAIN_UI_TEXT_REMEDIATION_PLAN.md)**.
