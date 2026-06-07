# DIR Diving UI/UX Audit — Command Complete v2

**Audit date:** 2026-06-07  
**Repository:** DIR DIVING (`DirDiving-App`)  
**Branch:** `main` @ `515746c`  
**Command source:** `4-COMANDO_DIR_DIVING_UI_UX_AUDIT_COMMAND_COMPLETE_v2.md` (Google Drive)  
**Baseline audit extended:** `Docs/DIR_DIVING_UI_UX_READINESS_AUDIT_CURRENT.md` (original scope @ `c5d48b4`)  
**Mode:** Read-only static audit + macOS build/test validation  
**Scope:** Apple Watch MAIN + iOS Companion MAIN — Planner, Ratio Deco, Tissue & Narcosis, Checklist, PDF/Share, Image Transfer, Watch Reminders, Manual Dive, Localization, Accessibility  
**No source changes:** Only documentation created/updated for this audit pass.

---

## Executive Summary

| Dimension | Readiness |
|---|---:|
| **Apple Watch MAIN UI/UX** | **82%** |
| **iOS Companion MAIN UI/UX** | **85%** |
| **Shared design system** | **81%** |
| **Overall UI/UX readiness** | **84%** |

### v2 extension readiness matrix

| Extension area | Readiness | Gate status |
|---|---:|---|
| Ratio Deco UX | **88%** | Code + unit tests pass; simulator screenshot QA **PENDING** |
| Tissue & Narcosis UX | **86%** | Source labels + logbook replay shipped @ `515746c`; chart VO **P2** |
| Checklist UX | **89%** | DIR/READY badges, gas sections, PDF units; templates functional |
| PDF / Share UX | **87%** | Export + Share Sheet wired; Mail/AirDrop/WhatsApp **PENDING** device QA |
| Image Transfer UX | **85%** | Resolution/conversion warnings IT/EN; pre-dive Watch visibility OK in code |
| Watch Reminder UX | **84%** | Multi/reminder aggregation + haptics; overlay a11y **P2** |
| Manual Dive UX | **88%** | Full editor + validation + logbook integration; device edit flow **PENDING** |

Both MAIN apps remain **feature-complete at the UI layer** and suitable for **internal TestFlight-style QA**. They are **not at external/App Store UI polish** without closing P1 localization, accessibility, device-verified layout/share gates, and manual QA matrices listed below.

### Top 10 remaining risks (base + v2)

| # | ID | App | Risk |
|---|---|---|---|
| 1 | IOS-UX-P1-001 | iOS | Legal onboarding steps 0–3 hardcoded English |
| 2 | WATCH-UX-P1-001 | Watch | Hardcoded Italian in dive detail/export/GPS rows |
| 3 | IOS-UX-P1-002 | iOS | Fullscreen black-band fix not device-verified on Pro hardware |
| 4 | IOS-UX-P1-003 | iOS | Logbook swipe delete inside `ScrollView` likely non-functional |
| 5 | WATCH-UX-P1-002 | Watch | Live Dive banner stacking may push depth hero below fold |
| 6 | IOS-UX-P1-004 | iOS | Full-plan CNS warning color-only — weak VoiceOver |
| 7 | IOS-UX-V2-P2-001 | iOS | PDF share channels not verified on device (Mail/AirDrop/WhatsApp) |
| 8 | IOS-UX-V2-P2-002 | iOS | Ratio Deco overlay chart lacks dedicated VoiceOver summary |
| 9 | WATCH-UX-V2-P2-001 | Watch | `DiveReminderOverlayView` has no accessibility labels |
| 10 | IOS-UX-V2-P2-003 | iOS | Tissue timeline / PPN2 chart tooltips coarse for VoiceOver |

### Internal testing readiness

| Gate | Verdict |
|---|---|
| Compile + algorithm tests | **Pass** @ `515746c` |
| Internal QA / TestFlight UI pass | **Proceed** with P1 matrix + v2 manual checklists |
| External TestFlight / App Store UI | **Blocked** on P1 localization, a11y, device gates |

