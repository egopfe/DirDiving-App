# DIR DIVING — Gauge Optional TTV Implementation Report (Command 02)

**Branch:** `main`  
**Date:** 2026-06-16  
**Scope:** Watch MAIN Gauge — optional TTV panel, adaptive top metrics, Settings copy, WC sync. **No TTV formula or lifecycle changes.**

## Summary

Gauge mode now shows an optional TTV index (default **OFF**). When OFF, the TTV view is absent from the tree and the top panel shows **RunTime | Temperature** with non-decompression accessibility. When ON, the existing **TTV | RunTime** split panel is preserved. Full Computer mode does not show Gauge top metrics.

## Files added

| File | Purpose |
|------|---------|
| `Utils/GaugeLivePresentationPolicy.swift` | Presentation-only top-panel policy |
| `Tests/WatchAlgorithmTests/GaugeOptionalTTVTests.swift` | Default, persistence, policy, TTV formula, a11y tests |

## Files modified

| File | Change |
|------|--------|
| `Views/DiveLiveView.swift` | `gaugeTopMetricsPanel`, runtime+temperature panel, policy-driven layout |
| `Views/SettingsView.swift` | `DIVING > GAUGE` section, sync on toggle |
| `Utils/DIRStartupSelectionPolicy.swift` | `applySyncedGaugeShowsTTV` |
| `Utils/WatchSyncKeys.swift` | `gaugeShowTTVKey` |
| `iOSApp/Utils/WatchSyncKeys.swift` | Same key for companion ingest |
| `Services/WatchSyncService.swift` | Publish/ingest gauge TTV preference |
| `iOSApp/Services/WatchSyncService.swift` | Ingest gauge TTV from Watch |
| `Resources/en.lproj/Localizable.strings` | Gauge settings footer + a11y |
| `Resources/it.lproj/Localizable.strings` | Command-mandated IT footer |
| `project.yml` | Test target sources |

## Not changed

- `DiveAlgorithm.ttvIndex` formula
- Dive lifecycle, stopwatch, alarms, Mission Mode
- NDL / ceiling / deco UI (not introduced)

## Tests

`GaugeOptionalTTVTests` — **8** cases covering defaults, persistence, presentation policy, sync apply, TTV formula regression, no TTS in Gauge metric label.
