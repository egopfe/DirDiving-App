# iOS Performance Signpost Catalog — Current

**Branch:** `main`  
**Registry source:** `Shared/Performance/DIRPerformanceSignpost.swift`  
**Categories:** 24

| Category | iOS-relevant | Instrumented in iOS production | Budget in `DIRPerformanceBudgets` | Notes |
|----------|--------------|--------------------------------|-----------------------------------|-------|
| `ios_planner_calc` | Yes | Yes — `PlannerStore.applyInputToPlanningOutputs` | `iosPlannerOCCalculation` | Primary OC planner path |
| `ios_ccr_planner_calc` | Yes | Yes — `PlannerStore.scheduleCCRPlanningUpdate` | `iosPlannerCCRCalculation` | CCR planner path |
| `tissue_analytics_gen` | Yes | **No** — category defined, no `begin()` call site | `tissueAnalyticsGeneration` | Gap: computed in `PlannerView.body` without signpost |
| `chart_snapshot_prep` | Yes | Yes — `PlannerChartSnapshots.make` | — | Downsamples to 2048 pts |
| `logbook_load` | Yes | Partial — Logger only in stores | `logbookLoad` | No signpost on iOS load path |
| `logbook_merge` | Yes | Partial | `logbookMerge` | Merge paths use Logger |
| `csv_import` | Yes | Partial | `csvImport` | Import bounds enforced in code |
| `csv_export` | Yes | No signpost | `csvExport` | Synchronous export |
| `pdf_generation` | Yes | No signpost | `pdfStructureGeneration` | Planner/equipment PDF |
| `cloud_merge` | Yes | Partial — `CloudSyncStore` Logger | `cloudMerge` | KVS sync |
| `wc_encode_decode` | Yes | Partial | `wcEncodeDecode` | Watch sync codec |
| `large_payload_transfer` | Yes | Partial | `largePayloadHashValidation` | 512 KB cap |
| `photo_validation_downsample` | Yes | Unknown / sparse | `photoValidationDownsampling` | Snorkeling photos |
| `briefing_card_import` | Yes | No signpost | — | Planner briefing transfer |
| `snorkeling_gps_process` | No (Watch-primary) | — | — | Watch runtime |
| `snorkeling_route_checkpoint` | No (Watch-primary) | — | — | Watch runtime |

## Missing signpost categories (recommended for remediation)

| Proposed category | Area |
|-------------------|------|
| `ios_startup_coordinator_init` | Coordinator + store graph |
| `ios_settings_mode_switch` | Settings scope change |
| `ios_map_preview_render` | Snorkeling dashboard/detail map |
| `ios_statistics_compute` | Apnea/Snorkeling statistics |
| `ios_export_session` | PDF/CSV/GPX export |
| `ios_sync_flush` | WatchConnectivity outbound flush |
| `ios_cloud_kvs_sync` | iCloud KVS synchronize |
