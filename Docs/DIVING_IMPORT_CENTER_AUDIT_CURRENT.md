# Diving Import Center — Audit (Current State)

**Date:** 2026-07-01  
**Baseline:** pre-implementation @ `4c27b2c`  
**Scope:** Diving iOS logbook file-based import only

---

## Audit matrix

| Area | Current implementation | Gap | Risk | Fix | Regression protection |
|------|------------------------|-----|------|-----|---------------------|
| CSV import | `CSVImportPanel` → `DiveImportService.importCSV(from:)` → `DiveLogStore.add` | No preview, no dedup UI, single-session only | Low — direct commit | Wrap in `DivingCSVImportParser` + Import Center preview | Keep `DiveImportService.importCSV` unchanged; `CSVMetadataRoundTripTests` |
| Subsurface XML | Export only via `SubsurfaceExportService` | No XML import | Medium — user expectation | `SubsurfaceXMLImportParser` with bounded `XMLParser` | iOS-only; no Watch changes |
| UDDF | None | No UDDF import | Medium | `UDDFImportParser` multi-dive | Validation via `normalizedForStorage` |
| Format detection | Extension/heuristic in import path | No unified detector | Low | `DivingImportFormatDetector` bounded preflight | Unit tests |
| Deduplication | None at import | Duplicate dives possible | Medium | `DivingImportDeduplicator` fingerprint + tolerances | Default skip duplicates |
| Preview / selective import | None | All-or-nothing CSV | Medium | `DivingImportCenterView` + preview rows | UX only; no store change |
| Storage | `DiveLogStore` only | — | — | Commit via `DivingImportCommitter` | No new storage layer |
| Metadata | Session `notes` | No dedicated import fields | Low | `DivingImportNotesBuilder` append-only | No `DiveSession` schema change |
| Snorkeling / Apnea | Separate logbooks | Cross-contamination risk | High if violated | Import Center Diving-only entry | `DivingImportNoRegressionTests` |
| Watch / sync | `WatchSyncService` | Accidental coupling | High | No import files in Watch target | Watch build unchanged |
| Cloud / Bluetooth | N/A | Scope creep | High | Explicitly excluded P1/P2 | Policy docs |
| Safety wording | CSV import disclaimers partial | Safety-critical claims | Medium | Localized disclaimer; no “validated” language | Copy review in l10n |
| Tests | `CSVMetadataRoundTripTests` | No import center tests | Medium | 7 new test files | No-regression suite |
| Localization | Legacy import strings | Import Center keys missing | Low | `diving.import.*` EN/IT | `audit_localization.sh` |

---

## Files inspected

- `iOSApp/Services/DiveImportService.swift`
- `iOSApp/Views/CSVImportPanel.swift`
- `iOSApp/Services/SubsurfaceExportService.swift`
- `iOSApp/Views/LogbookView.swift`
- `Services/DiveLogStore.swift`
- `Models/DiveSession.swift`
- `Models/DiveSample.swift`
- `Models/GPSPoint.swift`
- `Utils/DiveSessionAlgorithmValidator.swift`
- `Utils/DiveProfileMath.swift`
- `Tests/iOSAlgorithmTests/CSVMetadataRoundTripTests.swift`
- `Docs/SUBSURFACE_CSV_ROUNDTRIP.md`
- `project.yml`

---

## Verdict

Pre-implementation audit complete. Gaps addressed in P1/P2 implementation on `main`.
