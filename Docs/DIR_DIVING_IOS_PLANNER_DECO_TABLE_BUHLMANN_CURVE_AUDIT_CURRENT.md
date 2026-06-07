# DIR DIVING iOS Planner — Decompression Table & Bühlmann Curve Audit (CURRENT)

> **SUPERSEDED for tissue-history chart and ascent briefing order** @ `f8820b7` and later.  
> Current behavior: primary CURVA = ZH-L16C tissue history; ascent table briefing order documented in [`IOS_PLANNER_CHART_TRUTHFULNESS.md`](IOS_PLANNER_CHART_TRUTHFULNESS.md).  
> Retained for historical gap analysis only.

**Date:** 2026-06-06  
**Scope:** iOS Companion MAIN — Planner result UI and Bühlmann algorithm output only (no Watch)  
**Branch / baseline:** `main` @ `b2ddc4e`  
**Mode:** Static code inspection — **report only**  
**Build:** Not run (audit is read-only; no code changes required to complete verification)

---

## 1. Executive summary

The iOS Planner **partially** matches the reference screenshot layout. The **PIANO / CURVA BÜHLMANN / GRAFICI** tab structure, **Piano Immersione** result screen, share export, summary metrics, and **PIANO DI RISALITA** table with **Profondità / Tempo / Gas / PPO₂** columns are **implemented** and bound to **real** `BuhlmannEngine` output (not static mock rows).

The largest gap versus the reference is the **CURVA BÜHLMANN** tab: the app renders a **reference NDL curve (depth vs NDL minutes)** with decorative compartment **group labels by depth band**, **not** a **ZH-L16C tissue loading / supersaturation curve over time (0–100 min, 0–100%)** as shown in the reference. The engine computes 16 tissue compartments internally but **does not expose time-series tissue history** for charting.

**Verdict vs reference screenshot:** **Partial** — structure and deco table largely align; Bühlmann graph type and data semantics do **not** match the reference.

**Safety note:** Copy and disclaimers correctly mark the planner as **reference-only / non-certified**. The NDL chart disclaimer explicitly states it is **not tissue loading**. A user comparing visually to the reference without reading copy could still **misinterpret** the Bühlmann tab as a decompression tissue chart — **P1 UX / clarity risk**, mitigated by existing disclaimer text.

---

## 2. Does the current Planner match the screenshot?

| Area | Match |
|------|--------|
| Result screen title + back + share | **Yes** (conceptually) |
| Tabs PIANO / CURVA BÜHLMANN / GRAFICI | **Yes** (IT localized) |
| Summary cards (TTR, stops, OTU, depth, bottom, CNS) | **Partial** — present but labels/extra rows differ; TTS not shown as separate tile |
| PIANO DI RISALITA table | **Partial** — deco stops + surface; **no bottom/travel row** like reference `40 m / 20 min / TRIMIX` |
| CURVA BÜHLMANN ZH-L16C graph | **No** — wrong chart type and axes |
| GRAFICI tab profile/deco charts | **Partial** — timeline + GF table, not depth profile chart |

**Overall:** **Partial**

---

## 3. Decompression / ascent stop table

**Implemented:** **Yes** (partial vs reference row set)

| Question | Answer |
|----------|--------|
| Table exists? | **Yes** — `PlanResultView.ascentTable` |
| Columns Profondità / Tempo / Gas / PPO₂? | **Yes** — localized headers + hardcoded `PPO2` column title |
| Real algorithm data? | **Yes** — `store.plan.decoStops` from `BuhlmannPlanner.decoStops(from: enginePlan)` |
| Static mock? | **No** — populated from `BuhlmannEngine.decompressionSchedule` |
| Surface row? | **Yes** — `0 m`, `-`, `SUPERFICIE` / `SURFACE`, `-` |
| Stop depth / duration / gas / PPO₂? | **Yes** — `DecoStop` fields |
| PPO₂ calculated? | **Yes** — `currentGas.ppO2(depthMeters:stopDepth, environment:)` in engine |
| Gas switches? | **Yes** — engine selects `currentGas` at each stop depth |
| Stop count in summary? | **Yes** — `store.plan.decoStops.count` |

**Gaps vs reference:**

