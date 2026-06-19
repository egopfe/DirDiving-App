# Snorkeling release-hard test matrix

Maps automated suites to Command 12 validation areas. Run via `./Scripts/validate_snorkeling_release_readiness.sh --internal`.

| Area | Test suite | Target |
|------|------------|--------|
| Domain models | `SnorkelingDomainModelTests` | Watch |
| GPS ingestion | `SnorkelingSensorGPSIngestionTests` | Watch |
| Lifecycle engine | `SnorkelingLifecycleEngineTests` | Watch |
| Architecture isolation | `SnorkelingArchitectureIsolationTests`, `SnorkelingCrossDomainIsolationTests` | Watch |
| Navigation / return | `SnorkelingNavigationReturnEngineTests` | Watch |
| Alarms / markers / haptics | `SnorkelingAlarmsMarkersHapticsMissionModeTests` | Watch |
| Watch presentation (7 stages) | `SnorkelingWatchPresentationTests` | Watch |
| Watch layout contract | `SnorkelingWatchLayoutContractTests` | Watch |
| Watch UI contract / a11y | `SnorkelingWatchUIViewContractTests` | Watch |
| Mockup matrix | `SnorkelingMockupReferenceMatrixTests` | Watch |
| Persistence / recovery | `SnorkelingPersistenceRecoveryTests` | Watch |
| Logbook store | `SnorkelingLogbookStoreTests` | Watch |
| Localization parity | `SnorkelingLocalizationParityTests` | Watch |
| Release self-check | `SnorkelingReleaseHardValidationTests` | Watch + iOS |
| Session sync crypto | `SnorkelingSessionSyncTransportNegativeTests`, `SnorkelingSessionSyncTransportNegativeWatchTests` | iOS + Watch |
| Pending queue / ACK | `SnorkelingWatchPendingQueueTests`, `SnorkelingRouteAckWatchTests` | Watch |
| Interrupted transfer | `SnorkelingSessionSyncInterruptedTransferTests` | iOS |
| Route ACK round trip | `SnorkelingRouteAckRoundTripTests` | iOS |
| Legacy v1 / duplicate | `SnorkelingLegacyV1TransportTests`, `SnorkelingDuplicateIgnoredImportTests` | iOS |
| iOS companion | `IOSSnorkelingCompanionTests`, `IOSSnorkelingRoutePlannerTests` | iOS |
| Logbook / analytics | `IOSSnorkelingLogbookAnalyticsTests` | iOS |
| Map / export / privacy | `IOSSnorkelingMapEquipmentExportTests`, `IOSSnorkelingExportServiceE2ETests` | iOS |
| Map gap segmentation | `IOSSnorkelingDashboardMapGapTests` | iOS |
| No-GPS presentation | `IOSSnorkelingNoGPSPresentationTests` | iOS |
| EXIF GPS scrub | `SnorkelingPhotoMetadataSanitizationTests` | iOS |
| iOS UI contract | `IOSSnorkelingUIViewContractTests` | iOS |
| Route / session codec | `SnorkelingRouteSyncCodecTests`, `SnorkelingSessionSyncCodecTests` | iOS |

## Physical QA (not automated)

| Folder | Scenario |
|--------|----------|
| `SNORKELING_IOS_WATCH_SYNC` | End-to-end sync |
| `SNORKELING_ROUTE_PUSH` | Route package + ACK |
| `SNORKELING_SESSION_PULL` | Session import + ACK |
| `SNORKELING_WATER_LOCK` | Water Lock during session |
| `SNORKELING_WATCH_UI` | Seven Watch stages vs mockups |
| `SNORKELING_IOS_MAPS` | Real GPS track on device |
| `SNORKELING_VOICEOVER` | Physical VoiceOver |
| `SNORKELING_BATTERY_THERMAL` | Long session thermal |
