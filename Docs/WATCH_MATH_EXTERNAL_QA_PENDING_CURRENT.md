# Watch Mathematical Functions — External QA Pending

**Updated:** 2026-06-19  
**Audit:** `0W-DIR_DIVING_WATCH_COMPLETE_MATH_FUNCTIONS_AUDIT_V3.0`  
**Branch:** `main` @ `448f015`  
**Software evidence:** 856 Watch Algorithm Tests, 0 failed, 0 skipped (Apple Watch Series 11 46mm simulator)

These gates **cannot** be closed by simulator/unit tests alone. No fabricated field evidence is claimed.

| Gate ID | Description | Status | Required evidence |
|---|---|---|---|
| WATCH-EXT-001 | Independent external Bühlmann reference validation on Watch hardware | **PENDING** | Third-party reference vectors; field or lab comparison |
| WATCH-PHY-001 | Apple Watch Ultra physical depth/ascent/haptic accuracy | **PENDING** | Completed `Docs/WATCH_ULTRA_PHYSICAL_QA_MATRIX.md` rows |
| WATCH-PHY-002 | Paired iPhone/Watch mathematical sync round-trip | **PENDING** | Completed `Docs/WATCH_IOS_SYNC_QA_MATRIX.md` rows |
| WATCH-PERF-001 (physical) | Long-dive battery/thermal impact on math sampling cadence | **PENDING** | Ultra field battery/thermal logs |
| UNDERWATER-QA | Real underwater Gauge/FC validation | **PENDING** | Signed field dive logs |
| GPS-FIELD-QA | Real-world Snorkeling GPS distance/bearing validation | **PENDING** | Measured course comparison |

## Software vs physical classification

| Category | Before remediation | After remediation |
|---|---:|---:|
| Watch Algorithm Tests executed | 844 | **856** |
| Skipped (software-only) | 19 | **0** |
| Failed | 0 | **0** |

## Audit-15 mandatory profile (Air 39 m)

The full named profile (39 m until mandatory deco → 10 m → second-by-second tissue/schedule observation) is **partially covered** by software multilevel tests (`FullComputerRuntimeEngineTests`, `FullComputerDecoSolverTests`, `FullComputerReleaseHardValidationTests`) but **lacks independent oracle and physical Watch evidence**. Status: **PENDING_EXTERNAL_VALIDATION**.

## Release posture

```text
WATCH_MATH_SOFTWARE_GATE: PASS (856/856)
WATCH_MATH_EXTERNAL_VALIDATION: PENDING
WATCH_MATH_PHYSICAL_ULTRA_QA: PENDING
EXTERNAL_WATCH_MATH_RELEASE_GATE: PENDING_EXTERNAL_EVIDENCE
```

Simulator mathematical tests passing does **not** certify the Watch as a dive computer.