### Build/test result

| Step | Result |
|---|---|
| `xcodegen generate` | **Succeeded** |
| iOS build (`iPhone 17 Pro` sim) | **BUILD SUCCEEDED** |
| Watch build (`Apple Watch Ultra 3 (49mm)`) | **BUILD SUCCEEDED** |
| iOS Algorithm Tests | **472 passed, 13 skipped, 0 failures** (485 total) |
| Watch Algorithm Tests | **171 passed, 13 skipped, 0 failures** (184 total) |

**Simulators used:** iPhone 17 Pro, Apple Watch Ultra 3 (49mm)  
**Unavailable destinations:** iPhone 15 Pro family, Apple Watch Ultra 2 — not installed on this Mac (OS 26.5 runtime).

---

## Scope Confirmation

| Check | Status |
|---|---|
| Watch MAIN included | ✓ |
| iOS Companion MAIN included | ✓ |
| Experimental UI excluded | ✓ |
| Algorithm / business logic unchanged | ✓ Audit read-only |
| Non-certified positioning preserved | ✓ Disclaimers on Ratio Deco, tissue, planner |
| v2 extensions audited | ✓ All seven PART X areas below |
| Only documentation modified | ✓ |

---

## Pre-flight

| Item | Value |
|---|---|
| Git HEAD | `515746c22e33a598603cd5ec73cbfe3e79ad7c96` |
| Branch | `main` (clean working tree at audit time) |
| Post-remediation delta from prior UI audit | V3 Bühlmann remediation @ `515746c`: tissue source labels, logbook replay UI, checklist PDF units, PDF share payload tests |

---

# Base UI/UX Audit (check_grafica scope)

*Condensed from `Docs/DIR_DIVING_UI_UX_READINESS_AUDIT_CURRENT.md`; findings unchanged unless noted below.*

## Apple Watch MAIN — summary

| Screen / area | Readiness | Key notes |
|---|---:|---|
| Dive Live | 84% | Depth hero strong; banner stacking P1; TTV/RunTime mixed locale |
| Start / pre-dive | 86% | Clear manual/auto paths |
| Mission Mode | 88% | Bolt overlay; no false Low Power claim |
| Depth safety 35/38/40 m | 86% | Color progression OK; caution vs critical same copy P2 |
| Ascent warnings | 90% | Banner + gauge a11y good |
| Compass | 80% | No scroll — clip risk 41 mm |
| Settings | 76% | Dense; wheel pickers |
| Images / logbook / export | 83% | Hardcoded IT in detail P1 |
| Navigation | 82% | Mixed back patterns P2 |

## iOS Companion MAIN — summary

| Screen / area | Readiness | Key notes |
|---|---:|---|
| Fullscreen / adaptive | 85% code / 70% device confidence | Black-band fix unverified P1 |
| Dashboard / tabs | 88% | Five-tab lazy shell |
| Planner input / result | 88–90% | Three modes live; stale mode footer P2 |
| Logbook / Analysis / Gear / More | 82–84% | Swipe delete P1; card typography drift P3 |
| Onboarding | 72% | English-only legal steps P1 |

## Shared design system

Watch `DiveUI` + iOS `DIRTheme` coherent on palette and warning semantics. Token drift in logbook cards and Watch micro-hints. **Shared readiness: 81%.**

## Accessibility / localization (cross-cutting)

| Area | Watch | iOS |
|---|---|---|
| VoiceOver on warnings | Partial | Good on CNS descent; weak full-plan CNS + depth chart |
| Chart a11y | Minimal charts | Tissue peak summary exists; depth profile missing |
| IT/EN parity | Hardcoded IT literals P1 | Onboarding English P1 |

**Watch a11y: 72% · iOS a11y: 72%**

---

# PART X — Ratio Deco UX Audit

**Primary files:** `iOSApp/Views/RatioDecoPlannerViews.swift`, `PlannerView.swift`, `PlannerStore`, `RatioDecoPlanningEngine`

