# DIR Diving — Snorkeling iOS Photos, Gear, Buddy, Export and Privacy (Command 10)

**Date:** 2026-06-18  
**Command:** `10_IOS_SNORKELING_PHOTOS_GEAR_BUDDY_EXPORT_PRIVACY.md`  
**Gate:** `READY_FOR_SNORKELING_COMMAND_11`

## Summary

Command 10 adds complementary iOS Snorkeling companion features without duplicating existing diving infrastructure: session/marker photos with privacy stripping, reusable equipment profiles, buddy/group safety planning, and privacy-gated multi-format export.

## Delivered

### Photos

- `SnorkelingSessionPhotoAttachment` + `SnorkelingSessionPhotoSupport`
- `IOSSnorkelingSessionPhotoStore` — import, thumbnails, deletion; missing files do not break session detail
- `IOSSnorkelingSessionPhotosView` — PhotosPicker, marker association, strip-location toggle
- Session detail photo card with horizontal thumbnails

### Equipment

- `SnorkelingEquipmentCatalog` — mask, snorkel, fins, wetsuit, weights, buoy, action cam categories
- `IOSSnorkelingEquipmentStore` + editor views (reusable profiles, active profile)
- Settings entry from dashboard gear button

### Buddy and group

- `SnorkelingBuddySafetyProfile` — buddy, group members, meeting point, expected return, emergency contact, checklist, pre-session confirmation
- `IOSSnorkelingBuddySafetyStore` + `IOSSnorkelingBuddySafetyView` with shareable plan (no real-time tracking claims)

### Export and privacy

- `SnorkelingExportPrivacyPolicy` — remove / reduced / exact location precision; buddy/emergency redaction
- `SnorkelingSessionExportEngine` — PDF, CSV, JSON, GPX (measured surface only), chart summary
- `IOSSnorkelingSessionExportService` + `IOSSnorkelingSessionExportView` with acknowledgement gates and progress
- Session detail export toolbar

### Shell

- `IOSSnorkelingSettingsView` — equipment + buddy navigation
- Dashboard settings gear; environment objects wired in `DIRDivingiOSApp`

### Localization

- EN/IT keys under `snorkeling.ios.export.*`, `photos.*`, `equipment.*`, `buddy.*`, `settings.*`

### Tests (Command 10 focused)

| Suite | Count | Result |
|-------|------:|--------|
| `IOSSnorkelingMapEquipmentExportTests` | 10 | PASS |
| Prior Commands 08–09 focused suites | 38 | PASS |
| **Total focused** | **48** | **PASS** |

Build: **DIRDiving iOS** — BUILD SUCCEEDED.

## Rules preserved

- No mock export success; cloud backup is preference-only
- GPX uses measured surface track only; location export requires explicit acknowledgement
- No real-time buddy tracking implied
- Reuses `PDFExportFilename`, `PDFPageContext`, `ShareSheetView` — no duplicate PDF infra

## Gate

`READY_FOR_SNORKELING_COMMAND_11`
