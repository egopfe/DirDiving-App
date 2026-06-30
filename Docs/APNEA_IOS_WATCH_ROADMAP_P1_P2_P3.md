# Apnea iOS + Watch — P1 / P2 / P3 Roadmap

**Status:** Implementation in progress on `main`. **Training and logging aid only** — not a medical or safety-critical device. See [`SAFETY_DISCLAIMER.md`](SAFETY_DISCLAIMER.md).

## Architectural split

| Platform | Responsibility |
|----------|----------------|
| **iOS companion** | Profiles, session check, checklist, statistics, logbook, export, training tables, analysis |
| **Apple Watch** | Runtime timer, recovery, haptics, sensor/data quality, session summary, final log |

Apnea does **not** reuse Snorkeling route/GPS runtime. GPS is optional logbook metadata only (`When In Use`).

## Priority tiers

### P1 — Essential

| Feature | Key artifacts |
|---------|---------------|
| Structured Apnea profiles | `Shared/Models/ApneaSessionProfile.swift`, `ApneaProfileKind` |
| Session Check | `ApneaSessionCheckResult.swift`, `ApneaSessionCheckEvaluator.swift`, `IOSApneaSessionCheckView.swift` |
| Watch recovery timer | `ApneaRecoveryTargetCalculator.swift`, `ApneaWatchRuntimeStore.swift` |
| Recovery haptic (once per cycle) | Watch runtime + `WKInterfaceDevice.play(.notification)` |
| Profile-based Watch layout | `ApneaWatchRuntimeLayout`, `ApneaWatchProfileLayoutPresentation.swift` |
| Data quality (base) | `ApneaSessionQualityModels.swift`, `ApneaDataQualityEvaluator.swift` |
| Fake Apnea logbook (isolated) | `FakeApneaLogbookProvider.swift`, `ApneaDemoSessionCatalog.swift` |

**Acceptance without physical QA:** `P1_INTERNAL_READY`, `P1_PHYSICAL_QA_PENDING`.

### P2 — High value

| Feature | Key artifacts |
|---------|---------------|
| Pre-apnea checklist | `ApneaChecklistItem.swift`, `ApneaChecklistCatalog`, `IOSApneaChecklistView.swift` |
| Session statistics & trends | `ApneaStatisticsCalculator.swift` |
| Configurable recovery ratio | `ApneaRecoveryPolicy`, `ApneaRecoveryComputationMode` |
| Watch session summary | `ApneaSessionSummaryMetrics`, Watch presentation |
| Sensor quality indicator | `ApneaSensorQuality`, `ApneaSensorQualityEvaluator` |
| Repetition tracking | Watch runtime + session dive records |

**Acceptance without physical QA:** `P2_INTERNAL_READY`, `P2_PHYSICAL_QA_PENDING`.

### P3 — Advanced

| Feature | Key artifacts |
|---------|---------------|
| Session export (share sheet) | `ApneaExportPayloadBuilder.swift` |
| CO₂ / O₂ training tables | `ApneaTrainingTable.swift`, `ApneaTrainingTableBuilder.swift`, `IOSApneaTrainingTablesView.swift` |
| Recovery analysis | Statistics + logbook views |
| Session comparison / personal best | `ApneaPersonalRecordsEngine.swift` |
| Watch coaching mode (tables) | `ApneaWatchRuntimeLayout.trainingTableCoaching` |

**Acceptance without physical QA:** `P3_INTERNAL_READY`, `P3_PHYSICAL_QA_PENDING`.

## Out of scope

Do not modify or regress: Diving, Gauge, Full Computer, Snorkeling, Bühlmann/GF planner, dive logbook ownership, underwater entitlement, Watch auto-open logic.

## QA evidence

Manual physical QA templates under `Docs/QA_EVIDENCE/APNEA_*` — all default **PENDING**. Simulator runs do not replace in-water testing.

## Related docs

- [`APNEA_IOS_WATCH_ARCHITECTURE.md`](APNEA_IOS_WATCH_ARCHITECTURE.md)
- [`APNEA_RECOVERY_TIMER_POLICY.md`](APNEA_RECOVERY_TIMER_POLICY.md)
- [`APNEA_SESSION_CHECK.md`](APNEA_SESSION_CHECK.md)
- [`APNEA_DATA_QUALITY_POLICY.md`](APNEA_DATA_QUALITY_POLICY.md)
- [`APNEA_TRAINING_TABLES.md`](APNEA_TRAINING_TABLES.md)
- [`APNEA_IOS_WATCH_P1_P2_P3_IMPLEMENTATION_REPORT_CURRENT.md`](APNEA_IOS_WATCH_P1_P2_P3_IMPLEMENTATION_REPORT_CURRENT.md)
- Command spec: `commands_for_cursor/DIR_DIVING_APNEA_IOS_WATCH_P1_P2_P3_CURSOR_COMMAND.md`
