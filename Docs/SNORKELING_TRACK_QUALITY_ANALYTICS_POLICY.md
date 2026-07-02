# Snorkeling Track Quality Analytics Policy

**Scope:** iOS Snorkeling session logbook detail.

## Metrics

- Total / measured / stale / unavailable track points
- GPS gap count (timestamp delta > `SnorkelingSessionMapPresentation.maxGapSecondsForContinuousSegment`)
- Longest gap duration when computable
- Measured percentage
- Overall quality key via `SnorkelingLogbookDetailPresentationPolicy.trackQualityKey`

## Quality keys

- `snorkeling.logbook.track_quality.good`
- `snorkeling.logbook.track_quality.degraded`
- `snorkeling.logbook.track_quality.sparse`
- `snorkeling.logbook.track_quality.unavailable`

## Forbidden

- Treating sparse/degraded tracks as navigation-grade fixes
- Underwater GPS quality claims
