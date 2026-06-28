# Master Performance Signpost Catalog (Current)

**Audit command:** 04 — MASTER MAIN CODE / SYNC / SECURITY / PERFORMANCE AUDIT V1.0  
**Branch:** `main` @ `7dfefe2`  
**Registry source:** `Shared/Performance/DIRPerformanceSignpost.swift`  
**Categories:** 24 (`DIRPerformanceSignpostCategory.allCases`)

**Policy:** Signpost names must never include GPS coordinates, dive profiles, gases, notes, or user identifiers.

---

## Required category mapping

| Command category | DIRPerformanceSignpostCategory | Production instrumented | Budget reference |
|------------------|-------------------------------|-------------------------|------------------|
| startup | — (gap) | Partial — Logger only coordinator | BUD-IOS-001/002 |
| planner solve | `iosPlannerCalculation`, `iosCCRPlannerCalculation` | Yes — PlannerBackgroundCalculation, PlannerStore | BUD-IOS-004/005 |
| chart render | `chartSnapshotPreparation` | Yes — PlannerChartSnapshots | BUD-IOS-006 |
| logbook load | `logbookLoad` | Yes — DiveLogStore iOS | BUD-IOS-008 |
| statistics compute | — (gap) | No dedicated signpost | BUD-IOS-010 |
| export | `csvExport`, `pdfGeneration` | Partial | BUD-IOS-011 |
| import | `csvImport` | Partial | BUD-IOS-012 |
| sync decode | `wcEncodeDecode` | Yes — WatchSyncService iOS | BUD-IOS-013 |
| sync persist | `logbookMerge` | Partial | PERF-I-12 |
| cloud backup | `cloudMerge` | Partial — CloudSyncStore | PERF-I-04 |
| map simplification | `snorkelingGPSProcessing` | Yes — SnorkelingSessionMapPresentation | BUD-IOS-015/016 |
| route render | — (gap) | Downsampling only; no render signpost | BUD-IOS-016 |
| settings switch | — (gap) | No signpost | BUD-IOS-003 |
| Watch tissue tick | `watchFullComputerTissueTick` | Yes — DiveManager | PERF-W-03 |
| Watch schedule recompute | `watchFullComputerScheduleGeneration` | Yes — FC engine | PERF-W-01 |
| Watch haptic | — (gap) | No signpost | — |
| Watch image decode | `photoValidationDownsampling` | Partial | PERF-W-17 |
| briefing-card render | — (gap) | iOS render path | — |
| briefing-card transfer | `briefingCardImport` | Partial — Watch receiver | — |
| large payload | `largePayloadTransfer` | Partial | PERF-I-14 |
| FC solver projection | `watchFullComputerSolverProjection` | Yes | PERF-W-01 |
| FC checkpoint | `watchCheckpointEncodeWrite`, `watchCheckpointRestore` | Yes | PERF-W-02 |
| Gauge ingest | `gaugeSampleIngestion` | Partial | PERF-W-08 |
| Apnea tick | `apneaSampleProcessing`, `apneaCheckpoint` | Partial | PERF-W-10/11 |
| Snorkeling tick | `snorkelingRouteCheckpoint` | Partial | PERF-W-12/13 |

---

## Full category list

| Raw name | Enum case | Watch | iOS |
|----------|-----------|-------|-----|
| fc_tissue_tick | watchFullComputerTissueTick | ✓ | — |
| fc_solver_projection | watchFullComputerSolverProjection | ✓ | — |
| fc_schedule_generation | watchFullComputerScheduleGeneration | ✓ | — |
| watch_checkpoint_encode_write | watchCheckpointEncodeWrite | ✓ | — |
| watch_checkpoint_restore | watchCheckpointRestore | ✓ | — |
| gauge_sample_ingest | gaugeSampleIngestion | ✓ | — |
| apnea_sample_process | apneaSampleProcessing | ✓ | — |
| apnea_checkpoint | apneaCheckpoint | ✓ | — |
| snorkeling_gps_process | snorkelingGPSProcessing | ✓ | ✓ |
| snorkeling_route_checkpoint | snorkelingRouteCheckpoint | ✓ | — |
| ios_planner_calc | iosPlannerCalculation | — | ✓ |
| ios_ccr_planner_calc | iosCCRPlannerCalculation | — | ✓ |
| tissue_analytics_gen | tissueAnalyticsGeneration | — | ✓ |
| chart_snapshot_prep | chartSnapshotPreparation | — | ✓ |
| logbook_load | logbookLoad | partial | ✓ |
| logbook_merge | logbookMerge | partial | ✓ |
| csv_import | csvImport | — | partial |
| csv_export | csvExport | — | partial |
| pdf_generation | pdfGeneration | — | partial |
| cloud_merge | cloudMerge | ✓ | ✓ |
| wc_encode_decode | wcEncodeDecode | partial | ✓ |
| large_payload_transfer | largePayloadTransfer | partial | partial |
| briefing_card_import | briefingCardImport | ✓ | partial |
| photo_validation_downsample | photoValidationDownsampling | ✓ | partial |

---

## Gaps (P3 — future instrumentation)

Recommended additions (non-blocking):

- `ios_startup_coordinator_init`
- `ios_settings_mode_switch`
- `ios_map_preview_render`
- `ios_statistics_compute`
- `watch_haptic_burst`

---

## Test evidence

- `PerformanceConcurrencyBatteryRemediationTests.testPerformanceSignpostCatalogComplete` — 24 categories compile
- `PerformanceConcurrencyBatteryRemediationWatchTests` — Watch signpost smoke

---

**Catalog audit completed:** 2026-06-28 @ `7dfefe2`.