- Reference includes a **bottom segment row** at max depth with bottom time and bottom gas (e.g. 40.0 m / 20 min / TRIMIX 18/45). Current table lists **decompression stops only** + surface; bottom/travel segments live under **GRAFICI → TIMELINE MULTI-SEGMENTO**, not in **PIANO DI RISALITA**.
- Gas labels use engine `BuhlmannGas.label` (`TX 18/45`, `EAN50`, `EAN80`) — reference uses `TRIMIX 18/45` wording (**P3** cosmetic).
- Column header IT string is `Profondita` (no accent) vs reference `Profondità` (**P3**).
- When `calculationCompleteness == .incompletePartialStops`, table is **suppressed** and replaced by incomplete banner (**correct safety behavior**).

---

## 4. STOP / TIME / GAS / PPO₂ (Profondità / Tempo / Gas / PPO₂)

**Implemented:** **Yes** for decompression stops; **partial** for full ascent plan narrative in one table.

Data flow:

```
GasPlanInput
  → PlannerService.makePlan
  → BuhlmannEngine.plan(BuhlmannPlanRequest)
  → BuhlmannEngineResult.stops [BuhlmannDecompressionStop]
  → BuhlmannPlanner.makeDecoStop → DecoStop
  → DivePlanResult.decoStops
  → PlanResultView.ascentTable (ForEach)
```

---

## 5. Bühlmann compartment graph

**Implemented:** **Partial** (chart exists; **not** reference semantics)

| Question | Answer |
|----------|--------|
| Graph UI exists? | **Yes** — Swift Charts `Chart` in `PlanResultView.buhlmannChart` |
| Real planner-linked data? | **Partial** — real **NDL** samples from `BuhlmannPlanner.ndlCurve`, not plan tissue history |
| Mock/static image? | **No** — computed points, but **wrong metric** for reference |
| 16 compartments time-series? | **No** — not produced by engine |
| Groups 1–4, 5–8, 9–12, 13–16 over **time**? | **No** — groups are **depth-band labels** on NDL curve (`ndlCurve` in `BuhlmannPlanner.swift`) |
| Axes 0–100% / 0–100 min? | **No** — axes are **Depth (m)** vs **NDL (min)** |
| Legend? | **Partial** — series name `Compartimenti` / group string; no explicit legend UI block |
| Updates on recalculate? | **Yes** — `PlannerStore.applyInputToPlanningOutputs` refreshes `buhlmann` on input/calculate |
| Trimix N₂+He tissue curves? | **No** in chart — engine supports N₂+He internally; chart does not visualize compartment pressures |

Documented intentionally in:

- `planner.buhlmann.curve_disclaimer` (IT/EN): *not tissue loading*
- `Docs/IOS_PLANNER_CHART_TRUTHFULNESS.md`

---

## 6. Sixteen tissue compartments as time-series data

**Available for charting:** **No**

| Item | Status | Location |
|------|--------|----------|
| 16 compartments (N₂ + He) | **Present** (runtime state) | `BuhlmannTissueState.compartments` (16), `BuhlmannConstants.compartmentCount` |
| Loading during profile | **Computed internally** | `loadedConstantDepth`, `loadedLinearDepth`, Schreiner in `BuhlmannTissueModel.swift` |
| Final tissue after plan | **Present** | `BuhlmannEngineResult.finalTissueState` |
| Sampled history (descent/bottom/stops/ascent/surface) | **Missing** | No `tissueHistory`, `[TissueSample]`, or per-minute compartment export |
| Supersaturation % vs M-value | **Missing** as serializable output | Ceiling computed in `ceiling(gf:environment:)` only at instants |
| Suitable for reference chart | **Requires algorithm output extension** | Not UI-only |

---

## 7. Tab structure (Piano / Curva Bühlmann / Grafici)

| Tab | Localized (IT) | Content | Status |
|-----|----------------|---------|--------|
| `.plan` | `PIANO` | Summary grid, gas ledger, ascent table, contingencies, team, briefing | **Implemented** |
| `.curve` | `CURVA BUHLMANN` | NDL depth chart + disclaimers | **Implemented** — wrong chart vs reference |
| `.charts` | `GRAFICI` | Segment timeline table + GF comparison table | **Partial** — no depth/deco profile chart like reference |

