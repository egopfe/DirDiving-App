# DIR DIVING iOS — Planner Emergency / Rock Bottom Settings

## Overview

The iOS Companion MAIN planner (`DIRDiving iOS`) includes a dedicated **Emergency** / **Emergenza** section that parameterizes the Rock Bottom / minimum gas estimate. This is reference-only planning UI; it does not change Bühlmann decompression, CCR, or Ratio Deco math.

## Location

Planner input screen, shown for modes that display gas reserve planning (**Deco** and **Technical**), immediately before **Available Gas** / **Pianificazione Gas**.

## User-configurable parameters

| Parameter | Default | Range | Unit |
|-----------|---------|-------|------|
| Team Size | 2 | 1–6 | divers (integer) |
| Emergency SAC | 30 | existing validation | L/min |
| Extra Emergency Minutes | 3 | 0–30 | min |

Emergency SAC is separate from normal SAC/RMV used for schedule consumption.

## Automatic (read-only in UI)

**Automatic ascent time** is computed from planned depth:

```
automaticAscentMinutes = max(3, plannedDepthMeters / 9.0)
```

Users cannot edit ascent time directly.

## Rock Bottom formula

```
averageAscentDepth = plannedDepthMeters / 2
averageAscentATA = ambient pressure at averageAscentDepth
emergencyMinutes = automaticAscentMinutes + extraEmergencyMinutes

Rock Bottom (L) = emergencySAC × teamSize × averageAscentATA × emergencyMinutes
```

Pressure equivalent on the primary back-gas cylinder is shown as a secondary value (liters primary).

## What is unchanged

- Bühlmann engine and decompression stop generation
- CCR planner and setpoint math
- Ratio Deco planner
- Schedule gas consumption ledger (bottom/deco/travel segments)
- Normal SAC/RMV consumption
- Available / remaining gas math (except Rock Bottom threshold follows new parameters)
- MOD/PPO₂/Dalton and gas-switch validation

## Persistence

`GasPlanInput.emergencyExtraMinutes` is stored with planner state. Legacy saved inputs without this key decode to **3.0** minutes.

## Disclaimer

Rock Bottom remains a reference minimum gas estimate. It does not replace training, team procedures, or certified planning tools.
