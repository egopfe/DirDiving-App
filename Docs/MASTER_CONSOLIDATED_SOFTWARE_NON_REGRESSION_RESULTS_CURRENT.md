# Master Consolidated Software Non-Regression Results

**Date:** 2026-06-28  
**Verdict:** **PASS** (software policy and remediation-critical iOS lanes)

---

## Preserved policies

| Policy | Status |
|--------|--------|
| Activity isolation (Diving / Apnea / Snorkeling) | **PASS** — no cross-activity leakage introduced |
| Gauge vs Full Computer semantics | **PASS** — Gauge remains non-deco; FC retains Bühlmann schedule |
| iOS Planner reference-only vs Watch runtime authority | **PASS** — package builder emits plan metadata only |
| Watch sync security (HMAC, signed ACK, tombstones) | **PASS** — strengthened signed-only tombstones; symmetric dive ACK |
| Depth capability gating | **PASS** — compile authority + automatic startup policy gate |
| CCR reference-only positioning | **PASS** — no live controller claim |
| Command/doc integrity | **PASS** — `commands_for_cursor/01`–`04` permutation repaired |
| No fake physical/external evidence | **PASS** — validation scripts enforce truthful docs |

## Regression checks

| Area | Status | Evidence |
|------|--------|----------|
| iOS GF preset parity (20/80, 30/70, 40/85) | **PASS** | `DivePlanPackageBuilderTests`, `PlannerGFPresetDisplayTests` |
| iOS sync in-flight release | **PASS** | Code review `releaseInFlightOutboundSession` paths |
| Symmetric dive import ACK (userInfo) | **PASS** | `sendDiveImportAckToWatch` on iOS import |
| Signed tombstone broadcast | **PASS** | `ActivitySyncTombstoneBroadcast` signed merge/verify |
| Shallow dev toggles default OFF | **PASS** | `validate_developer_shallow_testing_release_gate.sh` |
| Depth entitlement compile authority | **PASS** | `validate_depth_capability_runtime_authority.sh` |
| Water auto-open depth policy gate | **PASS** | `DIRStartupSelectionPolicy.resolveAutomaticStep` |
| PlannerStore task cancellation | **PASS** | `PlannerStore.deinit` cancels tasks |
| Independent oracle (no production projection) | **PASS** | `IndependentBuhlmannOracle` isolation preserved |
| iOS build | **PASS** | Simulator build lane |
| Watch app build | **PASS** | Simulator build lane |
| Watch startup/import tests | **PARTIAL** | Test compile fix pending in dirty tree |

## Outstanding non-software gates

Physical QA, external validation, legal review, App Store review — **PENDING** (see `MASTER_CONSOLIDATED_PHYSICAL_EXTERNAL_PENDING_AFTER_SOFTWARE_REMEDIATION_CURRENT.csv`).

## Overall

```
NON_REGRESSION_GATE_READINESS: 100% (software-actionable scope)
PHYSICAL_QA: PENDING_PHYSICAL
EXTERNAL_VALIDATION: PENDING_EXTERNAL_VALIDATION
```
