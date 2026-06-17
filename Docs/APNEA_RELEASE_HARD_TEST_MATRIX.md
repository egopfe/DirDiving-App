# Apnea release-hard test matrix

**Branch:** `integration/full-computer`  
**Automation entry point:** `./Scripts/validate_apnea_release_readiness.sh`

## Engine / lifecycle

| ID | Area | Automated test | Notes |
|----|------|----------------|-------|
| E-01 | Depth feed spike rejection | `ApneaLifecycleEngineTests.testDepthFeedRejectsSpike` | no phantom depth |
| E-02 | Regressive timestamp | `testDepthFeedRejectsRegressiveTimestamp` | monotonic ingest |
| E-03 | Lifecycle manual surface | `testStateMachineManualSurfaceFromDescending` | explicit transitions |
| E-04 | Sensor degraded phase | `testSensorLossMarksDegradedPhase` | 3 s timeout |
| E-05 | Session engine replay | `ApneaTimeRecoveryCheckpointEngineTests` | checkpoint round-trip |
| E-06 | Manual fallback | `testManualFallbackDescentDoesNotResetSessionState` | no silent session reset |
| E-07 | Recovery policies | `testRecoveryPolicyModesComputeExpectedDurations` | 1:1, 2:1, fixed |
| E-08 | Irregular wall clock | `testIrregularDeltaAdvancesSessionAndRecovery` | monotonic clock |

## Alarms / markers / events

| ID | Area | Automated test | Notes |
|----|------|----------------|-------|
| A-01 | Depth alarm trigger | `ApneaOperationalEventEngineTests` | threshold crossing |
| A-02 | Marker / target overlay | `ApneaWatchPresentationTests.testOverlayPassesThroughPresentation` | dismiss-safe |
| A-03 | Alarm count formatting | `testAlarmCountFormatting` | ready screen |

## Presentation / UI contract

| ID | Area | Automated test | Notes |
|----|------|----------------|-------|
| U-01 | Stage mapping | `ApneaWatchPresentationTests` | ready/dive/ascent/recovery/summary |
| U-02 | Sensor gate | `ApneaReleaseHardValidationTests.testSensorDegradedBlocksReadyStart` | start disabled |
| U-03 | Accessibility hooks | `ApneaWatchUIViewContractTests` | Dynamic Type + a11y labels |
| U-04 | EN/IT keys | `ApneaWatchUIViewContractTests`, release-hard l10n tests | buddy, stages, overlays |

## Sync / logbook

| ID | Area | Automated test | Notes |
|----|------|----------------|-------|
| S-01 | Plan codec | `ApneaSyncCodecTests` | encode/decode/checksum |
| S-02 | Watch receiver | `ApneaSyncWatchReceiverTests` | stale revision, session-active guard |
| S-03 | Namespace isolation | `ApneaReleaseHardValidationTests` (iOS + self-check) | separate from dive/FC sync |
| S-04 | Logbook merge | `ApneaLogbookStoreTests`, `ApneaSyncCodecTests.testIOSLogbookAtomicImport` | idempotent import |
| S-05 | iOS companion wiring | `IOSApneaCompanionTests` | stores + navigation |

## Analytics / export

| ID | Area | Automated test | Notes |
|----|------|----------------|-------|
| L-01 | Record eligibility | `IOSApneaLogbookAnalyticsTests` | degraded/simulated excluded |
| L-02 | Dive analytics | `testDiveAnalyticsComputesSpeedsAndMarkers` | speeds, markers, alarms |
| L-03 | Charts / map / export | `IOSApneaMapEquipmentExportTests` | GPX, CSV, equipment |

## Performance

| ID | Area | Budget | Test |
|----|------|--------|------|
| P-01 | Checkpoint codec | ≤ 50 ms | `ApneaReleaseHardValidationTests.testCheckpointRoundTripWithinBudget` |

## Visual / mockup (23 APNEA PNGs)

| ID | Mockup files | Surface |
|----|--------------|---------|
| V-01 … V-08 | `APNEA_WATCH_01` … `08` | `ApneaMockupReferenceMatrix` + `ApneaWatchPresentation` stages |
| V-09 … V-23 | `APNEA_IOS_01` … `15` | iOS `IOSApnea*` views (view-level; no raster embedded) |

Executable Watch presentation fixtures: 5 lifecycle stages indexed in `ApneaMockupReferenceMatrix.presentationStagesReferencedByWatchMockups()`.

## Manual / physical (not automated)

| ID | Area | Matrix |
|----|------|--------|
| X-01 | Watch Ultra depth + Water Lock | [`WATCH_ULTRA_PHYSICAL_QA_MATRIX.md`](WATCH_ULTRA_PHYSICAL_QA_MATRIX.md) |
| X-02 | Watch ↔ iOS Apnea sync | [`WATCH_IOS_SYNC_QA_MATRIX.md`](WATCH_IOS_SYNC_QA_MATRIX.md) |
| X-03 | VoiceOver / Dynamic Type (EN/IT) | [`IOS_DYNAMIC_TYPE_VOICEOVER_QA_MATRIX.md`](IOS_DYNAMIC_TYPE_VOICEOVER_QA_MATRIX.md) |
| X-04 | Glove / wet interaction | Manual on-device |
| X-05 | Screenshot regression (41/45/49 mm, iPhone sizes) | [`ReferenceUI/README.md`](ReferenceUI/README.md) |