| Check | Status | Notes |
|---|---|---|
| Ratio Deco mode picker | ✓ | `PlannerDecompressionMethodPicker`; disabled in Base mode with explanation |
| Presets 1:1, 2:1, Custom | ✓ | Built-in + saved custom presets; save/delete sheet |
| Comparison mode | ✓ | `RatioDecoComparisonSection` — Bühlmann vs Ratio tables + validation |
| Validation warnings | ✓ | Color-coded summary; incompatible plan banner; localized warning list |
| Overlay chart | ✓ | `RatioDecoOverlayProfileChart` in comparison mode |
| Export integration | ✓ | Planner PDF/briefing paths include decompression method context |
| Disclaimer | ✓ | `RatioDecoDisclaimerBanner` — reference-only, non-validated |
| Accessibility | Partial | Disclaimer + validation combine labels; overlay chart no VO summary (**P2**) |
| Device QA | **PENDING** | `Docs/RATIO_DECO_SIMULATOR_QA_CHECKLIST.md` |

**Issues:** IOS-UX-V2-P2-002 (overlay chart a11y), IOS-UX-V2-P3-001 (simulator screenshot evidence pending)

**Ratio Deco UX readiness: 88%**

---

# PART X — Tissue & Narcosis UX Audit

**Primary files:** `iOSApp/Views/TissueAnalytics/TissueNarcosisAnalyticsView.swift`, `TissueAnalyticsCharts.swift`, `TissueAnalyticsService.swift`, `TissueAnalyticsLogbookReplay.swift`

| Check | Status | Notes |
|---|---|---|
| Tissue loading cards | ✓ | Entry card + summary strip; 16-compartment presentation |
| Controlling compartment | ✓ | Highlighted in tissue tab |
| Tissue timeline | ✓ | Runtime scrubber + chart |
| PPN2 chart | ✓ | Narcosis tab |
| END calculations | ✓ | Displayed with unit preference |
| Source transparency | ✓ **NEW @ 515746c** | Capsule: planned / recorded / simulated / insufficientData + footnotes |
| Planner integration | ✓ | From planner result navigation |
| Logbook integration | ✓ | Recorded single-gas replay; manual/trimix → simulated label |
| Tooltip readability | Partial | Small 11pt labels; dense on narrow phones |
| Accessibility | Partial | Tab selector buttons; chart VO summaries incomplete (**P2**) |

**Issues:** IOS-UX-V2-P2-003 (chart/timeline VoiceOver), IOS-UX-V2-P3-002 (multigas logbook replay UI label only — full replay future work)

**Tissue & Narcosis UX readiness: 86%**

---

# PART X — Checklist UX Audit

**Primary files:** `iOSApp/Views/EquipmentView.swift`, `EquipmentChecklistGasSection.swift`, `DIRChecklistConfigurationEvaluator.swift`, `ChecklistPDFBuilder.swift`, template sheets

| Check | Status | Notes |
|---|---|---|
| My Equipment / Gear tab | ✓ | Hero + planning card + checklist card |
| REC / TEC templates | ✓ | Template sheet from Gear |
| Custom templates / items | ✓ | Add/remove checklist rows |
| Task items | ✓ | Ready toggles per item |
| GAS items | ✓ | `usesGas` toggle + `EquipmentChecklistGasSection` |
| Back Gas / Deco Stage / Travel / Bailout | ✓ | Gas role picker + planner sync mapper |
| DIR badge validation | ✓ | Hero color from `isDIRConfigurationComplete` |
| READY badge validation | ✓ | Per-item ready state + evaluator rules |
| FIELD badge removal | ✓ | Removed @ prior remediation; dead keys gone |
| PDF export | ✓ | Toolbar share; **units respect `IOSUnitPreference` @ 515746c** |
| Accessibility | Partial | Toggles use system VO; gas section dense (**P3**) |

**Checklist UX readiness: 89%**

---

# PART X — PDF / Share UX Audit

