# iOS planner limitations (reference-only)

DIR DIVING iOS planner output is **informational reference only**. It is not a certified decompression planner or dive computer.

## Environment model

- Altitude and salinity adjust ambient pressure, MOD, NDL preview, END/EAD, rock-bottom, and Bühlmann ceilings through `PlannerEnvironment` / `AmbientPressureModel`.
- **All planner modes** (Base, Deco, Technical) validate environment inputs; invalid altitude/salinity returns `.invalidEnvironment` — no silent sea-level fallback in the validation path.
- MOD display and warnings use environment-aware helpers; sea-level convenience APIs are documented as non-safety paths.

## Planner three-mode projection

- **Base:** single bottom gas; standard GF preset; NDL preview uses projected input (not hidden Technical draft gases/GF).
- **Deco:** bottom + max one deco gas; NDL reference tab shows simplified Bühlmann output — **not** the full Technical compartment/tissue chart.
- **Technical:** full multigas draft; full Bühlmann presentation including charts where enabled.

## Cloud / iCloud sync

- Divergent depth profiles between local and iCloud for the same session ID surface a **depth profile merge conflict** — no silent hybrid sample fusion.
- iCloud KVS backup rejects payloads over **512 KB** (`IOSAlgorithmConfiguration.maxSyncPayloadBytes`); local protected logbook remains authoritative on device.

## PPO₂ tolerance policy

- `ppo2HardValidationToleranceBar` (0.0001 bar) — strict segment/runtime validation.
- `ppo2DecoGasSwitchDepthToleranceBar` (0.02 bar) — deco switch depth rounding tolerance only.
- Display warnings follow engine validation policy; `.PPO2Exceeded` dominates when limits are exceeded.

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
