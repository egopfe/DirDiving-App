# Subsurface export

The app exports a CSV file with the following columns:

```csv
time_seconds,depth_m,temperature_c
```

Optional GPS columns when available:

```csv
entry_lat,entry_lon,exit_lat,exit_lon
```

## DIR DIVING metadata (round-trip)

Exports from the iOS companion include a `# session_meta` comment block before profile rows. Re-import restores session ID (when safe), start/end dates, manual flag, pressures, equipment, gas, and notes. See [`../SUBSURFACE_CSV_ROUNDTRIP.md`](../SUBSURFACE_CSV_ROUNDTRIP.md).

Subsurface and other tools ignore `#` lines; compatibility is preserved.

## Workflow

### iOS Companion

1. Open **Logbook**.
2. Select a dive.
3. Open the detail page.
4. Press **Genera CSV Subsurface**.
5. Press **Condividi CSV**.
6. Import the CSV in Subsurface or re-import in DIR DIVING to verify round-trip.

If the session has no samples, the UI shows an export error instead of a share action.

The stable iOS companion also supports CSV import from Logbook for compatible files with `time_seconds`, `depth_m` and `temperature_c` columns. Optional GPS columns are preserved as surface metadata.

### Apple Watch

1. Open the dive log.
2. Either open a dive detail and press **ESPORTA (SUBSURFACE)**, or press **ESPORTA ULTIMA (SUBSURFACE)** from the list.
3. Press **CONDIVIDI CSV** when the file is ready.
4. Transfer the CSV to iPhone, Mac, Files, AirDrop or email, then import it in Subsurface.

Watch export does not include `# session_meta` (iOS companion export does when exporting from iPhone logbook).

The export code is in:

```text
Services/SubsurfaceExportService.swift
```

Import code on iOS lives in:

```text
iOSApp/Services/DiveImportService.swift
```

Tests: `Tests/iOSAlgorithmTests/CSVMetadataRoundTripTests.swift`
