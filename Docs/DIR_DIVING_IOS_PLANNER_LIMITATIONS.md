# DIR DIVING iOS Planner Limitations

Date: 2026-05-29 (comprehensive readiness implementation pass)  
Scope: iOS Companion MAIN only

## Safety Position

DIR DIVING iOS is not a certified dive computer. The planner is a Buhlmann-based planning reference and must be validated against certified instruments, training, tables, team procedures, and instructor guidance.

## Implemented Reference Engine

The iOS planner now includes a ZHL-16C N2+He multigas reference engine:

- Air, nitrox, trimix, and heliox gas compositions.
- Travel, bottom, and decompression gases.
- Gas switches at configured depths.
- GF Low / GF High based ceiling and stop propagation.
- Tissue-state NDL.
- Runtime/TTS schedule generation from profile segments, with TTS separated from total runtime.
- Optional non-air-saturated initial tissue state for repetitive/reference planning workflows.

## Environment Baseline (2026-05-29)

- **Single surface-pressure baseline:** `BuhlmannConstants.seaLevelSurfacePressureBar` = `1.01325` bar, aligned with `PlannerEnvironment.seaLevelSaltWater`.
- **`airSaturated()`** default uses the same constant — not legacy `IOSAlgorithmConfiguration.surfacePressureBar` (1.0 bar).
- **Preview/plan consistency:** `PlannerStore` passes `PlannerEnvironment` into `BuhlmannPlanner.plan` for NDL curve preview; preview NDL aligns with plan NDL within documented tolerance for the same inputs.
- **Nil-environment Bühlmann fallback:** Uses ISA sea-level saltwater pressure formula — not legacy `1.0 bar + 10 m/bar` helper.

## Repetitive Planning Semantics (2026-05-29)

- Tissue snapshot is sourced from the **prior calculated reference plan** when the user taps **Calculate Plan** — not from dive log or watch tissue data.
- Logbook-derived tissue seeding is **not implemented** (documented future enhancement).
- Invalid, missing, stale, corrupt, schema-mismatched, or environment-incompatible snapshots fail closed with typed `PlannerResultState` values.
- Invalid surface interval emits `.surfaceIntervalRejected` (non-finite or negative minutes).

## Bailout Gas Role (2026-05-29)

- Bailout cylinders are visible in gas configuration and schedule lines.
- Bailout is used for **reserve/contingency** messaging in gas planning — **not** part of the primary Bühlmann decompression schedule unless explicitly implemented in `BuhlmannEngine`.
- Plan result shows an explicit bailout schedule hint when bailout gas is configured.

## CNS / OTU (2026-05-29, comprehensive reference model)

- **CNS single exposure:** NOAA 1991 piecewise-linear time limits (Baker / NOAA Diving Manual). Constant-depth segments use `minutes / Tlimit(PPO2) × 100`. Descent/ascent ramps integrate in 0.05-minute steps along the linear PPO2 path.
- **CNS daily (24 h):** NOAA daily limit table with linear interpolation between canonical knots (1.0–1.6 bar). Daily CNS accumulates in parallel with single-exposure CNS using the daily limit function.
- **CNS recovery:** 90-minute half-time decay during surface intervals and in-water segments where inspired PPO₂ ≤ 0.5 bar (air-break recovery).
- **OTU dive:** Lambertsen UPTD with constant-depth `(0.5 / (PPO2 − 0.5))^(5/6) × minutes` and Baker Eq. 2 ramp integration on linear PPO₂ changes.
- **OTU daily / weekly:** REPEX-style reference thresholds — elevated dive OTU ≥ 300, daily 24 h OTU ≥ 850, weekly OTU ≥ 1 800. Daily OTU resets after 24 h surface interval; weekly after 7 days.
- **Repetitive carryover:** Tissue snapshot schema v2 stores `oxygenCarryover` from the prior calculated profile; surface interval applies CNS decay and OTU window resets before the next plan.
- Schedule segments reconstruct start/end depth from runtime order so exposure reflects descent and ascent, not just target depth.
- Still **reference-only** — not certified oxygen exposure authority; not a substitute for manufacturer tables, medical guidance, or dive-computer CNS clocks.

## CNS / OTU UI clarity (2026-06-02)

