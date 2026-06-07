# DIR Diving iOS Bühlmann comprehensive readiness remediation — V3 report

**Source audit:** [`DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_V3.md`](DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_V3.md)  
**Audit baseline:** `a4b99e6` (V3 audit @ `ae942d3` report commit)  
**Branch:** `main`  
**Remediation date:** 2026-06-07  
**Scope:** Non-physical V3 P2/P3 + Bühlmann P3 polish — code, tests, documentation only

---

## Executive summary

All repository-completable gaps from the V3 audit were addressed: logbook tissue/narcosis source classification with **recorded single-gas Bühlmann replay** where safe, strengthened simulated/manual labeling, checklist PDF imperial switch depths, PDF share payload tests, external validation fixture template, manual QA checklists (PDF share, Ratio Deco simulator), GF equality policy documentation, briefing TTS wording verified, planner tissue fail-empty on invalid environment, and documentation baseline updates.

**Physical/external/App Store gates remain PENDING.** DIR DIVING remains **non-certified/reference-only**. **Bühlmann remains primary.** **Ratio Deco remains comparative heuristic only.**

---

## V3-P2 issues addressed

| ID | Issue | Resolution |
|----|-------|------------|
| V3-P2-001 | Logbook tissue/narcosis simulated only | `TissueAnalyticsLogbookReplay` — recorded Schreiner replay for non-manual sessions with ≥2 samples and single gas; manual/trimix → simulated; &lt;2 samples → insufficient; UI source labels + dynamic logbook subtitles (EN/IT) |
| V3-P2-002 | No share destination evidence | [`PDF_SHARE_MANUAL_QA_CHECKLIST.md`](PDF_SHARE_MANUAL_QA_CHECKLIST.md); automated PDF URL/size/`%PDF`/protected directory tests in `PDFExportServiceTests` |
| V3-P2-003 | External validation not executed | Strengthened [`DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_PLAN.md`](DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_PLAN.md); new [`BUHLMANN_EXTERNAL_VALIDATION_FIXTURES_TEMPLATE.md`](BUHLMANN_EXTERNAL_VALIDATION_FIXTURES_TEMPLATE.md) — campaign **PENDING** |

---

## V3-P3 issues addressed

| ID | Issue | Resolution |
|----|-------|------------|
| V3-P3-001 | Checklist PDF hardcoded meters | `ChecklistPDFBuilder` + `PDFExportService.exportChecklist` use `Formatters.depth` + user `IOSUnitPreference` |
| V3-P3-002 | Manual trapezoidal profile | Enhanced `manual_dive.synthetic_profile.disclosure`; manual sessions force `simulated` source; [`MANUAL_DIVE_PROFILE_EDITOR_FUTURE_WORK.md`](MANUAL_DIVE_PROFILE_EDITOR_FUTURE_WORK.md) |
| V3-P3-003 | Ratio Deco visual QA | [`RATIO_DECO_SIMULATOR_QA_CHECKLIST.md`](RATIO_DECO_SIMULATOR_QA_CHECKLIST.md) — evidence **PENDING** until screenshots in `Docs/QA_EVIDENCE/RATIO_DECO_SIMULATOR/` |

---

## Bühlmann P3 items addressed

| ID | Issue | Resolution |
|----|-------|------------|
| IOS-BUH-P3-001 | GF Low == GF High | **Option A kept** — validation rejects equality; EN/IT message documents conservative DIR DIVING policy; [`DIR_DIVING_IOS_PLANNER_LIMITATIONS.md`](DIR_DIVING_IOS_PLANNER_LIMITATIONS.md) |
| IOS-BUH-P3-002 | TTS/TTR copy | Already fixed in strings (`TTS estimate` / `stima TTS`); verified in `BühlmannComprehensiveReadinessV3RemediationTests` + `PlannerCNSCopyTests` |
| IOS-BUH-P3-003 | Tissue chart sea-level fallback | `buildFromPlanner` returns nil when environment invalid; `compartmentMetrics` returns nil when ambient conversion fails |
| IOS-BUH-P3-004 | Doc baseline drift | Updated limitations, logbook replay doc, external validation plan; this report records remediation HEAD |

---

## Files changed

### iOS app
- `iOSApp/Utils/TissueAnalyticsLogbookReplay.swift` *(new)*
- `iOSApp/Models/TissueAnalyticsTrace.swift` — `insufficientData` source + footnotes
- `iOSApp/Services/TissueAnalyticsService.swift` — logbook routing; planner environment guard
- `iOSApp/Services/PDF/ChecklistPDFBuilder.swift` — unit-aware switch depth
- `iOSApp/Services/PDF/PDFExportService.swift` — checklist unit preference
- `iOSApp/Services/PDF/DivePackPDFBuilder.swift` — unit-aware checklist lines
- `iOSApp/Views/TissueAnalytics/TissueNarcosisAnalyticsView.swift` — source footnotes
- `iOSApp/Views/DiveDetailView.swift` — dynamic logbook subtitle
- `iOSApp/Views/EquipmentView.swift` — imperial checklist export
- `iOSApp/Resources/en.lproj/Localizable.strings`
- `iOSApp/Resources/it.lproj/Localizable.strings`

