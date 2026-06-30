# Apnea iOS + Watch P1/P2/P3 — Implementation Report (Current)

**Branch:** `main`  
**Baseline commit:** `8871f98` (update at release)  
**Scope:** Apnea companion (iOS), Apnea Watch runtime, shared models — per `commands_for_cursor/DIR_DIVING_APNEA_IOS_WATCH_P1_P2_P3_CURSOR_COMMAND.md`

**Disclaimer:** Training and logging aid only. Not medical. Not safety-critical.

---

## Implementation scope

| Tier | Status | Notes |
|------|--------|-------|
| P1 | In progress / internal ready | Profiles, session check, recovery timer, haptic, layout, data quality, fake logbook |
| P2 | In progress | Checklist, statistics, recovery ratio, Watch summary, sensor quality, reps |
| P3 | In progress | Export, training tables, recovery analysis, personal best, coaching layout |

---

## Shared models added/updated

| File | Purpose |
|------|---------|
| `Shared/Models/ApneaSessionProfile.swift` | `ApneaProfileKind`, `ApneaWatchRuntimeLayout`, profile struct |
| `Shared/Models/ApneaSessionConfiguration.swift` | Active session configuration |
| `Shared/Models/ApneaSessionCheckResult.swift` | Check status + issues |
| `Shared/Models/ApneaChecklistItem.swift` | Pre-apnea checklist catalog |
| `Shared/Models/ApneaSessionQualityModels.swift` | `ApneaDataQualityLevel`, sensor quality, summary metrics |
| `Shared/Models/ApneaTrainingTable.swift` | CO₂/O₂ tables and steps |
| `Shared/Models/ApneaDemoSessionCatalog.swift` | Demo session fixtures |
| `Shared/Models/ApneaCompanionProfile.swift` | Companion profile extensions |

Existing: `ApneaRecoveryPolicy.swift`, `ApneaDataQuality.swift` (per-sample).

## Shared utils added/updated

| File | Purpose |
|------|---------|
| `ApneaSessionCheckEvaluator.swift` | Pre-session check logic |
| `ApneaRecoveryTargetCalculator.swift` | Recovery target/remaining/reached |
| `ApneaDataQualityEvaluator.swift` | Session quality report |
| `ApneaStatisticsCalculator.swift` | Holds, recovery, trends |
| `ApneaTrainingTableBuilder.swift` | CO₂/O₂ step generation |
| `ApneaExportPayloadBuilder.swift` | Share-sheet text payload |
| `ApneaWatchProfileLayoutPresentation.swift` | Profile-specific Watch strings |

---

## P1 file changes

**iOS:** `IOSApneaProfilesView.swift`, `IOSApneaSessionCheckView.swift`, `IOSApneaSettingsContent.swift`, `FakeApneaLogbookProvider.swift`

**Watch:** `Services/ApneaWatchRuntimeStore.swift`, `Utils/ApneaWatchPresentation.swift`

**Tests:** `ApneaWatchRuntimeStoreTests`, `ApneaRecoveryPolicyLifecycleTests`, `ApneaWatchLayoutContractTests`, `ApneaWatchPresentationTests`, `ApneaReleaseHardValidationTests`, `FakeApneaLogbookProviderTests`

---

## P2 file changes

**iOS:** `IOSApneaChecklistView.swift`, statistics in dashboard/logbook views, recovery policy in settings

**Watch:** Runtime rep tracking, `ApneaSessionSummaryMetrics`, sensor strip in presentation

**Tests:** Extended Watch runtime and presentation tests

---

## P3 file changes

**iOS:** `IOSApneaTrainingTablesView.swift`, `IOSApneaSessionExportView.swift`, recovery analysis in session detail

**Watch:** `trainingTableCoaching` layout path

**Tests:** Training table builder, export payload (when added)

---

## Fake logbook separation

- Provider: `iOSApp/Services/FakeApneaLogbookProvider.swift`
- Toggle: Apnea settings (default OFF)
- ID prefix: `demo-apnea-`
- Not synced to Watch; excluded from real statistics
- QA: `Docs/QA_EVIDENCE/IOS_APNEA_FAKE_LOGBOOK_*` (existing)

---

## Tests

**Watch:** `Tests/WatchAlgorithmTests/Apnea*.swift` — recovery lifecycle, layout contract, runtime store, presentation

**iOS:** `Tests/iOSAlgorithmTests/FakeApneaLogbookProviderTests.swift`, `IOSApneaCompanionTests.swift`, sync/logbook tests

**Execution:** Run before release:

```bash
xcodegen generate
xcodebuild -scheme "DIRDiving Watch Algorithm Tests" -destination 'platform=watchOS Simulator,name=Apple Watch Series 11 (46mm)' test
xcodebuild -scheme "DIRDiving iOS Algorithm Tests" -destination 'platform=iOS Simulator,name=iPhone 15' test
```

---

## Build / localization

- Regenerate project: `xcodegen generate`
- Localization keys under `apnea.*` in EN/IT strings (profiles, session check, recovery, checklist, data quality, export, training)
- Audit: `./Scripts/audit_localization.sh` when available

---

## Documentation created

| Doc | Path |
|-----|------|
| Roadmap | `Docs/APNEA_IOS_WATCH_ROADMAP_P1_P2_P3.md` |
| Architecture | `Docs/APNEA_IOS_WATCH_ARCHITECTURE.md` |
| Recovery policy | `Docs/APNEA_RECOVERY_TIMER_POLICY.md` |
| Session check | `Docs/APNEA_SESSION_CHECK.md` |
| Data quality | `Docs/APNEA_DATA_QUALITY_POLICY.md` |
| Training tables | `Docs/APNEA_TRAINING_TABLES.md` |
| This report | `Docs/APNEA_IOS_WATCH_P1_P2_P3_IMPLEMENTATION_REPORT_CURRENT.md` |

## QA templates created

All under `Docs/QA_EVIDENCE/APNEA_*/README.md` — default **PENDING**.

---

## Known limitations

- Physical in-water QA not yet executed
- HR/SpO₂ shown only when platform provides data; unavailable is not an error
- Training tables and coaching mode require solid P1/P2 Watch runtime
- GPS optional for logbook metadata only; no Apnea route navigation
- Recovery haptic is a reminder, not authorization to breath-hold

---

## Physical QA status

**PENDING** — no PASS recorded without device evidence.

---

## Final verdict (without physical QA)

```text
INTERNAL_READY
PHYSICAL_QA_PENDING
APNEA_IOS_WATCH_P1_READY (internal)
APNEA_IOS_WATCH_P2_READY (internal)
APNEA_IOS_WATCH_P3_READY (internal)
NO_CROSS_ACTIVITY_REGRESSION (verify via QA template)
NO_LOCATION_POLICY_REGRESSION
NO_FAKE_DATA_CONTAMINATION
NO_SAFETY_CRITICAL_CLAIMS
NO_MEDICAL_DEVICE_CLAIMS
```

Maximum achievable verdict until physical QA completes: **INTERNAL_READY / PHYSICAL_QA_PENDING**.