Tab state: `@State private var tab: PlanTab` in `PlanResultView` — stable while result view remains on stack; resets when navigating away and back (standard SwiftUI).

**Owner view:** `PlanResultView` inside `PlannerView` → `navigationDestination(isPresented: $showPlan)`.

---

## 8. Files inspected

| File | Role |
|------|------|
| `iOSApp/Views/PlannerView.swift` | Input UI; `PlanResultView` result tabs, summary, ascent table, Bühlmann chart, Grafici |
| `iOSApp/Services/PlannerStore.swift` | `plan`, `buhlmann`, `calculate()` |
| `iOSApp/Services/PlannerService.swift` | `DivePlanResult` assembly, TTR←TTS mapping |
| `iOSApp/Services/BuhlmannPlanner.swift` | Engine bridge, `decoStops`, `ndlCurve`, `makeDecoStop` |
| `iOSApp/Models/DivePlan.swift` | `DecoStop`, `DivePlanResult`, `NDLPoint`, `BuhlmannPlanResult` |
| `iOSApp/Utils/PlannerResultState.swift` | Result headers, completeness states |
| `iOSApp/Utils/PlanCalculationCompleteness.swift` | Partial stop suppression |
| `iOSApp/Algorithms/Buhlmann/BuhlmannEngine.swift` | ZHL-16C schedule, stops, segments, `ttsMinutes` |
| `iOSApp/Algorithms/Buhlmann/BuhlmannTissueModel.swift` | 16-compartment tissue math |
| `iOSApp/Algorithms/Buhlmann/BuhlmannGas.swift` | Gas labels, PPO₂ |
| `iOSApp/Resources/it.lproj/Localizable.strings` | Tab titles, table headers, disclaimers |
| `iOSApp/Resources/en.lproj/Localizable.strings` | EN equivalents |
| `Docs/IOS_PLANNER_CHART_TRUTHFULNESS.md` | Prior NDL chart truthfulness note |
| `Docs/DIR_DIVING_IOS_PLANNER_LIMITATIONS.md` | Engine capabilities & limitations |

---

## 9. Screen-by-screen findings

### 9.1 Planner input (`PlannerView`)

- Advanced-only mode; safety acknowledgment gate; **Calcola Piano** navigates to `PlanResultView`.
- Pre-calculation CNS/OTU preview tiles — not part of reference result screen.

### 9.2 Plan result header

- **Back:** NavigationStack back chevron (system).
- **Title:** `planner.result.title` → **Piano Immersione** (IT).
- **Share:** `ShareLink` with text export including TTR, stops, CNS, OTU, deco lines (`planShareText`).
- Result header badge: deco required / no-deco / incomplete / repetitive — dynamic from `store.plan.resultHeader`.

### 9.3 PIANO tab

**Summary grid (`resultGrid`):**

| Reference element | Current | Data source | Notes |
|-------------------|---------|-------------|-------|
| TTR / TTS | **Partial** | `store.plan.ttrMinutes` ← `enginePlan.ttsMinutes` | UI label **TTR** but value is engine **TTS**; no separate TTS tile; `totalRuntimeMinutes` not shown |
| Deco stops count | **Yes** | `decoStops.count` | |
| OTU | **Yes** | `store.plan.otu` | |
| Prof. Max | **Yes** | `input.plannedDepthMeters` | Display via unit formatter |
| Tempo Fondo | **Yes** | `input.plannedBottomMinutes` | |
| CNS% | **Partial** | `plan.gasAnalysis.cnsPercentDisplay` | Label **CNS (piano completo)** not bare **CNS%** |

Extra tiles not in reference: NDL, CNS descent+bottom, CNS ascent/deco estimate, density, END, turn pressure — informational, not blocking.

**PIANO DI RISALITA:** See §3–4.

### 9.4 CURVA BÜHLMANN tab

- Title card: **CURVA BÜHLMANN ZH-L16C** (`planner.buhlmann.curve_title`).
- Swift Charts line marks: X = depth, Y = NDL, series = compartment group string.
- **Does not** match reference time-based tissue loading curves.

### 9.5 GRAFICI tab

- **TIMELINE MULTI-SEGMENTO:** `store.plan.segments` — descent, bottom, ascent, stop, gas switch rows (real).
- **COMPARAZIONE GF:** `store.plan.gfComparisons` — TTS/stop count by GF preset (real).
- **Missing:** depth-vs-time dive profile chart or deco visualization shown in typical reference mockups.

