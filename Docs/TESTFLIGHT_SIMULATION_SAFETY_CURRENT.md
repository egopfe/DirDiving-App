# TestFlight Simulation Safety (Current)

**Command:** 10 remediation  
**Date:** 2026-06-20  
**Finding:** SEC-P2-004 — **FIXED**

---

## Policy owner

`Shared/Utils/TestFlightSimulationSafetyPolicy.swift`  
`Shared/Utils/DivingRecordEligibilityPolicy` (simulated source tag)

---

## Build classes

| Build | Simulation selectable | Notes |
|-------|----------------------|-------|
| DEBUG | Via developer unlock | Local development |
| TestFlight (`sandboxReceipt`) | Yes, after acknowledgment | Beta testing only |
| App Store release | **No** | `normalizeSensorSourceForRelease` forces automatic |

---

## Acknowledgment

| Key | Purpose |
|-----|---------|
| `dirdiving_testflight_simulation_acknowledged_v1` | User accepted simulation risk |
| `dirdiving_testflight_simulation_disclosure_required` | Disclosure gate flag |

`DeveloperSettings.allowsSimulationSensorSelection` respects receipt class and acknowledgment.

---

## Session provenance

`DiveSession.depthSensorSourceTag`:

- `simulation` when depth from simulated sensor
- Exported in Subsurface CSV as `dirdiving_depth_sensor_source: simulation`
- `DivingRecordEligibilityPolicy.isSimulatedSession` for eligibility checks

---

## Release hygiene

- App Store archives: simulation not selectable (existing receipt check + policy)
- TestFlight: document in release notes that simulated depth is not for real diving

---

## Validation

| Test | Matrix ID |
|------|-----------|
| `testSimulatedSessionTagDetection` | SEC-NEG-19 |
| `testWatchSubsurfaceExportTagsSimulation` | REQ-SEC-REM-04 |
