# CCR / Rebreather Planner — DIR DIVING iOS MAIN

**Last updated:** 2026-06-14 (`main` @ `99ea74a`)  
**Product stance:** **Reference-only** companion planner — not a certified CCR controller.

## Scope

The iOS Companion MAIN includes a dedicated **CCR / Rebreather planner** surface (`CCRPlannerView`, `CCRPlannerEngine`) isolated from open-circuit Bühlmann. It helps divers compare:

- Setpoint profiles (low / high switching depth)
- Diluent and bailout gas choices
- Reference deco schedules and tissue traces
- Heuristic bailout cylinder reserves (SAC-based estimates)

Apple Watch **does not** run CCR loop logic. Watch remains a diving logger with ascent awareness and **BUSSOLA** — not live loop monitoring.

## Engine architecture

| Component | Role |
|-----------|------|
| `CCRPlannerEngine` | Deco schedule and inspired-gas math for CCR profiles |
| `CCRTissueHistorySampler` | Chart tissue trace aligned with CCR engine |
| Bailout module | Heuristic SAC × stress × crude deco time — **not** OC Bühlmann bailout simulation |
| `runtimeSegments` | Reserved / quarantined — does not affect current output |

Bühlmann ZHL-16C remains the **primary OC planner** engine. Ratio Deco remains a **comparative heuristic only** on OC surfaces.

## UI surfaces

- **Input:** setpoints, diluent, bailout cylinders, GF, profile depth/time
- **Results:** schedule table, tissue charts, narcosis/END reference estimates, bailout heuristic panel
- **Export:** separate CCR Plan PDF — see [`CCR_REBREATHER_EXPORT_POLICY.md`](CCR_REBREATHER_EXPORT_POLICY.md)
- **Equipment sync:** checklist ↔ planner gas import/export — see [`CCR_REBREATHER_CHECKLIST_SYNC.md`](CCR_REBREATHER_CHECKLIST_SYNC.md)

## Safety and disclaimers

All CCR outputs are **indicative**. Read [`CCR_REBREATHER_SAFETY_DISCLAIMER.md`](CCR_REBREATHER_SAFETY_DISCLAIMER.md) and [`CCR_REBREATHER_LIMITATIONS.md`](CCR_REBREATHER_LIMITATIONS.md) before use.

## Validation status

External CCR profile validation is **PENDING** — [`CCR_REBREATHER_VALIDATION_PLAN.md`](CCR_REBREATHER_VALIDATION_PLAN.md), [`CCR_REBREATHER_VALIDATION_EVIDENCE.md`](CCR_REBREATHER_VALIDATION_EVIDENCE.md).

## Related documents

| Document | Purpose |
|----------|---------|
| [`CCR_REBREATHER_LIMITATIONS.md`](CCR_REBREATHER_LIMITATIONS.md) | Mathematical and product limitations |
| [`CCR_REBREATHER_EXPORT_POLICY.md`](CCR_REBREATHER_EXPORT_POLICY.md) | PDF/export truthfulness |
| [`SAFETY_DISCLAIMER.md`](SAFETY_DISCLAIMER.md) | Global app safety disclaimer |
| [`DIR_DIVING_CCR_PLANNER_IMPLEMENTATION_REPORT.md`](DIR_DIVING_CCR_PLANNER_IMPLEMENTATION_REPORT.md) | Implementation history |
