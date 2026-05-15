# iOS Companion Mockup Coherence

The `main-iOS` code maps to the supplied premium iOS companion mockup as follows.

## Logbook

Implemented:
- dark technical UI;
- cyan accent;
- search bar;
- compact dive rows with day, month, time, thumbnail, site, max depth, runtime, gas and chevron;
- yellow `BUDDY` badge;
- max depth, runtime and gas label.

Files:
- `Views/LogbookView.swift`
- `Views/Components/DIRSearchBar.swift`
- `Views/Components/DIRCard.swift`

## Dive detail

Implemented:
- header card;
- internal underline tabs: RIEPILOGO / GRAFICI / DETTAGLI;
- metric grid;
- depth chart using Charts;
- GPS block;
- notes block;
- Subsurface CSV export.

File:
- `Views/DiveDetailView.swift`

## Planner

Implemented:
- planner modes: Semplice / Avanzato / Tecnico;
- planned depth/time/temperature with cyan plus/minus steppers;
- bottom gas + deco gas 1 + deco gas 2;
- MOD/PPO2;
- cyan `Calcola Piano` call to action;
- TTR, deco stop count, OTU and CNS;
- dedicated `Piano Immersione` result screen;
- ascent/decompression table;
- Buhlmann ZHL-16C simplified curve.

Files:
- `Views/PlannerView.swift`
- `Models/GasPlan.swift`
- `Models/DivePlan.swift`
- `Services/PlannerService.swift`
- `Services/BuhlmannPlanner.swift`

## Bottom navigation

Implemented:
- Logbook
- Analisi
- Planner
- Attrezzatura
- Altro

File:
- `Views/ContentView.swift`

## Differences from visual mockup

- Real underwater thumbnail photos are represented by generated, photographic-style SwiftUI thumbnails until final media assets are supplied.
- Buhlmann/deco calculations are simplified planning-assistant logic, not a certified decompression engine.
- iCloud backup is represented as prepared/future status.
- CSV export is implemented with depth, temperature, and entry/exit GPS columns when available; `.ssrf` export is not implemented yet.
