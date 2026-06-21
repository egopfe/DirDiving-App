# DIR DIVING — Terminology Glossary (IT / EN)

**Command:** 11 — Localization & Accessibility Audit  
**Date:** 2026-06-20  
**Branch:** `main`  
**Policy:** Technical diving terminology stays precise. Product names and listed acronyms remain **untranslated** unless a screen explicitly expands them.

---

## Core diving metrics (Diving / Full Computer / Gauge)

| Concept | Italian (UI) | English (UI) | Activity | Notes |
|---------|--------------|--------------|----------|-------|
| Current depth | Profondità attuale | Current depth | Diving | `live.*` formatters |
| Maximum depth | Profondità massima | Maximum depth | Diving / Apnea / Snorkeling | Context-specific keys |
| Average depth | Profondità media | Average depth | Diving | |
| Runtime | Tempo immersione / Runtime | Runtime | Diving | Short labels may keep **Runtime** |
| **TTV** | TTV | TTV | **Gauge only** | Never confused with TTS |
| **TTS** | TTS | TTS | **Full Computer** | Time to surface; expanded in footers |
| **NDL** | NDL | NDL | Full Computer / Planner | No decompression limit |
| **Ceiling** | Ceiling | Ceiling | Full Computer | Operational ascent ceiling |
| Stop depth | Profondità tappa | Stop depth | Full Computer | Distinct from ceiling |
| Decompression stop | Tappa di decompressione | Decompression stop | Diving | |
| **CNS** | CNS | CNS | **Diving Planner only** | Not used in Apnea/Snorkeling |
| **OTU** | OTU | OTU | **Diving Planner only** | Weekly OTU warnings |

## Activity-specific session terms

| Concept | Italian | English | Activity |
|---------|---------|---------|----------|
| Dive (session) | Immersione | Dive | Diving |
| Apnea dive (attempt) | Immersione / tuffo | Dive | Apnea |
| Snorkeling dip | Immersione / dip | Dip | Snorkeling |
| Recovery | Recupero | Recovery | Apnea |
| Route / track | Traccia / percorso | Track / route | Snorkeling |
| Waypoint | Waypoint | Waypoint | Snorkeling |
| Return to entry | Ritorno all'ingresso | Return to entry | Snorkeling |

## Full Computer / gas

| Concept | Italian | English |
|---------|---------|---------|
| Active gas | Gas attivo | Active gas |
| Gas switch | Cambio gas | Gas switch |
| Bottom gas | Gas di fondo | Bottom gas |
| Decompression gas | Gas decompressivo | Decompression gas |
| Hold depth | Mantieni la profondità | Maintain depth |
| Ascend to stop | Risali a %@ | Ascend to %@ |

## GPS policy labels

| Concept | Italian | English | Activity |
|---------|---------|---------|----------|
| Surface GPS (dive entry/exit) | GPS superficie | Surface GPS | Diving |
| Route GPS | GPS percorso | Route GPS | Snorkeling |
| GPS degraded | GPS degradato | GPS degraded | Both |
| GPS unavailable | GPS non disponibile | GPS unavailable | Both |

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

## Units & locale

- Depth: `m` / `ft` via unit preference stores and `Formatters.depth`
- Duration: localized format strings (`live.unit.min`, `fc.imported_plan.runtime_minutes_format`)
- Temperature: `°C` / `°F` via preference
- Pressure: `bar` / `psi` in planner settings
- Dates/numbers: locale-aware formatters at presentation layer

## Export language policy

PDFs, briefings, and user-facing exports use the **active app locale** at export time. Machine-readable JSON field names remain stable English identifiers.

## Cross-activity isolation rules

1. Do not use Diving **CNS/OTU** strings in Apnea or Snorkeling UI.
2. Do not label Snorkeling **dips** with Diving **deco stop** terminology.
3. Do not expose **TTV** in Full Computer surfaces or **TTS** in Gauge surfaces.
4. GPS copy must distinguish **surface capture** (Diving) from **continuous route** (Snorkeling).
