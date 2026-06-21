# Orchestrated Audit Full Remediation — Execution Log (Current)

**Command:** `17-DIR_DIVING_ORCHESTRATED_AUDIT_FULL_REMEDIATION_COMMAND_V1.0.md`  
**Branch:** `codex/orchestrated-audit-full-remediation-v1`  
**Starting commit:** `cc38a47`  
**Started:** 2026-06-21

## Phase A — baselines

- `xcodegen generate` — PASS  
- Watch app build — PASS  
- iOS app build — PASS  
- Watch algorithm tests (pre-fix baseline) — identified missing environment propagation (ORCH-001)

## Phase B — ORCH-001 P0 environment propagation

- Added `FullComputerEnvironmentRecord` with source policy (`iPhonePlanImported`, `watchSettingsManual`, `watchSensorMeasuredProposal`)
- Watch predive store persists draft/confirmed environment atomically with gas profile
- Removed implicit `.seaLevelSaltWater` from live `FullComputerRuntimePlan(profile:)` init
- Package import validates and preserves environment; invalid/missing rejected fail-closed
- Predive/imported-plan UI shows environment + source
- Manual altitude/salinity in Watch Full Computer Settings; optional sensor proposal

## Phase C — ORCH-002 independent altitude oracle

- `IndependentBuhlmannOracle` uses independent ISA/hydrostatic pressure (no `AmbientPressureModel`)
- `OrchestratedAltitudeEnvironmentTests` — 6 tests PASS

## Phase D — ORCH-003 logbook provenance

- Extended `FullComputerDiveLogbookMetadata` with versioned environment fields
- Runtime export captures frozen environment from live plan + confirmed source

## Phase E — ORCH-008 macOS gates @ remediation commit

- Watch build — PASS  
- iOS build — PASS  
- Watch algorithm tests — **960/960 PASS**  
- iOS algorithm tests — **1488/1488 PASS**

## Phase F — ORCH-014 tooling

- `Scripts/scan_prohibited_claims.py` — POSIX path normalization for allowlist matching

## Phases G–L — physical/external/legal (ORCH-004–007, 009–012, 015)

Software prerequisites and QA matrices remain in `Docs/QA_EVIDENCE/**`. **Device, paired-device, field, external-tool, counsel, and App Store evidence require human execution** and are not fabricated in this remediation commit.

## Phase M — documentation

- `Docs/INDEX.md` — orchestrated audit index section  
- This execution log + completion report + traceability CSV