| UI label | Scope |
|----------|--------|
| **CNS (bottom preview)** | Pre-calculation only; bottom-phase estimate — not the full planned profile. |
| **CNS (full plan)** | After calculation; includes descent, bottom, ascent, decompression stops, and decompression gases. |
| **CNS Descent + Bottom** | After calculation; descent + bottom only — excludes ascent and decompression stops. |
| **CNS ascent/deco (est.)** | Derived difference (full plan minus descent+bottom); not a certified per-gas CNS ledger. |

**15% rule:** When descent+bottom CNS exceeds 15% of the reference maximum CNS budget (100%), the planner shows a red value, localized warning, and corrective hint (EN/IT). User can disable the warning highlight in **More** settings; values remain visible.

**Accessibility:** Warning banner exposes dedicated VoiceOver label and hint (EN/IT).

**Remaining limitation:** No separate certified breakdown of CNS contribution per decompression gas cylinder — only schedule PPO₂ in the ascent table.

## Current Assumptions

- Planner environment supports altitude-aware surface pressure and salinity-aware water density via `PlannerEnvironment`; invalid altitude/salinity fail closed with `.invalidEnvironment`.
- Rock-bottom, reserve, EAD/END, and segment PPO2 calculations route through `PlannerEnvironment`.
- Surface-interval off-gassing for repetitive planning uses altitude-aware surface pressure.
- Gas consumption ledgers key cylinders by stable UUID.
- Water vapor pressure is fixed at `0.0627 bar`.
- Stops are rounded to 3 m intervals.
- Default descent rate is 18 m/min; ascent 9 m/min; switch dwell 0.5 min.
- Gas density, CNS, OTU, END, and EAD remain reference estimates.

## Known Limitations

- External Bühlmann validation campaign documented but **not completed** — see `DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_PLAN.md`.
- Physical-device accessibility QA checklist exists but **requires manual execution** — see `DIR_DIVING_IOS_PHYSICAL_ACCESSIBILITY_QA.md`.
- The planner does not replace real-time decompression control.
- Individual physiology, workload, thermal stress, and equipment failures are not modeled.
- GF comparison computes up to four full engine plans; results are cached but first calculation may briefly block UI.
- App Store/TestFlight review remains required.

## UX Presentation

The iOS planner UI exposes repetitive planning, schedule gas ledger, environment assumptions, typed warnings, CNS/OTU reference labeling, bailout hints, calculation progress on Calculate, and explicit result headers. These are presentation layers — not certified decompression advice.

## Fail-Closed Policy

The planner must not silently normalize unsafe input into valid-looking output. Invalid gas mixes, gradient factors, MOD violations, hypoxic gas, invalid switch depths, impossible profiles, invalid repetitive state, and **incomplete decompression schedules** must surface as blocking states or unavailable output.

## Algorithmic readiness pass (2026-05-31 @ `dce89e7`)

Implemented per [`IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md) and [`IOS_MAIN_ALGORITHM_READINESS_100_REPORT.md`](IOS_MAIN_ALGORITHM_READINESS_100_REPORT.md):

| Area | Behaviour |
|------|-----------|
| **Pressure / MOD / PPO₂** | Single `AmbientPressureModel` path via `PlannerEnvironment`; actual PPO₂ shown when over limit |
| **Planning depth** | User toggle max vs average depth; end-to-end NDL, deco, gas, contingencies |
| **Cloud sync** | Per-session merge via `DiveSessionMerge.preferred`; conflict list published |
| **CSV** | `# session_meta` export/import — see [`SUBSURFACE_CSV_ROUNDTRIP.md`](SUBSURFACE_CSV_ROUNDTRIP.md) |
| **Incomplete calc** | Partial stops suppressed; explicit incomplete message (EN/IT) |
| **Contingencies** | Engine-driven recomputation; no mock GF helper in production path |
| **Analysis** | Demo dives excluded from aggregates by default; optional include toggle |
| **Depth limits** | Centralized in `IOSAlgorithmConfiguration` with documented CSV/sync/planner ranges |
| **OTU recovery** | Progressive budget decay between binary reset windows |

**Tests:** 154 iOS algorithm XCTest (1 skipped), 0 failures local iPhone 17 sim @ `dce89e7`.
