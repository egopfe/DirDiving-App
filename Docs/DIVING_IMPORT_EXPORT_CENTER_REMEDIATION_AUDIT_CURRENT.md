# Diving Import / Export Center — Remediation Audit

**Date:** 2026-07-01  
**Baseline:** `b7163a3` (import-only center)

---

## Issue confirmed

P1/P2 Import Center shipped **import only**. Export remained CSV-only in `DiveDetailView`. Logbook toolbar showed "Import Center" with no export path.

| Area | Before remediation | Gap |
|------|-------------------|-----|
| Import CSV | ✅ Import Center | — |
| Import XML/UDDF | ✅ Import Center | — |
| Export CSV | ✅ DiveDetail only | Not in Center |
| Export XML | ❌ | Missing |
| Export UDDF | ❌ | Missing |
| Logbook entry | "Import Center" only | Misleading label |

---

## UI locations (pre-remediation)

- **Import:** Logbook toolbar, `CSVImportPanel`, `DivingImportCenterView`
- **Export CSV:** `DiveDetailView.exportBlock` → `SubsurfaceExportService.writeCSV`

---

## Remediation plan

1. `DivingImportExportCenterView` with Import \| Export tabs
2. `DivingSubsurfaceXMLExportService` + `DivingUDDFExportService`
3. `DivingExportCoordinator` routing CSV/XML/UDDF
4. `DiveDetailView` format picker (CSV/XML/UDDF)
5. Logbook label → "Import / Export Center"

---

## Regression risks

| Risk | Mitigation |
|------|------------|
| CSV export break | Keep `SubsurfaceExportService` unchanged; regression tests |
| CSV import break | Import tab unchanged; no-regression tests |
| Watch/sync | No Watch files modified |
| Cross-activity | Diving-only; demo dives excluded from export |

---

## Files modified

See [`DIVING_IMPORT_EXPORT_CENTER_IMPLEMENTATION_REPORT_CURRENT.md`](DIVING_IMPORT_EXPORT_CENTER_IMPLEMENTATION_REPORT_CURRENT.md).
