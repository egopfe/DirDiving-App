# DIR DIVING iOS — CNS / OTU Planner Implementation Audit

**Scope:** `DIRDiving iOS` planner result only  
**Positioning:** Reference-only oxygen exposure estimates — not certified oxygen tracking  
**Audit baseline:** post `IOS_MAIN_ALGORITHM_MATH_AUDIT` remediation

---

## Models

| Metric | Source | Includes |
|---|---|---|
| **CNS (full plan)** | NOAA CNS over full engine segments | Descent, bottom, ascent, deco, deco gases |
| **CNS descent + bottom** | Same model, `.descent` + `.bottom` filter | Excludes ascent/deco |
| **CNS ascent/deco estimate** | Derived delta (full − descent/bottom) | Presentation only |
| **OTU (dive)** | Lambertsen OTU | Full schedule |
| **OTU daily / weekly** | Rolling budgets with decay | Carryover when repetitive enabled |

Equations unchanged in `OxygenExposureModels.swift`.

---

## 15% descent + bottom rule

- Threshold: `> 15%` of 100% daily budget reference (`CNSDescentBottomPlannerRule`)
- Toggle: More → planner settings (`PlannerCNSDescentBottomCheckSettings`)
- UI: Red tile + banner; state `.cnsDescentBottomThresholdExceeded`

---

## Weekly OTU

- Computed in `OxygenExposureResult.otuWeekly`
- Displayed in planner secondary metrics when finite (`showsWeeklyOTUMetric`)
- Warning when `otuWeekly >= OTUREPEXLimits.weeklyOTU` → `.otuWeeklyElevated` + banner

---

## Granular warning states

| State | Trigger |
|---|---|
| `.cnsSingleElevated` | Full-plan CNS threshold |
| `.cnsDailyElevated` | Daily CNS threshold |
| `.otuDiveElevated` | Single-dive OTU |
| `.otuDailyElevated` | 24 h OTU |
| `.otuWeeklyElevated` | Weekly OTU |
| `.cnsDescentBottomThresholdExceeded` | 15% rule |
| `.oxygenExposureElevated` | Umbrella when any exposure warning |
| `.PPO2Exceeded` | Segment PPO₂ vs gas limit |

---

## UI visibility matrix

| UI element | Base | Deco | Technical |
|---|---|---|---|
| CNS preview (input) | ✓ | ✓ | ✓ |
| CNS full plan tile | ✓ | ✓ | ✓ |
| CNS descent+bottom | ✓ | ✓ | ✓ |
| Weekly OTU | ✓ | ✓ | ✓ |
| OTU dive / daily summary | ✓ | ✓ | ✓ |

---

## Localization (EN / IT)

Keys include: `planner.metric.cns_full_plan*`, `planner.metric.cns_descent_bottom*`, `planner.metric.otu_weekly*`, `planner.warning.otu_weekly_elevated`, `planner.state.cns_single_elevated.*`, `planner.state.otu_*_elevated.*`

Tests: `PlannerCNSCopyTests.swift`, `PlannerOxygenWarningGranularityTests.swift`

---

## Limitations

- Logbook / analysis do **not** store post-dive CNS/OTU
- Weekly OTU carryover depends on planner repetitive inputs
- Not certified oxygen tracking or decompression advice

---

*See also:* [`DIR_DIVING_IOS_OXYGEN_EXPOSURE_MODEL.md`](DIR_DIVING_IOS_OXYGEN_EXPOSURE_MODEL.md)
