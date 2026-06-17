# Full Computer release-hard test matrix

**Branch:** `main`  
**Automation entry point:** `./Scripts/validate_full_computer_release_readiness.sh`

## Mathematical / algorithm

| ID | Area | Automated test | Tolerance / budget |
|----|------|----------------|-------------------|
| M-01 | Air TTS differential | `FullComputerReleaseHardValidationTests.testDifferentialAirPlannerMatchesRuntimeTTS` | ±3 min (`FullComputerReleaseHardTolerances.plannerRuntimeTTSMinutes`) |
| M-02 | EAN32 TTS differential | `testDifferentialEAN32PlannerMatchesRuntimeTTS` | ±3 min |
| M-03 | Trimix + deco gases TTS | `testDifferentialTrimixPlannerMatchesRuntimeTTS` | ±3 min |
| M-04 | Repetitive tissues | `testRepetitiveInitialTissuesAlignWithPlannerProjection` | ±3 min TTS |
| M-05 | Multilevel profile | `testMultilevelProfileProducesFiniteDecoMetrics` | finite NDL/TTS |
| M-06 | Replay vs continuous | `FullComputerRuntimeEngineTests.testRecoveryReplayMatchesContinuousIngest` | 0.0001 bar tissue |
| M-07 | NDL accents | `FullComputerUIStateMatrixTests.testNDLAccentThresholdsMatchCommandEleven` | exact |
| M-08 | Stop state machine | `FullComputerDecoStopStateMachineTests` | exact keys |
| M-09 | Gas switch policy | `FullComputerGasSwitchPolicyTests` | policy rules |
| M-10 | NaN / Inf / negative depth | `FullComputerReleaseHardValidationTests` numerical tests | reject, no tissue reset |
| M-11 | Irregular delta | `FullComputerRuntimeEngineTests.testIrregularDeltaUsesRealElapsedTime` | degraded, not reset |
| M-12 | iOS golden fixtures | `BuhlmannGoldenFixtureTests`, `PlannerRegressionFixtureTests` | fixture-defined |

## Integration

| ID | Area | Automated test | Notes |
|----|------|----------------|-------|
| I-01 | FC runtime lifecycle | `DiveManagerAlgorithmIntegrationTests.testFullComputerRuntimeStartsOnManualDive` | sim depth |
| I-02 | Gauge isolation | `testGaugeModeDoesNotStartFullComputerRuntime` | |
| I-03 | Checkpoint round-trip | `FullComputerRecoveryCheckpointTests` | checksum + tissues |
| I-04 | Draft schema upgrade | `testLegacyDraftWithoutCheckpointStillDecodes` | v4 → v5 |
| I-05 | Logbook metadata merge | `testWatchMergePreservesFullComputerLogbookMetadata` | |
| I-06 | Predive sensor gate | `FullComputerUIStateMatrixTests.testPrediveReadinessBlocksUnavailableSensor` | |
| I-07 | No silent Gauge fallback | `testDiveManagerNeverAssignsGaugeDuringFullComputerSession` + `testFullComputerSessionKeepsModeWhenDepthValidationFails` | static + runtime |
| I-08 | Invalid plan blocked | `testInvalidPlanCannotStartRuntimeEngine` | |

## Performance

| ID | Area | Budget | Test |
|----|------|--------|------|
| P-01 | Deco solver | ≤ 50 ms | `testDecoSolverRespectsPerformanceBudget` |
| P-02 | Checkpoint codec | ≤ 50 ms | `testCheckpointRoundTripWithinBudget` |
| P-03 | Runtime tick projection | XCTest `measure` | `testProjectionPerformanceBudget` |

## Visual / mockup (25 FC_UI PNGs)

| ID | Mockup file | Fixture / surface |
|----|-------------|-------------------|
| V-01 … V-25 | `FC_UI_01` … `FC_UI_25` | `FullComputerMockupReferenceMatrix` |

Executable live-deco fixtures: 20-state matrix in `FullComputerLivePanelFixtures`. Settings / iOS transfer surfaces are view-level (no raster embedded).

## Manual / physical (not automated)

| ID | Area | Matrix |
|----|------|--------|
| X-01 | Watch Ultra depth sensor | [`WATCH_ULTRA_PHYSICAL_QA_MATRIX.md`](WATCH_ULTRA_PHYSICAL_QA_MATRIX.md) |
| X-02 | Watch ↔ iOS sync | [`WATCH_IOS_SYNC_QA_MATRIX.md`](WATCH_IOS_SYNC_QA_MATRIX.md) |
| X-03 | iCloud two-device | [`ICLOUD_TWO_DEVICE_QA_MATRIX.md`](ICLOUD_TWO_DEVICE_QA_MATRIX.md) |
| X-04 | VoiceOver / Dynamic Type | [`IOS_DYNAMIC_TYPE_VOICEOVER_QA_MATRIX.md`](IOS_DYNAMIC_TYPE_VOICEOVER_QA_MATRIX.md) |
| X-05 | Screenshot regression (41/45/49 mm, EN/IT) | [`ReferenceUI/README.md`](ReferenceUI/README.md) |
| X-06 | External Bühlmann validation | [`PLANNER_GOLDEN_VALIDATION_QA_MATRIX.md`](PLANNER_GOLDEN_VALIDATION_QA_MATRIX.md) |

**Certification:** None of the above constitutes CE / EN13319 / ISO 6425 certification.
