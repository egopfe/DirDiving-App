# Apnea iOS + Watch Architecture (P1/P2/P3)

**Disclaimer:** Training and logging aid only. Recovery alerts are reminders — they do not authorize a new breath-hold.

## Functional flow

```text
iOS configures ApneaSessionProfile
  → iOS runs Apnea Session Check (+ optional checklist)
  → iOS syncs plan/profile to Watch (ApneaSyncCodec)
  → Watch runs session (ApneaWatchRuntimeStore, ApneaSessionEngine)
  → Watch tracks hold, recovery, reps, sensors
  → Watch produces final log → sync to iOS
  → iOS logbook, data quality, statistics, export
```

## Layer map

| Layer | Location | Role |
|-------|----------|------|
| Session profiles | `Shared/Models/ApneaSessionProfile.swift` | Kind, targets, recovery policy, Watch layout |
| Session configuration | `Shared/Models/ApneaSessionConfiguration.swift` | Active profile + runtime flags |
| Recovery policy | `Shared/Models/ApneaRecoveryPolicy.swift` | Fixed, ratio 1:1/2:1, custom ratio |
| Session check | `Shared/Models/ApneaSessionCheckResult.swift`, `Shared/Utils/ApneaSessionCheckEvaluator.swift` | Ready / warning / incomplete / blocked |
| Checklist | `Shared/Models/ApneaChecklistItem.swift` | Pre-session items (non-blocking) |
| Data quality | `Shared/Models/ApneaSessionQualityModels.swift`, `Shared/Utils/ApneaDataQualityEvaluator.swift` | Session-level good/medium/poor/unavailable |
| Training tables | `Shared/Models/ApneaTrainingTable.swift`, `Shared/Utils/ApneaTrainingTableBuilder.swift` | CO₂/O₂ step sequences |
| Pure calculators | `ApneaRecoveryTargetCalculator`, `ApneaStatisticsCalculator`, `ApneaExportPayloadBuilder` | Testable logic outside SwiftUI |
| Watch runtime | `Services/ApneaWatchRuntimeStore.swift` | Hold/recovery cycle, haptic latch, layout |
| Watch presentation | `Utils/ApneaWatchPresentation.swift`, `Shared/Utils/ApneaWatchProfileLayoutPresentation.swift` | Stage + profile layout strings |
| iOS UI | `iOSApp/Views/Apnea/` | Settings, session check, checklist, training tables |
| iOS demo logbook | `iOSApp/Services/FakeApneaLogbookProvider.swift` | Isolated DEMO sessions (`demo-apnea-` prefix) |
| Watch logbook | `Services/ApneaLogbookStore.swift` | Local persistence + outbound sync |
| Sync | `Shared/Utils/ApneaSyncCodec.swift` | Plan iOS→Watch; session Watch→iOS |

## iOS vs Watch boundaries

**iOS only:** profile CRUD, session check UI, checklist, statistics dashboards, export share sheet, training table editor, fake logbook toggle, recovery policy settings.

**Watch only:** live hold timer, automatic recovery start at hold end, recovery target countdown, one-shot haptic at target, compact sensor strip, rep counter, session summary screen, coaching steps for training tables.

**Shared:** models, evaluators, sync codecs. No Snorkeling route planner or map runtime in Apnea.

## Profile → Watch layout

`ApneaWatchRuntimeLayout` maps profile kind to compact screens:

| Layout | Profiles | Primary fields |
|--------|----------|----------------|
| `staticHoldRecovery` | Static, Recovery session | HOLD, RECOVERY elapsed/target, REP n/m |
| `dynamicHoldReps` | Dynamic, Training intervals | HOLD, REP, RECOVERY |
| `depthMetrics` | Depth / Constant weight | DEPTH, MAX, TIME, RECOVERY |
| `freeTrainingCompact` | Free training | HOLD, RECOVERY, SENSORS |
| `trainingTableCoaching` | CO₂/O₂ tables (P3) | Next step, hold, recovery, rep |

Use multiple Watch pages when needed; avoid overcrowding a single screen.

## Recovery cycle (Watch)

```text
Hold started → Hold ended → Recovery timer auto-starts
  → Target from ApneaRecoveryTargetCalculator + profile policy
  → Haptic once when target reached (latched per cycle)
  → Latch resets on next hold
```

Wording: **Recovery target reached** / **Recupero target raggiunto**. Never "safe to dive" or "ready to hold".

## Fake logbook isolation

- Default OFF; separate from real `ApneaLogbookStore`
- DEMO badge required; ID prefix `demo-apnea-`
- Excluded from real statistics and Watch sync

## Tests

| Suite | Examples |
|-------|----------|
| `Tests/iOSAlgorithmTests/` | Profile, recovery calculator, session check, data quality, statistics, export, training tables |
| `Tests/WatchAlgorithmTests/` | Recovery runtime, haptic latch, layout contract, sensor quality, session summary |

## Physical QA

All `Docs/QA_EVIDENCE/APNEA_*` templates default **PENDING**. See implementation report for current verdict.
