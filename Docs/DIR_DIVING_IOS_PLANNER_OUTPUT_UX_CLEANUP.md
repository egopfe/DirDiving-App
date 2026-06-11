# DIR Diving iOS — Planner Output UX Cleanup

**Branch:** `main`  
**Scope:** Presentation-only

## 1. Runtime immersione ordering

The **Dive Runtime** table follows the Bühlmann engine operational timeline. Deco stops (**Sosta Deco** / **Deco Stop**) are interleaved with **Trasporto** / **Travel** rows at the correct depth/time. Values are not recalculated.

## 2. Tappe decompressive

A separate **Deco Stops** section lists only true decompression stops from `DivePlanResult.decoStops` (or CCR `decoStops`). Hidden for Base/no-deco plans.

## 3. Buddy comparison removal

Partial gas-only team/buddy comparison was removed from the main Planner UI and briefing PDF. Internal `teamGasMatches` computation is preserved for future **Team / Buddy Planning**.

## 4. Gas disponibile

Sections that showed loaded/available gas were renamed from misleading **Riserva gas** / **GAS RESERVE** to **Gas disponibile** / **Available Gas**. True reserve/minimum gas warnings keep their reserve naming.

## 5. Gas display format

Gas ledger and available-gas cards show:

- **Primary:** liters (actual gas quantity)
- **Secondary:** `≈` pressure equivalent for the specific cylinder

Pressure equivalents are display-only and cylinder-specific.

## Calculation boundaries

No Bühlmann, CCR, Ratio Deco, gas planning, MOD/PPO₂, or planner mode logic was changed.
