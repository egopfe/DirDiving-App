# iOS raster snapshot regression policy (current)

**Command 14 remediation — software gate only**

## Scope

19 iOS canonical mockups (15 Apnea + 3 Snorkeling + 1 Companion selection + FC_UI_07 plan transfer = **20** iOS raster rows including FC_UI_07).

## Layered approach

1. **Structural contract** — implementation view exists; required localization and accessibility identifiers present (`IOSMockupSnapshotContracts`).
2. **Deterministic presentation fingerprint** — fixed date/locale presentation mappers produce stable SHA-256 payloads (`IOSMockupRasterSnapshotTests`).
3. **PNG dimension validation** — committed mockup IHDR width/height match contract (768×1024 companion screens; 853×1844 activity selection).
4. **Physical pixel-diff** — **PENDING** (`Docs/QA_EVIDENCE/PHYSICAL_PIXEL_DIFF/`). Simulator captures do **not** satisfy physical QA.

## Tolerance

- Presentation fingerprint: exact match (zero tolerance) for deterministic mapper outputs.
- PNG dimensions: exact match to canonical mockup IHDR.
- Physical overlay diff: not automated in CI; manual evidence template defines per-device tolerance.

## Non-goals

- Mockup PNGs are never embedded in live UI or app bundles.
- Mockup PNGs are not App Store screenshots.
- Raster baselines in tests validate contracts and dimensions — not claimed as device pixel parity.

## Validation

`IOSMockupRasterSnapshotTests` + `./Scripts/validate_mockup_visual_regression_readiness.sh`