**Primary files:** `PDFExportService.swift`, `ChecklistPDFBuilder.swift`, `PlannerView.swift`, `EquipmentView.swift`, `ShareSheetView.swift`

| Export type | Status | Share path |
|---|---|---|
| Planner plan PDF | ✓ | Planner toolbar → `ShareSheetView` |
| Briefing PDF | ✓ | `PDFExportService.exportBriefing` |
| Checklist PDF | ✓ | Gear toolbar |
| Dive Pack PDF | ✓ | Logbook/detail export flows |
| Share Sheet | ✓ | `UIActivityViewController` wrapper |
| WhatsApp / Mail / AirDrop / Files | **PENDING** | Requires device manual QA |
| Unit tests | ✓ | PDF share payload tests @ `515746c` |
| Accessibility | ✓ | Share toolbar `pdf.export.share.a11y` label |

**Manual QA:** `Docs/PDF_SHARE_MANUAL_QA_CHECKLIST.md` — all channels **PENDING**

**Issues:** IOS-UX-V2-P2-001 (device share verification)

**PDF / Share UX readiness: 87%**

---

# PART X — Image Transfer UX Audit

**Primary files:** `Views/UserImagesView.swift` (Watch), `iOSApp/Views/WatchPhotoTransferPanel.swift`, `WatchPhotoPreprocessor.swift`, `UserImageStore.swift`

| Check | Status | Notes |
|---|---|---|
| Image selection | ✓ | Watch list + detail; iOS transfer panel |
| Resolution validation | ✓ | Preprocessor enforces Watch constraints |
| Conversion warnings | ✓ | `watch_photo.convert.warning` IT/EN |
| IT/EN localization | ✓ | Transfer panel + delete confirm strings |
| Watch visibility before dive | ✓ | Images tab; sync on companion photo arrival |
| Delete / error UX | Partial | 9pt error text on Watch (**P2** from base audit) |
| Accessibility | Good | Row/detail labels on Watch list |

**Image Transfer UX readiness: 85%**

---

# PART X — Watch Reminders UX Audit

**Primary files:** `DiveReminderSettingsView.swift`, `DiveReminderEditorView.swift`, `DiveReminderOverlayView.swift`, `DiveReminderEngine.swift`, `HapticService.swift`, `DiveLiveView.swift`

| Check | Status | Notes |
|---|---|---|
| Multiple reminders | ✓ | Max-count guard; list in settings |
| Single / recurring | ✓ | Editor with recurrence options |
| Haptics | ✓ | Fired on trigger via `HapticService` |
| Overlay readability | ✓ | Yellow border card; runtime stamp |
| Aggregation logic | ✓ | `hiddenCount` when >2 simultaneous (`DiveReminderEngine`) |
| Settings flow | ✓ | Global toggle + NavigationLink editor |
| Accessibility | **Gap** | Overlay non-interactive but no `accessibilityLabel` (**P2**) |
| Tests | ✓ | `DiveReminderEngineTests` including hiddenCount |

**Issues:** WATCH-UX-V2-P2-001 (overlay VoiceOver)

**Watch Reminder UX readiness: 84%**

---

# PART X — Manual Dive UX Audit

**Primary files:** `ManualDiveEditorView.swift`, `ManualDiveEditorValidation.swift`, `LogbookView.swift`, `DiveDetailView.swift`

| Field / flow | Status | Notes |
|---|---|---|
| Manual dive creation | ✓ | Add from logbook |
| Max / avg depth | ✓ | Steppers; unit-aware; validation order |
| GPS start/end | ✓ | Lat/lon text fields |
| Equipment | ✓ | Free-text equipment field |
| Gas data | ✓ | Segmented gas label picker |
| Deco notes | ✓ | Dedicated field |
| Metadata-only edit | ✓ | Banner when editing manual session without profile |
| Synthetic profile disclosure | ✓ | Shown when generating profile from summary fields |
| Export consistency | ✓ | Subsurface export paths include manual sessions |
| Logbook consistency | ✓ | Grouped list; detail tabs |
| Tests | ✓ | `ManualDiveEditorLogicTests` |
| Device QA | **PENDING** | Full create/edit/save matrix on hardware |

