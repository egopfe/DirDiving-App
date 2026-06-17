# DIR DIVING — Localization Glossary (IT / EN)

**Date:** 2026-06-02  
**Branch:** `integration/full-computer`  
**Policy:** Technical diving terminology stays precise. Acronyms listed below remain **untranslated** in both locales unless a screen explicitly expands them.

---

## Core diving metrics

| Concept | Italian (UI) | English (UI) | Notes |
|---------|--------------|--------------|-------|
| Current depth | Profondità attuale | Current depth | Use `live.*` / logbook formatters |
| Maximum depth | Profondità massima | Maximum depth | |
| Average depth | Profondità media | Average depth | |
| Runtime | Runtime / Tempo immersione | Runtime | Short metric labels may keep **Runtime** |
| TTV | TTV | TTV | Gauge-only index; never confused with TTS |
| NDL | NDL | NDL | Expanded footer: Limite di non decompressione / No decompression limit |
| TTS | TTS | TTS | Expanded footer: Tempo alla superficie / Time to surface |
| Ceiling | Ceiling | Ceiling | Operational ascent ceiling |
| Decompression stop | Tappa di decompressione | Decompression stop | |
| Decompression in progress | Decompressione in corso | Decompression in progress | |
| Decompression complete | Decompressione completata | Decompression complete | |

## Full Computer / gas

| Concept | Italian | English |
|---------|---------|---------|
| Active gas | Gas attivo | Active gas |
| Suggested gas | Gas suggerito | Suggested gas |
| Gas switch | Cambio gas | Gas switch |
| Bottom gas | Gas di fondo | Bottom gas |
| Decompression gas | Gas decompressivo | Decompression gas |
| Gas unavailable | Gas non disponibile | Gas not available |
| Gas lost | Gas perso | Gas lost |
| Hold depth | Mantieni la profondità | Maintain depth |
| Ascend to stop | Risali a %@ | Ascend to %@ |
| Descend to stop | Scendi a %@ | Descend to %@ |

## Navigation / GPS

| Concept | Italian | English |
|---------|---------|---------|
| Waypoint | Waypoint | Waypoint |
| Return to entry | Ritorno all'ingresso | Return to entry |
| Turn left | Gira a sinistra | Turn left |
| Turn right | Gira a sinistra | Turn right |
| On line | In rotta | On line |
| GPS degraded | GPS degradato | GPS degraded |
| GPS unavailable | GPS non disponibile | GPS unavailable |

## Sync / recovery

| Concept | Italian | English |
|---------|---------|---------|
| Recovery | Recupero | Recovery |
| Session recovered | Sessione recuperata | Session recovered |
| Sync pending | Sincronizzazione in attesa | Sync pending |
| Sync failed | Sincronizzazione non riuscita | Sync failed |

## Intentionally untranslated acronyms

`NDL`, `TTS`, `TTV`, `GF`, `PPO2`, `MOD`, `CNS`, `OTU`, `EAN`, `GPS`, `CSV`, `JSON`, `GPX`, `PDF`, `ZH-L16C`, `CCR`, `FO2`, `FHe`, `FN2`

## Product names (never localized)

`DIR DIVING`, `BUSSOLA` (never **COMPASSO**), `FULL COMPUTER`, `GAUGE`

## Units

- Depth: `m` / locale formatters via `Formatters.depth`
- Duration: `min`, `s` — use localized format strings (`live.unit.min`, `fc.imported_plan.runtime_minutes_format`)
- Temperature: `°C` / `°F` via unit preference stores
- Pressure: `bar` / `psi` via planner settings

## Export language policy

Exported PDFs and briefings use the **active app locale** at export time (`DIRIOSLocalizer` / `String(localized:)`). Machine-readable JSON field names remain stable English identifiers.
