# DIR Diving — iOS Oxygen Exposure Model (MAIN)

**Scope:** iOS Companion planner reference only — not certified oxygen exposure guidance.

---

## CNS and OTU (full profile)

The planner integrates CNS and OTU over the **complete Bühlmann runtime schedule** (descent, bottom, gas switches, ascent, decompression stops) using:

- `OxygenExposureModel` in `iOSApp/Services/OxygenExposureModels.swift`
- NOAA piecewise single- and daily-exposure CNS limits
- 90-minute surface / in-water air-break recovery (PPO₂ ≤ 0.5 bar)
- Lambertsen REPEX OTU thresholds (300 / 850 / 1800)

### OTU constant-depth (canonical direction)

When inspired PPO₂ > 0.5 bar:

`OTU = minutes × ((PPO₂ − 0.5) / 0.5)^(5/6)`

PPO₂ ≤ 0.5 bar contributes **0** OTU. OTU increases monotonically with PPO₂ for fixed duration. This is a **reference estimate only** — not certified pulmonary oxygen toxicity guidance; does not replace training, agency standards, REPEX tables, or certified dive computers.

Ramp segments use Baker Eq. 2 integration consistent with the corrected constant-depth rate.

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

**Pre-calculation (Planner input — DENSITY / END card):**

- **CNS (bottom preview)** — bottom-phase reference only; footnote states full-plan CNS appears after **Calcola Piano**.
- **OTU** — preview alongside preview CNS.

**Post-calculation (Dive plan result — PLAN tab grid):**

| Label (EN) | Meaning |
|------------|---------|
| **CNS (full plan)** | Total CNS for the complete planned profile (descent, bottom, ascent, decompression stops, decompression gases). |
| **CNS Descent + Bottom** | CNS integrated only on descent + bottom segments; excludes ascent and decompression stops. |
| **CNS ascent/deco (est.)** | Derived `max(0, fullPlanCNS − descentBottomCNS)`; informational only — not a per-gas certified breakdown. |
| **OTU** | Full-profile OTU reference estimate. |

Footnotes (EN/IT) clarify inclusion/exclusion and reference-only posture.

**15% planner warning (result screen):**

- Toggle: **More → CNS Descent + Bottom 15% check** (`dirdiving_ios_planner_cns_descent_bottom_check_enabled`, default **on**).
- When **CNS Descent + Bottom > 15%** and toggle on: value turns red, warning triangle, red warning text + action-oriented hint, VoiceOver label/hint.
- Does **not** change decompression stops, gas selection, or Bühlmann math.

This does **not** change decompression stops, gas selection, or Bühlmann math.

### Purpose

- Help divers compare oxygen load **before ascent/deco** against a simple daily-budget fraction
- **Non-certified** planner hint — not a substitute for NOAA tables, agency limits, or dive-computer CNS

---

## Tests

- `Tests/iOSAlgorithmTests/CNSDescentBottomTests.swift` — segment filtering, 15% boundary, trimix/nitrox profiles, NaN/infinity guards.
- `Tests/iOSAlgorithmTests/OTUCanonicalFixtureTests.swift` — independent Lambertsen OTU fixtures, monotonicity, ramp/segment integration.
- `Tests/iOSAlgorithmTests/OxygenExposureDeepModelTests.swift` — NOAA CNS tables, schedule integration, carryover.

---

*Document aligned with MAIN @ `caa55d2` + CNS Descent + Bottom pass.*
