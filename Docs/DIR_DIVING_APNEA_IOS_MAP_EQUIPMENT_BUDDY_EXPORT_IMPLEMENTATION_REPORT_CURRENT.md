# DIR DIVING — iOS Apnea Map, Equipment, Buddy and Export

**Command:** `10_IOS_APNEA_MAP_EQUIPMENT_BUDDY_EXPORT.md`  
**Date:** 2026-06-17  
**Branch:** `integration/full-computer`  
**Result:** PASS

## Implemented
- Map: surface-only GPS track, start/end times, fix-quality badge, permission-denied state, privacy notice.
- Equipment: categorized reusable profiles (fins, monofin, mask, suit, ballast, buoy, line, lanyard) with active profile selection.
- Buddy & safety: buddy card, emergency contact, checklist, timestamped pre-session confirmation, shareable plan text (no rescue monitoring claim).
- Export: PDF, CSV, JSON, GPX, chart summary share; privacy/redaction gates for GPS and contact data; cloud backup preference without false upload success.

## Architecture
- Shared: `ApneaEquipmentCatalog`, `ApneaBuddySafety`, `ApneaExportFileNaming`, `ApneaExportPrivacyPolicy`, `ApneaSessionExportEngine`, extended `ApneaSessionMapPresentation`.
- iOS stores: `IOSApneaEquipmentStore`, `IOSApneaBuddySafetyStore`.
- iOS service: `IOSApneaSessionExportService` (file generation + share sheet handoff).
- Views under `iOSApp/Views/Apnea/`; settings links for equipment and buddy.

## Tests
- `IOSApneaMapEquipmentExportTests.swift`: filename sanitization, privacy/GPX gates, large CSV/JSON, map permission/fix quality, equipment/buddy stores, PDF lines.

## Localization
Added EN/IT keys for equipment categories, buddy/safety, map privacy/fix states, and export formats/errors.

## Visual references used
- `APNEA_IOS_07_EQUIPMENT`
- `APNEA_IOS_08_BUDDY_SAFETY`
- `APNEA_IOS_09_SESSION_MAP`
- `APNEA_IOS_14_EXPORT_SHARE`

Mockups used as hierarchy references; export success is shown only after file generation completes.
