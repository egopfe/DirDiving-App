# CCR / Rebreather Planner — Limitations (DIR DIVING iOS MAIN)

**Last updated:** 2026-06-08 (comprehensive readiness remediation)

## Product scope

DIR DIVING includes a **CCR / Rebreather reference planner** on iOS Companion MAIN. It helps divers **compare reference setpoint profiles, diluent choices, deco schedules, and heuristic bailout reserves**. It is **not**:

- a certified CCR controller or loop monitor
- live loop PPO₂ monitoring (no validated sensor integration)
- manufacturer procedure replacement
- a Bühlmann OC bailout switch simulator (bailout module uses **heuristic SAC estimates**)

## Mathematical model

| Component | Behavior |
|---|---|
| Inspired gas | Setpoint + diluent with water vapor correction |
| Deco schedule | Dedicated `CCRPlannerEngine` (isolated from OC Bühlmann) |
| Tissue trace (charts) | `CCRTissueHistorySampler` aligned with CCR engine |
| Narcosis / END | Simplified loop density estimator — **reference estimates only** |
| Bailout scenarios | SAC × stress × crude deco time estimate — **heuristic reserve** |
| `runtimeSegments` | **Inactive / quarantined** — reserved for future manual setpoint timeline; **does not change** current engine output |

## UI / export truthfulness

- All bailout outputs labeled **heuristic** (EN/IT).
- PDF includes reference-only disclaimer and narcosis estimator footnote.
- Dive Pack PDF is **OC planner only** — CCR uses separate CCR Plan PDF export ([`CCR_REBREATHER_EXPORT_POLICY.md`](CCR_REBREATHER_EXPORT_POLICY.md)).

## Watch

Apple Watch **does not** run CCR loop logic. Synced data must not be shown as live CCR monitoring on Watch.

## External validation

Pending — see [`CCR_REBREATHER_VALIDATION_EVIDENCE.md`](CCR_REBREATHER_VALIDATION_EVIDENCE.md).
