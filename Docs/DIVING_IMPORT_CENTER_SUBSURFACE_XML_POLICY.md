# Diving Import Center — Subsurface XML Policy

**Scope:** File-based Subsurface XML export (P2)

---

## Detection

- `.xml` with root path containing `divelog` / `dives` / `dive` → `subsurfaceXML`

## Supported structure (tolerant)

```xml
<divelog>
  <dives>
    <dive date="..." time="..." duration="..." maxdepth="...">
      <divecomputer model="...">
        <sample time="..." depth="..." temp="..." />
      </divecomputer>
    </dive>
  </dives>
</divelog>
```

## Field mapping

| Source | DiveSession |
|--------|-------------|
| date + time | startDate |
| duration | durationSeconds / endDate |
| maxdepth | maxDepthMeters |
| meandepth / avgdepth | avgDepthMeters |
| temp (samples) | avgWaterTemperatureCelsius |
| site / location | siteName |
| buddy | buddy |
| notes | notes |
| gas | notes if unmapped |
| GPS attributes | entryGPS / exitGPS |
| computer model | notes metadata |
| dive id / number | sourceDiveID fingerprint |

## Samples policy

- Profile requires samples for importable candidate
- Missing samples → `.missingSamples` warning, non-importable
- Must pass `DiveSessionAlgorithmValidator.normalizedForStorage`

## Units

- Parsed via `DivingImportUnitParser` (m/ft, C/F, min/sec)

## Exclusions

- No Subsurface Cloud
- No live sync
