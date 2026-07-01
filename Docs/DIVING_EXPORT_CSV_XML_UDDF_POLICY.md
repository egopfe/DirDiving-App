# Diving Export — CSV / XML / UDDF Policy

**Scope:** Diving iOS file-based export

---

## CSV

- **Service:** `SubsurfaceExportService.makeCSV` / `writeCSV` (unchanged semantics)
- **Single session only** in Export Center (multi → error)
- Metadata, GPS privacy, CCR keys preserved per existing round-trip policy

## Subsurface XML

- **Service:** `DivingSubsurfaceXMLExportService`
- Single and multi-session
- `<divelog program="DirDiving"><dives><dive>…<divecomputer><sample/>`

## UDDF

- **Service:** `DivingUDDFExportService`
- Version 3.2.0 root; `profiledata/repetitiongroup/dive/samples/waypoint`

## Coordinator

- `DivingExportCoordinator.export(sessions:format:)` — read-only; no `DiveLogStore` mutation

## Safety wording

- "Exported logs are for interoperability… not a safety or decompression validation"

## Privacy

- `DivingExportPrivacyOptions` applied to CSV and XML GPS fields
