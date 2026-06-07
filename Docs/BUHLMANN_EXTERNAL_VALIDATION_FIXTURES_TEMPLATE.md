# Bühlmann external validation fixtures template

**Status:** Template only — **no external sign-off**. Internal XCTest fixtures remain authoritative for CI.

Use this schema when recording comparisons against Subsurface, decotengu, or other reference planners. **Do not set `validationStatus` to `external_reference_validated` without signed campaign evidence.**

## Fixture row schema

| Field | Required | Example |
|-------|----------|---------|
| `fixtureId` | Yes | `ext-val-tmx-45-25-gf3070` |
| `validationStatus` | Yes | `pending_external_validation` |
| `referenceSource` | Yes | `Subsurface 5.0.11 planner export` |
| `referenceSourceVersion` | Yes | `5.0.11` |
| `depthMeters` | Yes | `45` |
| `bottomMinutes` | Yes | `25` |
| `gfLow` / `gfHigh` | Yes | `30` / `70` |
| `gases[]` | Yes | bottom + deco with O₂/He/switch depths |
| `environment.altitudeMeters` | If non-zero | `0` |
| `environment.salinity` | If non-default | `salt` |
| `expectedTTSRangeMinutes.min` | Recommended | `38` |
| `expectedTTSRangeMinutes.max` | Recommended | `52` |
| `toleranceMinutes` | Yes | `3` |
| `observedDirDivingTTS` | After run | `44` |
| `observedExternalTTS` | After run | `46` |
| `observedDirDivingFirstStopMeters` | If deco | `21` |
| `observedExternalFirstStopMeters` | If deco | `21` |
| `passFail` | After review | `pass` / `fail` / `pending` |
| `reviewerSignOff` | External gate | **PENDING** |
| `notes` | Yes | Must state non-certified reference-only |

## Example JSON fragment

```json
{
  "fixtureId": "ext-val-air-30-20-gf3085",
  "validationStatus": "pending_external_validation",
  "referenceSource": "decotengu",
  "referenceSourceVersion": "0.14.1",
  "depthMeters": 30,
  "bottomMinutes": 20,
  "gfLow": 30,
  "gfHigh": 85,
  "gases": [
    { "role": "bottom", "oxygen": 0.21, "helium": 0, "switchDepthMeters": 0 }
  ],
  "environment": { "altitudeMeters": 0, "salinity": "salt" },
  "toleranceMinutes": 3,
  "expectedTTSRangeMinutes": { "min": 0, "max": 0 },
  "observedDirDivingTTS": null,
  "observedExternalTTS": null,
  "passFail": "pending",
  "reviewerSignOff": "PENDING",
  "notes": "Reference comparison only — not certified equivalence."
}
```

## Separation of concerns

| Layer | Purpose |
|-------|---------|
| Internal JSON fixtures + XCTest | Regression on DIR DIVING engine |
| This template | External campaign evidence capture |
| App Store / certification claims | **Prohibited** until legal + external gates complete |

See [`DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_PLAN.md`](DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_PLAN.md).