---

## 10. Data-flow summary (algorithm → UI)

```
User taps Calcola Piano
  PlannerStore.calculate()
    PlannerService.makePlan(input:…)
      BuhlmannEngine.plan(request) → stops, segments, ttsMinutes, ndlMinutes, finalTissueState
      GasPlanningService.analyze → CNS, OTU
    DivePlanResult
  PlannerStore.plan

PlanResultView reads store.plan.* and store.buhlmann.curve (parallel NDL preview, not tissue trace)
```

**Key mismatch:** `store.buhlmann` is refreshed from `BuhlmannPlanner.plan(depthMeters:bottomGas:…)` (NDL preview), **not** from the full multigas deco simulation tissue trace.

---

## 11. Gap table vs reference screenshot

| Reference element | Status | File / component | Data source | Severity | Recommended approach |
|-------------------|--------|------------------|-------------|----------|---------------------|
| Back + Piano Immersione + share | Present | `PlanResultView` toolbar / nav | N/A | P3 | Polish spacing if needed |
| Tabs PIANO / CURVA BÜHLMANN / GRAFICI | Present | `PlanTab`, `resultTabs` | Localized strings | — | — |
| Summary TTR + TTS | Partial | `resultGrid` | `ttrMinutes` = TTS only | P2 | ViewModel: expose `ttsMinutes` + optional `totalRuntimeMinutes`; label TTS correctly |
| Summary deco / OTU / depth / bottom / CNS | Present | `resultGrid` | `DivePlanResult` | P3 | Optional rename CNS label to match reference |
| PIANO DI RISALITA table | Partial | `ascentTable` | `decoStops` | P2 | UI: optionally prepend bottom/travel rows from `segments` or new view-model rows |
| Columns Prof / Tempo / Gas / PPO₂ | Present | `tableRow` | `DecoStop` | — | — |
| Surface row | Present | `ascentTable` | Static row | — | — |
| Bottom row at max depth | Missing | — | Available in `segments` | P2 | UI-only row mapping from bottom segment |
| CURVA tissue loading 0–100% vs time | Missing | `buhlmannChart` | No tissue history | **P1** | **Algorithm output extension** then new chart |
| Compartment groups 1–4 … 13–16 over time | Missing | `ndlCurve` groups by depth band only | NDL preview | **P1** | Sample compartments during `BuhlmannEngine.plan` simulation |
| Legend for compartment groups | Partial | Chart series label | NDL groups | P2 | UI legend after real data exists |
| GRAFICI depth/deco charts | Partial | `segmentTimeline`, `gfComparisonCard` | Real segments | P2 | UI chart from `segments` (may not need algorithm change) |
| TRIMIX vs TX gas naming | Partial | `BuhlmannGas.label` | Engine | P3 | Copy/localization only |

---

## 12. Severity list

### P0 — Dangerous or misleading (mitigated)

- **None confirmed as silent false certification** — disclaimers and incomplete-calculation suppression are present.
- **Residual risk:** Bühlmann tab **looks like** a scientific decompression curve; disclaimer reduces but does not eliminate misinterpretation vs reference mock (**borderline P1**, not P0 given copy).

### P1 — Required feature missing vs reference

1. Tissue loading **time-series** not exported from engine.
2. CURVA BÜHLMANN tab is **NDL vs depth**, not **ZH-L16C loading vs time**.
3. Compartment grouping in chart is **not** real compartment saturation traces.

### P2 — Present but incomplete

1. Ascent table excludes bottom/travel rows shown in reference.
2. TTR/TTS summary labeling and missing explicit TTS tile.
3. GRAFICI lacks depth profile visualization.
4. No chart legend block matching reference.

### P3 — Cosmetic / polish

1. Gas label `TX` vs `TRIMIX`.
2. Column accent / typography vs screenshot.
3. Extra summary metrics beyond reference.

---

## 13. Recommended implementation plan

### P1 — Data foundation (algorithm output)

