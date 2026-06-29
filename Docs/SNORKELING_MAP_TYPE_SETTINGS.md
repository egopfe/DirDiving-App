# Snorkeling Map Type Settings

Snorkeling-only user preference for map basemap style on iOS companion maps.

## Options

| User label | Technical MapKit style | Use case |
|------------|------------------------|----------|
| **Satellite** (default) | `.hybrid` | Satellite imagery + labels — coast, bays, entry/exit |
| **Explore** | `.standard` | Cartographic basemap — roads, places, orientation |

## Scope

Applied to Snorkeling iOS maps only:
- Route Planner
- Session detail map
- Dashboard track preview

Watch stores the same preference for settings parity; no interactive Watch map view exists today.

**Not applied to:** Diving, Full Computer, Gauge, Apnea.

## Persistence

UserDefaults key: `dirdiving.snorkeling.mapType`  
Invalid/missing values fall back to `satellite`.

## QA

Physical device QA required — see `Docs/QA_EVIDENCE/SNORKELING_MAP_TYPE_*`.