**Manual Dive UX readiness: 88%**

---

## Extended Readiness Scoring

### v2 extension areas (iOS-weighted feature modules)

| Area | Weight | Score | Weighted |
|---|---:|---:|---:|
| Ratio Deco UX | 12% | 88% | 10.6 |
| Tissue & Narcosis UX | 12% | 86% | 10.3 |
| Checklist UX | 10% | 89% | 8.9 |
| PDF / Share UX | 10% | 87% | 8.7 |
| Image Transfer UX | 8% | 85% | 6.8 |
| Manual Dive UX | 8% | 88% | 7.0 |
| **iOS v2 module subtotal** | **60%** | | **52.3 → ~87%** |

*v2 modules fold into iOS Companion score below alongside base areas.*

### Apple Watch (weighted)

| Area | Weight | Score | Weighted |
|---|---:|---:|---:|
| Live Dive UI | 18% | 84% | 15.1 |
| Compass | 10% | 80% | 8.0 |
| Settings | 14% | 76% | 10.6 |
| Warnings/safety UI | 14% | 89% | 12.5 |
| Watch Reminders | 10% | 84% | 8.4 |
| Navigation | 8% | 82% | 6.6 |
| Images/logbook/export | 10% | 83% | 8.3 |
| Accessibility/localization | 8% | 72% | 5.8 |
| Design system | 8% | 88% | 7.0 |
| **Total** | | | **82%** |

### iOS Companion (weighted)

| Area | Weight | Score | Weighted |
|---|---:|---:|---:|
| Fullscreen/adaptive | 10% | 85% | 8.5 |
| Planner input/result | 15% | 89% | 13.4 |
| Ratio Deco | 10% | 88% | 8.8 |
| Tissue & Narcosis | 10% | 86% | 8.6 |
| Checklist + Gear | 10% | 89% | 8.9 |
| PDF/Share + Manual Dive | 10% | 88% | 8.8 |
| Logbook/Analysis/More | 15% | 83% | 12.5 |
| Accessibility/localization | 10% | 72% | 7.2 |
| Design system | 10% | 86% | 8.6 |
| **Total** | | | **85%** |

### Overall

`(82 × 0.35) + (85 × 0.45) + (81 × 0.20) ≈ **84%**`

---

## P0/P1/P2/P3 Issue Table (base + v2)

| ID | App | Area | Pri | Description | Fix effort |
|---|---|---|---|---|---|
| WATCH-UX-P1-001 | Watch | Logbook | **P1** | Hardcoded IT strings | S |
| WATCH-UX-P1-002 | Watch | Live | **P1** | Banner stacking compresses depth hero | M |
| IOS-UX-P1-001 | iOS | Onboarding | **P1** | Legal steps English-only | S |
| IOS-UX-P1-002 | iOS | Layout | **P1** | Black bands not device-verified | S QA |
| IOS-UX-P1-003 | iOS | Logbook | **P1** | Swipe delete in ScrollView | M |
| IOS-UX-P1-004 | iOS | Planner | **P1** | Full-plan CNS weak a11y | S |
| IOS-UX-V2-P2-001 | iOS | PDF/Share | **P2** | Mail/AirDrop/WhatsApp not device-tested | S QA |
| IOS-UX-V2-P2-002 | iOS | Ratio Deco | **P2** | Overlay chart VoiceOver summary | S |
| IOS-UX-V2-P2-003 | iOS | Tissue | **P2** | Timeline/PPN2 chart VO gaps | M |
| WATCH-UX-V2-P2-001 | Watch | Reminders | **P2** | Overlay missing accessibility labels | S |
| WATCH-UX-P2-001 | Watch | Depth | **P2** | 35 m vs 38 m same copy | S |
| IOS-UX-P2-001 | iOS | Planner | **P2** | Stale mode footer strings | S |
| IOS-UX-V2-P3-001 | iOS | Ratio Deco | **P3** | Simulator screenshot QA pending | QA |
| IOS-UX-V2-P3-002 | iOS | Tissue | **P3** | Multigas logbook replay future work | Doc |

