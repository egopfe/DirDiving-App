# Bühlmann External Validation Evidence

**Status:** PENDING  
**Scope:** Open-circuit Bühlmann ZHL-16C planner (Base / Deco / Technical)  
**Rule:** No PASS without attached evidence files in this folder.

## Required profiles

| Profile ID | Description | External source | Tolerance |
|---|---|---|---|
| OC-AIR-NDL-18M | Air no-deco @ 18 m | Trusted external planner | ±2 min NDL |
| OC-NX32-30M | EAN32 @ 30 m | Trusted external planner | ±3 min runtime |
| OC-TX-18-45-40M | Trimix 18/45 @ 40 m | Trusted external planner | ±5 min TTS |
| OC-MULTIGAS-DECO | Back + 2 deco stages | Trusted external planner | Stop depths ±3 m |
| OC-ALT-FW | Altitude + freshwater | Trusted external planner | MOD/ceiling ±2 m |

## Evidence checklist

- [ ] Screenshots or export files from external tool
- [ ] Tester name and date
- [ ] Device / tool version
- [ ] Internal fixture cross-reference (`Tests/iOSAlgorithmTests/BuhlmannReferenceFixtureTests.swift`)
- [ ] Result field: PENDING / PASS / FAIL

Internal fixtures do **not** replace external validation.
