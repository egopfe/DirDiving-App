# iOS Planner — Chart Truthfulness

**Scope:** `DIRDiving iOS` Bühlmann result tabs, reference-only planner.

## Primary chart — ZH-L16C tissue loading (CURVA BÜHLMANN)

The primary CURVA BÜHLMANN chart plots **sampled tissue history** from the generated reference plan:

- **X-axis:** elapsed plan time (min) — `BuhlmannTissueGroupPoint.elapsedMinutes`
- **Y-axis:** display load (%) — max compartment `loadPercent` per group at each timestamp
- **Series:** Compartments 1–4, 5–8, 9–12, 13–16 (localized legend)

Data source: `BuhlmannEngineResult.tissueHistory` → `DivePlanResult.tissueHistory`.

### Sampling semantics

- Tissue history is **sampled for visualization only** by replaying `BuhlmannRuntimeSegment` data through the existing Schreiner/Haldane loaders (`BuhlmannTissueHistorySampler`).
- Sampling cadence: **1-minute steps** within each segment, plus segment boundaries.
- Sampling **does not alter** decompression stop calculation, stop depths, or stop durations.
- Duplicate `(elapsedMinutes, compartmentIndex)` samples are replaced with the latest value.

### Load / supersaturation metrics (display)

Per compartment at sample time:

- `loadPercent` = `(totalInert / M-value) × 100`, display-clamped to `[0, 100]`
- `supersaturationPercent` = `((totalInert − inspiredInert) / (M-value − inspiredInert)) × 100`, display-clamped
- M-value uses mixed N2/He a/b coefficients at ambient depth for the breathing gas in that segment.
- GF for tolerated ambient follows the same depth interpolation as the decompression schedule.

### Group aggregation

Documented method: **`max_load_percent_per_group`** — at each timestamp, each group shows the **maximum** `loadPercent` among its four compartments.

### Empty state

When tissue history is unavailable (invalid plan, blocking issues), the CURVA BÜHLMANN tab shows a safe empty state — **not** the legacy NDL chart as a primary substitute.

### Copy

- `planner.buhlmann.tissue_curve_title`
- `planner.buhlmann.tissue_curve_disclaimer` — sampled ZH-L16C reference visualization; not certified decompression advice.

## Secondary chart — NDL reference curve (Technical mode)

When NDL preview data exists, Technical mode shows a **secondary** chart below the tissue chart:

- Title: `planner.buhlmann.ndl_reference_title`
- **X-axis:** depth (m)
- **Y-axis:** NDL minutes
- Source: `BuhlmannPlanner.ndlCurve` / `store.buhlmann.curve`
- Disclaimer: `planner.buhlmann.curve_disclaimer` — explicitly **not tissue loading**

## Depth profile chart (GRAFICI)

- Title: `planner.charts.depth_profile`
- **X-axis:** elapsed time (min)
- **Y-axis:** depth (m), inverted visually (negative Y values)
- Source: `PlannerDepthProfileBuilder.points(from: plan.segments)`

## Ascent table rows

`PlannerAscentTableBuilder` maps engine segments + deco stops into PIANO DI RISALITA rows:

| Row kind | Source |
|----------|--------|
| Bottom | Bottom segments at max depth |
| Travel | Descent/ascent runtime segments |
| Deco stop | `DecoStop` from engine |
| Surface | Static surface row |

## Summary metrics

- **TTS** = `BuhlmannEngineResult.ttsMinutes` (time to surface from end of bottom)
- **Runtime** = `BuhlmannEngineResult.totalRuntimeMinutes` (full planned profile)
- The legacy **TTR** label on the TTS value was removed.

## Tests

- `BuhlmannTissueHistoryTests`
- `PlannerCurveChartTests`
- `PlannerAscentTableTests`
- `PlannerDepthProfileTests`
- `PlannerLocalizationTests`