**P0:** None at UI layer.

---

## Readiness-To-100 Roadmap (v2 additions)

| Phase | Focus | Acceptance | Effort |
|---|---|---|---|
| V2-1 | Device PDF share matrix | `PDF_SHARE_MANUAL_QA_CHECKLIST.md` all PASS | 0.5 d QA |
| V2-2 | Ratio Deco simulator QA | `RATIO_DECO_SIMULATOR_QA_CHECKLIST.md` screenshots | 0.5 d QA |
| V2-3 | Reminder overlay a11y | VO reads title + messages + hidden count | 0.5 d |
| V2-4 | Tissue/Ratio chart VO | Summaries on overlay + tissue timeline | 1–2 d |
| V2-5 | Base P1 closure | Localization, fullscreen, logbook delete, CNS banner | 3–5 d |

*Base Watch/iOS phases W-1…I-6 from prior audit remain valid; see `Docs/DIR_DIVING_UI_UX_READINESS_AUDIT_CURRENT.md`.*

---

## Validation Results

```
git rev-parse HEAD → 515746c22e33a598603cd5ec73cbfe3e79ad7c96
xcodegen generate → Succeeded
xcodebuild -scheme "DIRDiving iOS" -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build → BUILD SUCCEEDED
xcodebuild -scheme "DIRDiving Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Ultra 3 (49mm)' build → BUILD SUCCEEDED
xcodebuild -scheme "DIRDiving iOS Algorithm Tests" -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test → 472 passed, 13 skipped, 0 failures (485 total)
xcodebuild -scheme "DIRDiving Watch Algorithm Tests" -destination 'platform=watchOS Simulator,name=Apple Watch Ultra 3 (49mm)' test → 171 passed, 13 skipped, 0 failures (184 total)
```

**Unresolved build issues:** None on available destinations.

---

## Manual QA Matrices (physical / device — PENDING)

| Matrix | Doc |
|---|---|
| PDF share channels | `Docs/PDF_SHARE_MANUAL_QA_CHECKLIST.md` |
| Ratio Deco simulator | `Docs/RATIO_DECO_SIMULATOR_QA_CHECKLIST.md` |
| iOS Dynamic Type / VoiceOver | `Docs/IOS_DYNAMIC_TYPE_VOICEOVER_QA_MATRIX.md` |
| Watch ↔ iOS sync | `Docs/WATCH_IOS_SYNC_QA_MATRIX.md` |
| Fullscreen / device layout | Prior audit P1 matrix (iPhone 15 Pro + 17 Pro hardware) |

---

## Confirmation

| Statement | Status |
|---|---|
| No source code files changed | ✓ |
| No SwiftUI views changed | ✓ |
| No assets / localization changed | ✓ |
| Algorithms / safety thresholds unchanged | ✓ |
| Only audit documentation created/updated | ✓ |
| DIR Diving remains non-certified dive companion | ✓ |
| Ratio Deco remains heuristic / reference-only | ✓ |
| Physical QA not claimed | ✓ |

---

## Related documents

| Document | Role |
|---|---|
| `Docs/DIR_DIVING_UI_UX_READINESS_AUDIT_CURRENT.md` | Base scope @ `c5d48b4` (superseded for scoring by this v2 report) |
| `Docs/DIR_DIVING_FULL_UI_UX_AUDIT_CURRENT.md` | Extended full audit reference |
| `Docs/DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_REMEDIATION_V3_REPORT.md` | Algorithm remediation feeding tissue/checklist/PDF UX |

---

*Audit executed per `4-COMANDO_DIR_DIVING_UI_UX_AUDIT_COMMAND_COMPLETE_v2.md` @ `515746c`. Device UI verification and share-channel QA remain separate gates.*
