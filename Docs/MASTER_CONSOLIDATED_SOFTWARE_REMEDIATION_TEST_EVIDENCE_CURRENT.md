# Master Consolidated Software Remediation — Test Evidence

**Date:** 2026-06-28  
**Branch:** `main`  
**Working tree:** `626c619` + dirty remediation fixes  
**Command:** `Docs/0000MASTER_SOFTWARE_REMEDIATION_TO_100_READINESS_COMMAND_V1.0.md`  
**Gate script:** `Scripts/validate_consolidated_software_readiness.sh`

---

## Integrity and claims gates

| Gate | Command | Result |
|------|---------|--------|
| Command permutation | `bash Scripts/validate_commands_for_cursor_integrity.sh` | **PASS** |
| Depth runtime authority | `bash Scripts/validate_depth_capability_runtime_authority.sh` | **PASS** |
| Shallow dev toggle release gate | `bash Scripts/validate_developer_shallow_testing_release_gate.sh` | **PASS** |
| No fake physical evidence | `bash Scripts/validate_no_fake_physical_evidence_claims.sh` | **PASS** |
| No fake external validation | `bash Scripts/validate_no_fake_external_validation_claims.sh` | **PASS** |
| Release claims vs evidence | `bash Scripts/validate_release_claims_against_evidence.sh` | **PASS** |
| Target isolation | `bash Scripts/check_main_target_isolation.sh` | **PASS** |
| Secrets scan | `bash Scripts/check_secrets.sh` | **PASS** |
| Localization audit | `bash Scripts/audit_localization.sh` | **PASS** |

## Build gates

| Target | Destination | Result |
|--------|-------------|--------|
| DIRDiving iOS | `platform=iOS Simulator,name=iPhone 17` | **BUILD SUCCEEDED** |
| DIRDiving Watch App | `platform=watchOS Simulator,name=Apple Watch Ultra 3 (49mm)` | **BUILD SUCCEEDED** (consolidated script lane) |

## Remediation-critical tests

| Suite | Filter | Result |
|-------|--------|--------|
| DIRDiving iOS Algorithm Tests | `DivePlanPackageBuilderTests` | **PASS** |
| DIRDiving iOS Algorithm Tests | `PlannerGFPresetDisplayTests` | **PASS** |
| Combined iOS remediation subset | 15 tests | **PASS** (0 failures) |

### Watch remediation subset

| Suite | Filter | Result |
|-------|--------|--------|
| DIRDiving Watch Algorithm Tests | `DIRModesAndStartupFlowTests` | **PASS** (14/14) |
| DIRDiving Watch Algorithm Tests | `FullComputerImportedPlanStoreTests` | **PASS** (20/20) |
| DIRDiving Watch Algorithm Tests | `IntegratedModesSequentialFlowTests` | **PASS** (2/2) |

Test maintenance aligned with CONS-006/CONS-007/CONS-019: shallow dev toggles + sensor source reset in startup/integration tests; `SalinityMode.salt` (not legacy `.saltWater`); `project.yml` preserves `DEBUG` alongside `DEPTH_ENTITLEMENT_SHALLOW`.

Full consolidated script exit: **PASS** (`validate_consolidated_software_readiness.sh`).

## Evidence commands (exact)

```bash
xcodegen generate
bash Scripts/validate_consolidated_software_readiness.sh

xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving iOS" \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build

xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving iOS Algorithm Tests" \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -only-testing:'DIRDiving iOS Algorithm Tests/DivePlanPackageBuilderTests' \
  -only-testing:'DIRDiving iOS Algorithm Tests/PlannerGFPresetDisplayTests' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO test
```

## Not executed / not claimed

- Physical Apple Watch wet depth, CMAltimeter, paired-device sync UI, accessibility manual, pixel baselines, field battery/thermal profiling
- External Bühlmann tool comparison, Subsurface desktop round-trip, legal counsel sign-off
- Full Watch algorithm suite (1091 tests) — blocked by test compile in dirty tree

## Verdict

Remediation-critical **iOS** software evidence: **PASS**. Consolidated automation gate: **PARTIAL** (Watch test compile fix pending). No physical or external evidence fabricated.
