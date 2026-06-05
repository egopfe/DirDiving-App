# DIR DIVING iOS Planner — Deco Table & Bühlmann Curve Fix Report

**Date:** 2026-06-02  
**Scope:** iOS Companion MAIN — Planner result UI and Bühlmann planner output only  
**Baseline audit:** `Docs/DIR_DIVING_IOS_PLANNER_DECO_TABLE_BUHLMANN_CURVE_AUDIT_CURRENT.md`  
**Verdict:** **IMPLEMENTED**

---

## Summary

All P1/P2 audit gaps for the iOS Planner result screen were addressed without changing decompression stop math, without touching Watch/experimental code, and without altering legal/safety disclaimers.

---

## Files created

| File | Purpose |
|------|---------|
| `iOSApp/Algorithms/Buhlmann/BuhlmannTissueHistory.swift` | Tissue history DTOs + visualization sampler |
| `iOSApp/Services/PlannerAscentTableBuilder.swift` | Ascent table rows + depth profile points + TRIMIX display label |
| `Tests/iOSAlgorithmTests/BuhlmannTissueHistoryTests.swift` | Engine tissue history tests |
| `Tests/iOSAlgorithmTests/PlannerCurveChartTests.swift` | Tissue vs NDL chart separation tests |
| `Tests/iOSAlgorithmTests/PlannerAscentTableTests.swift` | Ascent table + TTS tests |
| `Tests/iOSAlgorithmTests/PlannerDepthProfileTests.swift` | Depth profile chart tests |
| `Tests/iOSAlgorithmTests/PlannerLocalizationTests.swift` | EN/IT key presence tests |
| `Docs/DIR_DIVING_IOS_PLANNER_DECO_TABLE_BUHLMANN_CURVE_FIX_REPORT.md` | This report |

## Files modified

| File | Change |
|------|--------|
| `iOSApp/Algorithms/Buhlmann/BuhlmannEngine.swift` | `tissueHistory` on `BuhlmannEngineResult`; post-plan sampling |
| `iOSApp/Services/BuhlmannPlanner.swift` | TRIMIX display labels; invalid-result tissue history |
| `iOSApp/Services/PlannerService.swift` | `ttsMinutes`, `totalRuntimeMinutes`, tissue history, ascent rows, depth profile |
| `iOSApp/Models/DivePlan.swift` | New result fields; replaced `ttrMinutes` with `ttsMinutes` |
| `iOSApp/Views/PlannerView.swift` | Tissue chart, NDL secondary chart, depth profile, ascent table, TTS/Runtime summary |
| `iOSApp/Resources/en.lproj/Localizable.strings` | New chart/table/metric strings |
| `iOSApp/Resources/it.lproj/Localizable.strings` | New chart/table/metric strings; `Profondità` accent fix |
| `project.yml` | Test target includes new algorithm/service files |
| `Docs/IOS_PLANNER_CHART_TRUTHFULNESS.md` | Rewritten for tissue + NDL + depth profile semantics |
| `Docs/DIR_DIVING_IOS_BUHLMANN_ENGINE_DESIGN.md` | Tissue history output section added |
| `Docs/DIR_DIVING_IOS_BUHLMANN_MATH_VERIFICATION.md` | Display metric formulas documented |
| `Docs/DIR_DIVING_IOS_PLANNER_LIMITATIONS.md` | Visualization sampling limitations |
| `Docs/DIR_DIVING_IOS_ALGORITHM_RELEASE_HARDENING.md` | 2026-06-02 planner chart hardening entry |
| Test updates | `PlanCalculationCompletenessTests`, `AuditRemediationTests`, `BuhlmannMultigasPlannerTests` |

---

## Issues fixed

### P1

| Issue | Fix |
|-------|-----|
| No tissue compartment time-series | `BuhlmannTissueHistorySampler` replays segments at 1-min cadence |
| CURVA BÜHLMANN was NDL vs depth | Primary chart is grouped ZH-L16C load % vs time |
| Decorative depth-band “compartment” groups | Real compartment groups 1–4 … 13–16 over time |

### P2

| Issue | Fix |
|-------|-----|
| Ascent table missing bottom/travel rows | `PlannerAscentTableBuilder` |
| TTR/TTS label mismatch | UI/export use **TTS** + **Runtime** |
| GRAFICI lacked depth profile | `depthProfileChart` from `plan.segments` |
| No chart legend | Tissue chart legend block with four group colors |

### P3

| Issue | Fix |
|-------|-----|
| TX vs TRIMIX label | `BuhlmannGas.displayLabel` → `TRIMIX 18/45` |
| Profondita accent | IT `planner.table.depth` → `Profondità` |

---

## Tissue history implementation

- DTO: `BuhlmannTissueHistorySample` (16 compartments × timestamps)
- Grouped chart series: `BuhlmannTissueGroupPoint` with **max loadPercent per group**
- Sampling replays existing segment list; **no change** to `decompressionSchedule` loop
- Golden fixture TTS/stop outputs verified unchanged (`BuhlmannTissueHistoryTests.testDecompressionOutputsUnchangedAfterAddingTissueSampling`)

---

## Chart implementation

- **CURVA BÜHLMANN:** Swift Charts line marks, four grouped series, 0–100% Y scale, EN/IT localized
- **NDL reference:** secondary card in Technical mode only, with existing NDL disclaimer
- **GRAFICI depth profile:** step profile from segments; depth axis inverted via negative Y values

---

## Ascent table

Rows: Bottom → Travel (descent/ascent segments) → Deco stops → Surface. All from engine/segment data; no static mock rows.

---

## TTS / Runtime terminology

| Term | Meaning |
|------|---------|
| **TTS** | `enginePlan.ttsMinutes` — time to surface from end of bottom |
| **Runtime** | `enginePlan.totalRuntimeMinutes` — full planned profile duration |

---

## Localization

All required EN/IT keys added (tissue chart, groups, NDL reference title, depth profile, ascent row labels, TTS, Runtime, export lines).

---

## macOS validation

Simulator: **iPhone 17**

```
xcodegen generate
xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving iOS" -destination 'platform=iOS Simulator,name=iPhone 17' build
→ BUILD SUCCEEDED

xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving iOS Algorithm Tests" -destination 'platform=iOS Simulator,name=iPhone 17' test
→ TEST SUCCEEDED (287 tests, 4 skipped, 0 failures)
```

---

## Scope confirmations

- **No Apple Watch files modified**
- **No watchOS targets modified**
- **No experimental iOS files modified**
- **Decompression stop math not changed** (sampling is post-plan replay only)
- **Legal/safety disclaimers preserved**; planner remains reference-only

---

## Remaining limitations

- Tissue load % is a **display metric** (M-value ratio), not a certified supersaturation index.
- Sampling replay may differ by sub-minute detail from a continuous real dive; cadence is fixed at 1 minute.
- Deco mode shows tissue chart but not the secondary NDL reference chart or GRAFICI depth profile tab.
- Depth profile uses metric meters in chart axis labels regardless of user unit preference (table uses unit formatter).
- Incomplete/partial stop plans suppress deco rows but may still show partial segment rows when completeness allows.

---

## Final verdict

**IMPLEMENTED** — audit P1/P2 items addressed with real engine-backed tissue history, truthful charts, full ascent table rows, TTS/Runtime clarity, depth profile, localization, tests, and documentation.