### Tests
- `Tests/iOSAlgorithmTests/BuhlmannComprehensiveReadinessV3RemediationTests.swift` *(new)*
- `Tests/iOSAlgorithmTests/TissueAnalyticsServiceTests.swift`
- `Tests/iOSAlgorithmTests/PDFExportServiceTests.swift`
- `Tests/iOSAlgorithmTests/ChecklistPlannerSyncMapperTests.swift`
- `Tests/iOSAlgorithmTests/IOSMainAlgorithmMathRemediationTests.swift`

### Build
- `project.yml` — test target sources

### Documentation
- `Docs/DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_REMEDIATION_V3_REPORT.md` *(this file)*
- `Docs/PDF_SHARE_MANUAL_QA_CHECKLIST.md` *(new)*
- `Docs/BUHLMANN_EXTERNAL_VALIDATION_FIXTURES_TEMPLATE.md` *(new)*
- `Docs/RATIO_DECO_SIMULATOR_QA_CHECKLIST.md` *(new)*
- `Docs/MANUAL_DIVE_PROFILE_EDITOR_FUTURE_WORK.md` *(new)*
- `Docs/LOGBOOK_TISSUE_REPLAY_FUTURE_WORK.md` *(updated)*
- `Docs/DIR_DIVING_IOS_PLANNER_LIMITATIONS.md` *(updated)*
- `Docs/DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_PLAN.md` *(updated)*

---

## Tests added / modified

**New (11):** `BühlmannComprehensiveReadinessV3RemediationTests` — planner/recorded/manual/trimix/insufficient sources, GF equality, TTS copy, invalid environment, checklist PDF metric/imperial, localization keys

**Modified:** `TissueAnalyticsServiceTests` (recorded + manual), `PDFExportServiceTests` (briefing/dive pack/checklist share payloads), `ChecklistPlannerSyncMapperTests`, `IOSMainAlgorithmMathRemediationTests` (recorded vs manual)

---

## Validation

### Pre-flight @ `ae942d3`

```
git branch --show-current  → main
git status -sb             → clean (before remediation edits)
git rev-parse --short HEAD → ae942d3
xcodegen generate          → PASS
```

### Post-remediation

| Command | Result |
|---------|--------|
| `xcodegen generate` | **PASS** |
| `DIRDiving iOS` build (generic iOS Simulator, no codesign) | **PASS** |
| `DIRDiving iOS Algorithm Tests` @ iPhone 17 Pro | **PASS** — **485 executed**, 13 skipped, 0 failures |

**Simulator substitution:** none — iPhone 17 Pro as specified.

**Watch:** not run — no Watch files modified.

---

## Static checks

| Check | Result |
|-------|--------|
| No new `try!` / `as!` in modified code | OK |
| No experimental files added to MAIN targets | OK |
| No App Store / certification overclaims in docs | OK |
| No Ratio Deco decompression-algorithm wording added | OK |
| Bühlmann ZH-L16C math unchanged | OK |
| CNS/OTU formulas unchanged | OK |
| Physical QA not marked complete | OK |
| Mail/AirDrop/WhatsApp QA not marked complete | OK |
| No hardcoded `%d m` in checklist PDF switch-depth path | OK |

---

## Confirmations

- **Bühlmann math:** unchanged (logbook replay uses existing tissue loaders; no engine formula changes)
- **Ratio Deco:** heuristic/comparative only
- **DIR DIVING:** non-certified/reference-only
- **App Store readiness:** **not claimed**

---

## Remaining tasks (PENDING)

| Task | Status |
|------|--------|
| Apple Watch Ultra underwater / depth sensor QA | **PENDING** |
| Real GPS entry/exit lifecycle QA | **PENDING** |
| Real underwater haptic QA | **PENDING** |
| Paired iPhone + Apple Watch real-device QA | **PENDING** |
| iCloud two-device real QA | **PENDING** |
| Subsurface external import/export validation | **PENDING** |
| External Bühlmann validation campaign | **PENDING** |
| Mail/AirDrop/WhatsApp physical share QA | **PENDING** |
| Accessibility Dynamic Type / VoiceOver manual matrix | **PENDING** |
| Ratio Deco simulator screenshots | **PENDING** — see checklist |
| Legal review | **PENDING** |
| App Store review | **PENDING** |
| Logbook multigas switch replay | **PENDING** — future work doc |

---

## Readiness statement

**Code / automated test / docs readiness:** non-physical V3 audit items are **implemented or explicitly deferred with justification**; iOS build and **485/485** passing algorithm tests (13 skipped) on `main`.

**Physical / external readiness:** **PENDING** — no device evidence recorded.

**Certified decompression / App Store readiness:** **must not be claimed.**

*Report generated after V3 comprehensive readiness remediation on `main`.*
