# Ratio Deco External Validation Evidence

**Status:** PENDING_EXTERNAL_VALIDATION  
**Scope:** Ratio Deco heuristic planner (reference-only) vs external simulator or trusted reference tool  
**Rule:** No PASS without attached evidence files in this folder.

## Required profiles

| Profile ID | Description | External source | Tolerance |
|---|---|---|---|
| RD-AIR-30M | Air single-level @ 30 m | External Ratio Deco simulator | GF/depth heuristic ±5 m |
| RD-NX32-35M | EAN32 @ 35 m | External Ratio Deco simulator | Stop count ±1 |
| RD-MULTIGAS | Back + deco stages | External Ratio Deco simulator | First stop depth ±3 m |
| RD-VALIDATOR | Bühlmann validator cross-check | Trusted Bühlmann planner | Reference-only label retained |

## Evidence checklist (per profile)

- [ ] Test profile description
- [ ] Configuration (GF, gases, environment)
- [ ] Reference tool name and version
- [ ] Expected output (screenshot/export)
- [ ] Actual DIR Diving output
- [ ] Tolerance applied
- [ ] Reviewer name
- [ ] Execution date
- [ ] Signature / status field: **PENDING_EXTERNAL_VALIDATION**

Internal unit tests (`Tests/iOSAlgorithmTests/RatioDeco*.swift`) do **not** replace external simulator validation.
