# Apnea Training Tables (CO₂ / O₂)

Structured interval training configured on iOS. **Training aid only — not a medical program.** User must acknowledge disclaimer before use.

## Models

`Shared/Models/ApneaTrainingTable.swift`:

| Type | Role |
|------|------|
| `ApneaTrainingTableKind` | `co2` or `o2` |
| `ApneaTrainingStep` | holdSeconds, recoverySeconds, orderIndex |
| `ApneaTrainingTable` | kind, displayName, repetitions, steps, `disclaimerAcknowledged` |

## Table semantics

| Kind | Hold duration | Recovery |
|------|---------------|----------|
| **CO₂** | Fixed or progressive | Decreasing across steps |
| **O₂** | Increasing across steps | Fixed |

Builder: `ApneaTrainingTableBuilder` (`Shared/Utils/ApneaTrainingTableBuilder.swift`).

## iOS UI

`IOSApneaTrainingTablesView.swift` — create/edit tables, confirm disclaimer, link to session profile.

Rules:

- Disclaimer required (`apnea.disclaimer.training_aid`)
- User confirms profile before Watch session
- Not presented as medical prescription

## Watch coaching (P3)

Layout `ApneaWatchRuntimeLayout.trainingTableCoaching`:

```text
Next: Hold
Hold: 01:30
Recovery: 02:00
Rep: 3/8
```

Haptics: start hold, end hold, recovery target reached, table completed. No voice or complex mid-session navigation.

Watch receives essential steps only via sync/plan package.

## Export & statistics

Training table sessions appear in logbook with profile reference. DEMO sessions excluded from personal bests.

## Tests

`Tests/iOSAlgorithmTests/ApneaTrainingTableBuilderTests.swift` — CO₂ recovery decreases; O₂ hold increases.

## QA

`Docs/QA_EVIDENCE/APNEA_TRAINING_TABLES/README.md` — **PENDING**.
