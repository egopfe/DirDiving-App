# DIR Diving — iOS Oxygen Exposure Model (MAIN)

**Scope:** iOS Companion planner reference only — not certified oxygen exposure guidance.

---

## CNS and OTU (full profile)

The planner integrates CNS and OTU over the **complete Bühlmann runtime schedule** (descent, bottom, gas switches, ascent, decompression stops) using:

- `OxygenExposureModel` in `iOSApp/Services/OxygenExposureModels.swift`
- NOAA piecewise single- and daily-exposure CNS limits
- 90-minute surface / in-water air-break recovery (PPO₂ ≤ 0.5 bar)
- Lambertsen REPEX OTU thresholds (300 / 850 / 1800)

Repetitive planning may apply `OxygenExposureCarryover` from a prior dive snapshot.

---

## CNS Descent + Bottom (planner-only)

### Definition

**CNS Descent + Bottom** is the CNS clock percentage accumulated **only** during planner segments classified as:

- `DiveSegmentKind.descent`
- `DiveSegmentKind.bottom`

Excluded from this metric (same integration model, but segments filtered out):

- Ascent
- Decompression stops (`stop`)
- Gas switches (`gasSwitch`)
- Surface intervals (not part of the generated schedule)
- Post-bottom gas-switch segments

Computation reuses `OxygenExposureModel` integration (no second CNS model). Carryover is **not** applied for this metric — it measures descent + bottom phases of the **current planned profile** only.

API: `OxygenExposureModel.cnsPercentDescentAndBottom(segments:environment:)`

Exposed on `TechnicalGasAnalysis.cnsDescentBottomPercent` after a full engine plan is available.

### 15% planner warning rule

| Constant | Value |
|----------|-------|
| Maximum daily CNS budget (reference) | 100% |
| Planner informational threshold | 15% |

```
descentBottomPercentage = cnsDescentBottomPercent

if descentBottomPercentage > 15%  →  exceeded (warning UI)
else                            →  acceptable
```

Implemented in `CNSDescentBottomPlannerRule` (`OxygenExposureModels.swift`).

### UI (informational only)

**Settings (More tab):** toggle `dirdiving_ios_planner_cns_descent_bottom_check_enabled` (default **on**). When off, the CNS Descent + Bottom value still appears in planner results but the 15% warning styling and message are suppressed.

Shown in the planner **result** grid alongside CNS% and OTU:

- Label: localized “CNS Descent + Bottom” / “CNS Discesa + Fondo”
- Value > 15%: existing red accent + warning triangle (no new color system)
- Warning copy shown only when threshold exceeded (IT/EN localized)

This does **not** change decompression stops, gas selection, or Bühlmann math.

### Purpose

- Help divers compare oxygen load **before ascent/deco** against a simple daily-budget fraction
- **Non-certified** planner hint — not a substitute for NOAA tables, agency limits, or dive-computer CNS

---

## Tests

`Tests/iOSAlgorithmTests/CNSDescentBottomTests.swift` — segment filtering, 15% boundary, trimix/nitrox profiles, NaN/infinity guards.

---

*Document aligned with MAIN @ `caa55d2` + CNS Descent + Bottom pass.*
