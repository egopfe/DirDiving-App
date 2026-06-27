# Apple Shallow Depth QA Plan

Physical shallow-water validation is **required** before any external release claiming real Apple shallow sensor support. All evidence folders default to **PENDING**.

## Evidence folders

| ID | Folder | Scope |
|----|--------|-------|
| 1 | `SHALLOW_SENSOR_AUTHORIZATION` | Entitlement + system authorization |
| 2 | `SHALLOW_SENSOR_START_STOP` | Provider lifecycle |
| 3 | `SHALLOW_DEPTH_SAMPLE_VALIDITY` | Depth/pressure/temperature validity |
| 4 | `SHALLOW_WATER_ENTRY_EXIT` | Submersion state transitions |
| 5 | `SHALLOW_SNORKELING_SESSION` | End-to-end Snorkeling with real shallow data |
| 6 | `SHALLOW_APNEA_SESSION` | End-to-end Apnea with limitation copy |
| 7 | `SHALLOW_SENSOR_LOSS` | Degraded/unavailable handling |
| 8 | `SHALLOW_RELAUNCH_RECOVERY` | Relaunch preserves source, not simulation |
| 9 | `SHALLOW_SYNC_TO_IOS` | Watch → iOS metadata round-trip |
| 10 | `SHALLOW_LOGBOOK_IMPORT` | Logbook shows "Apple Shallow" |
| 11 | `SHALLOW_ACTIVITY_GATING` | Gauge/Full Computer blocked appropriately |
| 12 | `SHALLOW_FULL_COMPUTER_BLOCKED` | Shallow cannot start Full Computer |

Each folder contains a `README.md` template with: branch, commit, tester, reviewer, date/time, devices, provisioning, steps, expected/observed, artifacts, PASS/FAIL/PENDING, signatures.

## Preconditions

- Apple Watch with shallow depth entitlement provisioning
- Shallow build: `DIRDepthEntitlementTier=shallow`, `DIRDiving.WithShallowDepth.entitlements`
- Paired iPhone with companion app build from same branch/commit
- Shallow-water test environment (controlled pool / approved shallow site)

## Validation script

```bash
./Scripts/validate_apple_shallow_depth_readiness.sh --internal   # may pass with PENDING evidence
./Scripts/validate_apple_shallow_depth_readiness.sh --release    # fails until evidence signed PASS
```

## Sign-off criteria (external)

All twelve `SHALLOW_*` folders must contain signed PASS records with reviewer approval before changing release verdict from `EXTERNAL_NO_GO`.

## Current verdict

- **INTERNAL_IMPLEMENTATION_READY** — code and deterministic tests
- **PHYSICAL_SHALLOW_QA_PENDING** — no signed shallow-water runs
- **EXTERNAL_NO_GO** — do not ship shallow sensor claims externally
