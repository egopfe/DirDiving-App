# Subsurface export

The app exports a CSV file with the following columns:

```csv
time_seconds,depth_m,temperature_c,entry_lat,entry_lon,exit_lat,exit_lon
```

## Workflow

### iOS Companion

1. Open **Logbook**.
2. Select a dive.
3. Open the detail page.
4. Press **Genera CSV Subsurface**.
5. Press **Condividi CSV**.
6. Import the CSV in Subsurface.

If the session has no samples, the UI shows an export error instead of a share action.

### Apple Watch

1. Open the dive log.
2. Either open a dive detail and press **ESPORTA (SUBSURFACE)**, or press **ESPORTA ULTIMA (SUBSURFACE)** from the list.
3. Press **CONDIVIDI CSV** when the file is ready.
4. Transfer the CSV to iPhone, Mac, Files, AirDrop or email, then import it in Subsurface.

The export code is in:

```text
Services/SubsurfaceExportService.swift
```
