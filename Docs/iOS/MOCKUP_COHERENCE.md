# Mockup coherence checklist

The code maps to the premium iOS mockup as follows:

## Logbook

Implemented:
- dark technical UI;
- cyan accent;
- search bar;
- dive cards;
- max depth, runtime and gas label.

Files:
- `Views/LogbookView.swift`
- `Views/Components/DIRSearchBar.swift`
- `Views/Components/DIRCard.swift`

## Dive detail

Implemented:
- header card;
- internal segmented tabs: Riepilogo / Grafici / Dettagli;
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
- planned depth/time/temperature;
- bottom gas + deco gas 1 + deco gas 2;
- MOD/PPO2;
- TTR, deco stop count, OTU and CNS;
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

- Real underwater thumbnail photos are represented by symbolic gradient cards.
- Buhlmann/deco calculations are simplified planning-assistant logic, not a certified decompression engine.
- iCloud backup is represented as prepared/future status.
- CSV export is implemented; `.ssrf` export is not implemented yet.
