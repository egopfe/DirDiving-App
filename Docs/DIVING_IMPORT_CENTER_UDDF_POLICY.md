# Diving Import Center — UDDF Policy

**Scope:** Universal Dive Data Format XML (P2)

---

## Detection

- `.xml` with root `<uddf>` → `uddf`

## Supported structure (tolerant)

- `uddf` → `profiledata` → `repetitiongroup` → `dive`
- Samples via `samples` / `waypoints`

## Multi-dive

- One file may produce multiple `DivingImportCandidate` entries
- Preview allows per-dive selection

## Field mapping

Minimum: start date/time, duration, depth samples, temperature (optional), site, buddy, notes, gas, computer model when present.

## Validation

- Each candidate: `normalizedForStorage(allowEmptySamples: false)`
- Invalid dives shown as non-importable in preview

## Limits

- Max 500 candidates per file
- Max samples per dive: `IOSAlgorithmConfiguration.maxProfileSampleCount`
- Max notes length: 4_000 chars

## Privacy

- File read with security-scoped access; not stored permanently
