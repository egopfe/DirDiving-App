# DIRDiving CCR Planner Safety Acknowledgement Fix

**Date:** 2026-07-02  
**Branch:** `main`

---

## Bug summary

CCR planner mode was gated by the same generic OC/Technical planner safety acknowledgement (`PlannerSafetyAcknowledgment`). Accepting the generic toggle in Base/Deco/Technical also unlocked CCR without a CCR-specific acknowledgement.

Italian generic label contained grammar typo: **"e solo indicativo"** instead of **"è solo indicativo"**.

---

## Root cause

- `CCRPlannerView` and `CCRPlanResultView` used `PlannerSafetyAcknowledgment.storageKey`
- No independent CCR acknowledgement persistence
- CCR UI showed generic warning text without dedicated toggle (unlock inherited from generic ack)

---

## Fix

- Added `CCRPlannerSafetyAcknowledgment` with separate `@AppStorage` key and revision
- Added `PlannerSafetyGatePolicy` for mode-aware gating (UI only)
- `CCRPlannerView`: CCR-specific toggle; content gated by CCR ack only
- `CCRPlanResultView`: PDF export context uses CCR ack
- `PlannerView`: mode-aware `effectivePlannerSafetyAcknowledged` (defensive; CCR routes via `CCRPlannerView`)
- Localization: `planner.ccr.safety_ack.*` + Italian typo fix on `planner.safety_ack.label`

---

## Files changed

- `iOSApp/Utils/PlannerSafetyAcknowledgment.swift`
- `iOSApp/Views/CCR/CCRPlannerView.swift`
- `iOSApp/Views/CCR/CCRPlanResultView.swift`
- `iOSApp/Views/PlannerView.swift`
- `iOSApp/Resources/en.lproj/Localizable.strings`
- `iOSApp/Resources/it.lproj/Localizable.strings`
- `Tests/iOSAlgorithmTests/PlannerSafetyGatePolicyTests.swift`

---

## No algorithmic changes

- `CCRPlannerService` — **not modified**
- Bühlmann / GF / CNS / MOD / OTU — **not modified**
- Planner numerical outputs — **unchanged**
- Watch runtime — **not modified**

---

## Tests executed

- `PlannerSafetyGatePolicyTests` (new)
- Existing planner/CCR algorithm tests preserved (not modified)

---

## Manual UI QA checklist (PENDING)

- [ ] CCR mode shows CCR acknowledgement toggle with correct IT/EN text
- [ ] Generic planner ack alone does not unlock CCR fields
- [ ] CCR ack alone does not unlock Technical/Base/Deco planner
- [ ] Toggling CCR ack enables CCR calculate flow
- [ ] CCR PDF export respects CCR acknowledgement

---

## Software readiness

UI safety acknowledgement / persistence / localization fix only. No regression to planner calculation or decompression algorithms.
