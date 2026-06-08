# CCR / Rebreather External Validation Plan

**Status:** Pending — not executed in code remediation pass (2026-06-08)  
**Evidence matrix:** [`CCR_REBREATHER_VALIDATION_EVIDENCE.md`](CCR_REBREATHER_VALIDATION_EVIDENCE.md)  
**Product stance:** DIR DIVING CCR planner is a **reference-only** companion tool, not a certified CCR controller.

## Objectives

1. Compare representative CCR reference profiles (setpoint switching, diluent mixes, GF stops) against trusted external tables/tools.
2. Verify bailout heuristic outputs are never interpreted as Bühlmann OC bailout schedules.
3. Confirm UI/PDF disclaimers remain visible in EN/IT.

## Evidence slots

| Case | Depth / time | Setpoints | Diluent | Pass/Fail | Evidence file |
|---|---|---|---|---|---|
| CCR-01 | 30 m / 25 min | 0.7 / 1.3 @ 20 m | Air | ☐ | |
| CCR-02 | 45 m / 20 min | 0.7 / 1.3 @ 20 m | TMX 21/35 | ☐ | |
| CCR-03 | Manual shallow-ascent low SP | 0.7 / 1.3 | Air | ☐ | |
| CCR-04 | Bailout heuristic vs external SAC estimate | — | EAN32 bailout | ☐ | |

## Blockers for external TestFlight

- No third-party CCR profile sign-off
- No manufacturer procedure review
- No physical loop QA (out of scope for companion app)

## Related docs

- `Docs/IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`
- `Docs/IOS_MAIN_ALGORITHM_MATH_AUDIT_REMEDIATION_REPORT.md`
- `Docs/DIR_DIVING_IOS_EXTERNAL_VALIDATION_AND_QA_PLAN.md`
