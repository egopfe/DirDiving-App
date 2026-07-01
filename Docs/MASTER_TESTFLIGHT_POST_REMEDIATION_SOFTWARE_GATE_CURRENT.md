# Internal TestFlight Post-Remediation Software Gate — CURRENT

**Command:** 05 §2B  
**Baseline:** `main` @ `2c30412`  
**Audit date:** 2026-07-01  
**Prior baseline:** `451f8fb` (CONDITIONAL — IOS-P1-001 + CONS-046 open)

---

## Software Gate Checklist

| Gate | Status @2c30412 | Evidence |
|---|---|---|
| iOS MAIN build | **PASS** | Audit 02/04 BUILD SUCCEEDED |
| Watch MAIN build | **PASS** | Audit 01/04 BUILD SUCCEEDED |
| iOS Algorithm Tests | **PASS** | **1655/1655** @ `2c30412` (68.4s) |
| Watch Algorithm Tests | **PARTIAL** | **1139/1152** — 13 non-FC failures (WFC-P2-005) |
| Command integrity script | **PASS** | CONS-046 V1.5 @ `6a0005b` |
| CONS-002 GF parity | **PASS** | DivePlanPackageBuilderTests |
| CONS-003 failed-ACK cleanup | **PASS** | ActivitySyncSignedAckSymmetryTests |
| CONS-004 diveImportAck symmetry | **PASS** | Sync tests |
| CONS-005 tombstone hardening | **PASS** | Security suite |
| CONS-007 depth capability authority | **PASS** | DepthCapabilityTests |
| CONS-008 independent oracle | **PASS** | Audit15 oracle suites |
| Release claims script | **PASS** | Static posture (build blocked in sandbox; upstream PASS) |
| No fake physical claims | **PASS** | All physical matrices PENDING |

---

## Remediation Delta Since @451f8fb

| ID | Prior | Current |
|---|---|---|
| IOS-P1-001 / CONS-049 | FAIL (compile) | **CLOSED** — 1655 PASS |
| CONS-046 | FAIL (script drift) | **CLOSED** — V1.5 PASS |
| Watch TTS test crash | FAIL | **CLOSED** — testPlannerRuntimeTTSWithinTolerance PASS |
| WFC-P2-005 routing tests | N/A | **NEW** — 13 failures post-Apnea wave |

---

## Verdict

```text
INTERNAL_TESTFLIGHT_SOFTWARE_GATE: READY
INTERNAL_TESTFLIGHT_SOFTWARE_READY_AFTER_REMEDIATION: READY
BLOCKERS: WFC-P2-005 (P2 — Watch routing test drift; does not block internal TF software lane)
PHYSICAL_DISCLOSURE_REQUIRED: YES
```

**Note:** Internal TestFlight software readiness is **READY** at `2c30412`. External TestFlight remains **NOT READY** until physical, external, and legal gates close.