1. Extend `BuhlmannEngine.plan` (or wrapper) to record **sampled tissue state** at fixed time steps or segment boundaries: 16 compartments × (N₂, He) or supersaturation ratio vs M-value.
2. Add DTO e.g. `BuhlmannTissueHistorySample { elapsedMinutes, compartmentIndex, loadPercent }` to `BuhlmannEngineResult` / `DivePlanResult`.
3. Aggregate into display groups **1–4, 5–8, 9–12, 13–16** (max or controlling compartment per group).

**Classification:** Algorithm output extension + mathematical sampling (no change to stop math required if sampled from existing simulation loop).

### P1 — UI after data exists

4. Replace or add second chart in CURVA tab: **X = time (min)**, **Y = load (%)**, four series for compartment groups, legend, disclaimer retained.
5. Keep or relocate existing NDL chart under GRAFICI or as secondary “NDL reference” to avoid regression of `IOS_PLANNER_CHART_TRUTHFULNESS`.

**Classification:** UI-only once history exists.

### P2 — Ascent table & summary

6. Map bottom + travel segments into **PIANO DI RISALITA** (view-model rows from `plan.segments`).
7. Fix **TTR vs TTS** labels; show `enginePlan.ttsMinutes` as **TTS**; expose total runtime if reference requires **TTR** as runtime.

**Classification:** ViewModel mapping + UI.

### P2 — GRAFICI

8. Swift Charts depth-vs-time profile from `plan.segments`.

**Classification:** UI-only (data already in `segments`).

### P3 — Polish

9. Align gas display names, headers, card spacing with reference screenshot.

---

## 14. Gap classification summary

| Gap | Classification |
|-----|----------------|
| Missing tissue history | **Algorithm output extension** |
| Wrong Bühlmann chart axes/metric | **UI-only** after history exists; **blocked** without algorithm output |
| Decorative NDL “compartment” groups | **Static mock replacement with real data** (currently real NDL but wrong grouping semantics) |
| Ascent table missing bottom row | **ViewModel mapping** + **UI-only** |
| TTR/TTS label confusion | **ViewModel** + **UI-only** |
| Segment timeline not in PIANO tab | **UI-only** |
| TX vs TRIMIX label | **UI-only** / localization |
| Depth profile chart | **UI-only** (`segments` sufficient) |

**Implementing the reference Bühlmann curve correctly requires algorithm output extension, not merely a SwiftUI chart swap.**

---

## 15. PART 7 — Algorithm change required?

| Missing item | Requires algorithm change? |
|--------------|----------------------------|
| Tissue loading curve | **Yes** — time-series sampling during existing simulation |
| Real grouped compartment curves | **Yes** — same |
| Deco stop table content | **No** — already computed |
| Bottom row in table | **No** — data in `segments` |
| TTS/TTR display | **No** — values exist in `BuhlmannEngineResult` |
| Depth profile chart | **No** — `segments` exist |
| NDL chart replacement | **No** for NDL itself; **Yes** for reference tissue chart |

---

## 16. Confirmation

- **No Swift, algorithm, model, or UI code was modified** during this audit.
- **No build was run** — findings are from static inspection of `main` @ `b2ddc4e`.
- Prior documentation (`IOS_PLANNER_CHART_TRUTHFULNESS.md`, `DIR_DIVING_IOS_PLANNER_LIMITATIONS.md`) is **consistent** with this audit.

---

## Quick answers (final output summary)

| Question | Answer |
|----------|--------|
| Matches screenshot? | **Partial** |
| Ascent/deco stop table implemented? | **Yes** (partial vs reference row set) |
| Bühlmann compartment graph implemented? | **Partial** (chart yes; reference semantics **no**) |
| 16 compartments time-series? | **No** |
| Grouped curves 1–4 … 13–16 over time? | **No** |

### Top 5 gaps

1. **CURVA BÜHLMANN** plots **NDL vs depth**, not **tissue loading % vs time** (reference ZHL-L16C curve).
2. **No tissue compartment time-series** exported from `BuhlmannEngine` for charting.
3. **PIANO DI RISALITA** omits **bottom/travel** rows (e.g. 40 m / 20 min / bottom gas) present in reference table.
4. **TTR label** on summary tile binds **`ttsMinutes`**; separate **TTS/TTR** presentation not aligned with reference.
5. **GRAFICI** tab has **segment table + GF comparison**, not a **depth/deco profile chart** matching reference graphics.
