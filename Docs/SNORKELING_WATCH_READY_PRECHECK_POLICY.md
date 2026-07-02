# Snorkeling Watch Ready Pre-check Policy

Compact ready-screen summary (not a long checklist):

| Row | Source |
|-----|--------|
| GPS | `gpsPresentationState` / `gpsQualityBand` |
| Depth sensor | `depthPresentationState` + `sensorHealth` |
| Entry | captured vs auto |
| Route | `SnorkelingWatchImportedRoutePresentation` |
| Buddy | ON/OFF |

Battery shown separately with 20% low threshold (aligned with return advisor default).
