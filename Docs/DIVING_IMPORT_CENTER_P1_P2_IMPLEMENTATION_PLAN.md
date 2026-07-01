# Diving Import Center — P1 + P2 Implementation Plan

**Status:** Implemented  
**Scope:** Diving iOS logbook — file-based import only

---

## Architecture

```
DivingImportCenterView
    ↓
DivingImportCoordinator (commit) / DivingImportParserRegistry (preview)
    ↓
DivingImportFormatDetector
    ↓
DivingCSVImportParser | SubsurfaceXMLImportParser | UDDFImportParser
    ↓
DivingImportDeduplicator.buildPreviewRows
    ↓
DiveSession (normalizedForStorage)
    ↓
DivingImportCommitter → DiveLogStore.add
    ↓
DivingImportCommitReport
```

---

## P1 — CSV consolidation

- Preserve `DiveImportService.importCSV(from:)` API
- `DivingCSVImportParser` wraps legacy import for preview
- Single-session CSV per file (existing behavior)
- Preview with warnings and duplicate badges
- `DivingImportDeduplicator` + `DivingImportCommitter`
- `CSVImportPanel` opens Import Center sheet

## P2 — Subsurface XML + UDDF

- `SubsurfaceXMLImportParser`: `<divelog>/<dives>/<dive>` tolerant parsing
- `UDDFImportParser`: `<uddf>` multi-dive support
- `DivingImportUnitParser` for m/ft, C/F, min/sec
- Missing samples → warning + non-importable unless valid profile

---

## Explicit exclusions (P1/P2)

- Subsurface Cloud sync / login
- Bluetooth / USB dive computer connection
- Bidirectional sync
- Credential / Keychain storage
- Snorkeling / Apnea import paths
- Watch runtime changes
- Decompression algorithm recalculation

---

## Acceptance mapping

| Criterion | Implementation |
|-----------|----------------|
| Import Center entry | Logbook toolbar + `CSVImportPanel` wrapper |
| CSV regression | `DiveImportService.importCSV` + round-trip tests |
| Preview | `DivingImportCenterView` phases |
| Multi-format | CSV, Subsurface XML, UDDF |
| Dedup | Fingerprint + tolerances; default skip |
| Report | Post-import summary screen |
| Tests | 7 test files + CSVMetadataRoundTripTests |
| Docs + QA | This plan + policy docs + QA templates |
