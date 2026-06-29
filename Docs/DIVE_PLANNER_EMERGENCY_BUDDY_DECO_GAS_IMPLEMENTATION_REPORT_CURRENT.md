# Diving Planner Emergency Buddy Deco Gas — Implementation Report

**Status:** INTERNAL_READY · PHYSICAL_QA_PENDING  
**Branch:** main

## Verdict

```text
INTERNAL_READY
PHYSICAL_QA_PENDING
DIVE_PLANNER_EMERGENCY_BUDDY_DECO_GAS_READY
NO_DECO_ALGORITHM_CHANGE
NO_RUNTIME_CHANGE
PER_GAS_ADEQUACY_CHECK_READY
```

## Summary

Emergency-section toggle `includeBuddyDecoGas` (default OFF) drives per-deco-gas adequacy in plan results and briefing without modifying Bühlmann schedule or runtime.

## Key files

| Area | File |
|------|------|
| Options model | `iOSApp/Models/DivePlannerEmergencyOptions.swift` |
| Adequacy model | `iOSApp/Models/DecoGasAdequacyResult.swift` |
| Calculation | `iOSApp/Services/DivePlannerEmergencyDecoGasService.swift` |
| Persistence | `GasPlanInput.includeBuddyDecoGas` |
| Planner integration | `PlannerService.swift` |
| UI input | `PlannerView.emergencyCard` |
| UI results | `PlanResultView.emergencyDecoGasCard` |
| Tests | `DivePlannerEmergencyBuddyDecoGasTests.swift`, `DivePlannerEmergencyGasAdequacyTests.swift` |
