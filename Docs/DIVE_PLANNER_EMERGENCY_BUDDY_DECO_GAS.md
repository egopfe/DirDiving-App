# Diving Planner — Emergency Buddy Deco Gas

## Purpose

Snorkeling-independent **Diving Planner** feature in the **Emergency** section. When enabled, emergency decompression gas adequacy checks include an assisted buddy using a conservative **2× multiplier** on primary diver deco gas per gas mix.

## UI location

**Planner → Emergency** (`emergencyCard` in `PlannerView`):

- Toggle **Include buddy deco gas** / **Calcola gas deco anche per buddy**
- Default: **OFF**

Results appear in the plan output as **Emergency deco gas** with per-gas adequacy and briefing summary lines.

## Behavior

| Toggle | Required deco gas |
|--------|-------------------|
| OFF | Primary diver deco consumption only |
| ON | Primary + buddy (buddy = primary; total = 2× primary per gas) |

## What does NOT change

- Bühlmann decompression schedule
- Gradient Factors
- Deco stop depths/durations
- Gas switch policy
- CNS / OTU
- Watch / Full Computer runtime
- Apnea / Snorkeling
- Selected gases or cylinder configuration

## Technical mapping

- Required liters per gas: `SAC × ATA × minutes` summed over **deco stop segments only**
- Buddy ON: `requiredTotal = requiredPrimary × 2`
- Available liters: sum of deco cylinder start volumes per gas label
- Bar reserve/shortfall: `liters / cylinderWaterCapacityLiters` when capacity known

## Persistence

Stored on `GasPlanInput.includeBuddyDecoGas` inside planner CloudSync state (`dirdiving_ios_experimental_planner_state`). Missing key decodes to `false`.

## Limitations (v1)

- Buddy uses 2× primary deco gas; no custom buddy RMV yet
- Emergency verification only; does not alter live dive runtime

## QA

Physical QA templates under `Docs/QA_EVIDENCE/DIVE_PLANNER_EMERGENCY_BUDDY_DECO_GAS_*` — default **PENDING**.
