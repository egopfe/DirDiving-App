# iOS Planner — NDL Chart Truthfulness

**Scope:** `DIRDiving iOS` Bühlmann tab, reference-only planner.

## Implementation (Option A)

The NDL chart plots **model-backed** points from `BuhlmannPlanner.ndlCurve` / `store.buhlmann.curve`:

- **X-axis:** depth (m) — `NDLPoint.depthMeters`
- **Y-axis:** NDL minutes — `NDLPoint.ndlMinutes`

The decorative formula `Y = max(0, 100 − depth×1.5)` was removed.

## Copy

- Card disclaimer (`planner.buhlmann.curve_disclaimer`): states reference NDL from the engine, non-certified, not tissue loading.
- NDL footnote (`planner.ndl.reference_ascent_footnote`): fixed 9 m/min reference ascent for NDL preview.
- Existing reference-only / non-certified planner headers unchanged.

## Tests

- `IOSMainAlgorithmReadinessTests.testNDLCurveUsesDepthAndNDLAxes`
- Existing Bühlmann NDL engine tests in `Tests/iOSAlgorithmTests/`
