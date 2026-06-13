# CCR External Validation Evidence

**Status:** PENDING  
**Scope:** CCR planner reference path (setpoint, diluent, density, CNS/OTU, heuristic bailout)  
**Rule:** No PASS without attached evidence files in this folder.

## Required profiles

| Profile ID | Description | External source | Tolerance |
|---|---|---|---|
| CCR-AIR-DIL-40M | Air diluent, SP 0.7/1.3 | CCR reference material | Density ±0.15 g/L |
| CCR-TX-18-45-40M | Trimix diluent | CCR reference material | Density ±0.15 g/L |
| CCR-SP-SWITCH | Setpoint switch @ 20 m | CCR reference material | Timeline continuity |
| CCR-CNS-OTU | Full profile CNS/OTU | NOAA tables cross-check | ±5% CNS |
| CCR-BAILOUT-HEUR | Heuristic bailout scenarios | Documented SAC policy | Qualitative only |

## Evidence checklist

- [ ] External CCR planning reference outputs
- [ ] Tester name and date
- [ ] Tool / worksheet version
- [ ] Link to internal tests (`CCRMathAuditRemediationV1Tests`, `CCRPlannerTests`)
- [ ] Result field: PENDING / PASS / FAIL

Heuristic bailout remains **non-authoritative** even after PASS on gas volume checks.
