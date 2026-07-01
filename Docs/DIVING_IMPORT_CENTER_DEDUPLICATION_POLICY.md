# Diving Import Center — Deduplication Policy

**Scope:** Preview classification and commit policy (P1/P2)

---

## Duplicate status

| Status | Meaning |
|--------|---------|
| `new` | No match in existing logbook |
| `exactDuplicate` | Same session ID, or same source dive ID in notes |
| `likelyDuplicate` | Matching fingerprint within tolerances |

## Fingerprint

- startDate bucket (minute)
- durationSeconds
- maxDepthCentimeters
- sampleCount
- optional sourceDiveID / sourceComputerModel

## Tolerances

- Start date: ±60 s
- Duration: ±30 s
- Max depth: ±0.5 m
- Sample count: exact match (with above)

## UI defaults

- **New:** checked, importable
- **Duplicate / likely duplicate:** unchecked, disabled toggle
- **Non-importable:** disabled

## Commit policy

- Default: `skipDuplicates`
- Alternative: `importAnyway` (does not overwrite existing sessions)
- No overwrite of existing `DiveSession` in P1/P2

## Tests

- `DivingImportDeduplicatorTests`
- `DivingImportCommitterTests` (preview row selection defaults)
