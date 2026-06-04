# iOS planner limitations (reference-only)

DIR DIVING iOS planner output is **informational reference only**. It is not a certified decompression planner or dive computer.

## Environment model

- Altitude and salinity adjust ambient pressure, MOD, NDL preview, END/EAD, rock-bottom, and Bühlmann ceilings through `PlannerEnvironment` / `AmbientPressureModel`.
- MOD display and warnings use environment-aware helpers; sea-level convenience APIs are documented as non-safety paths.

## Bühlmann preview vs full plan

- Preview NDL and NDL curve seed tissue state with `.airSaturated(surfacePressureBar: environment.surfacePressureBar)` matching full engine assumptions.
- Full plans run `BuhlmannPlanPreflightValidator` before schedule generation (descent/bottom via engine validate; deco/travel bands via extended preflight).

## Gas ledger

- **Consumed totals** reflect gases used in the generated Bühlmann schedule only.
- **Unused planned** and **bailout/standby** cylinders appear in `unusedPlannedEntries` — not counted as schedule consumption.
- See `ScheduleGasConsumptionService` and planner UI “Unused planned gas” section.

## Analysis dashboard

- SAC and temperature summaries are **arithmetic means across sessions**, not duration-weighted averages.

## Oxygen exposure

- CNS/OTU estimates may extrapolate/clamp at high PPO₂; `.PPO2Exceeded` dominates planner warning state when configured limits are exceeded.

## Manual dive pressures

- Entry/exit pressures store canonical **bar** values when edited on device; display respects user unit preference.
- Legacy text-only sessions infer `bar`/`psi` from suffix when present.
