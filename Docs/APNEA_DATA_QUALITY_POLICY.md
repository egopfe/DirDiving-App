# Apnea Data Quality Policy

Session-level quality assessment for logbook and Watch display. **Not a medical or safety certification.**

## Two quality enums

| Enum | Scope | Values |
|------|-------|--------|
| `ApneaDataQuality` | Per depth/time sample | measured, interpolated, estimated, missing, rejected |
| `ApneaDataQualityLevel` | Session summary | good, medium, poor, unavailable |

Session reports use `ApneaSessionQualityReport` in `Shared/Models/ApneaSessionQualityModels.swift`.

## Evaluation

`ApneaDataQualityEvaluator.evaluate(session:heartRateAvailable:)` considers:

- Session completeness (valid holds, warnings)
- Valid hold count
- Recovery tracking completeness (`ApneaRecoveryInterval` per dive)
- Depth availability
- Heart rate availability (when supported)
- Sensor gaps (missing/rejected samples)

`ApneaSensorQualityEvaluator` produces compact Watch labels from `ApneaSensorQuality` (depth, heartRate, spO2).

## Display conventions

**Watch (compact):**

```text
SENSORS OK
DEPTH WEAK
HR —
```

Unavailable HR/SpO₂ are not shown as critical errors.

**iOS logbook:**

```text
Data quality: Good
Depth signal: Good
Recovery tracking: Complete
```

## Fake / DEMO sessions

Demo logbook entries (`demo-apnea-*`) must be labeled DEMO. Do not include in real statistics or export without DEMO badge.

## Policy rules

- Do not invent sensor data
- Do not introduce unsupported health APIs
- Mark incomplete sessions explicitly in statistics
- Personal bests exclude DEMO sessions

## Tests

`Tests/iOSAlgorithmTests/ApneaDataQualityEvaluatorTests.swift` — good/medium/poor/unavailable paths.

## QA

`Docs/QA_EVIDENCE/APNEA_DATA_QUALITY_LOGBOOK/README.md` — **PENDING**.
