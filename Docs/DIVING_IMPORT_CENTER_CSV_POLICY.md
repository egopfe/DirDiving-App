# Diving Import Center — CSV Policy

**Scope:** DirDiving / Subsurface-style CSV (P1)

---

## Supported format

- Extension: `.csv`, `.txt`
- Header must include `time_seconds` and `depth_m` (DirDiving / Subsurface export convention)
- Single dive per file (existing `DiveImportService` behavior preserved)

## Flow

1. `DivingImportFormatDetector` classifies as `dirDivingCSV` or `subsurfaceCSV`
2. `DivingCSVImportParser.previewImport` calls `DiveImportService.importCSV(from:)`
3. Preview shows one candidate with warnings
4. User selects and commits via `DivingImportCommitter`

## Warnings

- Missing/sparse samples, temperature, GPS
- Invalid rows skipped (count preserved from legacy import)

## Limits

- `IOSAlgorithmConfiguration.maxImportBytes`
- No null bytes; bounded line reads (legacy service)

## Regression

- `DiveImportService.importCSV(from:)` unchanged
- `CSVMetadataRoundTripTests` must pass
- Metadata (site, buddy, gas, SAC, CCR, GPS) preserved per existing round-trip doc

## Safety

- Wording: “Imported log” — not validated/certified/safety-verified
- No decompression recalculation on import
