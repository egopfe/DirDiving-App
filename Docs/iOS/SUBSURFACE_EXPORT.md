# Subsurface export

The app exports a CSV file with the following columns:

```csv
time_seconds,depth_m,temperature_c,entry_lat,entry_lon,exit_lat,exit_lon
```

## Workflow

1. Open **Logbook**.
2. Select a dive.
3. Open the detail page.
4. Press **Genera CSV Subsurface**.
5. Press **Condividi CSV**.
6. Import the CSV in Subsurface.

The export code is in:

```text
Services/SubsurfaceExportService.swift
```
