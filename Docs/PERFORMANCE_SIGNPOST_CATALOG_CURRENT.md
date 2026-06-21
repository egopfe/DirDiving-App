# DIR DIVING — Performance Signpost Catalog (Current)

**Subsystem:** `com.egopfe.dirdiving`  
**Category:** `Performance`  
**Implementation:** `Shared/Performance/DIRPerformanceSignpost.swift`

All signpost names are static, non-sensitive identifiers. No GPS coordinates, dive profiles, gases, notes, or user identifiers appear in signpost names or metadata.

| Category enum | Signpost name | Instrumented paths |
|---------------|---------------|-------------------|
| `watchFullComputerTissueTick` | `fc_tissue_tick` | `DiveManager.tickFullComputerRuntimeIfNeeded` |
| `watchFullComputerSolverProjection` | `fc_solver_projection` | Reserved for solver projection intervals |
| `watchFullComputerScheduleGeneration` | `fc_schedule_generation` | Reserved for schedule generation |
| `watchCheckpointEncodeWrite` | `watch_checkpoint_encode_write` | Reserved for generic checkpoint encode/write |
| `watchCheckpointRestore` | `watch_checkpoint_restore` | Reserved for checkpoint restore |
| `gaugeSampleIngestion` | `gauge_sample_ingest` | Reserved for gauge depth ingestion |
| `apneaSampleProcessing` | `apnea_sample_process` | Reserved for Apnea sample processing |
| `apneaCheckpoint` | `apnea_checkpoint` | Reserved for Apnea checkpoint |
| `snorkelingGPSProcessing` | `snorkeling_gps_process` | Reserved for Snorkeling GPS processing |
| `snorkelingRouteCheckpoint` | `snorkeling_route_checkpoint` | `SnorkelingWatchRuntimeStore.persistCheckpoint` |
| `iosPlannerCalculation` | `ios_planner_calc` | `PlannerStore.applyInputToPlanningOutputs` |
| `iosCCRPlannerCalculation` | `ios_ccr_planner_calc` | `PlannerStore.refreshCCRPlan` |
| `tissueAnalyticsGeneration` | `tissue_analytics_gen` | Reserved for tissue analytics |
| `chartSnapshotPreparation` | `chart_snapshot_prep` | `PlannerChartSnapshots.make` |
| `logbookLoad` | `logbook_load` | Reserved for logbook load |
| `logbookMerge` | `logbook_merge` | Reserved for logbook merge |
| `csvImport` | `csv_import` | Reserved for CSV import |
| `csvExport` | `csv_export` | Reserved for CSV export |
| `pdfGeneration` | `pdf_generation` | Reserved for PDF generation |
| `cloudMerge` | `cloud_merge` | Reserved for cloud merge |
| `wcEncodeDecode` | `wc_encode_decode` | Reserved for WC encode/decode |
| `largePayloadTransfer` | `large_payload_transfer` | Reserved for large payload transfer |
| `briefingCardImport` | `briefing_card_import` | Reserved for briefing-card import |
| `photoValidationDownsampling` | `photo_validation_downsample` | Reserved for photo validation |

## Coverage guard

`PerformanceConcurrencyBatteryRemediationTests.testSignpostCatalogCoversRequiredCategories` and the Watch counterpart verify all 24 categories begin/end intervals without failure.

## Field diagnostics

Use Instruments → os_signpost or Logging with subsystem filter `com.egopfe.dirdiving` and category `Performance` on physical hardware. Simulator signposts validate compile-time coverage only; they are not physical battery or thermal evidence.
