# DIR DIVING iOS Buhlmann Fixture Sources

Date: 2026-05-29 (reaudit hardening pass)

This document records fixture assumptions used by `Tests/iOSAlgorithmTests/Fixtures/*.json`.

- Model: Buhlmann ZHL-16C N2+He reference engine in `iOSApp/Algorithms/Buhlmann`.
- Water vapor pressure: `0.0627 bar`.
- Default rates: descent `18 m/min`, ascent `9 m/min`.
- Stop interval: `3 m`.
- Safety positioning: non-certified, reference-only planner output.

## Fixture Matrix

- Air: `air-18m.json`, `air-30m.json`, `air-40m.json`
- Nitrox: `nitrox32-30m.json`
- Trimix bottom/deco: `trimix-bottom.json`, `trimix-ean50.json`, `trimix-ean50-o2.json`
- GF comparison: `gf-30-70.json`, `gf-50-80.json`
- Pressure context profiles: `altitude-profile.json`, `fresh-vs-salt-profile.json`
- Repetitive planning profile: `repetitive-surface-interval.json`
- Duplicate label / stable ID profile: `duplicate-gas-labels.json`
- Oxygen exposure deco profile: `oxygen-exposure-deco.json`
- Contingency profile: `lost-deco-gas.json`
- Invalid/fail-closed fixtures:
  - `invalid-gas-composition.json`
  - `mod-violation.json`
  - `hypoxic-too-shallow.json`
  - `gas-switch-too-deep.json`

## Tolerance Policy

- TTS/stop expectations are range-based, not exact decompression equivalence.
- Default tolerance in fixtures is explicit (`toleranceMinutes`); parser rejects malformed/incomplete schema.
- Invalid fixtures must fail closed with blocking model issues.
- No fixture path may return fake `999` NDL or NaN/infinity outputs.

## External References

- Bühlmann ZHL-16C public coefficient tables (N2/He, a/b half-times).
- NOAA oxygen exposure tables for CNS/OTU-style reference thresholds.
- Decotengu-style envelope comparisons (coarse tolerance, never exact parity claims).
