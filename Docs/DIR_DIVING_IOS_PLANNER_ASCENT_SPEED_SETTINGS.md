# DIR DIVING iOS — Planner Ascent Speed Settings

## Overview

Global **Planner Ascent Speeds** / **Velocità di risalita planner** settings control operational transit-time estimation in the iOS Companion MAIN planner. They do **not** change Bühlmann decompression stop depths or durations.

## Location

**More → Settings → Planner Ascent Speeds**

## Depth bands (m/min)

| Band | Default |
|------|---------|
| Deeper than 40 m | 9 |
| 40–30 m | 9 |
| 30–20 m | 9 |
| 20–6 m | 6 |
| 6–0 m | 3 |

Range: 1–18 m/min per band.

## What changes

- **Runtime immersione / Dive Runtime** — Risalita / transit row minutes
- **Gas consumption** — transit/ascent segment minutes in the schedule ledger
- **Rock Bottom** — automatic ascent time component (plus user extra emergency minutes)
- **Total runtime** display derived from operational segments

## What does not change

- Bühlmann stop depths
- Bühlmann stop minutes
- Tissue loading / GF / NDL / TTS (Bühlmann engine)
- CCR planner
- Ratio Deco planner
- MOD/PPO₂ validation
- Gas consumption formula: `SAC × ATA × minutes` (only `minutes` for transit changes)

## Formulas

**Transit ascent time** between depths:

```
ascentMinutes(from, to) = Σ (distance in band / band speed)
```

**Rock Bottom emergency time**:

```
emergencyMinutes = ascentMinutes(plannedDepth, 0) + extraEmergencyMinutes
Rock Bottom = emergencySAC × teamSize × averageAscentATA × emergencyMinutes
```

## Persistence

Stored in `UserDefaults` key `planner.ascentSpeedSettings.v1`. Watch ascent-rate limits remain separate.

## Disclaimer

Reference-only planner estimates. Not certified decompression or gas planning.
